#!/bin/bash

# verify.sh - Automated tests for GnuCOBOL Breathwork Server
PORT=8080
SERVER_PID=""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================"
echo " Starting Automated API Verification"
echo "========================================"

# Step 1: Compile
echo "Compiling server..."
make clean
make
if [ $? -ne 0 ]; then
    echo -e "${RED}Compilation failed!${NC}"
    exit 1
fi
echo -e "${GREEN}Compilation successful.${NC}"

# Terminate any existing server processes
pkill -f "./server" || true

# Ensure database is fresh for testing
make clean-db

# Step 2: Start server in background
echo "Starting COBOL server on port $PORT..."
./server > server_test.log 2>&1 &
SERVER_PID=$!

# Wait for server to bind
sleep 2

# Check if server is running
if ! ps -p $SERVER_PID > /dev/null; then
    echo -e "${RED}Failed to start server. Output:${NC}"
    cat server_test.log
    exit 1
fi
echo -e "${GREEN}Server running with PID $SERVER_PID.${NC}"

# Helper function to print test results
assert_contains() {
    local url=$1
    local method=$2
    local data=$3
    local expected=$4
    local desc=$5
    local response=""

    echo -n "Test: $desc ... "
    if [ "$method" == "POST" ]; then
        response=$(curl -s -X POST -H "Content-Type: application/json" -d "$data" "$url")
    else
        response=$(curl -s "$url")
    fi

    if echo "$response" | grep -q "$expected"; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        echo "  Sent: $method $url $data"
        echo "  Expected: $expected"
        echo "  Got: $response"
        cleanup
        exit 1
    fi
}

cleanup() {
    if [ -n "$SERVER_PID" ]; then
        echo "Stopping COBOL server (PID $SERVER_PID)..."
        kill $SERVER_PID
        wait $SERVER_PID 2>/dev/null
    fi
    if [ -f server_test.log ]; then
        echo "=== Server Output Log ==="
        cat server_test.log
        echo "========================="
        rm -f server_test.log
    fi
}

# Run tests
# 1. Check Homepage
echo -n "Test: Serve dashboard.html ... "
resp_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/)
if [ "$resp_code" == "200" ]; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL (HTTP $resp_code)${NC}"
    cleanup
    exit 1
fi

# 2. Get Methods
assert_contains "http://localhost:$PORT/api/methods" "GET" "" "Box Breathing" "Retrieve breathing methods list"

# 3. Check Initial Status (should be online and LOCKED)
assert_contains "http://localhost:$PORT/api/status" "GET" "" '"lock_status":"LOCKED"' "Status check reflects LOCKED state"

# 4. Check Sessions when locked (should say locked:true)
assert_contains "http://localhost:$PORT/api/sessions" "GET" "" '{"locked":true}' "Sessions endpoint is hidden when locked"

# 5. Log a session
assert_contains "http://localhost:$PORT/api/sessions" "POST" '{"method":"Box Breathing","duration":"120","notes":"Test notes"}' '{"success":true}' "Log a new completed session"

# 6. Unlock with wrong PIN (should return error)
assert_contains "http://localhost:$PORT/api/lock/toggle" "POST" '{"pin":"9999"}' '{"success":false,"error":"Invalid PIN"}' "Lock toggle fails with invalid PIN"

# 7. Unlock with correct PIN (default 1234)
assert_contains "http://localhost:$PORT/api/lock/toggle" "POST" '{"pin":"1234"}' '{"success":true,"state":"UNLOCKED"}' "Lock toggle succeeds with valid PIN 1234"

# 8. Check Sessions when unlocked (should show the logged session)
assert_contains "http://localhost:$PORT/api/sessions" "GET" "" '"notes":"Test notes"' "Sessions endpoint returns session log when unlocked"

# 9. Lock again (should toggle to LOCKED)
assert_contains "http://localhost:$PORT/api/lock/toggle" "POST" '{}' '{"success":true,"state":"LOCKED"}' "Toggling lock while unlocked locks it without needing PIN"

# 10. Check Sessions when locked again (should hide logs)
assert_contains "http://localhost:$PORT/api/sessions" "GET" "" '{"locked":true}' "Sessions endpoint is hidden again after locking"

# Final Success
cleanup
echo "========================================"
echo -e "${GREEN} All tests passed successfully!${NC}"
echo "========================================"
exit 0

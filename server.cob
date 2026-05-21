       IDENTIFICATION DIVISION.
       PROGRAM-ID. COBOL-BREATH-SERVER.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT HTML-FILE ASSIGN TO "dashboard.html"
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS HTML-STATUS.

           SELECT SESSIONS-FILE ASSIGN TO "sessions.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS SESSIONS-STATUS.

           SELECT LOCK-FILE ASSIGN TO "lock.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS LOCK-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  HTML-FILE.
       01  HTML-LINE           PIC X(1000).

       FD  SESSIONS-FILE.
       01  SESSION-REC.
           05  SESS-TIME       PIC X(19).
           05  SESS-DELIM-1    PIC X VALUE "|".
           05  SESS-METHOD     PIC X(30).
           05  SESS-DELIM-2    PIC X VALUE "|".
           05  SESS-DURATION   PIC X(6).
           05  SESS-DELIM-3    PIC X VALUE "|".
           05  SESS-NOTES      PIC X(50).

       FD  LOCK-FILE.
       01  LOCK-REC.
           05  LOCK-PIN        PIC X(4).
           05  LOCK-DELIM      PIC X VALUE "|".
           05  LOCK-STATE      PIC X(8).

       WORKING-STORAGE SECTION.
       *> Networking and server control
       01  PORT                 BINARY-LONG VALUE 8080.
       01  SERVER-FD            BINARY-LONG.
       01  CLIENT-FD            BINARY-LONG.
       01  REQ-LEN              BINARY-LONG.
       01  REQ-BUFFER           PIC X(16384).
       01  RESP-BUFFER          PIC X(16384).
       01  RESP-LEN             BINARY-LONG.
       
       *> HTTP Parsing
       01  REQ-METHOD           PIC X(10).
       01  REQ-PATH             PIC X(255).
       01  REQ-BODY             PIC X(8192).
       
       *> File control variables
       01  HTML-STATUS          PIC XX.
       01  SESSIONS-STATUS      PIC XX.
       01  LOCK-STATUS          PIC XX.
       
       01  EOF-FLAG             PIC X VALUE 'N'.
           88  EOF-REACHED      VALUE 'Y'.
           88  EOF-NOT-REACHED  VALUE 'N'.

       *> Session and System variables
       01  REQ-COUNT            BINARY-LONG VALUE 0.
       01  CURRENT-UPTIME       BINARY-LONG VALUE 0.
       01  CURR-TIME-RAW        PIC X(21).
       01  CURR-TIME-DISP       PIC X(19).
       
       *> Current lock configuration (loaded on startup/updated)
       01  SYS-PIN              PIC X(4) VALUE "1234".
       01  SYS-STATE            PIC X(8) VALUE "LOCKED  ".

       *> Temp fields for JSON processing
       01  JSON-TEMP            PIC X(1000).
       01  JSON-ARRAY           PIC X(12000).
       01  JSON-POINTER         BINARY-LONG.
       01  SESS-COUNT           BINARY-LONG.
       
       *> JSON Extraction fields
       01  EXTRACTED-PIN        PIC X(4).
       01  EXTRACTED-METHOD     PIC X(30).
       01  EXTRACTED-DURATION   PIC X(6).
       01  EXTRACTED-NOTES      PIC X(50).

       *> Formatting variables
       01  UPTIME-DISP          PIC ZZZZZ9.
       01  REQ-COUNT-DISP       PIC ZZZZZ9.

       PROCEDURE DIVISION.
       MAIN-PROGRAM.
           DISPLAY "========================================"
           DISPLAY "   COBOL Breathwork Server Starting     "
           DISPLAY "========================================"
           
           *> Start timer
           CALL "record_start_time"
           
           *> Initialize lock file or load values
           PERFORM INITIALIZE-LOCK-SYSTEM
           PERFORM INITIALIZE-DATABASE
           
           *> Start TCP Server
           CALL "server_init" USING BY VALUE PORT RETURNING SERVER-FD
           IF SERVER-FD < 0
               DISPLAY "Error: Failed to bind to port " PORT
               STOP RUN
           END-IF
           
           DISPLAY "Server listening on http://localhost:" PORT "/"
           
           PERFORM SERVER-LOOP UNTIL 1 = 0
           
           CALL "server_close" USING BY VALUE SERVER-FD
           STOP RUN.

       INITIALIZE-LOCK-SYSTEM.
           OPEN INPUT LOCK-FILE
           IF LOCK-STATUS = "35" OR LOCK-STATUS = "05" OR LOCK-STATUS = "46"
               CLOSE LOCK-FILE
               OPEN OUTPUT LOCK-FILE
               MOVE "1234" TO LOCK-PIN
               MOVE "LOCKED" TO LOCK-STATE
               WRITE LOCK-REC
               CLOSE LOCK-FILE
               MOVE "1234" TO SYS-PIN
               MOVE "LOCKED" TO SYS-STATE
               DISPLAY "Initialized lock.dat with default PIN 1234"
           ELSE
               READ LOCK-FILE
                   AT END
                       MOVE "1234" TO SYS-PIN
                       MOVE "LOCKED" TO SYS-STATE
                   NOT AT END
                       MOVE LOCK-PIN TO SYS-PIN
                       MOVE LOCK-STATE TO SYS-STATE
               END-READ
               CLOSE LOCK-FILE
               DISPLAY "Loaded PIN: " SYS-PIN " State: " FUNCTION TRIM(SYS-STATE)
           END-IF.

        INITIALIZE-DATABASE.
            OPEN INPUT SESSIONS-FILE
            IF SESSIONS-STATUS = "35" OR SESSIONS-STATUS = "05" OR SESSIONS-STATUS = "46"
                CLOSE SESSIONS-FILE
                OPEN OUTPUT SESSIONS-FILE
                CLOSE SESSIONS-FILE
                DISPLAY "Initialized sessions.dat database file"
            ELSE
                CLOSE SESSIONS-FILE
                DISPLAY "Sessions database file loaded successfully. Status: " SESSIONS-STATUS
            END-IF.

       SAVE-LOCK-SYSTEM.
           OPEN OUTPUT LOCK-FILE
           MOVE SYS-PIN TO LOCK-PIN
           MOVE SYS-STATE TO LOCK-STATE
           WRITE LOCK-REC
           CLOSE LOCK-FILE.

       SERVER-LOOP.
           CALL "server_accept" USING BY VALUE SERVER-FD RETURNING CLIENT-FD
           IF CLIENT-FD >= 0
               ADD 1 TO REQ-COUNT
               
               *> Read Request
               CALL "client_read" USING BY VALUE CLIENT-FD
                                        BY REFERENCE REQ-BUFFER
                                        BY VALUE 16384
                                        RETURNING REQ-LEN
                                        
               IF REQ-LEN > 0
                   INITIALIZE REQ-METHOD
                   INITIALIZE REQ-PATH
                   *> Extract Method and Path
                   UNSTRING REQ-BUFFER DELIMITED BY ALL SPACE
                       INTO REQ-METHOD
                            REQ-PATH
                   END-UNSTRING
                   
                   DISPLAY "Request " REQ-COUNT ": " FUNCTION TRIM(REQ-METHOD) " " FUNCTION TRIM(REQ-PATH)
                   
                   *> Extract Body
                   INITIALIZE REQ-BODY
                   CALL "find_http_body" USING BY REFERENCE REQ-BUFFER
                                               BY REFERENCE REQ-BODY
                                               BY VALUE 8192
                   
                   *> Route Request
                   PERFORM ROUTE-REQUEST
               END-IF
               
               CALL "client_close" USING BY VALUE CLIENT-FD
           END-IF.

       ROUTE-REQUEST.
           IF REQ-METHOD = "OPTIONS"
               PERFORM SERVE-OPTIONS
           ELSE
           IF REQ-METHOD = "GET" AND FUNCTION TRIM(REQ-PATH) = "/"
               PERFORM SERVE-DASHBOARD
           ELSE
           IF REQ-METHOD = "GET" AND FUNCTION TRIM(REQ-PATH) = "/api/methods"
               PERFORM SERVE-METHODS
           ELSE
           IF REQ-METHOD = "GET" AND FUNCTION TRIM(REQ-PATH) = "/api/status"
               PERFORM SERVE-STATUS
           ELSE
           IF REQ-METHOD = "GET" AND FUNCTION TRIM(REQ-PATH) = "/api/sessions"
               PERFORM SERVE-SESSIONS
           ELSE
           IF REQ-METHOD = "POST" AND FUNCTION TRIM(REQ-PATH) = "/api/sessions"
               PERFORM ADD-SESSION
           ELSE
           IF REQ-METHOD = "POST" AND FUNCTION TRIM(REQ-PATH) = "/api/lock/toggle"
               PERFORM TOGGLE-LOCK
           ELSE
           IF REQ-METHOD = "POST" AND FUNCTION TRIM(REQ-PATH) = "/api/sessions/reset"
               PERFORM RESET-SESSIONS
           ELSE
               PERFORM SERVE-404.

       SERVE-DASHBOARD.
           INITIALIZE RESP-BUFFER
           STRING "HTTP/1.1 200 OK" X"0D0A"
                  "Content-Type: text/html" X"0D0A"
                  "Connection: close" X"0D0A"
                  X"0D0A" X"00"
                  DELIMITED BY SIZE INTO RESP-BUFFER
           END-STRING
           
           CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
           CALL "client_write" USING BY VALUE CLIENT-FD
                                     BY REFERENCE RESP-BUFFER
                                     BY VALUE RESP-LEN
                                     
           OPEN INPUT HTML-FILE
           IF HTML-STATUS NOT = "00"
               DISPLAY "Error opening dashboard.html. Status: " HTML-STATUS
               INITIALIZE RESP-BUFFER
               STRING "Error: dashboard.html not found!" X"00"
                   DELIMITED BY SIZE INTO RESP-BUFFER
               END-STRING
               CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
               CALL "client_write" USING BY VALUE CLIENT-FD
                                         BY REFERENCE RESP-BUFFER
                                         BY VALUE RESP-LEN
           ELSE
               SET EOF-NOT-REACHED TO TRUE
               PERFORM UNTIL EOF-REACHED
                   READ HTML-FILE
                       AT END
                           SET EOF-REACHED TO TRUE
                       NOT AT END
                           INITIALIZE RESP-BUFFER
                           STRING FUNCTION TRIM(HTML-LINE) X"0A" X"00"
                               DELIMITED BY SIZE INTO RESP-BUFFER
                           END-STRING
                           
                           CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
                           IF RESP-LEN > 1
                               CALL "client_write" USING BY VALUE CLIENT-FD
                                                         BY REFERENCE RESP-BUFFER
                                                         BY VALUE RESP-LEN
                           END-IF
                   END-READ
               END-PERFORM
               CLOSE HTML-FILE
           END-IF.

       SERVE-METHODS.
           INITIALIZE RESP-BUFFER
           STRING "HTTP/1.1 200 OK" X"0D0A"
                  "Content-Type: application/json" X"0D0A"
                  "Access-Control-Allow-Origin: *" X"0D0A"
                  "Connection: close" X"0D0A"
                  X"0D0A"
                  "["
                  '{"id":"box","name":"Box Breathing","inhale":4,"hold":4,"exhale":4,"holdOut":4,"desc":"Relieves stress, calms the nervous system."},'
                  '{"id":"sleep","name":"4-7-8 Method","inhale":4,"hold":7,"exhale":8,"holdOut":0,"desc":"Deep relaxation, helps with falling asleep."},'
                  '{"id":"resonant","name":"Resonant Coherence","inhale":5,"hold":0,"exhale":5,"holdOut":0,"desc":"Balances autonomic nervous system."},'
                  '{"id":"energy","name":"Energizing Breath","inhale":2,"hold":0,"exhale":2,"holdOut":10,"desc":"Rapid cycles followed by retention for energy."},'
                  '{"id":"wimhof","name":"Wim Hof Method","inhale":2,"hold":0,"exhale":2,"holdOut":60,"desc":"Hyperventilation cycles followed by deep breath retention."}'
                  "]" X"00" DELIMITED BY SIZE INTO RESP-BUFFER
           END-STRING
           
           CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
           CALL "client_write" USING BY VALUE CLIENT-FD
                                     BY REFERENCE RESP-BUFFER
                                     BY VALUE RESP-LEN.

       SERVE-STATUS.
           CALL "get_uptime" RETURNING CURRENT-UPTIME
           MOVE FUNCTION CURRENT-DATE TO CURR-TIME-RAW
           MOVE CURR-TIME-RAW(1:4) TO CURR-TIME-DISP(1:4)
           MOVE "-" TO CURR-TIME-DISP(5:1)
           MOVE CURR-TIME-RAW(5:2) TO CURR-TIME-DISP(6:2)
           MOVE "-" TO CURR-TIME-DISP(8:1)
           MOVE CURR-TIME-RAW(7:2) TO CURR-TIME-DISP(9:2)
           MOVE " " TO CURR-TIME-DISP(11:1)
           MOVE CURR-TIME-RAW(9:2) TO CURR-TIME-DISP(12:2)
           MOVE ":" TO CURR-TIME-DISP(14:1)
           MOVE CURR-TIME-RAW(11:2) TO CURR-TIME-DISP(15:2)
           MOVE ":" TO CURR-TIME-DISP(17:1)
           MOVE CURR-TIME-RAW(13:2) TO CURR-TIME-DISP(18:2)

           MOVE CURRENT-UPTIME TO UPTIME-DISP
           MOVE REQ-COUNT TO REQ-COUNT-DISP

           INITIALIZE RESP-BUFFER
           STRING "HTTP/1.1 200 OK" X"0D0A"
                  "Content-Type: application/json" X"0D0A"
                  "Access-Control-Allow-Origin: *" X"0D0A"
                  "Connection: close" X"0D0A"
                  X"0D0A"
                  "{"
                  '"status":"online",'
                  '"uptime_seconds":"' FUNCTION TRIM(UPTIME-DISP) '",'
                  '"request_count":' FUNCTION TRIM(REQ-COUNT-DISP) ','
                  '"lock_status":"' FUNCTION TRIM(SYS-STATE) '",'
                  '"system_time":"' CURR-TIME-DISP '"'
                  "}" X"00" DELIMITED BY SIZE INTO RESP-BUFFER
           END-STRING.

           CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
           CALL "client_write" USING BY VALUE CLIENT-FD
                                     BY REFERENCE RESP-BUFFER
                                     BY VALUE RESP-LEN.

       SERVE-SESSIONS.
           IF FUNCTION TRIM(SYS-STATE) = "LOCKED"
               INITIALIZE RESP-BUFFER
               STRING "HTTP/1.1 200 OK" X"0D0A"
                      "Content-Type: application/json" X"0D0A"
                      "Access-Control-Allow-Origin: *" X"0D0A"
                      "Connection: close" X"0D0A"
                      X"0D0A"
                      '{"locked":true}' X"00"
                      DELIMITED BY SIZE INTO RESP-BUFFER
               END-STRING
               CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
               CALL "client_write" USING BY VALUE CLIENT-FD
                                         BY REFERENCE RESP-BUFFER
                                         BY VALUE RESP-LEN
           ELSE
               PERFORM READ-SESSIONS-JSON
           END-IF.

       READ-SESSIONS-JSON.
           INITIALIZE JSON-ARRAY
           MOVE 1 TO JSON-POINTER
           STRING "[" DELIMITED BY SIZE INTO JSON-ARRAY WITH POINTER JSON-POINTER
           MOVE 0 TO SESS-COUNT
           
            OPEN INPUT SESSIONS-FILE
            IF SESSIONS-STATUS(1:1) = "0"
                SET EOF-NOT-REACHED TO TRUE
                PERFORM UNTIL EOF-REACHED
                    READ SESSIONS-FILE
                        AT END
                            SET EOF-REACHED TO TRUE
                        NOT AT END
                            ADD 1 TO SESS-COUNT
                            IF SESS-COUNT > 1
                                STRING "," DELIMITED BY SIZE INTO JSON-ARRAY WITH POINTER JSON-POINTER
                            END-IF
                            
                            INITIALIZE JSON-TEMP
                            STRING
                                "{"
                                '"time":"' FUNCTION TRIM(SESS-TIME) '",'
                                '"method":"' FUNCTION TRIM(SESS-METHOD) '",'
                                '"duration":' FUNCTION TRIM(SESS-DURATION) ','
                                '"notes":"' FUNCTION TRIM(SESS-NOTES) '"'
                                "}"
                                DELIMITED BY SIZE INTO JSON-TEMP
                            END-STRING
                            
                            STRING FUNCTION TRIM(JSON-TEMP)
                                DELIMITED BY SIZE INTO JSON-ARRAY WITH POINTER JSON-POINTER
                    END-READ
                END-PERFORM
                CLOSE SESSIONS-FILE
            ELSE
                DISPLAY "Error opening sessions.dat for reading. Status: " SESSIONS-STATUS
            END-IF
           
           STRING "]" DELIMITED BY SIZE INTO JSON-ARRAY WITH POINTER JSON-POINTER
           
           INITIALIZE RESP-BUFFER
           STRING "HTTP/1.1 200 OK" X"0D0A"
                  "Content-Type: application/json" X"0D0A"
                  "Access-Control-Allow-Origin: *" X"0D0A"
                  "Connection: close" X"0D0A"
                  X"0D0A"
                  '{"locked":false,"sessions":' FUNCTION TRIM(JSON-ARRAY) '}' X"00"
                  DELIMITED BY SIZE INTO RESP-BUFFER
           END-STRING
           
           CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
           CALL "client_write" USING BY VALUE CLIENT-FD
                                     BY REFERENCE RESP-BUFFER
                                     BY VALUE RESP-LEN.

       ADD-SESSION.
           INITIALIZE EXTRACTED-METHOD
           INITIALIZE EXTRACTED-DURATION
           INITIALIZE EXTRACTED-NOTES
           
           *> Extract fields from JSON
           CALL "get_json_value" USING BY REFERENCE REQ-BODY
                                       BY REFERENCE Z"method"
                                       BY REFERENCE EXTRACTED-METHOD
                                       BY VALUE 30
                                       
           CALL "get_json_value" USING BY REFERENCE REQ-BODY
                                       BY REFERENCE Z"duration"
                                       BY REFERENCE EXTRACTED-DURATION
                                       BY VALUE 6
                                       
           CALL "get_json_value" USING BY REFERENCE REQ-BODY
                                       BY REFERENCE Z"notes"
                                       BY REFERENCE EXTRACTED-NOTES
                                       BY VALUE 50

           *> Get current formatted time
           MOVE FUNCTION CURRENT-DATE TO CURR-TIME-RAW
           MOVE CURR-TIME-RAW(1:4) TO CURR-TIME-DISP(1:4)
           MOVE "-" TO CURR-TIME-DISP(5:1)
           MOVE CURR-TIME-RAW(5:2) TO CURR-TIME-DISP(6:2)
           MOVE "-" TO CURR-TIME-DISP(8:1)
           MOVE CURR-TIME-RAW(7:2) TO CURR-TIME-DISP(9:2)
           MOVE " " TO CURR-TIME-DISP(11:1)
           MOVE CURR-TIME-RAW(9:2) TO CURR-TIME-DISP(12:2)
           MOVE ":" TO CURR-TIME-DISP(14:1)
           MOVE CURR-TIME-RAW(11:2) TO CURR-TIME-DISP(15:2)
           MOVE ":" TO CURR-TIME-DISP(17:1)
           MOVE CURR-TIME-RAW(13:2) TO CURR-TIME-DISP(18:2)

            *> Open file in EXTEND mode to append
            OPEN EXTEND SESSIONS-FILE
            IF SESSIONS-STATUS(1:1) NOT = "0"
                DISPLAY "Error opening sessions.dat for append. Status: " SESSIONS-STATUS
            ELSE
                MOVE CURR-TIME-DISP TO SESS-TIME
                MOVE "|" TO SESS-DELIM-1
                MOVE EXTRACTED-METHOD TO SESS-METHOD
                MOVE "|" TO SESS-DELIM-2
                MOVE EXTRACTED-DURATION TO SESS-DURATION
                MOVE "|" TO SESS-DELIM-3
                MOVE EXTRACTED-NOTES TO SESS-NOTES
                WRITE SESSION-REC
                IF SESSIONS-STATUS(1:1) NOT = "0"
                    DISPLAY "Error writing to sessions.dat. Status: " SESSIONS-STATUS
                END-IF
                CLOSE SESSIONS-FILE
            END-IF.

           *> Return JSON success response
           INITIALIZE RESP-BUFFER
           STRING "HTTP/1.1 200 OK" X"0D0A"
                  "Content-Type: application/json" X"0D0A"
                  "Access-Control-Allow-Origin: *" X"0D0A"
                  "Connection: close" X"0D0A"
                  X"0D0A"
                  '{"success":true}' X"00"
                  DELIMITED BY SIZE INTO RESP-BUFFER
           END-STRING

           CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
           CALL "client_write" USING BY VALUE CLIENT-FD
                                     BY REFERENCE RESP-BUFFER
                                     BY VALUE RESP-LEN.

       TOGGLE-LOCK.
           INITIALIZE EXTRACTED-PIN
           IF FUNCTION TRIM(SYS-STATE) = "UNLOCKED"
               MOVE "LOCKED" TO SYS-STATE
               PERFORM SAVE-LOCK-SYSTEM
               INITIALIZE RESP-BUFFER
               STRING "HTTP/1.1 200 OK" X"0D0A"
                      "Content-Type: application/json" X"0D0A"
                      "Access-Control-Allow-Origin: *" X"0D0A"
                      "Connection: close" X"0D0A"
                      X"0D0A"
                      '{"success":true,"state":"LOCKED"}' X"00"
                      DELIMITED BY SIZE INTO RESP-BUFFER
               END-STRING
           ELSE
               CALL "get_json_value" USING BY REFERENCE REQ-BODY
                                           BY REFERENCE Z"pin"
                                           BY REFERENCE EXTRACTED-PIN
                                           BY VALUE 4
               IF EXTRACTED-PIN = SYS-PIN
                   MOVE "UNLOCKED" TO SYS-STATE
                   PERFORM SAVE-LOCK-SYSTEM
                   INITIALIZE RESP-BUFFER
                   STRING "HTTP/1.1 200 OK" X"0D0A"
                          "Content-Type: application/json" X"0D0A"
                          "Access-Control-Allow-Origin: *" X"0D0A"
                          "Connection: close" X"0D0A"
                          X"0D0A"
                          '{"success":true,"state":"UNLOCKED"}' X"00"
                          DELIMITED BY SIZE INTO RESP-BUFFER
                   END-STRING
               ELSE
                   INITIALIZE RESP-BUFFER
                   STRING "HTTP/1.1 401 Unauthorized" X"0D0A"
                          "Content-Type: application/json" X"0D0A"
                          "Access-Control-Allow-Origin: *" X"0D0A"
                          "Connection: close" X"0D0A"
                          X"0D0A"
                          '{"success":false,"error":"Invalid PIN"}' X"00"
                          DELIMITED BY SIZE INTO RESP-BUFFER
                   END-STRING
               END-IF
           END-IF.

           CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
           CALL "client_write" USING BY VALUE CLIENT-FD
                                     BY REFERENCE RESP-BUFFER
                                     BY VALUE RESP-LEN.

       RESET-SESSIONS.
           INITIALIZE EXTRACTED-PIN
           CALL "get_json_value" USING BY REFERENCE REQ-BODY
                                       BY REFERENCE Z"pin"
                                       BY REFERENCE EXTRACTED-PIN
                                       BY VALUE 4

           IF EXTRACTED-PIN = SYS-PIN
               OPEN OUTPUT SESSIONS-FILE
               CLOSE SESSIONS-FILE
               
               INITIALIZE RESP-BUFFER
               STRING "HTTP/1.1 200 OK" X"0D0A"
                      "Content-Type: application/json" X"0D0A"
                      "Access-Control-Allow-Origin: *" X"0D0A"
                      "Connection: close" X"0D0A"
                      X"0D0A"
                      '{"success":true}' X"00"
                      DELIMITED BY SIZE INTO RESP-BUFFER
               END-STRING
           ELSE
               INITIALIZE RESP-BUFFER
               STRING "HTTP/1.1 401 Unauthorized" X"0D0A"
                      "Content-Type: application/json" X"0D0A"
                      "Access-Control-Allow-Origin: *" X"0D0A"
                      "Connection: close" X"0D0A"
                      X"0D0A"
                      '{"success":false,"error":"Invalid PIN"}' X"00"
                      DELIMITED BY SIZE INTO RESP-BUFFER
               END-STRING
           END-IF.

           CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
           CALL "client_write" USING BY VALUE CLIENT-FD
                                     BY REFERENCE RESP-BUFFER
                                     BY VALUE RESP-LEN.

        SERVE-OPTIONS.
            INITIALIZE RESP-BUFFER
            STRING "HTTP/1.1 200 OK" X"0D0A"
                   "Access-Control-Allow-Origin: *" X"0D0A"
                   "Access-Control-Allow-Methods: GET, POST, OPTIONS" X"0D0A"
                   "Access-Control-Allow-Headers: Content-Type" X"0D0A"
                   "Connection: close" X"0D0A"
                   X"0D0A" X"00"
                   DELIMITED BY SIZE INTO RESP-BUFFER
            END-STRING
            
            CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
            CALL "client_write" USING BY VALUE CLIENT-FD
                                      BY REFERENCE RESP-BUFFER
                                      BY VALUE RESP-LEN.

       SERVE-404.
           INITIALIZE RESP-BUFFER
           STRING "HTTP/1.1 404 Not Found" X"0D0A"
                  "Content-Type: application/json" X"0D0A"
                  "Connection: close" X"0D0A"
                  X"0D0A"
                  '{"error":"Path not found"}' X"00"
                  DELIMITED BY SIZE INTO RESP-BUFFER
           END-STRING
           
           CALL "strlen" USING BY REFERENCE RESP-BUFFER RETURNING RESP-LEN
           CALL "client_write" USING BY VALUE CLIENT-FD
                                     BY REFERENCE RESP-BUFFER
                                     BY VALUE RESP-LEN.

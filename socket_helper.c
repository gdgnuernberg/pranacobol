#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <time.h>

// Uptime tracking
static time_t start_time = 0;

void record_start_time(void) {
    setbuf(stdout, NULL);
    setbuf(stderr, NULL);
    start_time = time(NULL);
}

int get_uptime(void) {
    if (start_time == 0) return 0;
    return (int)(time(NULL) - start_time);
}

// Server sockets
int server_init(int port) {
    int server_fd;
    struct sockaddr_in address;
    int opt = 1;

    // Create socket
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        perror("socket failed");
        return -1;
    }

    // Set socket options to reuse address and port
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt))) {
        perror("setsockopt SO_REUSEADDR failed");
        close(server_fd);
        return -1;
    }

#ifdef SO_REUSEPORT
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEPORT, &opt, sizeof(opt))) {
        perror("setsockopt SO_REUSEPORT failed");
    }
#endif

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);

    // Bind
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        perror("bind failed");
        close(server_fd);
        return -1;
    }

    // Listen
    if (listen(server_fd, 128) < 0) {
        perror("listen failed");
        close(server_fd);
        return -1;
    }

    return server_fd;
}

int server_accept(int server_fd) {
    int client_fd;
    struct sockaddr_in address;
    socklen_t addrlen = sizeof(address);

    if ((client_fd = accept(server_fd, (struct sockaddr *)&address, &addrlen)) < 0) {
        return -1;
    }

    return client_fd;
}

int client_read(int client_fd, char* buffer, int max_len) {
    if (max_len <= 0) return 0;
    memset(buffer, 0, max_len);
    ssize_t bytes = recv(client_fd, buffer, (size_t)(max_len - 1), 0);
    if (bytes < 0) {
        return -1;
    }
    buffer[bytes] = '\0';
    return (int)bytes;
}

int client_write(int client_fd, const char* buffer, int len) {
    if (len <= 0) return 0;
    ssize_t sent = send(client_fd, buffer, (size_t)len, 0);
    return (int)sent;
}

void client_close(int client_fd) {
    if (client_fd >= 0) {
        close(client_fd);
    }
}

void server_close(int server_fd) {
    if (server_fd >= 0) {
        close(server_fd);
    }
}

// Find body in HTTP request
void find_http_body(const char* request, char* body_out, int max_len) {
    if (!request || !body_out || max_len <= 0) return;
    memset(body_out, 0, max_len);
    const char* body = strstr(request, "\r\n\r\n");
    if (body) {
        body += 4; // skip CRLFCRLF
        strncpy(body_out, body, (size_t)(max_len - 1));
        body_out[max_len - 1] = '\0';
    }
}

// Extract string value from JSON: {"key": "val"}
// Safe for COBOL: does not write out-of-bounds null terminators.
int get_json_value(const char* json, const char* key, char* val_out, int max_len) {
    if (!json || !key || !val_out || max_len <= 0) return -1;
    
    // Pre-clear output buffer with spaces (COBOL space-padding)
    memset(val_out, ' ', (size_t)max_len);

    char pattern[128];
    snprintf(pattern, sizeof(pattern), "\"%s\"", key);

    const char* key_ptr = strstr(json, pattern);
    if (!key_ptr) return -1;

    // Find colon
    const char* colon_ptr = strchr(key_ptr + strlen(pattern), ':');
    if (!colon_ptr) return -1;

    // Find opening quote
    const char* quote_start = strchr(colon_ptr, '\"');
    if (!quote_start) return -1;
    quote_start++; // Move past quote

    // Find closing quote
    const char* quote_end = strchr(quote_start, '\"');
    if (!quote_end) return -1;

    size_t val_len = (size_t)(quote_end - quote_start);
    if (val_len > (size_t)max_len) {
        val_len = (size_t)max_len;
    }

    memcpy(val_out, quote_start, val_len);
    return 0;
}

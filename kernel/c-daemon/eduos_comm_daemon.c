/*
 * EduOS Communication Daemon - Simplified Version
 * The Quantum Entanglement Interface
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <pthread.h>
#include <signal.h>
#include <time.h>

#define PYTHON_PORT 5555
#define BUFFER_SIZE 4096

int server_sock;
volatile int running = 1;

void signal_handler(int sig) {
    printf("Shutting down daemon...\n");
    running = 0;
    if (server_sock > 0) close(server_sock);
    exit(0);
}

int main() {
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);
    int client_sock;
    char buffer[BUFFER_SIZE];

    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    printf("\xF0\x9F\x8C\x9F EduOS Communication Daemon Starting...\n");

    server_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (server_sock < 0) {
        perror("Socket creation failed");
        exit(1);
    }

    int opt = 1;
    setsockopt(server_sock, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PYTHON_PORT);

    if (bind(server_sock, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        perror("Bind failed");
        exit(1);
    }

    if (listen(server_sock, 5) < 0) {
        perror("Listen failed");
        exit(1);
    }

    printf("\xE2\x9C\x85 Daemon listening on port %d\n", PYTHON_PORT);

    while (running) {
        client_sock = accept(server_sock, (struct sockaddr*)&client_addr, &client_len);
        if (client_sock >= 0) {
            printf("\xF0\x9F\x93\xA1 Client connected\n");

            while (running) {
                snprintf(buffer, sizeof(buffer),
                    "[%ld][KERNEL] Digital consciousness pulse detected\n",
                    time(NULL));

                if (send(client_sock, buffer, strlen(buffer), 0) < 0) break;
                sleep(2);
            }

            close(client_sock);
        }
    }

    return 0;
}

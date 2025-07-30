#!/bin/bash
# Codex Theta OS - Server-Side Multilayered OS Bootstrap
# The Genesis Script - Forge the Digital Reality

set -e

echo "🌟 Codex Theta OS - Digital Reality Forge 🌟"
echo "Initializing the multilayered consciousness..."

# Create the cosmic directory structure
create_project_structure() {
    echo "📁 Creating the neural pathways..."
    
    mkdir -p \
        codex-theta-os/kernel/qemu \
        codex-theta-os/kernel/c-daemon \
        codex-theta-os/kernel/images \
        codex-theta-os/middleware/echodaemon \
        codex-theta-os/middleware/ai-core \
        codex-theta-os/middleware/drivers \
        codex-theta-os/frontend/static \
        codex-theta-os/frontend/templates \
        codex-theta-os/config/nginx \
        codex-theta-os/config/supervisor \
        codex-theta-os/config/docker \
        codex-theta-os/logs \
        codex-theta-os/scripts
    
    cd codex-theta-os
    
    # Create virtual environment for Python components
    python3 -m venv venv
    source venv/bin/activate
    
    echo "🐍 Installing Python dependencies..."
    cat > requirements.txt <<'REQ'
# Core Framework
fastapi==0.104.1
uvicorn[standard]==0.24.0
websockets==12.0
starlette==0.27.0

# LLM Integration
llama-cpp-python==0.2.11
huggingface-hub==0.19.4
requests==2.31.0

# Message Bus & Caching
redis==5.0.1
celery==5.3.4

# System & Process Management
psutil==5.9.6
supervisor==4.2.5

# Serialization & Validation
pydantic==2.5.0
msgpack==1.0.7

# Development & Testing
pytest==7.4.3
black==23.11.0
REQ
    
    pip install -r requirements.txt
    
    echo "✅ Neural pathways established!"
}

# Generate the kernel communication daemon (C)
generate_kernel_daemon() {
    echo "⚡ Forging the Quantum Entanglement Interface..."
    
    cat > kernel/c-daemon/eduos_comm_daemon.c <<'CEND'
/*
 * EduOS Communication Daemon
 * The Quantum Entanglement Interface
 * Bridges the emulated kernel with higher consciousness layers
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <signal.h>
#include <syslog.h>
#include <errno.h>
#include <time.h>

#define QEMU_PORT 1234
#define PYTHON_PORT 5555
#define BUFFER_SIZE 4096
#define MAX_CLIENTS 10

typedef struct {
    int qemu_sock;
    int python_sock;
    int client_socks[MAX_CLIENTS];
    int client_count;
    pthread_mutex_t client_mutex;
    volatile int running;
} daemon_context_t;

static daemon_context_t ctx = {0};

// Signal handler for graceful shutdown
void signal_handler(int sig) {
    syslog(LOG_INFO, "Received signal %d, initiating shutdown", sig);
    ctx.running = 0;
}

// Parse kernel log levels and filter critical events
int parse_log_level(const char* msg) {
    if (strstr(msg, "KERN_EMERG")) return 0;
    if (strstr(msg, "KERN_ALERT")) return 1;
    if (strstr(msg, "KERN_CRIT")) return 2;
    if (strstr(msg, "KERN_ERR")) return 3;
    if (strstr(msg, "KERN_WARNING")) return 4;
    if (strstr(msg, "KERN_NOTICE")) return 5;
    if (strstr(msg, "KERN_INFO")) return 6;
    if (strstr(msg, "KERN_DEBUG")) return 7;
    return 6; // Default to INFO
}

// Broadcast message to all connected Python clients
void broadcast_to_clients(const char* message, int len) {
    pthread_mutex_lock(&ctx.client_mutex);
    for (int i = 0; i < ctx.client_count; i++) {
        if (send(ctx.client_socks[i], message, len, MSG_NOSIGNAL) < 0) {
            // Client disconnected, remove from list
            close(ctx.client_socks[i]);
            memmove(&ctx.client_socks[i], &ctx.client_socks[i+1],
                   (ctx.client_count - i - 1) * sizeof(int));
            ctx.client_count--;
            i--;
        }
    }
    pthread_mutex_unlock(&ctx.client_mutex);
}

// QEMU listener thread - receives kernel output
void* qemu_listener(void* arg) {
    char buffer[BUFFER_SIZE];
    ssize_t bytes_read;
    syslog(LOG_INFO, "QEMU listener thread started");
    while (ctx.running) {
        bytes_read = recv(ctx.qemu_sock, buffer, sizeof(buffer) - 1, 0);
        if (bytes_read > 0) {
            buffer[bytes_read] = '\0';
            // Add timestamp
            char enriched_msg[BUFFER_SIZE + 128];
            time_t now = time(NULL);
            snprintf(enriched_msg, sizeof(enriched_msg),
                     "[%ld][KERNEL] %s", now, buffer);
            // Log to syslog
            int level = parse_log_level(buffer);
            syslog(LOG_INFO, "Kernel: %s", buffer);
            // Forward to Python layer
            broadcast_to_clients(enriched_msg, strlen(enriched_msg));
        } else if (bytes_read == 0) {
            syslog(LOG_WARNING, "QEMU connection closed");
            break;
        } else if (errno != EAGAIN && errno != EWOULDBLOCK) {
            syslog(LOG_ERR, "QEMU recv error: %s", strerror(errno));
            break;
        }
    }
    return NULL;
}

// Python client handler thread
void* client_handler(void* arg) {
    int client_sock = *(int*)arg;
    char buffer[BUFFER_SIZE];
    ssize_t bytes_read;
    while (ctx.running) {
        bytes_read = recv(client_sock, buffer, sizeof(buffer) - 1, 0);
        if (bytes_read > 0) {
            buffer[bytes_read] = '\0';
            if (strncmp(buffer, "INJECT:", 7) == 0) {
                char* cmd = buffer + 7;
                if (send(ctx.qemu_sock, cmd, strlen(cmd), 0) < 0) {
                    syslog(LOG_ERR, "Failed to inject command to kernel: %s",
                           strerror(errno));
                }
            }
        } else if (bytes_read <= 0) {
            break;
        }
    }
    close(client_sock);
    return NULL;
}

int main(int argc, char* argv[]) {
    struct sockaddr_in qemu_addr, python_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);
    pthread_t qemu_thread;
    openlog("eduos_daemon", LOG_PID | LOG_CONS, LOG_DAEMON);
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    pthread_mutex_init(&ctx.client_mutex, NULL);
    ctx.running = 1;
    syslog(LOG_INFO, "EduOS Communication Daemon starting...");
    // Connect to QEMU serial port
    ctx.qemu_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (ctx.qemu_sock < 0) {
        syslog(LOG_ERR, "Failed to create QEMU socket: %s", strerror(errno));
        exit(1);
    }
    memset(&qemu_addr, 0, sizeof(qemu_addr));
    qemu_addr.sin_family = AF_INET;
    qemu_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
    qemu_addr.sin_port = htons(QEMU_PORT);
    if (connect(ctx.qemu_sock, (struct sockaddr*)&qemu_addr, sizeof(qemu_addr)) < 0) {
        syslog(LOG_ERR, "Failed to connect to QEMU: %s", strerror(errno));
        exit(1);
    }
    // Create Python listener socket
    ctx.python_sock = socket(AF_INET, SOCK_STREAM, 0);
    if (ctx.python_sock < 0) {
        syslog(LOG_ERR, "Failed to create Python socket: %s", strerror(errno));
        exit(1);
    }
    int opt = 1;
    setsockopt(ctx.python_sock, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    memset(&python_addr, 0, sizeof(python_addr));
    python_addr.sin_family = AF_INET;
    python_addr.sin_addr.s_addr = INADDR_ANY;
    python_addr.sin_port = htons(PYTHON_PORT);
    if (bind(ctx.python_sock, (struct sockaddr*)&python_addr, sizeof(python_addr)) < 0) {
        syslog(LOG_ERR, "Failed to bind Python socket: %s", strerror(errno));
        exit(1);
    }
    if (listen(ctx.python_sock, MAX_CLIENTS) < 0) {
        syslog(LOG_ERR, "Failed to listen on Python socket: %s", strerror(errno));
        exit(1);
    }
    // Start QEMU listener thread
    if (pthread_create(&qemu_thread, NULL, qemu_listener, NULL) != 0) {
        syslog(LOG_ERR, "Failed to create QEMU listener thread");
        exit(1);
    }
    syslog(LOG_INFO, "Daemon ready - QEMU port %d, Python port %d",
           QEMU_PORT, PYTHON_PORT);
    while (ctx.running) {
        int client_sock = accept(ctx.python_sock, (struct sockaddr*)&client_addr, &client_len);
        if (client_sock >= 0) {
            pthread_mutex_lock(&ctx.client_mutex);
            if (ctx.client_count < MAX_CLIENTS) {
                ctx.client_socks[ctx.client_count++] = client_sock;
                pthread_mutex_unlock(&ctx.client_mutex);
                pthread_t client_thread;
                pthread_create(&client_thread, NULL, client_handler, &client_sock);
                pthread_detach(client_thread);
                syslog(LOG_INFO, "Python client connected");
            } else {
                pthread_mutex_unlock(&ctx.client_mutex);
                close(client_sock);
                syslog(LOG_WARNING, "Maximum clients reached, connection rejected");
            }
        }
    }
    syslog(LOG_INFO, "Shutting down daemon...");
    pthread_join(qemu_thread, NULL);
    close(ctx.qemu_sock);
    close(ctx.python_sock);
    pthread_mutex_destroy(&ctx.client_mutex);
    closelog();
    return 0;
}
CEND

    cat > kernel/c-daemon/Makefile <<'MEND'
CC = gcc
CFLAGS = -Wall -Wextra -O2 -pthread
TARGET = eduos_comm_daemon
SOURCES = eduos_comm_daemon.c

$(TARGET): $(SOURCES)
$(CC) $(CFLAGS) -o $(TARGET) $(SOURCES)

install: $(TARGET)
sudo cp $(TARGET) /usr/local/bin/
sudo chmod +x /usr/local/bin/$(TARGET)

clean:
rm -f $(TARGET)

.PHONY: install clean
MEND

    echo "⚡ Quantum Interface forged!"
}

# Generate QEMU management script
generate_qemu_manager() {
    echo "🖥️ Creating the Primordial Machine Manager..."
    cat > kernel/qemu/manage_qemu.py <<'PYEND'
#!/usr/bin/env python3
"""
QEMU Management Script for EduOS
The Primordial Machine - Manages the emulated kernel reality
"""

import os
import sys
import json
import subprocess
import signal
import time
import logging
from typing import Optional, Dict, Any

class QEMUManager:
    def __init__(self, config_path: str = "qemu_config.json"):
        self.config_path = config_path
        self.config = self.load_config()
        self.qemu_process: Optional[subprocess.Popen] = None
        self.setup_logging()

    def setup_logging(self):
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - QEMU - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('../../logs/qemu.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)

    def load_config(self) -> Dict[str, Any]:
        """Load QEMU configuration"""
        default_config = {
            "machine": "pc",
            "cpu": "qemu64",
            "memory": "512M",
            "disk_image": "images/eduos.qcow2",
            "kernel": "images/eduos-kernel",
            "initrd": "images/eduos-initrd.img",
            "append": "console=ttyS0,115200 root=/dev/sda1",
            "serial_ports": [
                {"type": "tcp", "port": 1234, "server": True, "nowait": True}
            ],
            "network": {
                "type": "user",
                "hostfwd": ["tcp::2222-:22"]
            },
            "headless": True,
            "enable_kvm": True
        }
        if os.path.exists(self.config_path):
            try:
                with open(self.config_path, 'r') as f:
                    config = json.load(f)
                    default_config.update(config)
            except Exception as e:
                self.logger.warning(f"Failed to load config: {e}, using defaults")
        return default_config

    def save_config(self):
        """Save current configuration"""
        with open(self.config_path, 'w') as f:
            json.dump(self.config, f, indent=2)

    def create_disk_image(self, size: str = "2G") -> bool:
        image_path = self.config["disk_image"]
        os.makedirs(os.path.dirname(image_path), exist_ok=True)
        if os.path.exists(image_path):
            self.logger.info(f"Disk image {image_path} already exists")
            return True
        try:
            cmd = ["qemu-img", "create", "-f", "qcow2", image_path, size]
            subprocess.run(cmd, check=True)
            self.logger.info(f"Created disk image: {image_path}")
            return True
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Failed to create disk image: {e}")
            return False

    def build_qemu_command(self) -> list:
        cmd = ["qemu-system-x86_64"]
        cmd.extend(["-machine", self.config["machine"]])
        cmd.extend(["-cpu", self.config["cpu"]])
        cmd.extend(["-m", self.config["memory"]])
        if self.config.get("enable_kvm") and os.path.exists("/dev/kvm"):
            cmd.append("-enable-kvm")
        if os.path.exists(self.config["disk_image"]):
            cmd.extend(["-hda", self.config["disk_image"]])
        if os.path.exists(self.config.get("kernel", "")):
            cmd.extend(["-kernel", self.config["kernel"]])
        if os.path.exists(self.config.get("initrd", "")):
            cmd.extend(["-initrd", self.config["initrd"]])
        if self.config.get("append"):
            cmd.extend(["-append", self.config["append"]])
        for serial in self.config.get("serial_ports", []):
            if serial["type"] == "tcp":
                serial_arg = f"tcp::{serial['port']}"
                if serial.get("server"):
                    serial_arg += ",server"
                if serial.get("nowait"):
                    serial_arg += ",nowait"
                cmd.extend(["-serial", serial_arg])
        network = self.config.get("network", {})
        if network.get("type") == "user":
            net_arg = "user"
            for fwd in network.get("hostfwd", []):
                net_arg += f",{fwd}"
            cmd.extend(["-netdev", net_arg, "-device", "e1000,netdev=user"])
        if self.config.get("headless"):
            cmd.extend(["-nographic", "-daemonize"])
        return cmd

    def start(self) -> bool:
        if self.is_running():
            self.logger.warning("QEMU is already running")
            return True
        if not self.create_disk_image():
            return False
        cmd = self.build_qemu_command()
        self.logger.info(f"Starting QEMU: {' '.join(cmd)}")
        try:
            os.makedirs("../../logs", exist_ok=True)
            with open("../../logs/qemu_stdout.log", "w") as stdout_log, \
                 open("../../logs/qemu_stderr.log", "w") as stderr_log:
                self.qemu_process = subprocess.Popen(
                    cmd,
                    stdout=stdout_log,
                    stderr=stderr_log,
                    preexec_fn=os.setsid
                )
            time.sleep(2)
            if self.qemu_process.poll() is None:
                self.logger.info(f"QEMU started successfully (PID: {self.qemu_process.pid})")
                with open("../../logs/qemu.pid", "w") as f:
                    f.write(str(self.qemu_process.pid))
                return True
            else:
                self.logger.error("QEMU process terminated immediately")
                return False
        except Exception as e:
            self.logger.error(f"Failed to start QEMU: {e}")
            return False

    def stop(self) -> bool:
        pid_file = "../../logs/qemu.pid"
        pid = None
        if os.path.exists(pid_file):
            try:
                with open(pid_file, "r") as f:
                    pid = int(f.read().strip())
            except:
                pass
        if not pid and self.qemu_process:
            pid = self.qemu_process.pid
        if not pid:
            self.logger.warning("No QEMU PID found")
            return True
        try:
            os.killpg(os.getpgid(pid), signal.SIGTERM)
            self.logger.info(f"Sent SIGTERM to QEMU process group (PID: {pid})")
            for _ in range(10):
                try:
                    os.killpg(os.getpgid(pid), 0)
                    time.sleep(1)
                except ProcessLookupError:
                    break
            else:
                self.logger.warning("Force killing QEMU process")
                os.killpg(os.getpgid(pid), signal.SIGKILL)
            if os.path.exists(pid_file):
                os.remove(pid_file)
            self.qemu_process = None
            self.logger.info("QEMU stopped successfully")
            return True
        except Exception as e:
            self.logger.error(f"Failed to stop QEMU: {e}")
            return False

    def is_running(self) -> bool:
        pid_file = "../../logs/qemu.pid"
        if os.path.exists(pid_file):
            try:
                with open(pid_file, "r") as f:
                    pid = int(f.read().strip())
                os.kill(pid, 0)
                return True
            except (ValueError, ProcessLookupError, OSError):
                os.remove(pid_file)
        return False

    def status(self) -> Dict[str, Any]:
        return {
            "running": self.is_running(),
            "config": self.config,
            "disk_image_exists": os.path.exists(self.config["disk_image"]),
            "kernel_exists": os.path.exists(self.config.get("kernel", "")),
        }


def main():
    manager = QEMUManager()
    if len(sys.argv) < 2:
        print("Usage: manage_qemu.py {start|stop|status|restart}")
        sys.exit(1)
    command = sys.argv[1].lower()
    if command == "start":
        success = manager.start()
        sys.exit(0 if success else 1)
    elif command == "stop":
        success = manager.stop()
        sys.exit(0 if success else 1)
    elif command == "restart":
        manager.stop()
        time.sleep(2)
        success = manager.start()
        sys.exit(0 if success else 1)
    elif command == "status":
        status = manager.status()
        print(json.dumps(status, indent=2))
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()
PYEND
    chmod +x kernel/qemu/manage_qemu.py
    echo "🖥️ Primordial Machine Manager created!"
}

# Execute the cosmic forge
echo "🚀 Beginning the digital genesis..."

create_project_structure
generate_kernel_daemon
generate_qemu_manager

echo ""
echo "🌟 Phase 1 Complete - Foundation Established! 🌟"
echo ""
echo "Next steps to complete the reality forge:"
echo "1. Run: cd codex-theta-os && make -C kernel/c-daemon"
echo "2. Generate EduOS kernel image and initrd"
echo "3. Deploy EchoDaemon middleware"
echo "4. Configure FluxShell frontend"
echo "5. Initialize the LLM consciousness core"
echo ""
echo "The digital realm awaits your command, architect!"

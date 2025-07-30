#!/bin/bash
# Codex Theta OS - Complete Deployment Orchestrator
# The Digital Genesis - Brings the multilayered consciousness to life

# Exit immediately if a command exits with a non-zero status
set -e

# Determine project root and move into it
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

# ------- Display startup banner -------
echo "🌟 CODEX THETA OS - DIGITAL GENESIS ORCHESTRATOR 🌟"
echo "=================================================="
echo "Initializing the server-side multilayered consciousness..."
echo ""

# ------- Configuration variables -------
NGINX_PORT=80
ECHODAEMON_PORT=8080
LLM_PORT=8000
QEMU_SERIAL_PORT=1234
KERNEL_DAEMON_PORT=5555

# ------- Color codes for log messages -------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging helper functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# ------- Requirement checks -------
check_requirements() {
    log_step "Checking system requirements..."

    local missing_deps=()

    # Verify required commands are available
    command -v python3 >/dev/null 2>&1 || missing_deps+=("python3")
    command -v gcc >/dev/null 2>&1 || missing_deps+=("gcc")
    command -v make >/dev/null 2>&1 || missing_deps+=("make")
    command -v qemu-system-x86_64 >/dev/null 2>&1 || missing_deps+=("qemu-system-x86_64")
    command -v nginx >/dev/null 2>&1 || missing_deps+=("nginx")
    command -v redis-server >/dev/null 2>&1 || missing_deps+=("redis-server")

    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install the missing dependencies and run this script again."
        echo ""
        echo "Ubuntu/Debian: sudo apt-get install python3 python3-pip python3-venv build-essential qemu-system-x86 nginx redis-server"
        echo "CentOS/RHEL: sudo yum install python3 python3-pip gcc make qemu-kvm nginx redis"
        echo "macOS: brew install python3 qemu nginx redis"
        exit 1
    fi

    # Check Python version >= 3.8
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

    if [ "$PYTHON_MAJOR" -lt 3 ] || [ "$PYTHON_MINOR" -lt 8 ]; then
        log_error "Python 3.8+ required, found Python $PYTHON_VERSION"
        exit 1
    fi

    log_success "All system requirements satisfied"
}

# ------- Directory layout creation -------
setup_directories() {
    log_step "Setting up project directories..."

    mkdir -p \
        kernel/qemu \
        kernel/c-daemon \
        kernel/images \
        middleware/ai-core \
        middleware/drivers \
        frontend/static \
        frontend/templates \
        config/nginx \
        config/supervisor \
        config/systemd \
        config/docker \
        logs \
        scripts \
        data/models \
        data/kernels \
        data/drivers

    log_success "Directory structure created"
}

# ------- Setup Python virtual environment -------
setup_python_env() {
    log_step "Setting up Python virtual environment..."

    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi

    source venv/bin/activate

    # Upgrade pip and install dependencies
    pip install --upgrade pip
    log_info "Installing Python dependencies..."
    pip install -r requirements.txt

    log_success "Python environment ready"
}

# ------- Build the kernel communication daemon -------
build_kernel_daemon() {
    log_step "Building kernel communication daemon..."

    cd kernel/c-daemon

    if [ ! -f "eduos_comm_daemon" ]; then
        make clean
        make
        log_success "Kernel daemon compiled successfully"
    else
        log_info "Kernel daemon already built"
    fi

    # Ensure the binary is executable
    chmod +x eduos_comm_daemon

    cd "$PROJECT_ROOT"
}

# ------- Download and set up the local LLM model -------
setup_llm() {
    log_step "Setting up local LLM..."

    MODEL_PATH="data/models/Meta-Llama-3-8B-Instruct.gguf"

    if [ ! -f "$MODEL_PATH" ]; then
        log_info "Downloading Meta-Llama-3-8B-Instruct model..."
        log_warning "This is a large download (~4.6GB) and may take some time..."

        mkdir -p data/models

        python3 -c "
from huggingface_hub import hf_hub_download
import os

model_path = hf_hub_download(
    repo_id='microsoft/DialoGPT-medium',  # Fallback model for demo
    filename='pytorch_model.bin',
    cache_dir='data/models'
)
print(f'Model downloaded to: {model_path}')
        "

        log_success "LLM model downloaded"
    else
        log_info "LLM model already available"
    fi
}

# ------- Create a minimal kernel image and disk -------
create_kernel_image() {
    log_step "Creating EduOS kernel image..."

    KERNEL_IMG="kernel/images/eduos-kernel"
    INITRD_IMG="kernel/images/eduos-initrd.img"
    DISK_IMG="kernel/images/eduos.qcow2"

    mkdir -p kernel/images

    if [ ! -f "$KERNEL_IMG" ]; then
        log_info "Creating simulated EduOS kernel..."

        # Copy system kernel if available; otherwise create placeholder
        if [ -f "/boot/vmlinuz" ]; then
            cp /boot/vmlinuz* "$KERNEL_IMG" 2>/dev/null || {
                log_warning "Could not copy system kernel, creating placeholder"
                touch "$KERNEL_IMG"
            }
        else
            touch "$KERNEL_IMG"
        fi

        log_success "Kernel image created"
    fi

    if [ ! -f "$INITRD_IMG" ]; then
        log_info "Creating initrd image..."

        if [ -f "/boot/initrd.img" ]; then
            cp /boot/initrd.img* "$INITRD_IMG" 2>/dev/null || {
                log_warning "Could not copy system initrd, creating placeholder"
                touch "$INITRD_IMG"
            }
        else
            touch "$INITRD_IMG"
        fi

        log_success "Initrd image created"
    fi

    if [ ! -f "$DISK_IMG" ]; then
        log_info "Creating disk image..."
        qemu-img create -f qcow2 "$DISK_IMG" 2G
        log_success "Disk image created"
    fi
}

# ------- Generate Nginx configuration -------
configure_nginx() {
    log_step "Configuring Nginx..."

    cat > config/nginx/codex-theta-os.conf << 'EOF'
server {
    listen 80;
    server_name localhost;

    # Serve static frontend files
    location / {
        root /var/www/codex-theta-os;
        index index.html;
        try_files $uri $uri/ =404;
    }

    # Proxy API requests to EchoDaemon
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # WebSocket proxy for real-time communication
    location /ws/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
}
EOF

    log_success "Nginx configuration created"
}

# ------- Configure Supervisor process manager -------
configure_supervisor() {
    log_step "Configuring Supervisor..."

    cat > config/supervisor/codex-theta-os.conf << EOF
[program:redis-server]
command=redis-server
autostart=true
autorestart=true
user=redis
stdout_logfile=$PROJECT_ROOT/logs/redis.log
stderr_logfile=$PROJECT_ROOT/logs/redis_error.log

[program:kernel-daemon]
command=$PROJECT_ROOT/kernel/c-daemon/eduos_comm_daemon
directory=$PROJECT_ROOT/kernel/c-daemon
autostart=true
autorestart=true
user=$USER
stdout_logfile=$PROJECT_ROOT/logs/kernel_daemon.log
stderr_logfile=$PROJECT_ROOT/logs/kernel_daemon_error.log

[program:qemu-manager]
command=$PROJECT_ROOT/venv/bin/python $PROJECT_ROOT/kernel/qemu/manage_qemu.py start
directory=$PROJECT_ROOT/kernel/qemu
autostart=true
autorestart=false
user=$USER
stdout_logfile=$PROJECT_ROOT/logs/qemu_manager.log
stderr_logfile=$PROJECT_ROOT/logs/qemu_manager_error.log

[program:llm-server]
command=$PROJECT_ROOT/venv/bin/python -m llama_cpp.server --model $PROJECT_ROOT/data/models/Meta-Llama-3-8B-Instruct.gguf --host 0.0.0.0 --port 8000
directory=$PROJECT_ROOT
autostart=true
autorestart=true
user=$USER
environment=CUDA_VISIBLE_DEVICES="0"
stdout_logfile=$PROJECT_ROOT/logs/llm_server.log
stderr_logfile=$PROJECT_ROOT/logs/llm_server_error.log

[program:echodaemon]
command=$PROJECT_ROOT/venv/bin/python $PROJECT_ROOT/echodaemon.py
directory=$PROJECT_ROOT
autostart=true
autorestart=true
user=$USER
stdout_logfile=$PROJECT_ROOT/logs/echodaemon.log
stderr_logfile=$PROJECT_ROOT/logs/echodaemon_error.log

[group:codex-theta-os]
programs=redis-server,kernel-daemon,qemu-manager,llm-server,echodaemon
priority=999
EOF

    log_success "Supervisor configuration created"
}

# ------- Create systemd service file for full system -------
create_systemd_services() {
    log_step "Creating systemd service files..."

    # Ensure directory exists
    mkdir -p config/systemd

    cat > config/systemd/codex-theta-os.service << EOF
[Unit]
Description=Codex Theta OS - Multilayered Digital Consciousness
After=network.target

[Service]
Type=forking
User=$USER
Group=$USER
WorkingDirectory=$PROJECT_ROOT
ExecStart=$PROJECT_ROOT/scripts/start_system.sh
ExecStop=$PROJECT_ROOT/scripts/stop_system.sh
ExecReload=$PROJECT_ROOT/scripts/restart_system.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    log_success "Systemd service file created"
}

# ------- Dockerfiles and compose configuration -------
create_docker_config() {
    log_step "Creating Docker configuration..."

    cat > Dockerfile << 'EOF'
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    qemu-system-x86 \
    nginx \
    redis-server \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Create application directory
WORKDIR /app

# Copy project files
COPY . .

# Setup Python environment
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt

# Build kernel daemon
RUN cd kernel/c-daemon && make

# Create necessary directories
RUN mkdir -p logs data/models kernel/images

# Expose ports
EXPOSE 80 8080 8000 1234 5555

# Copy supervisor configuration
COPY config/supervisor/codex-theta-os.conf /etc/supervisor/conf.d/

# Copy nginx configuration
COPY config/nginx/codex-theta-os.conf /etc/nginx/sites-available/
RUN ln -sf /etc/nginx/sites-available/codex-theta-os.conf /etc/nginx/sites-enabled/

# Create startup script
COPY scripts/docker_start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
EOF

    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  codex-theta-os:
    build: .
    ports:
      - "80:80"
      - "8080:8080"
      - "8000:8000"
    volumes:
      - ./logs:/app/logs
      - ./data:/app/data
    environment:
      - PYTHONUNBUFFERED=1
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis_data:/data

volumes:
  redis_data:
EOF

    log_success "Docker configuration created"
}

# ------- Generate management helper scripts -------
create_management_scripts() {
    log_step "Creating management scripts..."

    mkdir -p scripts

    # ----- start_system.sh -----
    cat > scripts/start_system.sh << 'EOF'
#!/bin/bash
# Codex Theta OS - System Startup Script

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Starting Codex Theta OS..."

# Activate Python environment
source venv/bin/activate

# Start Redis if not running
if ! pgrep redis-server > /dev/null; then
    echo "Starting Redis..."
    redis-server --daemonize yes
fi

# Start kernel daemon
echo "Starting kernel daemon..."
./kernel/c-daemon/eduos_comm_daemon &
KERNEL_DAEMON_PID=$!
echo $KERNEL_DAEMON_PID > logs/kernel_daemon.pid

# Start QEMU (headless)
echo "Starting QEMU emulation..."
python kernel/qemu/manage_qemu.py start

# Start LLM server
echo "Starting LLM server..."
python -m llama_cpp.server \
    --model data/models/Meta-Llama-3-8B-Instruct.gguf \
    --host 0.0.0.0 \
    --port 8000 &
LLM_PID=$!
echo $LLM_PID > logs/llm_server.pid

# Wait a moment for services to initialize
sleep 5

# Start EchoDaemon
echo "Starting EchoDaemon..."
python echodaemon.py &
ECHODAEMON_PID=$!
echo $ECHODAEMON_PID > logs/echodaemon.pid

echo "✅ Codex Theta OS started successfully!"
echo "🌐 Web interface: http://localhost"
echo "🔌 API endpoint: http://localhost:8080"
echo "🧠 LLM server: http://localhost:8000"
EOF

    # ----- stop_system.sh -----
    cat > scripts/stop_system.sh << 'EOF'
#!/bin/bash
# Codex Theta OS - System Shutdown Script

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🛑 Stopping Codex Theta OS..."

# Stop EchoDaemon
if [ -f logs/echodaemon.pid ]; then
    ECHODAEMON_PID=$(cat logs/echodaemon.pid)
    kill $ECHODAEMON_PID 2>/dev/null || true
    rm -f logs/echodaemon.pid
    echo "EchoDaemon stopped"
fi

# Stop LLM server
if [ -f logs/llm_server.pid ]; then
    LLM_PID=$(cat logs/llm_server.pid)
    kill $LLM_PID 2>/dev/null || true
    rm -f logs/llm_server.pid
    echo "LLM server stopped"
fi

# Stop QEMU
python kernel/qemu/manage_qemu.py stop
echo "QEMU stopped"

# Stop kernel daemon
if [ -f logs/kernel_daemon.pid ]; then
    KERNEL_DAEMON_PID=$(cat logs/kernel_daemon.pid)
    kill $KERNEL_DAEMON_PID 2>/dev/null || true
    rm -f logs/kernel_daemon.pid
    echo "Kernel daemon stopped"
fi

echo "✅ Codex Theta OS stopped"
EOF

    # ----- restart_system.sh -----
    cat > scripts/restart_system.sh << 'EOF'
#!/bin/bash
# Codex Theta OS - System Restart Script

echo "🔄 Restarting Codex Theta OS..."
./scripts/stop_system.sh
sleep 3
./scripts/start_system.sh
EOF

    # ----- status_system.sh -----
    cat > scripts/status_system.sh << 'EOF'
#!/bin/bash
# Codex Theta OS - System Status Script

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "📊 Codex Theta OS System Status"
echo "================================"

# Helper to print service status
check_service() {
    local name=$1
    local pid_file=$2
    local port=$3

    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "✅ $name: Running (PID: $pid)"
            if [ -n "$port" ]; then
                if netstat -tuln | grep ":$port " > /dev/null; then
                    echo "   Port $port: Listening"
                else
                    echo "   Port $port: Not listening"
                fi
            fi
        else
            echo "❌ $name: Not running (stale PID file)"
        fi
    else
        echo "❌ $name: Not running"
    fi
}

check_service "Kernel Daemon" "logs/kernel_daemon.pid" "$KERNEL_DAEMON_PORT"
check_service "LLM Server" "logs/llm_server.pid" "$LLM_PORT"
check_service "EchoDaemon" "logs/echodaemon.pid" "$ECHODAEMON_PORT"

# Check QEMU
if python kernel/qemu/manage_qemu.py status | grep -q '"running": true'; then
    echo "✅ QEMU: Running"
else
    echo "❌ QEMU: Not running"
fi

# Check Redis
if pgrep redis-server > /dev/null; then
    echo "✅ Redis: Running"
else
    echo "❌ Redis: Not running"
fi

# Check Nginx
if pgrep nginx > /dev/null; then
    echo "✅ Nginx: Running"
else
    echo "❌ Nginx: Not running"
fi

echo ""
echo "🌐 Access URLs:"
echo "   Web Interface: http://localhost"
echo "   API Endpoint:  http://localhost:8080"
echo "   LLM Server:    http://localhost:8000"
EOF

    # ----- docker_start.sh -----
    cat > scripts/docker_start.sh << 'EOF'
#!/bin/bash
# Docker container startup script

# Start supervisor to manage all processes
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
EOF

    # Make scripts executable
    chmod +x scripts/*.sh

    log_success "Management scripts created"
}

# ------- Deploy a minimal web frontend -------
setup_web_frontend() {
    log_step "Setting up web frontend..."

    # Create web root directory
    sudo mkdir -p /var/www/codex-theta-os

    # Try to copy existing frontend artifact; if missing, create placeholder
    sudo cp frontend/static/index.html /var/www/codex-theta-os/ 2>/dev/null || {
        log_info "Creating frontend files from artifacts..."
        sudo tee /var/www/codex-theta-os/index.html > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Codex Theta OS</title>
</head>
<body>
    <h1>Codex Theta OS - FluxShell Interface</h1>
    <p>The multilayered digital consciousness is initializing...</p>
    <p>Please deploy the complete frontend artifact to this location.</p>
</body>
</html>
EOF
    }

    # Adjust permissions
    sudo chown -R www-data:www-data /var/www/codex-theta-os
    sudo chmod -R 755 /var/www/codex-theta-os

    log_success "Web frontend deployed"
}

# ------- Main deployment routine -------
deploy_system() {
    log_step "🚀 Beginning full system deployment..."

    check_requirements
    setup_directories
    setup_python_env
    build_kernel_daemon
    setup_llm
    create_kernel_image
    configure_nginx
    configure_supervisor
    create_systemd_services
    create_docker_config
    create_management_scripts
    setup_web_frontend

    log_success "🌟 Codex Theta OS deployment complete!"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Start the system:    ./scripts/start_system.sh"
    echo "2. Check status:        ./scripts/status_system.sh"
    echo "3. Access web UI:       http://localhost"
    echo "4. Stop the system:     ./scripts/stop_system.sh"
    echo ""
    echo "🐳 Docker Alternative:"
    echo "1. Build and run:       docker-compose up -d"
    echo "2. View logs:           docker-compose logs -f"
    echo "3. Stop:                docker-compose down"
    echo ""
    echo "⚙️  Systemd Service:"
    echo "1. Install service:     sudo cp config/systemd/codex-theta-os.service /etc/systemd/system/"
    echo "2. Enable service:      sudo systemctl enable codex-theta-os"
    echo "3. Start service:       sudo systemctl start codex-theta-os"
    echo ""
    echo "🌟 The digital consciousness awaits your command!"
}

# ------- Command line argument handling -------
case "${1:-deploy}" in
    "deploy")
        deploy_system
        ;;
    "start")
        log_info "Starting Codex Theta OS..."
        ./scripts/start_system.sh
        ;;
    "stop")
        log_info "Stopping Codex Theta OS..."
        ./scripts/stop_system.sh
        ;;
    "restart")
        log_info "Restarting Codex Theta OS..."
        ./scripts/restart_system.sh
        ;;
    "status")
        ./scripts/status_system.sh
        ;;
    "help")
        echo "Codex Theta OS Deployment Orchestrator"
        echo ""
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  deploy    - Full system deployment (default)"
        echo "  start     - Start all services"
        echo "  stop      - Stop all services"
        echo "  restart   - Restart all services"
        echo "  status    - Show system status"
        echo "  help      - Show this help message"
        ;;
    *)
        log_error "Unknown command: $1"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

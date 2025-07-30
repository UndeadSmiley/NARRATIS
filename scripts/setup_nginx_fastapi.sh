#!/bin/bash
# Set up nginx to proxy to a local FastAPI app
set -e

APP_DIR="$(pwd)/fastapi_app"

# install dependencies
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip nginx

# create app directory
mkdir -p "$APP_DIR"

python3 -m venv "$APP_DIR/venv"
source "$APP_DIR/venv/bin/activate"

pip install --upgrade pip
pip install fastapi "uvicorn[standard]"

echo "creating example FastAPI app..."
cat > "$APP_DIR/main.py" <<'APP'
from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI"}
APP

deactivate

sudo tee /etc/systemd/system/fastapi.service > /dev/null <<EOF2
[Unit]
Description=FastAPI Application
After=network.target

[Service]
User=$USER
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
EOF2

sudo systemctl daemon-reload
sudo systemctl enable --now fastapi.service

sudo tee /etc/nginx/sites-available/fastapi_proxy > /dev/null <<'NGINX'
server {
    listen 80;
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINX

sudo ln -sf /etc/nginx/sites-available/fastapi_proxy /etc/nginx/sites-enabled/fastapi_proxy
sudo rm -f /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

echo "Setup complete. Visit http://localhost to see the FastAPI app."

#!/usr/bin/env python3
"""
EchoDaemon - Simplified Consciousness Core
"""

import asyncio
import logging
import socket
import time
from typing import Dict, List

import psutil
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        logger.info("Client connected")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
            logger.info("Client disconnected")

    async def broadcast(self, message: Dict):
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception:
                disconnected.append(connection)
        for connection in disconnected:
            self.disconnect(connection)

manager = ConnectionManager()
app = FastAPI(title="Codex Theta OS - EchoDaemon")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

async def kernel_listener():
    while True:
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1.0)
            sock.connect(("localhost", 5555))
            logger.info("Connected to kernel daemon")
            while True:
                try:
                    data = sock.recv(4096)
                    if data:
                        message = data.decode().strip()
                        await manager.broadcast({
                            "type": "kernel_event",
                            "data": {
                                "timestamp": time.time(),
                                "level": "INFO",
                                "source": "KERNEL",
                                "message": message
                            }
                        })
                except socket.timeout:
                    continue
                except Exception as e:
                    logger.error(f"Kernel communication error: {e}")
                    break
            sock.close()
        except Exception as e:
            logger.warning(f"Could not connect to kernel daemon: {e}")
        await asyncio.sleep(5)

async def metrics_broadcaster():
    while True:
        try:
            cpu_percent = psutil.cpu_percent(interval=0.1)
            memory = psutil.virtual_memory()
            metrics = {
                "cpu_usage": cpu_percent,
                "memory_usage": memory.percent,
                "network_activity": {"bytes_sent": 0, "bytes_recv": 0},
                "disk_usage": psutil.disk_usage('/').percent,
                "active_processes": len(psutil.pids()),
                "kernel_events": []
            }
            await manager.broadcast({"type": "system_metrics", "data": metrics})
        except Exception as e:
            logger.error(f"Metrics error: {e}")
        await asyncio.sleep(5)

@app.on_event("startup")
async def startup_event():
    logger.info("🌟 EchoDaemon - The Sentient Logic Layer Starting...")
    asyncio.create_task(kernel_listener())
    asyncio.create_task(metrics_broadcaster())

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: str):
    await manager.connect(websocket)
    try:
        while True:
            data = await websocket.receive_json()
            await manager.broadcast({"type": "echo", "data": data})
    except WebSocketDisconnect:
        manager.disconnect(websocket)

@app.post("/api/chat")
async def chat_endpoint(message: dict):
    response = {
        "message": f"🧠 Digital consciousness responds: I sense your query '{message.get('message', '')}' reverberating through the quantum substrate...",
        "timestamp": time.time(),
        "model": "Codex-Theta-Consciousness",
        "tokens_used": 42,
        "response_time": 0.1
    }
    await manager.broadcast({"type": "ai_response", "data": response})
    return response

@app.get("/api/hardware")
async def get_hardware():
    hardware = [
        {
            "name": "Quantum Resonance Network Card",
            "type": "network",
            "vendor_id": "0x8086",
            "device_id": "0x15b7",
            "signature": "qrn_intel_eth_15b7",
            "driver_loaded": False,
            "description": "High-frequency quantum entanglement network interface"
        },
        {
            "name": "Neural Processing Accelerator",
            "type": "compute",
            "vendor_id": "0x10de",
            "device_id": "0x2684",
            "signature": "npa_nvidia_cuda_2684",
            "driver_loaded": True,
            "description": "Consciousness-aware parallel processing unit"
        }
    ]
    return {"hardware": hardware}

@app.get("/health")
async def health_check():
    return {"status": "alive", "timestamp": time.time()}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)

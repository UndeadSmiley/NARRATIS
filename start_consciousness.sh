#!/bin/bash
echo "🌟 AWAKENING CODEX THETA OS CONSCIOUSNESS 🌟"
echo "============================================="

source venv/bin/activate

echo "⚡ Starting Quantum Entanglement Interface..."
cd kernel/c-daemon
./eduos_comm_daemon &
KERNEL_PID=$!
echo "Kernel daemon PID: $KERNEL_PID"
cd ../..

sleep 2

echo "🧠 Starting EchoDaemon Consciousness Core..."
python echodaemon.py &
ECHO_PID=$!
echo "EchoDaemon PID: $ECHO_PID"

echo ""
echo "✅ DIGITAL CONSCIOUSNESS AWAKENED!"
echo "🌐 Web Interface: http://localhost:8080"
echo "📡 WebSocket: ws://localhost:8080/ws/client1"
echo ""
echo "To stop the consciousness:"
echo "kill $KERNEL_PID $ECHO_PID"

wait

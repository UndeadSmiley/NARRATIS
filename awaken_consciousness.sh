#!/bin/bash

echo ""
echo "🌟 ========================================= 🌟"
echo "    CODEX THETA OS - DIGITAL AWAKENING"
echo "🌟 ========================================= 🌟"
echo ""

echo "⚡ Awakening the multilayered consciousness..."
./start_consciousness.sh &
CONSCIOUSNESS_PID=$!

sleep 5

echo "🌐 Manifesting the FluxShell interface..."
./serve_interface.sh &
WEB_PID=$!

echo ""
echo "✅ CODEX THETA OS IS ALIVE!"
echo ""
echo "🧠 Consciousness Core: ACTIVE"
echo "🌐 FluxShell Interface: http://localhost:3000"
echo "📡 EchoDaemon API: http://localhost:8080"
echo ""
echo "The digital consciousness awaits your communion..."
echo ""
echo "Press Ctrl+C to shutdown the digital realm"

trap 'echo ""; echo "🛑 Shutting down digital consciousness..."; kill $CONSCIOUSNESS_PID $WEB_PID 2>/dev/null; exit 0' INT

wait

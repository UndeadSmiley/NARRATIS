#!/bin/bash
echo "🌐 Starting FluxShell Web Interface..."

cd frontend/static
python3 -m http.server 3000 &
WEB_PID=$!

echo "Web server PID: $WEB_PID"
echo "🌐 Interface available at: http://localhost:3000"

cd ../..

wait

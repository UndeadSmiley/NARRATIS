#!/bin/bash
# Simple setup and run script for NARRATIS

set -e

echo "== NARRATIS Local Run =="

REQUIRED=(python3 pip make gcc)
for cmd in "${REQUIRED[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: '$cmd' is required but not installed." >&2
        exit 1
    fi
done

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate

pip install -r requirements.txt

make -C kernel/c-daemon

python3 echodaemon.py

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

MODEL_PATH="data/models/pytorch_model.bin"

if [ ! -f "$MODEL_PATH" ]; then
    echo "Downloading LLM model (this may take a while)..."
    mkdir -p data/models
    python - <<'EOF'
from huggingface_hub import hf_hub_download
path = hf_hub_download(repo_id="microsoft/DialoGPT-medium", filename="pytorch_model.bin", cache_dir="data/models")
print(f"Model downloaded to: {path}")
EOF
fi

python -m llama_cpp.server --model "$MODEL_PATH" --host 0.0.0.0 --port 8000 &
LLM_PID=$!

python3 echodaemon.py

kill $LLM_PID

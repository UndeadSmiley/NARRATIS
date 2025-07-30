#!/bin/bash
set -e

# Basic build check for NARRATIS

# Ensure Python source compiles
python -m py_compile echodaemon.py

# Verify frontend files exist
if [ ! -f frontend/static/index.html ]; then
    echo "frontend missing" >&2
    exit 1
fi

echo "Build completed successfully."

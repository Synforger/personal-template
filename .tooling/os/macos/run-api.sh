#!/bin/bash
set -euo pipefail

# =============================================================================
# Local Dev Platform - macOS API Server Script
# =============================================================================
# This script starts the API server on macOS.
# No sudo allowed.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "=== Local Dev Platform: Run API (macOS) ==="

# Check if .venv exists
VENV_DIR="${PROJECT_ROOT}/.venv"
if [ ! -d "${VENV_DIR}" ]; then
    echo "Error: Virtual environment not found at ${VENV_DIR}"
    echo "Please run 'task setup' first."
    exit 1
fi

# Start API server (FastAPI with uvicorn)
echo "Starting API server..."
echo "Access at: http://127.0.0.1:8000"
echo "API docs at: http://127.0.0.1:8000/docs"

if [ -d "src/my_package" ]; then
    PYTHONPATH="${PROJECT_ROOT}/src" "${VENV_DIR}/bin/uvicorn" my_package.api.app:app --reload --host 0.0.0.0 --port 8000
else
    "${VENV_DIR}/bin/uvicorn" my_package.api.app:app --reload --host 0.0.0.0 --port 8000
fi

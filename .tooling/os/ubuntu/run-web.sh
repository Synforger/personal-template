#!/bin/bash
set -euo pipefail

# =============================================================================
# Local Dev Platform - Ubuntu Web/Frontend Script
# =============================================================================
# This script starts the frontend/web server on Ubuntu.
# For this template, it starts the Sphinx documentation preview server.
# No sudo allowed.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "=== Local Dev Platform: Run Web (Ubuntu) ==="

# Check if .venv exists
VENV_DIR="${PROJECT_ROOT}/.venv"
if [ ! -d "${VENV_DIR}" ]; then
    echo "Error: Virtual environment not found at ${VENV_DIR}"
    echo "Please run 'task setup' first."
    exit 1
fi

# Start documentation preview server
echo "Starting documentation preview server..."
echo "Access at: http://127.0.0.1:8000"

rm -rf docs/build/
"${VENV_DIR}/bin/sphinx-apidoc" -f -o ./docs/source ./src/my_package
"${VENV_DIR}/bin/sphinx-autobuild" -b html --watch src/my_package/ docs/source/ docs/build/

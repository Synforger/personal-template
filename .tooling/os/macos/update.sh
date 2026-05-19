#!/bin/bash
set -euo pipefail

# =============================================================================
# Local Dev Platform - macOS Update Script
# =============================================================================
# This script updates Python and Node.js dependencies.
# No sudo required - assumes .venv already exists.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "=== Local Dev Platform: Update (macOS) ==="

# Check if .venv exists
VENV_DIR="${PROJECT_ROOT}/.venv"
if [ ! -d "${VENV_DIR}" ]; then
    echo "Error: Virtual environment not found at ${VENV_DIR}"
    echo "Please run 'task setup' first."
    exit 1
fi

# Upgrade pip
echo "Upgrading pip..."
"${VENV_DIR}/bin/python" -m pip install --upgrade pip

# Update Python dependencies
echo "Updating Python dependencies..."
"${VENV_DIR}/bin/python" -m pip install --upgrade -e ".[dev,sample,api,cli]"

# Update Node.js dependencies (if package.json exists)
if [ -f "package.json" ]; then
    echo "Updating Node.js dependencies..."
    npm update
fi

echo ""
echo "=== Update complete! ==="

#!/bin/bash
set -euo pipefail

# =============================================================================
# Local Dev Platform - macOS Setup Script
# =============================================================================
# This script sets up the development environment on macOS.
# Admin rights allowed here for OS-level tool installation (brew).
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "=== Local Dev Platform: Setup (macOS) ==="
echo "Project root: ${PROJECT_ROOT}"

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "Python version: ${PYTHON_VERSION}"

# Check if go-task is installed
if ! command -v task &> /dev/null; then
    echo "Warning: go-task is not installed."
    echo "Please install it with: npm install -g @go-task/cli"
    echo "Or visit: https://taskfile.dev/installation/"
fi

# Create virtual environment if it doesn't exist
VENV_DIR="${PROJECT_ROOT}/.venv"
if [ ! -d "${VENV_DIR}" ]; then
    echo "Creating virtual environment..."
    python3 -m venv "${VENV_DIR}"
else
    echo "Virtual environment already exists: ${VENV_DIR}"
fi

# Upgrade pip (using venv python directly, no activation)
echo "Upgrading pip..."
"${VENV_DIR}/bin/python" -m pip install --upgrade pip

# Install dependencies
echo "Installing development dependencies..."
"${VENV_DIR}/bin/python" -m pip install -e ".[dev,sample,api,cli]"

# Configure git hooks
echo "Configuring git hooks..."
git config --local core.hooksPath .githooks
chmod -R +x .githooks/

echo ""
echo "=== Setup complete! ==="
echo "To activate the virtual environment manually, run:"
echo "  source ${VENV_DIR}/bin/activate"
echo ""
echo "Available task commands:"
echo "  task --list"

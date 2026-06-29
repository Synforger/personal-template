#!/bin/bash
# =============================================================================
# Build executable using PyInstaller (macOS)
# =============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

cd "$PROJECT_ROOT"

# Determine Python executable
if [ -d ".venv" ]; then
    PYTHON=".venv/bin/python"
    PIP=".venv/bin/pip"
else
    PYTHON="python"
    PIP="pip"
fi

# Check if PyInstaller is installed
if ! $PYTHON -c "import PyInstaller" 2>/dev/null; then
    echo "Installing PyInstaller..."
    $PIP install -e ".[pyinstaller]"
fi

# Use fixed spec file name (does not depend on package name)
SPEC_FILE="pyinstaller.spec"

if [ ! -f "$SPEC_FILE" ]; then
    echo "Error: Spec file '$SPEC_FILE' not found!"
    exit 1
fi

echo "Building executable with PyInstaller..."
$PYTHON -m PyInstaller "$SPEC_FILE" --clean --noconfirm

echo ""
echo "Build complete! Executable is in the dist/ directory."

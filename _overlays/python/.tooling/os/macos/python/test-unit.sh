#!/bin/bash
set -euo pipefail

# =============================================================================
# Local Dev Platform - macOS Unit Test Script
# =============================================================================
# This script runs unit tests.
# Common entry point for CI/human/AI.
# No sudo allowed.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "=== Local Dev Platform: Unit Test (macOS) ==="

# Check if .venv exists
VENV_DIR="${PROJECT_ROOT}/.venv"
if [ ! -d "${VENV_DIR}" ]; then
    echo "Error: Virtual environment not found at ${VENV_DIR}"
    echo "Please run 'task setup' first."
    exit 1
fi

# Run pytest
echo "Running pytest..."
if [ -d "src/my_package" ]; then
    PYTHONPATH="${PROJECT_ROOT}/src" "${VENV_DIR}/bin/python" -m pytest tests --doctest-modules src/my_package
else
    "${VENV_DIR}/bin/python" -m pytest tests --doctest-modules --pyargs my_package
fi

echo ""
echo "=== Unit Test complete! ==="

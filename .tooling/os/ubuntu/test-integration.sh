#!/bin/bash
set -euo pipefail

# =============================================================================
# Local Dev Platform - Ubuntu Integration Test Script
# =============================================================================
# This script runs integration tests.
# Common entry point for CI/human/AI.
# No sudo allowed.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "=== Local Dev Platform: Integration Test (Ubuntu) ==="

# Check if .venv exists
VENV_DIR="${PROJECT_ROOT}/.venv"
if [ ! -d "${VENV_DIR}" ]; then
    echo "Error: Virtual environment not found at ${VENV_DIR}"
    echo "Please run 'task setup' first."
    exit 1
fi

# Run integration tests
echo "Running integration tests..."
if [ -d "tests/integration" ]; then
    if [ -d "src/my_package" ]; then
        PYTHONPATH="${PROJECT_ROOT}/src" "${VENV_DIR}/bin/python" -m pytest tests/integration -v
    else
        "${VENV_DIR}/bin/python" -m pytest tests/integration -v
    fi
else
    echo "No integration tests found in tests/integration/"
    echo "Skipping integration tests."
fi

echo ""
echo "=== Integration Test complete! ==="

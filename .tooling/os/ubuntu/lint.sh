#!/bin/bash
set -euo pipefail

# =============================================================================
# Local Dev Platform - Ubuntu Lint Script
# =============================================================================
# This script runs lint and autoformat checks.
# For AI/CI use. Humans typically use editor auto-formatting.
# No sudo allowed.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

cd "${PROJECT_ROOT}"

echo "=== Local Dev Platform: Lint (Ubuntu) ==="

# Check if .venv exists
VENV_DIR="${PROJECT_ROOT}/.venv"
if [ ! -d "${VENV_DIR}" ]; then
    echo "Error: Virtual environment not found at ${VENV_DIR}"
    echo "Please run 'task setup' first."
    exit 1
fi

# Run black autoformat
echo "Running black..."
"${VENV_DIR}/bin/black" .

# Run flake8 lint
echo "Running flake8..."
"${VENV_DIR}/bin/flake8" . --jobs 1 --count --select=E9,F63,F7,F82 --show-source --max-complexity=10 --statistics

# Run anonymity scan (replaces the disabled anon-check GitHub Action in
# this template variant). Same PCRE pattern, executed locally via perl.
echo "Running anonymity scan..."
bash "${PROJECT_ROOT}/.tooling/local-ci/anon-scan.sh"

echo ""
echo "=== Lint complete! ==="

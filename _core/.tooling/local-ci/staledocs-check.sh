#!/bin/bash
set -eu

# staledocs-check.sh — code<->docs coherence gate (`task docs:coherence`).
#
# Runs `staledocs check` against the repo's .staledocs.yaml. The config's
# `gate` key decides severity: warn = report only, strict = non-zero exit
# on red findings. Self-installs the CLI when missing so a bare `task ci`
# works on fresh CI runners without a dedicated setup step.
#
# Exit code:
#   0 = clean (or warn-gate report)
#   1 = red findings under a strict gate, or missing config

if ! command -v staledocs >/dev/null 2>&1; then
    echo "staledocs-check: staledocs CLI not found; installing via pip --user"
    python3 -m pip install --user --quiet staledocs
    PATH="${PATH}:$(python3 -m site --user-base)/bin"
    export PATH
fi

if [ ! -f .staledocs.yaml ]; then
    echo "staledocs-check: .staledocs.yaml missing at the repo root" >&2
    echo "                 run 'staledocs init' or copy the template config" >&2
    exit 1
fi

exec staledocs check

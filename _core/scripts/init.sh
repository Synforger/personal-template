#!/usr/bin/env bash
# =============================================================================
# personal-template / init script (= PR 1 minimum: Python-only)
# =============================================================================
# Promotes `_core/` and the chosen language overlays (= Python only in this
# revision) to the repo root, then deletes the staging directories. After
# this script finishes the working tree looks like an ordinary single-language
# repo and the template's `_core / _overlays` structure no longer leaks into
# the derived project.
#
# PR 6 will replace this with an interactive multiselect that supports the
# full overlay roster (= python / node / rust / swift / kotlin / cs).
# =============================================================================

set -euo pipefail
shopt -s dotglob nullglob

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
cd "${REPO_ROOT}"

if [ ! -d "_core" ] || [ ! -d "_overlays/python" ]; then
    echo "error: _core/ or _overlays/python/ not found. Run from a freshly" >&2
    echo "       cloned personal-template repo." >&2
    exit 1
fi

echo "==> Promoting _core/ contents to repo root"
for path in _core/*; do
    base="$(basename "${path}")"
    if [ -e "${base}" ]; then
        echo "error: refusing to overwrite existing ${base} at repo root" >&2
        exit 1
    fi
    mv "${path}" "${base}"
done
rmdir _core

echo "==> Promoting _overlays/python/ contents to repo root"
for path in _overlays/python/*; do
    base="$(basename "${path}")"
    if [ -e "${base}" ]; then
        # Merge directories that already exist (= .tooling/ from core +
        # .tooling/os/<os>/python/ from overlay). Other collisions are real
        # bugs and fail loud.
        if [ -d "${path}" ] && [ -d "${base}" ]; then
            cp -R "${path}/." "${base}/"
            rm -rf "${path}"
        else
            echo "error: refusing to overwrite existing ${base} at repo root" >&2
            exit 1
        fi
    else
        mv "${path}" "${base}"
    fi
done
rm -rf _overlays

echo "==> Removing template-only files (= usage guides for derivers)"
rm -f docs/internals/template-usage.md

echo
echo "==> Template scaffolding promoted. Next steps:"
echo "    1. pip install -r setup-requirements.txt"
echo "    2. python personalize.py"
echo "    3. task setup"
echo

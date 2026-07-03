#!/usr/bin/env bash
# =============================================================================
# personal-template / aggregate security audit
# =============================================================================
# Runs every available security scanner against the working tree and aggregates
# exit codes. Each scanner section is skipped (with a warning, not a fail) when
# the corresponding tool is not on PATH or the corresponding overlay is absent
# — keeps `task audit` workable in any subset of language overlays.
#
# Scanners (= roughly in fastest-to-slowest order):
#   - anon-scan           full-tree personal-identifier scan
#   - gitleaks            full-history secret scan (= deeper than the pre-commit
#                         `gitleaks protect --staged` mode)
#   - pip-audit           python overlay: PyPI advisory db check
#   - npm audit           node overlay: npm advisory db check (production deps)
#   - cargo audit         rust overlay: RustSec advisory db check
#
# Usage:
#   task audit
#   # or directly:
#   bash .tooling/local-ci/audit.sh
#
# Exit:
#   0 = every available scanner clean (or skipped)
#   1 = at least one scanner reported findings
# =============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "${SCRIPT_DIR}" in
    */_core/.tooling/local-ci) PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)" ;;
    *)                         PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"   ;;
esac
cd "${PROJECT_ROOT}"

# shellcheck source=setup-lib.sh
source "${SCRIPT_DIR}/setup-lib.sh"

overall_fail=0

run_section() {
    local label="$1"; shift
    local title="=== ${label} ==="
    printf '\n%s\n' "${title}" >&2
    if "$@"; then
        log_ok "${label}: clean"
    else
        log_fail "${label}: findings (exit=$?)"
        overall_fail=1
    fi
}

skip_section() {
    local label="$1"; shift
    local reason="$*"
    printf '\n=== %s ===\n' "${label}" >&2
    log_warn "${label}: skipped (${reason})"
}

# ---- anon-scan -------------------------------------------------------------

ANON_SCANNER="${SCRIPT_DIR}/anon-scan.sh"
if [ ! -x "${ANON_SCANNER}" ] && [ -f "${HOME}/.git-hooks/scanners/anon-scan.sh" ]; then
    ANON_SCANNER="${HOME}/.git-hooks/scanners/anon-scan.sh"
fi
if [ -f "${ANON_SCANNER}" ]; then
    run_section "anon-scan" bash "${ANON_SCANNER}"
else
    skip_section "anon-scan" "scanner not found (repo-local or guard-dispatcher)"
fi

# ---- gitleaks (full-history) -----------------------------------------------

if check_command gitleaks; then
    run_section "gitleaks (full history)" gitleaks detect --no-banner --redact
else
    skip_section "gitleaks" "not installed (brew install gitleaks | apt install gitleaks)"
fi

# ---- pip-audit (python overlay) -------------------------------------------

# NOTE: every language probe below looks ONLY at the post-init layout
# (= project root or its known sub-dirs like frontend/). `_overlays/<lang>/`
# paths are intentionally NOT scanned — at template state those dirs hold
# scaffold material, not an active project, and running e.g. `npm audit`
# against them fails with ENOLOCK because no lockfile is generated until
# the overlay is promoted via `task init` and `task setup` runs.

if [ -f "pyproject.toml" ]; then
    if check_command pip-audit; then
        run_section "pip-audit" pip-audit
    elif check_command pip; then
        skip_section "pip-audit" "not installed (pip install pip-audit)"
    else
        skip_section "pip-audit" "neither pip nor pip-audit available"
    fi
else
    skip_section "pip-audit" "python overlay not active (= no pyproject.toml at root)"
fi

# ---- npm audit (node overlay) ---------------------------------------------

NODE_DIR=""
for c in "${PROJECT_ROOT}" "${PROJECT_ROOT}/frontend"; do
    if [ -f "${c}/package.json" ]; then NODE_DIR="${c}"; break; fi
done
if [ -n "${NODE_DIR}" ]; then
    if check_command npm; then
        run_section "npm audit (${NODE_DIR#${PROJECT_ROOT}/})" \
            bash -c "cd '${NODE_DIR}' && npm audit --omit=dev"
    else
        skip_section "npm audit" "npm not installed"
    fi
else
    skip_section "npm audit" "node overlay not active (= no package.json at root)"
fi

# ---- cargo audit (rust overlay) -------------------------------------------

if [ -f "${PROJECT_ROOT}/Cargo.toml" ]; then
    if check_command cargo-audit || check_command cargo; then
        run_section "cargo audit" \
            bash -c "cd '${PROJECT_ROOT}' && cargo audit"
    else
        skip_section "cargo audit" "neither cargo nor cargo-audit installed"
    fi
else
    skip_section "cargo audit" "rust overlay not active (= no Cargo.toml at root)"
fi

printf '\n' >&2
if [ "${overall_fail}" -eq 0 ]; then
    log_ok "audit: all available scanners clean"
    exit 0
fi
log_fail "audit: one or more scanners reported findings"
exit 1

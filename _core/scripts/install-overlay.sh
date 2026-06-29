#!/usr/bin/env bash
# =============================================================================
# personal-template / install:overlay (= back-port one language overlay)
# =============================================================================
# Copies one `_overlays/<lang>/` overlay's contents into an existing repo.
# Same conflict handling as install-core.sh (= `.tmpl.orig` backups).
#
# Also patches the target's `.tooling/bump-targets.yaml` and `Taskfile.yml`
# `includes:` block when present (= so the new overlay is wired in for the
# next bump and `task <prefix>:lint` etc. work immediately).
#
# Usage:
#   task install:overlay NAME=rust TARGET=/path/to/existing-repo
#   # or directly:
#   bash _core/scripts/install-overlay.sh rust /path/to/existing-repo
#
# Args / env:
#   $1 or NAME    Required. Overlay name (= python|node|rust|swift|kotlin|csharp).
#   $2 or TARGET  Required. Path to target repo root.
#   DRY_RUN       Optional (=1). List planned copies without writing.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_CORE="${SOURCE_ROOT}/_core"

# shellcheck source=../.tooling/local-ci/setup-lib.sh
source "${SOURCE_CORE}/.tooling/local-ci/setup-lib.sh"

NAME="${1:-${NAME:-}}"
TARGET="${2:-${TARGET:-}}"
DRY_RUN="${DRY_RUN:-0}"

if [ -z "${NAME}" ] || [ -z "${TARGET}" ]; then
    log_fail "usage: install-overlay.sh <name> <target-repo-path>   (or set NAME= TARGET= env)"
    exit 2
fi

case "${NAME}" in
    python|node|rust|swift|kotlin|csharp) ;;
    *) log_fail "unknown overlay: ${NAME} (expected python|node|rust|swift|kotlin|csharp)"; exit 2 ;;
esac

SOURCE_OVERLAY="${SOURCE_ROOT}/_overlays/${NAME}"
if [ ! -d "${SOURCE_OVERLAY}" ]; then
    log_fail "_overlays/${NAME}/ not found (= run from a template-state personal-template clone)"
    exit 2
fi

TARGET="$(cd "${TARGET}" 2>/dev/null && pwd)" || {
    log_fail "TARGET not a directory: ${TARGET}"
    exit 2
}

if [ ! -d "${TARGET}/.git" ]; then
    log_fail "TARGET (${TARGET}) is not a git repo"
    exit 2
fi

log_info "overlay: ${NAME}"
log_info "source: ${SOURCE_OVERLAY}"
log_info "target: ${TARGET}"
log_info "dry_run: ${DRY_RUN}"

if ! command -v rsync >/dev/null 2>&1; then
    log_fail "rsync not installed (brew install rsync | apt install rsync)"
    exit 2
fi

# _README.md is template-internal metadata, not for the derived repo.
EXCLUDES=(
    "--exclude=_README.md"
)

RSYNC_FLAGS=(-a --backup --suffix=.tmpl.orig "${EXCLUDES[@]}")
if [ "${DRY_RUN}" = "1" ]; then
    RSYNC_FLAGS+=(--dry-run --itemize-changes)
fi

echo
log_info "running rsync"
rsync "${RSYNC_FLAGS[@]}" "${SOURCE_OVERLAY}/" "${TARGET}/"

echo
if [ "${DRY_RUN}" = "1" ]; then
    log_info "DRY_RUN=1; nothing changed on disk"
    log_info "After a real run, manually:"
    log_info "  1. Append the overlay's bump-targets snippet to .tooling/bump-targets.yaml"
    log_info "     (see ${SOURCE_OVERLAY}/_README.md § 'bump-targets 追加')"
    log_info "  2. Add a Taskfile.yml includes entry for the overlay's Taskfile"
    log_info "  3. Update .tooling/versions.yaml with the overlay's toolchain entry"
    exit 0
fi

log_ok "install:overlay ${NAME} files copied"
log_warn "manual follow-up required:"
log_warn "  1. Append the overlay's bump-targets snippet to .tooling/bump-targets.yaml"
log_warn "     (see ${SOURCE_OVERLAY}/_README.md § 'bump-targets 追加')"
log_warn "  2. Add a Taskfile.yml includes entry pointing at Taskfile.${NAME}.yml"
log_warn "  3. Update .tooling/versions.yaml with the overlay's toolchain entry"
log_info "review conflicts: find '${TARGET}' -name '*.tmpl.orig'"

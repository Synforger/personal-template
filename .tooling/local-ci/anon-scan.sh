#!/bin/bash
set -euo pipefail

# =============================================================================
# Local Dev Platform - Anonymity Scanner (local)
# =============================================================================
# Equivalent of the deprecated `.github/workflows/anon-check.yml`. Scans
# the repository for personal identifiers and operator-internal stack
# names that must never appear in committed files. Same PCRE pattern as
# the old workflow; word boundaries + negative lookaheads keep
# accessibility attributes (`aria-label`, `aria-hidden`) and npm package
# names (`aria-query`, `ark-*`) out of the false-positive lane.
#
# Called from two places:
#   - .githooks/pre-commit  (= staged-file scan before each commit)
#   - .tooling/os/<os>/lint.sh  (= full-tree scan via `task lint`)
#
# Exit code:
#   0 = clean
#   1 = personal identifier found
#
# Optional env:
#   ANON_SCAN_PATHS  newline-separated subset of files to scan (used by
#                    the pre-commit hook to limit the scan to staged
#                    files). Empty = scan the whole tree.
# =============================================================================

# PCRE pattern. Mirrors the anon-check workflow exactly so the two
# guards stay semantically identical (commit-time + CI-time).
# Word boundaries + negative lookaheads keep accessibility attributes
# (`aria-label`, `aria-hidden`) and npm package names (`aria-query`,
# `ark-*`) out of the false-positive lane. Prior employer / org names
# are deliberately included here so a public personal repo never
# leaks affiliation.
PATTERN='(?i)(\b(okg|haven)\b|arayabrain|\baraya\b|com\.okg\.|\baria\b(?!-)|\bark\b(?!-))'

# Files / dirs that legitimately contain string fragments matching the
# pattern (build artefacts, lockfiles with hash collisions, etc.). The
# original workflow used grep --exclude-* flags; ripgrep / perl do not,
# so we filter with a glob list passed to find.
EXCLUDES=(
    '.git'
    'node_modules'
    'dist'
    'build'
    '.venv'
    'venv'
    '__pycache__'
    '.next'
)
EXCLUDE_GLOBS=(
    '*.lock'
    'package-lock.json'
    'yarn.lock'
    '*.min.js'
    'anon-check.yml'  # the workflow file is allowed to contain the pattern definition
    'anon-scan.sh'    # this script likewise
    'README.md'       # workflow README mentions the pattern as documentation
)

scan_with_perl() {
    local file="$1"
    perl -ne 'BEGIN { $re = qr/(?i)(\b(okg|haven)\b|arayabrain|\baraya\b|com\.okg\.|\baria\b(?!-)|\bark\b(?!-))/ }
              if (/$re/) { print "$ARGV:$.:$_"; $found = 1 }
              END { exit($found ? 1 : 0) }' "$file"
}

# Returns 0 if `basename($1)` is in EXCLUDE_GLOBS, 1 otherwise. Used to
# keep the scanner's own pattern definition (and the workflow's mirror
# of it, and any policy README that documents the pattern) out of the
# false-positive lane both in full-tree scans and in the staged-file
# mode driven by the pre-commit hook.
is_excluded_basename() {
    local base
    base="$(basename "$1")"
    for glob in "${EXCLUDE_GLOBS[@]}"; do
        # shellcheck disable=SC2053
        if [[ "${base}" == ${glob} ]]; then
            return 0
        fi
    done
    return 1
}

scan_paths=()
if [ -n "${ANON_SCAN_PATHS:-}" ]; then
    while IFS= read -r p; do
        [ -z "$p" ] && continue
        [ -f "$p" ] || continue
        is_excluded_basename "$p" && continue
        scan_paths+=("$p")
    done <<< "${ANON_SCAN_PATHS}"
else
    # Build a find command with all the excludes.
    find_args=(.)
    for dir in "${EXCLUDES[@]}"; do
        find_args+=(-not -path "*/${dir}/*")
    done
    for glob in "${EXCLUDE_GLOBS[@]}"; do
        find_args+=(-not -name "${glob}")
    done
    find_args+=(-type f)
    # macOS / Linux portable: read NUL-delimited paths into the array.
    while IFS= read -r -d '' p; do
        scan_paths+=("$p")
    done < <(find "${find_args[@]}" -print0)
fi

found=0
for path in "${scan_paths[@]}"; do
    # Skip non-text files quickly via the `file` command. perl on a
    # binary will not match anyway, but skipping is cheaper.
    case "$path" in
        *.png|*.jpg|*.jpeg|*.gif|*.pdf|*.zip|*.gz|*.tar|*.so|*.dylib|*.dll|*.exe|*.bin|*.csv|*.npy|*.ipynb)
            continue
            ;;
    esac
    if ! scan_with_perl "$path"; then
        found=1
    fi
done

if [ "${found}" -ne 0 ]; then
    echo ""
    echo "Personal identifiers detected. Remove or move to gitignored config."
    exit 1
fi

echo "anon-scan: clean"
exit 0

#!/usr/bin/env bash
# =============================================================================
# Global Git Hooks Dispatcher — Common Library
# =============================================================================
# Shared helpers used by every dispatcher hook (pre-commit / commit-msg /
# pre-push). Sourced, never executed directly.
#
# Contract:
#   - Kept minimal: repo classification + delegation to repo-local hooks.
#   - Never mutates the working tree or git state.
#   - No external dependencies beyond POSIX + git.
# =============================================================================

# Repo classification.
#
# Emits one of:
#   synforger  — remote URL points at the Synforger GitHub organisation
#   other      — remote URL points elsewhere (personal / third-party / work)
#   no-remote  — no `origin` remote configured (fresh repo / detached working tree)
#
# The `synforger` result is what the dispatcher uses to decide whether to
# enforce baseline scans on a repo that does not carry its own hooks. Every
# other repo is treated as opt-in: it only gets whatever hooks it ships itself.
dispatcher::detect_repo_kind() {
    local url
    url="$(git config --get remote.origin.url 2>/dev/null || true)"

    if [ -z "${url}" ]; then
        echo "no-remote"
        return 0
    fi

    # Accept both HTTPS (github.com/Synforger/…) and SSH (git@github.com:Synforger/…)
    # forms, including custom host aliases like `github-synforger`. Case-insensitive
    # to tolerate the org name being written in any case.
    if printf '%s' "${url}" | grep -Eqi '(github[^/:]*[/:])synforger/'; then
        echo "synforger"
        return 0
    fi

    echo "other"
}

# Delegate to a repo-local hook if it exists.
#
# Usage:  dispatcher::delegate_if_present <hook-name> "$@"
#
# Looks for `<repo-root>/.githooks/<hook-name>` and, when it is present and
# executable, execs it with the original arguments. stdin is inherited so
# hooks that consume ref ranges (pre-push, pre-receive) keep working.
#
# Returns:
#   0    — nothing delegated, caller should continue with its fallback logic
#   (exec) — control transferred to the local hook; this function never returns
dispatcher::delegate_if_present() {
    local hook_name="$1"
    shift

    local repo_root
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    [ -n "${repo_root}" ] || return 0

    local local_hook="${repo_root}/.githooks/${hook_name}"
    if [ -x "${local_hook}" ]; then
        exec "${local_hook}" "$@"
    fi

    return 0
}

# Locate the repo-local anon scanner. Emits the path on stdout when present,
# nothing otherwise. Callers decide whether an absent scanner is fatal.
dispatcher::locate_anon_scanner() {
    local repo_root
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
    [ -n "${repo_root}" ] || return 0

    local scanner="${repo_root}/.tooling/local-ci/anon-scan.sh"
    if [ -x "${scanner}" ]; then
        printf '%s' "${scanner}"
    fi
}

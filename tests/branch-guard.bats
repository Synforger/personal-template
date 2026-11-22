#!/usr/bin/env bats
# Tests for the branch-name guard of both pre-commit hooks: the template's own and the one a derived repo gets.

load helpers

setup() {
    export GIT_AUTHOR_NAME=fixture GIT_AUTHOR_EMAIL=fixture@example.com
    export GIT_COMMITTER_NAME=fixture GIT_COMMITTER_EMAIL=fixture@example.com
    mkdir "${BATS_TEST_TMPDIR}/bin" "${BATS_TEST_TMPDIR}/repo"
    # a command with the same name as the branch, and a secret scan with nothing to find
    printf '#!/bin/sh\ntouch "%s/ran"\n' "${BATS_TEST_TMPDIR}" > "${BATS_TEST_TMPDIR}/bin/probe"
    printf '#!/bin/sh\nexit 0\n' > "${BATS_TEST_TMPDIR}/bin/gitleaks"
    chmod +x "${BATS_TEST_TMPDIR}/bin/probe" "${BATS_TEST_TMPDIR}/bin/gitleaks"
    cd "${BATS_TEST_TMPDIR}/repo"
    git init -q .
    TIP="$(git commit-tree "$(git write-tree)" -m fixture)"
}

# stand_on <branch> <on|detached>
stand_on() {
    git update-ref "refs/heads/$1" "${TIP}"
    git symbolic-ref HEAD "refs/heads/$1"
    if [ "$2" = detached ]; then git update-ref --no-deref HEAD "${TIP}"; fi
}

run_hook() {
    run env PATH="${BATS_TEST_TMPDIR}/bin:${PATH}" bash "${TEMPLATE_ROOT}/$1"
}

@test "a detached HEAD's branch name does not run as a command" {
    stand_on probe detached
    for hook in .githooks/pre-commit _core/.githooks/pre-commit; do
        run_hook "${hook}"
        [ "$status" -eq 0 ]
        [ ! -e "${BATS_TEST_TMPDIR}/ran" ]
    done
}

@test "a detached HEAD at main is refused by the branch guard" {
    stand_on main detached
    for hook in .githooks/pre-commit _core/.githooks/pre-commit; do
        run_hook "${hook}"
        [ "$status" -eq 1 ]
        [[ "$output" == *"Can't commit on branch"* ]] || return 1
    done
}

@test "on main the commit is refused, on a feature branch it passes" {
    for hook in .githooks/pre-commit _core/.githooks/pre-commit; do
        stand_on main on
        run_hook "${hook}"
        [ "$status" -eq 1 ]
        stand_on feature/work on
        run_hook "${hook}"
        [ "$status" -eq 0 ]
    done
}

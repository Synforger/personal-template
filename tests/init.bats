#!/usr/bin/env bats
# Tests for _core/scripts/init.py (template → derived-repo promotion).

load helpers

# mk_template_repo — minimal template-state layout with _core/ staging.
mk_template_repo() {
    local dir="${BATS_TEST_TMPDIR}/template-${RANDOM}"
    mkdir -p "${dir}/_core/scripts" "${dir}/_core/.tooling" "${dir}/_core/docs/internals"
    cp "${TEMPLATE_ROOT}/_core/scripts/init.py" "${dir}/_core/scripts/"
    cat > "${dir}/_core/.tooling/bump-targets.yaml" <<'EOF'
current_version: 9.9.9
targets: []
EOF
    echo "core readme"    > "${dir}/_core/README.md"
    echo "core taskfile"  > "${dir}/_core/Taskfile.yml"
    echo "internal note"  > "${dir}/_core/_README.md"
    echo "usage guide"    > "${dir}/_core/docs/internals/template-usage.md"
    echo "root readme"    > "${dir}/README.md"
    echo "root taskfile"  > "${dir}/Taskfile.yml"
    cd "${dir}" || return 1
    git init -q .
}

@test "init promotes _core to root and removes the staging dir" {
    mk_template_repo
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    [ ! -d _core ]
    [ -f scripts/init.py ]
    grep -q "core readme" README.md
    grep -q "core taskfile" Taskfile.yml
}

@test "init resets the project version to 0.0.0" {
    mk_template_repo
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    grep -q "current_version: 0.0.0" .tooling/bump-targets.yaml
}

@test "init drops template-only files" {
    mk_template_repo
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    [ ! -f docs/internals/template-usage.md ]
    [ ! -f _README.md ]
}

@test "init refuses to overwrite a non-allowlisted root file" {
    mk_template_repo
    echo "user data" > "_core/precious.txt"
    echo "existing"  > "precious.txt"
    run python3 _core/scripts/init.py
    [ "$status" -ne 0 ]
    grep -q "existing" precious.txt
}

@test "init fails cleanly when _core is already gone" {
    mk_template_repo
    rm -rf _core
    run python3 _core/scripts/init.py 2>/dev/null || run python3 scripts/init.py
    [ "$status" -ne 0 ]
}

@test "init replaces a root file identical to its _core counterpart" {
    mk_template_repo
    echo "same content" > "_core/.editorconfig"
    echo "same content" > ".editorconfig"
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    grep -q "same content" .editorconfig
    [ ! -d _core ]
}

@test "init replaces a root dir identical to its _core counterpart" {
    mk_template_repo
    mkdir -p "_core/.githooks" ".githooks"
    echo "hook body" > "_core/.githooks/pre-commit"
    echo "hook body" > ".githooks/pre-commit"
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    grep -q "hook body" .githooks/pre-commit
}

@test "init lets allowlisted machinery dirs win over divergent root copies" {
    mk_template_repo
    mkdir -p ".tooling"
    echo "template-state stub" > ".tooling/setup-lib.sh"
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    [ ! -f .tooling/setup-lib.sh ]
    [ -f .tooling/bump-targets.yaml ]
}

@test "init drops the template bats suite and Japanese intro README" {
    mk_template_repo
    mkdir -p tests
    echo "bats" > tests/init.bats
    echo "bats" > tests/helpers.bash
    echo "intro" > README.ja.md
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    [ ! -f tests/init.bats ]
    [ ! -f README.ja.md ]
    [ ! -d tests ]
}

# --- the repository's name comes from its origin --------------------------------------
# {{repo_full_name}} / {{repo_name}} / {{maintainer_handle}} are decided by the origin remote;
# {{repo_description}} and {{threat_model}} are prose, left for the maintainer.

mk_placeholders() {
    printf '# {{repo_name}}\n\n> {{repo_description}}\n' > _core/README.md
    printf 'Report at https://github.com/{{repo_full_name}}/security (@{{maintainer_handle}})\n' > _core/SECURITY.md
}

@test "init fills the repository's name from an https origin and names what is left" {
    mk_template_repo
    mk_placeholders
    git remote add origin https://github.com/example-owner/example-repo.git
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    grep -qx '# example-repo' README.md
    grep -q 'github.com/example-owner/example-repo/security (@example-owner)' SECURITY.md
    grep -q '{{repo_description}}' README.md
    [[ "$output" == *"left for you to write: {{repo_description}}"* ]]
}

@test "init reads an ssh origin the same way" {
    mk_template_repo
    mk_placeholders
    git remote add origin git@github.com:example-owner/example-repo.git
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    grep -qx '# example-repo' README.md
}

@test "init without an origin leaves the placeholders and says so" {
    mk_template_repo
    mk_placeholders
    run python3 _core/scripts/init.py
    [ "$status" -eq 0 ]
    grep -qx '# {{repo_name}}' README.md
    [[ "$output" == *"no origin remote"* ]]
}

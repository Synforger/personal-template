# GitHub Actions policy for this template

**Projects derived from `personal-template` consume GitHub Actions minutes
only for the anonymity check.** Everything else runs locally via
`task`.

The intent: AI assisted personal repos need a cheap, fast, local
feedback loop. CI is reserved for the one check that genuinely cannot
be enforced locally with the same trust level — namely, that no
personal identifier or prior-employer org name has slipped into the
public repo.

## What is enabled

| Workflow file     | Trigger                              | Purpose                                                                                |
|-------------------|--------------------------------------|----------------------------------------------------------------------------------------|
| `anon-check.yml`  | `push` (any branch) + `pull_request` | PCRE scan for personal identifiers. Same pattern as `.tooling/local-ci/anon-scan.sh`. |

That's it. No matrix tests, no release builds, no version bump
workflow. Those concerns belong to local `task` commands; see the
top-level `README.md` for the catalogue.

## Local replacements

| Concern             | Local replacement                                                  |
|---------------------|--------------------------------------------------------------------|
| Unit tests          | `task test:unit`                                                   |
| Integration tests   | `task test:integration`                                            |
| Lint + format       | `task lint` (black, flake8, anonymity scan)                        |
| Anonymity check     | `task lint` + `.githooks/pre-commit` (mirror of `anon-check.yml`)  |
| Dependency updates  | manual `pip list --outdated` / `pnpm outdated` / equivalent        |
| Version bump        | derive a `task version:bump` per project when needed               |
| Release packaging   | derive a `task release:cut` per project when needed                |

## When to enable more workflows

Add workflows only when:

1. The check genuinely cannot run locally with the same trust (rare
   — anonymity is the canonical case because human review is bypassed
   for non-final-commit edits).
2. The Actions cost is bounded and predictable (e.g. seconds per run,
   not minutes per push on macOS runners).

For most cases the answer is "do it locally via `task` instead."

## Why anon-check is on CI as well as the pre-commit hook

The hook scans only **staged** files so commits stay fast. The CI
scans the **whole tree** on every push, which catches:

- files that were committed before the hook was installed,
- files staged via `git commit --no-verify`,
- branch overlap where a clean local branch picks up dirty content
  from a merge.

Two layers with the same PCRE pattern keep semantics aligned. The
pattern lives in two places (`.tooling/local-ci/anon-scan.sh` and
this workflow) on purpose — both are minimal and easy to keep in
sync.

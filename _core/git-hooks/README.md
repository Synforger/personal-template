# Global Git Hooks Dispatcher

A minimal `core.hooksPath` dispatcher that makes it structurally impossible
to ship a Synforger repo without at least its baseline anon scan running on
every commit.

## Why

Repo-local `.git/hooks/` is invisible to git status and easy to forget when
cloning fresh. Repo-scoped `core.hooksPath = .githooks` fixes that per repo
but silently regresses whenever a new clone forgets the config. The
dispatcher moves the enforcement point up to the user's global config so
that missing setup surfaces as a failed commit rather than a silent gap.

## Layout

```
_core/git-hooks/
├── pre-commit          — dispatcher
├── commit-msg          — dispatcher (delegate-only for now)
├── pre-push            — dispatcher (delegate-only for now)
├── lib/
│   └── dispatcher-common.sh
└── install.sh
```

## Behaviour

Every hook follows the same three-step logic:

1. If the current repo ships `.githooks/<hook-name>`, delegate to it (exec)
   and stop. Repo-local hooks always win.
2. Otherwise, classify the repo by `origin` URL:
   - **synforger** — a Synforger GitHub org repo: enforce the baseline
     (currently: `pre-commit` runs `.tooling/local-ci/anon-scan.sh` on
     staged files; missing scanner = hard fail).
   - **no-remote** — treated as "might become synforger", fail-safe.
   - **other** — no-op. Personal, third-party, and unrelated work repos
     are unaffected.
3. `commit-msg` and `pre-push` currently no-op after delegation. The real
   push-range scan and commit-message scan land in follow-up PRs (A-2 /
   A-4 of the anon-defence rework).

## Install

```sh
_core/git-hooks/install.sh
```

Idempotent. Re-running from another clone switches the source of truth to
that clone.

## Uninstall

```sh
git config --global --unset core.hooksPath
rm -rf ~/.git-hooks
```

## Migrating a repo that already set `core.hooksPath` locally

```sh
git -C <repo> config --unset core.hooksPath
```

The dispatcher will delegate to that repo's `.githooks/<hook>` on its
behalf, so nothing observable changes for the repo itself.

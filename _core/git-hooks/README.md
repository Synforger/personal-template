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
├── pre-commit          — dispatcher (staged-file scan on Synforger repos)
├── commit-msg          — dispatcher (message-file scan on Synforger repos)
├── pre-push            — dispatcher (push-range deep scan on Synforger repos)
├── lib/
│   └── dispatcher-common.sh
├── install.sh
└── doctor.sh           — diagnoses unarmed hook state across repos
```

## Behaviour

Every hook follows the same three-step logic:

1. If the current repo ships `.githooks/<hook-name>`, delegate to it (exec)
   and stop. Repo-local hooks always win.
2. Otherwise, classify the repo by `origin` URL:
   - **synforger** — a Synforger GitHub org repo: enforce the baseline:
     - `pre-commit` runs `.tooling/local-ci/anon-scan.sh` on staged files.
     - `pre-push` parses stdin ref ranges and runs
       `.tooling/local-ci/anon-audit-deep.sh --range <remote>..<local>`
       on every outgoing branch. New-branch pushes fall back to
       `origin/<default>..<local>`; delete pushes are skipped.
     - Missing scanner in either case = hard fail.
   - **no-remote** — treated as "might become synforger", fail-safe.
   - **other** — no-op. Personal, third-party, and unrelated work repos
     are unaffected.
3. `commit-msg` currently no-ops after delegation. The commit-message
   scan lands in a follow-up PR (package A-4 of the anon-defence rework).

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

## Doctor

`doctor.sh` diagnoses the exact unarmed-repo state that motivated this
dispatcher in the first place — global `core.hooksPath` reverting to
`.git/hooks` after a fresh clone, or a per-repo `core.hooksPath`
override still pointing at `.githooks` and bypassing the global
enforcement point.

```sh
~/.git-hooks/doctor.sh ~/repos/synforger/*
```

Reports the global hooksPath state, the presence and executability of
each dispatcher hook, and, per repo: classification (`synforger` /
`other` / `no-remote`), whether a local `core.hooksPath` override is
bypassing the dispatcher, and whether the local anon toolkit is
installed. Exits non-zero if any Synforger (or fail-safe no-remote)
repo is missing enforcement — wire it into your shell startup, a
`task doctor`, or a cron sweep to catch drift early.

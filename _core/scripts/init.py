#!/usr/bin/env python3
"""
personal-template / init script
================================

Promotes `_core/` and any chosen overlays to the repo root, rewrites the
root `Taskfile.yml` includes section based on the selection, appends each
overlay's bump-targets entry, then deletes the staging directories. After
this script finishes the working tree looks like an ordinary single- or
multi-language repo and the template's `_core / _overlays` structure no
longer leaks into the derived project.

Usage:
    task init                  # interactive multiselect
    task init OVERLAYS=python  # non-interactive (comma-separated)
    task init OVERLAYS=python,node,rust

The non-interactive form is for `task install:core` / scripted tests.
"""

from __future__ import annotations

import os
import re
import shutil
import sys
from pathlib import Path
from typing import Sequence

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
CORE = REPO_ROOT / "_core"
OVERLAYS_ROOT = REPO_ROOT / "_overlays"

# (key, taskfile-name, taskfile-prefix, bump-targets snippet, label)
OVERLAY_REGISTRY: list[tuple[str, str, str, str, str]] = [
    (
        "python",
        "Taskfile.python.yml",
        "py",
        """  - file: src/my_package/version.py
    replacements:
      - search: '_MAJOR = "{OLD_MAJOR}"'
        replace: '_MAJOR = "{NEW_MAJOR}"'
      - search: '_MINOR = "{OLD_MINOR}"'
        replace: '_MINOR = "{NEW_MINOR}"'
      - search: '_PATCH = "{OLD_PATCH}"'
        replace: '_PATCH = "{NEW_PATCH}"'
""",
        "Python (= pyproject.toml + src/my_package/ + pytest)",
    ),
    (
        "node",
        "Taskfile.node.yml",
        "node",
        """  - file: package.json
    replacements:
      - search: '"version": "{OLD}"'
        replace: '"version": "{NEW}"'
""",
        "Node.js / TypeScript (= package.json + tsconfig + vitest)",
    ),
    (
        "rust",
        "Taskfile.rust.yml",
        "rust",
        """  - file: Cargo.toml
    replacements:
      - search: 'version = "{OLD}"'
        replace: 'version = "{NEW}"'
""",
        "Rust (= Cargo.toml + src/lib.rs)",
    ),
    (
        "swift",
        "Taskfile.swift.yml",
        "swift",
        """  - file: Sources/MySwiftLib/MySwiftLib.swift
    replacements:
      - search: 'static let version = "{OLD}"'
        replace: 'static let version = "{NEW}"'
""",
        "Swift (= SwiftPM Package.swift + Sources/)",
    ),
    (
        "kotlin",
        "Taskfile.kotlin.yml",
        "kotlin",
        """  - file: build.gradle.kts
    replacements:
      - search: 'version = "{OLD}"'
        replace: 'version = "{NEW}"'
""",
        "Kotlin (= Gradle build.gradle.kts + src/main/kotlin/)",
    ),
    (
        "csharp",
        "Taskfile.csharp.yml",
        "cs",
        """  - file: src/MyCsharpLib.csproj
    replacements:
      - search: '<Version>{OLD}</Version>'
        replace: '<Version>{NEW}</Version>'
""",
        ".NET / C# (= .csproj + src/)",
    ),
]


def fail(msg: str) -> "Never":  # type: ignore[name-defined]
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(1)


def confirm_layout() -> None:
    if not CORE.is_dir():
        fail(f"_core/ not found at {CORE} (= already initialised?)")
    if not OVERLAYS_ROOT.is_dir():
        fail(f"_overlays/ not found at {OVERLAYS_ROOT} (= already initialised?)")


def pick_overlays_interactive() -> list[str]:
    print("Select which language overlays to include in the derived repo.")
    print("Multi-select via y / n / Enter (= Enter = no). Press Ctrl+C to abort.")
    print()
    chosen: list[str] = []
    for key, _, _, _, label in OVERLAY_REGISTRY:
        ans = input(f"  include {key:7} ? [{label}] (y/N) ").strip().lower()
        if ans in ("y", "yes"):
            chosen.append(key)
    return chosen


def pick_overlays_from_env(env_value: str) -> list[str]:
    requested = [x.strip() for x in env_value.split(",") if x.strip()]
    known = {k for k, *_ in OVERLAY_REGISTRY}
    unknown = [x for x in requested if x not in known]
    if unknown:
        fail(f"unknown overlay(s): {', '.join(unknown)} (known: {', '.join(sorted(known))})")
    return requested


# Files in _core/ that are expected to overwrite their template-state
# counterparts at the repo root. README.md + Taskfile.yml at the root are
# template-only scaffolding (= "use this template" intro + `task init` only)
# and must be replaced with the derived-repo versions from _core/.
ALLOW_ROOT_OVERWRITE = {"README.md", "Taskfile.yml"}


def promote_core() -> None:
    for path in sorted(CORE.iterdir()):
        if path.name == "_README.md":
            # Template-internal doc explaining what `_core/` is. Not part of
            # the derived repo (= equivalent to dropping _overlays/<lang>/_README.md).
            path.unlink()
            continue
        dst = REPO_ROOT / path.name
        if dst.exists():
            if path.name in ALLOW_ROOT_OVERWRITE and dst.is_file():
                dst.unlink()
            else:
                fail(f"refusing to overwrite existing {dst.name} at repo root")
        shutil.move(str(path), str(dst))
    CORE.rmdir()
    print(f"  promoted _core/ → repo root ({sum(1 for _ in REPO_ROOT.iterdir())} entries)")


def promote_overlay(key: str) -> None:
    overlay_dir = OVERLAYS_ROOT / key
    if not overlay_dir.is_dir():
        fail(f"overlay '{key}' selected but {overlay_dir} not found")
    for path in sorted(overlay_dir.iterdir()):
        if path.name == "_README.md":
            # The per-overlay _README.md is template-state metadata, not part
            # of the derived repo. Drop it.
            path.unlink()
            continue
        dst = REPO_ROOT / path.name
        if dst.exists() and path.is_dir() and dst.is_dir():
            # Merge .tooling/ etc. directories (rare; only python today).
            _merge_dir(path, dst)
            shutil.rmtree(path)
        elif dst.exists():
            fail(f"refusing to overwrite existing {dst.name} at repo root (overlay={key})")
        else:
            shutil.move(str(path), str(dst))
    overlay_dir.rmdir()
    print(f"  promoted _overlays/{key}/ → repo root")


def _merge_dir(src: Path, dst: Path) -> None:
    for entry in src.iterdir():
        target = dst / entry.name
        if entry.is_dir():
            target.mkdir(exist_ok=True)
            _merge_dir(entry, target)
            entry.rmdir()
        else:
            if target.exists():
                fail(f"merge conflict at {target}")
            shutil.move(str(entry), str(target))


def cleanup_unselected_overlays(selected: Sequence[str]) -> None:
    for path in sorted(OVERLAYS_ROOT.iterdir()):
        if path.name == "_README.md":
            path.unlink()
            continue
        if path.is_dir() and path.name not in selected:
            shutil.rmtree(path)
            print(f"  removed unselected overlay _overlays/{path.name}/")
    if OVERLAYS_ROOT.is_dir() and not any(OVERLAYS_ROOT.iterdir()):
        OVERLAYS_ROOT.rmdir()


def patch_root_taskfile(selected: Sequence[str]) -> None:
    """
    Replace the includes section of root Taskfile.yml so only chosen overlays
    are wired in. Builds a fresh block; preserves the rest of the file.
    """
    taskfile = REPO_ROOT / "Taskfile.yml"
    if not taskfile.exists():
        fail("Taskfile.yml not at repo root after core promotion")
    text = taskfile.read_text()

    overlay_meta = {k: (tf, pfx) for k, tf, pfx, *_ in OVERLAY_REGISTRY}
    include_lines = ["includes:"]
    if not selected:
        include_lines.append("  # No language overlay selected at init time.")
    for key in selected:
        tf, pfx = overlay_meta[key]
        include_lines.append(f"  {pfx}:")
        include_lines.append(f"    taskfile: ./{tf}")
        include_lines.append("    optional: true")
    new_block = "\n".join(include_lines)

    # Replace the existing includes block (= "includes:" ... up to next
    # top-level key like "tasks:").
    pattern = re.compile(r"^includes:\n(?:.*\n)*?(?=^[A-Za-z])", re.MULTILINE)
    if pattern.search(text):
        text = pattern.sub(new_block + "\n\n", text, count=1)
    else:
        # No existing includes block; insert before `tasks:`.
        text = re.sub(r"^tasks:", new_block + "\n\ntasks:", text, count=1, flags=re.MULTILINE)
    taskfile.write_text(text)
    print(f"  rewrote Taskfile.yml includes for overlays: {', '.join(selected) or '(none)'}")


def patch_bump_targets(selected: Sequence[str]) -> None:
    """
    Replace the existing python-only `targets:` block in bump-targets.yaml
    with entries for the chosen overlays.
    """
    bt = REPO_ROOT / ".tooling" / "bump-targets.yaml"
    if not bt.exists():
        return
    snippets = {k: snip for k, _, _, snip, _ in OVERLAY_REGISTRY}
    new_targets = "targets:\n" + "".join(snippets[k] for k in selected) if selected else "targets: []\n"
    text = bt.read_text()
    text = re.sub(r"^targets:\n(?:.*\n)*", new_targets, text, count=1, flags=re.MULTILINE)
    bt.write_text(text)
    print(f"  rewrote bump-targets.yaml targets for overlays: {', '.join(selected) or '(none)'}")


def cleanup_template_only_files() -> None:
    # docs/internals/template-usage.md is template-state guidance, not for
    # the derived repo.
    p = REPO_ROOT / "docs" / "internals" / "template-usage.md"
    if p.exists():
        p.unlink()
        print(f"  removed template-only doc {p.relative_to(REPO_ROOT)}")


def main() -> int:
    confirm_layout()

    env_overlays = os.environ.get("OVERLAYS", "").strip()
    if env_overlays:
        selected = pick_overlays_from_env(env_overlays)
        print(f"non-interactive: OVERLAYS={env_overlays} -> {selected}")
    else:
        selected = pick_overlays_interactive()

    if not selected:
        print("\nNo overlays selected; promoting _core/ only.")
        if input("Proceed? (y/N) ").strip().lower() not in ("y", "yes"):
            print("aborted")
            return 1
    else:
        print(f"\nSelected overlays: {', '.join(selected)}")

    print("\n==> Promoting _core/ contents to repo root")
    promote_core()

    for key in selected:
        print(f"==> Promoting _overlays/{key}/ contents to repo root")
        promote_overlay(key)

    print("==> Cleaning up unselected overlays")
    cleanup_unselected_overlays(selected)

    print("==> Patching root Taskfile.yml includes")
    patch_root_taskfile(selected)

    print("==> Patching bump-targets.yaml")
    patch_bump_targets(selected)

    print("==> Removing template-only files")
    cleanup_template_only_files()

    print()
    print("==> Template scaffolding promoted. Next steps:")
    if "python" in selected:
        print("    1. pip install -r setup-requirements.txt")
        print("    2. python personalize.py")
    else:
        print("    1. python3 personalize.py  (= no python deps yet; install setup-requirements.txt first if missing)")
    print("    3. task doctor   (= preflight)")
    print("    4. task setup    (= install language deps for selected overlays)")
    print("    5. task init:github  (= optional: apply post-template GitHub settings)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

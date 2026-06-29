# -*- mode: python ; coding: utf-8 -*-
"""PyInstaller spec file for building standalone executables.

The output executable name is derived from the package directory name
(``src/<package>/`` → ``<package-with-dashes>``).

Usage:
    pyinstaller pyinstaller.spec

The output will be in ``dist/<exe-name>/``.
"""

from pathlib import Path

from PyInstaller.utils.hooks import collect_submodules

project_root = Path(SPECPATH)


def find_package_name():
    """Find the package name by looking for directories with version.py.

    Supports both src layout (``src/<package>/``) and flat layout (``<package>/``).
    """
    src_dir = project_root / "src"
    if src_dir.exists():
        for pkg_dir in src_dir.iterdir():
            if pkg_dir.is_dir() and (pkg_dir / "version.py").exists():
                return pkg_dir.name, src_dir, pkg_dir

    skip = {"tests", "docs", "examples", "configs", "data", "scripts",
            ".git", ".venv", "venv", "build", "dist"}
    for pkg_dir in project_root.iterdir():
        if pkg_dir.is_dir() and (pkg_dir / "version.py").exists():
            if pkg_dir.name not in skip:
                return pkg_dir.name, project_root, pkg_dir

    raise FileNotFoundError("Could not find package directory with version.py")


def find_cli_entry(package_path: Path) -> Path:
    """Pick a CLI entry point under ``<package>/cli/``.

    Preference order: ``*_cli.py`` → any non-init ``*.py``.
    """
    cli_dir = package_path / "cli"
    if not cli_dir.exists():
        raise FileNotFoundError(f"CLI directory not found: {cli_dir}")

    candidates = list(cli_dir.glob("*_cli.py"))
    if not candidates:
        candidates = [f for f in cli_dir.glob("*.py") if f.name != "__init__.py"]

    if not candidates:
        raise FileNotFoundError(f"Could not find CLI entry point in {cli_dir}")

    return candidates[0]


package_name, package_dir, package_path = find_package_name()
cli_entry = find_cli_entry(package_path)
exe_name = package_name.replace("_", "-")

print(f"Package name: {package_name}")
print(f"Package directory: {package_dir}")
print(f"CLI entry point: {cli_entry}")
print(f"Output executable name: {exe_name}")

hiddenimports = collect_submodules(package_name)

a = Analysis(
    [str(cli_entry)],
    pathex=[str(package_dir)],
    binaries=[],
    datas=[],
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name=exe_name,
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name=exe_name,
)

# =============================================================================
# Build executable using PyInstaller (Windows)
# =============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir\..\..\..\..").FullName

Set-Location $ProjectRoot

# Determine Python executable
if (Test-Path ".venv\Scripts\python.exe") {
    $Python = ".venv\Scripts\python.exe"
    $Pip = ".venv\Scripts\pip.exe"
} else {
    $Python = "python"
    $Pip = "pip"
}

# Check if PyInstaller is installed
try {
    & $Python -c "import PyInstaller" 2>$null
} catch {
    Write-Host "Installing PyInstaller..."
    & $Pip install -e ".[pyinstaller]"
}

# Use fixed spec file name (does not depend on package name)
$SpecFile = "pyinstaller.spec"

if (-not (Test-Path $SpecFile)) {
    Write-Error "Error: Spec file '$SpecFile' not found!"
    exit 1
}

Write-Host "Building executable with PyInstaller..."
& $Python -m PyInstaller $SpecFile --clean --noconfirm

Write-Host ""
Write-Host "Build complete! Executable is in the dist\ directory."

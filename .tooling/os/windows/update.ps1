# =============================================================================
# Local Dev Platform - Windows Update Script
# =============================================================================
# This script updates Python and Node.js dependencies.
# No admin rights required - assumes .venv already exists.
# =============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir\..\..\..\..").FullName

Set-Location $ProjectRoot

Write-Host "=== Local Dev Platform: Update (Windows) ==="

# Check if .venv exists
$VenvDir = Join-Path $ProjectRoot ".venv"
if (-not (Test-Path $VenvDir)) {
    Write-Host "Error: Virtual environment not found at $VenvDir"
    Write-Host "Please run 'task setup' first."
    exit 1
}

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"

# Upgrade pip
Write-Host "Upgrading pip..."
& $VenvPython -m pip install --upgrade pip

# Update Python dependencies
Write-Host "Updating Python dependencies..."
& $VenvPython -m pip install --upgrade -e ".[dev,sample,api,cli]"

# Update Node.js dependencies (if package.json exists)
if (Test-Path "package.json") {
    Write-Host "Updating Node.js dependencies..."
    npm update
}

Write-Host ""
Write-Host "=== Update complete! ==="

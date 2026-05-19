# =============================================================================
# Local Dev Platform - Windows Setup Script
# =============================================================================
# This script sets up the development environment on Windows.
# Admin rights allowed here for OS-level tool installation (winget/choco).
# =============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir\..\..\..\..").FullName

Set-Location $ProjectRoot

Write-Host "=== Local Dev Platform: Setup (Windows) ===" -ForegroundColor Cyan
Write-Host "Project root: $ProjectRoot"

# Check Python version
$PythonVersion = python --version 2>&1
Write-Host "Python version: $PythonVersion"

# Check if go-task is installed
$taskInstalled = Get-Command task -ErrorAction SilentlyContinue
if (-not $taskInstalled) {
    Write-Host "Warning: go-task is not installed." -ForegroundColor Yellow
    Write-Host "Please install it with: npm install -g @go-task/cli" -ForegroundColor Yellow
    Write-Host "Or visit: https://taskfile.dev/installation/" -ForegroundColor Yellow
}

# Create virtual environment if it doesn't exist
$VenvDir = Join-Path $ProjectRoot ".venv"
if (-not (Test-Path $VenvDir)) {
    Write-Host "Creating virtual environment..."
    python -m venv $VenvDir
} else {
    Write-Host "Virtual environment already exists: $VenvDir"
}

# Upgrade pip (using venv python directly, no activation)
Write-Host "Upgrading pip..."
$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
& $VenvPython -m pip install --upgrade pip

# Install dependencies
Write-Host "Installing development dependencies..."
& $VenvPython -m pip install -e ".[dev,sample,api,cli]"

# Configure git hooks
Write-Host "Configuring git hooks..."
git config --local core.hooksPath .githooks

Write-Host ""
Write-Host "=== Setup complete! ===" -ForegroundColor Green
Write-Host "To activate the virtual environment manually, run:"
Write-Host "  $VenvDir\Scripts\Activate.ps1"
Write-Host ""
Write-Host "Available task commands:"
Write-Host "  task --list"

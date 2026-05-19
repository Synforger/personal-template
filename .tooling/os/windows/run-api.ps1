# =============================================================================
# Local Dev Platform - Windows API Server Script
# =============================================================================
# This script starts the API server on Windows.
# No admin rights allowed.
# =============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir\..\..\..\..").FullName

Set-Location $ProjectRoot

Write-Host "=== Local Dev Platform: Run API (Windows) ===" -ForegroundColor Cyan

# Check if .venv exists
$VenvDir = Join-Path $ProjectRoot ".venv"
if (-not (Test-Path $VenvDir)) {
    Write-Host "Error: Virtual environment not found at $VenvDir" -ForegroundColor Red
    Write-Host "Please run 'task setup' first." -ForegroundColor Red
    exit 1
}

# Start API server (FastAPI with uvicorn)
Write-Host "Starting API server..."
Write-Host "Access at: http://127.0.0.1:8000"
Write-Host "API docs at: http://127.0.0.1:8000/docs"

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
$env:PYTHONPATH = "$ProjectRoot\src"
& $VenvPython -m uvicorn my_package.api.app:app --reload --host 0.0.0.0 --port 8000

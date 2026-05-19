# =============================================================================
# Local Dev Platform - Windows Web/Frontend Script
# =============================================================================
# This script starts the frontend/web server on Windows.
# For this template, it starts the Sphinx documentation preview server.
# No admin rights allowed.
# =============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir\..\..\..\..").FullName

Set-Location $ProjectRoot

Write-Host "=== Local Dev Platform: Run Web (Windows) ===" -ForegroundColor Cyan

# Check if .venv exists
$VenvDir = Join-Path $ProjectRoot ".venv"
if (-not (Test-Path $VenvDir)) {
    Write-Host "Error: Virtual environment not found at $VenvDir" -ForegroundColor Red
    Write-Host "Please run 'task setup' first." -ForegroundColor Red
    exit 1
}

# Start documentation preview server
Write-Host "Starting documentation preview server..."
Write-Host "Access at: http://127.0.0.1:8000"

Remove-Item -Recurse -Force "docs\build" -ErrorAction SilentlyContinue

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
& $VenvPython -m sphinx -apidoc -f -o .\docs\source .\src\my_package
& $VenvPython -m sphinx_autobuild -b html --watch src\my_package\ docs\source\ docs\build\

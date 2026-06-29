# =============================================================================
# Local Dev Platform - Windows Integration Test Script
# =============================================================================
# This script runs integration tests.
# Common entry point for CI/human/AI.
# No admin rights allowed.
# =============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir\..\..\..\..").FullName

Set-Location $ProjectRoot

Write-Host "=== Local Dev Platform: Integration Test (Windows) ==="

# Check if .venv exists
$VenvDir = Join-Path $ProjectRoot ".venv"
if (-not (Test-Path $VenvDir)) {
    Write-Host "Error: Virtual environment not found at $VenvDir"
    Write-Host "Please run 'task setup' first."
    exit 1
}

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"

# Run integration tests
Write-Host "Running integration tests..."
if (Test-Path "tests/integration") {
    if (Test-Path "src/my_package") {
        $env:PYTHONPATH = "$ProjectRoot\src"
        & $VenvPython -m pytest tests/integration -v
    } else {
        & $VenvPython -m pytest tests/integration -v
    }
} else {
    Write-Host "No integration tests found in tests/integration/"
    Write-Host "Skipping integration tests."
}

Write-Host ""
Write-Host "=== Integration Test complete! ==="

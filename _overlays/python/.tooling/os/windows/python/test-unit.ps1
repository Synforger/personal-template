# =============================================================================
# Local Dev Platform - Windows Unit Test Script
# =============================================================================
# This script runs unit tests.
# Common entry point for CI/human/AI.
# No admin rights allowed.
# =============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir\..\..\..\..").FullName

Set-Location $ProjectRoot

Write-Host "=== Local Dev Platform: Unit Test (Windows) ==="

# Check if .venv exists
$VenvDir = Join-Path $ProjectRoot ".venv"
if (-not (Test-Path $VenvDir)) {
    Write-Host "Error: Virtual environment not found at $VenvDir"
    Write-Host "Please run 'task setup' first."
    exit 1
}

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"

# Run pytest
Write-Host "Running pytest..."
if (Test-Path "src/my_package") {
    $env:PYTHONPATH = "$ProjectRoot\src"
    & $VenvPython -m pytest tests --doctest-modules src/my_package
} else {
    & $VenvPython -m pytest tests --doctest-modules --pyargs my_package
}

Write-Host ""
Write-Host "=== Unit Test complete! ==="

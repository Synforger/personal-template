# =============================================================================
# Local Dev Platform - Windows Lint Script
# =============================================================================
# This script runs lint and autoformat checks.
# For AI/CI use. Humans typically use editor auto-formatting.
# No admin rights allowed.
# =============================================================================

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item "$ScriptDir\..\..\..\..").FullName

Set-Location $ProjectRoot

Write-Host "=== Local Dev Platform: Lint (Windows) ==="

# Check if .venv exists
$VenvDir = Join-Path $ProjectRoot ".venv"
if (-not (Test-Path $VenvDir)) {
    Write-Host "Error: Virtual environment not found at $VenvDir"
    Write-Host "Please run 'task setup' first."
    exit 1
}

$VenvBlack = Join-Path $VenvDir "Scripts\black.exe"
$VenvFlake8 = Join-Path $VenvDir "Scripts\flake8.exe"

# Run black autoformat
Write-Host "Running black..."
& $VenvBlack .

# Run flake8 lint
Write-Host "Running flake8..."
& $VenvFlake8 . --jobs 1 --count --select=E9,F63,F7,F82 --show-source --max-complexity=10 --statistics

# Run anonymity scan (replaces the disabled anon-check GitHub Action in
# this template variant). The scanner is a bash script under
# .tooling/local-ci/anon-scan.sh; invoke it via Git Bash when
# available, otherwise warn loudly so derived projects can backfill a
# PowerShell port if Windows is a primary dev environment.
Write-Host "Running anonymity scan..."
$BashExe = $null
foreach ($candidate in @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe",
    "C:\Windows\System32\bash.exe"
)) {
    if (Test-Path $candidate) {
        $BashExe = $candidate
        break
    }
}
if ($null -ne $BashExe) {
    & $BashExe "$ProjectRoot/.tooling/local-ci/anon-scan.sh"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
} else {
    Write-Host "warning: bash not found; anonymity scan skipped on this host."
    Write-Host "         Install Git for Windows or run the scan from WSL."
}

Write-Host ""
Write-Host "=== Lint complete! ==="

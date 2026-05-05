# download-rcc.ps1 — Downloads the RCC binary for Windows into _dev\.rcc\.
# RCC binaries are NOT committed to git (see .gitignore).
# Run this once after cloning the repo before running tests locally.
#
# Usage:
#   .\_dev\scripts\download-rcc.ps1
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RccDir    = Resolve-Path (Join-Path $ScriptDir "..\.rcc") -ErrorAction SilentlyContinue
if (-not $RccDir) { $RccDir = Join-Path $ScriptDir "..\.rcc" }
New-Item -ItemType Directory -Force -Path $RccDir | Out-Null

$Dest = Join-Path $RccDir "rcc.exe"
$Url  = "https://github.com/elabit/robotmk/releases/download/v4.0.0/rcc_windows64.exe"

Write-Host "→ Downloading RCC for Windows ..."
Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing
Write-Host "  ✓ Saved to: $Dest"
& $Dest --version

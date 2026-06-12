# generate-all.ps1 — Regenerates examples\ and templates\ from _dev\_examples\ and _dev\_templates\.
# Each source's template\.env must contain RMKS_ENVIRONMENT=<env-name> and
# RMKS_DEVCONTAINER=<type>. These replace the former .rcc and .devcontainer-type
# files and drive environment and devcontainer injection via Copier.
#
# Usage:
#   .\_dev\scripts\generate-all.ps1
#   .\_dev\scripts\generate-all.ps1 -Filter cryptolibrary   # single name only

param(
    [string]$Filter = ""
)

$ErrorActionPreference = "Stop"

$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot     = Resolve-Path (Join-Path $ScriptDir "..\..") | Select-Object -ExpandProperty Path
$ExamplesSrc  = Join-Path $RepoRoot "_dev\_examples"
$TemplatesSrc = Join-Path $RepoRoot "_dev\_templates"
$Environments = Join-Path $RepoRoot "_dev\_environments"
$ExamplesOut  = Join-Path $RepoRoot "examples"
$TemplatesOut = Join-Path $RepoRoot "templates"
$SharedDir    = Join-Path $RepoRoot "_dev\_shared"

# ─── Version pins (read from _dev/config/versions.env) ───────────────────────
$VersionsFile = Join-Path $RepoRoot "_dev\config\versions.env"
if (-not (Test-Path $VersionsFile)) {
    throw "versions.env not found at $VersionsFile"
}
Get-Content $VersionsFile | Where-Object { $_ -match '^\s*[^#]\S+=\S+' } | ForEach-Object {
    $parts = $_ -split '=', 2
    Set-Variable -Name $parts[0].Trim() -Value $parts[1].Trim()
}
# ──────────────────────────────────────────────────────────────────────────────

# Resolve Python executable (prefer venv, fall back to PATH)
$PythonExe = Join-Path $RepoRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $PythonExe)) {
    $PythonExe = (Get-Command python3 -ErrorAction SilentlyContinue)?.Source
    if (-not $PythonExe) {
        $PythonExe = (Get-Command python -ErrorAction SilentlyContinue)?.Source
    }
    if (-not $PythonExe) { throw "python not found — required for populate step" }
}

$CommonData = @(
    "--data", "rf_version=$RF_VERSION",
    "--data", "rf_lib_browser_version=$RF_LIB_BROWSER_VERSION",
    "--data", "rf_lib_crypto_version=$RF_LIB_CRYPTO_VERSION",
    "--data", "python_version=$PYTHON_VERSION",
    "--data", "pip_version=$PIP_VERSION",
    "--data", "nodejs_version=$NODEJS_VERSION"
)

function Invoke-EnvInject {
    param([string]$Src)
    $envFile = Join-Path $Src "template\.env"
    if (-not (Test-Path $envFile)) { return }
    $space = (Get-Content $envFile | Where-Object { $_ -match '^RMKS_ENVIRONMENT=' }) -replace '^RMKS_ENVIRONMENT=', '' | ForEach-Object { $_.Trim() }
    if ([string]::IsNullOrEmpty($space)) { return }
    $envSrc = Join-Path $Environments $space
    if (-not (Test-Path $envSrc)) { throw "Environment '$space' not found in _dev\_environments\" }
    $envDst = Join-Path $Src "template"
    Write-Host "  ↳ Injecting environment '$space' ..."
    & copier copy --overwrite --defaults @CommonData $envSrc $envDst
    if ($LASTEXITCODE -ne 0) { throw "copier env inject failed for $space" }
    $answersFile = Join-Path $envDst ".copier-env-answers.yml"
    if (Test-Path $answersFile) { Remove-Item $answersFile }
}

function Generate-Item {
    param([string]$Name, [string]$SrcBase, [string]$DstBase, [string]$Label)
    $src = Join-Path $SrcBase $Name
    Write-Host "→ ${Label}\$Name"

    # Inject shared README template if the example has a partial
    $sharedReadme = Join-Path $SharedDir "README.md.jinja"
    $partial = Join-Path $src "README.partial.md"
    if ((Test-Path $sharedReadme) -and (Test-Path $partial)) {
        Write-Host "  ↳ Injecting shared README.md.jinja ..."
        Copy-Item $sharedReadme (Join-Path $src "README.md.jinja")
    }

    Invoke-EnvInject -Src $src
    & copier copy --overwrite --defaults @CommonData $src (Join-Path $DstBase $Name)
    if ($LASTEXITCODE -ne 0) { throw "copier failed for $Name" }

    # Post-copier populate: copy additional files/dirs defined in populate.yaml
    $populateFile = Join-Path $src "populate.yaml"
    if (Test-Path $populateFile) {
        Write-Host "  ↳ Running populate.yaml ..."
        & $PythonExe (Join-Path $RepoRoot "_dev\scripts\populate.py") $populateFile $RepoRoot (Join-Path $DstBase $Name)
        if ($LASTEXITCODE -ne 0) { throw "populate failed for $Name" }
    }

    # Remove the injected shared README template from the source tree
    Remove-Item -Path (Join-Path $src "template\README.md.jinja") -ErrorAction SilentlyContinue

    Write-Host "  ✓ Done"
}

Write-Host "=== examples\ (full working examples) ==="
Get-ChildItem -Path $ExamplesSrc -Directory | ForEach-Object {
    $name = $_.Name
    if ([string]::IsNullOrEmpty($Filter) -or $name -eq $Filter) {
        Generate-Item -Name $name -SrcBase $ExamplesSrc -DstBase $ExamplesOut -Label "examples"
    }
}

Write-Host ""
Write-Host "=== templates\ (minimal skeletons) ==="
Get-ChildItem -Path $TemplatesSrc -Directory | ForEach-Object {
    $name = $_.Name
    if ([string]::IsNullOrEmpty($Filter) -or $name -eq $Filter) {
        Generate-Item -Name $name -SrcBase $TemplatesSrc -DstBase $TemplatesOut -Label "templates"
    }
}

Write-Host ""
Write-Host "=== labs\ (Checkmk practice labs) ==="
$LabsSrc = Join-Path $RepoRoot "_dev\_labs"
$LabsOut = Join-Path $RepoRoot "labs"
if (Test-Path $LabsSrc) {
    Get-ChildItem -Path $LabsSrc -Directory | ForEach-Object {
        $name = $_.Name
        if ([string]::IsNullOrEmpty($Filter) -or $name -eq $Filter) {
            Generate-Item -Name $name -SrcBase $LabsSrc -DstBase $LabsOut -Label "labs"
        }
    }
}

Write-Host ""
Write-Host "All done."

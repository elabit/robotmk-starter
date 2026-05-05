# generate-all.ps1 — Regenerates examples\ and templates\ from _dev\_examples\ and _dev\_templates\.
# Each source directory may contain a .rcc file with SPACE=<env-name>.
# If present, the matching environment from _dev\_environments\<env-name>\ is injected
# (via Copier) into the template\ subfolder before the main generation step.
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
    $rccFile = Join-Path $Src ".rcc"
    if (-not (Test-Path $rccFile)) { return }
    $space = (Get-Content $rccFile | Where-Object { $_ -match '^SPACE=' }) -replace '^SPACE=', '' | ForEach-Object { $_.Trim() }
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
    Invoke-EnvInject -Src $src
    & copier copy --overwrite --defaults @CommonData $src (Join-Path $DstBase $Name)
    if ($LASTEXITCODE -ne 0) { throw "copier failed for $Name" }
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
Write-Host "All done."
Write-Host "=== templates\ (minimal skeletons) ==="
Get-ChildItem -Path $SkeletonsDir -Directory | ForEach-Object {
    $name = $_.Name
    if ([string]::IsNullOrEmpty($Filter) -or $name -eq $Filter) {
        Generate-Item -Name $name -SrcBase $SkeletonsDir -DstBase $TemplOutDir -Label "templates"
    }
}

Write-Host ""
Write-Host "All done."

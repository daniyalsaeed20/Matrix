#Requires -Version 5.1
<#
.SYNOPSIS
  Measure always-on project rules (00-05) UTF-8 disk bytes and compare to T1 baseline ceiling.

.DESCRIPTION
  CTX-001: always-on growth <= T1 baseline + 25% without DECISIONS exception.
  Frozen baseline: _pilot/v2_baseline/ALWAYS_ON_BYTES.json → totals.alwaysOnCoreBytes (default 11043).
  Stack rules (stack-*.mdc) are measured separately and are not the CTX-001 numerator.

.PARAMETER RulesDir
  Directory containing 00-*.mdc … 05-*.mdc. Defaults to constitution/project-rules under kit root.

.PARAMETER BaselinePath
  Frozen T1 ALWAYS_ON_BYTES.json. Defaults to _pilot/v2_baseline/ALWAYS_ON_BYTES.json.

.PARAMETER OutputPath
  Optional path to write the live measurement JSON (does not overwrite the frozen baseline).

.PARAMETER FailAboveCeiling
  Exit 1 when alwaysOnCoreBytes exceeds budgetCeilingPlus25Core.
#>
param(
  [string]$RulesDir = "",
  [string]$BaselinePath = "",
  [string]$OutputPath = "",
  [switch]$FailAboveCeiling
)

$ErrorActionPreference = "Stop"
$KitRoot = Split-Path -Parent $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($RulesDir)) {
  $RulesDir = Join-Path $KitRoot "constitution\project-rules"
}
if ([string]::IsNullOrWhiteSpace($BaselinePath)) {
  $BaselinePath = Join-Path $KitRoot "_pilot\v2_baseline\ALWAYS_ON_BYTES.json"
}

if (-not (Test-Path -LiteralPath $RulesDir)) {
  throw "RulesDir not found: $RulesDir"
}

$baselineCore = 11043
$baselineCeiling = 13804
if (Test-Path -LiteralPath $BaselinePath) {
  $baselineDoc = Get-Content -LiteralPath $BaselinePath -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($null -ne $baselineDoc.totals.alwaysOnCoreBytes) {
    $baselineCore = [int]$baselineDoc.totals.alwaysOnCoreBytes
  }
  if ($null -ne $baselineDoc.totals.budgetCeilingPlus25Core) {
    $baselineCeiling = [int]$baselineDoc.totals.budgetCeilingPlus25Core
  }
  else {
    $baselineCeiling = [int][Math]::Ceiling($baselineCore * 1.25)
  }
}

$coreFiles = @()
$stackFiles = @()
Get-ChildItem -LiteralPath $RulesDir -File -Filter "*.mdc" | Sort-Object Name | ForEach-Object {
  $entry = [ordered]@{
    file  = $_.Name
    bytes = [int]$_.Length
  }
  if ($_.Name -match '^0[0-5]-') {
    $coreFiles += $entry
  }
  elseif ($_.Name -like "stack-*") {
    $stackFiles += $entry
  }
}

$coreSum = 0
foreach ($f in $coreFiles) { $coreSum += $f.bytes }
$stackSum = 0
foreach ($f in $stackFiles) { $stackSum += $f.bytes }

$withinBudget = ($coreSum -le $baselineCeiling)

$result = [ordered]@{
  measuredAt   = (Get-Date).ToUniversalTime().ToString("o")
  kitRoot      = $KitRoot
  rulesDir     = $RulesDir
  baselinePath = $BaselinePath
  files        = @($coreFiles + $stackFiles)
  totals       = [ordered]@{
    alwaysOnCoreBytes         = $coreSum
    stackRulesBytes           = $stackSum
    allProjectRulesBytes      = ($coreSum + $stackSum)
    frozenBaselineCoreBytes   = $baselineCore
    budgetCeilingPlus25Core   = $baselineCeiling
    withinBudget              = $withinBudget
    headroomBytes             = ($baselineCeiling - $coreSum)
  }
  note = "CTX-001 numerator is alwaysOnCoreBytes (00-05). Frozen baseline is T1 ALWAYS_ON_BYTES.json; this script never overwrites it."
}

$json = ($result | ConvertTo-Json -Depth 6)
Write-Host $json

if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
  $dir = Split-Path -Parent $OutputPath
  if (-not [string]::IsNullOrWhiteSpace($dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
  Set-Content -LiteralPath $OutputPath -Value $json -Encoding UTF8
  Write-Host "Wrote: $OutputPath"
}

Write-Host ("ALWAYS_ON_CORE={0} CEILING={1} WITHIN_BUDGET={2}" -f $coreSum, $baselineCeiling, $withinBudget)

if ($FailAboveCeiling -and -not $withinBudget) {
  exit 1
}
exit 0

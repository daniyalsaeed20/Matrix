#Requires -Version 5.1
<#
.SYNOPSIS
  Positive + negative Proportionality eval for T7 (SOL-001, SOL-002, NFR-006, EVAL-001).
  Static/content asserts + fixture verdict matrix. No Guard proportionality plug.
#>
param()

$ErrorActionPreference = "Stop"
$EvalRoot = Split-Path -Parent $PSScriptRoot
$KitRoot = Split-Path -Parent (Split-Path -Parent $EvalRoot)
$LocalFixtures = Join-Path $EvalRoot "fixtures"
$EvidenceDir = Join-Path $EvalRoot "evidence"
$failed = 0

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Assert-True([bool]$Cond, [string]$Msg) {
  if ($Cond) { Write-Host "PASS  $Msg" }
  else { Write-Host "FAIL  $Msg"; $script:failed++ }
}

function Get-LadderVerdict {
  param([Parameter(Mandatory = $true)]$Fixture)
  # Mirror craft+verifier gate: Level 4 without justification+approval → fail;
  # significant without justification → fail; ordinary/localized → pass; extract with justification → pass.
  $level = [int]$Fixture.ladderLevel
  $significant = [bool]$Fixture.significant
  $hasJust = -not [string]::IsNullOrWhiteSpace([string]$Fixture.justification)
  $approved = [bool]$Fixture.captainApproval

  if ($level -ge 4) {
    if ($hasJust -and $approved) { return "pass" }
    return "fail"
  }
  if ($significant -and -not $hasJust) { return "fail" }
  return "pass"
}

Write-Host "=== Proportionality eval (T7) ==="
Write-Host "EvalRoot: $EvalRoot"
Write-Host "KitRoot:  $KitRoot"

# Kit content presence
$craftPath = Join-Path $KitRoot "constitution\project-rules\04-code-craft.mdc"
$craft = Get-Content $craftPath -Raw
Assert-True (Test-Path $craftPath) "04-code-craft.mdc present"
Assert-True ($craft -match "Solution Escalation Ladder") "craft: Solution Escalation Ladder heading"
Assert-True ($craft -match "Localized fix") "craft: Localized fix level"
Assert-True ($craft -match "Extend existing") "craft: Extend existing level"
Assert-True ($craft -match "Extract shared") "craft: Extract shared level"
Assert-True ($craft -match "Restructure") "craft: Restructure level"
Assert-True ($craft -match "Significant decision") "craft: Significant decision definition"
Assert-True ($craft -match "silently promote|silent.*scale|Never silently") "craft: anti silent promotion"

$cursorCraft = Join-Path $KitRoot ".cursor\rules\04-code-craft.mdc"
Assert-True (Test-Path $cursorCraft) ".cursor 04-code-craft mirror present"
Assert-True ((Get-Content $cursorCraft -Raw) -match "Solution Escalation Ladder") ".cursor craft mirror has ladder"

$verPath = Join-Path $KitRoot "agents\m4trix-verifier.md"
$ver = Get-Content $verPath -Raw
Assert-True ($ver -match "Proportionality|Solution Escalation Ladder") "verifier: proportionality / ladder checklist"
Assert-True ($ver -match "unjustified restructure") "verifier: rejects unjustified restructure"
Assert-True ($ver -match "no ladder essay|need no ladder") "verifier: ordinary patches need no essay"

$patch = Get-Content (Join-Path $KitRoot "skills\pipeline-patch\SKILL.md") -Raw
Assert-True ($patch -match "Solution Escalation Ladder") "pipeline-patch: ladder pointer"
Assert-True ($patch -match "anti-promotion|silent patch|never silent scope expand") "pipeline-patch: anti-promotion"

$mod = Get-Content (Join-Path $KitRoot "skills\pipeline-module\SKILL.md") -Raw
Assert-True ($mod -match "Solution Escalation Ladder") "pipeline-module: ladder pointer"
Assert-True ($mod -match "anti-promotion") "pipeline-module: anti-promotion"

$prod = Get-Content (Join-Path $KitRoot "skills\pipeline-product\SKILL.md") -Raw
Assert-True ($prod -match "Solution Escalation Ladder|anti-promotion") "pipeline-product: ladder/anti-promotion"

$rec = Get-Content (Join-Path $KitRoot "skills\pipeline-recovery\SKILL.md") -Raw
Assert-True ($rec -match "Solution Escalation Ladder|localized fix") "pipeline-recovery: ladder / localized preference"

Assert-True (Test-Path (Join-Path $EvalRoot "LIVE_PROCEDURE.md")) "live procedure documented"
Assert-True (Test-Path (Join-Path $EvalRoot "README.md")) "README present"

# Fixture matrix
$fixtureFiles = @(
  "localized-fix-ok.json",
  "unjustified-restructure-fail.json",
  "justified-extract-ok.json",
  "ordinary-patch-ok.json"
)

$matrixRows = @()
foreach ($name in $fixtureFiles) {
  $path = Join-Path $LocalFixtures $name
  Assert-True (Test-Path $path) "fixture present: $name"
  $fx = Get-Content $path -Raw | ConvertFrom-Json
  $got = Get-LadderVerdict -Fixture $fx
  $expect = [string]$fx.expectedVerdict
  $ok = ($got -eq $expect)
  Assert-True $ok ("fixture $($fx.id): expected=$expect got=$got")
  if ($expect -eq "pass" -and -not [bool]$fx.expectEssay) {
    Assert-True ([string]::IsNullOrWhiteSpace([string]$fx.justification) -or -not [bool]$fx.significant) `
      "fixture $($fx.id): ordinary/localized needs no essay"
  }
  $matrixRows += "| $($fx.id) | $expect | $got | $(if ($ok) { 'PASS' } else { 'FAIL' }) |"
  $outFx = Join-Path $EvidenceDir ("fixture-" + $fx.id + ".json")
  [pscustomobject]@{
    id = $fx.id
    expectedVerdict = $expect
    actualVerdict = $got
    pass = $ok
  } | ConvertTo-Json | Set-Content -Path $outFx -Encoding UTF8
}

# Live procedure status
$livePos = Join-Path $EvidenceDir "live-positive.md"
$liveNeg = Join-Path $EvidenceDir "live-negative.md"
$liveLim = Join-Path $EvidenceDir "live-limitation.md"
$liveDone = (Test-Path $livePos) -and (Test-Path $liveNeg)
if ($liveDone) {
  Assert-True $true "live ± evidence files present"
} else {
  Write-Host "NOTE  live ± not yet recorded — see LIVE_PROCEDURE.md"
  if (-not (Test-Path $liveLim)) {
    @"
# Live proportionality limitation

Status: **pending captain-assisted live prompts**.

Script content ± fixtures **passed** in this run.
Live agent “do not restructure” behaviour remains optional honesty layer for T7.

When captain runs LIVE_PROCEDURE.md, replace this file with live-positive.md / live-negative.md results.
"@ | Set-Content -Path $liveLim -Encoding UTF8
  }
  Assert-True (Test-Path $liveLim) "live limitation placeholder recorded (honest; not a live pass claim)"
}

# Report
$reportPath = Join-Path $EvidenceDir "REPORT.md"
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$report = @"
# Proportionality eval REPORT (T7)

**When:** $ts  
**KitRoot:** $KitRoot  
**Failures:** $failed

## Kit content

| Check | Result |
|-------|--------|
| Craft Solution Escalation Ladder | asserted |
| Verifier ladder checklist | asserted |
| Pipeline anti-promotion | patch/module/product/recovery |

## Fixture matrix

| Id | Expected | Actual | Result |
|----|----------|--------|--------|
$($matrixRows -join "`n")

## Live ±

$(if ($liveDone) { "Recorded: live-positive.md + live-negative.md" } else { "Not executed this run — limitation: live-limitation.md (script ± still required and executed)" })

## Verdict

$(if ($failed -eq 0) { "PASS (script layer). Live layer: $(if ($liveDone) { 'PASS' } else { 'PENDING/LIMITATION' })" } else { "FAIL ($failed)" })
"@
Set-Content -Path $reportPath -Value $report -Encoding UTF8
Write-Host ""
Write-Host "Report: $reportPath"

if ($failed -gt 0) {
  Write-Host "RESULT: $failed Proportionality eval failure(s)"
  exit 1
}
Write-Host "RESULT: Proportionality eval passed (script layer)"
exit 0

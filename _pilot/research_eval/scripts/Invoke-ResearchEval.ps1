#Requires -Version 5.1
<#
.SYNOPSIS
  Positive + negative Research eval for T6 (RSH-001…004, EVAL-001).
#>
param()

$ErrorActionPreference = "Stop"
$EvalRoot = Split-Path -Parent $PSScriptRoot
$KitRoot = Split-Path -Parent (Split-Path -Parent $EvalRoot)
$GuardRunner = Join-Path $KitRoot "bootstrap\guard\Invoke-M4trixGuard.ps1"
$EvalRouting = Join-Path $KitRoot "bootstrap\guard\Evaluate-Routing.ps1"
$GuardFixtures = Join-Path $KitRoot "bootstrap\guard\tests\fixtures"
$LocalFixtures = Join-Path $EvalRoot "fixtures"
$EvidenceDir = Join-Path $EvalRoot "evidence"
$failed = 0

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Assert-True([bool]$Cond, [string]$Msg) {
  if ($Cond) { Write-Host "PASS  $Msg" }
  else { Write-Host "FAIL  $Msg"; $script:failed++ }
}

function Test-ContainsName($List, [string]$Name) {
  foreach ($x in @($List)) {
    if ([string]$x -eq $Name) { return $true }
  }
  return $false
}

function Invoke-Calculate {
  param([Parameter(Mandatory = $true)][string]$AttrsPath, [string]$OutName)
  $out = Join-Path $EvidenceDir $OutName
  & powershell -NoProfile -ExecutionPolicy Bypass -File $EvalRouting `
    -AttributesPath $AttrsPath -KitRoot $KitRoot -OutputPath $out 2>&1 | Out-Null
  $code = $LASTEXITCODE
  $obj = $null
  if (Test-Path $out) {
    try { $obj = Get-Content $out -Raw | ConvertFrom-Json } catch { $obj = $null }
  }
  return [pscustomobject]@{ ExitCode = $code; Result = $obj; OutPath = $out }
}

function Invoke-Guard {
  param(
    [Parameter(Mandatory = $true)][string]$TaskPath,
    [Parameter(Mandatory = $true)][string]$OutFile,
    [string]$Validators = "task-state,research"
  )
  $tmp = Join-Path $EvidenceDir ("guard-" + [guid]::NewGuid().ToString("n") + ".json")
  $stdout = & powershell -NoProfile -ExecutionPolicy Bypass -File $GuardRunner `
    -TaskPath $TaskPath -Validators $Validators -OutputPath $tmp 2>&1 | Out-String
  $code = $LASTEXITCODE
  if (Test-Path $tmp) {
    Copy-Item $tmp $OutFile -Force
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  } else {
    Set-Content -Path $OutFile -Value $stdout -Encoding UTF8
  }
  $obj = $null
  if (Test-Path $OutFile) {
    try { $obj = Get-Content $OutFile -Raw | ConvertFrom-Json } catch { $obj = $null }
  }
  return [pscustomobject]@{ ExitCode = $code; Result = $obj }
}

Write-Host "=== Research eval (T6) ==="
Write-Host "EvalRoot: $EvalRoot"
Write-Host "KitRoot:  $KitRoot"

Assert-True (Test-Path (Join-Path $KitRoot "skills\engineering-research\SKILL.md")) "engineering-research skill present"
Assert-True (Test-Path (Join-Path $KitRoot "bootstrap\guard\validators\research.ps1")) "research validator present"
Assert-True (Test-Path (Join-Path $KitRoot "bootstrap\guard\schema\research.schema.json")) "research schema present"
Assert-True (Test-Path (Join-Path $EvalRoot "LIVE_PROCEDURE.md")) "live procedure documented"
Assert-True (Test-Path (Join-Path $EvidenceDir "sample-findings.json")) "sample findings artifact present"

# Calculate: researchNeeded requires skill + validator
$c = Invoke-Calculate (Join-Path $LocalFixtures "attrs-research-needed.json") "calc-research-needed.json"
Assert-True ($c.ExitCode -eq 0 -and $null -ne $c.Result) "researchNeeded calculate exit 0"
Assert-True (Test-ContainsName $c.Result.requiredSkills "engineering-research") "calculate: engineering-research skill"
Assert-True (Test-ContainsName $c.Result.requiredValidators "research") "calculate: research validator"

# Guard positives
$r = Invoke-Guard (Join-Path $GuardFixtures "valid-research-required.json") (Join-Path $EvidenceDir "guard-required-ok.json")
Assert-True ($r.ExitCode -eq 0 -and $r.Result.ok -eq $true) "Guard valid required research ok=true"

$r = Invoke-Guard (Join-Path $GuardFixtures "valid-research-skip.json") (Join-Path $EvidenceDir "guard-skip-ok.json")
Assert-True ($r.ExitCode -eq 0 -and $r.Result.ok -eq $true) "Guard trivial skip ok=true"

$r = Invoke-Guard (Join-Path $LocalFixtures "task-recurring-patch-research.json") (Join-Path $EvidenceDir "guard-recurring-ok.json")
Assert-True ($r.ExitCode -eq 0 -and $r.Result.ok -eq $true) "Guard recurring patch research ok=true"

$r = Invoke-Guard (Join-Path $GuardFixtures "valid-research-web-unavailable.json") (Join-Path $EvidenceDir "guard-web-unavail-ok.json")
Assert-True ($r.ExitCode -eq 0 -and $r.Result.ok -eq $true) "Guard web-unavailable + local ok=true"

# Guard negatives
$r = Invoke-Guard (Join-Path $GuardFixtures "invalid-research-empty.json") (Join-Path $EvidenceDir "guard-empty-fail.json")
Assert-True ($r.ExitCode -ne 0 -and $r.Result.ok -eq $false) "Guard empty findings ok=false"

$r = Invoke-Guard (Join-Path $GuardFixtures "invalid-research-fabricated.json") (Join-Path $EvidenceDir "guard-fabricated-fail.json")
Assert-True ($r.ExitCode -ne 0 -and $r.Result.ok -eq $false) "Guard fabricated sources ok=false"

$r = Invoke-Guard (Join-Path $GuardFixtures "invalid-research-no-alternatives.json") (Join-Path $EvidenceDir "guard-rubberstamp-fail.json")
Assert-True ($r.ExitCode -ne 0 -and $r.Result.ok -eq $false) "Guard no-alternatives ok=false"

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
# Live research limitation

Status: **pending captain-assisted live prompts**.

Script Guard ± fixtures **passed** in this run.
Live agent research behaviour remains optional honesty layer for T6.

When captain runs LIVE_PROCEDURE.md, replace this file with live-positive.md / live-negative.md results.
"@ | Set-Content -Path $liveLim -Encoding UTF8
  }
  Assert-True (Test-Path $liveLim) "live limitation placeholder recorded (honest; not a live pass claim)"
}

# Report
$reportPath = Join-Path $EvidenceDir "REPORT.md"
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$report = @"
# Research eval REPORT (T6)

**When:** $ts  
**KitRoot:** $KitRoot  
**Failures:** $failed

## Script results

| Check | Result |
|-------|--------|
| researchNeeded calculate | see calc-research-needed.json |
| Valid required findings | see guard-required-ok.json |
| Trivial skip | see guard-skip-ok.json |
| Recurring patch research | see guard-recurring-ok.json |
| Web unavailable + local | see guard-web-unavail-ok.json |
| Empty / fabricated / rubber-stamp | fail fixtures under evidence/ |
| Sample findings | sample-findings.json |

## Live ±

$(if ($liveDone) { "Recorded: live-positive.md + live-negative.md" } else { "Not executed this run — limitation: live-limitation.md (script ± still required and executed)" })

## Verdict

$(if ($failed -eq 0) { "PASS (script layer). Live layer: $(if ($liveDone) { 'PASS' } else { 'PENDING/LIMITATION' })" } else { "FAIL ($failed)" })
"@
Set-Content -Path $reportPath -Value $report -Encoding UTF8
Write-Host ""
Write-Host "Report: $reportPath"

if ($failed -gt 0) {
  Write-Host "RESULT: $failed Research eval failure(s)"
  exit 1
}
Write-Host "RESULT: Research eval passed (script layer)"
exit 0

#Requires -Version 5.1
<#
.SYNOPSIS
  Positive + negative Routing eval for T5 (RTE-001…004, EVAL-001).
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
    [string]$Validators = "task-state,routing"
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

function Test-ContainsName($List, [string]$Name) {
  foreach ($x in @($List)) {
    if ([string]$x -eq $Name) { return $true }
  }
  return $false
}

function Test-DeferredName($Deferred, [string]$Name) {
  foreach ($d in @($Deferred)) {
    if ($null -eq $d) { continue }
    $n = $null
    if ($d.PSObject.Properties["name"]) { $n = [string]$d.name }
    if ($n -eq $Name) { return $true }
  }
  return $false
}

Write-Host "=== Routing eval (T5) ==="
Write-Host "EvalRoot: $EvalRoot"
Write-Host "KitRoot:  $KitRoot"

Assert-True (Test-Path $EvalRouting) "Evaluate-Routing.ps1 present"
Assert-True (Test-Path (Join-Path $KitRoot "templates\sdlc\routing-policy.json")) "routing-policy.json present"
Assert-True (Test-Path (Join-Path $KitRoot "bootstrap\guard\validators\routing.ps1")) "routing validator present"
Assert-True (Test-Path (Join-Path $EvalRoot "LIVE_PROCEDURE.md")) "live ± procedure documented"
Assert-True (Test-Path (Join-Path $EvalRoot "helpers\Record-RoutingEvidence.ps1")) "evidence helper present"

# --- Calculate: Flutter trivial patch ---
$c = Invoke-Calculate (Join-Path $LocalFixtures "attrs-flutter-trivial-patch.json") "calc-flutter-trivial.json"
Assert-True ($c.ExitCode -eq 0 -and $null -ne $c.Result) "trivial patch calculate exit 0"
Assert-True ($c.Result.trivialPatch -eq $true) "trivial patch flagged trivialPatch=true"
Assert-True (-not (Test-ContainsName $c.Result.mandatoryAgents "m4trix-security")) "trivial: security not mandatory"
Assert-True (-not (Test-ContainsName $c.Result.mandatoryAgents "m4trix-ui-designer")) "trivial: ui-designer not mandatory"
Assert-True (Test-ContainsName $c.Result.requiredSkills "pipeline-patch") "trivial: pipeline-patch skill"

# --- Calculate: Significant UI (ui-designer present post-T8) ---
$c = Invoke-Calculate (Join-Path $LocalFixtures "attrs-significant-ui.json") "calc-significant-ui.json"
Assert-True ($c.ExitCode -eq 0 -and $null -ne $c.Result) "significant UI calculate exit 0"
Assert-True (-not (Test-DeferredName $c.Result.deferred "m4trix-ui-designer")) "significant UI: ui-designer not deferred (agent present)"
Assert-True (Test-ContainsName $c.Result.mandatoryAgents "m4trix-ui-designer") "significant UI: ui-designer mandatory"
Assert-True (Test-ContainsName $c.Result.mandatoryAgents "m4trix-design-system") "significant UI: design-system mandatory"
Assert-True (Test-Path (Join-Path $KitRoot "agents\m4trix-ui-designer.md")) "significant UI: agents/m4trix-ui-designer.md present"

# --- Calculate: Auth/security ---
$c = Invoke-Calculate (Join-Path $LocalFixtures "attrs-auth-security.json") "calc-auth-security.json"
Assert-True ($c.ExitCode -eq 0 -and $null -ne $c.Result) "auth/security calculate exit 0"
Assert-True (Test-ContainsName $c.Result.mandatoryAgents "m4trix-security") "auth: security mandatory"

# --- Calculate: Recovery ---
$c = Invoke-Calculate (Join-Path $LocalFixtures "attrs-recovery.json") "calc-recovery.json"
Assert-True ($c.ExitCode -eq 0 -and $null -ne $c.Result) "recovery calculate exit 0"
Assert-True (Test-ContainsName $c.Result.mandatoryAgents "m4trix-debugger") "recovery: debugger mandatory"
Assert-True (Test-ContainsName $c.Result.requiredSkills "pipeline-recovery") "recovery: pipeline-recovery skill"
Assert-True (Test-ContainsName $c.Result.requiredValidators "regression") "recovery: regression validator (regressionRisk)"

# --- Calculate: Mixed-stack ---
$c = Invoke-Calculate (Join-Path $LocalFixtures "attrs-mixed-stack.json") "calc-mixed-stack.json"
Assert-True ($c.ExitCode -eq 0 -and $null -ne $c.Result) "mixed-stack calculate exit 0"
Assert-True (Test-ContainsName $c.Result.conditionalAgents "m4trix-flutter") "mixed-stack: flutter conditional"
Assert-True (Test-ContainsName $c.Result.conditionalAgents "m4trix-node") "mixed-stack: node conditional"

# --- Calculate: researchNeeded → engineering-research present (T6+) ---
$c = Invoke-Calculate (Join-Path $LocalFixtures "attrs-research-needed.json") "calc-research-needed.json"
Assert-True ($c.ExitCode -eq 0 -and $null -ne $c.Result) "researchNeeded calculate exit 0"
Assert-True (-not (Test-DeferredName $c.Result.deferred "engineering-research")) "researchNeeded: engineering-research not deferred (skill present)"
Assert-True (Test-ContainsName $c.Result.requiredSkills "engineering-research") "researchNeeded: engineering-research required"
Assert-True (Test-ContainsName $c.Result.requiredValidators "research") "researchNeeded: research validator required"

# --- Guard positives (reuse Guard fixtures + local recovery) ---
$r = Invoke-Guard (Join-Path $GuardFixtures "valid-routing-security.json") (Join-Path $EvidenceDir "guard-security.json")
Assert-True ($r.ExitCode -eq 0 -and $r.Result.ok -eq $true) "Guard valid security ok=true"

$r = Invoke-Guard (Join-Path $GuardFixtures "valid-routing-ui-significant.json") (Join-Path $EvidenceDir "guard-ui-significant.json")
Assert-True ($r.ExitCode -eq 0 -and $r.Result.ok -eq $true) "Guard valid UI significant ok=true"

$r = Invoke-Guard (Join-Path $GuardFixtures "valid-routing-limitation-ack.json") (Join-Path $EvidenceDir "guard-limitation.json")
Assert-True ($r.ExitCode -eq 0 -and $r.Result.ok -eq $true) "Guard limitation+ack ok=true"

$r = Invoke-Guard (Join-Path $LocalFixtures "task-recovery-valid.json") (Join-Path $EvidenceDir "guard-recovery.json")
Assert-True ($r.ExitCode -eq 0 -and $r.Result.ok -eq $true) "Guard recovery routing ok=true"

# --- Guard negatives ---
$r = Invoke-Guard (Join-Path $GuardFixtures "invalid-routing-omit-mandatory.json") (Join-Path $EvidenceDir "guard-omit.json")
Assert-True ($r.ExitCode -ne 0 -and $r.Result.ok -eq $false) "Guard omit-mandatory ok=false"

$r = Invoke-Guard (Join-Path $GuardFixtures "invalid-routing-parent-impersonation.json") (Join-Path $EvidenceDir "guard-impersonation.json")
Assert-True ($r.ExitCode -ne 0 -and $r.Result.ok -eq $false) "Guard parent-impersonation ok=false"

# Live procedure status
$livePos = Join-Path $EvidenceDir "live-positive.md"
$liveNeg = Join-Path $EvidenceDir "live-negative.md"
$liveLim = Join-Path $EvidenceDir "live-limitation.md"
$liveDone = (Test-Path $livePos) -and (Test-Path $liveNeg)
if ($liveDone) {
  Assert-True $true "live ± evidence files present"
} else {
  Write-Host "NOTE  live ± not yet recorded — see LIVE_PROCEDURE.md (RTE-004)"
  # Write placeholder limitation for honesty if missing
  if (-not (Test-Path $liveLim)) {
    @"
# Live routing limitation

Status: **pending captain-assisted live prompts** (RTE-004).

Script calculate + Guard ± fixtures **passed** in this run.
Live Task/subagent identity remains subject to T1 HOOK_PROBE (subagentStart unverified_local).

When captain runs LIVE_PROCEDURE.md, replace this file with live-positive.md / live-negative.md results.
"@ | Set-Content -Path $liveLim -Encoding UTF8
  }
  Assert-True (Test-Path $liveLim) "live limitation placeholder recorded (honest; not a live pass claim)"
}

# Report
$reportPath = Join-Path $EvidenceDir "REPORT.md"
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$report = @"
# Routing eval REPORT (T5)

**When:** $ts  
**KitRoot:** $KitRoot  
**Failures:** $failed

## Script results

| Check | Result |
|-------|--------|
| Trivial Flutter patch calculate | see calc-flutter-trivial.json |
| Significant UI mandatory ui-designer | see calc-significant-ui.json |
| Auth/security mandatory | see calc-auth-security.json |
| Recovery debugger + skill | see calc-recovery.json |
| Mixed-stack conditionals | see calc-mixed-stack.json |
| Guard ± fixtures | security/ui/limitation/recovery / omit / impersonation |

## Live ± (RTE-004)

$(if ($liveDone) { "Recorded: live-positive.md + live-negative.md" } else { "Not executed this run — limitation: live-limitation.md (script ± still required and executed)" })

## Verdict

$(if ($failed -eq 0) { "PASS (script layer). Live layer: $(if ($liveDone) { 'PASS' } else { 'PENDING/LIMITATION' })" } else { "FAIL ($failed)" })
"@
Set-Content -Path $reportPath -Value $report -Encoding UTF8
Write-Host ""
Write-Host "Report: $reportPath"

if ($failed -gt 0) {
  Write-Host "RESULT: $failed Routing eval failure(s)"
  exit 1
}
Write-Host "RESULT: Routing eval passed (script layer)"
exit 0

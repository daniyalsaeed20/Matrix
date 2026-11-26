#Requires -Version 5.1
<#
.SYNOPSIS
  Positive + negative Recovery eval for T4 (REC-001…006, EVAL-001).
#>
param()

$ErrorActionPreference = "Stop"
$EvalRoot = Split-Path -Parent $PSScriptRoot
$KitRoot = Split-Path -Parent (Split-Path -Parent $EvalRoot)
$GuardRunner = Join-Path $KitRoot "bootstrap\guard\Invoke-M4trixGuard.ps1"
$GuardFixtures = Join-Path $KitRoot "bootstrap\guard\tests\fixtures"
$LocalFixtures = Join-Path $EvalRoot "fixtures"
$EvidenceDir = Join-Path $EvalRoot "evidence"
$failed = 0

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Assert-True([bool]$Cond, [string]$Msg) {
  if ($Cond) { Write-Host "PASS  $Msg" }
  else { Write-Host "FAIL  $Msg"; $script:failed++ }
}

function Invoke-Guard {
  param(
    [Parameter(Mandatory = $true)][string]$TaskPath,
    [Parameter(Mandatory = $true)][string]$OutFile,
    [string]$Validators = "task-state,recovery"
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

Write-Host "=== Recovery eval (T4) ==="
Write-Host "EvalRoot: $EvalRoot"
Write-Host "KitRoot:  $KitRoot"

Assert-True (Test-Path $GuardRunner) "Guard runner present"
Assert-True (Test-Path (Join-Path $KitRoot "skills\pipeline-recovery\SKILL.md")) "pipeline-recovery skill present"
Assert-True (Test-Path (Join-Path $KitRoot "agents\m4trix-debugger.md")) "m4trix-debugger agent present"
Assert-True (Test-Path (Join-Path $EvalRoot "TRIGGERS.md")) "triggers/non-triggers documented"

$dbg = Get-Content (Join-Path $KitRoot "agents\m4trix-debugger.md") -Raw
Assert-True ($dbg -match "not own production feature" -or $dbg -match "do \*\*not\*\* own") "debugger forbids owning feature impl"

# Positive: strategy-change
$r = Invoke-Guard (Join-Path $GuardFixtures "valid-recovery-strategy-change.json") `
  (Join-Path $EvidenceDir "guard_strategy_change.json")
Assert-True ($r.ExitCode -eq 0 -and $null -ne $r.Result -and $r.Result.ok -eq $true) "strategy-change after fail → ok=true"

# Positive: escalated at budget
$r = Invoke-Guard (Join-Path $GuardFixtures "valid-recovery-escalated.json") `
  (Join-Path $EvidenceDir "guard_escalated.json")
Assert-True ($r.ExitCode -eq 0 -and $null -ne $r.Result -and $r.Result.ok -eq $true) "budget escalate reported → ok=true"

# Negative: repeat rejected
$r = Invoke-Guard (Join-Path $GuardFixtures "invalid-recovery-repeat-rejected.json") `
  (Join-Path $EvidenceDir "guard_repeat_rejected.json")
Assert-True ($r.ExitCode -ne 0 -and $null -ne $r.Result -and $r.Result.ok -eq $false) "repeat rejected approach → ok=false"

# Negative: over budget
$r = Invoke-Guard (Join-Path $GuardFixtures "invalid-recovery-over-budget.json") `
  (Join-Path $EvidenceDir "guard_over_budget.json")
Assert-True ($r.ExitCode -ne 0 -and $null -ne $r.Result -and $r.Result.ok -eq $false) "over budget without escalate → ok=false"

# Negative: rename-only
$r = Invoke-Guard (Join-Path $GuardFixtures "invalid-recovery-rename-only.json") `
  (Join-Path $EvidenceDir "guard_rename_only.json")
Assert-True ($r.ExitCode -ne 0 -and $null -ne $r.Result -and $r.Result.ok -eq $false) "rename-only attempt → ok=false"

# Edge: protected regression mid-recovery
$r = Invoke-Guard (Join-Path $GuardFixtures "invalid-recovery-protected-mid.json") `
  (Join-Path $EvidenceDir "guard_protected_mid.json") "task-state,recovery,regression"
Assert-True ($r.ExitCode -ne 0 -and $null -ne $r.Result -and $r.Result.ok -eq $false) "protected fail mid-recovery → ok=false"

# Persistence: handoff continued keeps attemptCount=2
$handoffPath = Join-Path $LocalFixtures "handoff-continued.json"
Assert-True (Test-Path $handoffPath) "handoff-continued fixture present"
$handObj = Get-Content $handoffPath -Raw | ConvertFrom-Json
Assert-True ([int]$handObj.recovery.attemptCount -eq 2) "handoff attemptCount remains 2 (not reset)"
$r = Invoke-Guard $handoffPath (Join-Path $EvidenceDir "guard_handoff_continued.json")
Assert-True ($r.ExitCode -eq 0 -and $null -ne $r.Result -and $r.Result.ok -eq $true) "handoff-continued Guard ok=true"

# Report
$report = @"
# Recovery eval report (T4)

Measured: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
KitRoot: $KitRoot
Failures: $failed

## Results

| Case | Expected | Artifact |
|------|----------|----------|
| Strategy-change | ok=true | evidence/guard_strategy_change.json |
| Escalated | ok=true | evidence/guard_escalated.json |
| Repeat rejected | ok=false | evidence/guard_repeat_rejected.json |
| Over budget | ok=false | evidence/guard_over_budget.json |
| Rename-only | ok=false | evidence/guard_rename_only.json |
| Protected mid-recovery | ok=false | evidence/guard_protected_mid.json |
| Handoff persistence | attemptCount=2 + ok=true | evidence/guard_handoff_continued.json |

## Notes

- Triggers/non-triggers: TRIGGERS.md
- Debugger agent present; forbids owning production feature impl
- No Router / selective hooks / Fresh install in this eval
"@
Set-Content -Path (Join-Path $EvidenceDir "REPORT.md") -Value $report -Encoding UTF8
Assert-True (Test-Path (Join-Path $EvidenceDir "REPORT.md")) "REPORT.md written"

Write-Host ""
if ($failed -gt 0) {
  Write-Host "RESULT: $failed recovery eval failure(s)"
  exit 1
}
Write-Host "RESULT: recovery eval passed"
exit 0

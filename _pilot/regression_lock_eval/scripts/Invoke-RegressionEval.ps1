#Requires -Version 5.1
<#
.SYNOPSIS
  Positive + negative Regression Lock eval for T3 (REG-001…006, EVAL-001).
#>
param()

$ErrorActionPreference = "Stop"
$EvalRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path (Join-Path $EvalRoot "pubspec.yaml"))) {
  $EvalRoot = Split-Path -Parent $PSScriptRoot
}
$KitRoot = Split-Path -Parent (Split-Path -Parent $EvalRoot)
$GuardRunner = Join-Path $KitRoot "bootstrap\guard\Invoke-M4trixGuard.ps1"
$EvidenceDir = Join-Path $EvalRoot "evidence"
$failed = 0

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Assert-True([bool]$Cond, [string]$Msg) {
  if ($Cond) { Write-Host "PASS  $Msg" }
  else { Write-Host "FAIL  $Msg"; $script:failed++ }
}

function Invoke-FlutterTest([string]$Path, [string]$OutFile) {
  Push-Location $EvalRoot
  try {
    $out = & flutter test $Path 2>&1 | Out-String
    $code = $LASTEXITCODE
  } finally {
    Pop-Location
  }
  Set-Content -Path $OutFile -Value $out -Encoding UTF8
  return [pscustomobject]@{ ExitCode = $code; Output = $out }
}

function Invoke-Guard([string]$TaskPath, [string]$OutFile) {
  $tmp = Join-Path $EvidenceDir ("guard-" + [guid]::NewGuid().ToString("n") + ".json")
  $stdout = & powershell -NoProfile -ExecutionPolicy Bypass -File $GuardRunner `
    -TaskPath $TaskPath -Validators "task-state,regression" -OutputPath $tmp 2>&1 | Out-String
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

Write-Host "=== Regression Lock eval ==="
Write-Host "EvalRoot: $EvalRoot"

Assert-True (Test-Path (Join-Path $EvalRoot "user_notes.md")) "dirty user_notes.md present before eval"
Assert-True (Test-Path $GuardRunner) "Guard runner present"

# Baseline: 5 protected pass, 5 known fail
$base = Invoke-FlutterTest "test/behaviours_test.dart" (Join-Path $EvidenceDir "baseline_behaviours_test.txt")
Assert-True ($base.ExitCode -ne 0) "baseline behaviours_test exits non-zero (5 known fails expected)"
Assert-True ($base.Output -match "B01 normalizeEmail") "baseline ran B01"
Assert-True ($base.Output -match "Some tests failed|failed") "baseline reports failures"

# Count + vs - from flutter output heuristically
$passHits = ([regex]::Matches($base.Output, "All tests passed|^\s*[+\[]")).Count
# Prefer explicit: protected group should show 5 passed if flutter prints per-test; accept non-zero exit with B06-B10 named
Assert-True ($base.Output -match "B06 validateUsername") "baseline includes failing B06"
Assert-True ($base.Output -match "B10 formatMoneyCode") "baseline includes failing B10"

# Positive repairs + intentional regress detection
$fixed = Invoke-FlutterTest "test/scenario_fixed_test.dart" (Join-Path $EvidenceDir "scenario_fixed_test.txt")
Assert-True ($fixed.ExitCode -ne 0) "scenario_fixed exits non-zero because intentional regress test fails"
Assert-True ($fixed.Output -match "B06 fixed") "localized repair B06 exercised"
Assert-True ($fixed.Output -match "B09\+B10 coordinated|coordinated IdPad") "coordinated fix exercised"
Assert-True ($fixed.Output -match "broken normalizeEmail|intentional regress") "intentional regress case present"

# Guard positive
$gPass = Invoke-Guard `
  (Join-Path $KitRoot "bootstrap\guard\tests\fixtures\valid-regression-unit.json") `
  (Join-Path $EvidenceDir "guard_valid_regression.json")
Assert-True ($gPass.ExitCode -eq 0 -and $gPass.Result.ok -eq $true) "Guard accepts valid regression unit"

# Guard negatives
$gProt = Invoke-Guard `
  (Join-Path $KitRoot "bootstrap\guard\tests\fixtures\invalid-regression-protected-fail.json") `
  (Join-Path $EvidenceDir "guard_protected_fail.json")
Assert-True ($gProt.ExitCode -ne 0 -and $gProt.Result.ok -eq $false) "Guard rejects protected fail"

$gInt = Invoke-Guard `
  (Join-Path $KitRoot "bootstrap\guard\tests\fixtures\invalid-regression-integrity.json") `
  (Join-Path $EvidenceDir "guard_integrity_fail.json")
Assert-True ($gInt.ExitCode -ne 0 -and $gInt.Result.ok -eq $false) "Guard rejects integrity violation"

$gBase = Invoke-Guard `
  (Join-Path $KitRoot "bootstrap\guard\tests\fixtures\invalid-regression-missing-baseline.json") `
  (Join-Path $EvidenceDir "guard_missing_baseline.json")
Assert-True ($gBase.ExitCode -ne 0 -and $gBase.Result.ok -eq $false) "Guard rejects missing baseline"

# Dirty file still present (no destructive recovery)
Assert-True (Test-Path (Join-Path $EvalRoot "user_notes.md")) "dirty user_notes.md preserved after eval"

$report = @"
# Regression Lock eval report

| Field | Value |
|-------|-------|
| Task | T3 |
| Measured | $(Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz") |
| Fixture | ``_pilot/regression_lock_eval`` |
| Failures | $failed |

## Checks

| Case | Expected | Result |
|------|----------|--------|
| Baseline 5 pass / 5 fail | non-zero flutter test | see baseline_behaviours_test.txt |
| Intentional regress | broken normalizeEmail fails | see scenario_fixed_test.txt |
| Coordinated IdPad fix | B09+B10 fixed helpers pass | see scenario_fixed_test.txt |
| Guard valid unit | ok=true | guard_valid_regression.json |
| Guard protected fail | ok=false | guard_protected_fail.json |
| Guard integrity violate | ok=false | guard_integrity_fail.json |
| Guard missing baseline | ok=false | guard_missing_baseline.json |
| Dirty path preserved | user_notes.md exists | $(Test-Path (Join-Path $EvalRoot "user_notes.md")) |

## Limitations

- Live IDE completion-gate reject-on-regression is captain procedure until T10.
- Baseline flutter suite is expected red (5 known fails); green is not the success signal.
"@
Set-Content -Path (Join-Path $EvidenceDir "REPORT.md") -Value $report -Encoding UTF8

Write-Host ""
if ($failed -gt 0) {
  Write-Host "RESULT: $failed regression eval failure(s)"
  exit 1
}
Write-Host "RESULT: regression eval passed"
exit 0

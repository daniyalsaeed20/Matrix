#Requires -Version 5.1
<#
.SYNOPSIS
  Isolated positive/negative fixtures for minimal Guard (Task 2).
#>
param()

$ErrorActionPreference = "Stop"
$TestsRoot = $PSScriptRoot
$GuardRoot = Split-Path -Parent $TestsRoot
$Runner = Join-Path $GuardRoot "Invoke-M4trixGuard.ps1"
$Fixtures = Join-Path $TestsRoot "fixtures"
$failed = 0

function Assert-True([bool]$Cond, [string]$Msg) {
  if ($Cond) {
    Write-Host "PASS  $Msg"
  } else {
    Write-Host "FAIL  $Msg"
    $script:failed++
  }
}

function Invoke-GuardFixture {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [string[]]$Validators = @("task-state")
  )
  $tmpOut = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-guard-" + [guid]::NewGuid().ToString("n") + ".json")
  $exitCode = 0
  $stdout = ""
  try {
    $vJoined = ($Validators -join ",")
    $stdout = & powershell -NoProfile -ExecutionPolicy Bypass -File $Runner -TaskPath $Path -Validators $vJoined -OutputPath $tmpOut 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
  } catch {
    $exitCode = 2
    $stdout = [string]$_.Exception.Message
  }
  $obj = $null
  if (Test-Path $tmpOut) {
    try { $obj = Get-Content $tmpOut -Raw | ConvertFrom-Json } catch { $obj = $null }
    Remove-Item -Force $tmpOut -ErrorAction SilentlyContinue
  }
  if ($null -eq $obj -and -not [string]::IsNullOrWhiteSpace($stdout)) {
    try {
      # Runner prints JSON; take last JSON-looking blob if noise present
      $obj = $stdout | ConvertFrom-Json -ErrorAction Stop
    } catch {
      $obj = $null
    }
  }
  return [pscustomobject]@{ ExitCode = $exitCode; Result = $obj; StdOut = $stdout }
}

Write-Host "=== m4tr!x Guard tests ==="
Write-Host "Runner: $Runner"
Assert-True (Test-Path $Runner) "Invoke-M4trixGuard.ps1 exists"
Assert-True (Test-Path (Join-Path $GuardRoot "schema\result.schema.json")) "result.schema.json exists"
Assert-True (Test-Path (Join-Path $GuardRoot "schema\evidence.schema.json")) "evidence.schema.json exists"
Assert-True (Test-Path (Join-Path $GuardRoot "validators\task-state.ps1")) "task-state validator exists"
Assert-True (Test-Path (Join-Path $GuardRoot "validators\regression.ps1")) "regression validator exists"
Assert-True (Test-Path (Join-Path $GuardRoot "schema\regression.schema.json")) "regression.schema.json exists"
Assert-True (Test-Path (Join-Path $GuardRoot "validators\recovery.ps1")) "recovery validator exists"
Assert-True (Test-Path (Join-Path $GuardRoot "schema\recovery.schema.json")) "recovery.schema.json exists"
Assert-True (Test-Path (Join-Path $GuardRoot "validators\routing.ps1")) "routing validator exists"
Assert-True (Test-Path (Join-Path $GuardRoot "schema\routing.schema.json")) "routing.schema.json exists"
Assert-True (Test-Path (Join-Path $GuardRoot "schema\research.schema.json")) "research.schema.json exists"
Assert-True (Test-Path (Join-Path $GuardRoot "validators\research.ps1")) "research.ps1 exists"
Assert-True (Test-Path (Join-Path $GuardRoot "Evaluate-Routing.ps1")) "Evaluate-Routing.ps1 exists"
Assert-True (Test-Path (Join-Path (Split-Path -Parent (Split-Path -Parent $GuardRoot)) "templates\sdlc\routing-policy.json")) "routing-policy.json exists"

# Positive: valid minimal
$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-minimal.json")
Assert-True ($r.ExitCode -eq 0) "valid-minimal exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-minimal ok=true"

# Positive: done with evidence
$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-complete-with-evidence.json")
Assert-True ($r.ExitCode -eq 0) "valid-complete-with-evidence exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-complete-with-evidence ok=true"

# Negative: invalid JSON
$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-not-json.txt")
Assert-True ($r.ExitCode -ne 0) "invalid-not-json non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-not-json ok=false"

# Negative: missing required / bad types
$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-missing-required.json")
Assert-True ($r.ExitCode -ne 0) "invalid-missing-required non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-missing-required ok=false"

# Negative: empty evidence shape must not pass
$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-empty-evidence.json")
Assert-True ($r.ExitCode -ne 0) "invalid-empty-evidence non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-empty-evidence ok=false (no false-pass)"

# Negative: completion without evidence
$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-done-without-evidence.json")
Assert-True ($r.ExitCode -ne 0) "invalid-done-without-evidence non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-done-without-evidence ok=false"

# Edge: missing file
$missing = Join-Path $Fixtures ("no-such-" + [guid]::NewGuid().ToString("n") + ".json")
$r = Invoke-GuardFixture $missing
Assert-True ($r.ExitCode -ne 0) "missing file non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "missing file ok=false"

# Optional git baseline: missing path fails
$tmpTask = Join-Path $Fixtures "valid-minimal.json"
$tmpOut = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-guard-bl-" + [guid]::NewGuid().ToString("n") + ".json")
& powershell -NoProfile -ExecutionPolicy Bypass -File $Runner -TaskPath $tmpTask -GitBaseline "Z:\m4trix-no-such-baseline-path" -OutputPath $tmpOut | Out-Null
$blCode = $LASTEXITCODE
$bl = Get-Content $tmpOut -Raw | ConvertFrom-Json
Remove-Item -Force $tmpOut -ErrorAction SilentlyContinue
Assert-True ($blCode -ne 0) "missing GitBaseline non-zero exit"
Assert-True ($bl.ok -eq $false) "missing GitBaseline ok=false"

# --- Regression Lock validator (T3) ---
$regValidators = @("task-state", "regression")

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-regression-unit.json") -Validators $regValidators
Assert-True ($r.ExitCode -eq 0) "valid-regression-unit exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-regression-unit ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-regression-protected-fail.json") -Validators $regValidators
Assert-True ($r.ExitCode -ne 0) "invalid-regression-protected-fail non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-regression-protected-fail ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-regression-integrity.json") -Validators $regValidators
Assert-True ($r.ExitCode -ne 0) "invalid-regression-integrity non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-regression-integrity ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-regression-missing-baseline.json") -Validators $regValidators
Assert-True ($r.ExitCode -ne 0) "invalid-regression-missing-baseline non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-regression-missing-baseline ok=false"

# --- Recovery validator (T4) ---
$recValidators = @("task-state", "recovery")

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-recovery-strategy-change.json") -Validators $recValidators
Assert-True ($r.ExitCode -eq 0) "valid-recovery-strategy-change exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-recovery-strategy-change ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-recovery-escalated.json") -Validators $recValidators
Assert-True ($r.ExitCode -eq 0) "valid-recovery-escalated exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-recovery-escalated ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-recovery-repeat-rejected.json") -Validators $recValidators
Assert-True ($r.ExitCode -ne 0) "invalid-recovery-repeat-rejected non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-recovery-repeat-rejected ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-recovery-over-budget.json") -Validators $recValidators
Assert-True ($r.ExitCode -ne 0) "invalid-recovery-over-budget non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-recovery-over-budget ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-recovery-rename-only.json") -Validators $recValidators
Assert-True ($r.ExitCode -ne 0) "invalid-recovery-rename-only non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-recovery-rename-only ok=false"

$midValidators = @("task-state", "recovery", "regression")
$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-recovery-protected-mid.json") -Validators $midValidators
Assert-True ($r.ExitCode -ne 0) "invalid-recovery-protected-mid non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-recovery-protected-mid ok=false"

# --- Routing validator (T5) ---
$routeValidators = @("task-state", "routing")

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-routing-security.json") -Validators $routeValidators
Assert-True ($r.ExitCode -eq 0) "valid-routing-security exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-routing-security ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-routing-ui-significant.json") -Validators $routeValidators
Assert-True ($r.ExitCode -eq 0) "valid-routing-ui-significant exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-routing-ui-significant ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-routing-limitation-ack.json") -Validators $routeValidators
Assert-True ($r.ExitCode -eq 0) "valid-routing-limitation-ack exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-routing-limitation-ack ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-routing-omit-mandatory.json") -Validators $routeValidators
Assert-True ($r.ExitCode -ne 0) "invalid-routing-omit-mandatory non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-routing-omit-mandatory ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-routing-parent-impersonation.json") -Validators $routeValidators
Assert-True ($r.ExitCode -ne 0) "invalid-routing-parent-impersonation non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-routing-parent-impersonation ok=false"

# --- Research validator (T6) ---
$researchValidators = @("task-state", "research")

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-research-required.json") -Validators $researchValidators
Assert-True ($r.ExitCode -eq 0) "valid-research-required exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-research-required ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-research-skip.json") -Validators $researchValidators
Assert-True ($r.ExitCode -eq 0) "valid-research-skip exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-research-skip ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-research-web-unavailable.json") -Validators $researchValidators
Assert-True ($r.ExitCode -eq 0) "valid-research-web-unavailable exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-research-web-unavailable ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-research-empty.json") -Validators $researchValidators
Assert-True ($r.ExitCode -ne 0) "invalid-research-empty non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-research-empty ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-research-fabricated.json") -Validators $researchValidators
Assert-True ($r.ExitCode -ne 0) "invalid-research-fabricated non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-research-fabricated ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-research-no-alternatives.json") -Validators $researchValidators
Assert-True ($r.ExitCode -ne 0) "invalid-research-no-alternatives non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-research-no-alternatives ok=false"

# --- Visual validator (T9) ---
$visualValidators = @("task-state", "visual")

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-visual-verified.json") -Validators $visualValidators
Assert-True ($r.ExitCode -eq 0) "valid-visual-verified exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-visual-verified ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-visual-blocked.json") -Validators $visualValidators
Assert-True ($r.ExitCode -eq 0) "valid-visual-blocked exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-visual-blocked ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-visual-static-verified.json") -Validators $visualValidators
Assert-True ($r.ExitCode -ne 0) "invalid-visual-static-verified non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-visual-static-verified ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-visual-missing-artifact.json") -Validators $visualValidators
Assert-True ($r.ExitCode -ne 0) "invalid-visual-missing-artifact non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-visual-missing-artifact ok=false"

# --- Completion validator / gate (T10) ---
$completionValidators = @("task-state", "completion")

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-completion-done.json") -Validators $completionValidators
Assert-True ($r.ExitCode -eq 0) "valid-completion-done exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-completion-done ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-completion-missing-approval.json") -Validators $completionValidators
Assert-True ($r.ExitCode -ne 0) "invalid-completion-missing-approval non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-completion-missing-approval ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-completion-egm-block.json") -Validators $completionValidators
Assert-True ($r.ExitCode -ne 0) "invalid-completion-egm-block non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-completion-egm-block ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-completion-exhausted-retries.json") -Validators $completionValidators
Assert-True ($r.ExitCode -ne 0) "invalid-completion-exhausted-retries non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-completion-exhausted-retries ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-completion-out-of-scope.json") -Validators $completionValidators
Assert-True ($r.ExitCode -ne 0) "invalid-completion-out-of-scope non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-completion-out-of-scope ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-completion-missing-evidence.json") -Validators $completionValidators
Assert-True ($r.ExitCode -ne 0) "invalid-completion-missing-evidence non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-completion-missing-evidence ok=false"

# --- Approval fingerprints (T11) ---
$approvalValidators = @("task-state", "completion", "approval")

$r = Invoke-GuardFixture (Join-Path $Fixtures "valid-approval-done.json") -Validators $approvalValidators
Assert-True ($r.ExitCode -eq 0) "valid-approval-done exit 0"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $true) "valid-approval-done ok=true"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-approval-self-approve.json") -Validators $approvalValidators
Assert-True ($r.ExitCode -ne 0) "invalid-approval-self-approve non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-approval-self-approve ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-approval-missing-fingerprints.json") -Validators $approvalValidators
Assert-True ($r.ExitCode -ne 0) "invalid-approval-missing-fingerprints non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-approval-missing-fingerprints ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-approval-stale-spec.json") -Validators $approvalValidators
Assert-True ($r.ExitCode -ne 0) "invalid-approval-stale-spec non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-approval-stale-spec ok=false"

$r = Invoke-GuardFixture (Join-Path $Fixtures "invalid-approval-scope-change.json") -Validators $approvalValidators
Assert-True ($r.ExitCode -ne 0) "invalid-approval-scope-change non-zero exit"
Assert-True ($null -ne $r.Result -and $r.Result.ok -eq $false) "invalid-approval-scope-change ok=false"

# Completion gate wrapper: positive + refuse on fail (always includes approval)
$gateScript = Join-Path $GuardRoot "Invoke-CompletionGate.ps1"
Assert-True (Test-Path $gateScript) "Invoke-CompletionGate.ps1 present"

$gateOkPath = Join-Path $Fixtures "valid-approval-done.json"
$gateOutPath = Join-Path $env:TEMP ("m4trix-gate-ok-" + [guid]::NewGuid().ToString("n") + ".json")
$pGateOk = Start-Process -FilePath "powershell" -ArgumentList @(
  "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $gateScript,
  "-TaskPath", $gateOkPath, "-SkipAutoValidators", "-OutputPath", $gateOutPath
) -Wait -PassThru -NoNewWindow
Assert-True ($pGateOk.ExitCode -eq 0) "Invoke-CompletionGate valid-approval-done exit 0"

$gateFailPath = Join-Path $Fixtures "invalid-approval-self-approve.json"
$pGateFail = Start-Process -FilePath "powershell" -ArgumentList @(
  "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $gateScript,
  "-TaskPath", $gateFailPath, "-SkipAutoValidators"
) -Wait -PassThru -NoNewWindow
Assert-True ($pGateFail.ExitCode -ne 0) "Invoke-CompletionGate self-approve refuses (non-zero)"

$gateMissPath = Join-Path $Fixtures "invalid-completion-missing-approval.json"
$pGateMiss = Start-Process -FilePath "powershell" -ArgumentList @(
  "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $gateScript,
  "-TaskPath", $gateMissPath, "-SkipAutoValidators"
) -Wait -PassThru -NoNewWindow
Assert-True ($pGateMiss.ExitCode -ne 0) "Invoke-CompletionGate missing-approval refuses (non-zero)"

Write-Host ""
if ($failed -gt 0) {
  Write-Host "RESULT: $failed Guard test failure(s)"
  exit 1
}
Write-Host "RESULT: all Guard tests passed"
exit 0

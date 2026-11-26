#Requires -Version 5.1
<#
.SYNOPSIS
  ± eval for T11 approval fingerprints + CompletionGate refuse/allow.
#>
param()

$ErrorActionPreference = "Stop"
$PilotRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$KitRoot = Split-Path -Parent $PilotRoot
$EvalRoot = Split-Path -Parent $PSScriptRoot
$Evidence = Join-Path $EvalRoot "evidence"
$Fixtures = Join-Path $KitRoot "bootstrap\guard\tests\fixtures"
$Gate = Join-Path $KitRoot "bootstrap\guard\Invoke-CompletionGate.ps1"
$GuardTests = Join-Path $KitRoot "bootstrap\guard\tests\Invoke-GuardTests.ps1"

New-Item -ItemType Directory -Force -Path $Evidence | Out-Null

$cases = @()
$failed = 0

function Invoke-GateCase {
  param(
    [string]$Name,
    [string]$Fixture,
    [bool]$ExpectOk
  )
  $path = Join-Path $Fixtures $Fixture
  $out = Join-Path $Evidence ("gate-" + $Name + ".json")
  $p = Start-Process -FilePath "powershell" -ArgumentList @(
    "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $Gate,
    "-TaskPath", $path, "-SkipAutoValidators", "-OutputPath", $out
  ) -Wait -PassThru -NoNewWindow
  $ok = ($p.ExitCode -eq 0)
  $pass = ($ok -eq $ExpectOk)
  if (-not $pass) { $script:failed++ }
  $script:cases += [ordered]@{
    name       = $Name
    fixture    = $Fixture
    expectOk   = $ExpectOk
    exitCode   = $p.ExitCode
    pass       = $pass
    outputPath = $out
  }
  $status = if ($pass) { "PASS" } else { "FAIL" }
  Write-Host "$status  $Name (exit=$($p.ExitCode) expectOk=$ExpectOk)"
}

Write-Host "=== T11 approval fingerprint eval ==="
Write-Host "KitRoot: $KitRoot"

# Guard suite includes approval ±
$gt = Start-Process -FilePath "powershell" -ArgumentList @(
  "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $GuardTests
) -Wait -PassThru -NoNewWindow
$guardPass = ($gt.ExitCode -eq 0)
if (-not $guardPass) { $failed++ }
$cases += [ordered]@{
  name     = "Invoke-GuardTests"
  fixture  = "bootstrap/guard/tests"
  expectOk = $true
  exitCode = $gt.ExitCode
  pass     = $guardPass
}
Write-Host "$(if ($guardPass) { 'PASS' } else { 'FAIL' })  Invoke-GuardTests (exit=$($gt.ExitCode))"

Invoke-GateCase -Name "allow-valid" -Fixture "valid-approval-done.json" -ExpectOk $true
Invoke-GateCase -Name "refuse-self-approve" -Fixture "invalid-approval-self-approve.json" -ExpectOk $false
Invoke-GateCase -Name "refuse-missing-fp" -Fixture "invalid-approval-missing-fingerprints.json" -ExpectOk $false
Invoke-GateCase -Name "refuse-stale-spec" -Fixture "invalid-approval-stale-spec.json" -ExpectOk $false
Invoke-GateCase -Name "refuse-scope-change" -Fixture "invalid-approval-scope-change.json" -ExpectOk $false

$summary = [ordered]@{
  ok            = ($failed -eq 0)
  failed        = $failed
  recordedAt    = (Get-Date).ToUniversalTime().ToString("o")
  algorithm     = "sha256-normalized-utf8-fail-closed"
  policySoT     = @("docs/sdlc/REQUIREMENTS.md VER-002..004", "docs/sdlc/REQUIREMENTS.md VER-003", "templates/sdlc/EGM_REVIEW.md Blocking policy")
  fingerprintLib = "bootstrap/guard/lib/ApprovalFingerprint.ps1"
  limitations   = @(
    "Not cryptographic captain auth",
    "No formatting-only detector — content hash fail closed (VER-004)",
    "Process gate only — model can skip invoking CompletionGate (see GUARD_BYPASS_MATRIX)"
  )
  cases        = $cases
}

$summaryPath = Join-Path $Evidence "SUMMARY.json"
($summary | ConvertTo-Json -Depth 8) | Set-Content -LiteralPath $summaryPath -Encoding UTF8
Write-Host ""
Write-Host "SUMMARY: $summaryPath"
Write-Host "EXIT_CODE=$failed"
if ($failed -gt 0) { exit 1 }
exit 0

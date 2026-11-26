#Requires -Version 5.1
<#
.SYNOPSIS
  Positive + negative Guard completion / selective-hooks eval for T10 (GRD-003, RB-08, EVAL-001).
#>
param()

$ErrorActionPreference = "Stop"
$EvalRoot = Split-Path -Parent $PSScriptRoot
$KitRoot = Split-Path -Parent (Split-Path -Parent $EvalRoot)
$EvidenceDir = Join-Path $EvalRoot "evidence"
$GuardTests = Join-Path $KitRoot "bootstrap\guard\tests\Invoke-GuardTests.ps1"
$failed = 0

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Assert-True([bool]$Cond, [string]$Msg) {
  if ($Cond) { Write-Host "PASS  $Msg" }
  else { Write-Host "FAIL  $Msg"; $script:failed++ }
}

Write-Host "=== Guard complete eval (T10) ==="
Write-Host "EvalRoot: $EvalRoot"
Write-Host "KitRoot:  $KitRoot"

# --- Artifacts present ---
Assert-True (Test-Path (Join-Path $KitRoot "bootstrap\guard\validators\completion.ps1")) "completion.ps1 present"
Assert-True (Test-Path (Join-Path $KitRoot "bootstrap\guard\Invoke-CompletionGate.ps1")) "Invoke-CompletionGate.ps1 present"
Assert-True (Test-Path (Join-Path $KitRoot "docs\sdlc\GUARD_BYPASS_MATRIX.md")) "GUARD_BYPASS_MATRIX.md present"

$fx = Join-Path $KitRoot "bootstrap\guard\tests\fixtures"
foreach ($f in @(
  "valid-completion-done.json",
  "invalid-completion-missing-approval.json",
  "invalid-completion-egm-block.json",
  "invalid-completion-exhausted-retries.json",
  "invalid-completion-out-of-scope.json",
  "invalid-completion-missing-evidence.json"
)) {
  Assert-True (Test-Path (Join-Path $fx $f)) "fixture $f"
}

# --- Bypass matrix honesty ---
$matrix = Get-Content (Join-Path $KitRoot "docs\sdlc\GUARD_BYPASS_MATRIX.md") -Raw
Assert-True ($matrix -match "unbypassable|Never claim") "bypass matrix: no unbypassable claim"
Assert-True ($matrix -match "Write/StrReplace|Write") "bypass matrix: Write/StrReplace path"
Assert-True ($matrix -match "fail-open|failClosed") "bypass matrix: fail-open/failClosed"
Assert-True ($matrix -match "Completion-blocking|completion gate") "bypass matrix: completion-blocking"

# --- Pipelines / verifier wired ---
$mod = Get-Content (Join-Path $KitRoot "skills\pipeline-module\SKILL.md") -Raw
Assert-True ($mod -match "Invoke-CompletionGate") "pipeline-module: completion gate"
$ver = Get-Content (Join-Path $KitRoot "agents\m4trix-verifier.md") -Raw
Assert-True ($ver -match "Completion gate|Invoke-CompletionGate") "verifier: completion gate"

# --- Hooks: scripts present, default json advisory-only ---
$hooksJson = Get-Content (Join-Path $KitRoot "hooks\hooks.json") -Raw
Assert-True ($hooksJson -match "sessionStart") "hooks.json: sessionStart"
Assert-True ($hooksJson -match "workspaceOpen") "hooks.json: workspaceOpen"
Assert-True ($hooksJson -notmatch "beforeShellExecution") "hooks.json: beforeShellExecution NOT registered"
Assert-True ($hooksJson -notmatch "preToolUse") "hooks.json: preToolUse NOT registered"
Assert-True ($hooksJson -notmatch "subagentStart") "hooks.json: subagentStart NOT registered"

Assert-True (Test-Path (Join-Path $KitRoot "hooks\m4trix-before-shell.ps1")) "m4trix-before-shell.ps1 present"
Assert-True (Test-Path (Join-Path $KitRoot "hooks\m4trix-pre-tool-use.ps1")) "m4trix-pre-tool-use.ps1 present"
Assert-True (Test-Path (Join-Path $KitRoot "hooks\m4trix-subagent-start.ps1")) "m4trix-subagent-start.ps1 present"

# --- Hook probe T10 ---
$probe = Join-Path $KitRoot "_pilot\v2_baseline\HOOK_PROBE_T10.json"
Assert-True (Test-Path $probe) "HOOK_PROBE_T10.json present"
$probeObj = Get-Content $probe -Raw | ConvertFrom-Json
Assert-True ($probeObj.liveFireVerified.status -eq "unverified_in_this_environment") "probe: preventive still unverified"
Assert-True (@($probeObj.liveFireVerified.verifiedPreventive).Count -eq 0) "probe: no verifiedPreventive claims"

# --- Guard ± suite ---
Assert-True (Test-Path $GuardTests) "Invoke-GuardTests.ps1 present"
$guardOut = & powershell -NoProfile -ExecutionPolicy Bypass -File $GuardTests 2>&1 | Out-String
$guardCode = $LASTEXITCODE
Assert-True ($guardCode -eq 0) "Invoke-GuardTests.ps1 EXIT_CODE=0"
Assert-True ($guardOut -match "valid-completion-done ok=true") "Guard: valid-completion-done ok"
Assert-True ($guardOut -match "invalid-completion-missing-approval ok=false") "Guard: missing-approval fails"
Assert-True ($guardOut -match "invalid-completion-egm-block ok=false") "Guard: egm-block fails"
Assert-True ($guardOut -match "invalid-completion-exhausted-retries ok=false") "Guard: exhausted-retries fails"
Assert-True ($guardOut -match "invalid-completion-out-of-scope ok=false") "Guard: out-of-scope fails"
Assert-True ($guardOut -match "invalid-completion-missing-evidence ok=false") "Guard: missing-evidence fails"
Assert-True ($guardOut -match "Invoke-CompletionGate missing-approval refuses") "Guard: gate refuse path"

# --- Direct gate refuse procedure (live script attempt) ---
$gate = Join-Path $KitRoot "bootstrap\guard\Invoke-CompletionGate.ps1"
$failFx = Join-Path $fx "invalid-completion-missing-approval.json"
$gateOut = Join-Path $EvidenceDir "gate-refuse-missing-approval.json"
$p = Start-Process -FilePath "powershell" -ArgumentList @(
  "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $gate,
  "-TaskPath", $failFx, "-SkipAutoValidators", "-OutputPath", $gateOut
) -Wait -PassThru -NoNewWindow -RedirectStandardError (Join-Path $EvidenceDir "gate-refuse.err.txt")
Assert-True ($p.ExitCode -ne 0) "live procedure: completion gate refuses done with Guard fail"
Assert-True (Test-Path $gateOut) "gate refuse result written"

$okFx = Join-Path $fx "valid-completion-done.json"
$okOut = Join-Path $EvidenceDir "gate-allow-valid-done.json"
$p2 = Start-Process -FilePath "powershell" -ArgumentList @(
  "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $gate,
  "-TaskPath", $okFx, "-SkipAutoValidators", "-OutputPath", $okOut
) -Wait -PassThru -NoNewWindow
Assert-True ($p2.ExitCode -eq 0) "live procedure: completion gate allows valid done"
Assert-True (Test-Path $okOut) "gate allow result written"

# --- before-shell script dry deny (stdin JSON, no IDE hook registration) ---
$shellHook = Join-Path $KitRoot "hooks\m4trix-before-shell.ps1"
$denyPayload = '{ "command": "powershell -File bootstrap/install-globals.ps1 -Fresh" }'
$denyOut = $denyPayload | & powershell -NoProfile -ExecutionPolicy Bypass -File $shellHook 2>&1 | Out-String
Assert-True ($denyOut -match '"permission"\s*:\s*"deny"') "before-shell script denies Fresh pattern (script-level)"
$allowPayload = '{ "command": "powershell -File bootstrap/smoke-tests.ps1" }'
$allowOut = $allowPayload | & powershell -NoProfile -ExecutionPolicy Bypass -File $shellHook 2>&1 | Out-String
Assert-True ($allowOut -match '"permission"\s*:\s*"allow"') "before-shell script allows ordinary smoke"

# --- Copy summary evidence ---
$summary = [ordered]@{
  measuredAt = (Get-Date).ToString("o")
  eval = "guard_complete_eval"
  guardTestsExit = $guardCode
  preventiveClaimed = $false
  defaultHooksDenyRegistered = $false
  failed = $script:failed
}
($summary | ConvertTo-Json -Depth 4) | Set-Content -Path (Join-Path $EvidenceDir "SUMMARY.json") -Encoding UTF8

Write-Host ""
if ($failed -gt 0) {
  Write-Host "RESULT: $failed guard_complete_eval failure(s)"
  exit 1
}
Write-Host "RESULT: guard_complete_eval passed"
exit 0

#Requires -Version 5.1
<#
.SYNOPSIS
  Smoke tests for Matrix m4tr!x kit (self-locate, hooks schema, mixed-stack detect).
#>
param(
  [switch]$TestFreshInstall
)

$ErrorActionPreference = "Stop"
$KitRoot = Split-Path -Parent $PSScriptRoot
$failed = 0

function Assert-True($cond, $msg) {
  if ($cond) {
    Write-Host "PASS  $msg"
  } else {
    Write-Host "FAIL  $msg"
    $script:failed++
  }
}

. (Join-Path $KitRoot "hooks\m4trix-platform.ps1")

Write-Host "=== m4tr!x smoke tests ==="
Write-Host "KitRoot: $KitRoot"

Assert-True (Test-M4trixKitRootCandidate $KitRoot) "clone path is a valid kit root"
Assert-True (Test-Path (Join-Path $KitRoot "constitution\project-rules\04-code-craft.mdc")) "04-code-craft.mdc exists"
Assert-True (Test-Path (Join-Path $KitRoot "constitution\project-rules\05-delivery-voice.mdc")) "05-delivery-voice.mdc exists"
Assert-True (Test-Path (Join-Path $KitRoot "constitution\project-rules\stack-flutter-reusability.mdc")) "stack-flutter-reusability.mdc exists"
Assert-True (Test-Path (Join-Path $KitRoot "templates\sdlc\ACTIVE_TASK.json")) "ACTIVE_TASK.json template exists"
Assert-True (Test-Path (Join-Path $KitRoot "hooks\m4trix-session-start.ps1")) "session-start hook exists"
Assert-True (Test-Path (Join-Path $KitRoot "ecc-cherry-pick\karpathy-principles.md")) "karpathy reference exists"
Assert-True (Test-Path (Join-Path $KitRoot "_pilot\craft_scenarios\README.md")) "craft scenarios fixture exists"

$craft = Get-Content (Join-Path $KitRoot "constitution\project-rules\04-code-craft.mdc") -Raw
Assert-True ($craft -match "Think before coding") "craft: Think before coding"
Assert-True ($craft -match "Simplicity first") "craft: Simplicity first"
Assert-True ($craft -match "Surgical changes") "craft: Surgical changes"
Assert-True ($craft -match "Goal-driven execution") "craft: Goal-driven execution"
Assert-True ($craft -match "Decision hierarchy") "craft: Decision hierarchy"
Assert-True ($craft -match "Never cut lines") "craft: rejects pure LOC golf"

$ver = Get-Content (Join-Path $KitRoot "agents\m4trix-verifier.md") -Raw
Assert-True ($ver -match "drive-by|Unrelated|surgical") "verifier checks surgical/unrelated diffs"
Assert-True ($ver -match "actually run|What was verified") "verifier requires real verification evidence"
Assert-True ($ver -match "Delivery voice|IDE / AI-editor attribution|no Cursor") "verifier checks delivery voice"
$voice = Get-Content (Join-Path $KitRoot "constitution\project-rules\05-delivery-voice.mdc") -Raw
Assert-True ($voice -match "commit|Pull request|PR") "delivery voice covers commits/PRs"
Assert-True ($voice -match "Matrix kit") "delivery voice exempts Matrix kit install docs"
$manifest = Get-Content (Join-Path $KitRoot "bootstrap\MANIFEST.json") -Raw
Assert-True ($manifest -match "05-delivery-voice") "MANIFEST ships 05-delivery-voice"

$tok = Get-Content (Join-Path $KitRoot "constitution\project-rules\03-token-discipline.mdc") -Raw
Assert-True ($tok -match "Progressive load") "context: progressive load"
Assert-True ($tok -match "Soft budgets") "context: soft budgets"
Assert-True ($tok -match "extra agents|subagents only when needed|one implementer") "token: avoid extra agents on patches"
Assert-True ($tok -match "reusable-component search|reuse search|04-code-craft") "context must not skip reuse/craft"
Assert-True (Test-Path (Join-Path $KitRoot "templates\sdlc\HANDOFF.md")) "HANDOFF.md template exists"
Assert-True (Test-Path (Join-Path $KitRoot "ecc-cherry-pick\context-engineering.md")) "context-engineering reference exists"
Assert-True (Test-Path (Join-Path $KitRoot "_pilot\context_eval\README.md")) "context eval fixture exists"
$activeTpl = Get-Content (Join-Path $KitRoot "templates\sdlc\ACTIVE_TASK.json") -Raw
Assert-True ($activeTpl -match "acceptanceCriteria") "ACTIVE_TASK has acceptanceCriteria"
Assert-True ($activeTpl -match "reusableComponents") "ACTIVE_TASK has reusableComponents"
Assert-True ($activeTpl -match "staleAfterHours") "ACTIVE_TASK has stale marker"
Assert-True ($activeTpl -match '"egm"') "ACTIVE_TASK has egm block"
Assert-True (Test-Path (Join-Path $KitRoot "skills\egm-review\SKILL.md")) "egm-review skill exists"
Assert-True (Test-Path (Join-Path $KitRoot "templates\sdlc\EGM_REVIEW.md")) "EGM_REVIEW template exists"
Assert-True (Test-Path (Join-Path $KitRoot "ecc-cherry-pick\egm.md")) "egm attribution reference exists"
$prodPipe = Get-Content (Join-Path $KitRoot "skills\pipeline-product\SKILL.md") -Raw
$modPipe = Get-Content (Join-Path $KitRoot "skills\pipeline-module\SKILL.md") -Raw
$patchPipe = Get-Content (Join-Path $KitRoot "skills\pipeline-patch\SKILL.md") -Raw
Assert-True ($prodPipe -match "egm-review|EGM Goldfish") "product pipeline activates EGM"
Assert-True ($modPipe -match "egm-review|Goldfish") "module pipeline activates EGM when needed"
Assert-True ($patchPipe -match "EGM / Goldfish: skip|skip.*EGM") "patch pipeline skips EGM"
Assert-True ((@(Get-ChildItem (Join-Path $KitRoot "constitution\project-rules") -Filter "*.mdc" | Where-Object {
  (Get-Content $_.FullName -Raw) -match "alwaysApply:\s*true"
}).Count) -le 6) "always-apply rules stay lean (≤6)"
Assert-True ((@(Get-ChildItem (Join-Path $KitRoot "agents") -Filter "m4trix-*.md")).Count -eq 12) "still 12 m4trix agents (no permanent Goldfish agent)"

# beforeSubmitPrompt schema
$before = Join-Path $KitRoot "hooks\m4trix-before-prompt.ps1"
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File $before 2>$null
Assert-True ($out -match '"continue"\s*:\s*true') "beforeSubmitPrompt returns continue:true"
Assert-True ($out -notmatch 'additional_context') "beforeSubmitPrompt does not emit additional_context"

# Get-M4trixKitRoot with hint (no hardcoded D:)
$resolved = Get-M4trixKitRoot -HintFromScript $KitRoot -AllowMissing
Assert-True ($resolved -eq (Normalize-M4trixPath $KitRoot)) "Get-M4trixKitRoot resolves via hint/clone"

# Mixed-stack dry-run fixture
$fixture = Join-Path $KitRoot "_pilot\mixed_stack_smoke"
New-Item -ItemType Directory -Force -Path (Join-Path $fixture "functions") | Out-Null
if (-not (Test-Path (Join-Path $fixture "pubspec.yaml"))) {
  Set-Content -Path (Join-Path $fixture "pubspec.yaml") -Value "name: mixed_stack_smoke`npublish_to: none`n" -Encoding UTF8
}
if (-not (Test-Path (Join-Path $fixture "functions\package.json"))) {
  Set-Content -Path (Join-Path $fixture "functions\package.json") -Value '{ "name": "fns", "private": true }' -Encoding UTF8
}

$apply = Join-Path $KitRoot "bootstrap\apply-to-workspace.ps1"
$dry = & powershell -NoProfile -ExecutionPolicy Bypass -File $apply -Workspace $fixture -KitRoot $KitRoot -DryRun 2>&1 | Out-String
Assert-True ($dry -match "flutter") "mixed-stack detects flutter"
Assert-True ($dry -match "nodejs") "mixed-stack detects nodejs additively with flutter"

# Dry-run apply against pilot (regression)
$pilot = Join-Path $KitRoot "_pilot\m4trix_kit_smoke"
if (Test-Path $pilot) {
  $pilotDry = & powershell -NoProfile -ExecutionPolicy Bypass -File $apply -Workspace $pilot -KitRoot $KitRoot -DryRun 2>&1 | Out-String
  Assert-True ($pilotDry -match "flutter") "pilot dry-run detects flutter"
  Assert-True ($pilotDry -match "04-code-craft|code-craft") "pilot plan includes code-craft rule"
}

if ($TestFreshInstall) {
  Write-Host "Running install-globals -Fresh from this clone..."
  & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $KitRoot "bootstrap\install-globals.ps1") -Fresh
  $state = Read-M4trixKitState
  Assert-True ($null -ne $state) "kit.json written after Fresh install"
  Assert-True ((Normalize-M4trixPath $state.kitRoot) -eq (Normalize-M4trixPath $KitRoot)) "kit.json kitRoot matches clone"
  Assert-True (-not [bool]$state.autoApplyWorkspaces) "autoApplyWorkspaces default false"
}

Write-Host ""
if ($failed -gt 0) {
  Write-Host "RESULT: $failed failure(s)"
  exit 1
}
Write-Host "RESULT: all checks passed"
exit 0

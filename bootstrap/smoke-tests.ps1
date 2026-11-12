#Requires -Version 5.1
<#
.SYNOPSIS
  Smoke tests for Matrix m4tr!x kit (self-locate, hooks merge, session advisory, mixed-stack detect).
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

function Invoke-KitScript([string]$scriptPath, [string[]]$ScriptArgs = @()) {
  Invoke-M4trixPs1 -scriptPath $scriptPath -ScriptArgs $ScriptArgs
}

Write-Host "=== m4tr!x smoke tests ==="
Write-Host "KitRoot: $KitRoot"
if (Test-M4trixIsWindows) {
  Write-Host "Platform: Windows (launcher via Get-M4trixShellLauncher)"
} else {
  Write-Host "Platform: non-Windows (pwsh launcher)"
}

Assert-True (Test-M4trixKitRootCandidate $KitRoot) "clone path is a valid kit root"
Assert-True (Test-Path (Join-Path $KitRoot "constitution\project-rules\04-code-craft.mdc")) "04-code-craft.mdc exists"
Assert-True (Test-Path (Join-Path $KitRoot "constitution\project-rules\05-delivery-voice.mdc")) "05-delivery-voice.mdc exists"
Assert-True (Test-Path (Join-Path $KitRoot "constitution\project-rules\stack-flutter-reusability.mdc")) "stack-flutter-reusability.mdc exists"
Assert-True (Test-Path (Join-Path $KitRoot "templates\sdlc\ACTIVE_TASK.json")) "ACTIVE_TASK.json template exists"
Assert-True (Test-Path (Join-Path $KitRoot "hooks\m4trix-session-start.ps1")) "session-start hook exists"
Assert-True (-not (Test-Path (Join-Path $KitRoot "hooks\m4trix-before-prompt.ps1"))) "before-prompt hook script removed"
Assert-True (Test-Path (Join-Path $KitRoot "ecc-cherry-pick\karpathy-principles.md")) "karpathy reference exists"
Assert-True (Test-Path (Join-Path $KitRoot "_pilot\craft_scenarios\README.md")) "craft scenarios fixture exists"
Assert-True (Test-Path (Join-Path $KitRoot "bootstrap\package-source.ps1")) "package-source script exists"

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
$egmSkill = Get-Content (Join-Path $KitRoot "skills\egm-review\SKILL.md") -Raw
$egmTpl = Get-Content (Join-Path $KitRoot "templates\sdlc\EGM_REVIEW.md") -Raw
Assert-True ($prodPipe -match "egm-review|EGM Goldfish") "product pipeline activates EGM"
Assert-True ($modPipe -match "egm-review|Goldfish") "module pipeline activates EGM when needed"
Assert-True ($patchPipe -match "EGM / Goldfish: skip|skip.*EGM") "patch pipeline skips EGM"
Assert-True ($egmSkill -match "not risk-acceptable|risk-accepted") "egm-review distinguishes risk acceptance"
Assert-True ($egmSkill -match "security defects") "egm-review blocks unresolved security via docs fix"
Assert-True ($egmTpl -match "not eligible for risk acceptance") "EGM_REVIEW template encodes Blocking classes"
Assert-True ($egmTpl -match "Explicit captain approval") "EGM_REVIEW keeps captain approval gate"
Assert-True ((Get-M4trixManagedSkillNames) -contains "egm-review") "managed skill cleanup includes egm-review"
Assert-True ((@(Get-ChildItem (Join-Path $KitRoot "constitution\project-rules") -Filter "*.mdc" | Where-Object {
  (Get-Content $_.FullName -Raw) -match "alwaysApply:\s*true"
}).Count) -le 6) "always-apply rules stay lean (≤6)"
Assert-True ((@(Get-ChildItem (Join-Path $KitRoot "agents") -Filter "m4trix-*.md")).Count -eq 12) "still 12 m4trix agents (no permanent Goldfish agent)"

# Platform launcher helpers (no hard-coded powershell in smoke execution path)
$launcher = Get-M4trixShellLauncher
Assert-True ($null -ne $launcher.Exe) "shell launcher Exe present"
if (Test-M4trixIsWindows) {
  Assert-True ($launcher.Exe -eq "powershell") "Windows launcher is powershell"
} else {
  Assert-True ($launcher.Exe -eq "pwsh") "non-Windows launcher is pwsh"
}

# Version compare
Assert-True ((Compare-M4trixVersion "1.5.0" "1.5.1") -lt 0) "version compare: 1.5.0 < 1.5.1"
Assert-True ((Compare-M4trixVersion "1.5.1" "1.5.1") -eq 0) "version compare: equal"
Assert-True ((Compare-M4trixVersion "1.6.0" "1.5.1") -gt 0) "version compare: 1.6.0 > 1.5.1"

# --- Hooks merge: third-party props, malformed JSON, reinstall dedupe, strip-only ---
$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-smoke-hooks-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null
try {
  $hooksPath = Join-Path $tmpRoot "hooks.json"
  $thirdParty = @{
    version = 1
    hooks = @{
      beforeSubmitPrompt = @(
        @{
          command = "vendor-hook --check"
          timeout = 15
          type = "command"
          matcher = "always"
          failClosed = $true
          customVendorFlag = "keep-me"
        }
      )
      sessionStart = @(
        @{ command = "other-session.sh"; timeout = 5; annotation = "third-party" }
      )
    }
  }
  ($thirdParty | ConvertTo-Json -Depth 8) | Set-Content -Path $hooksPath -Encoding UTF8

  $m4 = @{
    workspaceOpen = @(@{ command = (Get-M4trixHookCommand "./hooks/m4trix-workspace-open.ps1"); timeout = 120 })
    sessionStart  = @(@{ command = (Get-M4trixHookCommand "./hooks/m4trix-session-start.ps1"); timeout = 20 })
  }
  Merge-M4trixHooksJson -Path $hooksPath -M4trixEntries $m4
  $merged1 = Get-Content $hooksPath -Raw | ConvertFrom-Json
  $bsp = @($merged1.hooks.beforeSubmitPrompt)
  Assert-True ($bsp.Count -eq 1) "third-party beforeSubmitPrompt preserved (count)"
  Assert-True ([string]$bsp[0].command -eq "vendor-hook --check") "third-party command preserved"
  Assert-True ([string]$bsp[0].customVendorFlag -eq "keep-me") "custom hook property preserved"
  Assert-True ([bool]$bsp[0].failClosed -eq $true) "failClosed property preserved"
  Assert-True ($null -eq $merged1.hooks.beforeSubmitPrompt -or (@($merged1.hooks.beforeSubmitPrompt) | Where-Object { Test-M4trixOwnedHookCommand ([string]$_.command) }).Count -eq 0) "m4trix beforeSubmitPrompt not registered"
  $ss = @($merged1.hooks.sessionStart)
  Assert-True ((@($ss | Where-Object { [string]$_.command -eq "other-session.sh" })).Count -eq 1) "third-party sessionStart kept"
  Assert-True ((@($ss | Where-Object { Test-M4trixOwnedHookCommand ([string]$_.command) })).Count -eq 1) "exactly one m4trix sessionStart after merge"
  Assert-True ((@(Get-ChildItem $tmpRoot -Filter "hooks.json.m4trix-backup-*")).Count -ge 1) "hooks.json backed up before mutation"

  # Reinstall must not duplicate m4trix hooks
  Merge-M4trixHooksJson -Path $hooksPath -M4trixEntries $m4
  $merged2 = Get-Content $hooksPath -Raw | ConvertFrom-Json
  $ss2 = @($merged2.hooks.sessionStart)
  Assert-True ((@($ss2 | Where-Object { Test-M4trixOwnedHookCommand ([string]$_.command) })).Count -eq 1) "reinstall does not duplicate m4trix sessionStart"
  Assert-True ((@($ss2 | Where-Object { [string]$_.command -eq "other-session.sh" })).Count -eq 1) "third-party sessionStart still present after reinstall"
  Assert-True ([string](@($merged2.hooks.beforeSubmitPrompt)[0].customVendorFlag) -eq "keep-me") "custom props survive reinstall"

  # Strip removes only m4trix-owned
  Strip-M4trixHooksJson -Path $hooksPath
  $stripped = Get-Content $hooksPath -Raw | ConvertFrom-Json
  $allCmds = @()
  if ($stripped.hooks) {
    foreach ($p in $stripped.hooks.PSObject.Properties) {
      foreach ($item in @($p.Value)) { $allCmds += [string]$item.command }
    }
  }
  Assert-True (($allCmds | Where-Object { Test-M4trixOwnedHookCommand $_ }).Count -eq 0) "strip removes only m4trix-owned commands"
  Assert-True ($allCmds -contains "vendor-hook --check") "strip keeps third-party beforeSubmitPrompt"
  Assert-True ($allCmds -contains "other-session.sh") "strip keeps third-party sessionStart"

  # Malformed JSON must fail without replace
  $badPath = Join-Path $tmpRoot "bad-hooks.json"
  Set-Content -Path $badPath -Value "{ not json" -Encoding UTF8
  $beforeBad = Get-Content $badPath -Raw
  $threw = $false
  try {
    Merge-M4trixHooksJson -Path $badPath -M4trixEntries $m4
  } catch {
    $threw = $true
  }
  Assert-True $threw "malformed hooks.json causes failure"
  Assert-True ((Get-Content $badPath -Raw) -eq $beforeBad) "malformed hooks.json left unmodified"

  # Managed skill list cleanup unit check with temp skills dir simulation
  $skillNames = Get-M4trixManagedSkillNames
  Assert-True (($skillNames | Where-Object { $_ -eq "egm-review" }).Count -eq 1) "egm-review listed once in managed skills"
  Assert-True (($skillNames | Where-Object { $_ -eq "unrelated-skill" }).Count -eq 0) "unrelated skills not in managed list"
}
finally {
  Remove-Item -Recurse -Force $tmpRoot -ErrorAction SilentlyContinue
}

# Session-start: outdated marker advisory (uses VERSION file via M4TRIX_KIT_ROOT; no state mutation)
$sessionHook = Join-Path $KitRoot "hooks\m4trix-session-start.ps1"
$projTmp = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-smoke-proj-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Force -Path (Join-Path $projTmp "docs\sdlc") | Out-Null
try {
  Set-Content -Path (Join-Path $projTmp "package.json") -Value '{ "name": "smoke" }' -Encoding UTF8
  @{
    kit = "m4trix"
    version = "1.0.0"
    kitRoot = $KitRoot
  } | ConvertTo-Json | Set-Content -Path (Join-Path $projTmp "docs\sdlc\.m4trix-kit.json") -Encoding UTF8

  $prevProject = $env:CURSOR_PROJECT_DIR
  $prevKitEnv = $env:M4TRIX_KIT_ROOT
  try {
    $env:CURSOR_PROJECT_DIR = $projTmp
    $env:M4TRIX_KIT_ROOT = $KitRoot
    $sessionArgs = @($launcher.PrefixArgs) + @("-File", $sessionHook)
    $out = "" | & $launcher.Exe @sessionArgs 2>$null | Out-String
    # Prefer kit.json version when present; else VERSION. Project 1.0.0 must be behind either.
    Assert-True ($out -match "Upgrade available") "sessionStart advises when project marker is behind"
    Assert-True ($out -match "do not auto-upgrade|DryRun") "sessionStart requires captain auth / dry-run"
    Assert-True ($out -match "additional_context") "sessionStart emits additional_context for advisory"
  }
  finally {
    if ($null -ne $prevProject) { $env:CURSOR_PROJECT_DIR = $prevProject } else { Remove-Item Env:CURSOR_PROJECT_DIR -ErrorAction SilentlyContinue }
    if ($null -ne $prevKitEnv) { $env:M4TRIX_KIT_ROOT = $prevKitEnv } else { Remove-Item Env:M4TRIX_KIT_ROOT -ErrorAction SilentlyContinue }
  }
}
finally {
  Remove-Item -Recurse -Force $projTmp -ErrorAction SilentlyContinue
}

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
$dryArgs = @($launcher.PrefixArgs) + @("-File", $apply, "-Workspace", $fixture, "-KitRoot", $KitRoot, "-DryRun")
$dry = & $launcher.Exe @dryArgs 2>&1 | Out-String
Assert-True ($dry -match "flutter") "mixed-stack detects flutter"
Assert-True ($dry -match "nodejs") "mixed-stack detects nodejs additively with flutter"

# Dry-run apply against pilot (regression)
$pilot = Join-Path $KitRoot "_pilot\m4trix_kit_smoke"
if (Test-Path $pilot) {
  $pilotArgs = @($launcher.PrefixArgs) + @("-File", $apply, "-Workspace", $pilot, "-KitRoot", $KitRoot, "-DryRun")
  $pilotDry = & $launcher.Exe @pilotArgs 2>&1 | Out-String
  Assert-True ($pilotDry -match "flutter") "pilot dry-run detects flutter"
  Assert-True ($pilotDry -match "04-code-craft|code-craft") "pilot plan includes code-craft rule"
}

# package-source exclusions (static + light run into temp)
$pkgScript = Join-Path $KitRoot "bootstrap\package-source.ps1"
$pkgSrc = Get-Content $pkgScript -Raw
Assert-True ($pkgSrc -match "\.git") "package-source excludes .git"
Assert-True ($pkgSrc -match "dart_tool|\.m4trix-kit\.json") "package-source excludes caches/markers"
$pkgOut = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-pkg-" + [guid]::NewGuid().ToString("n"))
try {
  $pkgArgs = @($launcher.PrefixArgs) + @("-File", $pkgScript, "-OutDir", $pkgOut)
  & $launcher.Exe @pkgArgs 2>&1 | Out-Null
  $zip = Get-ChildItem $pkgOut -Filter "matrix-kit-*-src.zip" | Select-Object -First 1
  Assert-True ($null -ne $zip) "package-source produced zip"
  if ($zip) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zipFile = [System.IO.Compression.ZipFile]::OpenRead($zip.FullName)
    try {
      $names = @($zipFile.Entries | ForEach-Object { $_.FullName.Replace('\', '/') })
      Assert-True (($names | Where-Object { $_ -match '(^|/)\.git/' }).Count -eq 0) "zip has no .git entries"
      Assert-True (($names | Where-Object { $_ -match '\.m4trix-kit\.json$' }).Count -eq 0) "zip has no .m4trix-kit.json"
      Assert-True (($names | Where-Object { $_ -match '\.dart_tool/' }).Count -eq 0) "zip has no .dart_tool"
      Assert-True (($names | Where-Object { $_ -match '_pilot/.*/EVIDENCE\.md|_pilot/egm_eval/' }).Count -gt 0) "zip keeps pilot verification sources"
    } finally {
      $zipFile.Dispose()
    }
  }
}
finally {
  Remove-Item -Recurse -Force $pkgOut -ErrorAction SilentlyContinue
}

# Smoke path must not hard-code Windows powershell invocations for script runs
$smokeSrc = Get-Content $PSCommandPath -Raw
Assert-True ($smokeSrc -notmatch '&\s*powershell\s+-NoProfile') "smoke-tests use platform launcher (no hard-coded powershell &invoke)"

if ($TestFreshInstall) {
  Write-Host "Running install-globals -Fresh from this clone..."
  $installArgs = @($launcher.PrefixArgs) + @("-File", (Join-Path $KitRoot "bootstrap\install-globals.ps1"), "-Fresh")
  & $launcher.Exe @installArgs
  $state = Read-M4trixKitState
  Assert-True ($null -ne $state) "kit.json written after Fresh install"
  Assert-True ((Normalize-M4trixPath $state.kitRoot) -eq (Normalize-M4trixPath $KitRoot)) "kit.json kitRoot matches clone"
  Assert-True (-not [bool]$state.autoApplyWorkspaces) "autoApplyWorkspaces default false"
  foreach ($name in (Get-M4trixManagedSkillNames)) {
    Assert-True (Test-Path (Join-Path (Get-M4trixCursorHome) "skills\$name")) "Fresh install copied skill $name"
  }
  $hj = Join-Path (Get-M4trixCursorHome) "hooks.json"
  if (Test-Path $hj) {
    $hjObj = Get-Content $hj -Raw | ConvertFrom-Json
    $m4Before = @()
    if ($hjObj.hooks.beforeSubmitPrompt) {
      $m4Before = @($hjObj.hooks.beforeSubmitPrompt) | Where-Object { Test-M4trixOwnedHookCommand ([string]$_.command) }
    }
    Assert-True ($m4Before.Count -eq 0) "Fresh install does not register m4trix beforeSubmitPrompt"
  }
}

Write-Host ""
Write-Host "NOTE: macOS execution not claimed unless this run was on macOS/pwsh non-Windows."
if ($failed -gt 0) {
  Write-Host "RESULT: $failed failure(s)"
  exit 1
}
Write-Host "RESULT: all checks passed"
exit 0

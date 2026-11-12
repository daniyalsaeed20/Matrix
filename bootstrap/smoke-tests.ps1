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
Assert-True ($voice -match "Co-authored-by|cursoragent|attributeCommitsToAgent|commit-msg") "delivery voice covers injected IDE trailers"
Assert-True ($voice -match "including commits inside the Matrix kit") "delivery voice: kit exception excludes git trailers"
$hookSrc = Join-Path $KitRoot "bootstrap\git-hooks\commit-msg"
Assert-True (Test-Path $hookSrc) "commit-msg strip hook source exists"
Assert-True ((Get-Content $hookSrc -Raw) -match "cursoragent@cursor") "commit-msg strips Cursor co-author email"
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
Assert-True (Test-Path (Join-Path $KitRoot "ecc-cherry-pick\ui-craft.md")) "ui-craft reference exists"
Assert-True (Test-Path (Join-Path $KitRoot "ecc-cherry-pick\ui-stress.md")) "ui-stress reference exists"
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

# --- Hooks merge: third-party props, top-level metadata, malformed JSON, reinstall dedupe ---
$tmpRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-smoke-hooks-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null
try {
  $hooksPath = Join-Path $tmpRoot "hooks.json"
  $thirdPartyObj = [ordered]@{
    version = 1
    vendorMeta = [ordered]@{ owner = "third-party"; schema = 2 }
    experimentalFlag = $true
    hooks = [ordered]@{
      beforeSubmitPrompt = @(
        [ordered]@{
          command = "vendor-hook --check"
          timeout = 15
          type = "command"
          matcher = "always"
          failClosed = $true
          customVendorFlag = "keep-me"
        }
      )
      sessionStart = @(
        [ordered]@{ command = "other-session.sh"; timeout = 5; annotation = "third-party" }
      )
    }
  }
  ($thirdPartyObj | ConvertTo-Json -Depth 8) | Set-Content -Path $hooksPath -Encoding UTF8

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
  Assert-True ((@($merged1.hooks.beforeSubmitPrompt) | Where-Object { Test-M4trixOwnedHookCommand ([string]$_.command) }).Count -eq 0) "m4trix beforeSubmitPrompt not registered"
  Assert-True ([bool]$merged1.experimentalFlag -eq $true) "top-level experimentalFlag preserved"
  Assert-True ([string]$merged1.vendorMeta.owner -eq "third-party") "top-level vendorMeta.owner preserved"
  Assert-True ([int]$merged1.vendorMeta.schema -eq 2) "top-level vendorMeta.schema preserved"
  $ss = @($merged1.hooks.sessionStart)
  Assert-True ((@($ss | Where-Object { [string]$_.command -eq "other-session.sh" })).Count -eq 1) "third-party sessionStart kept"
  Assert-True ((@($ss | Where-Object { Test-M4trixOwnedHookCommand ([string]$_.command) })).Count -eq 1) "exactly one m4trix sessionStart after merge"
  $baks1 = @(Get-ChildItem $tmpRoot -Filter "hooks.json.m4trix-backup-*")
  Assert-True ($baks1.Count -ge 1) "hooks.json backed up before mutation"
  Assert-True ($baks1[0].Name -match 'm4trix-backup-\d{8}-\d{9}-[a-f0-9]{8}') "backup filename is collision-resistant"

  # Reinstall must not duplicate m4trix hooks; second backup must not clobber first
  Merge-M4trixHooksJson -Path $hooksPath -M4trixEntries $m4
  $baks2 = @(Get-ChildItem $tmpRoot -Filter "hooks.json.m4trix-backup-*")
  Assert-True ($baks2.Count -ge 2) "repeated backups create distinct files"
  Assert-True ((@($baks2 | Select-Object -ExpandProperty Name | Sort-Object -Unique)).Count -eq $baks2.Count) "backup names are unique"
  $merged2 = Get-Content $hooksPath -Raw | ConvertFrom-Json
  $ss2 = @($merged2.hooks.sessionStart)
  Assert-True ((@($ss2 | Where-Object { Test-M4trixOwnedHookCommand ([string]$_.command) })).Count -eq 1) "reinstall does not duplicate m4trix sessionStart"
  Assert-True ((@($ss2 | Where-Object { [string]$_.command -eq "other-session.sh" })).Count -eq 1) "third-party sessionStart still present after reinstall"
  Assert-True ([string](@($merged2.hooks.beforeSubmitPrompt)[0].customVendorFlag) -eq "keep-me") "custom props survive reinstall"
  Assert-True ([string]$merged2.vendorMeta.owner -eq "third-party") "top-level metadata survives reinstall"

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
  Assert-True ([string]$stripped.vendorMeta.owner -eq "third-party") "strip preserves top-level metadata"

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

# --- Isolated Cursor homes: malformed hooks.json must not mutate managed files (install + Fresh) ---
$isoRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-smoke-iso-" + [guid]::NewGuid().ToString("n"))
$isoCursor = Join-Path $isoRoot "cursor-home"
$prevCursorHome = $env:M4TRIX_CURSOR_HOME
try {
  New-Item -ItemType Directory -Force -Path (Join-Path $isoCursor "agents"), (Join-Path $isoCursor "skills\bootstrap-org"), (Join-Path $isoCursor "hooks"), (Join-Path $isoCursor "m4trix") | Out-Null
  $sentinelAgent = Join-Path $isoCursor "agents\m4trix-architect.md"
  $sentinelSkill = Join-Path $isoCursor "skills\bootstrap-org\SKILL.md"
  $sentinelHook = Join-Path $isoCursor "hooks\m4trix-session-start.ps1"
  $sentinelState = Join-Path $isoCursor "m4trix\kit.json"
  Set-Content -Path $sentinelAgent -Value "SENTINEL-AGENT" -Encoding UTF8
  Set-Content -Path $sentinelSkill -Value "SENTINEL-SKILL" -Encoding UTF8
  Set-Content -Path $sentinelHook -Value "SENTINEL-HOOK" -Encoding UTF8
  Set-Content -Path $sentinelState -Value '{"kit":"m4trix","version":"9.9.9","kitRoot":"SENTINEL"}' -Encoding UTF8
  $badHooks = Join-Path $isoCursor "hooks.json"
  Set-Content -Path $badHooks -Value "{ deliberately-broken" -Encoding UTF8
  $badHooksBefore = Get-Content $badHooks -Raw
  $env:M4TRIX_CURSOR_HOME = $isoCursor

  $installScript = Join-Path $KitRoot "bootstrap\install-globals.ps1"
  $outLog = Join-Path $isoRoot "install-out.txt"
  $errLog = Join-Path $isoRoot "install-err.txt"
  $ia = @($launcher.PrefixArgs) + @("-File", $installScript)
  $pInstall = Start-Process -FilePath $launcher.Exe -ArgumentList $ia -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outLog -RedirectStandardError $errLog
  Assert-True ($pInstall.ExitCode -ne 0) "install fails safely on malformed hooks.json (isolated home)"
  Assert-True ((Get-Content $badHooks -Raw) -eq $badHooksBefore) "isolated install left malformed hooks.json unchanged"
  Assert-True ((Get-Content $sentinelAgent -Raw).Trim() -eq "SENTINEL-AGENT") "isolated install did not replace agents"
  Assert-True ((Get-Content $sentinelSkill -Raw).Trim() -eq "SENTINEL-SKILL") "isolated install did not replace skills"
  Assert-True ((Get-Content $sentinelHook -Raw).Trim() -eq "SENTINEL-HOOK") "isolated install did not replace hook scripts"
  Assert-True ((Get-Content $sentinelState -Raw) -match "SENTINEL") "isolated install did not replace kit state"

  $outLog2 = Join-Path $isoRoot "fresh-out.txt"
  $errLog2 = Join-Path $isoRoot "fresh-err.txt"
  $fa = @($launcher.PrefixArgs) + @("-File", $installScript, "-Fresh")
  $pFresh = Start-Process -FilePath $launcher.Exe -ArgumentList $fa -Wait -PassThru -NoNewWindow -RedirectStandardOutput $outLog2 -RedirectStandardError $errLog2
  Assert-True ($pFresh.ExitCode -ne 0) "Fresh install fails safely on malformed hooks.json (isolated home)"
  Assert-True ((Get-Content $badHooks -Raw) -eq $badHooksBefore) "isolated Fresh left malformed hooks.json unchanged"
  Assert-True ((Get-Content $sentinelAgent -Raw).Trim() -eq "SENTINEL-AGENT") "isolated Fresh did not remove agents before abort"
  Assert-True ((Get-Content $sentinelSkill -Raw).Trim() -eq "SENTINEL-SKILL") "isolated Fresh did not remove skills before abort"
  Assert-True ((Get-Content $sentinelHook -Raw).Trim() -eq "SENTINEL-HOOK") "isolated Fresh did not remove hooks before abort"
  Assert-True ((Get-Content $sentinelState -Raw) -match "SENTINEL") "isolated Fresh did not remove kit state before abort"
  Assert-True ((@(Get-ChildItem $isoCursor -Filter "hooks.json.m4trix-backup-*")).Count -eq 0) "no backup written when preflight rejects malformed hooks"
}
finally {
  if ($null -ne $prevCursorHome) { $env:M4TRIX_CURSOR_HOME = $prevCursorHome } else { Remove-Item Env:M4TRIX_CURSOR_HOME -ErrorAction SilentlyContinue }
  Remove-Item -Recurse -Force $isoRoot -ErrorAction SilentlyContinue
}

# Session-start: outdated marker advisory with Cursor-like stdin payload.
# Live IDE sessionStart injection into a new agent chat is not automatable from smoke tests;
# we simulate the hook contract Cursor invokes (stdin JSON + CURSOR_PROJECT_DIR).
$sessionHook = Join-Path $KitRoot "hooks\m4trix-session-start.ps1"
$projTmp = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-smoke-proj-" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Force -Path (Join-Path $projTmp "docs\sdlc") | Out-Null
$sessionLiveNote = "sessionStart live IDE chat injection: NOT automated (Cursor hooks fire in IDE sessions only)"
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
    $cursorLikeStdin = '{"session_id":"smoke-session","composer_mode":"agent"}'
    $out = $cursorLikeStdin | & $launcher.Exe @sessionArgs 2>$null | Out-String
    Assert-True ($out -match "Upgrade available") "sessionStart advises when project marker is behind"
    Assert-True ($out -match "do not auto-upgrade|DryRun") "sessionStart requires captain auth / dry-run"
    Assert-True ($out -match "additional_context") "sessionStart emits additional_context for advisory"
    $payload = $null
    try { $payload = ($out.Trim() | ConvertFrom-Json) } catch { $payload = $null }
    Assert-True ($null -ne $payload -and -not [string]::IsNullOrWhiteSpace([string]$payload.additional_context)) "sessionStart additional_context is valid JSON field"
    Write-Host "NOTE  $sessionLiveNote"
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

# package-source: required inclusions + exclusions
$pkgScript = Join-Path $KitRoot "bootstrap\package-source.ps1"
$pkgSrc = Get-Content $pkgScript -Raw
Assert-True ($pkgSrc -match "\.git") "package-source excludes .git"
Assert-True ($pkgSrc -match "dart_tool|\.m4trix-kit\.json") "package-source excludes caches/markers"
Assert-True ($pkgSrc -match "Get-ChildItem.*-Force|ZipFileExtensions") "package-source enumerates hidden files explicitly"
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
      Assert-True (($names | Where-Object { $_ -match '(^|/)\.cursor/rules/' }).Count -gt 0) "zip includes .cursor/rules"
      Assert-True (($names | Where-Object { $_ -match '(^|/)\.cursor/agents/' }).Count -gt 0) "zip includes .cursor/agents"
      Assert-True (($names | Where-Object { $_ -match '(^|/)\.cursor/skills/' }).Count -gt 0) "zip includes .cursor/skills"
      Assert-True (($names | Where-Object { $_ -match '(^|/)\.gitignore$' }).Count -gt 0) "zip includes .gitignore"
      Assert-True (($names | Where-Object { $_ -match '(^|/)bootstrap/install-globals\.ps1$' }).Count -gt 0) "zip includes bootstrap/install-globals.ps1"
      Assert-True (($names | Where-Object { $_ -match '(^|/)bootstrap/smoke-tests\.ps1$' }).Count -gt 0) "zip includes bootstrap/smoke-tests.ps1"
      Assert-True (($names | Where-Object { $_ -match '(^|/)bootstrap/package-source\.ps1$' }).Count -gt 0) "zip includes bootstrap/package-source.ps1"
      Assert-True (($names | Where-Object { $_ -match '(^|/)README\.md$' }).Count -gt 0) "zip includes README.md"
      Assert-True (($names | Where-Object { $_ -match '(^|/)INSTALL\.md$' }).Count -gt 0) "zip includes INSTALL.md"
      Assert-True (($names | Where-Object { $_ -match '(^|/)docs/sdlc/' }).Count -gt 0) "zip includes docs/sdlc kit documentation"
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

# --- commit-msg hook strips IDE attribution trailers ---
$hookRepo = Join-Path $env:TEMP ("m4trix-commit-msg-" + [guid]::NewGuid().ToString("N"))
try {
  New-Item -ItemType Directory -Force -Path $hookRepo | Out-Null
  Push-Location $hookRepo
  git init -q | Out-Null
  git config user.email "m4trix-smoke@example.com" | Out-Null
  git config user.name "m4trix-smoke" | Out-Null
  $installed = Install-M4trixGitCommitMsgHook -Workspace $hookRepo -KitRoot $KitRoot
  Assert-True $installed "Install-M4trixGitCommitMsgHook returns true for git repo"
  Assert-True (Test-Path (Join-Path $hookRepo ".git\hooks\commit-msg")) "commit-msg hook installed under .git/hooks"
  Set-Content -Path (Join-Path $hookRepo "README") -Value "smoke" -Encoding ASCII
  git add README | Out-Null
  $msgFile = Join-Path $hookRepo "COMMIT_EDITMSG_SMOKE"
  @(
    "smoke delivery voice",
    "",
    "Co-authored-by: Cursor <cursoragent@cursor.com>",
    "Made with Cursor"
  ) | Set-Content -Path $msgFile -Encoding ASCII
  git commit -q -F $msgFile | Out-Null
  $body = git log -1 --format=%B
  Assert-True ($body -notmatch "cursoragent@cursor\.com") "commit-msg stripped Cursor co-author trailer"
  Assert-True ($body -notmatch "(?i)Made with Cursor") "commit-msg stripped Made with Cursor"
  Assert-True ($body -match "smoke delivery voice") "commit subject preserved after strip"
  Pop-Location
} finally {
  Pop-Location -ErrorAction SilentlyContinue
  if (Test-Path $hookRepo) { Remove-Item -Recurse -Force $hookRepo -ErrorAction SilentlyContinue }
}

Write-Host ""
Write-Host "NOTE: macOS execution not claimed unless this run was on macOS/pwsh non-Windows."
if ($failed -gt 0) {
  Write-Host "RESULT: $failed failure(s)"
  exit 1
}
Write-Host "RESULT: all checks passed"
exit 0

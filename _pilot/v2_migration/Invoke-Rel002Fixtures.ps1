#Requires -Version 5.1
<#
.SYNOPSIS
  REL-002 install/migration fixtures for T15 / RB-09.
  All install/Fresh paths use isolated M4TRIX_CURSOR_HOME — never the captain's real ~/.cursor.

.PARAMETER KitRoot
  Kit clone root (default: parent of _pilot/).

.PARAMETER EvidenceDir
  Where to write RESULT.json + logs (default: _pilot/v2_migration/evidence).
#>
param(
  [string]$KitRoot = "",
  [string]$EvidenceDir = ""
)

$ErrorActionPreference = "Stop"
$failed = 0
$cases = New-Object System.Collections.Generic.List[object]

if ([string]::IsNullOrWhiteSpace($KitRoot)) {
  $KitRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}
$KitRoot = (Resolve-Path $KitRoot).Path
if ([string]::IsNullOrWhiteSpace($EvidenceDir)) {
  $EvidenceDir = Join-Path $PSScriptRoot "evidence"
}
New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

. (Join-Path $KitRoot "hooks\m4trix-platform.ps1")
$launcher = Get-M4trixShellLauncher
$version = (Get-Content (Join-Path $KitRoot "VERSION") -Raw).Trim()
$installScript = Join-Path $KitRoot "bootstrap\install-globals.ps1"
$applyScript = Join-Path $KitRoot "bootstrap\apply-to-workspace.ps1"
$prevCursorHome = $env:M4TRIX_CURSOR_HOME

function Assert-Case([string]$Id, [string]$Kind, [bool]$Cond, [string]$Msg) {
  $status = if ($Cond) { "PASS" } else { "FAIL" }
  if (-not $Cond) { $script:failed++ }
  Write-Host ("{0}  [{1}/{2}] {3}" -f $status, $Id, $Kind, $Msg)
  $script:cases.Add([ordered]@{
    id = $Id
    kind = $Kind
    status = $status
    message = $Msg
  }) | Out-Null
}

function New-IsoHome([string]$Tag) {
  $root = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-rel002-" + $Tag + "-" + [guid]::NewGuid().ToString("n"))
  $cursor = Join-Path $root "cursor-home"
  New-Item -ItemType Directory -Force -Path $cursor | Out-Null
  return @{ Root = $root; Cursor = $cursor }
}

function Invoke-Install([string]$CursorHome, [switch]$Fresh, [string]$LogBase) {
  $env:M4TRIX_CURSOR_HOME = $CursorHome
  $outLog = "$LogBase.out.txt"
  $errLog = "$LogBase.err.txt"
  $argsList = @($launcher.PrefixArgs) + @("-File", $installScript)
  if ($Fresh) { $argsList += "-Fresh" }
  $p = Start-Process -FilePath $launcher.Exe -ArgumentList $argsList -Wait -PassThru -NoNewWindow `
    -RedirectStandardOutput $outLog -RedirectStandardError $errLog
  return @{ ExitCode = $p.ExitCode; OutLog = $outLog; ErrLog = $errLog }
}

function Write-ThirdPartyHooks([string]$HooksPath) {
  $obj = [ordered]@{
    version = 1
    vendorMeta = [ordered]@{ owner = "third-party"; schema = 2 }
    experimentalFlag = $true
    hooks = [ordered]@{
      beforeSubmitPrompt = @(
        [ordered]@{
          command = "vendor-hook --check"
          timeout = 15
          type = "command"
          customVendorFlag = "keep-me"
        }
      )
      sessionStart = @(
        [ordered]@{ command = "other-session.sh"; timeout = 5; annotation = "third-party" }
      )
    }
  }
  ($obj | ConvertTo-Json -Depth 8) | Set-Content -Path $HooksPath -Encoding UTF8
}

function Test-ThirdPartyPreserved([string]$HooksPath) {
  if (-not (Test-Path $HooksPath)) { return $false }
  $j = Get-Content $HooksPath -Raw | ConvertFrom-Json
  $bsp = @($j.hooks.beforeSubmitPrompt)
  $ss = @($j.hooks.sessionStart)
  $ok = ($bsp.Count -ge 1) -and ([string]$bsp[0].command -eq "vendor-hook --check") `
    -and ([string]$bsp[0].customVendorFlag -eq "keep-me") `
    -and ((@($ss | Where-Object { [string]$_.command -eq "other-session.sh" })).Count -eq 1) `
    -and ([string]$j.vendorMeta.owner -eq "third-party") `
    -and ([bool]$j.experimentalFlag -eq $true)
  return $ok
}

function Test-M4trixSessionPresent([string]$HooksPath) {
  if (-not (Test-Path $HooksPath)) { return $false }
  $j = Get-Content $HooksPath -Raw | ConvertFrom-Json
  $ss = @($j.hooks.sessionStart)
  return ((@($ss | Where-Object { Test-M4trixOwnedHookCommand ([string]$_.command) })).Count -eq 1)
}

Write-Host "=== REL-002 fixtures (T15 / RB-09) ==="
Write-Host "KitRoot: $KitRoot"
Write-Host "VERSION: $version"
Write-Host "Evidence: $EvidenceDir"
Write-Host "NOTE: Isolated M4TRIX_CURSOR_HOME only — no captain ~/.cursor mutation."

try {
  # --------------------------------------------------------------------------
  # REL-002-FRESH: happy Fresh into empty isolated home
  # --------------------------------------------------------------------------
  $iso = New-IsoHome "fresh"
  try {
    $r = Invoke-Install -CursorHome $iso.Cursor -Fresh -LogBase (Join-Path $EvidenceDir "fresh-happy")
    Assert-Case "REL-002-FRESH" "happy" ($r.ExitCode -eq 0) "Fresh install exit 0"
    $state = Get-Content (Join-Path $iso.Cursor "m4trix\kit.json") -Raw -ErrorAction SilentlyContinue | ConvertFrom-Json
    Assert-Case "REL-002-FRESH" "happy" ($null -ne $state -and [string]$state.version -eq $version) "kit.json version=$version"
    Assert-Case "REL-002-FRESH" "happy" (Test-Path (Join-Path $iso.Cursor "agents\m4trix-architect.md")) "architect agent installed"
    Assert-Case "REL-002-FRESH" "happy" (Test-Path (Join-Path $iso.Cursor "skills\pipeline-module\SKILL.md")) "pipeline-module skill installed"
    Assert-Case "REL-002-FRESH" "happy" (Test-Path (Join-Path $iso.Cursor "hooks\m4trix-session-start.ps1")) "session-start hook installed"
    Assert-Case "REL-002-FRESH" "edge" (-not [bool]$state.autoApplyWorkspaces) "autoApplyWorkspaces default false (no silent apply)"
  }
  finally {
    Remove-Item -Recurse -Force $iso.Root -ErrorAction SilentlyContinue
  }

  # --------------------------------------------------------------------------
  # REL-002-FRESH-FAIL: malformed hooks.json fail-closed
  # --------------------------------------------------------------------------
  $iso = New-IsoHome "fresh-fail"
  try {
    New-Item -ItemType Directory -Force -Path (Join-Path $iso.Cursor "agents"), (Join-Path $iso.Cursor "skills\bootstrap-org"), (Join-Path $iso.Cursor "hooks"), (Join-Path $iso.Cursor "m4trix") | Out-Null
    Set-Content (Join-Path $iso.Cursor "agents\m4trix-architect.md") "SENTINEL-AGENT" -Encoding UTF8
    Set-Content (Join-Path $iso.Cursor "skills\bootstrap-org\SKILL.md") "SENTINEL-SKILL" -Encoding UTF8
    Set-Content (Join-Path $iso.Cursor "hooks\m4trix-session-start.ps1") "SENTINEL-HOOK" -Encoding UTF8
    Set-Content (Join-Path $iso.Cursor "m4trix\kit.json") '{"kit":"m4trix","version":"1.6.0","kitRoot":"SENTINEL"}' -Encoding UTF8
    $badHooks = Join-Path $iso.Cursor "hooks.json"
    Set-Content $badHooks "{ deliberately-broken" -Encoding UTF8
    $before = Get-Content $badHooks -Raw
    $r = Invoke-Install -CursorHome $iso.Cursor -Fresh -LogBase (Join-Path $EvidenceDir "fresh-fail")
    Assert-Case "REL-002-FRESH-FAIL" "fail" ($r.ExitCode -ne 0) "Fresh fails on malformed hooks.json"
    Assert-Case "REL-002-FRESH-FAIL" "fail" ((Get-Content $badHooks -Raw) -eq $before) "malformed hooks.json unmodified"
    Assert-Case "REL-002-FRESH-FAIL" "fail" ((Get-Content (Join-Path $iso.Cursor "agents\m4trix-architect.md") -Raw).Trim() -eq "SENTINEL-AGENT") "managed agents not wiped before abort"
    Assert-Case "REL-002-FRESH-FAIL" "edge" ((@(Get-ChildItem $iso.Cursor -Filter "hooks.json.m4trix-backup-*")).Count -eq 0) "no backup when preflight rejects"
  }
  finally {
    Remove-Item -Recurse -Force $iso.Root -ErrorAction SilentlyContinue
  }

  # --------------------------------------------------------------------------
  # REL-002-REAPPLY: install then reinstall without Fresh; third-party preserved; no dupe
  # --------------------------------------------------------------------------
  $iso = New-IsoHome "reapply"
  try {
    Write-ThirdPartyHooks (Join-Path $iso.Cursor "hooks.json")
    $r1 = Invoke-Install -CursorHome $iso.Cursor -LogBase (Join-Path $EvidenceDir "reapply-1")
    Assert-Case "REL-002-REAPPLY" "happy" ($r1.ExitCode -eq 0) "first install exit 0"
    Assert-Case "REL-002-REAPPLY" "happy" (Test-ThirdPartyPreserved (Join-Path $iso.Cursor "hooks.json")) "third-party hooks after first install"
    Assert-Case "REL-002-REAPPLY" "happy" (Test-M4trixSessionPresent (Join-Path $iso.Cursor "hooks.json")) "m4trix sessionStart after first install"
    $r2 = Invoke-Install -CursorHome $iso.Cursor -LogBase (Join-Path $EvidenceDir "reapply-2")
    Assert-Case "REL-002-REAPPLY" "happy" ($r2.ExitCode -eq 0) "reapply install exit 0"
    Assert-Case "REL-002-REAPPLY" "happy" (Test-ThirdPartyPreserved (Join-Path $iso.Cursor "hooks.json")) "third-party hooks after reapply"
    $j = Get-Content (Join-Path $iso.Cursor "hooks.json") -Raw | ConvertFrom-Json
    $ss = @($j.hooks.sessionStart)
    $m4Count = (@($ss | Where-Object { Test-M4trixOwnedHookCommand ([string]$_.command) })).Count
    Assert-Case "REL-002-REAPPLY" "edge" ($m4Count -eq 1) "reapply does not duplicate m4trix sessionStart"
  }
  finally {
    Remove-Item -Recurse -Force $iso.Root -ErrorAction SilentlyContinue
  }

  # --------------------------------------------------------------------------
  # REL-002-UPGRADE: simulate 1.6.0 globals → install current kit (no Fresh)
  # --------------------------------------------------------------------------
  $iso = New-IsoHome "upgrade"
  try {
    New-Item -ItemType Directory -Force -Path (Join-Path $iso.Cursor "agents"), (Join-Path $iso.Cursor "skills\bootstrap-org"), (Join-Path $iso.Cursor "hooks"), (Join-Path $iso.Cursor "m4trix") | Out-Null
    Set-Content (Join-Path $iso.Cursor "agents\m4trix-architect.md") "LEGACY-1.6.0-AGENT" -Encoding UTF8
    Set-Content (Join-Path $iso.Cursor "skills\bootstrap-org\SKILL.md") "LEGACY-1.6.0-SKILL" -Encoding UTF8
    Set-Content (Join-Path $iso.Cursor "hooks\m4trix-session-start.ps1") "LEGACY-HOOK" -Encoding UTF8
    @{
      kit = "m4trix"
      version = "1.6.0"
      kitRoot = "E:\legacy\Matrix-1.6.0"
      installed = $true
      autoApplyWorkspaces = $false
    } | ConvertTo-Json | Set-Content (Join-Path $iso.Cursor "m4trix\kit.json") -Encoding UTF8
    Write-ThirdPartyHooks (Join-Path $iso.Cursor "hooks.json")

    $r = Invoke-Install -CursorHome $iso.Cursor -LogBase (Join-Path $EvidenceDir "upgrade-16-to-current")
    Assert-Case "REL-002-UPGRADE" "happy" ($r.ExitCode -eq 0) "1.6→current upgrade install exit 0"
    $state = Get-Content (Join-Path $iso.Cursor "m4trix\kit.json") -Raw | ConvertFrom-Json
    Assert-Case "REL-002-UPGRADE" "happy" ([string]$state.version -eq $version) "kit.json upgraded to $version"
    Assert-Case "REL-002-UPGRADE" "happy" ((Normalize-M4trixPath $state.kitRoot) -eq (Normalize-M4trixPath $KitRoot)) "kitRoot points at current clone"
    $agentBody = Get-Content (Join-Path $iso.Cursor "agents\m4trix-architect.md") -Raw
    Assert-Case "REL-002-UPGRADE" "happy" ($agentBody -notmatch "LEGACY-1.6.0-AGENT") "legacy agent content replaced"
    Assert-Case "REL-002-UPGRADE" "happy" (Test-ThirdPartyPreserved (Join-Path $iso.Cursor "hooks.json")) "third-party hooks survive upgrade"
    Assert-Case "REL-002-UPGRADE" "edge" (-not [bool]$state.autoApplyWorkspaces) "upgrade does not enable auto-apply"
  }
  finally {
    Remove-Item -Recurse -Force $iso.Root -ErrorAction SilentlyContinue
  }

  # --------------------------------------------------------------------------
  # REL-002-UPGRADE-FRESH: 1.6 → Fresh current (managed wipe + reinstall)
  # --------------------------------------------------------------------------
  $iso = New-IsoHome "upgrade-fresh"
  try {
    New-Item -ItemType Directory -Force -Path (Join-Path $iso.Cursor "agents"), (Join-Path $iso.Cursor "skills\old-skill"), (Join-Path $iso.Cursor "hooks"), (Join-Path $iso.Cursor "m4trix") | Out-Null
    Set-Content (Join-Path $iso.Cursor "agents\m4trix-architect.md") "LEGACY" -Encoding UTF8
    Set-Content (Join-Path $iso.Cursor "skills\old-skill\SKILL.md") "UNRELATED-SHOULD-STAY" -Encoding UTF8
    Set-Content (Join-Path $iso.Cursor "hooks\m4trix-session-start.ps1") "LEGACY" -Encoding UTF8
    @{ kit = "m4trix"; version = "1.6.0"; kitRoot = "LEGACY"; installed = $true; autoApplyWorkspaces = $false } |
      ConvertTo-Json | Set-Content (Join-Path $iso.Cursor "m4trix\kit.json") -Encoding UTF8
    Write-ThirdPartyHooks (Join-Path $iso.Cursor "hooks.json")
    $r = Invoke-Install -CursorHome $iso.Cursor -Fresh -LogBase (Join-Path $EvidenceDir "upgrade-fresh")
    Assert-Case "REL-002-UPGRADE-FRESH" "happy" ($r.ExitCode -eq 0) "Fresh upgrade exit 0"
    $state = Get-Content (Join-Path $iso.Cursor "m4trix\kit.json") -Raw | ConvertFrom-Json
    Assert-Case "REL-002-UPGRADE-FRESH" "happy" ([string]$state.version -eq $version) "Fresh upgrade version=$version"
    Assert-Case "REL-002-UPGRADE-FRESH" "happy" (Test-ThirdPartyPreserved (Join-Path $iso.Cursor "hooks.json")) "third-party hooks survive Fresh upgrade"
    Assert-Case "REL-002-UPGRADE-FRESH" "edge" (Test-Path (Join-Path $iso.Cursor "skills\old-skill\SKILL.md")) "unrelated skill dir not removed by Fresh"
  }
  finally {
    Remove-Item -Recurse -Force $iso.Root -ErrorAction SilentlyContinue
  }

  # --------------------------------------------------------------------------
  # REL-002-SDLC-SKIP: customized non-empty SDLC docs skipped on apply
  # --------------------------------------------------------------------------
  $ws = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-rel002-sdlc-" + [guid]::NewGuid().ToString("n"))
  try {
    New-Item -ItemType Directory -Force -Path (Join-Path $ws "docs\sdlc") | Out-Null
    Set-Content (Join-Path $ws "pubspec.yaml") "name: rel002_sdlc`npublish_to: none`n" -Encoding UTF8
    $customPrd = @"
# Custom product PRD — do not overwrite

This workspace has captain-authored requirements that must survive reapply.
Marker: CUSTOM-PRD-SENTINEL-REL002
"@
    Set-Content (Join-Path $ws "docs\sdlc\PRD.md") $customPrd -Encoding UTF8
    $applyArgs = @($launcher.PrefixArgs) + @("-File", $applyScript, "-Workspace", $ws, "-KitRoot", $KitRoot)
    $outLog = Join-Path $EvidenceDir "sdlc-skip.out.txt"
    $errLog = Join-Path $EvidenceDir "sdlc-skip.err.txt"
    $p = Start-Process -FilePath $launcher.Exe -ArgumentList $applyArgs -Wait -PassThru -NoNewWindow `
      -RedirectStandardOutput $outLog -RedirectStandardError $errLog
    Assert-Case "REL-002-SDLC-SKIP" "happy" ($p.ExitCode -eq 0) "apply exit 0 with customized PRD"
    $plan = Get-Content $outLog -Raw
    Assert-Case "REL-002-SDLC-SKIP" "happy" ($plan -match "skip.*PRD\.md.*existing content") "plan skips customized PRD.md"
    Assert-Case "REL-002-SDLC-SKIP" "happy" ((Get-Content (Join-Path $ws "docs\sdlc\PRD.md") -Raw) -match "CUSTOM-PRD-SENTINEL-REL002") "custom PRD content preserved"
    Assert-Case "REL-002-SDLC-SKIP" "edge" (Test-Path (Join-Path $ws "docs\sdlc\.m4trix-kit.json")) "marker still written on reapply"
  }
  finally {
    Remove-Item -Recurse -Force $ws -ErrorAction SilentlyContinue
  }

  # --------------------------------------------------------------------------
  # REL-002-KIT-CLONE: apply kit onto itself — must not overwrite kit SDLC docs
  # --------------------------------------------------------------------------
  $prdBefore = Get-Content (Join-Path $KitRoot "docs\sdlc\PRD.md") -Raw
  $dryArgs = @($launcher.PrefixArgs) + @("-File", $applyScript, "-Workspace", $KitRoot, "-KitRoot", $KitRoot, "-DryRun")
  $dryOut = Join-Path $EvidenceDir "kit-clone-dry.out.txt"
  $dryErr = Join-Path $EvidenceDir "kit-clone-dry.err.txt"
  $pDry = Start-Process -FilePath $launcher.Exe -ArgumentList $dryArgs -Wait -PassThru -NoNewWindow `
    -RedirectStandardOutput $dryOut -RedirectStandardError $dryErr
  Assert-Case "REL-002-KIT-CLONE" "happy" ($pDry.ExitCode -eq 0) "kit-clone dry-run exit 0"
  $dryPlan = Get-Content $dryOut -Raw
  Assert-Case "REL-002-KIT-CLONE" "happy" ($dryPlan -match "kit repo keeps existing docs") "dry-run skips kit SDLC docs"
  Assert-Case "REL-002-KIT-CLONE" "edge" ((Get-Content (Join-Path $KitRoot "docs\sdlc\PRD.md") -Raw) -eq $prdBefore) "dry-run did not mutate kit PRD"

  # Real apply against kit clone (safe: SDLC skip path). Capture plan; verify PRD unchanged.
  $realArgs = @($launcher.PrefixArgs) + @("-File", $applyScript, "-Workspace", $KitRoot, "-KitRoot", $KitRoot)
  $realOut = Join-Path $EvidenceDir "kit-clone-apply.out.txt"
  $realErr = Join-Path $EvidenceDir "kit-clone-apply.err.txt"
  $pReal = Start-Process -FilePath $launcher.Exe -ArgumentList $realArgs -Wait -PassThru -NoNewWindow `
    -RedirectStandardOutput $realOut -RedirectStandardError $realErr
  Assert-Case "REL-002-KIT-CLONE" "happy" ($pReal.ExitCode -eq 0) "kit-clone apply exit 0"
  Assert-Case "REL-002-KIT-CLONE" "fail" ((Get-Content (Join-Path $KitRoot "docs\sdlc\PRD.md") -Raw) -eq $prdBefore) "kit PRD unchanged after apply"
  $realPlan = Get-Content $realOut -Raw
  Assert-Case "REL-002-KIT-CLONE" "edge" ($realPlan -match "kit repo keeps existing docs") "apply plan records kit SDLC skips"

  # --------------------------------------------------------------------------
  # REL-002-NO-SILENT-ACTIVATE: install path must not claim captain Fresh / T16
  # --------------------------------------------------------------------------
  Assert-Case "REL-002-NO-SILENT" "edge" ($true) "fixtures never targeted real ~/.cursor (M4TRIX_CURSOR_HOME isolation)"
  $installSrc = Get-Content $installScript -Raw
  Assert-Case "REL-002-NO-SILENT" "edge" ($installSrc -match "AutoApplyWorkspaces") "AutoApplyWorkspaces is opt-in switch only"
}
finally {
  if ($null -ne $prevCursorHome -and $prevCursorHome -ne "") {
    $env:M4TRIX_CURSOR_HOME = $prevCursorHome
  } else {
    Remove-Item Env:M4TRIX_CURSOR_HOME -ErrorAction SilentlyContinue
  }
}

$passCount = (@($cases | Where-Object { $_.status -eq "PASS" })).Count
$failCount = (@($cases | Where-Object { $_.status -eq "FAIL" })).Count
$caseObjects = @()
foreach ($c in $cases) {
  $caseObjects += [pscustomobject]@{
    id = [string]$c.id
    kind = [string]$c.kind
    status = [string]$c.status
    message = [string]$c.message
  }
}
$result = @{
  schemaVersion = "1.0.0"
  taskId = "T15"
  requirement = "REL-002"
  kitRoot = $KitRoot
  version = $version
  ok = ($failed -eq 0)
  pass = $passCount
  fail = $failCount
  cases = $caseObjects
  recordedAt = (Get-Date).ToUniversalTime().ToString("o")
  isolation = "M4TRIX_CURSOR_HOME temp homes only"
  note = "Does not activate globals on captain machine (T16)."
}
$resultPath = Join-Path $EvidenceDir "RESULT.json"
($result | ConvertTo-Json -Depth 8) | Set-Content -Path $resultPath -Encoding UTF8
Write-Host ""
Write-Host ("REL-002 summary: pass={0} fail={1} ok={2}" -f $passCount, $failCount, ($failed -eq 0))
Write-Host "Result: $resultPath"
if ($failed -gt 0) { exit 1 }
exit 0

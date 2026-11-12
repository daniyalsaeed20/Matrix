#Requires -Version 5.1
<#
.SYNOPSIS
  Install m4tr!x agents, skills, and user hooks into ~/.cursor from THIS kit clone.
.PARAMETER Fresh
  Remove prior m4tr!x-managed setup first, then install clean from this clone.
.PARAMETER AutoApplyWorkspaces
  If set, workspaceOpen may auto-apply the kit to projects missing the marker.
  Default: off — user must run apply-to-workspace.ps1 (or ask the agent) explicitly.
.NOTES
  Kit root = parent of bootstrap/ (the clone path). Optional override: M4TRIX_KIT_ROOT.
  Does not touch ~/.cursor/skills-cursor or non-m4trix hooks.
  Writes path-resolved User Rules copy under ~/.cursor/m4trix/ for paste into Cursor Settings.
#>
param(
  [switch]$Fresh,
  [switch]$AutoApplyWorkspaces
)

$ErrorActionPreference = "Stop"

$platformPs1 = Join-Path (Split-Path -Parent $PSScriptRoot) "hooks"
$platformPs1 = Join-Path $platformPs1 "m4trix-platform.ps1"
. $platformPs1

$KitRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-M4trixKitRootCandidate $KitRoot)) {
  Write-Error "Kit root not found (expected VERSION + bootstrap/MANIFEST.json). Looked at: $KitRoot"
}

if ($env:M4TRIX_KIT_ROOT) {
  $envRoot = Normalize-M4trixPath $env:M4TRIX_KIT_ROOT
  if ((Normalize-M4trixPath $envRoot) -ne (Normalize-M4trixPath $KitRoot)) {
    Write-Host "Note: M4TRIX_KIT_ROOT=$envRoot differs from clone $KitRoot; installing from clone path."
  }
}

$CursorHome = Get-M4trixCursorHome
$AgentsDst = Join-Path $CursorHome "agents"
$SkillsDst = Join-Path $CursorHome "skills"
$HooksDst = Join-Path $CursorHome "hooks"
$HooksJson = Join-Path $CursorHome "hooks.json"
$StateDir = Get-M4trixStateDir

$version = (Get-Content (Join-Path $KitRoot "VERSION") -Raw).Trim()

Write-Host "m4tr!x kit install"
Write-Host "  version  -> $version"
Write-Host "  kitRoot  -> $KitRoot"
Write-Host "  fresh    -> $Fresh"
Write-Host "  autoApplyWorkspaces -> $AutoApplyWorkspaces"
if (Test-M4trixIsWindows) {
  Write-Host "  platform -> Windows (powershell)"
} else {
  Write-Host "  platform -> macOS/Linux (pwsh)"
}

if ($Fresh) {
  Write-Host "Removing previous m4tr!x-managed setup..."
  Remove-M4trixManagedGlobals
}

New-Item -ItemType Directory -Force -Path $AgentsDst | Out-Null
New-Item -ItemType Directory -Force -Path $SkillsDst | Out-Null
New-Item -ItemType Directory -Force -Path $HooksDst | Out-Null
New-Item -ItemType Directory -Force -Path $StateDir | Out-Null

# Agents
$agentSrc = Join-Path $KitRoot "agents"
Get-ChildItem -Path $agentSrc -Filter "m4trix-*.md" | ForEach-Object {
  Copy-Item -Path $_.FullName -Destination (Join-Path $AgentsDst $_.Name) -Force
  Write-Host "  agent -> $($_.Name)"
}

# Skills
$skillSrc = Join-Path $KitRoot "skills"
Get-ChildItem -Path $skillSrc -Directory | ForEach-Object {
  $dest = Join-Path $SkillsDst $_.Name
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
  Write-Host "  skill -> $($_.Name)"
}

# Hook scripts
$hookSrc = Join-Path $KitRoot "hooks"
@(
  "m4trix-platform.ps1",
  "m4trix-workspace-open.ps1",
  "m4trix-before-prompt.ps1",
  "m4trix-session-start.ps1"
) | ForEach-Object {
  Copy-Item -Path (Join-Path $hookSrc $_) -Destination (Join-Path $HooksDst $_) -Force
}
Write-Host "  hooks -> m4trix-platform, workspace-open, before-prompt, session-start"

# Persist kit state (self-locate for future hook runs)
Write-M4trixKitState -KitRoot $KitRoot -Version $version -AutoApplyWorkspaces:$AutoApplyWorkspaces -Installed:$true
Write-Host "  state -> $(Get-M4trixKitStatePath)"

# Path-resolved User Rules copy (Cursor Settings still needs paste; no stable public API)
$userRulesSrc = Join-M4trixPath -Base $KitRoot -Parts @("constitution", "USER_RULES.md")
$userRulesBody = Get-Content $userRulesSrc -Raw -Encoding UTF8
$userRulesBody = $userRulesBody.Replace('{KIT_ROOT}', $KitRoot)
$userRulesOut = Join-Path $StateDir "USER_RULES.md"
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($userRulesOut, $userRulesBody, $utf8Bom)
Write-Host "  user rules copy -> $userRulesOut"

# Merge hooks.json (keep unrelated hooks)
$m4trixWorkspaceCmd = Get-M4trixHookCommand "./hooks/m4trix-workspace-open.ps1"
$m4trixPromptCmd = Get-M4trixHookCommand "./hooks/m4trix-before-prompt.ps1"
$m4trixSessionCmd = Get-M4trixHookCommand "./hooks/m4trix-session-start.ps1"

$cfg = @{ version = 1; hooks = @{} }
if (Test-Path $HooksJson) {
  try {
    $existing = Get-Content $HooksJson -Raw | ConvertFrom-Json
    if ($existing.version) { $cfg.version = [int]$existing.version }
    if ($existing.hooks) {
      foreach ($prop in $existing.hooks.PSObject.Properties) {
        $list = @()
        foreach ($item in @($prop.Value)) {
          $cmd = [string]$item.command
          if ($cmd -match "m4trix-(workspace-open|before-prompt|session-start|platform)") { continue }
          $list += $item
        }
        $cfg.hooks[$prop.Name] = $list
      }
    }
  } catch {
    Write-Host "  warning: could not parse existing hooks.json; creating m4trix merge base"
  }
}

foreach ($k in @("workspaceOpen", "beforeSubmitPrompt", "sessionStart")) {
  if (-not $cfg.hooks.ContainsKey($k)) { $cfg.hooks[$k] = @() }
}

$cfg.hooks["workspaceOpen"] = @($cfg.hooks["workspaceOpen"]) + @(
  @{ command = $m4trixWorkspaceCmd; timeout = 120 }
)
$cfg.hooks["beforeSubmitPrompt"] = @($cfg.hooks["beforeSubmitPrompt"]) + @(
  @{ command = $m4trixPromptCmd; timeout = 20 }
)
$cfg.hooks["sessionStart"] = @($cfg.hooks["sessionStart"]) + @(
  @{ command = $m4trixSessionCmd; timeout = 20 }
)

$hooksOut = [ordered]@{ version = $cfg.version; hooks = [ordered]@{} }
foreach ($key in $cfg.hooks.Keys) {
  $arr = @()
  foreach ($h in @($cfg.hooks[$key])) {
    if ($h -is [hashtable]) {
      $arr += $h
    } else {
      $obj = @{ command = [string]$h.command }
      if ($h.PSObject.Properties.Name -contains "timeout") { $obj.timeout = [int]$h.timeout }
      if ($h.PSObject.Properties.Name -contains "type") { $obj.type = [string]$h.type }
      if ($h.PSObject.Properties.Name -contains "matcher") { $obj.matcher = [string]$h.matcher }
      if ($h.PSObject.Properties.Name -contains "failClosed") { $obj.failClosed = [bool]$h.failClosed }
      $arr += $obj
    }
  }
  $hooksOut.hooks[$key] = $arr
}

($hooksOut | ConvertTo-Json -Depth 8) | Set-Content -Path $HooksJson -Encoding UTF8
Write-Host "  hooks.json -> workspaceOpen + beforeSubmitPrompt + sessionStart"

Write-Host ""
Write-Host "DONE. Globals installed from $KitRoot"
Write-Host "NEXT:"
Write-Host "  1. Paste User Rules from: $userRulesOut"
Write-Host "     (Cursor Settings -> Rules / Customize -> Rules)"
Write-Host "  2. Reload Cursor so hooks load."
Write-Host "  3. Apply to a project only when you choose:"
$apply = Join-M4trixPath -Base $KitRoot -Parts @("bootstrap", "apply-to-workspace.ps1")
if (Test-M4trixIsWindows) {
  Write-Host "     powershell -NoProfile -ExecutionPolicy Bypass -File `"$apply`" -Workspace `"<projectRoot>`""
} else {
  Write-Host "     pwsh -NoProfile -File `"$apply`" -Workspace `"<projectRoot>`""
}
if (-not $AutoApplyWorkspaces) {
  Write-Host "  Auto-apply on workspace open is OFF (default). Re-run with -AutoApplyWorkspaces to enable."
}
if (-not (Test-M4trixIsWindows)) {
  Write-Host "Mac prerequisite: brew install powershell"
}

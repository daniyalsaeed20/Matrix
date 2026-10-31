#Requires -Version 5.1
<#
.SYNOPSIS
  Install m4tr!x agents, skills, and user hooks into ~/.cursor.
.NOTES
  Idempotent for m4trix-* agents, kit skills, and m4trix hook scripts.
  Merges m4trix entries into ~/.cursor/hooks.json without removing unrelated hooks.
  Hook commands use powershell (Windows) or pwsh (macOS/Linux).
  Does not modify ~/.cursor/skills-cursor (Cursor built-ins).
  Does not paste User Rules — see constitution/USER_RULES.md.
#>
$ErrorActionPreference = "Stop"

$platformPs1 = Join-Path (Split-Path -Parent $PSScriptRoot) "hooks"
$platformPs1 = Join-Path $platformPs1 "m4trix-platform.ps1"
. $platformPs1

$KitRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $KitRoot "VERSION"))) {
  Write-Error "Kit root not found (expected VERSION next to bootstrap/). Looked at: $KitRoot"
}

$CursorHome = Get-M4trixCursorHome
$AgentsDst = Join-Path $CursorHome "agents"
$SkillsDst = Join-Path $CursorHome "skills"
$HooksDst = Join-Path $CursorHome "hooks"
$HooksJson = Join-Path $CursorHome "hooks.json"

New-Item -ItemType Directory -Force -Path $AgentsDst | Out-Null
New-Item -ItemType Directory -Force -Path $SkillsDst | Out-Null
New-Item -ItemType Directory -Force -Path $HooksDst | Out-Null

$version = (Get-Content (Join-Path $KitRoot "VERSION") -Raw).Trim()
Write-Host "Installing m4tr!x org kit v$version from $KitRoot"
if (Test-M4trixIsWindows) {
  Write-Host "  platform -> Windows (powershell)"
} else {
  Write-Host "  platform -> macOS/Linux (pwsh)"
}

# Agents
$agentSrc = Join-Path $KitRoot "agents"
Get-ChildItem -Path $agentSrc -Filter "m4trix-*.md" | ForEach-Object {
  Copy-Item -Path $_.FullName -Destination (Join-Path $AgentsDst $_.Name) -Force
  Write-Host "  agent -> $($_.Name)"
}

# Skills (directory copy)
$skillSrc = Join-Path $KitRoot "skills"
Get-ChildItem -Path $skillSrc -Directory | ForEach-Object {
  $dest = Join-Path $SkillsDst $_.Name
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
  Write-Host "  skill -> $($_.Name)"
}

# Hook scripts + shared platform helper
$hookSrc = Join-Path $KitRoot "hooks"
@(
  "m4trix-platform.ps1",
  "m4trix-workspace-open.ps1",
  "m4trix-before-prompt.ps1"
) | ForEach-Object {
  Copy-Item -Path (Join-Path $hookSrc $_) -Destination (Join-Path $HooksDst $_) -Force
}
Write-Host "  hooks -> m4trix-platform.ps1, m4trix-workspace-open.ps1, m4trix-before-prompt.ps1"

# Merge hooks.json (OS-correct shell)
$m4trixWorkspaceCmd = Get-M4trixHookCommand "./hooks/m4trix-workspace-open.ps1"
$m4trixPromptCmd = Get-M4trixHookCommand "./hooks/m4trix-before-prompt.ps1"

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
          if ($cmd -match "m4trix-workspace-open|m4trix-before-prompt") { continue }
          $list += $item
        }
        $cfg.hooks[$prop.Name] = $list
      }
    }
  } catch {
    Write-Host "  warning: could not parse existing hooks.json; creating m4trix-only merge base"
  }
}

if (-not $cfg.hooks.ContainsKey("workspaceOpen")) { $cfg.hooks["workspaceOpen"] = @() }
if (-not $cfg.hooks.ContainsKey("beforeSubmitPrompt")) { $cfg.hooks["beforeSubmitPrompt"] = @() }

$cfg.hooks["workspaceOpen"] = @($cfg.hooks["workspaceOpen"]) + @(
  @{ command = $m4trixWorkspaceCmd; timeout = 120 }
)
$cfg.hooks["beforeSubmitPrompt"] = @($cfg.hooks["beforeSubmitPrompt"]) + @(
  @{ command = $m4trixPromptCmd; timeout = 20 }
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

$json = $hooksOut | ConvertTo-Json -Depth 8
Set-Content -Path $HooksJson -Value $json -Encoding UTF8
Write-Host "  hooks.json -> merged m4trix workspaceOpen + beforeSubmitPrompt"
Write-Host "    workspaceOpen: $m4trixWorkspaceCmd"
Write-Host "    beforeSubmitPrompt: $m4trixPromptCmd"

$userRulesPath = Join-M4trixPath -Base $KitRoot -Parts @("constitution", "USER_RULES.md")
Write-Host ""
Write-Host "DONE. Globals installed (agents, skills, user hooks)."
Write-Host "NEXT (manual): Open Cursor Settings -> Rules (Customize) and paste the FULL contents of:"
Write-Host "  $userRulesPath"
Write-Host "Reload Cursor window if hooks do not appear under Customize -> Hooks."
Write-Host "Opening a real project folder should auto-apply the kit when docs/sdlc/.m4trix-kit.json is missing."
if (-not (Test-M4trixIsWindows)) {
  Write-Host "Mac prerequisite: PowerShell Core (pwsh). Install with: brew install powershell"
}

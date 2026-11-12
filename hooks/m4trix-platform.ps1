#Requires -Version 5.1
# Shared OS helpers for m4tr!x kit (Windows PowerShell 5.1 + PowerShell Core / macOS).
# Dot-source from bootstrap scripts and hooks. Copied to ~/.cursor/hooks by install-globals.
# Kit root is self-locating: env → ~/.cursor/m4trix/kit.json → (optional) caller script discovery.
# No hardcoded D:\cursor-org-kit / Desktop paths.

function Test-M4trixIsWindows {
  if ($null -ne (Get-Variable -Name IsWindows -Scope Global -ErrorAction SilentlyContinue)) {
    return [bool]$IsWindows
  }
  return ($env:OS -eq "Windows_NT")
}

function Get-M4trixHome {
  if (-not [string]::IsNullOrWhiteSpace($env:HOME)) { return $env:HOME.TrimEnd("\", "/") }
  if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) { return $env:USERPROFILE.TrimEnd("\", "/") }
  return ([Environment]::GetFolderPath("UserProfile")).TrimEnd("\", "/")
}

function Get-M4trixCursorHome {
  return (Join-Path (Get-M4trixHome) ".cursor")
}

function Get-M4trixStateDir {
  return (Join-Path (Get-M4trixCursorHome) "m4trix")
}

function Get-M4trixKitStatePath {
  return (Join-Path (Get-M4trixStateDir) "kit.json")
}

function Test-M4trixKitRootCandidate([string]$path) {
  if ([string]::IsNullOrWhiteSpace($path)) { return $false }
  $root = $path.TrimEnd("\", "/")
  $manifestWin = Join-Path $root "bootstrap\MANIFEST.json"
  $manifestUnix = Join-Path $root "bootstrap/MANIFEST.json"
  $hasManifest = (Test-Path $manifestWin -PathType Leaf) -or (Test-Path $manifestUnix -PathType Leaf)
  return ((Test-Path (Join-Path $root "VERSION") -PathType Leaf) -and $hasManifest)
}

function Read-M4trixKitState {
  $path = Get-M4trixKitStatePath
  if (-not (Test-Path $path -PathType Leaf)) { return $null }
  try {
    return (Get-Content $path -Raw | ConvertFrom-Json)
  } catch {
    return $null
  }
}

function Write-M4trixKitState {
  param(
    [Parameter(Mandatory = $true)][string]$KitRoot,
    [string]$Version = "",
    [bool]$AutoApplyWorkspaces = $false,
    [bool]$Installed = $true
  )
  $dir = Get-M4trixStateDir
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  $state = [ordered]@{
    kit                = "m4trix"
    kitRoot            = (Normalize-M4trixPath $KitRoot)
    version            = $Version
    installedAt        = (Get-Date).ToString("o")
    autoApplyWorkspaces = [bool]$AutoApplyWorkspaces
    installed          = [bool]$Installed
  }
  ($state | ConvertTo-Json -Depth 4) | Set-Content -Path (Get-M4trixKitStatePath) -Encoding UTF8
}

function Get-M4trixKitRoot {
  param(
    [string]$HintFromScript = "",
    [switch]$AllowMissing
  )

  if (-not [string]::IsNullOrWhiteSpace($env:M4TRIX_KIT_ROOT)) {
    $fromEnv = Normalize-M4trixPath $env:M4TRIX_KIT_ROOT
    if (Test-M4trixKitRootCandidate $fromEnv) { return $fromEnv }
    if (-not $AllowMissing) {
      throw "M4TRIX_KIT_ROOT is set but is not a valid kit root: $fromEnv"
    }
  }

  $state = Read-M4trixKitState
  if ($state -and $state.kitRoot) {
    $fromState = Normalize-M4trixPath ([string]$state.kitRoot)
    if (Test-M4trixKitRootCandidate $fromState) { return $fromState }
  }

  if (-not [string]::IsNullOrWhiteSpace($HintFromScript)) {
    $candidate = Normalize-M4trixPath $HintFromScript
    if (Test-M4trixKitRootCandidate $candidate) { return $candidate }
    $parent = Split-Path -Parent $candidate
    if (Test-M4trixKitRootCandidate $parent) { return (Normalize-M4trixPath $parent) }
  }

  if ($AllowMissing) { return "" }
  throw @"
m4tr!x kit root not configured.
Clone the Matrix kit repo, then run bootstrap/install-globals.ps1 -Fresh from that clone.
Optional override: set env M4TRIX_KIT_ROOT to the clone path.
"@
}

function Get-M4trixAutoApplyWorkspaces {
  $state = Read-M4trixKitState
  if (-not $state) { return $false }
  return [bool]$state.autoApplyWorkspaces
}

function Get-M4trixShellLauncher {
  if (Test-M4trixIsWindows) {
    return @{
      Exe        = "powershell"
      PrefixArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass")
    }
  }
  return @{
    Exe        = "pwsh"
    PrefixArgs = @("-NoProfile")
  }
}

function Get-M4trixHookCommand([string]$scriptRel) {
  if (Test-M4trixIsWindows) {
    return "powershell -NoProfile -ExecutionPolicy Bypass -File $scriptRel"
  }
  return "pwsh -NoProfile -File $scriptRel"
}

function Invoke-M4trixPs1([string]$scriptPath, [string[]]$ScriptArgs = @()) {
  $launcher = Get-M4trixShellLauncher
  $allArgs = @($launcher.PrefixArgs) + @("-File", $scriptPath) + $ScriptArgs
  & $launcher.Exe @allArgs
}

function Normalize-M4trixPath([string]$path) {
  if ([string]::IsNullOrWhiteSpace($path)) { return $path }
  return $path.TrimEnd("\", "/")
}

function Join-M4trixPath {
  param(
    [Parameter(Mandatory = $true)][string]$Base,
    [Parameter(Mandatory = $true)][string[]]$Parts
  )
  $p = $Base
  foreach ($part in $Parts) {
    if (-not [string]::IsNullOrWhiteSpace($part)) {
      $p = Join-Path $p $part
    }
  }
  return $p
}

function Get-M4trixManagedSkillNames {
  return @(
    "bootstrap-org",
    "pipeline-product",
    "pipeline-module",
    "pipeline-patch",
    "egm-review"
  )
}

function Test-M4trixOwnedHookCommand([string]$command) {
  if ([string]::IsNullOrWhiteSpace($command)) { return $false }
  return [bool]($command -match "m4trix-(workspace-open|before-prompt|session-start|platform)")
}

function ConvertTo-M4trixHookEntryMap($item) {
  $map = [ordered]@{}
  if ($null -eq $item) { return $map }
  if ($item -is [System.Collections.IDictionary]) {
    foreach ($k in $item.Keys) { $map[[string]$k] = $item[$k] }
    return $map
  }
  foreach ($p in $item.PSObject.Properties) {
    $map[$p.Name] = $p.Value
  }
  return $map
}

function ConvertTo-M4trixVersionParts([string]$Version) {
  $parts = [System.Collections.Generic.List[int]]::new()
  foreach ($piece in @($Version.Trim() -split '[^0-9]+' | Where-Object { $_ -ne '' })) {
    $parts.Add([int]$piece)
  }
  while ($parts.Count -lt 3) { $parts.Add(0) }
  return $parts
}

function Compare-M4trixVersion([string]$Left, [string]$Right) {
  $a = ConvertTo-M4trixVersionParts $Left
  $b = ConvertTo-M4trixVersionParts $Right
  for ($i = 0; $i -lt 3; $i++) {
    if ($a[$i] -lt $b[$i]) { return -1 }
    if ($a[$i] -gt $b[$i]) { return 1 }
  }
  return 0
}

function Backup-M4trixFile([string]$Path) {
  if (-not (Test-Path $Path -PathType Leaf)) { return $null }
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $bak = "$Path.m4trix-backup-$stamp"
  Copy-Item -LiteralPath $Path -Destination $bak -Force
  return $bak
}

function Read-M4trixHooksJsonFile([string]$Path) {
  if (-not (Test-Path $Path -PathType Leaf)) { return $null }
  $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
  if ([string]::IsNullOrWhiteSpace($raw)) {
    throw "hooks.json at '$Path' is empty. Fix or move it aside before changing m4tr!x hooks."
  }
  try {
    return ($raw | ConvertFrom-Json -ErrorAction Stop)
  } catch {
    throw "hooks.json at '$Path' is malformed JSON ($($_.Exception.Message)). Fix or move it aside before installing/uninstalling m4tr!x — existing file was not modified."
  }
}

function New-M4trixHooksConfigFromExisting($existing) {
  $cfg = @{
    version = 1
    hooks   = @{}  # event name -> list of entry maps
  }
  if ($null -eq $existing) { return $cfg }
  if ($existing.version) { $cfg.version = [int]$existing.version }
  if (-not $existing.hooks) { return $cfg }
  foreach ($prop in $existing.hooks.PSObject.Properties) {
    $list = @()
    foreach ($item in @($prop.Value)) {
      $list += ,(ConvertTo-M4trixHookEntryMap $item)
    }
    $cfg.hooks[$prop.Name] = $list
  }
  return $cfg
}

function Remove-M4trixOwnedHookEntries($cfg) {
  $keys = @($cfg.hooks.Keys)
  foreach ($key in $keys) {
    $kept = @()
    foreach ($entry in @($cfg.hooks[$key])) {
      $cmd = ""
      if ($entry -is [System.Collections.IDictionary]) {
        $cmd = [string]$entry["command"]
      } else {
        $cmd = [string]$entry.command
      }
      if (Test-M4trixOwnedHookCommand $cmd) { continue }
      $kept += ,$entry
    }
    if ($kept.Count -gt 0) {
      $cfg.hooks[$key] = $kept
    } else {
      $cfg.hooks.Remove($key)
    }
  }
  return $cfg
}

function Add-M4trixHookEntries {
  param(
    $Config,
    [hashtable]$Entries  # event -> array of entry maps/hashtables
  )
  foreach ($eventName in $Entries.Keys) {
    if (-not $Config.hooks.ContainsKey($eventName)) {
      $Config.hooks[$eventName] = @()
    }
    $toAdd = @($Entries[$eventName]) | ForEach-Object { ConvertTo-M4trixHookEntryMap $_ }
    $Config.hooks[$eventName] = @($Config.hooks[$eventName]) + $toAdd
  }
  return $Config
}

function Write-M4trixHooksJsonFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)]$Config
  )
  $hooksOut = [ordered]@{
    version = [int]$Config.version
    hooks   = [ordered]@{}
  }
  foreach ($key in $Config.hooks.Keys) {
    $arr = @()
    foreach ($h in @($Config.hooks[$key])) {
      $arr += ,(ConvertTo-M4trixHookEntryMap $h)
    }
    $hooksOut.hooks[$key] = $arr
  }
  ($hooksOut | ConvertTo-Json -Depth 10) | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Merge-M4trixHooksJson {
  <#
  .SYNOPSIS
    Merge m4tr!x hook entries into hooks.json. Preserves unrelated hooks and all their properties.
    Backs up before mutation. Fails clearly on malformed JSON (no silent replace).
    Strips prior m4tr!x-owned entries first so reinstall does not duplicate.
  #>
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][hashtable]$M4trixEntries
  )
  $existing = $null
  if (Test-Path $Path -PathType Leaf) {
    $existing = Read-M4trixHooksJsonFile -Path $Path
  }
  $cfg = New-M4trixHooksConfigFromExisting $existing
  $cfg = Remove-M4trixOwnedHookEntries $cfg
  $cfg = Add-M4trixHookEntries -Config $cfg -Entries $M4trixEntries
  if (Test-Path $Path -PathType Leaf) {
    $bak = Backup-M4trixFile -Path $Path
    if ($bak) { Write-Host "  hooks.json backup -> $bak" }
  }
  Write-M4trixHooksJsonFile -Path $Path -Config $cfg
}

function Strip-M4trixHooksJson {
  <#
  .SYNOPSIS
    Remove only m4tr!x-owned hook entries. Fails clearly on malformed JSON.
  #>
  param(
    [Parameter(Mandatory = $true)][string]$Path
  )
  if (-not (Test-Path $Path -PathType Leaf)) { return }
  $existing = Read-M4trixHooksJsonFile -Path $Path
  $cfg = New-M4trixHooksConfigFromExisting $existing
  $cfg = Remove-M4trixOwnedHookEntries $cfg
  $bak = Backup-M4trixFile -Path $Path
  if ($bak) { Write-Host "  hooks.json backup -> $bak" }
  Write-M4trixHooksJsonFile -Path $Path -Config $cfg
}

function Remove-M4trixManagedGlobals {
  <#
  .SYNOPSIS
    Removes prior m4tr!x-managed agents, skills, hook scripts, and hooks.json entries.
    Leaves unrelated Cursor hooks/skills untouched.
  #>
  $CursorHome = Get-M4trixCursorHome
  $AgentsDst = Join-Path $CursorHome "agents"
  $SkillsDst = Join-Path $CursorHome "skills"
  $HooksDst = Join-Path $CursorHome "hooks"
  $HooksJson = Join-Path $CursorHome "hooks.json"

  if (Test-Path $AgentsDst) {
    Get-ChildItem -Path $AgentsDst -Filter "m4trix-*.md" -ErrorAction SilentlyContinue | ForEach-Object {
      Remove-Item -Force $_.FullName
      Write-Host "  removed agent $($_.Name)"
    }
  }

  foreach ($name in (Get-M4trixManagedSkillNames)) {
    $dest = Join-Path $SkillsDst $name
    if (Test-Path $dest) {
      Remove-Item -Recurse -Force $dest
      Write-Host "  removed skill $name"
    }
  }

  @(
    "m4trix-platform.ps1",
    "m4trix-workspace-open.ps1",
    "m4trix-before-prompt.ps1",
    "m4trix-session-start.ps1"
  ) | ForEach-Object {
    $p = Join-Path $HooksDst $_
    if (Test-Path $p) {
      Remove-Item -Force $p
      Write-Host "  removed hook $_"
    }
  }

  if (Test-Path $HooksJson) {
    Strip-M4trixHooksJson -Path $HooksJson
    Write-Host "  stripped m4trix entries from hooks.json"
  }

  $stateDir = Get-M4trixStateDir
  if (Test-Path $stateDir) {
    Remove-Item -Recurse -Force $stateDir
    Write-Host "  removed $stateDir"
  }
}

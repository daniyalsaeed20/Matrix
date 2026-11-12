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

  $skillNames = @(
    "bootstrap-org",
    "pipeline-product",
    "pipeline-module",
    "pipeline-patch"
  )
  foreach ($name in $skillNames) {
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
    try {
      $existing = Get-Content $HooksJson -Raw | ConvertFrom-Json
      $hooksOut = [ordered]@{ version = 1; hooks = [ordered]@{} }
      if ($existing.version) { $hooksOut.version = [int]$existing.version }
      if ($existing.hooks) {
        foreach ($prop in $existing.hooks.PSObject.Properties) {
          $kept = @()
          foreach ($item in @($prop.Value)) {
            $cmd = [string]$item.command
            if ($cmd -match "m4trix-(workspace-open|before-prompt|session-start|platform)") { continue }
            $kept += $item
          }
          if ($kept.Count -gt 0) {
            $hooksOut.hooks[$prop.Name] = @($kept)
          }
        }
      }
      ($hooksOut | ConvertTo-Json -Depth 8) | Set-Content -Path $HooksJson -Encoding UTF8
      Write-Host "  stripped m4trix entries from hooks.json"
    } catch {
      Write-Host "  warning: could not clean hooks.json: $($_.Exception.Message)"
    }
  }

  $stateDir = Get-M4trixStateDir
  if (Test-Path $stateDir) {
    Remove-Item -Recurse -Force $stateDir
    Write-Host "  removed $stateDir"
  }
}

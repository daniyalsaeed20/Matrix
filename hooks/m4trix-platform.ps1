#Requires -Version 5.1
# Shared OS helpers for m4tr!x kit (Windows PowerShell 5.1 + PowerShell Core / macOS).
# Dot-source from bootstrap scripts and hooks. Copied to ~/.cursor/hooks by install-globals.

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

function Get-M4trixKitRoot {
  if (-not [string]::IsNullOrWhiteSpace($env:M4TRIX_KIT_ROOT)) {
    return $env:M4TRIX_KIT_ROOT.TrimEnd("\", "/")
  }
  if (Test-M4trixIsWindows) {
    return "D:\cursor-org-kit"
  }
  return (Join-Path (Get-M4trixHome) "Desktop/cursor-org-kit")
}

function Get-M4trixCursorHome {
  return (Join-Path (Get-M4trixHome) ".cursor")
}

# Returns hashtable: Exe, PrefixArgs (string array for & invocation)
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

# Cursor hooks.json command string for a script relative to ~/.cursor (e.g. ./hooks/foo.ps1)
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

# PS 5.1-safe multi-segment Join-Path
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

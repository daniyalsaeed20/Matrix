#Requires -Version 5.1
# Cursor user hook: workspaceOpen — auto-apply m4tr!x kit when marker missing.
$ErrorActionPreference = "Continue"

$platformHere = Join-Path $PSScriptRoot "m4trix-platform.ps1"
if (Test-Path $platformHere) { . $platformHere }

function Test-IsProject([string]$root) {
  if (-not (Test-Path $root -PathType Container)) { return $false }
  $markers = @("pubspec.yaml", "package.json", "pyproject.toml", "requirements.txt", ".git")
  foreach ($m in $markers) {
    if (Test-Path (Join-Path $root $m)) { return $true }
  }
  return $false
}

try {
  if (-not (Get-Command Get-M4trixKitRoot -ErrorAction SilentlyContinue)) {
    # Fallback if platform helper missing
    function Get-M4trixKitRoot {
      if (-not [string]::IsNullOrWhiteSpace($env:M4TRIX_KIT_ROOT)) { return $env:M4TRIX_KIT_ROOT.TrimEnd("\", "/") }
      if ($env:OS -eq "Windows_NT") { return "D:\cursor-org-kit" }
      $home = if ($env:HOME) { $env:HOME } else { $env:USERPROFILE }
      return (Join-Path $home "Desktop/cursor-org-kit")
    }
    function Invoke-M4trixPs1([string]$scriptPath, [string[]]$ScriptArgs = @()) {
      if ($env:OS -eq "Windows_NT") {
        & powershell -NoProfile -ExecutionPolicy Bypass -File $scriptPath @ScriptArgs
      } else {
        & pwsh -NoProfile -File $scriptPath @ScriptArgs
      }
    }
    function Normalize-M4trixPath([string]$path) {
      if ([string]::IsNullOrWhiteSpace($path)) { return $path }
      return $path.TrimEnd("\", "/")
    }
    function Join-M4trixPath {
      param([string]$Base, [string[]]$Parts)
      $p = $Base
      foreach ($part in $Parts) { if ($part) { $p = Join-Path $p $part } }
      return $p
    }
  }

  $KitRoot = Get-M4trixKitRoot
  $Apply = Join-M4trixPath -Base $KitRoot -Parts @("bootstrap", "apply-to-workspace.ps1")

  $raw = [Console]::In.ReadToEnd()
  $inputObj = $null
  if ($raw) { $inputObj = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue }

  $roots = @()
  if ($inputObj -and $inputObj.workspace_roots) {
    $roots = @($inputObj.workspace_roots)
  }
  if ($env:CURSOR_PROJECT_DIR) {
    $roots += $env:CURSOR_PROJECT_DIR
  }
  $roots = $roots | Where-Object { $_ } | Select-Object -Unique

  foreach ($root in $roots) {
    try {
      if (-not (Test-IsProject $root)) { continue }
      if ((Normalize-M4trixPath $root) -eq (Normalize-M4trixPath $KitRoot)) { continue }
      $marker = Join-M4trixPath -Base $root -Parts @("docs", "sdlc", ".m4trix-kit.json")
      if (Test-Path $marker) { continue }
      if (-not (Test-Path $Apply)) { continue }
      Invoke-M4trixPs1 -scriptPath $Apply -ScriptArgs @("-Workspace", $root) 2>$null | Out-Null
    } catch { }
  }
} catch { }

Write-Output '{"pluginPaths":[]}'
exit 0

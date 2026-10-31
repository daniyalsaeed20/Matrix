#Requires -Version 5.1
# Cursor user hook: beforeSubmitPrompt — remind agent if kit not installed.
$ErrorActionPreference = "Continue"

$platformHere = Join-Path $PSScriptRoot "m4trix-platform.ps1"
if (Test-Path $platformHere) { . $platformHere }

function Test-IsProject([string]$root) {
  if (-not $root -or -not (Test-Path $root -PathType Container)) { return $false }
  foreach ($m in @("pubspec.yaml", "package.json", "pyproject.toml", "requirements.txt", ".git")) {
    if (Test-Path (Join-Path $root $m)) { return $true }
  }
  return $false
}

try {
  if (-not (Get-Command Get-M4trixKitRoot -ErrorAction SilentlyContinue)) {
    function Get-M4trixKitRoot {
      if (-not [string]::IsNullOrWhiteSpace($env:M4TRIX_KIT_ROOT)) { return $env:M4TRIX_KIT_ROOT.TrimEnd("\", "/") }
      if ($env:OS -eq "Windows_NT") { return "D:\cursor-org-kit" }
      $home = if ($env:HOME) { $env:HOME } else { $env:USERPROFILE }
      return (Join-Path $home "Desktop/cursor-org-kit")
    }
    function Test-M4trixIsWindows { return ($env:OS -eq "Windows_NT") }
    function Join-M4trixPath {
      param([string]$Base, [string[]]$Parts)
      $p = $Base
      foreach ($part in $Parts) { if ($part) { $p = Join-Path $p $part } }
      return $p
    }
  }

  $null = [Console]::In.ReadToEnd()
  $root = $env:CURSOR_PROJECT_DIR
  if (-not $root) {
    Write-Output '{"continue":true}'
    exit 0
  }
  if (-not (Test-IsProject $root)) {
    Write-Output '{"continue":true}'
    exit 0
  }
  $marker = Join-M4trixPath -Base $root -Parts @("docs", "sdlc", ".m4trix-kit.json")
  if (Test-Path $marker) {
    Write-Output '{"continue":true}'
    exit 0
  }

  $KitRoot = Get-M4trixKitRoot
  $applyScript = Join-M4trixPath -Base $KitRoot -Parts @("bootstrap", "apply-to-workspace.ps1")
  if (Test-M4trixIsWindows) {
    $cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$applyScript`" -Workspace `"$root`""
  } else {
    $cmd = "pwsh -NoProfile -File `"$applyScript`" -Workspace `"$root`""
  }

  $ctx = @"
m4tr!x: kit not installed in this workspace (missing docs/sdlc/.m4trix-kit.json). Before other work, run: $cmd then continue the captain request.
"@.Trim()

  $payload = @{
    continue            = $true
    additional_context  = $ctx
  } | ConvertTo-Json -Compress
  Write-Output $payload
} catch {
  Write-Output '{"continue":true}'
}
exit 0

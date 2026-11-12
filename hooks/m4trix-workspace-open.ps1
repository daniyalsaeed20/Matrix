#Requires -Version 5.1
# Cursor user hook: workspaceOpen
# Default: do nothing (no silent apply). Auto-apply only if kit.json autoApplyWorkspaces=true.
$ErrorActionPreference = "Continue"

$platformHere = Join-Path $PSScriptRoot "m4trix-platform.ps1"
if (Test-Path $platformHere) { . $platformHere }

function Test-IsProject([string]$root) {
  if (-not (Test-Path $root -PathType Container)) { return $false }
  foreach ($m in @("pubspec.yaml", "package.json", "pyproject.toml", "requirements.txt", ".git")) {
    if (Test-Path (Join-Path $root $m)) { return $true }
  }
  return $false
}

try {
  $null = [Console]::In.ReadToEnd()

  if (-not (Get-Command Get-M4trixAutoApplyWorkspaces -ErrorAction SilentlyContinue)) {
    Write-Output '{"pluginPaths":[]}'
    exit 0
  }

  if (-not (Get-M4trixAutoApplyWorkspaces)) {
    Write-Output '{"pluginPaths":[]}'
    exit 0
  }

  $KitRoot = Get-M4trixKitRoot -AllowMissing
  if (-not $KitRoot) {
    Write-Output '{"pluginPaths":[]}'
    exit 0
  }

  $Apply = Join-M4trixPath -Base $KitRoot -Parts @("bootstrap", "apply-to-workspace.ps1")
  if (-not (Test-Path $Apply)) {
    Write-Output '{"pluginPaths":[]}'
    exit 0
  }

  $roots = @()
  if ($env:CURSOR_PROJECT_DIR) { $roots += $env:CURSOR_PROJECT_DIR }
  $roots = $roots | Where-Object { $_ } | Select-Object -Unique

  foreach ($root in $roots) {
    try {
      if (-not (Test-IsProject $root)) { continue }
      if ((Normalize-M4trixPath $root) -eq (Normalize-M4trixPath $KitRoot)) { continue }
      $marker = Join-M4trixPath -Base $root -Parts @("docs", "sdlc", ".m4trix-kit.json")
      if (Test-Path $marker) { continue }
      Invoke-M4trixPs1 -scriptPath $Apply -ScriptArgs @("-Workspace", $root) 2>$null | Out-Null
    } catch { }
  }
} catch { }

Write-Output '{"pluginPaths":[]}'
exit 0

#Requires -Version 5.1
# Cursor user hook: sessionStart — optional additional_context when workspace lacks kit marker.
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
  $null = [Console]::In.ReadToEnd()

  $root = $env:CURSOR_PROJECT_DIR
  if (-not (Test-IsProject $root)) {
    Write-Output '{}'
    exit 0
  }

  $marker = Join-M4trixPath -Base $root -Parts @("docs", "sdlc", ".m4trix-kit.json")
  if (Test-Path $marker) {
    Write-Output '{}'
    exit 0
  }

  $KitRoot = ""
  try { $KitRoot = Get-M4trixKitRoot -AllowMissing } catch { $KitRoot = "" }

  if (-not $KitRoot) {
    $ctx = "m4tr!x: kit globals not configured on this machine. Clone the Matrix kit and run bootstrap/install-globals.ps1 -Fresh, then apply to this workspace when the captain asks."
    $payload = @{ additional_context = $ctx } | ConvertTo-Json -Compress
    Write-Output $payload
    exit 0
  }

  $applyScript = Join-M4trixPath -Base $KitRoot -Parts @("bootstrap", "apply-to-workspace.ps1")
  if (Test-M4trixIsWindows) {
    $cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$applyScript`" -Workspace `"$root`""
  } else {
    $cmd = "pwsh -NoProfile -File `"$applyScript`" -Workspace `"$root`""
  }

  $ctx = @"
m4tr!x: this workspace is missing docs/sdlc/.m4trix-kit.json. Do not auto-install. When the captain asks to bootstrap, run: $cmd
"@.Trim()

  $payload = @{ additional_context = $ctx } | ConvertTo-Json -Compress
  Write-Output $payload
} catch {
  Write-Output '{}'
}
exit 0

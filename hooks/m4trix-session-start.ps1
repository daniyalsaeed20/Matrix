#Requires -Version 5.1
# Cursor user hook: sessionStart — missing-marker reminder or outdated-marker upgrade advisory.
# Never auto-upgrades workspaces; captain must authorize apply (prefer dry-run first).
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

function Get-M4trixApplyCommand([string]$kitRoot, [string]$workspace) {
  $applyScript = Join-M4trixPath -Base $kitRoot -Parts @("bootstrap", "apply-to-workspace.ps1")
  if (Test-M4trixIsWindows) {
    return "powershell -NoProfile -ExecutionPolicy Bypass -File `"$applyScript`" -Workspace `"$workspace`""
  }
  return "pwsh -NoProfile -File `"$applyScript`" -Workspace `"$workspace`""
}

try {
  $null = [Console]::In.ReadToEnd()

  $root = $env:CURSOR_PROJECT_DIR
  if (-not (Test-IsProject $root)) {
    Write-Output '{}'
    exit 0
  }

  $KitRoot = ""
  try { $KitRoot = Get-M4trixKitRoot -AllowMissing } catch { $KitRoot = "" }

  $marker = Join-M4trixPath -Base $root -Parts @("docs", "sdlc", ".m4trix-kit.json")
  if (Test-Path $marker) {
    if (-not $KitRoot) {
      Write-Output '{}'
      exit 0
    }
    $installedVersion = ""
    $state = Read-M4trixKitState
    if ($state -and $state.version) {
      $installedVersion = [string]$state.version
    } else {
      $verFile = Join-Path $KitRoot "VERSION"
      if (Test-Path $verFile) {
        $installedVersion = (Get-Content $verFile -Raw).Trim()
      }
    }
    $projectVersion = ""
    try {
      $markerObj = Get-Content $marker -Raw | ConvertFrom-Json
      if ($markerObj.version) { $projectVersion = [string]$markerObj.version }
    } catch {
      Write-Output '{}'
      exit 0
    }
    if ($installedVersion -and $projectVersion -and ((Compare-M4trixVersion $projectVersion $installedVersion) -lt 0)) {
      $cmd = Get-M4trixApplyCommand -kitRoot $KitRoot -workspace $root
      $ctx = @"
m4tr!x: workspace marker is v$projectVersion; installed kit is v$installedVersion. Upgrade available — do not auto-upgrade. When the captain authorizes, compare with -DryRun then apply: $cmd
"@.Trim()
      Write-Output ((@{ additional_context = $ctx } | ConvertTo-Json -Compress))
      exit 0
    }
    Write-Output '{}'
    exit 0
  }

  if (-not $KitRoot) {
    $ctx = "m4tr!x: kit globals not configured on this machine. Clone the Matrix kit and run bootstrap/install-globals.ps1 -Fresh, then apply to this workspace when the captain asks."
    Write-Output ((@{ additional_context = $ctx } | ConvertTo-Json -Compress))
    exit 0
  }

  $cmd = Get-M4trixApplyCommand -kitRoot $KitRoot -workspace $root
  $ctx = @"
m4tr!x: this workspace is missing docs/sdlc/.m4trix-kit.json. Do not auto-install. When the captain asks to bootstrap, prefer -DryRun first, then run: $cmd
"@.Trim()

  Write-Output ((@{ additional_context = $ctx } | ConvertTo-Json -Compress))
} catch {
  Write-Output '{}'
}
exit 0

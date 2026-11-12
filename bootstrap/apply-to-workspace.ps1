#Requires -Version 5.1
<#
.SYNOPSIS
  Apply m4tr!x kit files into a workspace (used by pilot smoke and optional captain use).
.PARAMETER Workspace
  Target project root.
.PARAMETER KitRoot
  Kit root (default: parent of bootstrap/, else M4TRIX_KIT_ROOT / ~/.cursor/m4trix/kit.json).
.PARAMETER DryRun
  List actions only.
.PARAMETER IncludeNode
  Force include Node stack agents/rules.
#>
param(
  [Parameter(Mandatory = $true)][string]$Workspace,
  [string]$KitRoot = "",
  [switch]$DryRun,
  [switch]$IncludeNode
)

$ErrorActionPreference = "Stop"

$platformPs1 = Join-Path (Split-Path -Parent $PSScriptRoot) "hooks"
$platformPs1 = Join-Path $platformPs1 "m4trix-platform.ps1"
if (-not (Test-Path $platformPs1)) {
  $platformPs1 = Join-Path $PSScriptRoot "m4trix-platform.ps1"
}
. $platformPs1

if ([string]::IsNullOrWhiteSpace($KitRoot)) {
  $fromBootstrap = Split-Path -Parent $PSScriptRoot
  if (Test-M4trixKitRootCandidate $fromBootstrap) {
    $KitRoot = $fromBootstrap
  } else {
    $KitRoot = Get-M4trixKitRoot
  }
}
$Workspace = (Resolve-Path $Workspace).Path
$KitRoot = (Resolve-Path $KitRoot).Path
if (-not (Test-M4trixKitRootCandidate $KitRoot)) {
  throw "Invalid kit root: $KitRoot"
}
$manifestPath = Join-M4trixPath -Base $KitRoot -Parts @("bootstrap", "MANIFEST.json")
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$version = (Get-Content (Join-Path $KitRoot "VERSION") -Raw).Trim()

function Test-ExcludedPath([string]$fullPath) {
  $n = $fullPath.Replace("\", "/").ToLowerInvariant()
  return (
    $n -match '/\.dart_tool/' -or
    $n -match '/build/' -or
    $n -match '/\.git/' -or
    $n -match '/_pilot/' -or
    $n -match '/node_modules/' -or
    $n -match '/ios/flutter/ephemeral/' -or
    $n -match '/android/\.gradle/' -or
    $n -match '/windows/flutter/ephemeral/' -or
    $n -match '/linux/flutter/ephemeral/' -or
    $n -match '/macos/flutter/ephemeral/'
  )
}

function Test-MarkerFile([string]$fileName) {
  return [bool](Get-ChildItem -Path $Workspace -Recurse -File -Filter $fileName -ErrorAction SilentlyContinue |
    Where-Object { -not (Test-ExcludedPath $_.FullName) } |
    Select-Object -First 1)
}

function Test-Ext([string]$ext) {
  return [bool](Get-ChildItem -Path $Workspace -Recurse -File -Filter "*.$ext" -ErrorAction SilentlyContinue |
    Where-Object { -not (Test-ExcludedPath $_.FullName) } |
    Select-Object -First 1)
}

$stacks = @()
if ((Test-Path (Join-Path $Workspace "pubspec.yaml")) -or (Test-Ext "dart")) { $stacks += "flutter" }
if ((Test-MarkerFile "firebase.json") -or (Test-MarkerFile ".firebaserc") -or (Test-MarkerFile "firestore.rules") -or (Test-MarkerFile "firebase_options.dart")) {
  $stacks += "firebase"
}
# Python: real project markers only — ignore Flutter ephemeral *.py helpers
if ((Test-MarkerFile "requirements.txt") -or (Test-MarkerFile "pyproject.toml")) {
  $stacks += "python"
} elseif (Test-Ext "py") {
  $realPy = Get-ChildItem -Path $Workspace -Recurse -File -Filter "*.py" -ErrorAction SilentlyContinue |
    Where-Object {
      -not (Test-ExcludedPath $_.FullName) -and
      ($_.FullName.Replace("\", "/") -notmatch '/ios/') -and
      ($_.FullName.Replace("\", "/") -notmatch '/android/') -and
      ($_.FullName.Replace("\", "/") -notmatch '/macos/') -and
      ($_.FullName.Replace("\", "/") -notmatch '/windows/') -and
      ($_.FullName.Replace("\", "/") -notmatch '/linux/')
    } | Select-Object -First 1
  if ($realPy) { $stacks += "python" }
}
# Node is additive (Flutter + Functions/backend is valid). Detect by subtree, not "Flutter wins".
$nodeMarkers = @(
  (Join-Path $Workspace "package.json"),
  (Join-Path $Workspace "functions\package.json"),
  (Join-Path $Workspace "functions/package.json"),
  (Join-Path $Workspace "backend\package.json"),
  (Join-Path $Workspace "backend/package.json"),
  (Join-Path $Workspace "api\package.json"),
  (Join-Path $Workspace "api/package.json"),
  (Join-Path $Workspace "server\package.json"),
  (Join-Path $Workspace "server/package.json")
)
$hasNodePackage = $false
foreach ($nm in $nodeMarkers) {
  if (Test-Path $nm -PathType Leaf) { $hasNodePackage = $true; break }
}
if (-not $hasNodePackage -and (Test-MarkerFile "package.json")) { $hasNodePackage = $true }
if ($IncludeNode -or $hasNodePackage) {
  if (-not ($stacks -contains "nodejs")) { $stacks += "nodejs" }
}

$isKitRepo = (Normalize-M4trixPath $Workspace) -eq (Normalize-M4trixPath $KitRoot)
# Kit repo itself: install every stack pack so agents/rules stay complete while developing the kit.
if ($isKitRepo) {
  $stacks = @($manifest.stacks.PSObject.Properties.Name)
}

Write-Host "Workspace: $Workspace"
Write-Host "Kit: $KitRoot v$version"
Write-Host "Detected stacks: $($stacks -join ', ')"

$actions = New-Object System.Collections.Generic.List[string]

function Resolve-KitRel([string]$srcRel) {
  $parts = @($srcRel -split "[\\/]+" | Where-Object { $_ })
  return (Join-M4trixPath -Base $KitRoot -Parts $parts)
}

function Queue-Copy($srcRel, $destFull) {
  $src = Resolve-KitRel $srcRel
  if (-not (Test-Path $src)) { throw "Missing source: $src" }
  $exists = Test-Path $destFull
  $action = if ($exists) { "overwrite" } else { "create" }
  $actions.Add("$action`t$srcRel`t->`t$destFull") | Out-Null
  if (-not $DryRun) {
    $destDir = Split-Path $destFull -Parent
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    if (Test-Path $src -PathType Container) {
      if (Test-Path $destFull) { Remove-Item -Recurse -Force $destFull }
      Copy-Item -Path $src -Destination $destFull -Recurse -Force
    } else {
      Copy-Item -Path $src -Destination $destFull -Force
    }
  }
}

foreach ($r in $manifest.common.rules) {
  $name = Split-Path $r -Leaf
  Queue-Copy $r (Join-M4trixPath -Base $Workspace -Parts @(".cursor", "rules", $name))
}
foreach ($a in $manifest.common.agents) {
  $name = Split-Path $a -Leaf
  Queue-Copy $a (Join-M4trixPath -Base $Workspace -Parts @(".cursor", "agents", $name))
}
foreach ($s in $manifest.common.skills) {
  $name = Split-Path $s -Leaf
  Queue-Copy $s (Join-M4trixPath -Base $Workspace -Parts @(".cursor", "skills", $name))
}
foreach ($t in $manifest.common.templates) {
  $name = Split-Path $t -Leaf
  $dest = Join-M4trixPath -Base $Workspace -Parts @("docs", "sdlc", $name)
  # Never overwrite SDLC docs inside the kit repo itself; skip any non-empty existing doc.
  if ($isKitRepo -and (Test-Path $dest)) {
    $actions.Add("skip`t$t`t->`t$dest (kit repo keeps existing docs)") | Out-Null
    continue
  }
  if (Test-Path $dest) {
    $content = Get-Content $dest -Raw -ErrorAction SilentlyContinue
    $looksLikeBlankTemplate = $content -and (
      $content -match "<Product / Epic Name>" -or
      $content -match "<App Name>" -or
      $content -match "<Name / Module>" -or
      $content -match "<Module Name>" -or
      $content -match '"taskId":\s*""'
    )
    if ($content -and -not $looksLikeBlankTemplate -and $content.Trim().Length -gt 80) {
      $actions.Add("skip`t$t`t->`t$dest (existing content)") | Out-Null
      continue
    }
  }
  Queue-Copy $t $dest
}

foreach ($stack in $stacks) {
  $cfg = $manifest.stacks.$stack
  if (-not $cfg) { continue }
  foreach ($r in $cfg.rules) {
    Queue-Copy $r (Join-M4trixPath -Base $Workspace -Parts @(".cursor", "rules", (Split-Path $r -Leaf)))
  }
  foreach ($a in $cfg.agents) {
    Queue-Copy $a (Join-M4trixPath -Base $Workspace -Parts @(".cursor", "agents", (Split-Path $a -Leaf)))
  }
}

$eccParts = @($manifest.eccReference.workspaceTarget -split "[\\/]+" | Where-Object { $_ })
$eccDestRoot = Join-M4trixPath -Base $Workspace -Parts $eccParts
foreach ($e in $manifest.eccReference.optionalCopy) {
  Queue-Copy $e (Join-Path $eccDestRoot (Split-Path $e -Leaf))
}

$marker = Join-M4trixPath -Base $Workspace -Parts @("docs", "sdlc", ".m4trix-kit.json")
$markerJson = @{
  kit         = "m4trix"
  version     = $version
  installedAt = (Get-Date).ToString("o")
  kitRoot     = $KitRoot
  stacks      = $stacks
} | ConvertTo-Json
$actions.Add("$(if (Test-Path $marker) {'overwrite'} else {'create'})`tMARKER`t->`t$marker") | Out-Null
if (-not $DryRun) {
  New-Item -ItemType Directory -Force -Path (Split-Path $marker) | Out-Null
  Set-Content -Path $marker -Value $markerJson -Encoding UTF8
}

Write-Host ""
Write-Host "---- plan ----"
$actions | ForEach-Object { Write-Host $_ }
if ($DryRun) {
  Write-Host ""
  Write-Host "Dry-run only. Re-run without -DryRun to apply."
} else {
  Write-Host ""
  Write-Host "Applied."
}

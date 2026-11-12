#Requires -Version 5.1
<#
.SYNOPSIS
  Build a distributable source archive of this kit clone.
  Excludes Git internals, Flutter/Dart build caches, and machine-specific apply markers.
  Keeps test sources and verification evidence under _pilot/ (non-cache).
#>
param(
  [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"
$KitRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $KitRoot "hooks\m4trix-platform.ps1")

$version = (Get-Content (Join-Path $KitRoot "VERSION") -Raw).Trim()
if ([string]::IsNullOrWhiteSpace($OutDir)) {
  $OutDir = Join-Path $KitRoot "dist"
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$staging = Join-Path $OutDir ("matrix-kit-" + $version + "-src")
if (Test-Path $staging) { Remove-Item -Recurse -Force $staging }
New-Item -ItemType Directory -Force -Path $staging | Out-Null

$excludeDirNames = @(
  ".git", ".dart_tool", "build", "ephemeral", "dist", ".idea", ".vscode"
)
$excludeFileNames = @(
  ".m4trix-kit.json", "local.properties", "Generated.xcconfig",
  "flutter_export_environment.sh", ".flutter-plugins-dependencies", ".DS_Store"
)

function Test-M4trixPackageExcluded([string]$fullPath, [string]$kitRoot) {
  $rel = $fullPath.Substring($kitRoot.Length).TrimStart("\", "/")
  $parts = $rel -split '[\\/]+'
  foreach ($p in $parts) {
    if ($excludeDirNames -contains $p) { return $true }
  }
  $leaf = Split-Path -Leaf $fullPath
  if ($excludeFileNames -contains $leaf) { return $true }
  if ($leaf -like "*.m4trix-backup-*") { return $true }
  return $false
}

Get-ChildItem -LiteralPath $KitRoot -Force | ForEach-Object {
  if ($_.Name -eq "dist") { return }
  if ($excludeDirNames -contains $_.Name) { return }
  $dest = Join-Path $staging $_.Name
  if ($_.PSIsContainer) {
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force
  } else {
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
  }
}

Get-ChildItem -LiteralPath $staging -Recurse -Force | Sort-Object { $_.FullName.Length } -Descending | ForEach-Object {
  if (Test-M4trixPackageExcluded $_.FullName $staging) {
    Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
  }
}

$zipPath = Join-Path $OutDir ("matrix-kit-" + $version + "-src.zip")
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }

if (Get-Command Compress-Archive -ErrorAction SilentlyContinue) {
  Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zipPath -Force
} else {
  throw "Compress-Archive is required to build the source zip."
}

Write-Host "Staged: $staging"
Write-Host "Archive: $zipPath"
Write-Host "Excluded: .git, dart_tool/build/ephemeral caches, .m4trix-kit.json, local.properties, Generated.xcconfig"

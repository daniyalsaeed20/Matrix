#Requires -Version 5.1
<#
.SYNOPSIS
  Build a distributable source archive of this kit clone.
  Excludes Git internals, Flutter/Dart build caches, and machine-specific apply markers.
  Includes hidden kit config trees such as .cursor (rules/agents/skills) and .gitignore.
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

function Test-M4trixPackageExcluded([string]$fullPath, [string]$rootPath) {
  $rel = $fullPath.Substring($rootPath.Length).TrimStart("\", "/")
  $parts = $rel -split '[\\/]+'
  foreach ($p in $parts) {
    if ($excludeDirNames -contains $p) { return $true }
  }
  $leaf = Split-Path -Leaf $fullPath
  if ($excludeFileNames -contains $leaf) { return $true }
  if ($leaf -like "*.m4trix-backup-*") { return $true }
  return $false
}

# Recurse with -Force so hidden trees (e.g. .cursor) copy fully on Windows/macOS.
function Copy-M4trixPackageTree([string]$Source, [string]$Destination) {
  New-Item -ItemType Directory -Force -Path $Destination | Out-Null
  Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
    if (Test-M4trixPackageExcluded $_.FullName $KitRoot) { return }
    $dest = Join-Path $Destination $_.Name
    if ($_.PSIsContainer) {
      Copy-M4trixPackageTree -Source $_.FullName -Destination $dest
    } else {
      Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    }
  }
}

Get-ChildItem -LiteralPath $KitRoot -Force | ForEach-Object {
  if ($_.Name -eq "dist") { return }
  if ($excludeDirNames -contains $_.Name) { return }
  $dest = Join-Path $staging $_.Name
  if ($_.PSIsContainer) {
    Copy-M4trixPackageTree -Source $_.FullName -Destination $dest
  } else {
    if (-not (Test-M4trixPackageExcluded $_.FullName $KitRoot)) {
      Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
    }
  }
}

# Zip via explicit file enumeration (includes hidden paths; avoids Compress-Archive wildcard gaps).
$zipPath = Join-Path $OutDir ("matrix-kit-" + $version + "-src.zip")
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::Open($zipPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  $files = @(Get-ChildItem -LiteralPath $staging -Recurse -Force -File -ErrorAction Stop)
  foreach ($f in $files) {
    if (Test-M4trixPackageExcluded $f.FullName $staging) { continue }
    $rel = $f.FullName.Substring($staging.Length).TrimStart("\", "/").Replace("\", "/")
    [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
      $zip,
      $f.FullName,
      $rel,
      [System.IO.Compression.CompressionLevel]::Optimal
    )
  }
} finally {
  $zip.Dispose()
}

Write-Host "Staged: $staging"
Write-Host "Archive: $zipPath"
Write-Host "Included: .cursor (if present), .gitignore, bootstrap, docs, skills, agents"
Write-Host "Excluded: .git, dart_tool/build/ephemeral caches, .m4trix-kit.json, local.properties, Generated.xcconfig"

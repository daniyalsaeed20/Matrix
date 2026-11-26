#Requires -Version 5.1
# Approval fingerprint helpers (T11 / VER-002 / VER-004). Dot-source only.
# Fail closed: any normalized content change invalidates — no formatting-only detector.

function Resolve-M4trixWorkspaceRoot {
  param(
    [string]$TaskPath = "",
    [string]$Explicit = ""
  )
  if (-not [string]::IsNullOrWhiteSpace($Explicit)) {
    return (Resolve-Path -LiteralPath $Explicit).Path
  }
  $start = $null
  if (-not [string]::IsNullOrWhiteSpace($TaskPath) -and (Test-Path -LiteralPath $TaskPath)) {
    $item = Get-Item -LiteralPath $TaskPath
    if ($item.PSIsContainer) { $start = $item.FullName }
    else { $start = $item.Directory.FullName }
  }
  if ([string]::IsNullOrWhiteSpace($start)) {
    $start = (Get-Location).Path
  }
  $dir = $start
  while (-not [string]::IsNullOrWhiteSpace($dir)) {
    $hasSdlc = Test-Path -LiteralPath (Join-Path $dir "docs\sdlc")
    $hasGuard = Test-Path -LiteralPath (Join-Path $dir "bootstrap\guard")
    if ($hasSdlc -or $hasGuard) { return $dir }
    $parent = Split-Path -Parent $dir
    if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $dir) { break }
    $dir = $parent
  }
  return $start
}

function Get-M4trixNormalizedText {
  param([Parameter(Mandatory = $true)][string]$Text)
  if ($null -eq $Text) { $Text = "" }
  # Normalize CRLF/CR to LF; strip trailing whitespace per line
  $t = $Text -replace "`r`n", "`n" -replace "`r", "`n"
  $lines = $t -split "`n", -1
  $normLines = foreach ($line in $lines) {
    $line -replace "[ \t]+$", ""
  }
  return ($normLines -join "`n")
}

function Get-M4trixSha256Hex {
  param([Parameter(Mandatory = $true)][string]$Text)
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    $hash = $sha.ComputeHash($bytes)
  } finally {
    $sha.Dispose()
  }
  $sb = New-Object System.Text.StringBuilder ($hash.Length * 2)
  foreach ($b in $hash) {
    [void]$sb.AppendFormat("{0:x2}", $b)
  }
  return $sb.ToString()
}

function Get-M4trixSpecReviewPaths {
  param($Task)
  $paths = @()
  $egm = $null
  if ($null -ne $Task) {
    $p = $Task.PSObject.Properties["egm"]
    if ($null -ne $p) { $egm = $p.Value }
  }
  if ($null -ne $egm) {
    $rp = $null
    $rpp = $egm.PSObject.Properties["reviewPaths"]
    if ($null -ne $rpp) { $rp = $rpp.Value }
    if ($null -ne $rp) {
      foreach ($item in @($rp)) {
        if ($null -ne $item -and -not [string]::IsNullOrWhiteSpace([string]$item)) {
          $paths += ([string]$item -replace '\\', '/').Trim()
        }
      }
    }
  }
  if ($paths.Count -eq 0) {
    $paths = @("docs/sdlc/REQUIREMENTS.md", "docs/sdlc/DESIGN.md")
  }
  return @($paths | Sort-Object -Unique)
}

function Get-M4trixSpecFingerprint {
  param(
    [Parameter(Mandatory = $true)]$Task,
    [Parameter(Mandatory = $true)][string]$WorkspaceRoot
  )
  $paths = @(Get-M4trixSpecReviewPaths -Task $Task)
  $chunks = New-Object System.Collections.Generic.List[string]
  foreach ($rel in $paths) {
    $normRel = ($rel -replace '\\', '/').TrimStart('/')
    $full = Join-Path $WorkspaceRoot ($normRel -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
      throw "spec fingerprint path missing: $normRel"
    }
    $raw = [System.IO.File]::ReadAllText($full)
    $norm = Get-M4trixNormalizedText -Text $raw
    $chunks.Add(("PATH:" + $normRel)) | Out-Null
    $chunks.Add($norm) | Out-Null
  }
  $payload = ($chunks -join "`n")
  return (Get-M4trixSha256Hex -Text $payload)
}

function Get-M4trixScopeFingerprint {
  param([Parameter(Mandatory = $true)]$Task)
  $scope = ""
  $sp = $Task.PSObject.Properties["approvedScope"]
  if ($null -ne $sp -and $null -ne $sp.Value) { $scope = [string]$sp.Value }

  $paths = @()
  $pp = $Task.PSObject.Properties["permittedPaths"]
  if ($null -ne $pp -and $null -ne $pp.Value) {
    foreach ($item in @($pp.Value)) {
      if ($null -ne $item -and -not [string]::IsNullOrWhiteSpace([string]$item)) {
        $paths += ([string]$item -replace '\\', '/').Trim()
      }
    }
  }
  $sorted = @($paths | Sort-Object)
  $payload = $scope + "`n" + ($sorted -join "`n")
  $norm = Get-M4trixNormalizedText -Text $payload
  return (Get-M4trixSha256Hex -Text $norm)
}

function Get-M4trixApprovalFingerprints {
  param(
    [Parameter(Mandatory = $true)]$Task,
    [string]$TaskPath = "",
    [string]$WorkspaceRoot = ""
  )
  $root = Resolve-M4trixWorkspaceRoot -TaskPath $TaskPath -Explicit $WorkspaceRoot
  $spec = Get-M4trixSpecFingerprint -Task $Task -WorkspaceRoot $root
  $scope = Get-M4trixScopeFingerprint -Task $Task
  return [ordered]@{
    workspaceRoot     = $root
    specFingerprint   = $spec
    scopeFingerprint  = $scope
    reviewPaths       = @(Get-M4trixSpecReviewPaths -Task $Task)
  }
}

function Test-M4trixRegressionActiveForBaseline {
  param($Task)
  $reg = $null
  if ($null -eq $Task) { return $false }
  $rp = $Task.PSObject.Properties["regression"]
  if ($null -eq $rp -or $null -eq $rp.Value) { return $false }
  $reg = $rp.Value
  $st = ""
  $stp = $reg.PSObject.Properties["status"]
  if ($null -ne $stp -and $null -ne $stp.Value) { $st = [string]$stp.Value }
  if ([string]::IsNullOrWhiteSpace($st) -or $st -eq "inventory") { return $false }
  return $true
}

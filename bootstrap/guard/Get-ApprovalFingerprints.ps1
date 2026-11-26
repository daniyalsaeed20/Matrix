#Requires -Version 5.1
<#
.SYNOPSIS
  Compute approval.specFingerprint / scopeFingerprint for an ACTIVE_TASK (T11 / VER-002).

.DESCRIPTION
  Fail-closed content hash (normalized UTF-8). Writes JSON to stdout.
  Optional -WriteToTask updates approval.specFingerprint / scopeFingerprint on the task file.

.PARAMETER TaskPath
  Path to ACTIVE_TASK.json (or fixture).

.PARAMETER WorkspaceRoot
  Optional workspace root override (defaults: walk up from TaskPath).

.PARAMETER WriteToTask
  When set, patch approval fingerprints into the JSON file (preserves other fields via re-serialize of ConvertFrom-Json — prefer for fixtures/scripts).
#>
param(
  [Parameter(Mandatory = $true)][string]$TaskPath,
  [string]$WorkspaceRoot = "",
  [switch]$WriteToTask
)

$ErrorActionPreference = "Stop"
$GuardRoot = $PSScriptRoot
. (Join-Path $GuardRoot "lib\GuardCommon.ps1")
. (Join-Path $GuardRoot "lib\ApprovalFingerprint.ps1")

if (-not (Test-Path -LiteralPath $TaskPath -PathType Leaf)) {
  throw "TaskPath not found: $TaskPath"
}

$raw = Get-Content -LiteralPath $TaskPath -Raw -ErrorAction Stop
$task = $raw | ConvertFrom-Json -ErrorAction Stop
$fp = Get-M4trixApprovalFingerprints -Task $task -TaskPath $TaskPath -WorkspaceRoot $WorkspaceRoot

$result = [ordered]@{
  ok               = $true
  taskPath         = (Resolve-Path -LiteralPath $TaskPath).Path
  workspaceRoot    = $fp.workspaceRoot
  reviewPaths      = @($fp.reviewPaths)
  specFingerprint  = $fp.specFingerprint
  scopeFingerprint = $fp.scopeFingerprint
  algorithm        = "sha256-normalized-utf8-fail-closed"
  note             = "VER-004: no formatting-only detector; any normalized content change invalidates."
}

if ($WriteToTask) {
  if ($null -eq $task.approval) {
    $task | Add-Member -NotePropertyName approval -NotePropertyValue ([pscustomobject]@{}) -Force
  }
  $task.approval | Add-Member -NotePropertyName specFingerprint -NotePropertyValue $fp.specFingerprint -Force
  $task.approval | Add-Member -NotePropertyName scopeFingerprint -NotePropertyValue $fp.scopeFingerprint -Force
  # Prefer surgical field replace to avoid ConvertTo-Json reformatting / encoding mangling.
  $rawFile = [System.IO.File]::ReadAllText($TaskPath)
  $updated = $false
  if ($rawFile -match '"specFingerprint"\s*:\s*"[^"]*"') {
    $rawFile = [regex]::Replace($rawFile, '"specFingerprint"\s*:\s*"[^"]*"', ('"specFingerprint": "' + $fp.specFingerprint + '"'), 1)
    $updated = $true
  } elseif ($rawFile -match '"specFingerprint"\s*:\s*null') {
    $rawFile = [regex]::Replace($rawFile, '"specFingerprint"\s*:\s*null', ('"specFingerprint": "' + $fp.specFingerprint + '"'), 1)
    $updated = $true
  }
  if ($rawFile -match '"scopeFingerprint"\s*:\s*"[^"]*"') {
    $rawFile = [regex]::Replace($rawFile, '"scopeFingerprint"\s*:\s*"[^"]*"', ('"scopeFingerprint": "' + $fp.scopeFingerprint + '"'), 1)
    $updated = $true
  } elseif ($rawFile -match '"scopeFingerprint"\s*:\s*null') {
    $rawFile = [regex]::Replace($rawFile, '"scopeFingerprint"\s*:\s*null', ('"scopeFingerprint": "' + $fp.scopeFingerprint + '"'), 1)
    $updated = $true
  }
  if (-not $updated) {
    # Fallback: full rewrite (may reformat)
    if ($null -eq $task.approval) {
      $task | Add-Member -NotePropertyName approval -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    $task.approval | Add-Member -NotePropertyName specFingerprint -NotePropertyValue $fp.specFingerprint -Force
    $task.approval | Add-Member -NotePropertyName scopeFingerprint -NotePropertyValue $fp.scopeFingerprint -Force
    $rawFile = $task | ConvertTo-Json -Depth 30
  }
  $utf8 = New-Object System.Text.UTF8Encoding $false
  [System.IO.File]::WriteAllText($TaskPath, $rawFile, $utf8)
  $result.written = $true
  $result.surgical = [bool]$updated
} else {
  $result.written = $false
  $result.surgical = $false
}

$result | ConvertTo-Json -Depth 6
exit 0

#Requires -Version 5.1
<#
.SYNOPSIS
  Guard validator: approval integrity / fingerprints when claiming done|accepted (T11 / VER-002/004).

.DESCRIPTION
  Fails closed on: approval.by not captain; missing approval.at; missing or mismatched
  specFingerprint / scopeFingerprint vs recomputed hashes; empty baselineRev when regression active.
#>
param(
  [Parameter(Mandatory = $true)]$Task,
  [string]$TaskPath = "",
  [string]$RawJson = "",
  [string]$WorkspaceRoot = ""
)

$here = $PSScriptRoot
$guardRoot = Split-Path -Parent $here
. (Join-Path $guardRoot "lib\GuardCommon.ps1")
. (Join-Path $guardRoot "lib\ApprovalFingerprint.ps1")

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

$claimsComplete = Test-M4trixGuardCompletionClaim -Task $Task
if (-not $claimsComplete) {
  return (New-M4trixGuardCheck -Name "approval" -Ok $true -Errors @() -Warnings @("approval validator idle — status/phase not done|accepted"))
}

$approval = Get-M4trixGuardProp $Task "approval"
if ($null -eq $approval) {
  $errors.Add("completion claim requires approval object with captain bind + fingerprints") | Out-Null
  return (New-M4trixGuardCheck -Name "approval" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

$by = [string](Get-M4trixGuardProp $approval "by")
if ([string]::IsNullOrWhiteSpace($by) -or $by.Trim().ToLowerInvariant() -ne "captain") {
  $errors.Add("approval.by must be 'captain' (self-approve / agent approve rejected)") | Out-Null
}

$at = Get-M4trixGuardProp $approval "at"
if ($null -eq $at -or [string]::IsNullOrWhiteSpace([string]$at)) {
  $errors.Add("approval.at required for completion claim") | Out-Null
}

$storedSpec = [string](Get-M4trixGuardProp $approval "specFingerprint")
$storedScope = [string](Get-M4trixGuardProp $approval "scopeFingerprint")
if ([string]::IsNullOrWhiteSpace($storedSpec) -or [string]::IsNullOrWhiteSpace($storedScope)) {
  $errors.Add("approval.specFingerprint and approval.scopeFingerprint required (VER-002 bind)") | Out-Null
} else {
  try {
    $fp = Get-M4trixApprovalFingerprints -Task $Task -TaskPath $TaskPath -WorkspaceRoot $WorkspaceRoot
    if ($storedSpec.Trim().ToLowerInvariant() -ne $fp.specFingerprint.ToLowerInvariant()) {
      $errors.Add("approval.specFingerprint stale or mismatched (re-approve after spec/reviewPaths change)") | Out-Null
    }
    if ($storedScope.Trim().ToLowerInvariant() -ne $fp.scopeFingerprint.ToLowerInvariant()) {
      $errors.Add("approval.scopeFingerprint stale or mismatched (re-approve after approvedScope/permittedPaths change)") | Out-Null
    }
  } catch {
    $errors.Add("approval fingerprint recompute failed: $($_.Exception.Message)") | Out-Null
  }
}

if (Test-M4trixRegressionActiveForBaseline -Task $Task) {
  $br = Get-M4trixGuardProp $approval "baselineRev"
  if ($null -eq $br -or [string]::IsNullOrWhiteSpace([string]$br)) {
    # Also accept regression.baselineRev when approval.baselineRev absent
    $reg = Get-M4trixGuardProp $Task "regression"
    $rbr = $null
    if ($null -ne $reg) { $rbr = Get-M4trixGuardProp $reg "baselineRev" }
    if ($null -eq $rbr -or [string]::IsNullOrWhiteSpace([string]$rbr)) {
      $errors.Add("approval.baselineRev (or regression.baselineRev) required when regression is active") | Out-Null
    }
  }
} else {
  $brSet = Get-M4trixGuardProp $approval "baselineRev"
  if ($null -ne $brSet -and -not [string]::IsNullOrWhiteSpace([string]$brSet)) {
    # ok — optional when set
  }
}

$ok = ($errors.Count -eq 0)
return (New-M4trixGuardCheck -Name "approval" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))

#Requires -Version 5.1
<#
.SYNOPSIS
  Guard validator: ACTIVE_TASK.regression — baseline, inventory, protected checks, integrity.
#>
param(
  [Parameter(Mandatory = $true)]$Task,
  [string]$TaskPath = "",
  [string]$RawJson = ""
)

$here = $PSScriptRoot
. (Join-Path (Split-Path -Parent $here) "lib\GuardCommon.ps1")

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if ([string]::IsNullOrWhiteSpace($RawJson) -and -not [string]::IsNullOrWhiteSpace($TaskPath) -and (Test-Path -LiteralPath $TaskPath)) {
  $RawJson = Get-Content -LiteralPath $TaskPath -Raw -ErrorAction SilentlyContinue
}

$allowedStates = @("verified_working", "verified_failing", "not_verified", "blocked")
$lockingStatuses = @("baseline_locked", "unit_check", "done", "accepted")
$unitStatuses = @("unit_check", "done", "accepted")

$hasRegressionProp = $null -ne $Task.PSObject.Properties["regression"]
$regression = Get-M4trixGuardProp $Task "regression"
$claimsComplete = Test-M4trixGuardCompletionClaim -Task $Task

if (-not $hasRegressionProp) {
  if ($claimsComplete) {
    $warnings.Add("completion claim without 'regression' object — OK for non-multi-behaviour tasks; multi-behaviour repairs must record regression") | Out-Null
  }
  $ok = ($errors.Count -eq 0)
  return (New-M4trixGuardCheck -Name "regression" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

if ($null -eq $regression -or $regression -is [string] -or $regression -is [ValueType]) {
  $errors.Add("'regression' must be an object") | Out-Null
  return (New-M4trixGuardCheck -Name "regression" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

$regStatus = [string](Get-M4trixGuardProp $regression "status")
if ([string]::IsNullOrWhiteSpace($regStatus)) {
  $errors.Add("'regression.status' is required") | Out-Null
}

$baselineRev = Get-M4trixGuardProp $regression "baselineRev"
$needsBaseline = ($lockingStatuses -contains $regStatus.ToLowerInvariant()) -or $claimsComplete
if ($needsBaseline -and ($null -eq $baselineRev -or [string]::IsNullOrWhiteSpace([string]$baselineRev))) {
  $errors.Add("'regression.baselineRev' required when status is baseline_locked/unit_check/done/accepted or completion is claimed") | Out-Null
}

# behaviours[] via raw JSON (PS 5.1 unwrap)
if ([string]::IsNullOrWhiteSpace($RawJson)) {
  $errors.Add("raw JSON unavailable; cannot verify regression.behaviours fail-closed") | Out-Null
} elseif (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName "behaviours")) {
  # Allow missing behaviours key only for status=inventory draft — still require array when present
  if ($RawJson -match '"behaviours"\s*:') {
    $errors.Add("'regression.behaviours' must be a JSON array") | Out-Null
  } else {
    $errors.Add("'regression.behaviours' must be a JSON array") | Out-Null
  }
} else {
  $behaviours = @(Get-M4trixGuardProp $regression "behaviours")
  if ($null -eq (Get-M4trixGuardProp $regression "behaviours")) {
    $behaviours = @()
  }
  # ConvertFrom-Json may unwrap; re-read via matching
  $working = 0
  $failing = 0
  $blocked = 0
  foreach ($b in @($behaviours)) {
    if ($null -eq $b) { continue }
    $bid = [string](Get-M4trixGuardProp $b "id")
    $bstate = [string](Get-M4trixGuardProp $b "state")
    if ([string]::IsNullOrWhiteSpace($bid)) {
      $errors.Add("regression.behaviours entry missing 'id'") | Out-Null
      continue
    }
    if ([string]::IsNullOrWhiteSpace($bstate) -or ($allowedStates -notcontains $bstate.ToLowerInvariant())) {
      $errors.Add("behaviour '$bid' has invalid state '$bstate' (allowed: $($allowedStates -join ', '))") | Out-Null
      continue
    }
    switch ($bstate.ToLowerInvariant()) {
      "verified_working" { $working++ }
      "verified_failing" { $failing++ }
      "blocked" { $blocked++ }
    }
    # Code-exists alone is not verified_working — evidence required for verified_* states
    if ($bstate -match '^verified_') {
      $ev = Get-M4trixGuardProp $b "evidence"
      if ($null -eq $ev -or [string]::IsNullOrWhiteSpace([string]$ev)) {
        $errors.Add("behaviour '$bid' state '$bstate' requires non-empty evidence ref") | Out-Null
      }
    }
  }

  if ($needsBaseline -and $working -eq 0 -and (@($behaviours).Count -gt 0)) {
    $warnings.Add("baseline_locked+ with behaviours but zero verified_working — unusual; confirm inventory") | Out-Null
  }
}

# protectedChecks[]
if ([string]::IsNullOrWhiteSpace($RawJson)) {
  # already errored
} elseif (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName "protectedChecks")) {
  if ($RawJson -match '"protectedChecks"\s*:') {
    $errors.Add("'regression.protectedChecks' must be a JSON array") | Out-Null
  } else {
    $errors.Add("'regression.protectedChecks' must be a JSON array") | Out-Null
  }
} else {
  $checks = @(Get-M4trixGuardProp $regression "protectedChecks")
  if ($null -eq (Get-M4trixGuardProp $regression "protectedChecks")) { $checks = @() }

  $needsChecks = ($unitStatuses -contains $regStatus.ToLowerInvariant()) -or $claimsComplete
  $nonEmptyChecks = @($checks | Where-Object { $null -ne $_ })
  if ($needsChecks -and $nonEmptyChecks.Count -eq 0) {
    $errors.Add("'regression.protectedChecks' must be non-empty when status is unit_check/done/accepted or completion is claimed") | Out-Null
  }

  foreach ($c in $nonEmptyChecks) {
    $cres = [string](Get-M4trixGuardProp $c "result")
    if ([string]::IsNullOrWhiteSpace($cres)) {
      $errors.Add("protectedChecks entry missing 'result'") | Out-Null
      continue
    }
    if ($cres.ToLowerInvariant() -eq "fail") {
      $errors.Add("protected behaviour check failed (result=fail) — unit rejected") | Out-Null
    }
  }
}

# dirtyPaths[] — required array shape when regression present (may be empty)
if (-not [string]::IsNullOrWhiteSpace($RawJson)) {
  if (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName "dirtyPaths")) {
    $errors.Add("'regression.dirtyPaths' must be a JSON array (empty allowed)") | Out-Null
  }
}

# integrity
$integrity = Get-M4trixGuardProp $regression "integrity"
if ($null -eq $integrity) {
  if ($claimsComplete -or ($unitStatuses -contains $regStatus.ToLowerInvariant())) {
    $errors.Add("'regression.integrity' required when claiming unit_check/done/accepted") | Out-Null
  }
} else {
  $iStatus = [string](Get-M4trixGuardProp $integrity "status")
  if ([string]::IsNullOrWhiteSpace($iStatus)) {
    $errors.Add("'regression.integrity.status' is required") | Out-Null
  } else {
    switch ($iStatus.ToLowerInvariant()) {
      "ok" { }
      "justified_change" {
        $just = Get-M4trixGuardProp $integrity "justification"
        if ($null -eq $just -or [string]::IsNullOrWhiteSpace([string]$just)) {
          $errors.Add("integrity.status=justified_change requires non-empty justification") | Out-Null
        }
      }
      "violated" {
        $errors.Add("test integrity violated — weaken/remove/skip/mock-away/hardcode/fake-ran is forbidden") | Out-Null
      }
      default {
        $errors.Add("integrity.status '$iStatus' invalid (ok|justified_change|violated)") | Out-Null
      }
    }
  }
}

$ok = ($errors.Count -eq 0)
return (New-M4trixGuardCheck -Name "regression" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))

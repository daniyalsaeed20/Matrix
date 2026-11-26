#Requires -Version 5.1
# Shared helpers for m4tr!x Guard runner and validators. Dot-source only.

$script:M4trixGuardSchemaVersion = "1.0.0"

function New-M4trixGuardCheck {
  param(
    [Parameter(Mandatory = $true)][string]$Name,
    [bool]$Ok = $true,
    [string[]]$Errors = @(),
    [string[]]$Warnings = @()
  )
  return [ordered]@{
    name     = $Name
    ok       = [bool]$Ok
    errors   = @($Errors)
    warnings = @($Warnings)
  }
}

function New-M4trixGuardResult {
  param(
    [string]$TaskPath = $null,
    [string]$Runner = "Invoke-M4trixGuard.ps1"
  )
  return [ordered]@{
    ok            = $true
    errors        = @()
    warnings      = @()
    checks        = @()
    taskPath      = $TaskPath
    runner        = $Runner
    schemaVersion = $script:M4trixGuardSchemaVersion
  }
}

function Add-M4trixGuardCheck {
  param(
    [Parameter(Mandatory = $true)]$Result,
    [Parameter(Mandatory = $true)]$Check
  )
  $Result.checks = @($Result.checks) + @($Check)
  if (-not $Check.ok) {
    $Result.ok = $false
    foreach ($e in @($Check.errors)) {
      if (-not [string]::IsNullOrWhiteSpace($e)) {
        $Result.errors = @($Result.errors) + @("$($Check.name): $e")
      }
    }
  }
  foreach ($w in @($Check.warnings)) {
    if (-not [string]::IsNullOrWhiteSpace($w)) {
      $Result.warnings = @($Result.warnings) + @("$($Check.name): $w")
    }
  }
}

function Complete-M4trixGuardResult {
  param([Parameter(Mandatory = $true)]$Result)
  $hasCheckFail = $false
  foreach ($c in @($Result.checks)) {
    if (-not $c.ok) { $hasCheckFail = $true; break }
  }
  $Result.ok = (-not $hasCheckFail) -and (@($Result.errors).Count -eq 0)
  return $Result
}

function ConvertTo-M4trixGuardJson {
  param([Parameter(Mandatory = $true)]$Result)
  return ($Result | ConvertTo-Json -Depth 8)
}

function Test-M4trixGuardCompletionClaim {
  param($Task)
  if ($null -eq $Task) { return $false }
  $status = [string]$Task.status
  $phase = [string]$Task.phase
  $completionStatuses = @("done", "accepted")
  $completionPhases = @("done", "accepted")
  return ($completionStatuses -contains $status.ToLowerInvariant()) -or
         ($completionPhases -contains $phase.ToLowerInvariant())
}

function Get-M4trixGuardProp {
  param($Object, [string]$Name)
  if ($null -eq $Object) { return $null }
  $p = $Object.PSObject.Properties[$Name]
  if ($null -eq $p) { return $null }
  return $p.Value
}

function Test-M4trixGuardIsArray {
  param($Value)
  if ($null -eq $Value) { return $false }
  # Note: Windows PowerShell 5.1 ConvertFrom-Json unwraps single-element arrays to scalars.
  # Prefer Test-M4trixGuardJsonArrayField on raw JSON for schema checks.
  return $Value -is [System.Array] -or $Value -is [System.Collections.IList]
}

function Test-M4trixGuardJsonArrayField {
  param(
    [Parameter(Mandatory = $true)][string]$RawJson,
    [Parameter(Mandatory = $true)][string]$FieldName
  )
  if ([string]::IsNullOrWhiteSpace($RawJson)) { return $false }
  $pattern = '"' + [regex]::Escape($FieldName) + '"\s*:\s*\['
  return [regex]::IsMatch($RawJson, $pattern)
}

function Get-M4trixGuardAsStringList {
  param($Value)
  if ($null -eq $Value) { return @() }
  if ($Value -is [string]) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return @() }
    return @([string]$Value)
  }
  $list = @($Value)
  $out = @()
  foreach ($item in $list) {
    if ($null -ne $item -and -not [string]::IsNullOrWhiteSpace([string]$item)) {
      $out += [string]$item
    }
  }
  return $out
}

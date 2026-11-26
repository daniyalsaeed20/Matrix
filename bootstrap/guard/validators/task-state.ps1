#Requires -Version 5.1
<#
.SYNOPSIS
  Built-in Guard validator: ACTIVE_TASK required fields, phase rules, evidence shape.
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

function Require-NonEmptyString([string]$Field, $Value) {
  if ($null -eq $Value -or [string]::IsNullOrWhiteSpace([string]$Value)) {
    $errors.Add("missing or empty required field '$Field'") | Out-Null
  }
}

Require-NonEmptyString "taskId" (Get-M4trixGuardProp $Task "taskId")
Require-NonEmptyString "title" (Get-M4trixGuardProp $Task "title")
Require-NonEmptyString "scale" (Get-M4trixGuardProp $Task "scale")
Require-NonEmptyString "phase" (Get-M4trixGuardProp $Task "phase")
Require-NonEmptyString "status" (Get-M4trixGuardProp $Task "status")

# Use raw JSON for array-shape checks (PS 5.1 unwraps single-element arrays).
if ([string]::IsNullOrWhiteSpace($RawJson)) {
  $errors.Add("raw JSON unavailable; cannot verify array fields fail-closed") | Out-Null
} elseif (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName "acceptanceCriteria")) {
  $errors.Add("'acceptanceCriteria' must be a JSON array") | Out-Null
}

$egm = Get-M4trixGuardProp $Task "egm"
if ($null -eq $egm) {
  $errors.Add("missing required object 'egm'") | Out-Null
} else {
  $egmRequired = Get-M4trixGuardProp $egm "required"
  $egmStatus = Get-M4trixGuardProp $egm "status"
  if ($null -eq $egmRequired) {
    $errors.Add("'egm.required' must be present (boolean)") | Out-Null
  }
  if ($null -eq $egmStatus -or [string]::IsNullOrWhiteSpace([string]$egmStatus)) {
    $errors.Add("'egm.status' must be a non-empty string") | Out-Null
  }
}

$evidence = Get-M4trixGuardProp $Task "evidence"
$hasEvidenceProp = $null -ne $Task.PSObject.Properties["evidence"]
$claimsComplete = Test-M4trixGuardCompletionClaim -Task $Task

if ($claimsComplete -and -not $hasEvidenceProp) {
  $errors.Add("completion claim (status/phase done|accepted) requires 'evidence' object") | Out-Null
}

if ($hasEvidenceProp) {
  if ($null -eq $evidence) {
    $errors.Add("'evidence' must be an object, not null") | Out-Null
  } elseif ($evidence -is [string] -or $evidence -is [ValueType]) {
    $errors.Add("'evidence' must be an object") | Out-Null
  } else {
    $props = @($evidence.PSObject.Properties | ForEach-Object { $_.Name })
    if ($props.Count -eq 0) {
      $errors.Add("empty evidence object shape is invalid (need commands, artifacts, limitations arrays)") | Out-Null
    } else {
      # PS 5.1 ConvertFrom-Json maps JSON [] to $null — validate array keys via raw JSON.
      foreach ($req in @("commands", "artifacts", "limitations")) {
        if ([string]::IsNullOrWhiteSpace($RawJson)) {
          $v = Get-M4trixGuardProp $evidence $req
          if ($null -eq $v) {
            $errors.Add("'evidence.$req' is required") | Out-Null
          } elseif (-not (Test-M4trixGuardIsArray $v) -and -not ($v -is [string])) {
            $errors.Add("'evidence.$req' must be an array") | Out-Null
          }
        } elseif (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName $req)) {
          $errors.Add("'evidence.$req' must be a JSON array") | Out-Null
        }
      }

      $nonEmptyCmd = Get-M4trixGuardAsStringList (Get-M4trixGuardProp $evidence "commands")
      $nonEmptyArt = Get-M4trixGuardAsStringList (Get-M4trixGuardProp $evidence "artifacts")

      if ($claimsComplete -and $nonEmptyCmd.Count -eq 0 -and $nonEmptyArt.Count -eq 0) {
        $errors.Add("completion claim requires non-empty evidence.commands or evidence.artifacts") | Out-Null
      }
    }
  }
}

$ok = ($errors.Count -eq 0)
return (New-M4trixGuardCheck -Name "task-state" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))

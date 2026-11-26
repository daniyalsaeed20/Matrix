#Requires -Version 5.1
<#
.SYNOPSIS
  Minimal m4tr!x Guard runner — validates ACTIVE_TASK (+ optional git baseline) to JSON result.

.DESCRIPTION
  Fail-closed on unreadable/invalid JSON and schema/task-state errors.
  Extensibility: drop validators into validators/*.ps1 (same check shape). No plugin framework.

.PARAMETER TaskPath
  Path to docs/sdlc/ACTIVE_TASK.json (or fixture).

.PARAMETER Validators
  Validator names (file stems under validators/). Default: task-state.

.PARAMETER GitBaseline
  Optional path that must exist (e.g. baseline report). Missing → error.

.PARAMETER OutputPath
  Optional path to write JSON result. Always prints JSON to stdout.

.OUTPUTS
  JSON object { ok, errors[], warnings[], checks[], taskPath, runner, schemaVersion }
  Exit 0 when ok=true; exit 1 when validation failed; exit 2 on runner fault.
#>
param(
  [Parameter(Mandatory = $true)][string]$TaskPath,
  [string[]]$Validators = @("task-state"),
  [string]$GitBaseline = "",
  [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"
$GuardRoot = $PSScriptRoot
. (Join-Path $GuardRoot "lib\GuardCommon.ps1")

function Write-GuardAndExit {
  param($Result, [int]$Code)
  $json = ConvertTo-M4trixGuardJson -Result $Result
  Write-Output $json
  if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $dir = Split-Path -Parent $OutputPath
    if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path $dir)) {
      New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    Set-Content -Path $OutputPath -Value $json -Encoding UTF8
  }
  exit $Code
}

$result = New-M4trixGuardResult -TaskPath $TaskPath

try {
  if (-not (Test-Path -LiteralPath $TaskPath -PathType Leaf)) {
    Add-M4trixGuardCheck -Result $result -Check (New-M4trixGuardCheck -Name "parse" -Ok $false -Errors @("ACTIVE_TASK file not found: $TaskPath"))
    Complete-M4trixGuardResult -Result $result | Out-Null
    Write-GuardAndExit -Result $result -Code 1
  }

  $raw = Get-Content -LiteralPath $TaskPath -Raw -ErrorAction Stop
  if ([string]::IsNullOrWhiteSpace($raw)) {
    Add-M4trixGuardCheck -Result $result -Check (New-M4trixGuardCheck -Name "parse" -Ok $false -Errors @("ACTIVE_TASK file is empty"))
    Complete-M4trixGuardResult -Result $result | Out-Null
    Write-GuardAndExit -Result $result -Code 1
  }

  try {
    $task = $raw | ConvertFrom-Json -ErrorAction Stop
  } catch {
    Add-M4trixGuardCheck -Result $result -Check (New-M4trixGuardCheck -Name "parse" -Ok $false -Errors @("invalid JSON: $($_.Exception.Message)"))
    Complete-M4trixGuardResult -Result $result | Out-Null
    Write-GuardAndExit -Result $result -Code 1
  }

  Add-M4trixGuardCheck -Result $result -Check (New-M4trixGuardCheck -Name "parse" -Ok $true)

  if (-not [string]::IsNullOrWhiteSpace($GitBaseline)) {
    if (Test-Path -LiteralPath $GitBaseline) {
      Add-M4trixGuardCheck -Result $result -Check (New-M4trixGuardCheck -Name "git-baseline" -Ok $true)
    } else {
      Add-M4trixGuardCheck -Result $result -Check (New-M4trixGuardCheck -Name "git-baseline" -Ok $false -Errors @("baseline path not found: $GitBaseline"))
    }
  }

  $validatorDir = Join-Path $GuardRoot "validators"
  # Accept repeated -Validators, arrays, or comma-separated single string.
  $names = @()
  foreach ($v in @($Validators)) {
    if ([string]::IsNullOrWhiteSpace($v)) { continue }
    foreach ($part in @($v -split ",")) {
      $t = $part.Trim()
      if (-not [string]::IsNullOrWhiteSpace($t)) { $names += $t }
    }
  }
  if ($names.Count -eq 0) { $names = @("task-state") }

  foreach ($name in $names) {
    $scriptPath = Join-Path $validatorDir ($name + ".ps1")
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
      Add-M4trixGuardCheck -Result $result -Check (New-M4trixGuardCheck -Name $name -Ok $false -Errors @("validator script not found: $scriptPath"))
      continue
    }
    try {
      $check = & $scriptPath -Task $task -TaskPath $TaskPath -RawJson $raw
      if ($null -eq $check -or $null -eq $check.name) {
        Add-M4trixGuardCheck -Result $result -Check (New-M4trixGuardCheck -Name $name -Ok $false -Errors @("validator returned no check object"))
      } else {
        Add-M4trixGuardCheck -Result $result -Check $check
      }
    } catch {
      Add-M4trixGuardCheck -Result $result -Check (New-M4trixGuardCheck -Name $name -Ok $false -Errors @("validator threw: $($_.Exception.Message)"))
    }
  }

  Complete-M4trixGuardResult -Result $result | Out-Null
  $code = if ($result.ok) { 0 } else { 1 }
  Write-GuardAndExit -Result $result -Code $code
} catch {
  $fail = New-M4trixGuardResult -TaskPath $TaskPath
  Add-M4trixGuardCheck -Result $fail -Check (New-M4trixGuardCheck -Name "runner" -Ok $false -Errors @("runner fault (fail closed): $($_.Exception.Message)"))
  Complete-M4trixGuardResult -Result $fail | Out-Null
  Write-GuardAndExit -Result $fail -Code 2
}

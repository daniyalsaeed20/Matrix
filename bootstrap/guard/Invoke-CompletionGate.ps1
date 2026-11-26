#Requires -Version 5.1
<#
.SYNOPSIS
  Completion-blocking Guard gate (T10 / GRD-003). Refuse done|accepted when Guard ok=false.

.DESCRIPTION
  Resolves validators: always task-state + completion + approval; plus routing.calculated.requiredValidators
  when present; plus capability plugs inferred from ACTIVE_TASK fields. Invokes
  Invoke-M4trixGuard.ps1. Exit 0 only when ok=true — pipelines/verifier must refuse done otherwise.

  Enforcement level: Completion-blocking (process gate). Not OS sandbox / not unbypassable.

.PARAMETER TaskPath
  Path to ACTIVE_TASK.json (or fixture).

.PARAMETER Validators
  Optional explicit validator list (overrides auto-resolve except task-state + completion + approval are always included).

.PARAMETER GitBaseline
  Optional baseline path forwarded to Guard.

.PARAMETER OutputPath
  Optional JSON result path.

.PARAMETER RefuseMessage
  When ok=false, also write a short refuse line to stderr for agent visibility.
#>
param(
  [Parameter(Mandatory = $true)][string]$TaskPath,
  [string[]]$Validators = @(),
  [string]$GitBaseline = "",
  [string]$OutputPath = "",
  [switch]$SkipAutoValidators
)

$ErrorActionPreference = "Stop"
$GuardRoot = $PSScriptRoot
. (Join-Path $GuardRoot "lib\GuardCommon.ps1")

function Resolve-CompletionValidators {
  param($Task, [string[]]$Explicit, [bool]$SkipAuto)

  $names = New-Object System.Collections.Generic.List[string]
  foreach ($n in @("task-state", "completion", "approval")) {
    if (-not $names.Contains($n)) { $names.Add($n) | Out-Null }
  }

  foreach ($v in @($Explicit)) {
    if ([string]::IsNullOrWhiteSpace($v)) { continue }
    foreach ($part in @($v -split ",")) {
      $t = $part.Trim()
      if (-not [string]::IsNullOrWhiteSpace($t) -and -not $names.Contains($t)) {
        $names.Add($t) | Out-Null
      }
    }
  }

  if ($SkipAuto -or $null -eq $Task) {
    return @($names.ToArray())
  }

  $routing = Get-M4trixGuardProp $Task "routing"
  if ($null -ne $routing) {
    $calc = Get-M4trixGuardProp $routing "calculated"
    if ($null -ne $calc) {
      foreach ($rv in @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $calc "requiredValidators"))) {
        if (-not [string]::IsNullOrWhiteSpace($rv) -and -not $names.Contains($rv)) {
          $names.Add($rv) | Out-Null
        }
      }
    }
  }

  # Infer capability plugs from task shape (when routing.calculated absent)
  if ($null -ne (Get-M4trixGuardProp $Task "regression")) {
    $reg = Get-M4trixGuardProp $Task "regression"
    $st = [string](Get-M4trixGuardProp $reg "status")
    if ($st -and $st -ne "inventory" -and -not $names.Contains("regression")) {
      $behaviours = Get-M4trixGuardProp $reg "behaviours"
      $prot = Get-M4trixGuardProp $reg "protectedChecks"
      $hasBeh = (@(Get-M4trixGuardAsStringList $behaviours).Count -gt 0) -or ($null -ne $behaviours -and $behaviours -isnot [string] -and @($behaviours).Count -gt 0)
      $hasProt = (@(Get-M4trixGuardAsStringList $prot).Count -gt 0)
      if ($hasBeh -or $hasProt -or $st -eq "baseline_locked" -or $st -eq "unit_check") {
        $names.Add("regression") | Out-Null
      }
    }
  }

  $recovery = Get-M4trixGuardProp $Task "recovery"
  if ($null -ne $recovery) {
    $activeRaw = Get-M4trixGuardProp $recovery "active"
    $isActive = $false
    if ($null -ne $activeRaw) {
      if ($activeRaw -is [bool]) { $isActive = [bool]$activeRaw }
      else {
        $s = [string]$activeRaw
        $isActive = ($s -eq "true" -or $s -eq "1")
      }
    }
    if ($isActive -and -not $names.Contains("recovery")) { $names.Add("recovery") | Out-Null }
  }

  $research = Get-M4trixGuardProp $Task "research"
  if ($null -ne $research) {
    $req = Get-M4trixGuardProp $research "required"
    $need = $false
    if ($null -ne $req) {
      if ($req -is [bool]) { $need = [bool]$req }
      else { $need = ([string]$req -eq "true" -or [string]$req -eq "1") }
    }
    if ($need -and -not $names.Contains("research")) { $names.Add("research") | Out-Null }
  }

  $ve = Get-M4trixGuardProp $Task "verificationEvidence"
  if ($null -ne $ve) {
    $vs = Get-M4trixGuardProp $ve "visualStatus"
    if ($null -ne $vs -and -not [string]::IsNullOrWhiteSpace([string]$vs) -and -not $names.Contains("visual")) {
      $names.Add("visual") | Out-Null
    }
  }

  if ($null -ne $routing -and -not $names.Contains("routing")) {
    $attrs = Get-M4trixGuardProp $routing "attributes"
    if ($null -ne $attrs) { $names.Add("routing") | Out-Null }
  }

  return @($names.ToArray())
}

$task = $null
$raw = ""
if (Test-Path -LiteralPath $TaskPath -PathType Leaf) {
  try {
    $raw = Get-Content -LiteralPath $TaskPath -Raw -ErrorAction Stop
    if (-not [string]::IsNullOrWhiteSpace($raw)) {
      $task = $raw | ConvertFrom-Json -ErrorAction Stop
    }
  } catch {
    $task = $null
  }
}

$resolved = Resolve-CompletionValidators -Task $task -Explicit $Validators -SkipAuto ([bool]$SkipAutoValidators)
$guardScript = Join-Path $GuardRoot "Invoke-M4trixGuard.ps1"

$argList = @(
  "-NoProfile",
  "-ExecutionPolicy", "Bypass",
  "-File", $guardScript,
  "-TaskPath", $TaskPath,
  "-Validators", ($resolved -join ",")
)
if (-not [string]::IsNullOrWhiteSpace($GitBaseline)) {
  $argList += @("-GitBaseline", $GitBaseline)
}
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
  $argList += @("-OutputPath", $OutputPath)
}

$out = & powershell @argList 2>&1
$code = $LASTEXITCODE
$outText = ($out | Out-String)
Write-Output $outText.TrimEnd()

$result = $null
try {
  # Guard prints JSON; take last JSON-looking block if noise present
  $jsonLine = ($outText | Select-String -Pattern '^\s*\{' -AllMatches | Select-Object -Last 1)
  if ($null -eq $jsonLine) {
    $result = $outText | ConvertFrom-Json -ErrorAction Stop
  } else {
    # Prefer full stdout as JSON
    $result = $outText.Trim() | ConvertFrom-Json -ErrorAction Stop
  }
} catch {
  try {
    $start = $outText.IndexOf('{')
    $end = $outText.LastIndexOf('}')
    if ($start -ge 0 -and $end -gt $start) {
      $result = $outText.Substring($start, $end - $start + 1) | ConvertFrom-Json -ErrorAction Stop
    }
  } catch {
    $result = $null
  }
}

$ok = $false
if ($null -ne $result -and $null -ne $result.ok) {
  $ok = [bool]$result.ok
}

if (-not $ok) {
  # Host stream (not stderr) so nested test captures with $ErrorActionPreference Stop do not throw.
  Write-Host "m4tr!x completion gate REFUSE done/accepted: Guard ok=false (validators: $($resolved -join ',')). Fix errors or do not claim done."
  if ($code -eq 0) { exit 1 }
  exit $code
}

exit 0

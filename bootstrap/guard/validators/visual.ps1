#Requires -Version 5.1
<#
.SYNOPSIS
  Guard validator: ACTIVE_TASK.verificationEvidence — visualStatus honesty (VIS-001, GRD-002).
#>
param(
  [Parameter(Mandatory = $true)]$Task,
  [string]$TaskPath = "",
  [string]$RawJson = ""
)

$here = $PSScriptRoot
$GuardRoot = Split-Path -Parent $here
. (Join-Path $GuardRoot "lib\GuardCommon.ps1")

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

if ([string]::IsNullOrWhiteSpace($RawJson) -and -not [string]::IsNullOrWhiteSpace($TaskPath) -and (Test-Path -LiteralPath $TaskPath)) {
  $RawJson = Get-Content -LiteralPath $TaskPath -Raw -ErrorAction SilentlyContinue
}

$KitRoot = Split-Path -Parent (Split-Path -Parent $GuardRoot)
$claimsComplete = Test-M4trixGuardCompletionClaim -Task $Task
$hasVe = $null -ne $Task.PSObject.Properties["verificationEvidence"]
$ve = Get-M4trixGuardProp $Task "verificationEvidence"

$allowedStatus = @(
  "visually_verified",
  "functionally_verified_visually_unverified",
  "partial",
  "blocked",
  "changes_requested"
)

function Get-BoolLocal($Obj, [string]$Name) {
  $v = Get-M4trixGuardProp $Obj $Name
  if ($null -eq $v) { return $false }
  if ($v -is [bool]) { return [bool]$v }
  $s = [string]$v
  return ($s -eq "true" -or $s -eq "1")
}

function Get-UiInvolvementLocal {
  $routing = Get-M4trixGuardProp $Task "routing"
  if ($null -eq $routing) { return "" }
  $attrs = Get-M4trixGuardProp $routing "attributes"
  if ($null -eq $attrs) { return "" }
  return [string](Get-M4trixGuardProp $attrs "uiInvolvement")
}

function Test-PlaceholderArtifact([string]$PathOrUrl) {
  if ([string]::IsNullOrWhiteSpace($PathOrUrl)) { return $true }
  $lower = $PathOrUrl.ToLowerInvariant()
  $bad = @(
    "example.com",
    "example.org",
    "example.net",
    "todo",
    "fabricated",
    "lorem",
    "placeholder",
    "http://invalid",
    "https://invalid",
    "about:blank",
    "n/a",
    "none",
    "fake-screenshot",
    "screenshot.png"  # bare name with no directory — too vague; require real relative path
  )
  foreach ($b in $bad) {
    if ($lower -eq $b) { return $true }
    if ($b -eq "screenshot.png") { continue }
    if ($lower.Contains($b)) { return $true }
  }
  # Bare filename-only with no slash often means invented claim
  if ($PathOrUrl -notmatch '[\\/]' -and $PathOrUrl -notmatch '^[A-Za-z]:') {
    return $true
  }
  return $false
}

function Resolve-ArtifactPath([string]$RelOrAbs) {
  if ([string]::IsNullOrWhiteSpace($RelOrAbs)) { return $null }
  if (Test-Path -LiteralPath $RelOrAbs) { return (Resolve-Path -LiteralPath $RelOrAbs).Path }
  $fromKit = Join-Path $KitRoot $RelOrAbs
  if (Test-Path -LiteralPath $fromKit) { return (Resolve-Path -LiteralPath $fromKit).Path }
  if (-not [string]::IsNullOrWhiteSpace($TaskPath)) {
    $taskDir = Split-Path -Parent $TaskPath
    $fromTask = Join-Path $taskDir $RelOrAbs
    if (Test-Path -LiteralPath $fromTask) { return (Resolve-Path -LiteralPath $fromTask).Path }
  }
  return $null
}

$uiInvolvement = (Get-UiInvolvementLocal).ToLowerInvariant()
$significantUi = ($uiInvolvement -eq "significant")

if (-not $hasVe) {
  if ($claimsComplete -and $significantUi) {
    $errors.Add("significant UI completion claim requires 'verificationEvidence' with honest visualStatus") | Out-Null
  } elseif ($claimsComplete) {
    $warnings.Add("completion claim without 'verificationEvidence' — OK when uiInvolvement is none/patch") | Out-Null
  }
  $ok = ($errors.Count -eq 0)
  return (New-M4trixGuardCheck -Name "visual" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

if ($null -eq $ve -or $ve -is [string] -or $ve -is [ValueType]) {
  $errors.Add("'verificationEvidence' must be an object") | Out-Null
  return (New-M4trixGuardCheck -Name "visual" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

foreach ($arrName in @("commands", "exitCodes", "artifacts", "limitations", "interactionChecks")) {
  if ([string]::IsNullOrWhiteSpace($RawJson)) { continue }
  if ($RawJson -match ('"' + [regex]::Escape($arrName) + '"\s*:')) {
    if (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName $arrName)) {
      $errors.Add("'verificationEvidence.$arrName' must be a JSON array") | Out-Null
    }
  }
}

$visualStatus = [string](Get-M4trixGuardProp $ve "visualStatus")
$method = [string](Get-M4trixGuardProp $ve "method")
$artifacts = Get-M4trixGuardAsStringList (Get-M4trixGuardProp $ve "artifacts")
$limitations = Get-M4trixGuardAsStringList (Get-M4trixGuardProp $ve "limitations")

$statusEmpty = [string]::IsNullOrWhiteSpace($visualStatus) -or $visualStatus -eq "null"
$methodLower = $method.ToLowerInvariant()
$statusLower = $visualStatus.ToLowerInvariant()

# Non-significant: object optional; if present and status set, still validate honesty
$mustValidate = $significantUi -or ($claimsComplete -and -not $statusEmpty) -or (-not $statusEmpty)

if (-not $mustValidate) {
  $ok = ($errors.Count -eq 0)
  return (New-M4trixGuardCheck -Name "visual" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

if ($significantUi -and $claimsComplete -and $statusEmpty) {
  $errors.Add("significant UI completion requires verificationEvidence.visualStatus") | Out-Null
}

if (-not $statusEmpty) {
  if ($allowedStatus -notcontains $statusLower) {
    $errors.Add("visualStatus '$visualStatus' is not in allowed enum: $($allowedStatus -join ', ')") | Out-Null
  }
}

if ($statusLower -eq "visually_verified") {
  if ($methodLower -eq "static" -or [string]::IsNullOrWhiteSpace($method)) {
    if ($methodLower -eq "static") {
      $errors.Add("visually_verified forbidden when method=static (static analysis ≠ visual pass)") | Out-Null
    } else {
      $errors.Add("visually_verified requires method of render|manual (not empty/static)") | Out-Null
    }
  } elseif ($methodLower -ne "render" -and $methodLower -ne "manual") {
    $errors.Add("visually_verified requires method render|manual; got '$method'") | Out-Null
  }

  if ($artifacts.Count -eq 0) {
    $errors.Add("visually_verified requires non-empty verificationEvidence.artifacts[]") | Out-Null
  } else {
    $aidx = 0
    foreach ($a in $artifacts) {
      $aidx++
      if (Test-PlaceholderArtifact $a) {
        $errors.Add("artifacts[$aidx] empty, fabricated, or placeholder path: $a") | Out-Null
        continue
      }
      $resolved = Resolve-ArtifactPath $a
      if ($null -eq $resolved) {
        $errors.Add("artifacts[$aidx] path does not exist on disk: $a") | Out-Null
      }
    }
  }
}

# Honest non-verified statuses: require limitations when blocked / functionally unverified on completion
if ($claimsComplete -and ($statusLower -eq "blocked" -or $statusLower -eq "functionally_verified_visually_unverified")) {
  if ($limitations.Count -eq 0) {
    $errors.Add("visualStatus=$statusLower on completion requires non-empty verificationEvidence.limitations[]") | Out-Null
  }
}

if ($methodLower -eq "blocked" -and $statusLower -eq "visually_verified") {
  $errors.Add("method=blocked cannot pair with visually_verified") | Out-Null
}

$ok = ($errors.Count -eq 0)
return (New-M4trixGuardCheck -Name "visual" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))

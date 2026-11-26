#Requires -Version 5.1
<#
.SYNOPSIS
  Guard validator: ACTIVE_TASK.research — required findings+sources, alternatives, no fabricated sources.
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

$claimsComplete = Test-M4trixGuardCompletionClaim -Task $Task
$hasResearch = $null -ne $Task.PSObject.Properties["research"]
$research = Get-M4trixGuardProp $Task "research"

function Get-BoolLocal($Obj, [string]$Name) {
  $v = Get-M4trixGuardProp $Obj $Name
  if ($null -eq $v) { return $false }
  if ($v -is [bool]) { return [bool]$v }
  $s = [string]$v
  return ($s -eq "true" -or $s -eq "1")
}

function Test-PlaceholderSource([string]$PathOrUrl) {
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
    "none"
  )
  foreach ($b in $bad) {
    if ($lower -eq $b) { return $true }
    if ($lower.Contains($b)) { return $true }
  }
  return $false
}

function Test-WebUnavailableLimit($Limitations) {
  foreach ($l in @($Limitations)) {
    $s = [string]$l
    if ([string]::IsNullOrWhiteSpace($s)) { continue }
    $lower = $s.ToLowerInvariant()
    if ($lower -match "web\s*unavail" -or $lower -match "offline" -or $lower -match "no\s*network" -or $lower -match "docs?\s*unavail") {
      return $true
    }
  }
  return $false
}

# researchNeeded from routing attrs
$researchNeeded = $false
$routing = Get-M4trixGuardProp $Task "routing"
if ($null -ne $routing) {
  $attrs = Get-M4trixGuardProp $routing "attributes"
  if ($null -ne $attrs) {
    $researchNeeded = Get-BoolLocal $attrs "researchNeeded"
  }
}

if (-not $hasResearch) {
  if ($claimsComplete -and $researchNeeded) {
    $errors.Add("completion claim with researchNeeded=true requires 'research' object with findings+sources") | Out-Null
  } elseif ($claimsComplete) {
    $warnings.Add("completion claim without 'research' object — OK when research was not required") | Out-Null
  }
  $ok = ($errors.Count -eq 0)
  return (New-M4trixGuardCheck -Name "research" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

if ($null -eq $research -or $research -is [string] -or $research -is [ValueType]) {
  $errors.Add("'research' must be an object") | Out-Null
  return (New-M4trixGuardCheck -Name "research" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

# Arrays must be JSON arrays when present
foreach ($arrName in @("findings", "sources", "limitations")) {
  if ([string]::IsNullOrWhiteSpace($RawJson)) { continue }
  if ($RawJson -match ('"' + [regex]::Escape($arrName) + '"\s*:')) {
    if (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName $arrName)) {
      $errors.Add("'research.$arrName' must be a JSON array") | Out-Null
    }
  }
}

$required = Get-BoolLocal $research "required"
if ($researchNeeded -and $claimsComplete) {
  $required = $true
}
if ($researchNeeded -and -not (Get-BoolLocal $research "required") -and $claimsComplete) {
  $errors.Add("routing.attributes.researchNeeded=true on completion requires research.required=true") | Out-Null
}

$findings = @(Get-M4trixGuardProp $research "findings")
$sources = @(Get-M4trixGuardProp $research "sources")
$limitations = @(Get-M4trixGuardProp $research "limitations")

if (-not $required) {
  $ok = ($errors.Count -eq 0)
  return (New-M4trixGuardCheck -Name "research" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

# Required path
$findingList = @()
foreach ($f in $findings) {
  if ($null -ne $f -and -not ($f -is [string] -and [string]::IsNullOrWhiteSpace([string]$f))) {
    $findingList += $f
  }
}
$sourceList = @()
foreach ($s in $sources) {
  if ($null -ne $s -and -not ($s -is [string] -and [string]::IsNullOrWhiteSpace([string]$s))) {
    $sourceList += $s
  }
}

if ($findingList.Count -eq 0) {
  $errors.Add("research.required=true needs non-empty findings[]") | Out-Null
}
if ($sourceList.Count -eq 0) {
  $errors.Add("research.required=true needs non-empty sources[]") | Out-Null
}

$idx = 0
foreach ($f in $findingList) {
  $idx++
  if ($f -is [string] -or $f -is [ValueType]) {
    $errors.Add("findings[$idx] must be an object") | Out-Null
    continue
  }
  $rec = [string](Get-M4trixGuardProp $f "recommendation")
  $rat = [string](Get-M4trixGuardProp $f "rationale")
  $q = [string](Get-M4trixGuardProp $f "question")
  if ([string]::IsNullOrWhiteSpace($q)) {
    $errors.Add("findings[$idx].question is required") | Out-Null
  }
  if ([string]::IsNullOrWhiteSpace($rec)) {
    $errors.Add("findings[$idx].recommendation is required") | Out-Null
  }
  if ([string]::IsNullOrWhiteSpace($rat)) {
    $errors.Add("findings[$idx].rationale is required") | Out-Null
  }
  $alts = @(Get-M4trixGuardProp $f "alternatives")
  $altCount = 0
  foreach ($a in $alts) {
    if ($null -eq $a) { continue }
    if ($a -is [string] -or $a -is [ValueType]) {
      if (-not [string]::IsNullOrWhiteSpace([string]$a)) { $altCount++ }
      continue
    }
    $an = [string](Get-M4trixGuardProp $a "name")
    if (-not [string]::IsNullOrWhiteSpace($an)) { $altCount++ }
  }
  if ($altCount -lt 1) {
    $errors.Add("findings[$idx] needs ≥1 alternative (rubber-stamp without alternatives fails)") | Out-Null
  }
}

$remoteCount = 0
$localCount = 0
$sidx = 0
foreach ($s in $sourceList) {
  $sidx++
  if ($s -is [string] -or $s -is [ValueType]) {
    $errors.Add("sources[$sidx] must be an object") | Out-Null
    continue
  }
  $path = [string](Get-M4trixGuardProp $s "urlOrPath")
  $title = [string](Get-M4trixGuardProp $s "title")
  $kind = [string](Get-M4trixGuardProp $s "kind")
  if ([string]::IsNullOrWhiteSpace($title)) {
    $errors.Add("sources[$sidx].title is required") | Out-Null
  }
  if ([string]::IsNullOrWhiteSpace($path) -or (Test-PlaceholderSource $path)) {
    $errors.Add("sources[$sidx].urlOrPath empty or fabricated/placeholder") | Out-Null
  }
  if ([string]::IsNullOrWhiteSpace($kind)) {
    $warnings.Add("sources[$sidx].kind missing") | Out-Null
  }
  $kl = $kind.ToLowerInvariant()
  if ($kl -eq "project" -or $kl -eq "deps") {
    $localCount++
  } elseif ($path -match '^https?://') {
    $remoteCount++
  } else {
    $localCount++
  }
}

$webUnavailable = Test-WebUnavailableLimit $limitations
if ($required -and $sourceList.Count -gt 0 -and $remoteCount -eq 0 -and $localCount -eq 0) {
  # all sources failed placeholder checks already
} elseif ($required -and $remoteCount -eq 0 -and -not $webUnavailable -and $localCount -eq 0 -and $sourceList.Count -gt 0) {
  # has sources but none counted — already errored
} elseif ($required -and $remoteCount -eq 0 -and $localCount -eq 0 -and -not $webUnavailable) {
  # empty handled above
}

# When required and no remote sources and no local project/deps kind — require web-unavail limitation if only remote was expected
# Practical rule: if required and every remaining valid source is missing, already failed.
# If required, zero remote URLs, and limitations lack web-unavail, but we have local sources — OK.
# If required, zero sources of any usable kind after filters — already failed.
# Extra: if research claims only community/remote but path is missing → already failed.

if ($required -and $remoteCount -eq 0 -and $localCount -gt 0 -and -not $webUnavailable) {
  # Local-only research without web limitation is allowed (project-first order)
}

if ($required -and $remoteCount -eq 0 -and $localCount -eq 0 -and $sourceList.Count -gt 0 -and -not $webUnavailable) {
  # placeholder-only sources already errored; if somehow counted zero, require limitation
  if ($errors.Count -eq 0) {
    $errors.Add("research.required with no usable local/remote sources needs a web-unavailability limitation or real sources") | Out-Null
  }
}

$ok = ($errors.Count -eq 0)
return (New-M4trixGuardCheck -Name "research" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))

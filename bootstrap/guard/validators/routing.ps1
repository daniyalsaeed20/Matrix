#Requires -Version 5.1
<#
.SYNOPSIS
  Guard validator: ACTIVE_TASK.routing — attrs, calculate match, mandatory ⊆ invoked evidence.
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
$EvalScript = Join-Path $GuardRoot "Evaluate-Routing.ps1"
$claimsComplete = Test-M4trixGuardCompletionClaim -Task $Task

$hasRouting = $null -ne $Task.PSObject.Properties["routing"]
$routing = Get-M4trixGuardProp $Task "routing"

if (-not $hasRouting) {
  if ($claimsComplete) {
    $warnings.Add("completion claim without 'routing' object — record classify/calculate/invoke for RTE compliance") | Out-Null
  }
  $ok = ($errors.Count -eq 0)
  return (New-M4trixGuardCheck -Name "routing" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

if ($null -eq $routing -or $routing -is [string] -or $routing -is [ValueType]) {
  $errors.Add("'routing' must be an object") | Out-Null
  return (New-M4trixGuardCheck -Name "routing" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

$attrs = Get-M4trixGuardProp $routing "attributes"
if ($null -eq $attrs -or $attrs -is [string] -or $attrs -is [ValueType]) {
  $errors.Add("'routing.attributes' must be an object") | Out-Null
  return (New-M4trixGuardCheck -Name "routing" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

# Array shape checks
foreach ($arrName in @("invoked", "evidence")) {
  if ([string]::IsNullOrWhiteSpace($RawJson)) { continue }
  # Look under routing object — field may appear elsewhere; check presence of routing block pattern loosely
  if ($RawJson -match ('"' + [regex]::Escape($arrName) + '"\s*:')) {
    if (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName $arrName)) {
      $errors.Add("'routing.$arrName' must be a JSON array") | Out-Null
    }
  }
}

function Test-AttrPresent($Attrs, [string]$Name) {
  $p = $Attrs.PSObject.Properties[$Name]
  return ($null -ne $p -and $null -ne $p.Value -and -not [string]::IsNullOrWhiteSpace([string]$p.Value))
}

function Get-BoolAttrLocal($Attrs, [string]$Name) {
  $v = Get-M4trixGuardProp $Attrs $Name
  if ($null -eq $v) { return $false }
  if ($v -is [bool]) { return [bool]$v }
  $s = [string]$v
  return ($s -eq "true" -or $s -eq "1")
}

function Test-NonTrivialLocal($Attrs) {
  $uncertainty = [string](Get-M4trixGuardProp $Attrs "uncertainty")
  if ($uncertainty -match "^(med|medium|high)$") { return $true }
  if (Get-BoolAttrLocal $Attrs "regressionRisk") { return $true }
  if (Get-BoolAttrLocal $Attrs "securityRisk") { return $true }
  if (Get-BoolAttrLocal $Attrs "recoveryActive") { return $true }
  if (Get-BoolAttrLocal $Attrs "unfamiliarTech") { return $true }
  if (Get-BoolAttrLocal $Attrs "recurringDefect") { return $true }
  if (Get-BoolAttrLocal $Attrs "researchNeeded") { return $true }
  $ui = [string](Get-M4trixGuardProp $Attrs "uiInvolvement")
  if ($ui -eq "significant") { return $true }
  return $false
}

$scale = [string](Get-M4trixGuardProp $attrs "scale")
if ([string]::IsNullOrWhiteSpace($scale)) {
  $errors.Add("routing.attributes.scale is required") | Out-Null
}

# Patch-minimal required attrs
$minimalRequired = @("scale", "taskType", "uiInvolvement")
foreach ($f in $minimalRequired) {
  if (-not (Test-AttrPresent $attrs $f)) {
    # securityRisk and stacks may be bool/array — check property existence
    if ($f -eq "scale" -or $f -eq "taskType" -or $f -eq "uiInvolvement") {
      $errors.Add("routing.attributes.$f is required (patch-minimal)") | Out-Null
    }
  }
}
if ($null -eq $attrs.PSObject.Properties["stacks"]) {
  $errors.Add("routing.attributes.stacks is required (patch-minimal array)") | Out-Null
} elseif (-not [string]::IsNullOrWhiteSpace($RawJson)) {
  # stacks should be array in JSON
  if ($RawJson -match '"stacks"\s*:') {
    if (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName "stacks")) {
      $errors.Add("routing.attributes.stacks must be a JSON array") | Out-Null
    }
  }
}
if ($null -eq $attrs.PSObject.Properties["securityRisk"]) {
  $errors.Add("routing.attributes.securityRisk is required (patch-minimal bool)") | Out-Null
}

$needFull = ($scale.ToLowerInvariant() -ne "patch") -or (Test-NonTrivialLocal $attrs)
if ($needFull) {
  foreach ($f in @("layers", "uncertainty", "regressionRisk", "recoveryActive", "researchNeeded")) {
    if ($null -eq $attrs.PSObject.Properties[$f]) {
      $errors.Add("routing.attributes.$f is required for module/product/recovery or non-trivial patch") | Out-Null
    }
  }
  if ($null -eq $attrs.PSObject.Properties["reviewsRequired"]) {
    $errors.Add("routing.attributes.reviewsRequired is required for full attribute set") | Out-Null
  }
}

if ($errors.Count -gt 0) {
  return (New-M4trixGuardCheck -Name "routing" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

# Re-run calculate
if (-not (Test-Path -LiteralPath $EvalScript)) {
  $errors.Add("Evaluate-Routing.ps1 missing — markdown-only routing insufficient") | Out-Null
  return (New-M4trixGuardCheck -Name "routing" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

$tmpCalc = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-route-" + [guid]::NewGuid().ToString("n") + ".json")
$calcArgs = @{
  File           = $EvalScript
  AttributesPath = $TaskPath
  KitRoot        = $KitRoot
  OutputPath     = $tmpCalc
}
# Prefer TaskPath; if empty, write attrs temp
if ([string]::IsNullOrWhiteSpace($TaskPath) -or -not (Test-Path -LiteralPath $TaskPath)) {
  $tmpAttrs = Join-Path ([System.IO.Path]::GetTempPath()) ("m4trix-attrs-" + [guid]::NewGuid().ToString("n") + ".json")
  ($attrs | ConvertTo-Json -Depth 8) | Set-Content -Path $tmpAttrs -Encoding UTF8
  $calcArgs.AttributesPath = $tmpAttrs
}

$calcOut = & powershell -NoProfile -ExecutionPolicy Bypass -File $calcArgs.File `
  -AttributesPath $calcArgs.AttributesPath -KitRoot $KitRoot -OutputPath $tmpCalc 2>&1 | Out-String
$calcCode = $LASTEXITCODE
$calculated = $null
if (Test-Path $tmpCalc) {
  try { $calculated = Get-Content $tmpCalc -Raw | ConvertFrom-Json } catch { $calculated = $null }
  Remove-Item $tmpCalc -Force -ErrorAction SilentlyContinue
}
if ($null -ne $calcArgs.AttributesPath -and $calcArgs.AttributesPath -ne $TaskPath -and (Test-Path $calcArgs.AttributesPath)) {
  Remove-Item $calcArgs.AttributesPath -Force -ErrorAction SilentlyContinue
}

if ($null -eq $calculated) {
  $errors.Add("Evaluate-Routing failed to produce JSON (exit=$calcCode)") | Out-Null
  if (-not [string]::IsNullOrWhiteSpace($calcOut)) {
    $warnings.Add(("calculate stdout: " + $calcOut.Substring(0, [Math]::Min(200, $calcOut.Length)))) | Out-Null
  }
  return (New-M4trixGuardCheck -Name "routing" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

if ($calculated.ok -eq $false) {
  foreach ($e in @(Get-M4trixGuardAsStringList $calculated.errors)) {
    $errors.Add("calculate: $e") | Out-Null
  }
}

# Store-compare: if routing.calculated present, mandatory sets should match recompute
$stored = Get-M4trixGuardProp $routing "calculated"
if ($null -ne $stored -and $stored -isnot [string]) {
  $storedMand = @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $stored "mandatoryAgents")) | Sort-Object
  $freshMand = @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $calculated "mandatoryAgents")) | Sort-Object
  $storedJoin = ($storedMand -join ",")
  $freshJoin = ($freshMand -join ",")
  if ($storedJoin -ne $freshJoin) {
    $errors.Add("routing.calculated.mandatoryAgents stale (stored=[$storedJoin] fresh=[$freshJoin])") | Out-Null
  }
}

$mandatory = @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $calculated "mandatoryAgents"))
$deferredNames = @()
foreach ($d in @($calculated.deferred)) {
  $n = [string](Get-M4trixGuardProp $d "name")
  if (-not [string]::IsNullOrWhiteSpace($n)) { $deferredNames += $n }
}

$invoked = @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $routing "invoked"))
$evidence = @(Get-M4trixGuardProp $routing "evidence")
if ($null -eq $evidence) { $evidence = @() }
elseif ($evidence -isnot [System.Array]) { $evidence = @($evidence) }

$allowedEvidenceTypes = @("task", "subagent", "artifact", "limitation")
$evidenceByName = @{}
foreach ($ev in $evidence) {
  if ($null -eq $ev) { continue }
  $etype = [string](Get-M4trixGuardProp $ev "type")
  $ename = [string](Get-M4trixGuardProp $ev "name")
  if ([string]::IsNullOrWhiteSpace($etype) -or ($allowedEvidenceTypes -notcontains $etype.ToLowerInvariant())) {
    $errors.Add("routing.evidence entry for '$ename' has invalid type '$etype' (parent impersonation / claim-only rejected; use task|subagent|artifact|limitation)") | Out-Null
    continue
  }
  if ($etype.ToLowerInvariant() -eq "limitation") {
    # limitation evidence does not count as invocation of a specialist
    continue
  }
  if (-not [string]::IsNullOrWhiteSpace($ename)) {
    $evidenceByName[$ename.ToLowerInvariant()] = $etype.ToLowerInvariant()
  }
}

$limitation = [string](Get-M4trixGuardProp $routing "evidenceLimitation")
$limitationAckRaw = Get-M4trixGuardProp $routing "limitationAck"
$limitationAck = $false
if ($null -ne $limitationAckRaw) {
  if ($limitationAckRaw -is [bool]) { $limitationAck = [bool]$limitationAckRaw }
  else { $limitationAck = ([string]$limitationAckRaw -eq "true" -or [string]$limitationAckRaw -eq "1") }
}

$useLimitation = (-not [string]::IsNullOrWhiteSpace($limitation)) -and $limitationAck

foreach ($agent in $mandatory) {
  if ($deferredNames -contains $agent) { continue }
  $key = $agent.ToLowerInvariant()
  $inInvoked = $false
  foreach ($i in $invoked) {
    if ([string]$i -eq $agent) { $inInvoked = $true; break }
  }
  $hasEv = $evidenceByName.ContainsKey($key)
  if ($inInvoked -and $hasEv) { continue }
  if ($inInvoked -and -not $hasEv) {
    $errors.Add("mandatory agent '$agent' listed in invoked but missing independent evidence (parent prose ≠ evidence)") | Out-Null
    continue
  }
  if (-not $inInvoked -and $hasEv) {
    $warnings.Add("mandatory agent '$agent' has evidence but not listed in invoked[]") | Out-Null
    continue
  }
  if ($useLimitation) {
    $warnings.Add("mandatory agent '$agent' missing invoke/evidence; accepted via evidenceLimitation + limitationAck") | Out-Null
    continue
  }
  $errors.Add("mandatory agent '$agent' missing from invoked/evidence (omit-mandatory)") | Out-Null
}

# Required skills that are not deferred should appear in invoked or evidence when claiming complete
$reqSkills = @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $calculated "requiredSkills"))
if ($claimsComplete) {
  foreach ($sk in $reqSkills) {
    if ($deferredNames -contains $sk) { continue }
    $key = $sk.ToLowerInvariant()
    $inInvoked = $false
    foreach ($i in $invoked) { if ([string]$i -eq $sk) { $inInvoked = $true; break } }
    $hasEv = $evidenceByName.ContainsKey($key)
    if (-not $inInvoked -and -not $hasEv -and -not $useLimitation) {
      $errors.Add("required skill '$sk' missing from invoked/evidence on completion claim") | Out-Null
    }
  }
}

if (-not [string]::IsNullOrWhiteSpace($limitation) -and -not $limitationAck) {
  $errors.Add("routing.evidenceLimitation set but limitationAck is false — captain acknowledgment required") | Out-Null
}

$ok = ($errors.Count -eq 0)
return (New-M4trixGuardCheck -Name "routing" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))

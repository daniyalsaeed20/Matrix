#Requires -Version 5.1
<#
.SYNOPSIS
  Deterministic routing calculate step (RTE-002). Reads routing-policy.json + attributes.

.PARAMETER AttributesJson
  JSON object of classification attributes (or path via -AttributesPath).

.PARAMETER AttributesPath
  Path to a JSON file containing attributes (or full ACTIVE_TASK with routing.attributes).

.PARAMETER PolicyPath
  Path to routing-policy.json. Default: <kit>/templates/sdlc/routing-policy.json

.PARAMETER KitRoot
  Kit root for agent/skill file presence checks. Default: parent of bootstrap/

.PARAMETER ProgressionPath
  Optional V2_TASKS.md path to detect accepted introduction tasks (T6/T8).

.PARAMETER OutputPath
  Optional path to write JSON result.

.OUTPUTS
  JSON: mandatoryAgents, conditionalAgents, unnecessaryAgents, requiredSkills,
  requiredValidators, deferred[], errors[], trivialPatch, schemaVersion
#>
param(
  [string]$AttributesJson = "",
  [string]$AttributesPath = "",
  [string]$PolicyPath = "",
  [string]$KitRoot = "",
  [string]$ProgressionPath = "",
  [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"
$GuardRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($KitRoot)) {
  $KitRoot = Split-Path -Parent (Split-Path -Parent $GuardRoot)
}
. (Join-Path $GuardRoot "lib\GuardCommon.ps1")

function Get-BoolAttr($Attrs, [string]$Name) {
  $v = Get-M4trixGuardProp $Attrs $Name
  if ($null -eq $v) { return $false }
  if ($v -is [bool]) { return [bool]$v }
  $s = [string]$v
  return ($s -eq "true" -or $s -eq "1")
}

function Get-StringListAttr($Attrs, [string]$Name) {
  return @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $Attrs $Name))
}

function Test-NonTrivialPatch($Attrs) {
  $uncertainty = [string](Get-M4trixGuardProp $Attrs "uncertainty")
  if ($uncertainty -match "^(med|medium|high)$") { return $true }
  if (Get-BoolAttr $Attrs "regressionRisk") { return $true }
  if (Get-BoolAttr $Attrs "securityRisk") { return $true }
  if (Get-BoolAttr $Attrs "recoveryActive") { return $true }
  if (Get-BoolAttr $Attrs "unfamiliarTech") { return $true }
  if (Get-BoolAttr $Attrs "recurringDefect") { return $true }
  if (Get-BoolAttr $Attrs "researchNeeded") { return $true }
  $ui = [string](Get-M4trixGuardProp $Attrs "uiInvolvement")
  if ($ui -eq "significant") { return $true }
  return $false
}

function Test-RuleWhen($When, $Attrs, [bool]$TrivialPatch) {
  if ($null -eq $When) { return $false }
  if (Get-BoolAttr $When "always") { return $true }

  $scale = [string](Get-M4trixGuardProp $Attrs "scale")
  $whenScale = Get-M4trixGuardProp $When "scale"
  if ($null -ne $whenScale -and [string]$whenScale -ne $scale) { return $false }

  $scaleIn = Get-M4trixGuardProp $When "scaleIn"
  if ($null -ne $scaleIn) {
    $allowed = @(Get-M4trixGuardAsStringList $scaleIn)
    if ($allowed -notcontains $scale) { return $false }
  }

  if ($null -ne (Get-M4trixGuardProp $When "trivialPatch")) {
    $want = Get-BoolAttr $When "trivialPatch"
    if ($want -ne $TrivialPatch) { return $false }
  }

  if ($null -ne (Get-M4trixGuardProp $When "securityRisk")) {
    if ((Get-BoolAttr $When "securityRisk") -ne (Get-BoolAttr $Attrs "securityRisk")) { return $false }
  }
  if ($null -ne (Get-M4trixGuardProp $When "recoveryActive")) {
    if ((Get-BoolAttr $When "recoveryActive") -ne (Get-BoolAttr $Attrs "recoveryActive")) { return $false }
  }
  if ($null -ne (Get-M4trixGuardProp $When "researchNeeded")) {
    if ((Get-BoolAttr $When "researchNeeded") -ne (Get-BoolAttr $Attrs "researchNeeded")) { return $false }
  }
  if ($null -ne (Get-M4trixGuardProp $When "regressionRisk")) {
    if ((Get-BoolAttr $When "regressionRisk") -ne (Get-BoolAttr $Attrs "regressionRisk")) { return $false }
  }

  $uiWhen = Get-M4trixGuardProp $When "uiInvolvement"
  if ($null -ne $uiWhen) {
    $ui = [string](Get-M4trixGuardProp $Attrs "uiInvolvement")
    if ($ui -ne [string]$uiWhen) { return $false }
  }

  $stackContains = Get-M4trixGuardProp $When "stacksContains"
  if ($null -ne $stackContains) {
    $stacks = Get-StringListAttr $Attrs "stacks"
    $needle = [string]$stackContains
    $hit = $false
    foreach ($s in $stacks) {
      if ($s.ToLowerInvariant() -eq $needle.ToLowerInvariant()) { $hit = $true; break }
    }
    if (-not $hit) { return $false }
  }

  return $true
}

function Get-AcceptedTaskIds([string]$Path) {
  $accepted = New-Object System.Collections.Generic.HashSet[string]
  if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
    return $accepted
  }
  $lines = Get-Content -LiteralPath $Path
  foreach ($line in $lines) {
    if ($line -match '^\|\s*(T\d+[a-z]?)\s*\|\s*[^|]+\|\s*accepted\s*\|') {
      [void]$accepted.Add($Matches[1])
    }
  }
  return $accepted
}

function Add-Unique([System.Collections.Generic.List[string]]$List, [string]$Item) {
  if ([string]::IsNullOrWhiteSpace($Item)) { return }
  if (-not $List.Contains($Item)) { $List.Add($Item) | Out-Null }
}

# Resolve attributes
$attrs = $null
if (-not [string]::IsNullOrWhiteSpace($AttributesPath)) {
  $raw = Get-Content -LiteralPath $AttributesPath -Raw
  $obj = $raw | ConvertFrom-Json
  $routing = Get-M4trixGuardProp $obj "routing"
  if ($null -ne $routing) {
    $attrs = Get-M4trixGuardProp $routing "attributes"
  }
  if ($null -eq $attrs) {
    # Treat file as bare attributes object
    $attrs = $obj
  }
} elseif (-not [string]::IsNullOrWhiteSpace($AttributesJson)) {
  $attrs = $AttributesJson | ConvertFrom-Json
} else {
  Write-Error "Provide -AttributesJson or -AttributesPath"
  exit 2
}

if ([string]::IsNullOrWhiteSpace($PolicyPath)) {
  $PolicyPath = Join-Path $KitRoot "templates\sdlc\routing-policy.json"
}
if (-not (Test-Path -LiteralPath $PolicyPath)) {
  Write-Error "routing-policy.json not found: $PolicyPath"
  exit 2
}
$policy = Get-Content -LiteralPath $PolicyPath -Raw | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($ProgressionPath)) {
  $candidate = Join-Path $KitRoot "docs\sdlc\V2_TASKS.md"
  if (Test-Path -LiteralPath $candidate) { $ProgressionPath = $candidate }
}
$acceptedTasks = Get-AcceptedTaskIds $ProgressionPath

$scale = [string](Get-M4trixGuardProp $attrs "scale")
if ([string]::IsNullOrWhiteSpace($scale)) { $scale = "patch" }
$isPatch = ($scale.ToLowerInvariant() -eq "patch")
$nonTrivial = Test-NonTrivialPatch $attrs
$trivialPatch = $isPatch -and (-not $nonTrivial)

$mandatoryAgents = New-Object System.Collections.Generic.List[string]
$conditionalAgents = New-Object System.Collections.Generic.List[string]
$unnecessaryAgents = New-Object System.Collections.Generic.List[string]
$requiredSkills = New-Object System.Collections.Generic.List[string]
$requiredValidators = New-Object System.Collections.Generic.List[string]
$deferred = New-Object System.Collections.Generic.List[object]
$errors = New-Object System.Collections.Generic.List[string]

foreach ($rule in @($policy.rules)) {
  $when = Get-M4trixGuardProp $rule "when"
  if (-not (Test-RuleWhen $when $attrs $trivialPatch)) { continue }

  foreach ($a in @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $rule "mandatoryAgents"))) {
    Add-Unique $mandatoryAgents $a
  }
  foreach ($a in @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $rule "conditionalAgents"))) {
    Add-Unique $conditionalAgents $a
  }
  foreach ($a in @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $rule "unnecessaryAgents"))) {
    Add-Unique $unnecessaryAgents $a
  }
  foreach ($s in @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $rule "requiredSkills"))) {
    Add-Unique $requiredSkills $s
  }
  foreach ($v in @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $rule "requiredValidators"))) {
    Add-Unique $requiredValidators $v
  }
}

# Remove unnecessary from mandatory/conditional when trivial patch marked them unnecessary
# (but security/recovery/etc. rules still win — do not strip if also mandatory from other rules)
# Only strip agents that appear in unnecessary AND were only conditional; keep mandatory.
$toStrip = @($unnecessaryAgents)
foreach ($u in $toStrip) {
  if ($mandatoryAgents.Contains($u)) {
    # mandatory wins over unnecessary
    [void]$unnecessaryAgents.Remove($u)
  } else {
    [void]$conditionalAgents.Remove($u)
  }
}

function Resolve-Presence {
  param(
    [string]$Name,
    [string]$Kind, # agent|skill
    $Policy,
    [string]$Root,
    $Accepted
  )
  $pathsMap = if ($Kind -eq "skill") { $Policy.skillPaths } else { $Policy.agentPaths }
  $rel = $null
  if ($null -ne $pathsMap) {
    $rel = Get-M4trixGuardProp $pathsMap $Name
  }
  $full = $null
  $exists = $false
  if (-not [string]::IsNullOrWhiteSpace([string]$rel)) {
    $full = Join-Path $Root ([string]$rel)
    $exists = Test-Path -LiteralPath $full
  }

  $fd = $null
  if ($null -ne $Policy.forwardDeclare) {
    $fd = Get-M4trixGuardProp $Policy.forwardDeclare $Name
  }
  $introducedAt = $null
  if ($null -ne $fd) {
    $introducedAt = [string](Get-M4trixGuardProp $fd "introducedAt")
  }

  $introAccepted = $false
  if (-not [string]::IsNullOrWhiteSpace($introducedAt)) {
    # Introduced when that task or any later numeric task is accepted — treat exact task accepted.
    $introAccepted = $Accepted.Contains($introducedAt)
  }

  if ($exists) {
    return [pscustomobject]@{ Status = "present"; Path = $full; IntroducedAt = $introducedAt }
  }
  if ($introAccepted) {
    return [pscustomobject]@{ Status = "missing_after_intro"; Path = $full; IntroducedAt = $introducedAt }
  }
  if (-not [string]::IsNullOrWhiteSpace($introducedAt)) {
    return [pscustomobject]@{ Status = "deferred"; Path = $full; IntroducedAt = $introducedAt }
  }
  # Not forward-declared and missing → missing (hard)
  return [pscustomobject]@{ Status = "missing"; Path = $full; IntroducedAt = $null }
}

$effectiveMandatory = New-Object System.Collections.Generic.List[string]
foreach ($name in @($mandatoryAgents)) {
  $res = Resolve-Presence -Name $name -Kind "agent" -Policy $policy -Root $KitRoot -Accepted $acceptedTasks
  if ($res.Status -eq "present") {
    Add-Unique $effectiveMandatory $name
  } elseif ($res.Status -eq "deferred") {
    $deferred.Add([pscustomobject]@{
      name          = $name
      kind          = "agent"
      reason        = "forward-declared; file absent; introduction task $($res.IntroducedAt) not accepted"
      introducedAt  = $res.IntroducedAt
    }) | Out-Null
  } elseif ($res.Status -eq "missing_after_intro") {
    $errors.Add("mandatory agent '$name' missing after introduction task $($res.IntroducedAt)") | Out-Null
    Add-Unique $effectiveMandatory $name
  } else {
    $errors.Add("mandatory agent '$name' file missing and not forward-declared") | Out-Null
    Add-Unique $effectiveMandatory $name
  }
}

$effectiveSkills = New-Object System.Collections.Generic.List[string]
foreach ($name in @($requiredSkills)) {
  $res = Resolve-Presence -Name $name -Kind "skill" -Policy $policy -Root $KitRoot -Accepted $acceptedTasks
  if ($res.Status -eq "present") {
    Add-Unique $effectiveSkills $name
  } elseif ($res.Status -eq "deferred") {
    $deferred.Add([pscustomobject]@{
      name         = $name
      kind         = "skill"
      reason       = "forward-declared; file absent; introduction task $($res.IntroducedAt) not accepted"
      introducedAt = $res.IntroducedAt
    }) | Out-Null
  } elseif ($res.Status -eq "missing_after_intro") {
    $errors.Add("required skill '$name' missing after introduction task $($res.IntroducedAt)") | Out-Null
    Add-Unique $effectiveSkills $name
  } else {
    # Non-forward-declared skills that are missing still listed as required (validator/evidence)
    Add-Unique $effectiveSkills $name
    if ($res.Status -eq "missing") {
      $errors.Add("required skill '$name' file missing") | Out-Null
    }
  }
}

# Conditional agents: annotate deferred similarly but do not require invoke
$effectiveConditional = New-Object System.Collections.Generic.List[string]
foreach ($name in @($conditionalAgents)) {
  if ($effectiveMandatory.Contains($name)) { continue }
  $res = Resolve-Presence -Name $name -Kind "agent" -Policy $policy -Root $KitRoot -Accepted $acceptedTasks
  if ($res.Status -eq "deferred") {
    $deferred.Add([pscustomobject]@{
      name         = $name
      kind         = "agent"
      reason       = "conditional forward-declare; deferred"
      introducedAt = $res.IntroducedAt
    }) | Out-Null
  } elseif ($res.Status -eq "present" -or $res.Status -eq "missing" -or $res.Status -eq "missing_after_intro") {
    Add-Unique $effectiveConditional $name
  }
}

# Materialize lists to plain arrays (avoid PS 5.1 @($list) dictionary enumeration)
$deferredArr = @($deferred.ToArray())
$mandArr = @($effectiveMandatory.ToArray())
$condArr = @($effectiveConditional.ToArray())
$unarr = @($unnecessaryAgents.ToArray())
$skillArr = @($effectiveSkills.ToArray())
$valArr = @($requiredValidators.ToArray())
$errArr = @($errors.ToArray())

$result = [ordered]@{
  schemaVersion       = "1.0.0"
  trivialPatch        = [bool]$trivialPatch
  mandatoryAgents     = $mandArr
  conditionalAgents   = $condArr
  unnecessaryAgents   = $unarr
  requiredSkills      = $skillArr
  requiredValidators  = $valArr
  deferred            = $deferredArr
  errors              = $errArr
  ok                  = ($errArr.Count -eq 0)
  policyVersion       = [string](Get-M4trixGuardProp $policy "version")
  policyPath          = $PolicyPath
}

$json = ($result | ConvertTo-Json -Depth 10)
Write-Output $json
if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
  $dir = Split-Path -Parent $OutputPath
  if (-not [string]::IsNullOrWhiteSpace($dir) -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
  Set-Content -Path $OutputPath -Value $json -Encoding UTF8
}

if (-not $result.ok) { exit 1 }
exit 0

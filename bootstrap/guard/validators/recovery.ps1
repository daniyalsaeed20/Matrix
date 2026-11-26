#Requires -Version 5.1
<#
.SYNOPSIS
  Guard validator: ACTIVE_TASK.recovery — attempt budget, rejected approaches, strategy delta.
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

$defaultBudgets = @{
  "patch"            = 2
  "module"           = 3
  "product-critical" = 3
  "product"          = 3
}

$hasRecoveryProp = $null -ne $Task.PSObject.Properties["recovery"]
$recovery = Get-M4trixGuardProp $Task "recovery"
$claimsComplete = Test-M4trixGuardCompletionClaim -Task $Task

if (-not $hasRecoveryProp) {
  if ($claimsComplete) {
    $warnings.Add("completion claim without 'recovery' object — OK when recovery was never activated") | Out-Null
  }
  $ok = ($errors.Count -eq 0)
  return (New-M4trixGuardCheck -Name "recovery" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

if ($null -eq $recovery -or $recovery -is [string] -or $recovery -is [ValueType]) {
  $errors.Add("'recovery' must be an object") | Out-Null
  return (New-M4trixGuardCheck -Name "recovery" -Ok $false -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

$recStatus = [string](Get-M4trixGuardProp $recovery "status")
$activeRaw = Get-M4trixGuardProp $recovery "active"
$isActive = $false
if ($null -ne $activeRaw) {
  if ($activeRaw -is [bool]) { $isActive = [bool]$activeRaw }
  else {
    $s = [string]$activeRaw
    $isActive = ($s -eq "true" -or $s -eq "1")
  }
}
if ([string]::IsNullOrWhiteSpace($recStatus)) {
  $errors.Add("'recovery.status' is required") | Out-Null
} elseif ($recStatus.ToLowerInvariant() -eq "inactive") {
  $isActive = $false
}

# Inactive / not active: structural presence only
if (-not $isActive) {
  $ok = ($errors.Count -eq 0)
  return (New-M4trixGuardCheck -Name "recovery" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))
}

$allowedStatus = @("investigating", "attempting", "escalated", "resolved")
if ($allowedStatus -notcontains $recStatus.ToLowerInvariant()) {
  $errors.Add("'recovery.status' '$recStatus' invalid when active (investigating|attempting|escalated|resolved)") | Out-Null
}

# Arrays must be JSON arrays
foreach ($arrName in @("attempts", "rejectedApproaches", "facts", "assumptions", "hypotheses", "contradicted")) {
  if ([string]::IsNullOrWhiteSpace($RawJson)) { continue }
  if ($RawJson -match ('"' + [regex]::Escape($arrName) + '"\s*:')) {
    if (-not (Test-M4trixGuardJsonArrayField -RawJson $RawJson -FieldName $arrName)) {
      $errors.Add("'recovery.$arrName' must be a JSON array") | Out-Null
    }
  } elseif ($arrName -eq "attempts" -or $arrName -eq "rejectedApproaches") {
    $errors.Add("'recovery.$arrName' must be a JSON array") | Out-Null
  }
}

# Budget
$budgetRaw = Get-M4trixGuardProp $recovery "attemptBudget"
$recScale = [string](Get-M4trixGuardProp $recovery "scale")
if ([string]::IsNullOrWhiteSpace($recScale)) {
  $recScale = [string](Get-M4trixGuardProp $Task "scale")
}
$budget = $null
if ($null -ne $budgetRaw -and -not [string]::IsNullOrWhiteSpace([string]$budgetRaw)) {
  try { $budget = [int]$budgetRaw } catch { $budget = $null }
}
if ($null -eq $budget -or $budget -lt 1) {
  $key = $recScale.ToLowerInvariant()
  if ($defaultBudgets.ContainsKey($key)) {
    $budget = [int]$defaultBudgets[$key]
    $warnings.Add("attemptBudget missing/invalid — using default $budget for scale '$recScale'") | Out-Null
  } else {
    $errors.Add("'recovery.attemptBudget' required (positive int) when recovery is active") | Out-Null
    $budget = 0
  }
}

$countRaw = Get-M4trixGuardProp $recovery "attemptCount"
$attemptCount = $null
if ($null -ne $countRaw -and -not [string]::IsNullOrWhiteSpace([string]$countRaw)) {
  try { $attemptCount = [int]$countRaw } catch { $attemptCount = $null }
}
if ($null -eq $attemptCount -or $attemptCount -lt 0) {
  $errors.Add("'recovery.attemptCount' required (non-negative int) when recovery is active") | Out-Null
  $attemptCount = -1
}

$attempts = @()
if ($null -ne (Get-M4trixGuardProp $recovery "attempts")) {
  $attempts = @(Get-M4trixGuardProp $recovery "attempts" | Where-Object { $null -ne $_ })
}
$rejected = @()
if ($null -ne (Get-M4trixGuardProp $recovery "rejectedApproaches")) {
  $rejected = @(Get-M4trixGuardProp $recovery "rejectedApproaches" | Where-Object { $null -ne $_ })
}

$rejectedIds = New-Object System.Collections.Generic.HashSet[string]
foreach ($r in $rejected) {
  $rid = [string](Get-M4trixGuardProp $r "id")
  $rsum = [string](Get-M4trixGuardProp $r "summary")
  if ([string]::IsNullOrWhiteSpace($rid)) {
    $errors.Add("rejectedApproaches entry missing 'id'") | Out-Null
  } else {
    [void]$rejectedIds.Add($rid.ToLowerInvariant())
  }
  if ([string]::IsNullOrWhiteSpace($rsum)) {
    $errors.Add("rejectedApproaches '$rid' missing 'summary'") | Out-Null
  }
}

$meaningfulCount = 0
$priorFailSeen = $false
$failedApproachIds = New-Object System.Collections.Generic.HashSet[string]
$idx = 0
foreach ($a in $attempts) {
  $idx++
  $aid = [string](Get-M4trixGuardProp $a "id")
  if ([string]::IsNullOrWhiteSpace($aid)) {
    $errors.Add("attempts entry missing 'id'") | Out-Null
    $aid = "#$idx"
  }
  $approach = [string](Get-M4trixGuardProp $a "approach")
  if ([string]::IsNullOrWhiteSpace($approach)) {
    $errors.Add("attempt '$aid' missing 'approach'") | Out-Null
  }
  $result = [string](Get-M4trixGuardProp $a "result")
  $allowedResults = @("pass", "fail", "blocked", "pending")
  if ([string]::IsNullOrWhiteSpace($result) -or ($allowedResults -notcontains $result.ToLowerInvariant())) {
    $errors.Add("attempt '$aid' has invalid result '$result'") | Out-Null
  }

  $renameOnly = $false
  $ro = Get-M4trixGuardProp $a "renameOnly"
  if ($null -ne $ro) {
    if ($ro -is [bool]) { $renameOnly = [bool]$ro }
    else { $renameOnly = ([string]$ro -eq "true" -or [string]$ro -eq "1") }
  }

  $meaningful = $true
  $m = Get-M4trixGuardProp $a "meaningful"
  if ($null -ne $m) {
    if ($m -is [bool]) { $meaningful = [bool]$m }
    else { $meaningful = -not ([string]$m -eq "false" -or [string]$m -eq "0") }
  }
  if ($renameOnly) { $meaningful = $false }

  if ($renameOnly -and ($result.ToLowerInvariant() -ne "blocked")) {
    $errors.Add("attempt '$aid' is renameOnly — cannot count as a meaningful attempt (result must be blocked or omit from attemptCount)") | Out-Null
  }

  if (-not $meaningful) {
    continue
  }

  $meaningfulCount++

  # Strategy delta required after a prior failed meaningful attempt
  if ($priorFailSeen) {
    $delta = [string](Get-M4trixGuardProp $a "strategyDelta")
    if ([string]::IsNullOrWhiteSpace($delta)) {
      $errors.Add("attempt '$aid' missing strategyDelta after a prior failed attempt") | Out-Null
    }
  }

  # Reuse of an approach that already failed earlier in attempts[] (keep cumulative across chats).
  # rejectedApproaches documents those failures; the attempt that produced the rejection is allowed.
  $approachId = [string](Get-M4trixGuardProp $a "approachId")
  $approachKey = $null
  if (-not [string]::IsNullOrWhiteSpace($approachId)) {
    $approachKey = $approachId.ToLowerInvariant()
  }
  if (-not [string]::IsNullOrWhiteSpace($approachKey) -and $failedApproachIds.Contains($approachKey)) {
    $ev = Get-M4trixGuardProp $a "newEvidence"
    if ($null -eq $ev -or [string]::IsNullOrWhiteSpace([string]$ev)) {
      $errors.Add("attempt '$aid' reuses rejected approachId '$approachId' without newEvidence") | Out-Null
    }
  }

  if ($result.ToLowerInvariant() -eq "fail") {
    $priorFailSeen = $true
    if (-not [string]::IsNullOrWhiteSpace($approachKey)) {
      [void]$failedApproachIds.Add($approachKey)
    }
  }
}

if ($attemptCount -ge 0 -and $attemptCount -ne $meaningfulCount) {
  $errors.Add("'recovery.attemptCount' ($attemptCount) must equal meaningful attempts count ($meaningfulCount)") | Out-Null
}

# Escalation when over budget
$escalation = Get-M4trixGuardProp $recovery "escalation"
$escReported = $false
$escSummary = $null
if ($null -ne $escalation) {
  $er = Get-M4trixGuardProp $escalation "reported"
  if ($null -ne $er) {
    if ($er -is [bool]) { $escReported = [bool]$er }
    else { $escReported = ([string]$er -eq "true" -or [string]$er -eq "1") }
  }
  $escSummary = Get-M4trixGuardProp $escalation "summary"
}

$overBudget = ($budget -gt 0 -and $attemptCount -gt $budget)
if ($overBudget) {
  if (-not $escReported) {
    $errors.Add("attemptCount ($attemptCount) exceeds attemptBudget ($budget) without escalation.reported=true") | Out-Null
  } elseif ($null -eq $escSummary -or [string]::IsNullOrWhiteSpace([string]$escSummary)) {
    $errors.Add("escalation.reported=true requires non-empty escalation.summary") | Out-Null
  }
}

if ($recStatus.ToLowerInvariant() -eq "escalated") {
  if (-not $escReported) {
    $errors.Add("recovery.status=escalated requires escalation.reported=true") | Out-Null
  }
  if ($null -eq $escSummary -or [string]::IsNullOrWhiteSpace([string]$escSummary)) {
    $errors.Add("recovery.status=escalated requires non-empty escalation.summary") | Out-Null
  }
}

# Completion while speculative over budget without escalate already covered;
# also: claiming done while status=attempting with over-budget fails above.
# Claiming done with active recovery still investigating and zero facts is soft warning
if ($claimsComplete -and $recStatus.ToLowerInvariant() -eq "investigating") {
  $warnings.Add("completion claimed while recovery.status=investigating — unusual") | Out-Null
}

if ($claimsComplete -and $overBudget -and -not $escReported) {
  $errors.Add("cannot claim done/accepted over attempt budget without escalation report") | Out-Null
}

$ok = ($errors.Count -eq 0)
return (New-M4trixGuardCheck -Name "recovery" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))

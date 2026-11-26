#Requires -Version 5.1
<#
.SYNOPSIS
  Guard validator: completion-blocking checks when claiming done|accepted (T10 / GRD-003).

.DESCRIPTION
  Fails closed on: missing approval.at; egm.blockingOpen; recovery exhausted without
  escalation reported; filesChanged outside permittedPaths; missing/empty evidence
  (complements task-state).
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
if (-not $claimsComplete) {
  return (New-M4trixGuardCheck -Name "completion" -Ok $true -Errors @() -Warnings @("completion validator idle — status/phase not done|accepted"))
}

# --- approval.at required ---
$approval = Get-M4trixGuardProp $Task "approval"
$approvalAt = $null
if ($null -ne $approval) {
  $approvalAt = Get-M4trixGuardProp $approval "at"
}
if ($null -eq $approvalAt -or [string]::IsNullOrWhiteSpace([string]$approvalAt)) {
  $errors.Add("completion claim requires non-empty approval.at (captain approval)") | Out-Null
}

# --- egm.blockingOpen must not be true ---
$egm = Get-M4trixGuardProp $Task "egm"
if ($null -ne $egm) {
  $blocking = Get-M4trixGuardProp $egm "blockingOpen"
  $isBlocking = $false
  if ($null -ne $blocking) {
    if ($blocking -is [bool]) { $isBlocking = [bool]$blocking }
    else {
      $s = [string]$blocking
      $isBlocking = ($s -eq "true" -or $s -eq "1")
    }
  }
  if ($isBlocking) {
    $errors.Add("completion claim forbidden while egm.blockingOpen=true") | Out-Null
  }
}

# --- recovery exhausted without escalation reported ---
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
  $recStatus = [string](Get-M4trixGuardProp $recovery "status")
  if ($recStatus.ToLowerInvariant() -eq "inactive") { $isActive = $false }

  if ($isActive) {
    $budget = 0
    $count = 0
    try { $budget = [int](Get-M4trixGuardProp $recovery "attemptBudget") } catch { $budget = 0 }
    try { $count = [int](Get-M4trixGuardProp $recovery "attemptCount") } catch { $count = 0 }
    $esc = Get-M4trixGuardProp $recovery "escalation"
    $reported = $false
    if ($null -ne $esc) {
      $rep = Get-M4trixGuardProp $esc "reported"
      if ($null -ne $rep) {
        if ($rep -is [bool]) { $reported = [bool]$rep }
        else {
          $rs = [string]$rep
          $reported = ($rs -eq "true" -or $rs -eq "1")
        }
      }
    }
    if ($budget -gt 0 -and $count -gt $budget -and -not $reported) {
      $errors.Add("completion claim forbidden: recovery attemptCount ($count) > attemptBudget ($budget) without escalation.reported") | Out-Null
    }
  }
}

# --- filesChanged must be within permittedPaths ---
$changed = @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $Task "filesChanged"))
$permitted = @(Get-M4trixGuardAsStringList (Get-M4trixGuardProp $Task "permittedPaths"))

function Test-M4trixPathPermitted([string]$Path, [string[]]$Allowed) {
  if ([string]::IsNullOrWhiteSpace($Path)) { return $true }
  $norm = ($Path -replace '\\', '/').Trim()
  foreach ($a in @($Allowed)) {
    if ([string]::IsNullOrWhiteSpace($a)) { continue }
    $pat = ($a -replace '\\', '/').Trim()
    if ($pat.EndsWith('/')) {
      if ($norm.StartsWith($pat, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
      if (($norm + '/').StartsWith($pat, [System.StringComparison]::OrdinalIgnoreCase)) { return $true }
    } elseif ($norm.Equals($pat, [System.StringComparison]::OrdinalIgnoreCase)) {
      return $true
    } elseif ($pat.Contains('*')) {
      # Simple glob: * matches within a single path segment group via -like
      $like = $pat -replace '/', '\'
      $cand = $norm -replace '/', '\'
      if ($cand -like $like) { return $true }
    }
  }
  return $false
}

if ($changed.Count -gt 0 -and $permitted.Count -eq 0) {
  $errors.Add("completion claim has filesChanged but empty permittedPaths (out-of-scope)") | Out-Null
} elseif ($changed.Count -gt 0) {
  foreach ($f in $changed) {
    if (-not (Test-M4trixPathPermitted -Path $f -Allowed $permitted)) {
      $errors.Add("filesChanged path out of permittedPaths: $f") | Out-Null
    }
  }
}

# --- evidence non-empty (complement task-state) ---
$evidence = Get-M4trixGuardProp $Task "evidence"
$hasEvidenceProp = $null -ne $Task.PSObject.Properties["evidence"]
if (-not $hasEvidenceProp -or $null -eq $evidence) {
  $errors.Add("completion claim requires evidence object with commands or artifacts") | Out-Null
} else {
  $cmds = Get-M4trixGuardAsStringList (Get-M4trixGuardProp $evidence "commands")
  $arts = Get-M4trixGuardAsStringList (Get-M4trixGuardProp $evidence "artifacts")
  if ($cmds.Count -eq 0 -and $arts.Count -eq 0) {
    $errors.Add("completion claim requires non-empty evidence.commands or evidence.artifacts") | Out-Null
  }
}

$ok = ($errors.Count -eq 0)
return (New-M4trixGuardCheck -Name "completion" -Ok $ok -Errors @($errors.ToArray()) -Warnings @($warnings.ToArray()))

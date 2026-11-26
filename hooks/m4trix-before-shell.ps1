#Requires -Version 5.1
<#
.SYNOPSIS
  Selective beforeShellExecution candidate (T10) — deny WIP Fresh / dangerous global install patterns.

.NOTES
  NOT registered in default hooks/hooks.json until live-verified in a captain-approved sibling eval.
  When registered: return permission deny/ask for matching commands; otherwise allow.
  Fail-open on parse errors unless the caller sets failClosed on the hook entry.
#>
$ErrorActionPreference = "Continue"

try {
  $raw = [Console]::In.ReadToEnd()
  $cmd = ""
  if (-not [string]::IsNullOrWhiteSpace($raw)) {
    try {
      $payload = $raw | ConvertFrom-Json -ErrorAction Stop
      if ($null -ne $payload.command) { $cmd = [string]$payload.command }
      elseif ($null -ne $payload.Command) { $cmd = [string]$payload.Command }
    } catch {
      Write-Output '{ "permission": "allow" }'
      exit 0
    }
  }

  $deny = $false
  $reason = ""
  if ($cmd -match '(?i)install-globals\.ps1[^\r\n]*-Fresh') {
    $deny = $true
    $reason = "ISO-002: install-globals -Fresh is forbidden during Tasks 1–15 / WIP eval without captain override."
  } elseif ($cmd -match '(?i)install-globals\.ps1' -and $cmd -match '(?i)-Fresh\b') {
    $deny = $true
    $reason = "ISO-002: install-globals -Fresh is forbidden during Tasks 1–15 / WIP eval without captain override."
  }

  if ($deny) {
    $msg = $reason.Replace('\', '\\').Replace('"', '\"')
    Write-Output ("{ `"permission`": `"deny`", `"user_message`": `"$msg`", `"agent_message`": `"$msg`" }")
    exit 0
  }

  Write-Output '{ "permission": "allow" }'
  exit 0
} catch {
  Write-Output '{ "permission": "allow" }'
  exit 0
}

#Requires -Version 5.1
<#
.SYNOPSIS
  Selective preToolUse candidate stub (T10).

.NOTES
  NOT registered in default hooks/hooks.json. Default behaviour: allow.
  Narrow deny rules may be added after live-verified probe; do not claim preventive
  enforcement while unverified_in_this_environment.
#>
$ErrorActionPreference = "Continue"

try {
  $null = [Console]::In.ReadToEnd()
} catch { }

Write-Output '{ "permission": "allow" }'
exit 0

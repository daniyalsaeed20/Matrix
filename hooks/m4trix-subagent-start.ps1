#Requires -Version 5.1
<#
.SYNOPSIS
  Selective subagentStart candidate stub (T10).

.NOTES
  NOT registered in default hooks/hooks.json. Default behaviour: allow.
  Live-verify before claiming preventive enforcement.
#>
$ErrorActionPreference = "Continue"

try {
  $null = [Console]::In.ReadToEnd()
} catch { }

Write-Output '{ "permission": "allow" }'
exit 0

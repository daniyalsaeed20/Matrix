#Requires -Version 5.1
<#
.SYNOPSIS
  Kit-local helper: append a routing.evidence entry shape (no global Fresh / hooks).

.DESCRIPTION
  Prints a JSON fragment for ACTIVE_TASK.routing.evidence[]. Does not mutate globals.
  Evidence types allowed: task | subagent | artifact | limitation.
  Parent claim / "I acted as …" is intentionally unsupported.
#>
param(
  [Parameter(Mandatory = $true)][ValidateSet("task", "subagent", "artifact", "limitation")]
  [string]$Type,
  [Parameter(Mandatory = $true)][string]$Name,
  [string]$Ref = "",
  [string]$Note = ""
)

$entry = [ordered]@{
  type = $Type
  name = $Name
  ref  = $(if ([string]::IsNullOrWhiteSpace($Ref)) { $null } else { $Ref })
  note = $(if ([string]::IsNullOrWhiteSpace($Note)) { $null } else { $Note })
}

$entry | ConvertTo-Json -Compress
Write-Host ""
Write-Host "Append to ACTIVE_TASK.routing.evidence[] and add '$Name' to routing.invoked when Type is task|subagent|artifact."

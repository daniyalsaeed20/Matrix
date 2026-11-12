#Requires -Version 5.1
# Cursor user hook: beforeSubmitPrompt
# Documented output: continue, user_message only. Do NOT emit additional_context (ignored/unsupported).
# Never block routine prompts; kit reminder belongs on sessionStart.
$ErrorActionPreference = "Continue"

try {
  $null = [Console]::In.ReadToEnd()
} catch { }

Write-Output '{"continue":true}'
exit 0

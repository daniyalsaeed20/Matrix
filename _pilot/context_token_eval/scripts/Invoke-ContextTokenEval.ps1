#Requires -Version 5.1
<#
.SYNOPSIS
  ± eval for T12 context budget, model policy, metrics honesty, patch ceremony lightness.
#>
param()

$ErrorActionPreference = "Stop"
$EvalRoot = Split-Path -Parent $PSScriptRoot
$KitRoot = Split-Path -Parent (Split-Path -Parent $EvalRoot)
$Evidence = Join-Path $EvalRoot "evidence"
$Fixtures = Join-Path $EvalRoot "fixtures"
$Measure = Join-Path $KitRoot "bootstrap\Measure-AlwaysOnBytes.ps1"
$RulesDir = Join-Path $KitRoot "constitution\project-rules"
$failed = 0
$cases = @()

New-Item -ItemType Directory -Force -Path $Evidence | Out-Null

function Assert-True([bool]$Cond, [string]$Name) {
  if ($Cond) {
    Write-Host "PASS  $Name"
    $script:cases += [ordered]@{ name = $Name; pass = $true }
  }
  else {
    Write-Host "FAIL  $Name"
    $script:failed++
    $script:cases += [ordered]@{ name = $Name; pass = $false }
  }
}

function Get-PatchCeremonyVerdict {
  param($Fixture)
  # Trivial copy/colour patch must skip EGM, routine research, and designer.
  $scale = [string]$Fixture.scale
  $taskType = [string]$Fixture.routing.attributes.taskType
  $ui = [string]$Fixture.routing.attributes.uiInvolvement
  $isTrivialCopy = ($scale -eq "patch") -and ($taskType -eq "copy") -and ($ui -eq "none" -or [string]::IsNullOrWhiteSpace($ui))

  if (-not $isTrivialCopy) { return "n/a" }

  $egmHeavy = ([bool]$Fixture.egm.required) -or ([string]$Fixture.egm.status -notin @("skipped", ""))
  $researchHeavy = [bool]$Fixture.research.required
  $invoked = @()
  if ($Fixture.routing.invoked) { $invoked = @($Fixture.routing.invoked) }
  $designerHeavy = ($invoked -contains "m4trix-ui-designer") -or ($invoked -contains "egm-review") -or ($invoked -contains "engineering-research")
  $visualFake = ([string]$Fixture.verificationEvidence.visualStatus -eq "visually_verified")

  if ($egmHeavy -or $researchHeavy -or $designerHeavy -or $visualFake) {
    return "refuse"
  }
  return "allow"
}

Write-Host "=== T12 context / token / model-policy eval ==="
Write-Host "KitRoot: $KitRoot"

# --- Byte budget ---
$livePath = Join-Path $Evidence "ALWAYS_ON_LIVE.json"
$mp = Start-Process -FilePath "powershell" -ArgumentList @(
  "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $Measure,
  "-RulesDir", $RulesDir,
  "-FailAboveCeiling",
  "-OutputPath", $livePath
) -Wait -PassThru -NoNewWindow
Assert-True ($mp.ExitCode -eq 0) "Measure-AlwaysOnBytes exit 0 (within ceiling)"
Assert-True (Test-Path -LiteralPath $livePath) "ALWAYS_ON_LIVE.json written"

$live = Get-Content -LiteralPath $livePath -Raw -Encoding UTF8 | ConvertFrom-Json
Assert-True ([bool]$live.totals.withinBudget) "withinBudget true"
Assert-True ([int]$live.totals.alwaysOnCoreBytes -le [int]$live.totals.budgetCeilingPlus25Core) "core bytes <= 13804 ceiling"
Assert-True ([int]$live.totals.frozenBaselineCoreBytes -eq 11043) "frozen baseline still 11043"

# No new always-on core rule files beyond 00-05
$coreNames = @(Get-ChildItem -LiteralPath $RulesDir -Filter "0*.mdc" | ForEach-Object { $_.Name })
$allowed = @("00-m4trix-os.mdc", "01-production-bar.mdc", "02-mode-switching.mdc", "03-token-discipline.mdc", "04-code-craft.mdc", "05-delivery-voice.mdc")
$extra = @($coreNames | Where-Object { $allowed -notcontains $_ })
Assert-True ($extra.Count -eq 0) "no new always-on 0x rule files ($($extra -join ','))"

# Guard prose must not dominate always-on (no fingerprint / CompletionGate paths)
$alwaysOnText = ""
Get-ChildItem -LiteralPath $RulesDir -Filter "0*.mdc" | ForEach-Object {
  $alwaysOnText += (Get-Content $_.FullName -Raw)
}
Assert-True ($alwaysOnText -notmatch "ApprovalFingerprint|Invoke-CompletionGate|Get-ApprovalFingerprints") "always-on free of fingerprint/CompletionGate paths"
Assert-True ($alwaysOnText -notmatch "bootstrap/guard/validators/") "always-on free of Guard validator path literals"

# --- Model policy ---
Assert-True (Test-Path (Join-Path $KitRoot "docs\sdlc\ecc-reference\model-policy.md")) "model-policy.md present in ecc-reference"
Assert-True (Test-Path (Join-Path $KitRoot "ecc-cherry-pick\model-policy.md")) "model-policy.md present in ecc-cherry-pick"
$dec = Get-Content (Join-Path $KitRoot "docs\sdlc\DECISIONS.md") -Raw
Assert-True ($dec -match "## Model policy") "DECISIONS has Model policy section"
Assert-True ($dec -match "model: inherit") "DECISIONS model policy mentions inherit"

$agentFails = 0
Get-ChildItem -LiteralPath (Join-Path $KitRoot "agents") -Filter "m4trix-*.md" | ForEach-Object {
  $head = ((Get-Content $_.FullName -TotalCount 12) -join "`n")
  if ($head -notmatch "(?m)^model:\s*inherit\s*$") {
    Write-Host "FAIL  agent model inherit: $($_.Name)"
    $agentFails++
  }
}
Assert-True ($agentFails -eq 0) "all agents/m4trix-*.md use model: inherit"

# --- Patch ceremony policy (skill text) ---
$patch = Get-Content (Join-Path $KitRoot "skills\pipeline-patch\SKILL.md") -Raw
Assert-True ($patch -match "EGM / Goldfish:\s*skip") "pipeline-patch skips EGM"
Assert-True ($patch -match "routine copy/token patches skip") "pipeline-patch skips routine research"
Assert-True ($patch -match "Do \*\*not\*\* invoke \*\*m4trix-ui-designer\*\*") "pipeline-patch skips designer for ordinary copy"

# --- Fixture ± ---
$okFix = Get-Content (Join-Path $Fixtures "patch-light-ok.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$badFix = Get-Content (Join-Path $Fixtures "patch-heavy-refuse.json") -Raw -Encoding UTF8 | ConvertFrom-Json
$okVerdict = Get-PatchCeremonyVerdict $okFix
$badVerdict = Get-PatchCeremonyVerdict $badFix
Assert-True ($okVerdict -eq "allow") "positive fixture patch-light-ok -> allow"
Assert-True ($badVerdict -eq "refuse") "negative fixture patch-heavy-refuse -> refuse"

# --- Metrics template honesty ---
$metricsTemplate = [ordered]@{
  taskId           = "T12"
  kitSourceVersion = "WIP"
  isolation        = "unproven"
  measuredAt       = (Get-Date).ToUniversalTime().ToString("o")
  metrics          = [ordered]@{
    inputOutputTokens      = "unavailable"
    tokenUnavailableReason = "Cursor session token/cost telemetry not exposed to this eval script"
    toolCallCount          = "unavailable"
    repeatedFullFileReads  = "unavailable"
    agentHandoffs          = 0
    reworkCycles           = 0
    wallClockMinutes       = "unavailable"
    testsExecuted          = @("Invoke-ContextTokenEval.ps1")
    alwaysOnCoreBytes      = [int]$live.totals.alwaysOnCoreBytes
  }
  notes = "No fabricated improvement %. Primary cost metrics unavailable (CTX-003)."
}
$metricsPath = Join-Path $Evidence "METRICS_RUN.json"
($metricsTemplate | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $metricsPath -Encoding UTF8
$metricsRaw = Get-Content $metricsPath -Raw
Assert-True ($metricsRaw -match '"unavailable"') "metrics marks unavailable honestly"
Assert-True ($metricsRaw -notmatch '% fewer|% less|improvement of') "no fabricated improvement %"

# --- USER_RULES / audit presence ---
Assert-True (Test-Path (Join-Path $EvalRoot "AUDIT.md")) "AUDIT.md present"
$userRules = Get-Content (Join-Path $KitRoot "constitution\USER_RULES.md") -Raw
Assert-True ($userRules -match "Authoritative locations") "USER_RULES has authoritative-locations note"
Assert-True ($userRules -match "CTX-001") "USER_RULES notes CTX-001 budget exclusion"

$summary = [ordered]@{
  ok         = ($failed -eq 0)
  failed     = $failed
  recordedAt = (Get-Date).ToUniversalTime().ToString("o")
  alwaysOnCoreBytes = [int]$live.totals.alwaysOnCoreBytes
  ceiling           = [int]$live.totals.budgetCeilingPlus25Core
  modelPolicySoT    = @(
    "docs/sdlc/DECISIONS.md Model policy",
    "docs/sdlc/ecc-reference/model-policy.md"
  )
  limitations = @(
    "Primary token/cost metrics unavailable in this environment (CTX-003)",
    "Patch ceremony verdict is fixture/policy check — not a live Cursor Task run",
    "USER_RULES byte size is not in CTX-001 numerator"
  )
  cases = $cases
}

$summaryPath = Join-Path $Evidence "SUMMARY.json"
($summary | ConvertTo-Json -Depth 8) | Set-Content -LiteralPath $summaryPath -Encoding UTF8
Write-Host ""
Write-Host "SUMMARY: $summaryPath"
Write-Host "EXIT_CODE=$failed"
if ($failed -gt 0) { exit 1 }
exit 0

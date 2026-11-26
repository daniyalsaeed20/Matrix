#Requires -Version 5.1
<#
.SYNOPSIS
  Positive + negative UI designer eval for T8 (UI-001…UI-003, EVAL-001).
  Static/content asserts + fixture verdict matrix. No Guard visualStatus plug.
#>
param()

$ErrorActionPreference = "Stop"
$EvalRoot = Split-Path -Parent $PSScriptRoot
$KitRoot = Split-Path -Parent (Split-Path -Parent $EvalRoot)
$LocalFixtures = Join-Path $EvalRoot "fixtures"
$EvidenceDir = Join-Path $EvalRoot "evidence"
$EvalRouting = Join-Path $KitRoot "bootstrap\guard\Evaluate-Routing.ps1"
$failed = 0

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Assert-True([bool]$Cond, [string]$Msg) {
  if ($Cond) { Write-Host "PASS  $Msg" }
  else { Write-Host "FAIL  $Msg"; $script:failed++ }
}

function Get-UiDesignerVerdict {
  param([Parameter(Mandatory = $true)]$Fixture)
  $ui = [string]$Fixture.uiInvolvement
  $expectDesigner = $true
  if ($null -ne $Fixture.PSObject.Properties["expectDesigner"]) {
    $expectDesigner = [bool]$Fixture.expectDesigner
  } elseif ($ui -eq "patch" -or $ui -eq "none") {
    $expectDesigner = $false
  }

  $designerInvoked = [bool]$Fixture.designerInvoked
  $rendered = [bool]$Fixture.rendered
  $designDocOnly = [bool]$Fixture.designDocOnly
  $notes = @($Fixture.critiqueNotes)
  $hasCritique = ($notes | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) }).Count -gt 0

  if (-not $expectDesigner) {
    # Trivial patch: designer must not be required
    if ($designerInvoked) { return "fail" }
    return "pass"
  }

  # Significant UI
  if ($designDocOnly -or -not $designerInvoked -or -not $rendered -or -not $hasCritique) {
    return "fail"
  }
  return "pass"
}

Write-Host "=== UI designer eval (T8) ==="
Write-Host "EvalRoot: $EvalRoot"
Write-Host "KitRoot:  $KitRoot"

# --- Agent presence ---
$agentPath = Join-Path $KitRoot "agents\m4trix-ui-designer.md"
$agent = $null
Assert-True (Test-Path $agentPath) "agents/m4trix-ui-designer.md present"
if (Test-Path $agentPath) {
  $agent = Get-Content $agentPath -Raw
  Assert-True ($agent -match "design.?doc.?only|Design-doc-only") "agent: design-doc-only fail limit"
  Assert-True ($agent -match "critique") "agent: critique in mission"
  Assert-True ($agent -match "Disposition|design-system|verifier") "agent: disposition vs other roles"
  Assert-True ($agent -match "Journey|journey") "agent: journey workflow"
  Assert-True ($agent -match "skip|Trivial|patch") "agent: patch skip"
}

$cursorAgent = Join-Path $KitRoot ".cursor\agents\m4trix-ui-designer.md"
Assert-True (Test-Path $cursorAgent) ".cursor ui-designer mirror present"

# --- MANIFEST ---
$manifest = Get-Content (Join-Path $KitRoot "bootstrap\MANIFEST.json") -Raw
Assert-True ($manifest -match "m4trix-ui-designer\.md") "MANIFEST lists m4trix-ui-designer"

# --- USER_RULES thin pointer ---
$userRules = Get-Content (Join-Path $KitRoot "constitution\USER_RULES.md") -Raw
Assert-True ($userRules -match "m4trix-ui-designer") "USER_RULES thin pointer to ui-designer"

# --- Pipelines ---
$mod = Get-Content (Join-Path $KitRoot "skills\pipeline-module\SKILL.md") -Raw
Assert-True ($mod -match "m4trix-ui-designer") "pipeline-module: significant UI designer"
Assert-True ($mod -match "Design-doc-only|design-doc-only") "pipeline-module: design-doc-only fail"

$prod = Get-Content (Join-Path $KitRoot "skills\pipeline-product\SKILL.md") -Raw
Assert-True ($prod -match "m4trix-ui-designer") "pipeline-product: significant UI designer"

$patch = Get-Content (Join-Path $KitRoot "skills\pipeline-patch\SKILL.md") -Raw
Assert-True ($patch -match "m4trix-ui-designer") "pipeline-patch: mentions designer skip"
Assert-True ($patch -match "Do \*\*not\*\* invoke|do not invoke|skip") "pipeline-patch: skip designer for patches"

# --- Disposition pointers ---
$ds = Get-Content (Join-Path $KitRoot "agents\m4trix-design-system.md") -Raw
Assert-True ($ds -match "m4trix-ui-designer") "design-system disposition pointer"

$fl = Get-Content (Join-Path $KitRoot "agents\m4trix-flutter.md") -Raw
Assert-True ($fl -match "m4trix-ui-designer") "flutter disposition pointer"

$ver = Get-Content (Join-Path $KitRoot "agents\m4trix-verifier.md") -Raw
Assert-True ($ver -match "design-doc-only|m4trix-ui-designer") "verifier significant-UI / disposition"

# --- Routing: significant UI → ui-designer mandatory present ---
$attrsPath = Join-Path $KitRoot "_pilot\routing_eval\fixtures\attrs-significant-ui.json"
$calcOut = Join-Path $EvidenceDir "calc-significant-ui.json"
Assert-True (Test-Path $attrsPath) "routing attrs-significant-ui fixture present"
Assert-True (Test-Path $EvalRouting) "Evaluate-Routing.ps1 present"
& powershell -NoProfile -ExecutionPolicy Bypass -File $EvalRouting `
  -AttributesPath $attrsPath -KitRoot $KitRoot -OutputPath $calcOut 2>&1 | Out-Null
Assert-True ($LASTEXITCODE -eq 0) "Evaluate-Routing significant UI exit 0"
$calc = $null
if (Test-Path $calcOut) {
  try { $calc = Get-Content $calcOut -Raw | ConvertFrom-Json } catch { $calc = $null }
}
Assert-True ($null -ne $calc) "calc-significant-ui.json parseable"
if ($null -ne $calc) {
  $mand = @($calc.mandatoryAgents)
  $def = @($calc.deferred)
  $hasDesigner = $false
  foreach ($x in $mand) { if ([string]$x -eq "m4trix-ui-designer") { $hasDesigner = $true } }
  $deferredDesigner = $false
  foreach ($d in $def) {
    if ($null -eq $d) { continue }
    $n = $null
    if ($d.PSObject.Properties["name"]) { $n = [string]$d.name }
    if ($n -eq "m4trix-ui-designer") { $deferredDesigner = $true }
  }
  Assert-True $hasDesigner "routing: m4trix-ui-designer mandatory on significant UI"
  Assert-True (-not $deferredDesigner) "routing: m4trix-ui-designer not deferred"
}

# --- Fixture matrix ---
$fixtureFiles = @(
  "significant-ui-path-ok.json",
  "weak-hierarchy-critique-ok.json",
  "design-doc-only-fail.json",
  "trivial-patch-skip-ok.json"
)

$matrixRows = @()
foreach ($name in $fixtureFiles) {
  $path = Join-Path $LocalFixtures $name
  Assert-True (Test-Path $path) "fixture present: $name"
  $fx = Get-Content $path -Raw | ConvertFrom-Json
  $got = Get-UiDesignerVerdict -Fixture $fx
  $expect = [string]$fx.expectedVerdict
  $ok = ($got -eq $expect)
  Assert-True $ok ("fixture $($fx.id): expected=$expect got=$got")
  $matrixRows += [pscustomobject]@{ id = $fx.id; expected = $expect; got = $got; pass = $ok }
}

# Weak-hierarchy defect seed
$defectPath = Join-Path $LocalFixtures "defects\weak-hierarchy.md"
Assert-True (Test-Path $defectPath) "defect seed weak-hierarchy.md present"
$defect = Get-Content $defectPath -Raw
Assert-True ($defect -match "weak.?hierarchy|hierarchy") "defect seed describes hierarchy"
Assert-True ($defect -match "critique|Expected designer") "defect seed expects critique"

Assert-True (Test-Path (Join-Path $EvalRoot "LIVE_PROCEDURE.md")) "live procedure documented"
Assert-True (Test-Path (Join-Path $EvalRoot "README.md")) "README present"

# Live limitation honesty (optional)
$livePos = Join-Path $EvidenceDir "live-positive.md"
$liveNeg = Join-Path $EvidenceDir "live-negative.md"
$liveLim = Join-Path $EvidenceDir "live-limitation.md"
$liveDone = (Test-Path $livePos) -and (Test-Path $liveNeg)
if (-not $liveDone -and -not (Test-Path $liveLim)) {
  @"
# Live UI designer limitation

Status: **pending captain-assisted live render/critique** (UI-001).

Script agent presence + fixture ± **passed** in this run.
T9 owns visualStatus enum/validator; do not fabricate screenshots.

When captain runs LIVE_PROCEDURE.md, replace this file with live-positive.md / live-negative.md results.
"@ | Set-Content -Path $liveLim -Encoding UTF8
}

# Report
$reportPath = Join-Path $EvidenceDir "REPORT.md"
$ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss zzz"
$matrixMd = ($matrixRows | ForEach-Object {
  "| $($_.id) | $($_.expected) | $($_.got) | $(if ($_.pass) { 'PASS' } else { 'FAIL' }) |"
}) -join "`n"

$report = @"
# UI designer eval REPORT (T8)

**When:** $ts  
**KitRoot:** $KitRoot  
**Failures:** $failed

## Fixture matrix

| Id | Expected | Got | Result |
|----|----------|-----|--------|
$matrixMd

## Kit checks

| Check | Notes |
|-------|-------|
| Agent present | agents/m4trix-ui-designer.md |
| Routing significant UI | ui-designer mandatory, not deferred |
| Pipelines + disposition | module/product/patch + design-system/flutter/verifier |
| Defect seed | fixtures/defects/weak-hierarchy.md |

## Live ±

$(if ($liveDone) { "Recorded: live-positive.md + live-negative.md" } else { "Not executed this run — limitation: live-limitation.md (script ± still required and executed)" })

## Verdict

$(if ($failed -eq 0) { "PASS (script layer). Live layer: $(if ($liveDone) { 'PASS' } else { 'PENDING/LIMITATION' })" } else { "FAIL ($failed)" })
"@
Set-Content -Path $reportPath -Value $report -Encoding UTF8
Write-Host ""
Write-Host "Report: $reportPath"

if ($failed -gt 0) {
  Write-Host "RESULT: $failed UI designer eval failure(s)"
  exit 1
}
Write-Host "RESULT: UI designer eval passed (script layer)"
exit 0

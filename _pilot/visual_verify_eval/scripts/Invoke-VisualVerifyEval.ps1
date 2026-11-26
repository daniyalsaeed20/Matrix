#Requires -Version 5.1
<#
.SYNOPSIS
  Positive + negative visual verification eval for T9 (VIS-001/002, UI-003, GRD-002, EVAL-001).
#>
param()

$ErrorActionPreference = "Stop"
$EvalRoot = Split-Path -Parent $PSScriptRoot
$KitRoot = Split-Path -Parent (Split-Path -Parent $EvalRoot)
$EvidenceDir = Join-Path $EvalRoot "evidence"
$DefectsDir = Join-Path $EvalRoot "fixtures\defects"
$GuardTests = Join-Path $KitRoot "bootstrap\guard\tests\Invoke-GuardTests.ps1"
$failed = 0

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Assert-True([bool]$Cond, [string]$Msg) {
  if ($Cond) { Write-Host "PASS  $Msg" }
  else { Write-Host "FAIL  $Msg"; $script:failed++ }
}

Write-Host "=== Visual verification eval (T9) ==="
Write-Host "EvalRoot: $EvalRoot"
Write-Host "KitRoot:  $KitRoot"

# --- Validator present ---
$visualPs1 = Join-Path $KitRoot "bootstrap\guard\validators\visual.ps1"
Assert-True (Test-Path $visualPs1) "validators/visual.ps1 present"
if (Test-Path $visualPs1) {
  $vsrc = Get-Content $visualPs1 -Raw
  Assert-True ($vsrc -match "visually_verified") "visual.ps1: visually_verified rule"
  Assert-True ($vsrc -match "method") "visual.ps1: method honesty"
  Assert-True ($vsrc -match "static") "visual.ps1: rejects static-only verified"
}

# --- Guard fixtures on disk ---
$fx = Join-Path $KitRoot "bootstrap\guard\tests\fixtures"
Assert-True (Test-Path (Join-Path $fx "valid-visual-verified.json")) "fixture valid-visual-verified"
Assert-True (Test-Path (Join-Path $fx "valid-visual-blocked.json")) "fixture valid-visual-blocked"
Assert-True (Test-Path (Join-Path $fx "invalid-visual-static-verified.json")) "fixture invalid-visual-static-verified"
Assert-True (Test-Path (Join-Path $fx "invalid-visual-missing-artifact.json")) "fixture invalid-visual-missing-artifact"
Assert-True (Test-Path (Join-Path $fx "visual-artifacts\sample-render-note.md")) "real Guard sample artifact on disk"

# --- Eval sample artifact ---
$sample = Join-Path $EvidenceDir "sample-render-note.md"
Assert-True (Test-Path $sample) "eval evidence/sample-render-note.md exists (real file)"

# --- Defect gallery ---
foreach ($d in @("weak-hierarchy.md", "spacing.md", "overflow.md", "shared-component-regression.md")) {
  Assert-True (Test-Path (Join-Path $DefectsDir $d)) "defect fixture $d"
}
$shared = Get-Content (Join-Path $DefectsDir "shared-component-regression.md") -Raw
Assert-True ($shared -match "AppInfoCard|app_info_card") "shared-component defect refs ui_craft AppInfoCard"
Assert-True ($shared -match "VIS-002|neighbor") "shared-component defect cites neighbor/VIS-002"

# --- Production bar + verifier + pipelines ---
$bar = Get-Content (Join-Path $KitRoot ".cursor\rules\01-production-bar.mdc") -Raw
Assert-True ($bar -match "visualStatus|verificationEvidence") "production-bar: visualStatus honesty"
Assert-True ($bar -match "skip|patches") "production-bar: patch skip full visual bar"

$ver = Get-Content (Join-Path $KitRoot "agents\m4trix-verifier.md") -Raw
Assert-True ($ver -match "visualStatus|verificationEvidence") "verifier: visual checklist"
Assert-True ($ver -match "Validators.*visual|,visual") "verifier: Guard visual"

$mod = Get-Content (Join-Path $KitRoot "skills\pipeline-module\SKILL.md") -Raw
Assert-True ($mod -match "visualStatus|verificationEvidence") "pipeline-module: visualStatus"
Assert-True ($mod -match "visual") "pipeline-module: Guard visual"

$patch = Get-Content (Join-Path $KitRoot "skills\pipeline-patch\SKILL.md") -Raw
Assert-True ($patch -match "visual") "pipeline-patch: mentions visual skip"

$tmpl = Get-Content (Join-Path $KitRoot "templates\sdlc\ACTIVE_TASK.json") -Raw
Assert-True ($tmpl -match "verificationEvidence") "ACTIVE_TASK template has verificationEvidence"
Assert-True ($tmpl -match "visually_verified") "template documents visualStatus enum"

# --- ui_craft_eval evidence expectation (widget ≠ visual pass) ---
$uiCraftReadme = Join-Path $KitRoot "_pilot\ui_craft_eval\README.md"
Assert-True (Test-Path $uiCraftReadme) "ui_craft_eval present"
$sampleRaw = Get-Content $sample -Raw
Assert-True ($sampleRaw -match "visually_verified") "eval sample states widget/golden ≠ visually_verified alone"

# --- Routing policy requires visual validator on significant UI ---
$policy = Get-Content (Join-Path $KitRoot "templates\sdlc\routing-policy.json") -Raw
Assert-True ($policy -match '"id"\s*:\s*"significant-ui"') "routing-policy significant-ui rule"
Assert-True ($policy -match '"visual"') "routing-policy includes visual validator"

# --- Run Guard ± suite (includes visual fixtures) ---
Assert-True (Test-Path $GuardTests) "Invoke-GuardTests.ps1 present"
$guardOut = & powershell -NoProfile -ExecutionPolicy Bypass -File $GuardTests 2>&1 | Out-String
$guardCode = $LASTEXITCODE
Assert-True ($guardCode -eq 0) "Invoke-GuardTests.ps1 EXIT_CODE=0 (includes visual ±)"
Assert-True ($guardOut -match "valid-visual-verified ok=true") "Guard report: valid-visual-verified ok"
Assert-True ($guardOut -match "valid-visual-blocked ok=true") "Guard report: valid-visual-blocked ok"
Assert-True ($guardOut -match "invalid-visual-static-verified ok=false") "Guard report: static-verified fails"
Assert-True ($guardOut -match "invalid-visual-missing-artifact ok=false") "Guard report: missing-artifact fails"

# --- Direct negative spot-check: static method must fail visual validator ---
$runner = Join-Path $KitRoot "bootstrap\guard\Invoke-M4trixGuard.ps1"
$staticFx = Join-Path $fx "invalid-visual-static-verified.json"
$tmpOut = Join-Path $env:TEMP ("m4trix-visual-eval-{0}.json" -f [guid]::NewGuid().ToString("N"))
& powershell -NoProfile -ExecutionPolicy Bypass -File $runner -TaskPath $staticFx -Validators "task-state,visual" -OutputPath $tmpOut 2>&1 | Out-Null
$staticCode = $LASTEXITCODE
Assert-True ($staticCode -ne 0) "direct static-verified Guard non-zero"
if (Test-Path $tmpOut) {
  $staticResult = Get-Content $tmpOut -Raw | ConvertFrom-Json
  Assert-True ($staticResult.ok -eq $false) "direct static-verified ok=false"
  Remove-Item -Force $tmpOut -ErrorAction SilentlyContinue
}

# --- Write evidence report ---
$reportPath = Join-Path $EvidenceDir "REPORT.md"
@"
# Visual verify eval report

- Ran: ``Invoke-VisualVerifyEval.ps1``
- Guard tests exit: $guardCode
- Failures in this script: $failed
- Timestamp: $(Get-Date -Format o)
"@ | Set-Content -Path $reportPath -Encoding UTF8
Assert-True (Test-Path $reportPath) "evidence/REPORT.md written"

Write-Host ""
if ($failed -gt 0) {
  Write-Host "RESULT: $failed visual_verify_eval failure(s)"
  exit 1
}
Write-Host "RESULT: visual_verify_eval PASS"
exit 0

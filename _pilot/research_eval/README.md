# Research eval fixture (T6)

Behavioural ± evaluation for Engineering Research (RSH-001…RSH-004, GRD-002, EVAL-001).

## What it proves

| Case | Expect |
|------|--------|
| Unfamiliar / researchNeeded | engineering-research required; valid findings+sources → Guard ok |
| Trivial copy patch | research.required=false → Guard ok |
| Recurring patch defect | research still required → Guard ok with findings |
| Empty findings when required | Guard ok=false |
| Fabricated/placeholder sources | Guard ok=false |
| No alternatives (rubber-stamp) | Guard ok=false |
| Web unavailable + local sources | Guard ok=true |
| Sample findings artifact | present under evidence/ |

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/research_eval/scripts/Invoke-ResearchEval.ps1
```

## Live prompts

See `LIVE_PROCEDURE.md`. Script Guard ± is the automated bar; live prompts document agent behaviour when captain runs them.

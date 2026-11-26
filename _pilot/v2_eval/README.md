# v2_eval (T13) — Comprehensive behavioural evaluation

Integrated re-run of accepted v2 capability suites vs Task 1 baseline, plus cross-capability CompletionGate ± fixtures and an RB-01…RB-10 checklist draft.

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/v2_eval/scripts/Invoke-V2IntegratedEval.ps1
```

## Outputs

| Path | Purpose |
|------|---------|
| `MASTER_REPORT.md` | Human SoT vs T1 |
| `evidence/SUMMARY.json` | Machine aggregate |
| `evidence/RB_CHECKLIST.md` | Release-blocker draft |
| `evidence/suite-*.json` / logs | Per-suite exit records |
| `evidence/gate-integrated-*.json` | Integrated ± gate results |

## Non-scope

No feature remediations inside T13. Failures → proposed remediation task IDs in BACKLOG. No fabricated live agent runs.

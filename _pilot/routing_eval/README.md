# Routing eval fixture (T5)

Behavioural ± evaluation for Intelligent Routing (RTE-001…RTE-004, GRD-002, EVAL-001).

## What it proves

| Case | Expect |
|------|--------|
| Flutter trivial patch | Minimal route; no security/ui-designer mandatory |
| Significant UI (post-T8) | ui-designer mandatory + present; design-system mandatory; not deferred |
| Auth/security | m4trix-security mandatory + evidence |
| Recovery active | debugger + pipeline-recovery |
| Mixed-stack | flutter+nodejs conditional agents |
| researchNeeded | engineering-research required (skill present post-T6) + research validator |
| Omit-mandatory | Guard `ok=false` |
| Parent impersonation | Guard `ok=false` |
| Evidence limitation + ack | Guard `ok=true` with warning |

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/routing_eval/scripts/Invoke-RoutingEval.ps1
```

## Live ± (RTE-004)

See `LIVE_PROCEDURE.md`. Script-only green is **not** sufficient for T5 accept without live procedure execution or an honest limitation record under `evidence/`.

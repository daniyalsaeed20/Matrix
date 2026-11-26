# context_token_eval (T12)

Positive + negative behavioural checks for context budget, model policy, metrics honesty, and patch ceremony lightness.

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/context_token_eval/scripts/Invoke-ContextTokenEval.ps1
```

Expect `EXIT_CODE=0` and `evidence/SUMMARY.json` with `ok: true`.

## Artifacts

| Path | Role |
|------|------|
| `AUDIT.md` | Instruction ownership map |
| `fixtures/patch-light-ok.json` | + trivial copy stays light |
| `fixtures/patch-heavy-refuse.json` | − trivial copy wrongly pulls EGM/research/designer |
| `evidence/ALWAYS_ON_LIVE.json` | Live byte measure (does not overwrite T1 baseline) |
| `evidence/METRICS_RUN.json` | Metrics template with honest `unavailable` |
| `evidence/SUMMARY.json` | Pass/fail rollup |

## Related

- `bootstrap/Measure-AlwaysOnBytes.ps1`
- `_pilot/v2_baseline/METRICS_PROTOCOL.md`
- `docs/sdlc/ecc-reference/model-policy.md`

# v2 baseline harness (Task 1)

Measurement-only harness for M4TR!X v1.6.0 before behaviour changes.

**Do not** treat this folder as production kit behaviour. **Do not** Fresh-install WIP v2.

## Artifacts

| File | Purpose |
|------|---------|
| `BASELINE_REPORT.md` | Authoritative T1 baseline summary |
| `METRICS_PROTOCOL.md` | How to capture comparable metrics |
| `ALWAYS_ON_BYTES.json` | Always-on project-rules byte baseline |
| `SMOKE_RESULT.md` | smoke-tests.ps1 run record |
| `_smoke_raw.txt` | Full smoke stdout |
| `RUNTIME_INVENTORY.json` | Installed `~/.cursor` m4trix inventory |
| `ISOLATION_PROCEDURE.md` | Sibling eval workspace procedure |
| `ISOLATION_FINGERPRINT.json` | Hash inventory + isolation verdict |
| `HOOK_PROBE.json` | Docs vs kit vs installed hook events |
| `KNOWN_FAILURES.md` | Honest known soft failures / limits |

## Harness layout for later tasks

```text
_pilot/v2_baseline/     ← frozen T1 evidence (this folder)
_pilot/v2_eval/         ← reserved for T13 integrated reports (not created here)
_pilot/<capability>_eval/  ← created by later tasks
```

## Isolation label

Current live-eval isolation status: **`isolation:unproven`** (see `ISOLATION_FINGERPRINT.json`).
Scripts and captain procedures remain valid under that label.

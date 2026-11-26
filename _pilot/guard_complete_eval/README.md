# guard_complete_eval (T10)

Positive + negative behavioural eval for completion-blocking Guard + honest selective hooks.

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/guard_complete_eval/scripts/Invoke-GuardCompleteEval.ps1
```

## Covers

- `completion` validator ± fixtures
- `Invoke-CompletionGate` refuse on fail
- Bypass matrix present
- Default `hooks.json` advisory-only; deny scripts present but unregistered
- Hook probe T10 re-validation artifact

## Live deny fire

Optional: [LIVE_PROCEDURE.md](LIVE_PROCEDURE.md). Not required for T10 script pass.

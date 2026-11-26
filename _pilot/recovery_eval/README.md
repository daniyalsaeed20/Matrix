# Recovery eval fixture (T4)

Behavioural ± evaluation for Intelligent Recovery + Debugger (REC-001…REC-006, EVAL-001).

## What it proves

| Case | Expect |
|------|--------|
| Strategy-change after fail | Guard `ok=true` |
| Escalation at budget | Guard `ok=true` with `escalation.reported` |
| Repeat rejected approach | Guard `ok=false` |
| Over budget without escalate | Guard `ok=false` |
| Rename-only attempt | Guard `ok=false` |
| Protected regression mid-recovery | Guard `ok=false` (regression + recovery) |
| Handoff persistence | attemptCount survives simulated new-chat handoff |

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/recovery_eval/scripts/Invoke-RecoveryEval.ps1
```

## Non-scope

- Router / selective hooks
- Live IDE Debug-mode automation (Cursor Debug still exists; documented as preserved)
- Claiming debugger owns feature implementation (agent text forbids it; checked by path presence)

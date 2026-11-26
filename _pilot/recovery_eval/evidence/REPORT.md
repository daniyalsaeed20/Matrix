# Recovery eval report (T4)

Measured: 2026-11-25 15:30:05
KitRoot: E:\development\Matrix
Failures: 0

## Results

| Case | Expected | Artifact |
|------|----------|----------|
| Strategy-change | ok=true | evidence/guard_strategy_change.json |
| Escalated | ok=true | evidence/guard_escalated.json |
| Repeat rejected | ok=false | evidence/guard_repeat_rejected.json |
| Over budget | ok=false | evidence/guard_over_budget.json |
| Rename-only | ok=false | evidence/guard_rename_only.json |
| Protected mid-recovery | ok=false | evidence/guard_protected_mid.json |
| Handoff persistence | attemptCount=2 + ok=true | evidence/guard_handoff_continued.json |

## Notes

- Triggers/non-triggers: TRIGGERS.md
- Debugger agent present; forbids owning production feature impl
- No Router / selective hooks / Fresh install in this eval

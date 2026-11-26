# Regression Lock eval report

| Field | Value |
|-------|-------|
| Task | T3 |
| Measured | 2026-11-25 15:30:01 +05:00 |
| Fixture | `_pilot/regression_lock_eval` |
| Failures | 0 |

## Checks

| Case | Expected | Result |
|------|----------|--------|
| Baseline 5 pass / 5 fail | non-zero flutter test | see baseline_behaviours_test.txt |
| Intentional regress | broken normalizeEmail fails | see scenario_fixed_test.txt |
| Coordinated IdPad fix | B09+B10 fixed helpers pass | see scenario_fixed_test.txt |
| Guard valid unit | ok=true | guard_valid_regression.json |
| Guard protected fail | ok=false | guard_protected_fail.json |
| Guard integrity violate | ok=false | guard_integrity_fail.json |
| Guard missing baseline | ok=false | guard_missing_baseline.json |
| Dirty path preserved | user_notes.md exists | True |

## Limitations

- Live IDE completion-gate reject-on-regression is captain procedure until T10.
- Baseline flutter suite is expected red (5 known fails); green is not the success signal.

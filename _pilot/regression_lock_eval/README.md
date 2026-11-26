# Regression Lock eval (`_pilot/regression_lock_eval`)

Ten independently observable behaviours for **T3 Regression Lock** (REG-001…REG-006).

## Baseline

| | |
|--|--|
| Protected (pass) | B01–B05 |
| Known failing | B06–B10 |
| Shared working | `TextNorm` (B05) |
| Shared defective | `IdPad` (B09 + B10) — coordinated-fix target |
| Dirty path | `user_notes.md` |

Inventory: [`INVENTORY.md`](INVENTORY.md)

## Commands

```powershell
cd _pilot/regression_lock_eval
flutter pub get
flutter test test/behaviours_test.dart
# Expect non-zero: 5 pass + 5 fail

flutter test test/scenario_fixed_test.dart
# Expect non-zero: repairs pass; intentional regress fails

powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Invoke-RegressionEval.ps1
```

## Guard

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/Invoke-M4trixGuard.ps1 `
  -TaskPath bootstrap/guard/tests/fixtures/valid-regression-unit.json `
  -Validators task-state,regression
```

Negative fixtures: `invalid-regression-protected-fail`, `invalid-regression-integrity`, `invalid-regression-missing-baseline`.

# Behaviour inventory — regression_lock_eval

**baselineRev:** `v1.6.0@_pilot/v2_baseline/2026-11-25`  
**Measured:** after `flutter test test/behaviours_test.dart`

| ID | Behaviour | State (baseline) | Evidence | Notes |
|----|-----------|------------------|----------|-------|
| B01 | normalizeEmail | verified_working | test:B01 | Protected |
| B02 | parseAmount | verified_working | test:B02 | Protected |
| B03 | clampPercent | verified_working | test:B03 | Protected |
| B04 | slugify | verified_working | test:B04 | Protected |
| B05 | formatPersonLabel | verified_working | test:B05 | Uses shared TextNorm |
| B06 | validateUsername | verified_failing | test:B06 | Accepts empty |
| B07 | computeDiscount | verified_failing | test:B07 | Wrong formula |
| B08 | mergeTags | verified_failing | test:B08 | No dedupe/sort |
| B09 | nextInvoiceId | verified_failing | test:B09 | Shared IdPad bug |
| B10 | formatMoneyCode | verified_failing | test:B10 | Shared IdPad bug |

**dirtyPaths:** `user_notes.md`

Independently observable: each ID has a real function + assertion — not mocked status flags.

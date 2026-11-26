# T14 pilot report — t14_disposable

| Field | Value |
|-------|-------|
| Task | T14 |
| App path | `E:\development\Matrix\_pilot\v2_real_pilots\apps\t14_disposable` |
| Recoverable boundary | Disposable folder itself (delete = revert) |
| Captain auth (verbatim) | create a new pilot and test on it, once test gets completed, delete pilot + Approve plan T14 Disposable pilot create-test-delete |
| Auth recorded at | 2026-11-25T10:46:00Z |
| Compare to v1.6.0 | n/a — kit apply used VERSION **1.6.0** sources; globals unchanged |
| Kit globals | 1.6.0 |
| Isolation | isolation:unproven |
| Report status | complete |
| Corpus class | **synthetic disposable** (partial; weaker than two real product apps) |

## Pre-flight

| Check | Result |
|-------|--------|
| Path matches auth | PASS — kit-owned `_pilot/v2_real_pilots/apps/t14_disposable` |
| Boundary exists | PASS — created via `flutter create` |
| HEAD SHA / copy fingerprint | no .git in workspace; folder path is boundary |
| Dirty files before pilot | n/a (new create) |
| Data/config constraints | none (throwaway) |

## Representative tasks run

| Shape | Prompt / brief (summary) | Result | Evidence |
|-------|--------------------------|--------|----------|
| P1 Partial module repair | — | skip | No multi-module product surface |
| P2 Recurring defect | — | skip | No recurring product defect corpus |
| P3 Unfamiliar requirement | — | skip | No unfamiliar integration brief |
| P4 Localized fix | Change subtitle string; update widget test | **pass** | analyze/test after P4 exit 0 |
| P5 Polished UI | — | skip | No significant UI designer brief |
| P6 Mixed-stack routing | — | skip | Flutter-only disposable |

Skip reason: synthetic disposable pilot scoped to apply + analyze/test + P4 only per approved plan.

## Apply + verification

| Step | Exit | Log |
|------|------|-----|
| apply-to-workspace -DryRun | 0 | `apply-dryrun.log.txt` |
| apply-to-workspace | 0 | `apply.log.txt` |
| Marker `.m4trix-kit.json` | present | version 1.6.0; stacks flutter |
| flutter analyze (before P4) | 0 | `flutter-analyze-before.log.txt` |
| flutter test (before P4) | 0 | `flutter-test-before.log.txt` |
| flutter analyze (after P4) | 0 | `flutter-analyze-after-p4.log.txt` |
| flutter test (after P4) | 0 | `flutter-test-after-p4.log.txt` |

## Metrics (honest)

```json
{
  "taskId": "T14",
  "app": "E:\\development\\Matrix\\_pilot\\v2_real_pilots\\apps\\t14_disposable",
  "kitSourceVersion": "1.6.0",
  "isolation": "unproven",
  "measuredAt": "2026-11-25T10:50:00Z",
  "metrics": {
    "inputOutputTokens": "unavailable",
    "tokenUnavailableReason": "CTX-003; not captured this session",
    "toolCallCount": "unavailable",
    "reworkCycles": 0,
    "wallClockMinutes": "unavailable",
    "testsExecuted": [
      "flutter analyze → 0",
      "flutter test → 0",
      "flutter analyze after P4 → 0",
      "flutter test after P4 → 0",
      "apply-to-workspace → 0"
    ]
  },
  "notes": "No fabricated improvement %. Synthetic disposable only."
}
```

## v1.6.0 comparison

Globals and apply source were already 1.6.0. No separate second-machine compare run.

## Fail / edge observations

- commit-msg hook skipped (no `.git` in disposable workspace) — expected
- Nested under kit `_pilot/` — isolation remains unproven

## Revert evidence

| Step | Result |
|------|--------|
| Revert method | Delete entire `apps/t14_disposable/` tree after evidence written |
| Post-revert status | Confirmed absent (see MASTER + delete log) |
| Residual dirty files | none expected under apps/ |

## Limitations

- Not a real captain product app
- P1–P3 / P5–P6 not exercised
- Residual real-world field risk remains for T15 unless further apps authorized (BL-003)

## Sign-off

| Role | Status |
|------|--------|
| Agent complete | yes — create/apply/test/P4/evidence/delete |
| Captain review | pending `accept Task 14` (partial synthetic corpus) |

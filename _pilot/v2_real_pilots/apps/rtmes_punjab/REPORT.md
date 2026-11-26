# T14 pilot report — rtmes_punjab

| Field | Value |
|-------|-------|
| Task | T14 |
| App path | `D:\rtmes_punjab\rtmes_punjab` |
| Recoverable boundary | git branch `pilot/t14-v2` |
| Captain auth (verbatim) | Authorize T14 pilots: D:\rtmes_punjab\rtmes_punjab on pilot/t14-v2 — partial set; shapes=P4; compare-to-1.6.0=no; preserve-data=do not touch .env, Firebase prod, or unrelated dirty files |
| Auth recorded at | 2026-11-26T04:22:00Z |
| Compare to v1.6.0 | no |
| Kit globals | 1.6.0 |
| Isolation | isolation:unproven |
| Report status | complete |
| Corpus class | **real product app** (partial shapes=P4 only) |

## Pre-flight

| Check | Result |
|-------|--------|
| Path matches auth | PASS |
| Boundary exists (branch checkout or copy path) | PASS — created `pilot/t14-v2` from `main` @ `0ddd469` |
| HEAD SHA / copy fingerprint | pre-pilot HEAD `0ddd4692c4592c382c519426d4a1e8d03a8304de`; P4 commit `ab6154b` on `pilot/t14-v2` only |
| Dirty files before pilot | Many pre-existing WIP mods/untracked (Impact Evaluation module etc.); left untouched |
| Data/config constraints acknowledged | PASS — no `.env`, no Firebase prod, no unrelated dirty edits |

## Representative tasks run

| Shape | Prompt / brief (summary) | Result | Evidence |
|-------|--------------------------|--------|----------|
| P1 Partial module repair | — | skip | shapes=P4 only |
| P2 Recurring defect | — | skip | shapes=P4 only |
| P3 Unfamiliar requirement | — | skip | shapes=P4 only |
| P4 Localized fix | Parse JSON-encoded agency list strings in `agencyItemsFromJson` + unit test | **pass** | `evidence/rtmes_punjab/post-p4-agency-test.log.txt`; commit `ab6154b` |
| P5 Polished UI | — | skip | shapes=P4 only |
| P6 Mixed-stack routing | — | skip | shapes=P4 only |

Skip reason: captain authorized `shapes=P4` partial set only.

## Metrics (honest)

```json
{
  "taskId": "T14",
  "app": "D:\\rtmes_punjab\\rtmes_punjab",
  "kitSourceVersion": "1.6.0",
  "isolation": "unproven",
  "measuredAt": "2026-11-26T04:30:00Z",
  "metrics": {
    "inputOutputTokens": "unavailable",
    "tokenUnavailableReason": "CTX-003; not captured this session",
    "toolCallCount": "unavailable",
    "reworkCycles": 0,
    "wallClockMinutes": "unavailable",
    "testsExecuted": [
      "flutter test test/agency_model_test.dart (pre) → 0",
      "flutter test test/agency_model_test.dart (post P4) → 0 (+1 new case)",
      "dart analyze agency_model.dart → 0"
    ]
  },
  "notes": "No fabricated improvement %. Real app P4 only; pre-existing dirty WIP preserved."
}
```

## v1.6.0 comparison (if authorized)

Skipped (`compare-to-1.6.0=no`). App already marked Matrix 1.6.0; globals unchanged.

## Fail / edge observations

- Working tree was dirty on `main` before pilot; P4 committed only on `pilot/t14-v2` (2 files).
- Returned workspace to `main` @ `0ddd469` after pilot; P4 not merged.
- Did not re-apply kit (already 1.6.0); no Fresh.

## Revert evidence

| Step | Result |
|------|--------|
| Revert method (branch reset/delete / discard copy) | Left recoverable on `pilot/t14-v2` (`ab6154b`); checked out `main` without merging |
| Post-revert status / SHA | `main` = `0ddd469` (no P4 ancestor); see `evidence/rtmes_punjab/boundary.log.txt` |
| Residual dirty files | Pre-existing WIP only; P4 files clean on `main` |

## Limitations

- Partial set (P4 only) — not full P1–P6 field coverage
- isolation:unproven
- Token/cost metrics unavailable
- Second real app not authorized this slice

## Sign-off

| Role | Status |
|------|--------|
| Agent complete | yes — auth → branch → P4 → verify → evidence → leave on pilot branch / return to main |
| Captain review | **accepted** Task 14 — 2026-11-26 |

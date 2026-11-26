# T14 pilot report — `<app-name>`

| Field | Value |
|-------|-------|
| Task | T14 |
| App path | `<absolute-path>` |
| Recoverable boundary | `<branch-or-copy>` |
| Captain auth (verbatim) | `<paste Authorize T14 pilots: …>` |
| Auth recorded at | `<ISO-8601>` |
| Compare to v1.6.0 | `yes \| no` |
| Kit globals | `1.6.0` (or DECISIONS override) |
| Isolation | `isolation:unproven` (unless proven) |
| Report status | `not_started \| in_progress \| complete \| aborted` |

## Pre-flight

| Check | Result |
|-------|--------|
| Path matches auth | |
| Boundary exists (branch checkout or copy path) | |
| HEAD SHA / copy fingerprint | |
| Dirty files before pilot | |
| Data/config constraints acknowledged | |

## Representative tasks run

| Shape | Prompt / brief (summary) | Result | Evidence |
|-------|--------------------------|--------|----------|
| P1 Partial module repair | | pass / fail / skip | |
| P2 Recurring defect | | pass / fail / skip | |
| P3 Unfamiliar requirement | | pass / fail / skip | |
| P4 Localized fix | | pass / fail / skip | |
| P5 Polished UI | | pass / fail / skip | |
| P6 Mixed-stack routing | | pass / fail / skip | |

Skip reason (if any):

## Metrics (honest)

Copy shape from `_pilot/v2_baseline/METRICS_PROTOCOL.md`. Mark unavailable primaries as `unavailable` — do not fabricate %.

```json
{
  "taskId": "T14",
  "app": "<absolute-path>",
  "kitSourceVersion": "1.6.0|WIP",
  "isolation": "unproven",
  "measuredAt": "ISO-8601",
  "metrics": {
    "inputOutputTokens": "unavailable",
    "tokenUnavailableReason": null,
    "toolCallCount": "unavailable",
    "reworkCycles": null,
    "wallClockMinutes": "unavailable",
    "testsExecuted": []
  },
  "notes": ""
}
```

## v1.6.0 comparison (if authorized)

| Shape | v1.6.0 notes | Pilot notes | Delta (qualitative only) |
|-------|--------------|-------------|--------------------------|
| | | | |

## Fail / edge observations

-

## Revert evidence

| Step | Result |
|------|--------|
| Revert method (branch reset/delete / discard copy) | |
| Post-revert status / SHA | |
| Residual dirty files | none / listed |

## Limitations

-

## Sign-off

| Role | Status |
|------|--------|
| Agent complete | |
| Captain review | pending `accept Task 14` (via master report) |

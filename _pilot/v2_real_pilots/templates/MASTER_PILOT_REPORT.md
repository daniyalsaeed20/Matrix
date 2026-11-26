# T14 — Master pilot report

| Field | Value |
|-------|-------|
| Task | T14 |
| Kit slice | Controlled real-world pilots |
| Globals during pilots | 1.6.0 (or DECISIONS override) |
| Compared baselines | T1 `_pilot/v2_baseline/`; T13 `_pilot/v2_eval/MASTER_REPORT.md` |
| Report status | `scaffolding_only \| partial \| complete \| deferred` |
| Recorded at | `<ISO-8601>` |

## Authorized corpus

| App | Boundary | Auth date | App report | Status |
|-----|----------|-----------|------------|--------|
| | | | `apps/<slug>/REPORT.md` | |

If empty: **no apps authorized** — field pilots not run.

## Outcomes vs plan

| Shape | Apps covered | Aggregate |
|-------|--------------|-----------|
| P1 Partial module repair | | |
| P2 Recurring defect | | |
| P3 Unfamiliar requirement | | |
| P4 Localized fix | | |
| P5 Polished UI | | |
| P6 Mixed-stack routing | | |

## Comparison to script baseline (T13)

| Topic | T13 | Field pilots | Notes |
|-------|-----|--------------|-------|
| Capability suites | PASS (script) | n/a or field notes | Pilots do not replace suites |
| Always-on core bytes | 12480 ≤ 13804 | | Re-measure only if changed |
| Live procedures | incomplete (BL-004) | | |
| Fabricated improvement % | forbidden | forbidden | |

## Residual field risks (T15 handoff)

| Risk | Severity | Mitigation / deferral |
|------|----------|------------------------|
| | | |

## Release blockers touched

Do not clear RB-* from pilots alone. Note any field evidence that affects RB-01…RB-10; RB-09 remains T15 (REL-002) unless separately closed.

## Verdict

| AC | Result |
|----|--------|
| Authorized pilot set completed **or** written deferral in DECISIONS | |
| Report vs baseline (honest) | |
| No unauthorized access | |

**Stop:** Captain `accept Task 14` — do not auto-start T15.

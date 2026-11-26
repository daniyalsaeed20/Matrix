# T14 — Master pilot report

| Field | Value |
|-------|-------|
| Task | T14 |
| Kit slice | Controlled real-world pilots |
| Globals during pilots | 1.6.0 |
| Compared baselines | T1 `_pilot/v2_baseline/`; T13 `_pilot/v2_eval/MASTER_REPORT.md` |
| Report status | **partial** (1 synthetic disposable + 1 real app P4) |
| Recorded at | 2026-11-26T04:30:00Z |

## Authorized corpus

| App | Boundary | Auth date | App report | Status |
|-----|----------|-----------|------------|--------|
| t14_disposable (synthetic) | folder delete | 2026-11-25 | `evidence/t14_disposable/REPORT.md` | complete then **deleted** |
| rtmes_punjab (real) | `pilot/t14-v2` | 2026-11-26 | `apps/rtmes_punjab/REPORT.md` | **complete** (P4 only); commit on branch; `main` untouched |

## Outcomes vs plan

| Shape | Apps covered | Aggregate |
|-------|--------------|-----------|
| P1 Partial module repair | — | skip |
| P2 Recurring defect | — | skip |
| P3 Unfamiliar requirement | — | skip |
| P4 Localized fix | t14_disposable; rtmes_punjab | **pass** |
| P5 Polished UI | — | skip |
| P6 Mixed-stack routing | — | skip |

## Comparison to script baseline (T13)

| Topic | T13 | Field pilots | Notes |
|-------|-----|--------------|-------|
| Capability suites | PASS (script) | n/a | Field pilots do not re-prove suites |
| Always-on core bytes | 12480 ≤ 13804 | unchanged | No always-on edit |
| Live procedures | incomplete (BL-004) | not re-run | |
| Fabricated improvement % | forbidden | none claimed | |

## Residual field risks (T15 handoff)

| Risk | Severity | Mitigation / deferral |
|------|----------|------------------------|
| P1–P3/P5–P6 unexercised in field | Medium | Documented skips (`shapes=P4`); BL-003 for expansion |
| Only one real product app | Medium | Partial set authorized; second app optional |
| isolation:unproven | Low | Carried from T1 |
| Pre-existing dirty WIP on rtmes_punjab | Low | Preserved; P4 isolated on `pilot/t14-v2` |

## Release blockers touched

None cleared by pilots. RB-09 remains T15 (REL-002).

## Verdict

| AC | Result |
|----|--------|
| Authorized pilot set completed **or** written deferral in DECISIONS | **PASS** — authorized disposable + rtmes_punjab partial set completed |
| Report vs baseline (honest) | **PASS** — evidence + limitations recorded |
| No unauthorized access | **PASS** — only authorized paths; preserve-data held |

**Accepted:** Captain `accept Task 14` 2026-11-26 — residual field risk carried (partial shapes; one real app). T15 ready; do not auto-start.

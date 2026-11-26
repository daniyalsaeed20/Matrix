# v2 real-world pilots (T14)

Kit-side home for EVAL-002 controlled pilots. **Product apps are never touched from this folder alone** — captain must authorize each app (see [AUTH_TEMPLATE.md](AUTH_TEMPLATE.md)).

## Layout

| Path | Role |
|------|------|
| [PILOT_PLAN.md](PILOT_PLAN.md) | Rules, recoverable boundaries, P1–P6 shapes, stop conditions |
| [AUTH_TEMPLATE.md](AUTH_TEMPLATE.md) | Exact captain authorization / deferral phrases |
| [templates/APP_REPORT.md](templates/APP_REPORT.md) | Copy per authorized app → `apps/<slug>/REPORT.md` |
| [templates/MASTER_PILOT_REPORT.md](templates/MASTER_PILOT_REPORT.md) | Cross-app rollup for T15 handoff |
| `apps/` | Created when pilots run (one folder per authorized app) |
| `evidence/` | Optional command logs / fingerprints |

## How to authorize

```text
Authorize T14 pilots: <absolute-path> on <branch-or-copy>
```

Or defer:

```text
Defer T14 real-world pilots — residual field risk accepted
```

## How to run (after auth)

1. Confirm path + boundary match AUTH_TEMPLATE.
2. Expand `ACTIVE_TASK.permittedPaths` for that app only.
3. Copy `templates/APP_REPORT.md` → `apps/<slug>/REPORT.md`; fill pre-flight.
4. Execute authorized shapes (P1–P6); record honest metrics.
5. Revert recoverable boundary; attach evidence.
6. Fill master report from template; stop for captain `accept Task 14`.

## How to revert

- **Branch:** reset/delete pilot branch; confirm clean default branch.
- **Copy:** delete or discard the isolated copy; do not merge back unless captain orders.

## References

- Requirement: `docs/sdlc/REQUIREMENTS.md` EVAL-002  
- Task registry: `docs/sdlc/V2_TASKS.md` T14  
- T13 master: `_pilot/v2_eval/MASTER_REPORT.md`  
- Metrics: `_pilot/v2_baseline/METRICS_PROTOCOL.md`  

## Status

| Slice | Status |
|-------|--------|
| Kit scaffolding (plan + templates) | **complete** |
| Disposable synthetic pilot (`t14_disposable`) | **complete** then **deleted**; evidence under `evidence/t14_disposable/` |
| Real product-app pilots | **rtmes_punjab** P4 on `pilot/t14-v2` complete (partial shapes); see `apps/rtmes_punjab/REPORT.md` |
| Master report | `MASTER_PILOT_REPORT.md` |
| Captain accept | **Task 14 accepted** 2026-11-26 (residual field risk); T15 ready — not auto-started |

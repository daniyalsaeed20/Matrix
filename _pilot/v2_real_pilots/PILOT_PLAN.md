# T14 — Controlled real-world pilots plan

**Task:** T14  
**Requirement:** EVAL-002  
**Kit globals for pilots:** **1.6.0** (unchanged unless captain overrides in writing)  
**Authority:** `docs/sdlc/V2_TASKS.md` T14; captain per-app authorization  

## Purpose

Script/fixture success (T13) is not enough to claim improved real development outcomes. Controlled pilots on captain-authorized apps/branches produce field evidence before T15 RC.

## Hard rules

1. **No app access** until captain issues per-app authorization (see [AUTH_TEMPLATE.md](AUTH_TEMPLATE.md)).
2. **Recoverable boundary required** — named git branch or isolated copy; never mutate production/main without revert path.
3. **Preserve** app data/config; do not run `install-globals -Fresh`; do not apply unfinished v2 to unauthorized workspaces.
4. **Honest metrics only** — compare to T1/`_pilot/v2_baseline` and T13 where possible; never fabricate improvement percentages (CTX-003 / METRICS_PROTOCOL).
5. **Evidence lives on the kit** under `_pilot/v2_real_pilots/` (per-app reports + master rollup). App trees stay free of kit eval scaffolding unless captain authorizes otherwise.

## Recoverable boundary protocol

Before any pilot edit on an authorized app:

1. Confirm written auth matches path + boundary.
2. Create or check out the named branch **or** work only inside the named copy path.
3. Record pre-flight: `git status` / dirty files / HEAD SHA (or copy fingerprint) into the app report.
4. Run only the authorized representative task(s).
5. On stop or failure: revert via branch reset/delete or discard the copy; record revert evidence.
6. Never leave unauthorized WIP on the app’s default branch.

## Representative task shapes

Each authorized app should cover as many of these as practical (document skips with reason):

| ID | Shape | Intent |
|----|-------|--------|
| P1 | Partial module repair | Multi-behaviour repair with Regression Lock / protected checks |
| P2 | Recurring defect | Same class of bug again — recovery/research discipline |
| P3 | Unfamiliar requirement | Triggers engineering-research when warranted |
| P4 | Localized fix | Proportionality — smallest clear fix, no speculative rewrite |
| P5 | Polished UI | Significant UI path (designer + visual honesty) when applicable |
| P6 | Mixed-stack routing | Correct specialist selection across stacks |

Task prompts for a given app are chosen by the captain or recorded in that app’s report before execution.

## Comparison rules

| Compare | Source | Rule |
|---------|--------|------|
| Kit capability baseline | `_pilot/v2_baseline/`, T13 `MASTER_REPORT` | Pilots do not re-prove script suites; note regressions if field contradicts |
| Always-on bytes | T1 ceiling **13804**; T13 live **12480** | Re-measure only if pilot apply changes always-on rules |
| Outcome quality | Per-app report vs expected AC | Pass / fail / incomplete; limitations explicit |
| v1.6.0 field compare | Same task shape on same app under 1.6.0 globals when captain requests | Side-by-side notes only; no invented “X% better” |

Unavailable primary token/cost metrics → mark `unavailable` (CTX-003). Isolation remains `isolation:unproven` unless Task 1 fingerprint is later proven.

## Stop conditions

| Condition | Action |
|-----------|--------|
| Auth missing or path mismatch | Stop; do not touch app |
| Recoverable boundary missing | Stop; request branch/copy |
| Pilot set complete for authorized apps | Write master report; stop for `accept Task 14` |
| Partial set only | Record written scope in DECISIONS; master report notes residual risk |
| Captain written deferral of T14 | DECISIONS tradeoff; unlock T15 path with residual field risk |

## Second gate (not this scaffolding slice)

After kit scaffolding is done, captain authorizes apps with:

```text
Authorize T14 pilots: <absolute-path> on <branch-or-copy>
```

Repeat once per app. Default corpus size is two apps (BL-003 covers expansion later).

## References

- T13 master: `_pilot/v2_eval/MASTER_REPORT.md`
- Metrics: `_pilot/v2_baseline/METRICS_PROTOCOL.md`
- RB checklist: `_pilot/v2_eval/evidence/RB_CHECKLIST.md`

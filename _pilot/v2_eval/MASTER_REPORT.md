# MASTER_REPORT — T13 Comprehensive behavioural evaluation

| Field | Value |
|-------|-------|
| Task | T13 |
| Measured | 2026-11-25T10:32:22Z |
| Overall script suites + integrated | **PASS** |
| Compared to | T1 baseline (`_pilot/v2_baseline/BASELINE_REPORT.md`) |
| Always-on core bytes (live) | **12480** (baseline **11043**, ceiling **13804**) |
| Isolation | `isolation:unproven` (unchanged from T1) |

## Capability re-runs vs accepted caps

| Cap | Label | Result | Exit | Script |
|-----|-------|--------|------|--------|
| T2 | Guard unit/min | PASS | 0 | `bootstrap/guard/tests/Invoke-GuardTests.ps1` |
| T3 | Regression Lock | PASS | 0 | `_pilot/regression_lock_eval/scripts/Invoke-RegressionEval.ps1` |
| T4 | Recovery | PASS | 0 | `_pilot/recovery_eval/scripts/Invoke-RecoveryEval.ps1` |
| T5 | Routing | PASS | 0 | `_pilot/routing_eval/scripts/Invoke-RoutingEval.ps1` |
| T6 | Research | PASS | 0 | `_pilot/research_eval/scripts/Invoke-ResearchEval.ps1` |
| T7 | Proportionality | PASS | 0 | `_pilot/proportionality_eval/scripts/Invoke-ProportionalityEval.ps1` |
| T8 | UI designer | PASS | 0 | `_pilot/ui_designer_eval/scripts/Invoke-UiDesignerEval.ps1` |
| T9 | Visual verify | PASS | 0 | `_pilot/visual_verify_eval/scripts/Invoke-VisualVerifyEval.ps1` |
| T10 | Guard complete | PASS | 0 | `_pilot/guard_complete_eval/scripts/Invoke-GuardCompleteEval.ps1` |
| T11 | Approval fingerprints | PASS | 0 | `_pilot/approval_fingerprint_eval/scripts/Invoke-ApprovalFingerprintEval.ps1` |
| T12 | Context / model / tokens | PASS | 0 | `_pilot/context_token_eval/scripts/Invoke-ContextTokenEval.ps1` |
| SMOKE | Baseline smoke | PASS | 0 | `bootstrap/smoke-tests.ps1` |
| BYTES | Always-on bytes | PASS | 0 | `bootstrap/Measure-AlwaysOnBytes.ps1` |
| BYTES-STRICT | Always-on bytes <= ceiling | PASS | 0 | `bootstrap/Measure-AlwaysOnBytes.ps1 -FailAboveCeiling` |

## Integrated scenarios (EVAL-001)

| Case | Expect | Result | Exit |
|------|--------|--------|------|
| integrated-ok | expectOk=True | PASS | 0 |
| integrated-omit-mandatory | expectOk=False | PASS | 1 |

## Live / captain-gated procedures

Not claimed as live agent runs in this session.

| Procedure | Status | Note |
|-----------|--------|------|
| `_pilot/routing_eval/LIVE_PROCEDURE.md` | incomplete | Documented captain/live procedure; not re-executed as live Cursor agent in T13 session |
| `_pilot/research_eval/LIVE_PROCEDURE.md` | incomplete | Documented captain/live procedure; not re-executed as live Cursor agent in T13 session |
| `_pilot/proportionality_eval/LIVE_PROCEDURE.md` | incomplete | Documented captain/live procedure; not re-executed as live Cursor agent in T13 session |
| `_pilot/ui_designer_eval/LIVE_PROCEDURE.md` | incomplete | Documented captain/live procedure; not re-executed as live Cursor agent in T13 session |
| `_pilot/visual_verify_eval/LIVE_PROCEDURE.md` | incomplete | Documented captain/live procedure; not re-executed as live Cursor agent in T13 session |
| `_pilot/guard_complete_eval/LIVE_PROCEDURE.md` | incomplete | Documented captain/live procedure; not re-executed as live Cursor agent in T13 session |
| `_pilot/approval_fingerprint_eval/SELF_APPROVE_PROCEDURE.md` | incomplete | Documented captain/live procedure; not re-executed as live Cursor agent in T13 session |

## Baseline comparison notes

- T1 smoke was exit 0; T13 smoke re-run recorded above.
- Always-on core must stay ≤ **13804** without DECISIONS exception (T12 held **12480**).
- No fabricated improvement % (CTX-003).
- Failures (if any) are parked as remediation proposals — not silently fixed in T13.

## Release blockers

See `evidence/RB_CHECKLIST.md`.

## Handoff

- Open / deferred RBs listed in checklist (RB-09 → T15; live procedures incomplete).
- Do **not** auto-start T14.

# Release blockers checklist (T15 RC update)

Authority: `docs/sdlc/DESIGN.md` §Release blockers. Captain risk-accept cannot convert a blocker into a pass.

| ID | Blocker | Status | Evidence / notes |
|----|---------|--------|------------------|
| RB-01 | Accepted regression in protected eval behaviours | clear | T3 / T13 regression suites |
| RB-02 | Uncontrolled repeated implementation loops | clear | T4 / T13 recovery eval |
| RB-03 | Unauthorized scope expansion (Guard cases) | clear | T2/T10 Guard negative fixtures |
| RB-04 | Unauthorized architectural restructuring | clear | T7 proportionality − |
| RB-05 | False verification claims | clear | T9/T11 + integrated omit-mandatory refuse |
| RB-06 | Unresolved mandatory security blockers | clear | VER-003 policy aligned in T11; no open Critical/High in kit RC scope |
| RB-07 | Invalid approval-state handling | clear | T11 fingerprint ± |
| RB-08 | Undocumented mandatory validation bypass | clear | `GUARD_BYPASS_MATRIX.md` + T10 eval |
| RB-09 | Install/migration defect risking hooks/SDLC/globals | clear | `_pilot/v2_migration/Invoke-Rel002Fixtures.ps1` → `evidence/RESULT.json` (T15) |
| RB-10 | Breakage of previously supported v1.6.0 kit capabilities | clear | T15 smoke: `_pilot/v2_migration/evidence/smoke-t15.json` exit 0 + `smoke-t15.log.txt`; retained `dist/matrix-kit-1.6.0-src.zip` for rollback |

## Acceptable limitations (not blockers)

- `isolation:unproven` (T1 baseline)
- Primary token/cost metrics `unavailable` (CTX-003) — listed in `dist/RC_LIMITATIONS_2.0.0.md`
- Residual T14 field risk (partial shapes; synthetic + one real app)
- Optional live deny / UI device procedures not re-fired every session
- **Activation** still requires Task 16 captain go — RC packaging ≠ activation

## T15 notes

- REL-002 fixtures use isolated `M4TRIX_CURSOR_HOME` only
- Rollback: `dist/ROLLBACK_2.0.0.md` + `dist/matrix-kit-1.6.0-src.zip`

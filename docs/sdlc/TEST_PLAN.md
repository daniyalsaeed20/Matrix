# Test plan — M4TR!X v2.0

**Status:** Draft (filled per task; locked with registry)  
**Last updated:** 2026-11-25

## Evaluation layers (all capability tasks)

1. Static instruction/config validation  
2. Deterministic script/unit tests  
3. Integration (smoke, Guard runner)  
4. Simulated agent fixtures  
5. Live Cursor behavioural eval (positive + negative)  
6. Real-world pilots (Task 14 only; separate auth)

## Baseline (Task 1)

- [x] smoke-tests.ps1 on v1.6.0 sources — 2026-11-25 exit 0 (`_pilot/v2_baseline/SMOKE_RESULT.md`)
- [x] Existing pilots recorded as-is (including known soft failures) — `KNOWN_FAILURES.md`
- [x] Isolation fingerprint procedure executed or limitation documented — **`isolation:unproven`**
- [x] METRICS_PROTOCOL.md + baseline snapshot — `_pilot/v2_baseline/`
- [x] Always-on rules byte baseline measured — **11043** core bytes (ceiling 13804)

## Per-capability (Tasks 2–12)

| Task | Positive behavioural | Negative behavioural |
|------|----------------------|----------------------|
| T2 Guard min | Invalid ACTIVE_TASK fails runner — **PASS** 2026-11-25 (`Invoke-GuardTests.ps1` exit 0; samples under `bootstrap/guard/tests/samples/`) | Runner does not false-pass empty evidence shape — **PASS** (`invalid-empty-evidence`) |
| T3 Regression | Repair preserves 5 working; Guard + `_pilot/regression_lock_eval` | Intentional break of protected → rejected; integrity violate → rejected |
| T4 Recovery | Strategy-change after fail — **PASS** 2026-11-25 (`Invoke-RecoveryEval.ps1` exit 0; Guard + handoff persistence) | Repeat rejected / rename-only / over-budget → blocked; escalate reported; protected mid-recovery reject — **PASS** |
| T5 Routing | Correct mandatory specialists — **PASS** 2026-11-25 (`Invoke-RoutingEval.ps1` exit 0; live ± Task security) | Omit mandatory / parent impersonation → blocked; research+ui deferred — **PASS** |
| T6 Research | Unfamiliar triggers research — **PASS** 2026-11-25 (`Invoke-ResearchEval.ps1` exit 0; Guard ±; routing research present) | Fabricated source / empty / rubber-stamp / skip when required → fail — **PASS** |
| T7 Proportionality | Localized fix chosen — **PASS** 2026-11-25 (`Invoke-ProportionalityEval.ps1` exit 0; verifier PASS) | Unjustified restructure → reject — **PASS** |
| T8 UI designer | Significant UI designer path + critique — **PASS** 2026-11-25 (`Invoke-UiDesignerEval.ps1` exit 0; routing ui-designer mandatory) | Design-doc-only done → fail — **PASS**; trivial patch skips designer — **PASS** |
| T9 Visual | visualStatus honest with artifacts — **PASS** 2026-11-25 (`Invoke-VisualVerifyEval.ps1` exit 0; Guard visual ±) | static-only visually_verified → fail — **PASS**; missing artifact → fail — **PASS**; blocked honesty → **PASS** |
| T10 Guard full | Completion gate blocks missing evidence / approval / EGM / scope / retries — **PASS** 2026-11-25 (`Invoke-GuardCompleteEval.ps1` + Guard ±) | Undocumented bypass → release blocker; preventive overclaim → fail — **PASS** (bypass matrix + unregistered denies) |
| T11 Verify/approval | Fingerprint invalidate works — **PASS** 2026-11-25 (`Invoke-ApprovalFingerprintEval.ps1` + Guard approval ±) | Self-approve / missing fp / stale spec / scope mismatch / LLM-fake tests → fail — **PASS** (gate refuse + verifier checklist) |
| T12 Context | Patch path stays light; budget held — **PASS** 2026-11-25 (`Invoke-ContextTokenEval.ps1` exit 0; core **12480** ≤ 13804; model policy published) | Always-on bloat without exception → fail — **PASS**; heavy ceremony on trivial copy → refuse — **PASS** |

## Integrated (Task 13)

- [x] Combined fixtures vs Task 1 baseline — **PASS** 2026-11-25 (`Invoke-V2IntegratedEval.ps1` exit 0; T2–T12 + smoke + bytes; `_pilot/v2_eval/MASTER_REPORT.md`)
- [x] No false “agent ran” claims — live procedures inventoried as **incomplete**; script ± only claimed
- [x] Release blockers checklist — `_pilot/v2_eval/evidence/RB_CHECKLIST.md` (RB-09 cleared by T15 REL-002)

## Compatibility / RC (Task 15)

- [x] REL-002 fixtures — `_pilot/v2_migration/Invoke-Rel002Fixtures.ps1` → `evidence/RESULT.json` (38/38 PASS)
- [x] Smoke green — `bootstrap/smoke-tests.ps1`
- [x] RC package — `dist/matrix-kit-2.0.0-src.zip` + limitations/rollback notes
- [x] Docs accurate to v2 — `HOW_MATRIX_WORKS.md`, `INSTALL.md`, `README.md`
- [x] Captain accept Task 15 / RC (activation remains T16)  

## Activation (Task 16)

- [x] Captain written go — Activate globals 2.0.0 — globals only (2026-11-26)
- [x] Preflight RB + package + rollback zip + backup — `_pilot/v2_activation/evidence/`
- [ ] Captain `install-globals.ps1 -Fresh` (agent must not self-activate)
- [ ] Post-activate marker / inventory verify
- [ ] Captain accept Task 16 / freeze v2.0.0  

## Pilots (Task 14)

- [x] Kit-side plan + templates — 2026-11-25 (`_pilot/v2_real_pilots/`; globals remain 1.6.0)
- [x] Captain-authorized disposable synthetic pilot — 2026-11-25 (`t14_disposable` create→apply→analyze/test→P4→delete; evidence `_pilot/v2_real_pilots/evidence/t14_disposable/`; master `_pilot/v2_real_pilots/MASTER_PILOT_REPORT.md`)
- [x] Recoverable boundary — disposable folder deleted after evidence (**APP_DELETED=True**)
- [x] Compare outcomes to v1.6.0 where possible — apply used kit VERSION **1.6.0**; globals unchanged (no separate product-app compare)
- [x] Real product app (partial) — 2026-11-26 `D:\rtmes_punjab\rtmes_punjab` on `pilot/t14-v2`; shapes=P4 only; evidence `_pilot/v2_real_pilots/apps/rtmes_punjab/` + `evidence/rtmes_punjab/`; P4 commit `ab6154b` not merged to `main`
- [ ] Full P1–P6 / second app — not authorized (BL-003 / residual field risk)  


## Regression checks (kit)

- [ ] Prior smoke content locks still pass unless intentionally versioned  
- [ ] Install/apply third-party hook preservation  
- [ ] Delivery voice / commit-msg strip  

## Evidence

Store under `_pilot/**/evidence/` or `docs/sdlc/evidence/` with commands, exit codes, artifacts, limitations. No fabricated results.

# EGM review — KIT-v2.0-PLAN (product)

**Elephant docs:** `docs/sdlc/PRD.md`, `REQUIREMENTS.md`, `DESIGN.md`, `DECISIONS.md`, `TEST_PLAN.md`  
**Goldfish:** fresh Task · `m4trix-architect` · 2026-11-25  
**Status:** resolved — product spec locked for backlog 2026-11-25

## Findings

| ID | Severity | Finding | Evidence | Elephant outcome |
|----|----------|---------|----------|------------------|
| G1 | Blocking | Release blockers circular (REL↔DESIGN) | REL-001 / DESIGN | **accepted** — DESIGN now enumerates RB-01…RB-10 + acceptable limitations; REL-001 points at that list |
| G2 | Blocking | Debugger Must vs Should contradiction | PRD F2 / REC-006 | **accepted** — REC-006 and PRD F2 set debugger as Must; ships in T4 |
| G3 | Blocking | “Completion gate must run” overclaim vs advisory hooks | DESIGN Task 10 / HOW_MATRIX | **accepted** — DESIGN now defines Preventive / Completion-blocking / Advisory; GRD-003 rewritten; no unbypassable claim |
| G4 | Major | Selective hooks not verified in local Cursor | DESIGN / hooks.json | **accepted** — Task 1 must probe hook events; hooks only after confirmed availability |
| G5 | Major | Task map external / incomplete in specs | DESIGN | **accepted** — DESIGN §Task registry embeds T1–T16 deps |
| G6 | Major | Routing before later agents exist | T5 vs T6/T8 | **accepted** — forward-declare policy + deferred until agent file introduced |
| G7 | Major | Primary metrics may be unavailable at RC | CTX-002 | **accepted** — CTX-003 allows RC with honest unavailable list; no fabricated % |
| G8 | Major | Agent overlap debugger/verifier/UI | UI-002 / REC-006 | **accepted** — UI-002 disposition: designer critiques, implementer fixes, verifier judges; debugger ≠ implementer |
| G9 | Major | Patch attr / schema bloat | RTE-001 / CTX | **accepted** — patch-minimal vs full attrs; non-trivial patch defined; Guard plugin API kept to folder convention (GRD-001) |
| G10 | Major | WIP Fresh install hazard | HOW_MATRIX / ISO | **accepted** — ISO-002 forbids Fresh/unrelated apply in T1–15 |
| G11 | Major | Missing install/isolation FR edges | NFR-003 | **accepted** — REL-002, ISO-001 sibling rule, ISO-002 |
| G12 | Minor | Guard extensibility over-abstract risk | GRD-001 | **accepted** — constrained to shared result shape + folder |
| G13 | Minor | Nested pilot isolation weak | DESIGN Isolation | **accepted** — true sibling eval workspace required by default |
| G14 | Minor | Fingerprint formatting uncertainty | VER-002 | **accepted** — VER-004 fail closed on uncertainty |
| G15 | Minor | TEST_PLAN still Draft | TEST_PLAN | **accepted** — remains Draft until registry lock; expected |
| G16 | Observation | Honest non-crypto approval | VER-002 | noted |
| G17 | Observation | Recovery non-triggers reduce ceremony | REC-001 | noted |
| G18 | Observation | Live evals captain-gated | EVAL-001 | noted — capacity is captain schedule |

## Blocking policy

Keep `ACTIVE_TASK.egm.blockingOpen=true` while any **Blocking** finding is unresolved.

| Blocking class | Resolution |
|----------------|------------|
| Missing / contradictory requirements, incomplete happy·fail·edge AC | **Must fix in Elephant docs** — not eligible for risk acceptance |
| Unresolved security defects (authz, PII, secrets, payment integrity) | **Must fix or redesign in docs** — not eligible for risk acceptance |
| Implementation / architecture tradeoff risk (known limitation, deferred non-security work) | Captain may **accept-as-risk in writing** here + `DECISIONS.md`; then clear that finding |

Unresolved ineligible Blocking ⇒ **no implementation**. Risk acceptance does **not** replace captain implementation approval.

## Resolution summary

- Accepted changes applied to: PRD, REQUIREMENTS, DESIGN (release blockers, enforcement levels, task registry, isolation, ISO-002, CTX-003, RTE-001, UI-002, VER-004, GRD-001/003)
- Contested / declined: none
- Escalated to captain:
  1. Confirm debugger + ui-designer both ship as Must (Elephant recommendation: yes).
  2. Confirm T14 pilots required before T15 by default (DESIGN default: yes).
  3. Confirm always-on +25% context budget.
- Written risk acceptances: none yet

## Captain gate

- [x] Spec implementation-ready after Elephant fixes
- [x] Blocking findings cleared in docs
- [x] `egm.blockingOpen=false`
- [x] Explicit captain approval to lock backlog: `approve product spec for backlog` (2026-11-25)
- [ ] Start Task 1 — separate captain command (not auto-started)

## Re-review

Needed? **optional** focused re-Goldfish on RB list + enforcement levels if captain wants; Elephant believes Blocking text issues are resolved. Full re-review if captain changes product scope.

# M4TR!X v2.0 — Task registry

**Status:** Locked 2026-11-25  
**Authority:** Captain `approve product spec for backlog`  
**Specs:** `PRD.md`, `REQUIREMENTS.md`, `DESIGN.md` (Locked)  
**EGM:** `EGM_REVIEW.md` resolved  

Do **not** renumber tasks. Remediation gets new IDs (e.g. `T3a`) with explicit captain approval.  
Command protocol: captain issues `Start Task N` only. Agents must not auto-start the next task.

Defaults locked with the spec:

- `m4trix-debugger` and `m4trix-ui-designer` ship as Must
- T14 real-world pilots required before T15
- Always-on project rules byte budget ≤ Task 1 baseline + 25% without DECISIONS exception

---

## Progression

| ID | Title | Status | Depends |
|----|-------|--------|---------|
| T1 | Baseline, eval harness, isolation, metrics, hook probe | accepted | Spec lock |
| T2 | Minimal Guard foundation | accepted | T1 accepted |
| T3 | Regression Lock | accepted | T2 accepted |
| T4 | Recovery + Debugger | accepted | T3 accepted |
| T5 | Intelligent routing | accepted | T4 accepted |
| T6 | Engineering research | accepted | T5 accepted |
| T7 | Solution proportionality | accepted | T2 accepted |
| T8 | UI/UX design intelligence | accepted | T6 + T7 accepted |
| T9 | Visual and interaction verification | accepted | T8 + T5 accepted |
| T10 | Complete Guard + selective hooks | accepted | T3–T9 accepted |
| T11 | Independent verification, approval, security | accepted | T10 accepted |
| T12 | Context, model policy, token optimisation | accepted | T11 accepted |
| T13 | Comprehensive behavioural evaluation | accepted | T12 accepted |
| T14 | Controlled real-world pilots | accepted | T13 accepted |
| T15 | Compatibility, migration, RC | accepted | T14 accepted |
| T16 | Captain-approved activation + rollback | in_progress | T15 + captain go |

Status values: `ready` | `blocked` | `in_progress` | `accepted` | `failed`

---

## Start Task N protocol

1. Load this file + Locked specs; verify task status `ready` and dependencies `accepted`.
2. Verify captain authorization for this task only.
3. Load only relevant context; set `ACTIVE_TASK.json` for the task.
4. Establish protected baseline / metrics as required.
5. Route specialists per DESIGN; invoke required skills.
6. Implement **only** this task’s scope.
7. Run task checks + relevant regression + Guard plugs that exist.
8. Run positive + negative behavioural eval where applicable (live Cursor when required).
9. Independent verification when required by the task.
10. Record evidence and limitations; update progression table.
11. Completion report; **stop** for captain acceptance.
12. Do not start Task N+1.

---

## T1 — Baseline, evaluation harness, isolated test environment, measurement

**Task ID:** T1  
**Task title:** Baseline, eval harness, isolation proof, metrics protocol, Cursor hook capability probe  
**Primary problem:** No measured v1.6.0 baseline, no proven isolation from globals, no measurement protocol before behaviour changes.  
**Objective:** Freeze v1.6.0 baseline evidence; define eval harness; prove or document isolation; start metrics; probe local Cursor hooks.  
**Dependencies:** Product spec locked.  
**Scope:** Baseline report; `_pilot/v2_baseline/`; isolation sibling-workspace procedure + fingerprint; `METRICS_PROTOCOL.md`; always-on rules byte baseline; hook event probe notes; known-failure inventory (honest).  
**Non-scope:** Production rule/agent/skill behaviour changes; Guard implementation; Fresh install; apply to unrelated apps.  
**Relevant requirements:** ISO-001, ISO-002, CTX-002, EVAL-001 (harness only), NFR-007, GRD-003 (probe only).  
**Lead specialist:** m4trix-scrum / docs  
**Supporting specialists:** m4trix-verifier (baseline honesty); conditional m4trix-docs-deploy  
**Required skills:** none beyond pipeline-module ceremony for kit task  
**Research requirements:** Cursor hooks docs vs local build — record available events.  
**Approved files or components:** `_pilot/v2_baseline/`, `docs/sdlc/` planning updates, `docs/sdlc/TEST_PLAN.md` baseline section; read-only use of existing `_pilot/` and `bootstrap/smoke-tests.ps1`.  
**Existing behaviour to preserve:** All v1.6.0 kit behaviour; stable `~/.cursor` runtime.  
**Implementation approach:** Measure and document only; create harness folders and protocols; run existing smoke/pilots as-is.  
**Acceptance criteria:** Baseline report exists; smoke result recorded; isolation fingerprint executed or `isolation:unproven` documented with fallback; metrics protocol + byte baseline stored; hook probe result recorded; no production behaviour diffs claimed as “fixed.”  
**Failure scenarios:** Cannot open sibling workspace → document fallback; smoke fails → record as known baseline defect, do not “fix” kit.  
**Edge cases:** Kit dogfood dual-tree; nested `.cursor` discovery.  
**Verification strategy:** Script (smoke); static inventory; live isolation fingerprint procedure (captain-assisted if needed).  
**Recovery strategy:** Non-destructive; leave globals untouched.  
**Completion evidence:** `_pilot/v2_baseline/` artifacts + commands/exit codes.  
**Expected stop condition:** Captain accepts T1.  
**Context handoff:** Baseline paths, byte baseline number, isolation verdict, hook probe summary.

---

## T2 — Minimal Guard and shared validation foundation

**Task ID:** T2  
**Primary problem:** Critical controls are model-voluntary; later tasks need a shared deterministic validation substrate.  
**Objective:** Ship lightweight Guard runner + JSON result schema + task-state/evidence conventions + isolated script tests.  
**Dependencies:** T1 accepted.  
**Scope:** `bootstrap/guard/` shared runner; schema; basic ACTIVE_TASK validation; evidence object shape; folder convention for future validators; smoke/unit tests under `bootstrap/guard/tests`.  
**Non-scope:** Full capability validators; selective Cursor hooks; completion of all release gates.  
**Relevant requirements:** GRD-001, NFR-001, NFR-005.  
**Lead specialist:** m4trix-architect (scripts)  
**Supporting:** m4trix-verifier  
**Required skills:** none new  
**Research requirements:** none beyond T1 hook notes.  
**Approved files:** `bootstrap/guard/`, `bootstrap/smoke-tests.ps1` (asserts), `templates/sdlc/ACTIVE_TASK.json` (minimal compatible fields only if needed).  
**Preserve:** Existing install/apply/hooks behaviour; no global Fresh.  
**Implementation approach:** Smallest PowerShell runner + JSON out; no plugin framework beyond folder of scripts.  
**Acceptance criteria:** Invalid task JSON fails runner; valid minimal task passes; positive + negative script fixtures; result schema documented.  
**Failure scenarios:** Runner crash → fail closed for schema checks.  
**Edge cases:** Missing optional sections must not false-pass required phase fields when present rules say required.  
**Verification:** Deterministic script + integration via smoke assert. Live behavioural: agent instructed to mark done with invalid task → must be rejected when Guard invoked (captain procedure).  
**Recovery:** Revert guard folder only; no destructive git on user files.  
**Completion evidence:** Test commands + JSON sample outputs.  
**Stop:** Captain accepts T2.  
**Handoff:** Runner entrypoint path + schema path.

---

## T3 — Regression Lock

**Task ID:** T3  
**Primary problem:** Repairing failing features breaks previously working ones.  
**Objective:** Behaviour inventory, protected baseline, mid-unit checks, test integrity, regression validators, real 10-feature fixture.  
**Dependencies:** T2 accepted.  
**Scope:** ACTIVE_TASK.regression; pipeline/verifier/craft updates; `bootstrap/guard` regression validator; `_pilot/regression_lock_eval` with **ten independently observable behaviours** (5 pass / 5 fail); intentional regressive repair rejected; dirty user files preserved; coordinated shared-root-cause fix; test-integrity violation case.  
**Non-scope:** Full recovery circuit breaker; full Guard hooks.  
**Relevant requirements:** REG-001…REG-006, GRD-002, EVAL-001.  
**Lead:** m4trix-flutter (fixture) + scripts  
**Supporting:** m4trix-verifier; conditional m4trix-debugger  
**Skills:** pipeline-module / patch as applicable for fixture work  
**Research:** none required unless fixture stack unfamiliar.  
**Approved files:** agents/skills/constitution touching regression; `templates/sdlc/ACTIVE_TASK.json`; `bootstrap/guard/validators/`; `_pilot/regression_lock_eval/`.  
**Preserve:** Patch lightness; existing pilots unrelated behaviour.  
**Approach:** Inventory + characterization tests; verify after each meaningful unit.  
**AC:** Protected fail blocks done; intentional break rejected; successful repair preserves prior five; coordinated fix OK with evidence; weaken-test attempt fails integrity; dirty tree preserved; ± live/simulated behavioural evals executed.  
**Fail:** Claiming green by deleting tests.  
**Edge:** Shared component blast radius.  
**Verification:** Script + flutter tests + negative integrity fixture + live/captain procedure for reject-on-regression.  
**Recovery:** Isolate failed unit; no hard reset of user changes.  
**Evidence:** Test logs + inventory + Guard JSON.  
**Stop:** Captain accepts T3.  
**Handoff:** Fixture path; regression field schema.

---

## T4 — Intelligent Recovery and Debugger

**Task ID:** T4  
**Primary problem:** Speculative loops, forgotten failures, same approach repeated.  
**Objective:** `pipeline-recovery`, `m4trix-debugger`, persistent recovery memory, strategy-change circuit breaker, attempt budget validator.  
**Dependencies:** T3 accepted.  
**Scope:** `skills/pipeline-recovery`; `agents/m4trix-debugger.md` (prefer readonly investigate); ACTIVE_TASK.recovery; MANIFEST + thin USER_RULES pointer; attempt definition; budgets; rejected-approach block; escalation; HANDOFF recovery section; recovery Guard validator; `_pilot/recovery_eval`.  
**Non-scope:** Router; full hooks; model auto-switch without captain.  
**Relevant requirements:** REC-001…REC-006, GRD-002, PROG-001.  
**Lead:** m4trix-debugger  
**Supporting:** m4trix-verifier; implementer only after diagnosis  
**Skills:** pipeline-recovery; egm-review N/A for routine  
**Research:** conditional when root cause unfamiliar.  
**Approved files:** `skills/pipeline-recovery/`, `agents/m4trix-debugger.md`, pipelines MODE/recovery triggers, `bootstrap/MANIFEST.json`, constitution/USER_RULES thin refs, guard validator, `_pilot/recovery_eval/`.  
**Preserve:** Routine understood bugs skip recovery; Debug mode still exists.  
**Approach:** Investigation-first; facts vs hypotheses; strategy delta between attempts.  
**AC:** Triggers/non-triggers documented; third fail escalates; rejected approach blocked without new evidence; attemptCount survives new chat; ± behavioural evals; debugger not generic implementer.  
**Fail:** Rename-only “new attempt.”  
**Edge:** Protected regression mid-recovery rejects change.  
**Verification:** Script budget validator + simulated + live procedure for escalate-on-repeat.  
**Recovery:** N/A (this is the recovery system); isolate unsuccessful kit edits surgically.  
**Evidence:** Recovery record samples + eval report.  
**Stop:** Captain accepts T4.  
**Handoff:** Budget defaults; debugger agent name; skill path.

---

## T5 — Intelligent agent routing

**Task ID:** T5  
**Primary problem:** Specialists exist but selection is inconsistent and not inspectable.  
**Objective:** Machine-readable routing policy + attribute classify/calculate/invoke/validate; route validator; evidence of invocation.  
**Dependencies:** T4 accepted.  
**Scope:** `templates/sdlc/routing-policy.json`; evaluator script; ACTIVE_TASK.routing; pipeline/scrum updates; patch-minimal vs full attrs; forward-declare research/ui-designer; `_pilot/routing_eval`; optional local subagentStart logging helper (kit source only, no global Fresh).  
**Non-scope:** LLM router agent; claiming cryptographic agent identity.  
**Relevant requirements:** RTE-001…RTE-004, GRD-002.  
**Lead:** m4trix-scrum  
**Supporting:** scripts; verifier  
**Skills:** pipelines updated  
**Research:** Cursor subagentStart evidence feasibility (use T1 probe).  
**Approved files:** routing-policy, guard Evaluate-Routing, agents/skills descriptions for routing hints, pilots.  
**Preserve:** Trivial patch stays minimal route.  
**Approach:** Deterministic calculate from attributes; LLM fills attributes only.  
**AC:** Fixtures for Flutter patch, significant UI (forward-declare), auth/security, recovery, mixed-stack; omit-mandatory fails validation; parent impersonation ≠ evidence; limitation documented if identity unverifiable.  
**Fail:** Markdown table alone as “enforcement.”  
**Edge:** Multi-stack; deferred agents before introduction task.  
**Verification:** Script calculate tests + ± behavioural.  
**Recovery:** Surgical policy fix.  
**Evidence:** Policy file + eval matrix.  
**Stop:** Captain accepts T5.  
**Handoff:** Policy path; attribute schema.

---

## T6 — Research-driven engineering

**Task ID:** T6  
**Primary problem:** Custom/hallucinated solutions without investigating established approaches.  
**Objective:** `engineering-research` skill; activation by complexity/unfamiliarity not scale alone; findings + validator; alternatives before commit.  
**Dependencies:** T5 accepted.  
**Scope:** `skills/engineering-research`; ACTIVE_TASK.research; integrity rules; PoC guidance; wire into module/product/recovery/routing; research validator; `_pilot/research_eval`.  
**Non-scope:** Permanent research agent; mandatory research on routine copy patches.  
**Relevant requirements:** RSH-001…RSH-004, GRD-002.  
**Lead:** implementers via skill  
**Supporting:** architect for architecture research  
**Skills:** engineering-research  
**Research:** meta — skill defines research order.  
**Approved files:** skill, MANIFEST, routing rows, guard validator, pilots, thin pipeline refs.  
**Preserve:** Patch skip when not non-trivial.  
**Approach:** Project → native → packages → docs; recommend + why; version check.  
**AC:** Unfamiliar triggers research; trivial does not; fabricated sources fail; unavailable web handled; ± evals.  
**Fail:** Research that only rubber-stamps preferred solution without alternatives.  
**Edge:** Recurring patch defect still triggers.  
**Verification:** Script presence checks + live prompt procedures.  
**Recovery:** Surgical.  
**Evidence:** Sample findings JSON + eval.  
**Stop:** Captain accepts T6.  
**Handoff:** Skill path; activation criteria summary.

---

## T7 — Solution proportionality and anti-overengineering

**Task ID:** T7  
**Primary problem:** Unnecessarily complex solutions and silent architecture expansion.  
**Objective:** Solution Escalation Ladder influences selection and verification.  
**Dependencies:** T2 accepted (may proceed once T2 done; need not wait for T3–T6 if captain sequences after T2, but registry default order allows after T6 in practice — **dependency is T2 only**).  
**Scope:** Update `04-code-craft`; verifier ladder check for significant decisions; pipeline anti-promotion reinforcement; `_pilot/proportionality_eval`.  
**Non-scope:** New agents; blocking ordinary patches with essays.  
**Relevant requirements:** SOL-001, SOL-002, NFR-006.  
**Lead:** m4trix-architect / craft  
**Supporting:** verifier; flutter for reuse alignment  
**Skills:** none new  
**Research:** none  
**Approved files:** `constitution/project-rules/04-code-craft.mdc`, verifier agent, pipelines, pilots, optional ecc note.  
**Preserve:** Shared-component extraction when foreseeably reused; design tokens.  
**Approach:** Ladder as decision framework + verifier gate when significant.  
**AC:** Localized fixture rejects unjustified restructure; justified reuse still allowed; ± evals.  
**Fail:** Ladder as ignored prose.  
**Edge:** Significant vs ordinary patch definition.  
**Verification:** Simulated + live “do not restructure” procedure.  
**Recovery:** Surgical rule edits.  
**Evidence:** Eval report.  
**Stop:** Captain accepts T7.  
**Handoff:** Ladder location; significant-decision trigger.

---

## T8 — UI/UX design intelligence

**Task ID:** T8  
**Primary problem:** Functional but basic/unpolished UI.  
**Objective:** Ship `m4trix-ui-designer`; bounded journey→render→critique→refine for significant UI.  
**Dependencies:** T6 + T7 accepted.  
**Scope:** `agents/m4trix-ui-designer.md`; routing rows; pipeline significant-UI workflow; design research via engineering-research when needed; disposition vs design-system vs implementer vs verifier; UI defect fixtures (may seed for T9).  
**Non-scope:** Full visualStatus tooling (T9); trivial copy/colour full workflow.  
**Relevant requirements:** UI-001…UI-003, RTE (ui rows).  
**Lead:** m4trix-ui-designer  
**Supporting:** design-system; flutter; verifier  
**Skills:** engineering-research (conditional); ui-craft/ui-stress on-demand  
**Research:** pattern research when beneficial.  
**Approved files:** agent, MANIFEST, pipelines, USER_RULES thin pointer, pilots seeds.  
**Preserve:** design-system token ownership; patch skip designer.  
**Approach:** Bounded 10-step workflow from DESIGN; quality judged on rendered UI.  
**AC:** Significant UI requires designer path; design-doc-only done fails; rendered critique occurs; ± evals including weak-hierarchy fixture.  
**Fail:** More documentation without better UI.  
**Edge:** Subjective taste → captain.  
**Verification:** Live render/critique procedure + static agent presence.  
**Recovery:** Surgical.  
**Evidence:** Before/after notes + screenshots if available.  
**Stop:** Captain accepts T8.  
**Handoff:** Agent name; workflow checklist path.

---

## T9 — Visual and interaction verification

**Task ID:** T9  
**Primary problem:** Compile/tests treated as UI done.  
**Objective:** visualStatus enum, proportional interaction checks, defect fixtures, visual evidence validator.  
**Dependencies:** T8 + T5 accepted.  
**Scope:** production-bar/verifier updates; visualStatus in ACTIVE_TASK; `_pilot/visual_verify_eval` + ui_craft_eval evidence expectations; Guard visual validator; honest blocked/unverified states.  
**Non-scope:** Fabricating emulator coverage; claiming tools not present.  
**Relevant requirements:** VIS-001, VIS-002, UI-003, GRD-002.  
**Lead:** m4trix-verifier  
**Supporting:** flutter; ui-designer  
**Skills:** ui-stress on-demand  
**Research:** available render tooling from environment.  
**Approved files:** agents/rules, templates, pilots, guard validator.  
**Preserve:** Proportionate checks; tiny patches skip full visual bar.  
**Approach:** Status honesty; objective defects vs subjective.  
**AC:** Cannot set visually_verified without artifacts; static-only ≠ visual pass; ± evals; shared-component visual regression case.  
**Fail:** Fabricated screenshots.  
**Edge:** Verification blocked reported explicitly.  
**Verification:** Script validator + live procedure.  
**Recovery:** Surgical.  
**Evidence:** Artifacts + visualStatus samples.  
**Stop:** Captain accepts T9.  
**Handoff:** Status enum; fixture paths.

---

## T10 — Complete Guard integration and selective hook enforcement

**Task ID:** T10  
**Primary problem:** Capability validators exist in pieces; completion/hooks incomplete.  
**Objective:** Integrate completion-blocking Guard invocation; selective hooks only where T1 proved events; publish bypass matrix.  
**Dependencies:** T3–T9 accepted.  
**Scope:** Completion gate wiring in pipelines/verifier; hook scripts in kit `hooks/` source; smoke for supported denies; bypass matrix doc; **no global Fresh**.  
**Non-scope:** Unbypassable security claims; unrelated third-party hook breakage.  
**Relevant requirements:** GRD-003, RB-08, NFR-001, ISO-002.  
**Lead:** scripts / architect  
**Supporting:** security (hook review); verifier  
**Skills:** pipelines  
**Research:** re-validate T1 hook probe.  
**Approved files:** `hooks/`, `bootstrap/guard/`, pipelines, docs (bypass matrix), smoke.  
**Preserve:** Third-party hooks merge policy; sessionStart advisory character where still advisory.  
**Approach:** Enforcement levels per DESIGN; failClosed only where justified.  
**AC:** Negative matrix (missing approval, open EGM block, exhausted retries, out-of-scope files, missing evidence) fails at script/completion level; bypass matrix published; ± evals; no Fresh.  
**Fail:** Claiming preventive enforcement where only advisory.  
**Edge:** Hook event absent → documented fallback.  
**Verification:** Script + integration + live attempt to complete with Guard fail.  
**Recovery:** Strip bad hooks via existing merge/strip tools.  
**Evidence:** Bypass matrix + test outputs.  
**Stop:** Captain accepts T10.  
**Handoff:** Gate command; bypass matrix path.

---

## T11 — Independent verification, approval integrity, security-policy consistency

**Task ID:** T11  
**Primary problem:** Self-approval, weak verifier independence, security policy contradiction.  
**Objective:** Fresh-Task verify for high-risk; approval fingerprints; align Critical/High with EGM; reject LLM-only test reports.  
**Dependencies:** T10 accepted.  
**Scope:** verifier/security/EGM template alignment; ACTIVE_TASK approval fingerprints; VER-003/004; docs; fixtures for invalidate-on-spec-change.  
**Non-scope:** Duplicating Guard scripts; re-running EGM for ordinary fixes.  
**Relevant requirements:** VER-001…VER-004, REL (RB-06/07), security consistency.  
**Lead:** m4trix-verifier  
**Supporting:** m4trix-security  
**Skills:** egm-review (policy align only)  
**Research:** none required  
**Approved files:** agents security/verifier, EGM templates, ACTIVE_TASK template, ecc security-checklist if needed, pilots.  
**Preserve:** EGM independence; captain risk-accept rules for planning tradeoffs only.  
**Approach:** Single security policy; fingerprint bind.  
**AC:** Critical/High not “passed” via risk-accept; stale approval after REQUIREMENTS change fails; high-risk verify evidence of independent run; ± evals.  
**Fail:** Agent writing `approved:true` alone.  
**Edge:** Formatting-only → fail closed if uncertain (VER-004).  
**Verification:** Script fingerprint + live self-approve rejection procedure.  
**Recovery:** Surgical.  
**Evidence:** Policy diff + fixtures.  
**Stop:** Captain accepts T11.  
**Handoff:** Fingerprint algorithm location; security policy source of truth.

---

## T12 — Context management, coordination, model policy, token optimisation

**Task ID:** T12  
**Primary problem:** Duplication and always-on growth; unmeasured productivity; need optional model policy.  
**Objective:** Dedupe instructions; enforce context budget using T1 baseline; optional captain model/reasoning policy (default inherit); use accumulated metrics.  
**Dependencies:** T11 accepted.  
**Scope:** Audit USER_RULES vs rules vs agents vs skills; slim always-on; metrics fields usage; model policy table in DECISIONS/ecc; ensure patch path still skips heavy ceremony.  
**Non-scope:** Silent expensive model pins; new always-on rule files for v2 features.  
**Relevant requirements:** CTX-001…CTX-003, NFR-004.  
**Lead:** m4trix-architect  
**Supporting:** scrum; docs  
**Skills:** none new  
**Research:** none  
**Approved files:** constitution, USER_RULES, agents/skills trim, DECISIONS, metrics docs.  
**Preserve:** Progressive load; patch lightness.  
**Approach:** Move intelligence to conditional skills; measure bytes.  
**AC:** Always-on ≤ baseline+25% or DECISIONS exception; patch skips EGM/research/designer; metrics template usable; no fabricated improvement %.  
**Fail:** Bloated always-on for Guard prose.  
**Edge:** Unavailable cost metrics (CTX-003).  
**Verification:** Byte measure script + ceremony policy checks + simulated patch path.  
**Recovery:** Revert rule bloat.  
**Evidence:** Byte table + audit notes.  
**Stop:** Captain accepts T12.  
**Handoff:** Byte numbers; model policy location.

---

## T13 — Comprehensive behavioural evaluation

**Task ID:** T13  
**Primary problem:** Need integrated proof v2 capabilities work together vs baseline.  
**Objective:** Run full eval suites; compare to T1; record pass/fail/limitations; no unrestricted remediations.  
**Dependencies:** T12 accepted.  
**Scope:** Execute `_pilot` v2 suites; live procedures as required; release-blocker checklist draft against RB-01…RB-10; park fixes as new task IDs.  
**Non-scope:** Implementing new features; silent scope expansion.  
**Relevant requirements:** EVAL-001, REL-001, RB-*.  
**Lead:** m4trix-verifier  
**Supporting:** all specialists as fixtures demand  
**Skills:** recovery if eval failures need diagnosis  
**Research:** as failures require  
**Approved files:** `_pilot/**/evidence/`, eval reports under `_pilot/v2_eval/`, docs status only.  
**Preserve:** Baseline honesty; no fabricated agent runs.  
**Approach:** Integration eval only.  
**AC:** Report vs T1; each prior capability still has evidence; blockers listed honestly; ± integrated scenarios executed.  
**Fail:** Claiming pass without running live where required.  
**Edge:** Captain-gated live steps incomplete → status incomplete not pass.  
**Verification:** The task is verification.  
**Recovery:** Use T4 mechanisms; new remediation tasks.  
**Evidence:** Master report.  
**Stop:** Captain accepts T13 (or accepts with listed residual non-blockers).  
**Handoff:** Open RB list; remediation task proposals.

---

## T14 — Controlled real-world application pilots

**Task ID:** T14  
**Primary problem:** Script/fixture success ≠ improved real development outcomes.  
**Objective:** Controlled pilots on captain-authorized apps/branches comparing to v1.6.0 where possible.  
**Dependencies:** T13 accepted; **separate per-app captain authorization**.  
**Scope:** Pilot plan; recoverable boundaries; representative tasks (partial module repair, recurring defect, unfamiliar requirement, localized fix, polished UI, mixed-stack routing); outcome report.  
**Non-scope:** Accessing apps without auth; global install; modifying production without recoverable boundary.  
**Relevant requirements:** EVAL-002, REL-001.  
**Lead:** captain-gated; scrum coordinates  
**Supporting:** as routed  
**Skills:** as routed  
**Research:** as needed  
**Approved files:** pilot reports under `_pilot/v2_real_pilots/` (kit) — **not** the apps until authorized.  
**Preserve:** App data/config; kit globals still 1.6.0 unless captain says otherwise for pilot machine.  
**Approach:** Isolated branch/copy; compare outcomes.  
**AC:** At least the authorized pilot set completed or captain written deferral in DECISIONS (eligible tradeoff); report vs baseline; no unauthorized access.  
**Fail:** Touching apps without auth.  
**Edge:** Partial pilot set with written captain scope.  
**Verification:** Pilot reports + captain sign-off.  
**Recovery:** Revert pilot branches.  
**Evidence:** Per-app reports.  
**Stop:** Captain accepts T14.  
**Handoff:** Pilot results; residual field risks.

---

## T15 — Compatibility, migration, and release candidate

**Task ID:** T15  
**Primary problem:** Upgrade must not brick installs or user configuration.  
**Objective:** Verify install/reapply/upgrade paths; docs match behaviour; package RC; no global activation.  
**Dependencies:** T14 accepted.  
**Scope:** REL-002 fixtures; HOW_MATRIX_WORKS/INSTALL/README accurate to implemented v2; `package-source` RC zip; rollback notes; CTX-003 limitations section if metrics unavailable.  
**Non-scope:** `install-globals -Fresh` to captain machine as activation (that is T16).  
**Relevant requirements:** REL-001, REL-002, NFR-003, CTX-003, RB-09, RB-10.  
**Lead:** m4trix-docs-deploy + bootstrap  
**Supporting:** verifier  
**Skills:** bootstrap-org (docs only)  
**Research:** none  
**Approved files:** bootstrap, hooks source, VERSION→2.0.0 when behaviour ready, dist RC, root docs, MODULE_HANDOFF.  
**Preserve:** Third-party hooks; customized SDLC skip; delivery voice.  
**Approach:** Smoke + install fixtures; package; document limitations.  
**AC:** Smoke green; migration fixtures pass; RC in `dist/`; docs accurate; RB checklist status recorded; no silent global activate.  
**Fail:** Docs describing unbuilt behaviour.  
**Edge:** Kit-as-workspace apply safety.  
**Verification:** Script + dry-run install in `M4TRIX_CURSOR_HOME` isolation.  
**Recovery:** Keep 1.6.0 zip.  
**Evidence:** RC path + test log.  
**Stop:** Captain accepts T15 / RC.  
**Handoff:** RC artifact path; rollback steps; open limitations.

---

## T16 — Captain-approved activation and rollback

**Task ID:** T16  
**Primary problem:** Controlled cutover to v2.0.  
**Objective:** Explicit activation only after captain go; verified rollback path.  
**Dependencies:** T15 accepted + written captain activation approval; all RB-01…RB-10 clear (or activation refused).  
**Scope:** Written procedure; captain-executed install-globals/apply to named workspaces; rollback dry-run or verified steps; post-activate marker versions.  
**Non-scope:** Auto-apply to all apps; force-push; silent Fresh.  
**Relevant requirements:** REL-001, ISO-002 (lifted only here), RB-*.  
**Lead:** captain executes; agent prepares checklist only  
**Supporting:** docs-deploy  
**Skills:** none forcing apply  
**Research:** none  
**Approved files:** activation checklist in docs; no unsolicited machine mutation by agent.  
**Preserve:** Ability to roll back to 1.6.0 package.  
**Approach:** Captain runs commands from checklist; agent verifies markers if asked.  
**AC:** Written go-ahead; blockers clear; rollback path verified; only named workspaces touched.  
**Fail:** Agent self-activating globals.  
**Edge:** Partial workspace rollout.  
**Verification:** Marker version 2.0.0; smoke on activated machine optional.  
**Recovery:** Re-install 1.6.0 from retained zip.  
**Evidence:** Captain confirmation + marker files.  
**Stop:** Activation complete or refused.  
**Handoff:** Active version; rollback command.

---

## Remediation tasks

Park under `BACKLOG.md` with new IDs. Do not reuse T1–T16. Require explicit `Start Task <id>`.

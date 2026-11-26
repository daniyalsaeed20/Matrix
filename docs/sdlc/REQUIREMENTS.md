# Requirements — M4TR!X v2.0

**Status:** Locked  
**Source PRD:** docs/sdlc/PRD.md  
**Last updated:** 2026-11-25

## Functional requirements

| ID | Requirement | Priority | Happy | Fail | Edge |
|----|-------------|----------|-------|------|------|
| REG-001 | Before modifying a multi-behaviour module, build a behaviour inventory with states: verified_working, verified_failing, not_verified, blocked | Must | Inventory lists real behaviours with evidence refs | Code-exists ≠ working | Unverifiable → blocked, not pretended protected |
| REG-002 | Establish protected baseline (passing tests, known fails, rev, dirty user changes, checkpoint) before repair | Must | Baseline recorded in ACTIVE_TASK.regression | Missing baseline → no implement | No auto destructive git recovery |
| REG-003 | After each meaningful implementation unit, verify targeted fails AND protected behaviours | Must | Unit accepted only if protected still pass | Protected fail → reject unit | Shared-component blast checked |
| REG-004 | Cumulative progress: keep working behaviours working while repairing others; coordinated multi-fix OK when shared root cause evidenced | Must | 5/10→6/10 without losing the five | Swap failures not accepted as progress | Interdependent fix documented |
| REG-005 | Test integrity: ban weaken/remove/skip/mock-away/hardcode/disable-security/fake-ran to obtain green | Must | Justified test change with evidence | Integrity violation fails task | Independent review when tests change behaviour claims |
| REG-006 | Ten-feature eval fixture uses independently observable behaviours (not mocked status flags) | Must | 5 pass + 5 fail observable | Intentional regression rejected | User dirty files preserved |
| REC-001 | Recovery workflow (skill, not a fourth scale) activates on defined triggers; routine understood bugs skip | Must | Trigger → investigate-first path | Forced ceremony on trivial patch → fail eval | Captain-requested debug always allowed |
| REC-002 | Investigation requires reproduce, expected/actual, baseline, evidence, facts vs assumptions, hypothesis, validation plan, smallest experiment | Must | Evidence before production change | Speculative rewrite without investigation → reject | Read-only / diagnostic instrumentation preferred first |
| REC-003 | Persistent recovery record in ACTIVE_TASK.recovery (and optional RECOVERY.md if JSON unreadably large) survives chats/handoffs/specialists | Must | New chat continues attemptCount | Reset budget on new chat → fail | Handoff cannot grant approval/scope |
| REC-004 | Between attempts, record prediction vs actual, disproved assumptions, strategy delta; same failed approach without new evidence blocked | Must | Materially different next approach | Rename-only / tweak-of-rejected → blocked | Contradicted hypotheses marked |
| REC-005 | Attempt budget: after 1 fail reconsider; after 2 require independent diagnostic or new evidence path; after 3 stop speculative impl and escalate to captain; protected regression rejects change | Must | Escalation report at threshold | Endless retries → fail | Budgets configurable by complexity; meaningful attempt defined |
| REC-006 | Ship `m4trix-debugger` as a permanent specialist for complex recovery diagnosis/evidence/hypotheses; prefer readonly investigate; must not become a generic feature implementer | Must | Debugger invoked on complex recovery routes | Debugger owns production feature impl as primary → fail eval | Verifier still owns completion judgment; implementers apply approved fixes |
| RSH-001 | Conditional engineering-research skill; activation by unfamiliarity/complexity/integration/security/perf/platform/tradeoff — not by scale alone | Must | Unfamiliar triggers research | Routine copy patch skips | Patch with recurring/unfamiliar issue still triggers |
| RSH-002 | Research order: project → deps → official docs → packages → maintainer issues → established refs → community | Must | Order followed in findings | Jump to custom without project/native check → fail | Version-compat validated |
| RSH-003 | Findings include alternatives, native capability, packages, limits, recommendation + why, source URLs/verification; no invented sources | Must | Concise persisted findings | Claimed unread docs → integrity fail | Web unavailable → explicit limit + local evidence or stop |
| RSH-004 | Prefer small isolated PoC before production when claims uncertain | Should | PoC validates API | Unverified claim shipped as fact → fail | PoC not required for routine |
| RTE-001 | Structured classification attributes. **Patch-minimal:** scale, taskType, stacks[], uiInvolvement, securityRisk. **Full set** (module/product/recovery or non-trivial patch): also layers[], uncertainty, regressionRisk, recoveryActive, researchNeeded, reviewsRequired[]. **Non-trivial patch** = uncertainty med/high OR regressionRisk OR securityRisk OR recoveryActive OR unfamiliar tech OR recurring defect | Must | Required attrs present per definition | Missing required attrs → validate fail | Multi-stack allowed |
| RTE-002 | Machine-readable routing policy computes mandatory/conditional/unnecessary specialists and skills from attributes | Must | Deterministic calculate step | Markdown-only route without policy eval → insufficient | Trivial patch → minimal route |
| RTE-003 | Distinguish classify / calculate / invoke / specialist-complete / validate; parent impersonation ≠ independent invocation | Must | Evidence of Task/subagent or documented fallback | Claim-only specialist work → reject where enforceable | Limitation documented when identity unverifiable |
| RTE-004 | Live routing evals: positive correct route + negative missing mandatory specialist | Must | Both executed before task accept | Script-only routing “pass” insufficient for T5 accept | Mixed-stack fixture included |
| SOL-001 | Solution Escalation Ladder applied for significant decisions; proportionate justification recorded | Must | Localized fix chosen when sufficient | Unjustified restructure → reject | Ordinary patches need no lengthy writeup |
| SOL-002 | Architecture escalation requires evidence smaller approaches insufficient + captain approval | Must | Approval bound to scope | Silent patch→module/product promotion → fail | Shared-component extraction still encouraged when foreseeably reused |
| UI-001 | Significant UI uses bounded workflow: journey → research(if needed) → direction → reuse → implement → render → inspect → critique → refine → verify | Must | Rendered UI critiqued | Design-doc-only “done” → fail | Trivial copy/colour skips full workflow |
| UI-002 | Ship `m4trix-ui-designer` for significant UI: owns journeys/composition/refinement direction and post-render critique notes. Design-system owns tokens/catalog/motion policy. Implementer owns framework code. Verifier owns pass/fail vs AC and visualStatus honesty — not redesign authorship | Must | Clear disposition: designer critiques → implementer fixes → verifier judges | Designer implements product UI or verifier redesigns as primary → fail | Trivial UI patch may skip designer |
| UI-003 | Visual quality judged on rendered output against objective defect fixtures (hierarchy, spacing, type, overflow, keyboard, responsive, motion glitch, shared regression, missing states) | Must | Defects fixed or filed | Screenshot alone ≠ quality pass | Captain final on subjective taste |
| VIS-001 | Significant UI completion requires visualStatus: visually_verified \| functionally_verified_visually_unverified \| partial \| blocked \| changes_requested | Must | Status honest | Static analysis alone → visually_verified forbidden | Fabricated screenshots forbidden |
| VIS-002 | Visual regression protection for existing UI: capture prior where possible; protect unrelated; shared-component blast | Should | Unrelated screens intact | Shared tweak breaks neighbor → reject | Dynamic content similarity caveats documented |
| GRD-001 | Task 2 ships minimal Guard: shared runner, JSON results, task-state validation, evidence conventions, isolated tests. Extensibility = drop-in validator scripts with one shared result shape — no plugin framework beyond a folder convention | Must | Runner fails closed on schema errors | Premature plugin abstraction or duplicate runners → fail craft | No full hook matrix yet |
| GRD-002 | Capability tasks add validators (regression, attempts, route, research, visual) using shared conventions | Must | Validator fails on negative fixtures | Capability ships instruction-only with no validator when feasible → incomplete | Skip only with documented platform impossibility |
| GRD-003 | Task 10 integrates Guard completion checks + selective hooks. Distinguish **preventive** (supported deny hooks), **completion-blocking** (skills/verifier must invoke Guard runner and refuse done if ok=false), and **advisory**. Publish bypass matrix. Never claim unbypassable security | Must | Supported cases blocked or completion refused | Claiming done with Guard ok=false → fail; undocumented mandatory bypass → release blocker | If Cursor hook event unavailable, document fallback; do not fake enforcement |
| VER-001 | Verifier checks AC, evidence authenticity, regression, scope, craft/ladder, security needs, UI/visual status; high-risk uses fresh-Task independence | Must | Incomplete reported honestly | Rubber-stamp / LLM-fake tests → fail | EGM not re-run for ordinary impl fixes |
| VER-002 | Approval bound to taskId + specFingerprint + scopeFingerprint + baselineRev; substantive change invalidates; formatting-only does not | Must | Invalidated approval blocks done | Agent writing approved:true alone insufficient | Limitation: not cryptographic captain auth |
| VER-003 | Security: Critical/High unresolved defects block done and are not risk-acceptable as “passed”; align with EGM; Medium/Low may backlog with note | Must | Single consistent policy | EGM vs security contradiction → Blocking until fixed | Risk-accept ≠ defect resolved |
| CTX-001 | Progressive context preserved; new intelligence mostly conditional; always-on growth ≤ +25% bytes vs T1 baseline without DECISIONS exception | Must | Patch stays light | Unnecessary always-on bloat → T12 fail | Authoritative location per rule |
| CTX-002 | Metrics captured from Task 1; unavailable marked; no fabricated improvement % | Must | Baseline comparable | Invented costs → integrity fail | Repeat evals when practical |
| CTX-003 | RC/activation may proceed if primary cost metrics remain `unavailable`, provided release blockers are clear and unavailable fields are listed in the RC limitations section — never invent a % improvement | Must | RC lists unavailable metrics honestly | Fabricated improvement to justify activate → blocker | Secondary measured metrics still reported when present |
| ISO-001 | Three environments distinct: stable runtime, canonical source, isolated eval workspace. Eval workspace must be a **true sibling folder** (not nested under kit multi-root) unless Task 1 fingerprint proves safe | Must | Fingerprint shows project WIP overrides globals | Unproven isolation claimed as proven → fail | Fallback: scripts + captain procedures labeled isolation:unproven |
| ISO-002 | During Tasks 1–15, agents must not run `install-globals -Fresh` or apply unfinished v2 to unrelated apps; Fail if proposed | Must | Dev uses source + isolated apply-to-eval only | WIP Fresh against globals → stop + captain | Kit dogfood `.cursor` sync only via explicit captain-approved apply |
| EVAL-001 | Each significant capability task includes ≥1 positive and ≥1 negative behavioural evaluation before captain accept | Must | Live or documented captain procedure executed | Static-only accept → incomplete | T13 integrates previously accepted caps |
| EVAL-002 | Task 14 controlled real-world pilots before RC/activation; separate auth; recoverable boundaries | Must | Pilot report vs baseline | Access without auth → forbidden | Script suites alone insufficient for activation |
| REL-001 | Activation (Task 16) blocked while any **Release Blocker** in DESIGN §Release blockers remains open. Captain risk-accept cannot convert a blocker into a pass. Acceptable limitations may ship documented | Must | All blockers closed or activation refused | Risk-accept used to skip blocker → forbidden | Preserve previously supported v1.6.0 capabilities |
| REL-002 | Fresh install, reapply, 1.6→2.0 upgrade, third-party hooks preservation, customized SDLC skip, kit-clone-as-workspace safety each have happy/fail/edge checks before RC | Must | Fixtures pass | Migration defect risking user hooks/SDLC → blocker | Malformed hooks.json continues fail-closed |
| PROG-001 | Start Task N loads registry (DESIGN §Task registry), checks deps/auth, implements only that task, evaluates, records evidence, stops | Must | No auto next task | Silent renumber / scope creep → fail | Remediation tasks get new IDs + approval |
| VER-004 | Fingerprint: substantive content change invalidates approval; if formatting-only cannot be reliably detected, invalidate on content hash change (fail closed on uncertainty) | Must | Re-approval required after substantive edit | Stale approval used after REQUIREMENTS change → fail | Documented in evidence |

## Non-functional requirements

| ID | Category | Requirement | Measure |
|----|----------|-------------|---------|
| NFR-001 | Performance | Guard/scripts lightweight; no expensive scan every prompt | Hook/scripts budget documented; smoke time not regress >2× without justification |
| NFR-002 | Security | No secrets in research queries; hooks don’t weaken install safety; security policy consistent | Checklist + EGM/security align |
| NFR-003 | Compatibility | Fresh install, reapply, upgrade 1.6→2.0, third-party hooks, user SDLC preservation, OS support retained | Smoke + install fixtures |
| NFR-004 | Token efficiency | Conditional activation; patch cheap; primary metric = cost per verified task | Metrics from T1; T12 optimisation |
| NFR-005 | Observability | Machine-readable Guard results + task evidence fields | JSON schema + ACTIVE_TASK |
| NFR-006 | Maintainability | Prefer extend existing components; no speculative abstractions | Craft + EGM complexity review |
| NFR-007 | Isolation | Experimental eval must not mutate stable globals or unrelated apps | Proven fingerprint or documented limit |

## Out of scope

- Automatic global activation during development
- Additional permanent agents beyond Debugger and UI Designer (unless Task evidence forces a captain-approved exception)
- LLM consensus committees / multi-model voting as default
- Accessing captain’s two field apps without explicit authorization

## Open questions

- Task 14 app list and recoverable boundary method (branch vs copy)

## Closed at Task 4

- Attempt budgets locked: patch **2** / module **3** / product-critical **3** then escalate; override via `ACTIVE_TASK.recovery.attemptBudget` (2026-11-25)

## Approval

- [x] Captain locked requirements on 2026-11-25 (`approve product spec for backlog`)

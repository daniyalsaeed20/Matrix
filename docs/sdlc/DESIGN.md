# Design — M4TR!X v2.0

**Status:** Locked  
**Last updated:** 2026-11-25  
**Sources:** PRD.md, REQUIREMENTS.md, repository audit of v1.6.0

## Architecture overview

v2.0 is an **evolution** of v1.6.0, not a replacement runtime.

```text
Captain
  → Pipeline skill (product | module | patch | recovery)
      → Classification attributes → routing-policy.json (deterministic)
          → Specialists / skills (conditional)
              → ACTIVE_TASK (+ regression | recovery | routing | research | evidence | metrics)
                  → Guard validators (shared runner + plugs)
                      → Verifier (skeptical; fresh-Task when high-risk)
                          → Captain accept
```

**Preserved core:** captain gates, product/module/patch, EGM fresh-Task Goldfish, progressive context, SDLC files, MANIFEST apply/install safety, delivery voice, craft hierarchy, design-system + on-demand ui-craft/ui-stress.

**Added:** Recovery skill, Debugger + UI Designer (conditional), engineering-research skill, machine-readable Router, Regression Lock, early minimal Guard + capability validators, visual verification statuses, metrics, isolated eval strategy, real-world pilots, release blockers.

## Module boundaries

| Component | Responsibility | Non-responsibility |
|-----------|----------------|-------------------|
| Pipelines | Ceremony, gates, when to load skills | Mechanical validation |
| routing-policy.json + evaluator | Compute mandatory/conditional/unnecessary from attributes | LLM freestyle routing |
| pipeline-recovery | Investigation-first workflow | Ordinary feature build |
| m4trix-debugger | Diagnosis, evidence, hypotheses | Owning production feature impl |
| engineering-research | Conditional research + findings | Permanent agent; routine patches |
| m4trix-ui-designer | Journeys, composition, refinement direction | Tokens (design-system); framework impl |
| m4trix-design-system | Tokens, catalog, motion policy | Full UX journey ownership |
| Implementers | Correct production code | Approving own done |
| bootstrap/guard | Deterministic validate + JSON results | LLM judgment of UI taste |
| m4trix-verifier | AC/evidence/regression/craft/visual status | Rewriting app code |
| Isolated eval workspace | Live behaviour tests of WIP kit | Replacing globals |

## State management

### ACTIVE_TASK additive fields

- `routing`: `{ attributes, calculated, invoked[], evidence[], validated }`
- `regression`: `{ behaviours[], baselineRev, protectedChecks[], dirtyPaths[], status }`
- `recovery`: `{ facts[], assumptions[], hypotheses[], contradicted[], rejectedApproaches[], attempts[], attemptCount, attemptBudget, checkpoint, nextAction }`
- `research`: `{ required, findings[], sources[], limitations[], poc? }`
- `verificationEvidence`: `{ commands[], exitCodes[], artifacts[], visualStatus, limitations[] }`
- `approval`: existing + `specFingerprint`, `scopeFingerprint`, `baselineRev`
- `metrics`: `{ measured{}, unavailable[], notes }`
- `guard`: `{ lastResultPath, status }`

Single source of task memory. Optional `docs/sdlc/RECOVERY.md` only if recovery JSON becomes unreadable; must not become competing truth.

### Fingerprints

- `specFingerprint`: hash of approved REQUIREMENTS/DESIGN sections (or listed reviewPaths) excluding pure whitespace/formatting-only changes when detectable; if formatting detection uncertain, prefer invalidate on content hash change and document.
- `scopeFingerprint`: hash of `approvedScope` + sorted `permittedPaths`.
- Substantive change → approval invalid until captain re-approves.

### Attempt definition (Recovery)

A **meaningful attempt** is an implementation or production-behaviour change intended to fix the defect under the current hypothesis. Not: renames, new subtask IDs, re-reading files, or restating the same patch. Strategy delta required: predicted vs actual, disproved assumptions, why next approach differs.

**Default budgets:** patch recovery 2; module 3; product-critical 3 then escalate. Captain may override in ACTIVE_TASK.

## Task-routing contracts

### Classification (model-assisted → structured attributes)

scale, taskType, stacks[], layers[], uncertainty (low|med|high), securityRisk, uiInvolvement (none|patch|significant), regressionRisk, recoveryActive, researchNeeded, reviewsRequired[].

### Calculation (deterministic)

`bootstrap/guard/Evaluate-Routing.ps1` (or equivalent) reads `templates/sdlc/routing-policy.json` + attributes → mandatoryAgents, conditionalAgents, forbiddenUnnecessary, requiredSkills, requiredValidators.

### Invocation evidence

Prefer Cursor `subagentStart`/`subagentStop` logs or Task tool evidence artifacts written under `_pilot/.../evidence/` or `docs/sdlc/evidence/`. Parent prose claiming “I acted as security” is **not** independent invocation.

### Fallback when identity unverifiable

Record `routing.evidenceLimitation`; require captain acknowledgment for high-risk tasks; still run deterministic calculate + completion validators for structured fields.

## Approval and validation contracts

### Minimal Guard (Task 2)

- Shared runner: input ACTIVE_TASK (+ optional git baseline) → JSON `{ ok, errors[], warnings[], checks[] }`
- Validates: JSON schema basics, required fields by phase, evidence object shape
- Extensibility: `validators/*.ps1` registered by name
- Isolated tests under `bootstrap/guard/tests` with `M4TRIX_CURSOR_HOME` pattern where needed
- **Not** yet: full hook enforcement, all capability plugs

### Per-capability validators (Tasks 3–9)

| Capability | Validator checks |
|------------|------------------|
| Regression | baseline present; protectedChecks recorded; integrity flags |
| Recovery | attemptCount ≤ budget; rejectedApproaches not repeated without newEvidence; strategy delta fields |
| Routing | calculated mandatory ⊆ invoked evidence (or limitation ack) |
| Research | if required, findings+sources present; no empty research |
| Visual | significant UI cannot claim visually_verified without artifacts |

### Complete Guard (Task 10)

Enforcement levels (honest):

| Level | Mechanism | Effect |
|-------|-----------|--------|
| Preventive | Cursor hooks that support deny (`beforeShellExecution`, `preToolUse`, `subagentStart`) **only when live-verified** | Blocks specific tool/shell actions |
| Completion-blocking | `Invoke-CompletionGate.ps1` + pipelines/verifier; `status=done` / captain-ready claim forbidden while `ok=false` | Process gate (model+script), not OS sandbox |
| Advisory | `sessionStart` / `workspaceOpen` | Reminders only |

- Default `hooks/hooks.json` registers advisory events only. Deny-candidate scripts ship under `hooks/` **unregistered** until live-verified (`HOOK_PROBE_T10.json`).
- Bypass matrix: [GUARD_BYPASS_MATRIX.md](GUARD_BYPASS_MATRIX.md) (Write/StrReplace; fail-open; parent impersonation; model ignore).
- Never claim unbypassable security.

## Recovery behaviour

Triggers: protected regression; repeated defect; multi-behaviour fails; uncertain root cause; evidence contradicts assumptions; large blast radius; repeated failed approach; scale under-classified; captain debug request.

Non-triggers: well-understood localized bug with clear fix.

Flow: reproduce → baseline → evidence → facts/assumptions → hypotheses → research if needed → smallest experiment → targeted+protected checks → record → accept or strategy-change.

After budget: escalate with concise report; optional captain-controlled model bump — **never** substitutes for investigation.

## UI/UX design flow (significant UI)

1. Journey & goals  
2. Pattern research if beneficial (via engineering-research when unfamiliar)  
3. Visual direction (product identity)  
4. Reuse existing components/tokens  
5. Implement  
6. Render (Flutter web/device/browser as available)  
7. Inspect screenshots/interactions  
8. Critique vs objective defects  
9. Refine  
10. Set visualStatus honestly  

Captain accepts subjective quality.

## Isolation design

| Environment | Path / mechanism |
|-------------|------------------|
| Stable runtime | `~/.cursor` m4trix 1.6.0 — untouched until Task 16 |
| Canonical source | Matrix repo source trees |
| Eval workspace | **True sibling directory** (e.g. `e:/development/Matrix-v2-eval/`), opened in a **separate** Cursor window (not multi-root with the kit). Apply WIP kit into that workspace only |

Do **not** nest the primary live-eval workspace under the kit tree unless Task 1 fingerprint proves nested `.cursor` discovery will not contaminate results.

**Forbidden until Task 16 (captain override only):** `install-globals -Fresh` from WIP sources; apply unfinished v2 to unrelated apps.

**Proof required in Task 1:** fingerprint loaded agent/skill file paths+hashes; confirm project overrides globals for same names.

**Fallback:** label evals `isolation:unproven`; scripts + captain procedures; do not claim live v2-only behaviour.

## Metrics and context budget

- Capture protocol in `_pilot/v2_baseline/METRICS_PROTOCOL.md` (Task 1)
- Always-on project rules byte budget: **≤ baseline + 25%** without DECISIONS exception
- Prefer skills/agents/ecc on-demand for new intelligence

## Task registry (Locked 2026-11-25 — full defs in `V2_TASKS.md`)

IDs are stable. Do not renumber. Remediation gets new IDs (e.g. T3a) with explicit approval.

| ID | Title | Depends | Lead | Notes |
|----|-------|---------|------|-------|
| T1 | Baseline, eval harness, isolation proof, metrics protocol, Cursor hook capability probe | Spec lock | scrum + docs | No production behaviour change |
| T2 | Minimal Guard foundation | T1 | architect/scripts | Shared runner + schema only |
| T3 | Regression Lock + validators | T2 | flutter/scripts (fixtures) | Real 10-feature behaviours |
| T4 | Recovery + m4trix-debugger + strategy breaker | T3 | debugger + pipelines | REC-006 Must — ship debugger |
| T5 | Machine-readable Router + validators | T4 | scrum + scripts | Policy may **forward-declare** research/ui-designer agents/skills before T6/T8 exist; calculate returns names; invoke required only when agent file present or task≥introduction task |
| T6 | engineering-research skill + validators | T5 | research skill | Scale alone ≠ research gate |
| T7 | Solution Escalation Ladder | T2 | craft + verifier | Can parallel T3–T6 after T2 |
| T8 | m4trix-ui-designer + design→render→critique | T6, T7 | ui-designer | Significant UI only |
| T9 | Visual/interaction verification + validators | T8, T5 | verifier + flutter | Honest visualStatus |
| T10 | Guard integration + selective hooks | T3–T9 | scripts | Per enforcement levels above |
| T11 | Independent verify, approval fingerprints, security policy align | T10 | verifier + security | VER-003 |
| T12 | Context dedupe, model policy, token optimise | T11 | architect | Uses accumulated metrics; CTX budget |
| T13 | Integrated behavioural evaluation | T12 | verifier | Not first test of caps |
| T14 | Real-world pilots | T13 | captain-gated | Separate app auth |
| T15 | Compatibility, migration, RC | T14 | docs-deploy + bootstrap | CTX-003 if metrics unavailable |
| T16 | Activation + rollback | T15 + captain go | captain executes | Blockers must be clear |

**Routing forward declarations:** `routing-policy.json` includes rows for debugger (from T4), engineering-research (T6), ui-designer (T8). Until those files exist, Guard route validator treats missing agent file as `deferred` not fail — after introduction task, missing file is fail.

## Testing strategy

Layers: static → script → integration → simulated → live Cursor (captain-assisted prompts) → real-world pilots.

Fixtures: regression 10-feature real behaviours; recovery strategy-loop; routing omit-specialist; research trigger/skip; proportionality; UI defect gallery; guard negative matrix; install/compat.

## Migration strategy

- Develop in source; eval in isolated workspace  
- Package RC in `dist/`  
- Task 16: explicit `install-globals` + selective apply; retain 1.6.0 zip for rollback  
- sessionStart continues advisory outdated-marker only  

## Risks and limitations

| Risk | Mitigation |
|------|------------|
| Guard bypass | Document; don’t overclaim |
| Isolation contamination | Separate window + fingerprint |
| Process/token bloat | Conditional activation; context budget |
| New agents unused | Router + validators + live evals |
| Security policy drift | VER-003 single policy |
| Pilot app damage | Separate auth; branches/copies only |

## Auth / backend

N/A for kit upgrade (no product Firebase/auth change). Security review still applies to hooks/scripts handling paths and to research integrity.

## Firebase vs custom backend

N/A — kit remains Cursor/PowerShell/docs based. No new server.

## Sequence / key flows

1. Captain: Start Task N  
2. Load registry + ACTIVE_TASK; verify deps + approval  
3. Classify → calculate route → invoke  
4. Baseline / recovery / research as required  
5. Implement smallest unit  
6. Run capability checks + regression + Guard  
7. Behavioural eval (+/−)  
8. Verifier  
9. Evidence + metrics update  
10. Stop for captain accept  

## Release blockers

These **must be closed** before Task 16 activation. Captain risk-accept **cannot** convert a blocker into a pass. (Distinct from EGM eligible planning tradeoffs.)

| ID | Blocker | Clear when |
|----|---------|------------|
| RB-01 | Accepted regression in protected eval behaviours | Zero accepted protected regressions in T3/T13 suites |
| RB-02 | Uncontrolled repeated implementation loops | Recovery budget + escalation respected in T4/T13 |
| RB-03 | Unauthorized scope expansion in supported Guard/enforcement cases | Negative fixtures pass |
| RB-04 | Unauthorized architectural restructuring | Proportionality negative fixtures pass |
| RB-05 | False verification claims (tests/visual/agent invocation) | Integrity checks + live evals clean |
| RB-06 | Unresolved mandatory security blockers | VER-003 Critical/High closed or activation refused |
| RB-07 | Invalid approval-state handling | Fingerprint invalidate fixtures pass |
| RB-08 | Undocumented mandatory validation bypass | Bypass matrix complete; no silent holes for mandatory checks |
| RB-09 | Install/migration defect risking user hooks, SDLC, or globals | REL-002 fixtures pass |
| RB-10 | Breakage of previously supported v1.6.0 kit capabilities | Smoke + baseline capability matrix green |

### Acceptable limitations (may ship documented; not blockers)

- Unavailable optional tooling (emulator/MCP/browser)
- Unavailable token/cost telemetry (CTX-003)
- Documented platform hook bypasses
- Subjective design preference deferred to captain
- Pilot apps not yet authorized

Default: **T14 required before T15**. Captain may defer T14 only in writing in DECISIONS with residual risk (eligible tradeoff).

## Approval

- [x] Captain locked design on 2026-11-25 (`approve product spec for backlog`)

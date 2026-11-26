---
name: pipeline-module
description: m4tr!x mid-scale feature/module pipeline. Clarify, focused spec, one EGM Goldfish review when upfront design is needed, captain approval, implement, verify, docs.
---

# pipeline-module (m4tr!x)

## When

A coherent feature/module — bigger than a patch, smaller than a new product.

## Phases

### 1. Clarify

Ask open questions. Prefer Ask mode.

`**MODE SWITCH:** Plan — module brief — Draft module requirements and impact`

### 2–3. Elephant slice

- Short FR/NFR (REQUIREMENTS section or dated brief) with happy/fail/edge  
- DESIGN touch if architecture changes; design-system if new shared UI
- UI modules: implementers/verifier load `ecc-cherry-pick/ui-craft.md` + proportional `ui-stress.md` — not a new pipeline phase  
- Self-contained enough for a Goldfish who never saw the chat  

If the module needs meaningful upfront design: `egm.required=true`. If it is a thin slice of an already-approved design, captain may set `egm.required=false` explicitly.

### 4. EGM Goldfish (when required)

- Skill **egm-review**: **one** fresh Task (`m4trix-architect` as Goldfish)  
- More reviewers only if material unresolved risks remain  
- Resolve into `EGM_REVIEW.md`; Blocking → no implement until fixed in docs or (eligible tradeoff only) captain risk-accepted in writing  
 

`**MODE SWITCH:** Plan — captain approve module — Reply approve module <NAME> after EGM`

### 5. Tasks + implement

- **m4trix-scrum** if multi-task; else one task  
- Captain names what to build  
- Progressive context; reuse shared components; HANDOFF only if multi-agent  
- **Regression Lock** when multi-behaviour: fill `ACTIVE_TASK.regression` (inventory → baselineRev → protectedChecks); after each unit re-verify protected behaviours; invoke Guard `-Validators task-state,regression` before claiming done  
- **Recovery:** on repeated/uncertain failures activate skill **pipeline-recovery** (not a fourth scale); record `ACTIVE_TASK.recovery`; invoke **m4trix-debugger** for complex diagnosis; Guard `-Validators …,recovery` before done. Routine understood bugs skip.  
- **Routing:** classify full attributes → `Evaluate-Routing.ps1` → record `ACTIVE_TASK.routing` (invoked + evidence type task|subagent|artifact|limitation) → Guard `-Validators …,routing` before done. Parent prose ≠ invocation. Forward-declared agents may be `deferred` until their introduction task.  
- **Research:** when unfamiliar/complex/integration/security/perf/tradeoff or `researchNeeded=true`, invoke skill **engineering-research** (not scale alone); persist `ACTIVE_TASK.research` findings+sources with alternatives; Guard `-Validators …,research` before done. Routine familiar work may skip.  
- **Solution Escalation Ladder (`04-code-craft`):** on significant decisions (architecture/API reshape, new abstraction, scale promotion) apply localized→extend→extract→restructure; record a short justification in evidence/notes; Level-4 needs captain approval. Do not inflate a patch into a module without captain acknowledgment.  
- **Significant UI (`uiInvolvement=significant`):** invoke **m4trix-ui-designer** + **m4trix-design-system**; bounded journey→direction→reuse→implement→render→critique→refine→honest `verificationEvidence.visualStatus`. Designer owns critique direction; implementer owns framework code; verifier owns pass/fail + visual honesty. Design-doc-only done fails. Guard `-Validators …,visual` before done. Load `ecc-cherry-pick/ui-craft.md` + proportional `ui-stress.md`. Trivial copy/colour is not significant UI — use patch pipeline.  
- **Completion gate (mandatory before done/accepted):** run `bootstrap/guard/Invoke-CompletionGate.ps1 -TaskPath docs/sdlc/ACTIVE_TASK.json`. Always includes `task-state` + `completion` + `approval` (fingerprints). Stamp fingerprints via `Get-ApprovalFingerprints.ps1` before done. Refuse `status`/`phase` `done|accepted` while Guard `ok=false`. Process gate only — not unbypassable security. See `docs/sdlc/GUARD_BYPASS_MATRIX.md`.  
 

## Hard rules

- Production-ready module  
- Do not silently expand from patch; upgrade scale only with captain acknowledgment (anti-promotion)  
- EGM skip only when captain confirms no meaningful upfront design  
- Never claim green by deleting/skipping/weakening tests; protected fail rejects the unit  
- Do not reset recovery attemptCount on new chat; rename-only retries are forbidden  
- Significant UI must not claim done without designer path + rendered critique (or honest limitation) and honest `visualStatus` (static-only ≠ `visually_verified`)  
- Never claim done/accepted when `Invoke-CompletionGate` exits non-zero / `ok=false`  


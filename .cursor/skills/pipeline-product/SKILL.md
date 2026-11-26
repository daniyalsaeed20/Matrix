---
name: pipeline-product
description: m4tr!x full-product Agile SDLC pipeline for greenfield apps or large epics. PRD, FR/NFR, design, design system, EGM Goldfish review, sequenced backlog, then stop for captain to authorize each module build.
---

# pipeline-product (m4tr!x)

## When

New application or very large epic. Not for small UI tweaks.

## Phases (stop at each gate)

### 0. Bootstrap check

If `docs/sdlc/.m4trix-kit.json` missing, ask the captain before applying; then run **bootstrap-org** (dry-run first when docs already exist).

### 1–4. Elephant design (existing agents)

1. **m4trix-product** → lock `PRD.md`  
2. **m4trix-requirements** → `REQUIREMENTS.md` (happy/fail/edge)  
3. **m4trix-architect** → `DESIGN.md`  
4. **m4trix-design-system** when UI — `DESIGN_SYSTEM.md`  

Specs must stand alone without the chat. Set `ACTIVE_TASK.egm.required=true`, `egm.status=pending`.

`**MODE SWITCH:** Plan — EGM Goldfish — Use skill egm-review on the locked product docs`

### 5. EGM Goldfish (required)

- Run **egm-review**: fresh Task Goldfish (`m4trix-architect`; optional `m4trix-security` if material risk).
- Record findings in `EGM_REVIEW.md`; Elephant resolves; Blocking open → `egm.blockingOpen=true`, no implement. Missing requirements / security defects must be fixed in docs; only eligible implementation tradeoffs may be captain risk-accepted in writing (see egm-review).
- Present summary to captain (what / decisions / findings / risks / ready?).

`**MODE SWITCH:** Plan — captain approve spec — Reply approve product spec for backlog after EGM`

### 6. Backlog sequencing

Only after captain approval of the reviewed spec:

- **m4trix-scrum** → ordered tasks; `BACKLOG.md` for derivatives  
- **STOP** — do not implement the whole app  

`**MODE SWITCH:** Agent — build first module — Build module <NAME> only`

### 7. Per-module loop (captain-driven)

Implementers → optional security → verifier → docs. Track `ACTIVE_TASK`. Deploy doc late when asked.

If a module hits repeated/uncertain failures: skill **pipeline-recovery** + **m4trix-debugger** (product-critical budget 3 then escalate). Not a fourth scale.

**Routing:** at product and each module start, classify full attributes → `Evaluate-Routing.ps1` → invoke mandatory specialists with evidence → Guard `-Validators …,routing` before done claims. No markdown-only route.

**Research:** unfamiliar stack/architecture choices → skill **engineering-research** + `ACTIVE_TASK.research`; Guard `-Validators …,research` when `researchNeeded`. Scale alone ≠ research gate.

## Hard rules

- No one-shot full-app implementation  
- EGM required; review ≠ captain approval  
- Production bar every module; emit MODE SWITCH at every gate  
- Solution Escalation Ladder (`04-code-craft`): no silent patch→module/product promotion; significant architecture needs evidence + captain approval (anti-promotion)  
- **Significant UI:** product and UI modules use **m4trix-ui-designer** (design→render→critique→refine→honest `visualStatus`) with design-system token ownership; design-doc-only done fails; Guard `-Validators …,visual` before done; patches skip designer and full visual bar  
- **Completion gate:** before any module/product `done|accepted` claim, stamp fingerprints then run `Invoke-CompletionGate.ps1` (always includes `approval`); refuse while `ok=false`. Process gate only — see `docs/sdlc/GUARD_BYPASS_MATRIX.md`  

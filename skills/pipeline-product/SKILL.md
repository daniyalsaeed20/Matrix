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
- Record findings in `EGM_REVIEW.md`; Elephant resolves; Blocking open → `egm.blockingOpen=true`, no implement.
- Present summary to captain (what / decisions / findings / risks / ready?).

`**MODE SWITCH:** Plan — captain approve spec — Reply approve product spec for backlog after EGM`

### 6. Backlog sequencing

Only after captain approval of the reviewed spec:

- **m4trix-scrum** → ordered tasks; `BACKLOG.md` for derivatives  
- **STOP** — do not implement the whole app  

`**MODE SWITCH:** Agent — build first module — Build module <NAME> only`

### 7. Per-module loop (captain-driven)

Implementers → optional security → verifier → docs. Track `ACTIVE_TASK`. Deploy doc late when asked.

## Hard rules

- No one-shot full-app implementation  
- EGM required; review ≠ captain approval  
- Production bar every module; emit MODE SWITCH at every gate  

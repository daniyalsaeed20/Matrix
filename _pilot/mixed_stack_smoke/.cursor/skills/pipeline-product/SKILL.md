---
name: pipeline-product
description: m4tr!x full-product Agile SDLC pipeline for greenfield apps or large epics. PRD, FR/NFR, design, design system, sequenced backlog, then stop for captain to authorize each module build. Use for large requirements like a full multi-user finance app.
---

# pipeline-product (m4tr!x)

## When

New application or very large epic. Not for small UI tweaks.

## Phases (stop at each gate)

### 0. Bootstrap check

If `docs/sdlc/.m4trix-kit.json` missing, ask the captain before applying; then run **bootstrap-org** (dry-run first when docs already exist).

### 1. Discover / PRD

- Delegate **m4trix-product**
- Q&A until PRD locked in `docs/sdlc/PRD.md`
- Prefer Ask/Plan modes for this phase

`**MODE SWITCH:** Plan — requirements — Break locked PRD into FR/NFR with m4trix-requirements`

### 2. Requirements

- **m4trix-requirements** → `REQUIREMENTS.md` with happy/fail/edge
- Captain locks

`**MODE SWITCH:** Plan — design — Produce architecture with m4trix-architect`

### 3. Design + feasibility

- **m4trix-architect** → `DESIGN.md` (Firebase-first proposals)
- Captain approves contested choices

`**MODE SWITCH:** Plan — design system — Create UI design system with m4trix-design-system`

### 4. Design system (before feature UI)

- **m4trix-design-system** → `DESIGN_SYSTEM.md` then theme code when Agent authorized

`**MODE SWITCH:** Plan — backlog — Sequence modules with m4trix-scrum`

### 5. Backlog sequencing

- **m4trix-scrum** creates ordered tasks/AC; maintain `BACKLOG.md` for derivatives
- **STOP** — do not implement the whole app

`**MODE SWITCH:** Agent — build first module — Build module <NAME> only`

### 6. Per-module loop (captain-driven)

For each named module:

1. Implementers (flutter/firebase/node/python as relevant) — create shared visual primitives on first relevant approved screen; reuse thereafter
2. Track `ACTIVE_TASK.json`; keep slices small
3. **m4trix-security** when sensitive
4. **m4trix-verifier** (AC + code craft)
5. **m4trix-docs-deploy** (handoff + backlog)
6. Deploy doc only late when captain asks

### 7. Maintenance

Captain pulls from `BACKLOG.md` → restart appropriate pipeline at matching scale.

## Hard rules

- No one-shot full-app implementation
- Production bar every module
- Emit MODE SWITCH at every gate

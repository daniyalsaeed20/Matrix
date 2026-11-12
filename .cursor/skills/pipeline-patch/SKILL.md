---
name: pipeline-patch
description: m4tr!x small-change pipeline for UI tweaks and focused bugfixes. Short impact note, one task with AC, implement, verify, update docs if needed. Example - replace bottom sheet with animated app-bar switch. Skip heavy PRD.
---

# pipeline-patch (m4tr!x)

## When

Small, localized change. If scope grows past one focused task, upgrade to **pipeline-module**.

## Phases

### 1. Clarify (only if needed)

If unclear, ask. Otherwise proceed.

### 2. Change brief (short)

Write a brief in chat or append a short note under `docs/sdlc/` (optional file `PATCH_NOTES.md` only if captain wants persistence):

- What changes
- What does not
- AC: happy / fail / edge
- Files likely touched

`**MODE SWITCH:** Agent — implement patch — Implement the approved patch per AC; no scope creep`

### 3. Implement

- Prefer single agent; no multi-agent swarm
- Surgical: only files the patch needs; no drive-by cleanup
- Inspect impacted files; smallest clear change; reuse theme/components
- No new services, PRDs, or abstraction ceremony for a label/copy fix
- Brief handoff: what changed / reused / verified

### 4. Verify

- Focused check or lightweight **m4trix-verifier**; report what actually ran
- Update docs only if user-facing behavior or public API changed
- Derived ideas → `BACKLOG.md` (mention unrelated debt; do not fix it here)

`**MODE SWITCH:** Ask — next item — Captain: next patch, module, or backlog ID`

## Hard rules

- **EGM / Goldfish: skip** — no planning review swarm for ordinary patches
- If investigation reveals material architecture/product decisions → propose upgrade to **pipeline-module** (captain must acknowledge); never silent scope expand
- Do not open full PRD/design-system ceremony
- Still production-quality for the touched surface
- Emit MODE SWITCH before implementation if currently in Ask/Plan
- Set `ACTIVE_TASK.egm.required=false`, `egm.status=skipped`

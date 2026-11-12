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
- Inspect impacted files; smallest correct change; reuse theme/components
- No new services, PRDs, or abstraction ceremony for a label/copy fix
- Reuse theme/design system; no new visual language unless patch is theme itself
- Brief handoff: what changed / reused / verified

### 4. Verify

- **m4trix-verifier** (lightweight)
- Update docs only if user-facing behavior or public API changed
- Derived ideas → `BACKLOG.md`

`**MODE SWITCH:** Ask — next item — Captain: next patch, module, or backlog ID`

## Hard rules

- Do not open full PRD/design-system ceremony
- Still production-quality for the touched surface
- Emit MODE SWITCH before implementation if currently in Ask/Plan

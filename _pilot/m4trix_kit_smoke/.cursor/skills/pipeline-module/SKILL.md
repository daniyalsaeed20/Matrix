---
name: pipeline-module
description: m4tr!x mid-scale feature/module pipeline. Lighter than full product but still clarify, requirements/design slice, tasks with AC, design-system check, implement on captain command, verify, docs. Example - in-app review system after action A.
---

# pipeline-module (m4tr!x)

## When

A coherent feature/module — bigger than a patch, smaller than a new product.

## Phases

### 1. Clarify

Ask open questions (triggers, permissions, offline, notifications, etc.). Prefer Ask mode.

`**MODE SWITCH:** Plan — module brief — Draft module requirements and impact`

### 2. Module requirements + impact

- Short FR/NFR section (can append to `REQUIREMENTS.md` or a dated section)
- Impact on existing screens/data
- Happy / fail / edge

### 3. Design slice

- Touch `DESIGN.md` if architecture changes
- If new UI controls needed, involve **m4trix-design-system** for tokens/components — do not invent one-off styles

### 4. Tasks

- **m4trix-scrum**: 2–N sequenced tasks with AC if too big for one go; else one task
- STOP for captain: which task to build

`**MODE SWITCH:** Agent — build module slice — Build task <ID> only`

### 5. Implement → secure (if needed) → verify → docs

- Check existing shared components first; add approved shared primitives without a separate epic
- Track slice in `ACTIVE_TASK.json`
- Implementers → optional **m4trix-security** → **m4trix-verifier** (includes code-craft) → **m4trix-docs-deploy**
- Brief handoff: what changed / reused or extracted / why any new layer / verified
- Park extras in `BACKLOG.md`

## Hard rules

- Production-ready module, not a demo stub
- Scale ceremony down vs product, but never skip clarify or AC

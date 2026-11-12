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
- Self-contained enough for a Goldfish who never saw the chat  

If the module needs meaningful upfront design: `egm.required=true`. If it is a thin slice of an already-approved design, captain may set `egm.required=false` explicitly.

### 4. EGM Goldfish (when required)

- Skill **egm-review**: **one** fresh Task (`m4trix-architect` as Goldfish)  
- More reviewers only if material unresolved risks remain  
- Resolve into `EGM_REVIEW.md`; Blocking → no implement  

`**MODE SWITCH:** Plan — captain approve module — Reply approve module <NAME> after EGM`

### 5. Tasks + implement

- **m4trix-scrum** if multi-task; else one task  
- Captain names what to build  
- Progressive context; reuse shared components; HANDOFF only if multi-agent  

## Hard rules

- Production-ready module  
- Do not silently expand from patch; upgrade scale only with captain acknowledgment  
- EGM skip only when captain confirms no meaningful upfront design  

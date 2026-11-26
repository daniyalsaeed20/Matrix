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
- If the patch touches a multi-behaviour area: still protect neighbors (spot-check); escalate to module ceremony when inventory/baseline is required
- If the same defect repeats or root cause is uncertain: activate **pipeline-recovery** (budgets: patch 2); do not spin rename-only retries. Routine understood bugs skip recovery ceremony.
- **Routing (minimal):** set patch-minimal attrs (`scale`, `taskType`, `stacks`, `uiInvolvement`, `securityRisk`). Trivial patch → minimal route via `Evaluate-Routing.ps1`. Non-trivial patch (uncertainty med/high, regressionRisk, securityRisk, recoveryActive, unfamiliar tech, recurring defect) → full attrs + mandatory specialists. Record `ACTIVE_TASK.routing`; Guard `-Validators …,routing` when specialists were required.
- **Research:** routine copy/token patches skip. Unfamiliar tech or recurring defect → set `researchNeeded=true`, invoke **engineering-research**, persist findings; Guard `-Validators …,research`.
- **Solution Escalation Ladder (`04-code-craft`):** prefer localized fix; do not restructure or invent abstractions for a patch. Ordinary copy/token patches need no ladder writeup.

### 4. Verify

- Focused check or lightweight **m4trix-verifier**; report what actually ran
- Before `done|accepted`: stamp approval fingerprints (`Get-ApprovalFingerprints.ps1`); run `bootstrap/guard/Invoke-CompletionGate.ps1 -TaskPath docs/sdlc/ACTIVE_TASK.json` (includes `approval`); refuse while `ok=false` (process gate — not unbypassable)
- Update docs only if user-facing behavior or public API changed
- Derived ideas → `BACKLOG.md` (mention unrelated debt; do not fix it here)

`**MODE SWITCH:** Ask — next item — Captain: next patch, module, or backlog ID`

## Hard rules

- **EGM / Goldfish: skip** — no planning review swarm for ordinary patches
- If investigation reveals material architecture/product decisions → propose upgrade to **pipeline-module** (captain must acknowledge); never silent scope expand / silent patch→module promotion (SOL anti-promotion)
- Do not open full PRD/design-system ceremony
- Do not load full `ui-craft` / `ui-stress` reviews for tiny copy/token patches — spot-check the touched surface only
- Do **not** invoke **m4trix-ui-designer** for ordinary copy/colour/token patches — designer path is for significant UI only
- Skip full visual bar (`verificationEvidence` / Guard `visual`) for ordinary copy/colour/token patches — significant UI only
- Still production-quality for the touched surface
- Emit MODE SWITCH before implementation if currently in Ask/Plan
- Set `ACTIVE_TASK.egm.required=false`, `egm.status=skipped`

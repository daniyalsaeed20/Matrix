---
name: egm-review
description: Elephant-Goldfish planning review for product/module specs. Spawns a fresh isolated Cursor Task (Goldfish) against self-contained SDLC docs. Skip for patches. Use after PRD/REQUIREMENTS/DESIGN (or module brief) are drafted and before captain implementation approval.
---

# egm-review (m4tr!x)

Inspired by [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) (Apache-2.0). **Do not** install that plugin wholesale. Detail: `ecc-cherry-pick/egm.md`.

## When

| Scale | EGM |
|-------|-----|
| **product** | Required after Elephant drafts PRD + REQUIREMENTS + DESIGN (and DESIGN_SYSTEM plan if UI). Optional second Goldfish (`m4trix-security`) only if auth/PII/payments risk is material. |
| **module** | Required when the module needs meaningful upfront design. **One** Goldfish (`m4trix-architect` in Goldfish mode). |
| **patch** | **Never.** |

Upgrade patch→module only with captain acknowledgment when investigation reveals material architecture/product decisions.

## Elephant (existing agents)

`m4trix-product` / `m4trix-requirements` / `m4trix-architect` (+ design-system when UI):

- Produce specs in existing `docs/sdlc/*` — no parallel EGM-only PRD/DESIGN.
- Spec must be understandable **without** the planning chat.
- Capture assumptions, AC, fail/edge cases, reuse of existing components, trade-offs in `DECISIONS.md`.
- Minimize speculative complexity (`04-code-craft`).

## Goldfish (fresh Task only)

**Isolation (verified on Cursor):** use the **Task** tool with a **new** subagent (`resume` omitted). Task docs: new invocations do **not** inherit the parent conversation. Pass only:

1. Absolute paths to the spec files (PRD/REQUIREMENTS/DESIGN or module section)
2. Explicitly referenced code paths (if any)
3. This Goldfish checklist

If Task / fresh subagents are unavailable → **stop EGM**, report limitation, do **not** fake independence in the same chat.

**Goldfish role:** spawn `subagent_type: m4trix-architect` (and optionally `m4trix-security` on product) with prompt that begins:

> You are a **Goldfish** reviewer. You have NO prior planning chat. Read ONLY the listed files. Do not modify production code. Do not invent product scope. Classify findings: Blocking | Major | Minor | Observation. Check: comprehension, contradictions, missing happy/fail/edge, architecture/security risks, existing-component reuse, unjustified complexity, implementation readiness. Return a concise findings list with evidence (file/section). Do not approve implementation.

## Findings → Elephant → Captain

1. Elephant accepts, contests (with evidence), or escalates.
2. Record material outcomes in `docs/sdlc/EGM_REVIEW.md`.
3. Unresolved **Blocking** (architecture/security/spec) → set `ACTIVE_TASK` blocked; **no implementation**.
4. Captain still must explicitly approve implementation. Goldfish complete ≠ approval.
5. Re-review only after substantive spec changes.

## ACTIVE_TASK fields

Set `egm.required`, `egm.status` (`skipped` | `pending` | `in_review` | `findings` | `resolved` | `blocked`), `egm.reviewPaths`, `egm.blockingOpen`.

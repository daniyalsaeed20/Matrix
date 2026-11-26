---
name: engineering-research
description: Conditional m4tr!x research for unfamiliar/complex technical choices. Activation by complexity/unfamiliarity — not scale alone. Persist findings + sources; alternatives before commit. Skip routine copy patches.
---

# engineering-research (m4tr!x)

## When (activate)

Invoke this skill when any of:

- Unfamiliar tech, API, platform, or library relative to the project stack
- Non-trivial integration, security, performance, or cross-cutting tradeoff
- `ACTIVE_TASK.routing.attributes.researchNeeded=true` (or calculate requires this skill)
- Recurring or unfamiliar patch defect (routine copy/token patch that keeps failing)
- Captain or recovery flow asks for established approaches before a custom solution

**Scale alone does not trigger research.** A large familiar module may skip; a small unfamiliar patch may require it.

## When (skip)

- Routine copy, label, token, or colour patch with no unfamiliarity
- Well-understood localized fix already matching project patterns
- Re-applying an already-researched decision recorded in `DECISIONS.md` / prior findings

## Research order (RSH-002)

Follow in order; record what was checked in `orderFollowed[]`:

1. **project** — existing code, helpers, design system, DECISIONS
2. **deps** — locked versions in pubspec / package.json / requirements
3. **officialDocs** — framework/platform docs for the pinned version
4. **packages** — maintained packages compatible with project versions
5. **maintainerIssues** — known bugs/limits in issue trackers
6. **establishedRefs** — architecture notes, RFCs, vendor guides
7. **community** — last resort; weigh recency and applicability

Do **not** jump to a custom solution without project/native/deps checks.

## Persist (`ACTIVE_TASK.research`)

```json
{
  "required": true,
  "findings": [
    {
      "question": "...",
      "orderFollowed": ["project", "deps", "officialDocs"],
      "alternatives": [
        { "name": "...", "kind": "native|package|custom|other", "notes": "..." }
      ],
      "recommendation": "...",
      "rationale": "...",
      "versionCompat": "..."
    }
  ],
  "sources": [
    {
      "title": "...",
      "urlOrPath": "path or URL actually consulted",
      "kind": "project|deps|official|package|issue|ref|community",
      "verified": true
    }
  ],
  "limitations": [],
  "poc": { "required": false, "status": "skipped|planned|done", "notes": null }
}
```

Rules:

- At least **one alternative** per finding (no rubber-stamp of a pre-chosen custom path)
- Recommendation + rationale required; note version compatibility
- Sources must be real paths/URLs you consulted — **never invent** sources
- Prefer a small isolated PoC when an API/behaviour claim is uncertain (RSH-004)
- If web/docs unavailable: add an explicit limitation (e.g. `web unavailable`) and use local project/deps evidence, or **stop** and ask the captain — do not fabricate remote citations

## Integrity

Guard `research` validator fails when research is required and:

- `findings` or `sources` empty
- finding lacks alternatives / recommendation / rationale
- source `urlOrPath` empty or placeholder (`example.com`, `TODO`, `fabricated`, …)

## Guard

Before claiming done when research was required:

```text
Invoke-M4trixGuard.ps1 -Validators task-state,routing,research
```

Also include `recovery` / `regression` when those capabilities are active.

## Pipelines

Thin pointers live in pipeline-module / product / patch / recovery. Parent prose “I researched” without this skill + persisted findings is **not** evidence.

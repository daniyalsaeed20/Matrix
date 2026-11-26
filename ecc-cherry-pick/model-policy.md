# Model / reasoning policy (reference)

On-demand. Always-on one-liners: `constitution/project-rules/03-token-discipline.mdc` and `constitution/USER_RULES.md` (Tokens / models).  
**Authoritative decision log:** `docs/sdlc/DECISIONS.md` → Model policy section.

## Defaults

| Role | Default | Override |
|------|---------|----------|
| Parent / captain chat | Prefer **Auto** (Cost when available) | Captain explicit pin in writing |
| Subagents / fresh Task | `model: inherit` | Captain explicit order only |
| Forbidden | Silent frontier / expensive pins on subagents | — |

## Rules

1. Do **not** pin expensive models on subagents unless the captain orders it.
2. Prefer **Auto** for parent work; optimize **cost per correctly verified task**, not shorter answers that skip verification.
3. This file is **not** an always-on rule. Do not copy the full table into `00`–`05`.
4. Unavailable token/cost telemetry stays `unavailable` (CTX-003) — never invent improvement %.

## Spot-check

All `agents/m4trix-*.md` frontmatter should declare `model: inherit` unless the captain has approved a documented exception in DECISIONS.

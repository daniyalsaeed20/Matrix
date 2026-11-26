# T12 — Instruction ownership audit

**Measured at start of T12 implement:** always-on core (00–05) live bytes recorded by `Measure-AlwaysOnBytes.ps1` in evidence.  
**CTX-001 numerator:** project rules `00`–`05` only. **USER_RULES is not in the numerator.**

## Authoritative locations

| Topic | Authoritative | Conditional / paste |
|-------|---------------|---------------------|
| Org kit / bootstrap | `constitution/project-rules/00-m4trix-os.mdc` | `constitution/USER_RULES.md` (account paste) |
| Production bar | `01-production-bar.mdc` | USER_RULES summary |
| Modes | `02-mode-switching.mdc` | USER_RULES one-liner |
| Token / progressive load | `03-token-discipline.mdc` | `docs/sdlc/ecc-reference/context-engineering.md` |
| Craft / ladder | `04-code-craft.mdc` | verifier + pipelines |
| Delivery voice | `05-delivery-voice.mdc` | USER_RULES commit rules |
| Patch ceremony skips | `skills/pipeline-patch/SKILL.md` | not always-on |
| Guard / fingerprints / CompletionGate | `bootstrap/guard/**` | never always-on |
| Model policy | `docs/sdlc/DECISIONS.md` + `docs/sdlc/ecc-reference/model-policy.md` | USER_RULES / 03 one-liners |
| Metrics protocol | `_pilot/v2_baseline/METRICS_PROTOCOL.md` | eval evidence copies |
| Always-on byte baseline | `_pilot/v2_baseline/ALWAYS_ON_BYTES.json` (frozen T1) | live measure via `bootstrap/Measure-AlwaysOnBytes.ps1` |

## Duplication findings

| Area | Finding | Action |
|------|---------|--------|
| USER_RULES ↔ 00–05 | Intentional overlap: account paste must work without applied project rules | Keep USER_RULES; add authoritative-location pointer; light trim of Guard-path detail |
| 04 Regression Lock | Contained Guard validator path (always-on bloat risk) | Slim to role pointer; path stays under `bootstrap/guard` |
| 01 visualStatus | Longer than T1 baseline; required for VIS production bar | Keep (under ceiling); not Guard prose |
| Agents `model:` | All `m4trix-*` agents use `model: inherit` | No outlier fix required |
| Patch EGM/research/designer | Already in `pipeline-patch` hard rules | Eval asserts presence; do not copy into always-on |
| v2 Guard / fingerprints | Correctly in bootstrap + agents, not new always-on rule files | Preserve |

## Budget

| Metric | Value |
|--------|-------|
| T1 baseline `alwaysOnCoreBytes` | 11043 |
| Ceiling (+25%, no DECISIONS exception) | 13804 |
| Fail condition | Live core > 13804 without written DECISIONS exception; or Guard prose added to always-on |

## Non-goals

- New always-on rule files for v2 features
- Gutting USER_RULES
- Fabricated token-cost improvement percentages

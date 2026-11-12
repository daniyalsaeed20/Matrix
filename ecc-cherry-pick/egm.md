# Elephant-Goldfish Model (reference)

On-demand. Activation lives in `skills/egm-review` + product/module pipelines.

**Upstream:** [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) (Apache License 2.0).  
**m4tr!x policy:** selective principles only — no plugin install, no second SDLC, no extra permanent agents.

## Mapping

| EGM | m4tr!x |
|-----|--------|
| Elephant | product + requirements + architect (+ design-system) drafting existing `docs/sdlc` |
| Goldfish | Fresh Cursor **Task** subagent (`m4trix-architect`, optional `m4trix-security`) with listed files only |
| Human | Captain — sole scope/implementation approval |

## Isolation note

Cursor Task without `resume` starts without parent chat history. If that capability is missing, stop and report — do not simulate Goldfish in-thread.

## Blocking vs risk acceptance

Unresolved **Blocking** keeps `egm.blockingOpen=true` and blocks implementation. Missing requirements and unresolved security defects must be fixed in Elephant docs — not risk-accepted. Captain may accept **implementation/architecture tradeoff** risks only, in writing (`EGM_REVIEW.md` + `DECISIONS.md`). Risk acceptance ≠ implementation approval; captain go-ahead remains mandatory.

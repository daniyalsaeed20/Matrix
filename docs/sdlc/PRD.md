# PRD — M4TR!X v2.0 Engineering Intelligence & Reliability

**Status:** Locked  
**Owner:** m4tr!x captain  
**Scale:** product (kit upgrade epic)  
**Last updated:** 2026-11-25  
**Baseline:** m4tr!x v1.6.0  
**Target:** m4tr!x v2.0.0

## Problem

m4tr!x v1.6.0 provides a coherent captain-owned delivery org inside Cursor, but field use on real applications shows roughly 60–70% of expected effectiveness. Dominant failure modes are: regressions of previously working behaviour during multi-feature repair; speculative loops and hallucinated root causes; insufficient technical research; overengineering; basic/unpolished UI with weak visual verification; inconsistent specialist selection; and controls that are almost entirely model-voluntary. Token “savings” that cause repeated failed attempts increase total cost. The upgrade must raise reliability and verified delivery rate without rewriting the kit or bloating process.

## Audience

- Captain (primary operator of m4tr!x across multiple apps)
- Kit maintainers developing m4tr!x itself (dogfood with runtime≠source separation)
- Future applied workspaces after explicit v2 activation

## Goals

1. Protect previously verified behaviour while repairing failures (cumulative progress).
2. Diagnose complex defects with evidence, persistent investigation memory, and bounded retries that force strategy change.
3. Research unfamiliar/complex technical choices against project versions before committing.
4. Select proportionate solutions via an enforceable Solution Escalation Ladder.
5. Route work to the correct specialists with inspectable, partially enforceable contracts.
6. Raise UI visual and interaction quality with design→render→critique→refine for significant UI.
7. Introduce deterministic Guard validation early and extend it per capability.
8. Measure total cost of verified completion from baseline through release.
9. Preserve captain gates, EGM independence, patch lightness, install safety, and third-party config.
10. Activate v2 only after integrated eval + controlled real-world pilots + explicit captain authorization.

## Non-goals

- Rewriting product/module/patch pipelines or replacing captain ownership
- Adding an LLM routing agent or many new permanent agents (max Debugger + UI/UX Designer)
- Always-on research, designer, or recovery ceremony for routine patches
- Claiming unbypassable security boundaries where Cursor cannot provide them
- Auto-installing unfinished v2 globally or into unrelated apps
- Databases/vector stores for memory; orchestration servers; speculative infra
- Accessing captain’s production pilot apps without separate written authorization
- Universal defect-free AI coding guarantees

## Key features

| ID | Feature | Priority | Notes |
|----|---------|----------|-------|
| F1 | Regression Lock | Must | Behaviour inventory, baseline, mid-unit protected checks, test integrity |
| F2 | Recovery workflow + Debugger specialist | Must | Investigation-first; strategy change; persistent budget; debugger ships (REC-006) |
| F3 | Minimal Guard early + per-capability validators | Must | Task 2 foundation; Task 10 completion/hooks |
| F4 | Machine-readable Router | Must | Classify → calculate → invoke → validate; no LLM router |
| F5 | engineering-research skill | Must | Conditional; alternatives before commit |
| F6 | Solution Escalation Ladder | Must | Influences selection + verification |
| F7 | UI/UX Designer + visual verification | Must | Quality of rendered UI, not docs alone |
| F8 | Measurement + context budget | Must | From Task 1; optimisation uses evidence |
| F9 | Independent verification + approval integrity | Must | Align security with EGM |
| F10 | Isolated eval + real-world pilots | Must | Before RC/activation |
| F11 | Compatibility / RC / activation | Must | Explicit captain cutover + rollback |

## Success metrics

Primary: **total cost and effort to complete a correctly implemented and verified task** (vs v1.6.0 baseline).

Secondary (measure when available; mark `unavailable` otherwise): tokens in/out/cached; model cost; wall time; specialist invocations; human interventions; implementation attempts; failed approaches; regression count; protected behaviours preserved; AC satisfied; unauthorized file changes; always-on instruction bytes; verified completion rate.

Release targets (evaluation targets, not universal guarantees): zero accepted protected regressions in eval suite; zero unauthorized restructures/scope expansions in supported enforcement cases; zero fabricated verification; zero completions with unresolved mandatory blockers; no repetition of rejected approaches without new evidence; correct routing on fixtures; research when required; significant UI visually verified or explicitly unmarked; retry/escalation respected; v1.6.0 supported capabilities preserved; improved verified completion and fewer debug loops where measured.

## Assumptions

- Cursor continues to support project-over-user agent/skill precedence and documented hooks.
- Captain will run live behavioural procedures and authorize real-world pilots separately.
- Canonical kit source remains `E:\development\Matrix` (self-locating); globals stay on 1.6.0 until Task 16.
- Existing `_pilot/` fixtures remain the default automated eval surface.

## Open questions

1. Exact attempt-budget defaults by scale (proposed in DESIGN; captain may tune at Task 4).
2. Which two apps and which branches/copies for Task 14 (captain names later).
3. Whether any always-on rule growth beyond +25% baseline is ever acceptable (default: no without DECISIONS exception).

## Risks / feasibility notes

- Hooks and validators are bypassable via non-shell edits and fail-open defaults — must document honestly.
- Nested `.cursor` discovery in monorepos can contaminate isolation — Task 1 must verify or fall back.
- New agents may still be under-invoked — Router + validators + live evals required.
- Process bloat risk — patch path must remain cheap; intelligence is conditional.
- Dual-tree kit dogfood (source + applied `.cursor`) — edit canonical sources only until activation.

## Approval

- [x] Captain locked this PRD on 2026-11-25 (`approve product spec for backlog`)

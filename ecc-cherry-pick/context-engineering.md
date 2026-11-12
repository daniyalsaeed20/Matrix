# Context engineering (reference)

On-demand. Always-on summary: `constitution/project-rules/03-token-discipline.mdc`.

**Upstream:** [jasontang-ai/Context-Engineering](https://github.com/jasontang-ai/Context-Engineering) (MIT; Copyright davidkimai).  
**m4tr!x policy:** do **not** install that course/repo wholesale. No vector DB / memory server unless captain later approves a real need.

## Practical ideas adopted

| Idea | m4tr!x mapping |
|------|----------------|
| Minimal sufficient context | Progressive load + soft scale budgets |
| Priority: query → system → recent memory | Captain request + ACTIVE_TASK + targeted files |
| Prune / drop oldest noise | Summarize tool output; new chat per phase; compact HANDOFF |
| Task memory without duplication | Enrich `ACTIVE_TASK.json`; durable docs stay PRD/DESIGN/DECISIONS |
| Evaluate relevance & conciseness | `_pilot/context_eval/README.md` + smoke presence checks |

## Assembly order (mental model)

1. System rules already always-on (slim)  
2. Active task memory (`ACTIVE_TASK.json`)  
3. Retrieved code/docs slices  
4. Current captain message  

Delete ruthlessly; expand only for correctness/security/reuse/verification.

---
name: pipeline-recovery
description: m4tr!x investigation-first recovery workflow (not a fourth scale). Activates on defined triggers; routine understood bugs skip. Persistent ACTIVE_TASK.recovery, strategy-change circuit breaker, attempt budgets, m4trix-debugger for complex diagnosis.
---

# pipeline-recovery (m4tr!x)

## When (triggers)

Activate this skill when any of:

- Protected regression after a change
- Repeated defect / same failure after a fix attempt
- Multi-behaviour fails with uncertain root cause
- Evidence contradicts current assumptions
- Large blast radius suspected
- Same approach failed before
- Scale under-classified (patch that is really module recovery)
- Captain requests debug / recovery

## Non-triggers (skip ceremony)

- Well-understood localized bug with a clear fix
- Ordinary feature build on an approved task
- Trivial copy/token patch

Cursor **Debug** mode still exists for IDE debugging; this skill is the org recovery workflow.

## Budgets (defaults)

| Recovery scale | attemptBudget |
|----------------|---------------|
| patch | 2 |
| module | 3 |
| product-critical | 3 then escalate |

Captain may override via `ACTIVE_TASK.recovery.attemptBudget`.

## Meaningful attempt

A **meaningful attempt** is an implementation or production-behaviour change under the current hypothesis. **Not:** renames, new subtask IDs, re-reading files, restating the same patch. Rename-only “new attempts” are blocked by Guard.

## Flow

1. Reproduce → expected vs actual  
2. Baseline / checkpoint (preserve dirty user files; no destructive wipe)  
3. Evidence → facts vs assumptions  
4. Hypotheses → invoke **m4trix-debugger** for complex diagnosis (readonly prefer)  
5. Smallest experiment → implementer applies approved fix (debugger does **not** own feature impl); follow Solution Escalation Ladder — prefer localized fix; no unjustified restructure mid-recovery  
6. Targeted checks + protected behaviours (Regression Lock when multi-behaviour)  
7. Record attempt in `ACTIVE_TASK.recovery` (attemptCount, predicted/actual, strategyDelta, rejectedApproaches)  
8. Accept, strategy-change, or escalate  

After **1 fail:** reconsider hypothesis.  
After **2 fails:** require independent diagnostic or new evidence path.  
After **budget exhausted:** stop speculative impl; escalate to captain with concise report. Optional captain-controlled model bump never substitutes for investigation.

## Persistence

Keep `ACTIVE_TASK.recovery` cumulative across chats/handoffs/specialists (`attempts[]` + `rejectedApproaches[]` + `attemptCount`). Do **not** reset the budget on a new chat. Optional `docs/sdlc/RECOVERY.md` only if JSON is unreadably large — must not become competing truth.

HANDOFF may copy attemptCount / rejectedApproaches / nextAction; it **cannot** grant approval or reset budget.

## Guard

Before claiming done while recovery is active, stamp approval fingerprints then use the **completion gate** (auto-includes `task-state` + `completion` + `approval` and active plugs):

```text
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/Get-ApprovalFingerprints.ps1 -TaskPath docs/sdlc/ACTIVE_TASK.json -WriteToTask
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/Invoke-CompletionGate.ps1 -TaskPath docs/sdlc/ACTIVE_TASK.json
```

Refuse `done|accepted` while exit non-zero / `ok=false`. Direct `Invoke-M4trixGuard.ps1 -Validators task-state,recovery,routing` remains valid for mid-recovery checks. Also include `regression` when multi-behaviour repair is in play, and `research` when root cause / approach is unfamiliar (`researchNeeded=true` → skill **engineering-research**). Protected fail mid-recovery rejects the unit. Routing attrs should set `recoveryActive=true` so calculate mandates debugger + pipeline-recovery.

## MODE SWITCH

- After escalate: `**MODE SWITCH:** Ask — recovery escalate — Captain: decide next for recovery on task <ID>`  
- After diagnosis ready for fix: `**MODE SWITCH:** Agent — apply recovery fix — Implement approved recovery fix for <hypothesis>; record strategyDelta`  
- Routine skip: continue on the current pipeline (patch/module/product) without recovery ceremony  

# Recovery triggers / non-triggers (T4)

## Triggers (activate pipeline-recovery)

- Protected regression after a change
- Repeated defect / same failure after a fix attempt
- Multi-behaviour fails with uncertain root cause
- Evidence contradicts assumptions
- Large blast radius
- Same approach failed before
- Scale under-classified
- Captain requests debug / recovery

## Non-triggers (skip ceremony)

- Well-understood localized bug with a clear fix
- Ordinary approved feature build
- Trivial copy/token patch

## Budgets

| Scale | attemptBudget |
|-------|---------------|
| patch | 2 |
| module | 3 |
| product-critical | 3 then escalate |

Override: `ACTIVE_TASK.recovery.attemptBudget`.

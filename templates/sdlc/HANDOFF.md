# Agent handoff — `<taskId>`

Use **only** when a second agent is truly needed. Skip for trivial single-agent patches.

**Does not** grant new approval or expand scope.

| Field | Content |
|-------|---------|
| Task | ID / title / scale |
| Approved scope | One sentence + AC bullets |
| Paths | Permitted / touched files (paths only) |
| Decisions | Pointers into `DECISIONS.md` / DESIGN (IDs or one-liners) |
| Reuse | Shared components found or created (paths) |
| Done | What was completed |
| Verified | Commands/checks actually run |
| Next | Remaining work for the receiving agent |
| Blockers | Open issues |

## Recovery (when active)

Copy from `ACTIVE_TASK.recovery` — do **not** reset budget or invent approval.

| Field | Content |
|-------|---------|
| attemptCount / attemptBudget | Current counts |
| rejectedApproaches | IDs + summaries (keep cumulative) |
| nextAction | What the receiving agent should do next |
| escalation | reported? summary? |

Receiving agent: continue from this table; **do not** re-investigate unless evidence is missing, stale, or contradictory. Never treat handoff as a fresh attempt budget.

## Routing (when recorded)

Copy from `ACTIVE_TASK.routing` — parent prose claiming a specialist ran is **not** evidence.

| Field | Content |
|-------|---------|
| attributes | Classification used for calculate |
| calculated.mandatoryAgents | From Evaluate-Routing |
| invoked / evidence | Names + type task\|subagent\|artifact\|limitation |
| deferred / limitation | Forward-declare or evidenceLimitation + ack |

Receiving agent: invoke remaining mandatory specialists; do not invent a markdown-only route.

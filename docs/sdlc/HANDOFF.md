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

Receiving agent: continue from this table; **do not** re-investigate unless evidence is missing, stale, or contradictory.

# EGM review — `<taskId / scale>`

**Elephant docs:** (paths)  
**Goldfish:** fresh Task · role(s) · date  
**Status:** pending | findings | resolved | blocked

## Findings

| ID | Severity | Finding | Evidence | Elephant outcome |
|----|----------|---------|----------|------------------|
| G1 | Blocking / Major / Minor / Observation | | | accepted / contested / escalated / declined |

## Blocking policy

Keep `ACTIVE_TASK.egm.blockingOpen=true` while any **Blocking** finding is unresolved.

| Blocking class | Resolution |
|----------------|------------|
| Missing / contradictory requirements, incomplete happy·fail·edge AC | **Must fix in Elephant docs** — not eligible for risk acceptance |
| Unresolved security defects (authz, PII, secrets, payment integrity) | **Must fix or redesign in docs** — not eligible for risk acceptance |
| Implementation / architecture tradeoff risk (known limitation, deferred non-security work) | Captain may **accept-as-risk in writing** here + `DECISIONS.md`; then clear that finding |

Unresolved ineligible Blocking ⇒ **no implementation**. Risk acceptance does **not** replace captain implementation approval.

## Resolution summary

- Accepted changes applied to: (PRD / REQUIREMENTS / DESIGN / DECISIONS)
- Contested / declined (brief why):
- Escalated to captain:
- Written risk acceptances (eligible class only; captain + date + residual risk):

## Captain gate

- [ ] Spec implementation-ready
- [ ] Blocking findings cleared in docs, **or** eligible implementation risks accepted in writing by captain
- [ ] `egm.blockingOpen=false` only after the above
- [ ] Explicit captain approval to implement (review ≠ approval)

## Re-review

Needed? yes/no · reason · date

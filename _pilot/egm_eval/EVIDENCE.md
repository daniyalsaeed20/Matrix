# EGM validation evidence (v1.5.0)

| # | Scenario | Type | Result |
|---|----------|------|--------|
| 1 | Product pipeline activates EGM | Static text + smoke | PASS |
| 2 | Module pipeline Goldfish when design-needed | Static text + smoke | PASS |
| 3 | Patch skips EGM | Static text + smoke | PASS |
| 4 | Fresh Task isolation | Real Task (`m4trix-architect`, no resume) | PASS — Cursor Task does not inherit parent chat |
| 5 | Goldfish detects incomplete spec | Real Task on `incomplete_module_spec.md` | PASS — Blocking: no AC, vague timing/arch; Major: fail/edge, security, reuse |
| 6 | Elephant must not invent scope | Policy in agents + skill | PASS (policy); not a live resolve cycle in this run |
| 7 | Blocking prevents implement | ACTIVE_TASK `egm.blockingOpen` + pipelines | PASS (policy encoded) |
| 8 | Captain approval still required | Skill + ACTIVE_TASK approval note | PASS (policy) |
| 9 | Craft/context/token rules intact | smoke always-apply ≤5, craft checks | PASS |

**Tokens:** N/A  
**Agents:** still 12 permanent; Goldfish = ephemeral Task  
**RTMES / customer apps:** not modified  

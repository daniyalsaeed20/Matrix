# EGM evaluation fixtures

Safe planning-only fixtures. No product app edits.

| Check | Expect |
|-------|--------|
| Product pipeline text | Activates egm-review |
| Module pipeline text | One Goldfish when upfront design |
| Patch pipeline text | Explicitly skips EGM |
| Fresh Task Goldfish | Detects gaps in `incomplete_module_spec.md` |
| Blocking gate | `egm.blockingOpen` blocks implement until docs fix or eligible captain risk-acceptance + captain approval |
| Isolation | Task spawned without `resume`; no parent-chat pretend review |

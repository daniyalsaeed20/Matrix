# Craft scenario expectations (policy)

Safe fixtures for verifying m4tr!x coding intelligence — not a production app.
Automated smoke checks that the kit **encodes** these behaviors; live UI/API runs are optional when a temp app exists.

| # | Request shape | Expect |
|---|---------------|--------|
| 1 | Small UI patch (button style) | Minimal files; one agent; no PRD; no unrelated refactor |
| 2 | New screen (custom app bar + info cards) | Inspect shared UI; reuse; extract shared only if app-wide; clean composition |
| 3 | Second similar screen | Reuse shared header/card; no duplicate styles |
| 4 | Simple API endpoint | Existing architecture; no extra layers; reuse validation/errors; security + tests |
| 5 | Small bugfix | Root cause; focused fix; verify; no orthogonal edits |

Gate: `04-code-craft.mdc` + verifier checklist + stack reuse rules.

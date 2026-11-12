# UI craft eval — evidence

**Kit version:** 1.6.0  
**Date:** 2026-11-12

## Automated (`flutter test`)

```text
All tests passed! (9)
```

| Scenario | Result | Method |
|----------|--------|--------|
| 1 New screen + theme | PASS | Widget test — MembersScreen uses `AppTheme.light()` |
| 2 Reuse shared card | PASS | ProfileScreen finds 2× `AppInfoCard` |
| 3 Long / empty data | PASS | 320px surface, long name/email, empty state; no overflow exception |
| 4 Motion restraint | PASS | CalmList has no descendant FadeTransition; OverAnimatedList has 2 (anti-pattern fixture) |
| 6 Text scale / disableAnimations | PASS | textScaler 2.0 + `MediaQuery.disableAnimations` |

## Manual / policy

| Scenario | Result | Method |
|----------|--------|--------|
| 5 Small patch ceremony | PASS (policy) | `pipeline-patch` + `03-token-discipline` item 6 — no full ui-craft/ui-stress load |

## Visual inspection

Not run in CI. Narrow-width overflow covered by Flutter exception check; pixel-perfect truncation/ellipsis appearance is visual-only if needed later.

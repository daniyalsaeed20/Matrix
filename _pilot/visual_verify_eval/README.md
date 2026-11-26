# Visual verification eval (T9)

Behavioural ± evaluation for VIS-001, VIS-002, UI-003, GRD-002, EVAL-001.

Proves Guard `visual` validator honesty, defect gallery presence, production-bar /
verifier pointers, and that static-only cannot pass as `visually_verified`.

## What it proves

| Case | Expect |
|------|--------|
| Validator present | `bootstrap/guard/validators/visual.ps1` |
| Real artifacts + non-static | `valid-visual-verified` → ok |
| Blocked honesty | `valid-visual-blocked` → ok |
| Static-only verified | `invalid-visual-static-verified` → fail |
| Missing artifact path | `invalid-visual-missing-artifact` → fail |
| Defect gallery | spacing, overflow, shared-component, weak-hierarchy |
| ui_craft_eval evidence | Widget/golden ≠ `visually_verified` alone (documented) |
| Patch skip | production-bar / pipeline-patch skip full visual bar |

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/visual_verify_eval/scripts/Invoke-VisualVerifyEval.ps1
```

## Live procedure

See `LIVE_PROCEDURE.md`. Script ± is the automated bar for T9 accept; live device/browser
render strengthens honesty when the captain runs it — never fabricate screenshots.

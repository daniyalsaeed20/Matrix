# UI designer eval fixture (T8)

Behavioural ± evaluation for UI/UX design intelligence (UI-001…UI-003, RTE significant-UI, EVAL-001).

T8 shipped designer path/disposition. T9 owns `verificationEvidence` / Guard `visual` — see `_pilot/visual_verify_eval/`.

## What it proves

| Case | Expect |
|------|--------|
| Significant UI path | ui-designer agent present; routing mandatory; not deferred |
| Weak-hierarchy defect | Critique notes required; design-doc-only insufficient |
| Design-doc-only “done” | FAIL |
| Trivial copy/colour patch | Designer path skipped / not required |
| Disposition | Designer ≠ implementer ≠ design-system ≠ verifier |

Also asserts: pipelines mention significant-UI workflow; MANIFEST lists agent; USER_RULES thin pointer.

## Defect gallery

T8 seed remains under `fixtures/defects/`. Extended gallery (spacing, overflow, shared-component) lives in `_pilot/visual_verify_eval/fixtures/defects/`.

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/ui_designer_eval/scripts/Invoke-UiDesignerEval.ps1
```

## Live prompts

See `LIVE_PROCEDURE.md`. Script content ± is the automated bar; live render/critique strengthens honesty when captain runs it.

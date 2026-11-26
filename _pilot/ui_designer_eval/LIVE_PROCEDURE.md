# Live UI designer procedure (T8)

Optional captain-assisted prompts. Script layer in `Invoke-UiDesignerEval.ps1` is required for T8 accept; live layer strengthens honesty.

## Positive — significant UI with render + critique

1. Open a fresh Agent chat on an isolated eval copy (or dogfood UI module).
2. Prompt: *Build a significant new screen. Use m4trix-ui-designer for journey/composition, implement with Flutter, render (web or device), then critique and refine. Do not claim done on design docs alone.*
3. Expect: designer invoked; render evidence (screenshot or device capture when available); objective critique notes; implementer applied at least one refine; verifier did not redesign as primary author.
4. Record notes under `evidence/live-positive.md` (attach screenshot paths if available).

## Negative — design-doc-only done

1. Prompt: *Significant UI module. Write DESIGN.md / journey notes only, then claim the module done without render or critique.*
2. Expect: verifier / pipeline rejects as design-doc-only incomplete (or agent refuses to claim done).
3. Record under `evidence/live-negative.md`.

## Limitation

If live render cannot run (no Flutter/device/browser), write `evidence/live-limitation.md` stating script ± passed and live pending — do not claim live PASS or fabricate screenshots.

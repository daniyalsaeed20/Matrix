# Live visual verification procedure (T9)

Script bar (`Invoke-VisualVerifyEval.ps1`) is **required** for T9 accept.

Live render is **optional** and strengthens honesty when tools are available.

## Steps (when captain runs live)

1. Pick a significant-UI surface (product app or `_pilot/ui_craft_eval`).
2. Render via available tooling (Flutter device/web, browser tab, desktop capture).
3. Save a real artifact under `docs/sdlc/evidence/` or the task's evidence folder.
4. Set `verificationEvidence.visualStatus=visually_verified`, `method=render|manual`, artifacts to real paths.
5. Run `Invoke-M4trixGuard.ps1 -Validators task-state,visual -TaskPath docs/sdlc/ACTIVE_TASK.json`.
6. If tooling unavailable: set `blocked` or `functionally_verified_visually_unverified` + limitations — do **not** invent PNG paths.

## Honesty rules

- Static analyze / widget test alone → not `visually_verified`
- Missing emulator → document limitation; never claim coverage
- Shared-component tweaks → check neighbor screens (VIS-002)

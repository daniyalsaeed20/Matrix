# MODULE_HANDOFF — T16 Activation (globals only)

**Status:** **in_progress** 2026-11-26 (captain `Activate globals 2.0.0 — globals only`)  
**Preflight:** `_pilot/v2_activation/evidence/PREFLIGHT_RESULT.json` — checks ok  
**Agent Fresh:** **forbidden** — captain executes `install-globals.ps1 -Fresh`

## Preflight delivered

| Area | Path / result |
|------|----------------|
| RB-01…RB-10 | clear (`_pilot/v2_eval/evidence/RB_CHECKLIST.md`) |
| RC zip | `dist/matrix-kit-2.0.0-src.zip` — see `PACKAGE_INTEGRITY.json` / `RC_ZIP_VERIFY.json` |
| Rollback zip | `dist/matrix-kit-1.6.0-src.zip` — `ROLLBACK_ZIP_VERIFY.json` VERSION 1.6.0 |
| Live backup | `_pilot/v2_activation/evidence/pre-activation-backup-2026-11-26T102412Z/` |
| Checklist | `_pilot/v2_activation/ACTIVATION_CHECKLIST.md` |
| Release status | `_pilot/v2_activation/RELEASE_STATUS.md` |
| Scope | **Globals only** — no workspace apply this task |

## Captain next

1. Run Fresh from checklist (no `-AutoApplyWorkspaces`)
2. Reload Cursor; paste `~/.cursor/m4trix/USER_RULES.md`; Attribution off
3. Reply `Fresh complete — verify T16`

## After verify

Record post-activate inventory; captain `accept Task 16`; freeze v2.0.0 implementation.

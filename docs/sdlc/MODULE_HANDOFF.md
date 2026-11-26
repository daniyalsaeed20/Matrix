# MODULE_HANDOFF — T16 Activation (globals only)

**Status:** **in_progress** 2026-11-26 — post-Fresh verify **FAIL**; source `v2.0.0` may publish to GitHub  
**Preflight:** `_pilot/v2_activation/evidence/PREFLIGHT_RESULT.json` — checks ok  
**Post-verify:** `_pilot/v2_activation/evidence/POST_FRESH_VERIFY.json` — **FAIL** (kit.json still `1.6.0`)  
**Agent Fresh:** **forbidden** — captain executes `install-globals.ps1 -Fresh`  
**Release notes:** `docs/releases/RELEASE_NOTES_2.0.0.md`

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

## Verify result (2026-11-26)

| Check | Expected | Observed |
|-------|----------|----------|
| `~/.cursor/m4trix/kit.json` version | `2.0.0` | **`1.6.0`** (same `installedAt` as pre-backup) |
| Agents debugger + ui-designer | present | **missing** |
| Skills `pipeline-recovery` + `engineering-research` | present | **missing** |
| `autoApplyWorkspaces` | false | false (ok) |
| Product workspace apply | none | none (ok) |

**Conclusion:** Fresh did **not** update globals. Do **not** accept Task 16.

## Captain next

1. Re-run Fresh from checklist (no `-AutoApplyWorkspaces`):

```powershell
cd E:\development\Matrix
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh
```

2. Confirm console shows `version -> 2.0.0` and completes without error  
3. Reload Cursor; paste `~/.cursor/m4trix/USER_RULES.md`; Attribution off  
4. Reply `Fresh complete — verify T16`

## After successful verify

Record post-activate inventory; captain `accept Task 16`; freeze v2.0.0 implementation.

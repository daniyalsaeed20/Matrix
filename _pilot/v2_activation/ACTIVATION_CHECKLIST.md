# T16 — Activation checklist (globals only)

**Authorization:** Captain written go 2026-11-26 — `Activate globals 2.0.0 — globals only.`  
**Agent rule:** Do **not** run `install-globals -Fresh` from the agent. Captain executes the Fresh command below.  
**Workspace apply:** **none** in this activation (captain applies later per project with DryRun).

## Preflight (agent — completed before Fresh)

| # | Check | Result |
|---|--------|--------|
| 1 | RB-01…RB-10 clear | PASS — `_pilot/v2_eval/evidence/RB_CHECKLIST.md` |
| 2 | Source `VERSION` | `2.0.0` |
| 3 | RC zip integrity | PASS — `evidence/PACKAGE_INTEGRITY.json` + `RC_ZIP_VERIFY.json` |
| 4 | 1.6.0 rollback zip | PASS — `ROLLBACK_ZIP_VERIFY.json` (VERSION 1.6.0, install-globals present) |
| 5 | Pre-activation backup | `evidence/pre-activation-backup-*/` (kit.json, hooks.json, USER_RULES.md, INVENTORY.json) |
| 6 | Third-party hooks | None present at backup (only m4trix sessionStart/workspaceOpen). Merge path preserves unrelated hooks if added later. |
| 7 | Scope | Globals only — no `apply-to-workspace` |
| 8 | Limitations accepted | Captain acknowledgment recorded in DECISIONS / ACTIVE_TASK |
| 9 | Git release checkpoint | `094df71` (v2.0.0 release) — see `evidence/GIT_CHECKPOINT.json` |

## Captain — run these steps now

Working directory: `E:\development\Matrix`

### 1. Activate globals (required)

```powershell
cd E:\development\Matrix
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh
```

Do **not** pass `-AutoApplyWorkspaces`.

### 2. Reload Cursor

Fully reload the window (or restart Cursor) so agents/skills/hooks reload.

### 3. Paste User Rules

1. Open Cursor → **Customize → Rules** (or Settings → Rules).
2. Paste **full** contents of:  
   `C:\Users\Datab\.cursor\m4trix\USER_RULES.md`
3. Save.

If you kept custom additions beyond the kit paste, merge them manually after pasting the kit copy. Pre-activation paste backup:  
`_pilot/v2_activation/evidence/pre-activation-backup-2026-11-26T102412Z/USER_RULES.md`

### 4. Attribution off

Turn **off** Cursor **Settings → Git & PRs → Attribution** (commit + PR).  
Older builds: **Settings → Agent → Attribution**.

### 5. Confirm back to agent

Reply exactly:

```text
Fresh complete — verify T16
```

Agent will then verify kit marker, agents, skills, hooks, Guard, router, recovery, research, UI designer — and record evidence. Agent still will **not** apply any product workspace.

## Rollback (if activation fails)

See `dist/ROLLBACK_2.0.0.md`. Short form:

```powershell
# Unpack retained zip if needed, then from the 1.6.0 tree:
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh
```

Retain `dist/matrix-kit-1.6.0-src.zip` (SHA256 in `evidence/PACKAGE_INTEGRITY.json`).

## Out of scope this activation

- Applying v2 to product apps (captain will DryRun + apply explicitly later)
- Reopening T1–T15 / new epic / framework restructure
- Force-push / silent Fresh by agent

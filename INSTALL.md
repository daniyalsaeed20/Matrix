# m4tr!x Kit — Install

Works on **Windows** and **macOS**. Bootstrap/hooks are PowerShell; on Mac install PowerShell Core first:

```bash
brew install powershell
```

**Kit root = this clone.** No fixed `D:\cursor-org-kit` default. Optional override: `M4TRIX_KIT_ROOT`.

## 1. Globals (account-wide) — only when you say so

From the clone directory:

**Windows**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh
```

**macOS**

```bash
pwsh -NoProfile -File ./bootstrap/install-globals.ps1 -Fresh
```

`-Fresh` **removes previous m4tr!x-managed setup** (agents `m4trix-*`, kit skills, m4trix hook scripts, m4trix `hooks.json` entries, `~/.cursor/m4trix/`), then installs clean from this clone.

Installs:

- `~/.cursor/agents/m4trix-*.md`
- `~/.cursor/skills/{bootstrap-org,pipeline-*,egm-review}/`
- `~/.cursor/hooks/m4trix-*.ps1`
- `~/.cursor/m4trix/kit.json` (persists kit root + flags)
- `~/.cursor/m4trix/USER_RULES.md` (path-resolved paste source)
- Merges into `~/.cursor/hooks.json` (backs up first; fails clearly on malformed JSON; preserves unrelated hooks + custom properties):
  - `workspaceOpen` — applies only if you later used `-AutoApplyWorkspaces`
  - `sessionStart` — missing-marker reminder or outdated-marker upgrade advisory (never auto-upgrades)
  - Strips any prior m4tr!x `beforeSubmitPrompt` entries (no longer registered)

Does **not** touch `~/.cursor/skills-cursor/` or unrelated hooks.

Also on install:

- Sets `~/.cursor/cli-config.json` `attribution.attributeCommitsToAgent` / `attributePRsToAgent` to `false` when that file exists (stops CLI/agent `Co-authored-by: Cursor` trailers).
- Installs a local `commit-msg` git hook in the **kit clone** that strips known IDE attribution trailers.

Reload Cursor after installing.

## 2. User Rules + Attribution

1. Open Cursor → **Customize → Rules**.
2. Paste **full** contents of `~/.cursor/m4trix/USER_RULES.md`.
3. Save.
4. Turn **off** Cursor **Settings → Git & PRs → Attribution** (commit + PR). Older builds: **Settings → Agent → Attribution**.

## 3. Per-project apply — explicit

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\apply-to-workspace.ps1 -Workspace "C:\path\to\your\app" -DryRun
# then without -DryRun
```

Copies rules/agents/skills/templates (incl. code craft + ACTIVE_TASK), detects stacks additively, writes `docs/sdlc/.m4trix-kit.json` with the clone `kitRoot`, and installs `.git/hooks/commit-msg` (when `.git` exists) to strip IDE `Co-authored-by` / Made-with trailers.

## 4. Optional auto-apply

```powershell
.\bootstrap\install-globals.ps1 -Fresh -AutoApplyWorkspaces
```

## 5. Smoke tests

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\smoke-tests.ps1
```

## Uninstall m4tr!x globals only

Re-run with a wipe helper:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command {
  . .\hooks\m4trix-platform.ps1
  Remove-M4trixManagedGlobals
}
```

Then remove pasted User Rules manually if desired.

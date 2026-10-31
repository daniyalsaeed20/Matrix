# m4tr!x Org Kit — Install

Works on **Windows** and **macOS**. Bootstrap/hooks stay PowerShell; on Mac install **PowerShell Core** first:

```bash
brew install powershell
```

Optional: set `M4TRIX_KIT_ROOT` if the kit is not at the default path.

| OS | Default kit root |
|----|------------------|
| Windows | `D:\cursor-org-kit` |
| macOS | `$HOME/Desktop/cursor-org-kit` |

## 1. Globals (account-wide)

**Windows**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\cursor-org-kit\bootstrap\install-globals.ps1
```

**macOS**

```bash
pwsh -NoProfile -File "$HOME/Desktop/cursor-org-kit/bootstrap/install-globals.ps1"
```

Installs:

- `~/.cursor/agents/m4trix-*.md` (Windows: `%USERPROFILE%\.cursor\agents\`)
- `~/.cursor/skills/{bootstrap-org,pipeline-product,pipeline-module,pipeline-patch}/`
- `~/.cursor/hooks/m4trix-*.ps1` (includes `m4trix-platform.ps1`)
- Merges m4tr!x entries into `~/.cursor/hooks.json`:
  - `workspaceOpen` — auto-apply kit when you open a real project without the marker
  - `beforeSubmitPrompt` — injects a short reminder if the kit is still missing
  - Commands use `powershell` on Windows and `pwsh` on macOS

Does **not** touch `~/.cursor/skills-cursor/`.

Reload the Cursor window after installing hooks (or check **Customize → Hooks**).

## 2. User Rules (manual paste — required)

1. Open Cursor → **Customize → Rules** (User Rules).
2. Paste the **full** contents of `constitution/USER_RULES.md` from the kit root (includes auto-bootstrap for Windows + Mac).
3. Save.

This is the reliable fallback if a hook does not fire. You do **not** paste rules again per project.

## 3. Per-project install (usually automatic)

When you open a project folder that looks like an app (`pubspec.yaml`, `package.json`, etc.) and `docs/sdlc/.m4trix-kit.json` is missing, the **workspaceOpen** hook runs:

```text
apply-to-workspace.ps1 → .cursor/ + docs/sdlc/
```

### Manual / agent fallback

**Windows**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\cursor-org-kit\bootstrap\apply-to-workspace.ps1 -Workspace "C:\path\to\your\app"
```

**macOS**

```bash
pwsh -NoProfile -File "$HOME/Desktop/cursor-org-kit/bootstrap/apply-to-workspace.ps1" -Workspace "/path/to/your/app"
```

Or in Agent chat (User Rules will push this if the marker is missing):

```text
Bootstrap m4tr!x for this workspace from the kit root (apply now).
```

Add `-IncludeNode` only when you want Node agents on a Flutter repo (custom backend).

Creates/updates:

- `.cursor/rules/` (m4trix OS + detected stacks)
- `.cursor/agents/` (relevant m4trix agents)
- `.cursor/skills/` (pipelines + bootstrap)
- `docs/sdlc/` templates + ecc-reference
- `docs/sdlc/.m4trix-kit.json` marker

## 4. Model picker

Set chat model to **Auto**. Prefer **Cost** optimization when your plan offers it.

## 5. Update kit later

1. Edit files under the kit root.
2. Re-run `install-globals.ps1` (same OS command as step 1).
3. Re-paste User Rules if `constitution/USER_RULES.md` changed.
4. Open projects again (or re-run apply) so workspace copies refresh.
5. Bump `VERSION` when you publish a meaningful kit change.

## 6. Uninstall globals (optional)

Delete `~/.cursor/agents/m4trix-*.md`, the four skill folders under `~/.cursor/skills/`, `~/.cursor/hooks/m4trix-*.ps1`, and remove m4trix entries from `hooks.json`. Remove User Rules text you pasted. Project `.cursor` / `docs/sdlc` remain until you delete them per repo.

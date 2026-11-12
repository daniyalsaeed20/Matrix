---
name: bootstrap-org
description: Bootstrap m4tr!x org kit into the current workspace. Detect stack, dry-run file plan from MANIFEST.json, wait for captain approval, then copy rules/agents/skills/templates into .cursor and docs/sdlc. Use when starting a new project or enabling m4tr!x on an existing repo.
---

# bootstrap-org (m4tr!x)

## Defaults

- Kit root is **self-locating**:
  1. `M4TRIX_KIT_ROOT` if set
  2. `~/.cursor/m4trix/kit.json` → `kitRoot` (from `install-globals.ps1`)
  3. Captain-named clone path
- **Do not** assume `D:\cursor-org-kit` or Desktop defaults.
- **Do not** apply the kit until the captain asks.
- Prefer dry-run first when the workspace already has customized `docs/sdlc`.

```powershell
# Windows — kitRoot from install state or captain
powershell -NoProfile -ExecutionPolicy Bypass -File "<kitRoot>\bootstrap\apply-to-workspace.ps1" -Workspace "<workspaceRoot>" -DryRun
# then without -DryRun after captain OK

# macOS
pwsh -NoProfile -File "<kitRoot>/bootstrap/apply-to-workspace.ps1" -Workspace "<workspaceRoot>" -DryRun
```

Machine globals (once per machine, captain-initiated):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<kitRoot>\bootstrap\install-globals.ps1" -Fresh
```

## Steps

1. Resolve kit root; confirm `VERSION`, `bootstrap/MANIFEST.json`, `bootstrap/apply-to-workspace.ps1`, `hooks/m4trix-platform.ps1`.
2. If `docs/sdlc/.m4trix-kit.json` already exists → report installed version and stop (unless captain wants re-apply).
3. Detect stacks (additive): flutter / firebase / python / nodejs (Node not suppressed by Flutter).
4. Dry-run apply; wait for captain if overwrite risk; then apply.
5. Confirm marker + `.cursor/rules` + `docs/sdlc` exist (including `ACTIVE_TASK.json` template when new).
6. Summarize; continue with the right pipeline.

`**MODE SWITCH:** Plan or Agent — start delivery — Use pipeline-product | pipeline-module | pipeline-patch for the request`

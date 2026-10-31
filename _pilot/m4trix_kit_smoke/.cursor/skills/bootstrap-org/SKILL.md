---
name: bootstrap-org
description: Bootstrap m4tr!x org kit into the current workspace. Detect stack, dry-run file plan from MANIFEST.json, wait for captain approval, then copy rules/agents/skills/templates into .cursor and docs/sdlc. Use when starting a new project or enabling m4tr!x on an existing repo.
---

# bootstrap-org (m4tr!x)

## Defaults

- Kit root: `D:\cursor-org-kit` (override if captain names another path)
- Captain opted into **auto-install**. Prefer:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\cursor-org-kit\bootstrap\apply-to-workspace.ps1 -Workspace "<workspaceRoot>"
```

- Use dry-run only if captain asks, or if apply fails / risk of overwriting customized docs
- Merge-safe apply script skips heavy non-template `docs/sdlc` content
- User-level hooks (`workspaceOpen`, `beforeSubmitPrompt`) also try to install; this skill is the agent fallback

## Steps

1. Confirm kit root exists (`VERSION`, `bootstrap/MANIFEST.json`, `bootstrap/apply-to-workspace.ps1`).
2. If `docs/sdlc/.m4trix-kit.json` already exists → report installed version and stop (unless captain wants re-apply).
3. Detect stacks (same rules as apply script): flutter / firebase / python (not Flutter ephemeral `.py`) / nodejs only if non-Flutter or `-IncludeNode`.
4. Run `apply-to-workspace.ps1` for the workspace (or copy per `MANIFEST.json` if script unavailable).
5. Confirm marker + `.cursor/rules` + `docs/sdlc` exist.
6. Summarize; continue captain request with the right pipeline.

`**MODE SWITCH:** Plan or Agent — start delivery — Use pipeline-product | pipeline-module | pipeline-patch for the request`

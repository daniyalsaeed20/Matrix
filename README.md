# m4tr!x Cursor Org Kit

Reusable Agile SDLC operating system for Cursor. You are the captain; specialist agents plan, clarify, design, implement, verify, and document. Production-ready delivery only — no mockups as finished work.

**Version:** see `VERSION`  
**Kit root:** Windows `D:\cursor-org-kit` · macOS `$HOME/Desktop/cursor-org-kit` (override: `M4TRIX_KIT_ROOT`)  
**Org:** m4tr!x  
**Platforms:** Windows + macOS (PowerShell scripts; Mac needs `pwsh`)

## What you get

| Layer | Purpose |
|-------|---------|
| Constitution | User Rules + project `.cursor/rules` |
| Agents | `m4trix-*` subagents (`model: inherit` / Auto) |
| Skills | `bootstrap-org`, `pipeline-product`, `pipeline-module`, `pipeline-patch` |
| Templates | `docs/sdlc/*` source-of-truth stubs |
| User hooks | Auto-apply on workspace open + prompt reminder if kit missing |
| ECC cherry-pick | Adapted excerpts only (no full ECC install) |

## Quick start

### macOS prerequisite

```bash
brew install powershell
```

### 1. Globals install (once per machine)

**Windows**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\cursor-org-kit\bootstrap\install-globals.ps1
```

**macOS**

```bash
pwsh -NoProfile -File "$HOME/Desktop/cursor-org-kit/bootstrap/install-globals.ps1"
```

### 2. User Rules

Paste the **full** [`constitution/USER_RULES.md`](constitution/USER_RULES.md) into **Customize → Rules** and Save.

### 3. Reload + open a project

Reload Cursor once so user hooks load. Open a real project — kit auto-applies when `docs/sdlc/.m4trix-kit.json` is missing.

### 4. Agent fallback

If the marker is still missing, Agent installs via User Rules / `apply-to-workspace.ps1` (you do not need to memorize the command).

### 5. Pipelines

- Full app / epic → `pipeline-product`
- Feature module → `pipeline-module`
- Small UI/bug fix → `pipeline-patch`

Follow every **MODE SWITCH** line (Ask / Plan / Agent / Debug). Cursor does not switch modes for you.

## Stack defaults (new projects)

- Flutter UI: **BLoC**, **GoRouter**, Material 3 + **design-system/theme catalog first**
- Existing stacks: **do not rewrite**
- BaaS: **Firebase-first**; custom Node/Python only when approved
- Auth / offline DB / sync / deploy targets: **propose → captain approves**
- Backlog: `docs/sdlc/BACKLOG.md` only

## Token discipline

- Model picker: **Auto** (prefer Cost when available)
- Subagents: `inherit` — never pin frontier models unless captain orders it
- Always-apply rules are slim; stack rules use globs
- One phase or module per chat when possible
- Avoid `/multitask` unless workstreams are truly independent

## Layout

```text
cursor-org-kit/
  constitution/     USER_RULES + project-rules
  agents/           m4trix-*.md
  skills/           bootstrap + pipelines
  templates/sdlc/   PRD, requirements, design, backlog, ...
  ecc-cherry-pick/  adapted ECC notes + ORIGIN.md
  bootstrap/        MANIFEST.json, install-globals.ps1, apply-to-workspace.ps1
  hooks/            platform helper + user hooks + hooks.json template
  _pilot/           smoke Flutter app (optional)
```

## Validation

**Pilot:** kit `_pilot/m4trix_kit_smoke` (Flutter 3.47 create)  
**Date:** 2026-10-29 (cross-platform pass: 2026-10-31)

| Check | Result |
|-------|--------|
| Globals install (`install-globals.ps1`) | 12 agents + 4 skills under `~/.cursor` |
| Bootstrap apply | OK via `bootstrap/apply-to-workspace.ps1` |
| Detected stacks | `flutter` only (ignores Flutter ephemeral `.py`) |
| `.cursor/rules` | OS rules + `stack-flutter.mdc` |
| `.cursor/agents` | common + `m4trix-flutter` |
| `.cursor/skills` | bootstrap + 3 pipelines |
| `docs/sdlc` + ecc-reference | templates + cherry-picks present |
| `.m4trix-kit.json` | written |
| `MODE SWITCH` in pipeline skills | present |
| User hooks (v1.2.0) | `workspaceOpen` + `beforeSubmitPrompt`; `powershell` / `pwsh` by OS |

**Manual (captain):** re-paste `constitution/USER_RULES.md` into Cursor User Rules after kit rule updates.

# m4tr!x Cursor Org Kit (Matrix)

Reusable Agile SDLC operating system for Cursor. You are the captain; specialist agents plan, clarify, design, implement, verify, and document. Production-ready delivery only — no mockups as finished work.

**Version:** see `VERSION`  
**Kit root:** wherever **this repo was cloned** (self-locating). Optional override: `M4TRIX_KIT_ROOT`  
**Org:** m4tr!x  
**Platforms:** Windows + macOS (PowerShell; Mac needs `pwsh`)  
**Craft:** think → simple → surgical → verify (`04-code-craft`)  
**Context:** progressive load + task memory (`03-token-discipline`, `ACTIVE_TASK.json`)  
**Planning:** Elephant→Goldfish via `egm-review` for product/design-heavy modules; **patches skip** (EGM-inspired, Apache-2.0 attributed)

This repository **is** the kit. Clone it, then install when you choose — nothing wires itself until you say so.

## What you get

| Layer | Purpose |
|-------|---------|
| Constitution | User Rules + project `.cursor/rules` (incl. code craft) |
| Agents | 12× `m4trix-*` subagents (`model: inherit` / Auto) |
| Skills | `bootstrap-org`, `pipeline-product`, `pipeline-module`, `pipeline-patch` |
| Templates | `docs/sdlc/*` including `ACTIVE_TASK.json` + `DECISIONS.md` |
| User hooks | Opt-in workspace apply; sessionStart reminder; schema-correct beforeSubmitPrompt |
| ECC cherry-pick | Adapted excerpts only |

## Quick start

### macOS prerequisite

```bash
brew install powershell
```

### 1. Clone this repo anywhere

```text
git clone <your-matrix-kit-remote> Matrix
cd Matrix
```

### 2. Fresh machine install (explicit)

**Windows** (from the clone):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh
```

**macOS:**

```bash
pwsh -NoProfile -File ./bootstrap/install-globals.ps1 -Fresh
```

`-Fresh` removes prior **m4tr!x-managed** agents/skills/hooks/state, then installs from **this clone path**. Unrelated Cursor hooks are kept.

Optional: `-AutoApplyWorkspaces` enables silent project apply on folder open (default **off**).

### 3. User Rules

Paste the generated copy from `~/.cursor/m4trix/USER_RULES.md` into **Customize → Rules** (or use `constitution/USER_RULES.md` after install substitutes the kit path).

### 4. Reload Cursor

Reload so user hooks load. Opening a project does **not** auto-apply unless you passed `-AutoApplyWorkspaces`.

### 5. Apply to a project (explicit)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\apply-to-workspace.ps1 -Workspace "C:\path\to\app"
```

Prefer `-DryRun` first when the app already has `docs/sdlc`.

### 6. Pipelines

- Full app / epic → `pipeline-product`
- Feature module → `pipeline-module`
- Small UI/bug fix → `pipeline-patch`

Follow every **MODE SWITCH** line.

## Stack defaults (new projects)

- Flutter UI: **BLoC**, **GoRouter**, Material 3 + design-system/theme catalog first + reuse ladder
- Existing stacks: **do not rewrite**
- BaaS: **Firebase-first**; custom Node/Python only when approved
- Mixed stacks are **additive** (Flutter + Functions/Node is valid)

## Layout

```text
Matrix/   (kit root = clone path)
  constitution/     USER_RULES + project-rules
  agents/           m4trix-*.md
  skills/           bootstrap + pipelines
  templates/sdlc/   PRD, requirements, ACTIVE_TASK, ...
  ecc-cherry-pick/  adapted ECC notes
  bootstrap/        MANIFEST, install-globals, apply-to-workspace, smoke-tests
  hooks/            platform + user hooks + hooks.json template
  _pilot/           smoke fixtures
```

## Validation

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\smoke-tests.ps1
```

## Cutover from old kit

After this kit works on your machine: uninstall/stop using `D:\cursor-org-kit` (or Desktop copy). Matrix is the source of truth.

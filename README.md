# m4tr!x — Cursor Org Kit (Matrix)

**m4tr!x** turns Cursor into a delivery org: you are the **captain** (CEO); specialist agents plan, clarify, design, implement, verify, and document — with gates, scale-matched ceremony, and a production bar (no mockups as “done”).

| | |
|--|--|
| **Version** | `1.5.3` (`VERSION`) |
| **Kit root** | This clone (self-locating). Override: `M4TRIX_KIT_ROOT` |
| **Platforms** | Windows + macOS (`pwsh` on Mac) |
| **Defaults** | Flutter (BLoC + GoRouter + M3), Firebase-first; Node/Python only when approved |
| **Planning review** | Elephant→Goldfish (`egm-review`) for product / design-heavy modules; **patches skip** |

This repo **is** the kit. Nothing wires itself until you install and apply.

---

## How it works

```text
  You (captain) ──► state the ask
                         │
                         ▼
              ┌── scale detection ──┐
              │                     │
         product              module              patch
              │                     │                │
              ▼                     ▼                ▼
     pipeline-product      pipeline-module    pipeline-patch
              │                     │                │
              ▼                     ▼                │
        approvals + MODE SWITCH ────┘                │
              │                                      │
              ▼                                      │
        EGM needed? ──yes──► Goldfish Task           │
              │                     │                │
              no / patch            ▼                │
              │            captain says go           │
              └──────────────┬──────┘                │
                             ▼                       │
                    implement → verify ◄─────────────┘
                             │
                             ▼
                    update docs/sdlc + BACKLOG
```

Always-on under the hood: **rules**, **12 agents**, **pipeline skills**, and **`docs/sdlc`** as source of truth.

---

## Why m4tr!x (vs Cursor alone)

Cursor is a strong coding IDE. It does **not** by itself enforce ownership, ceremony-by-size, stop-and-ask gates, progressive context, skeptical verification, or isolated planning review.

| Area | Vanilla Cursor | With m4tr!x |
|------|----------------|-------------|
| Role | You + ad-hoc agent | Captain + named specialists |
| Ceremony | Same energy for toggle and epic | **product / module / patch** pipelines |
| Scope | Easy to invent features | Clarify first; park extras in `BACKLOG.md` |
| Approvals | Soft / absent | Explicit gates; implement only what you name |
| Modes | Easy to keep coding across phases | Forced **MODE SWITCH** (Ask / Plan / Agent / Debug) |
| Planning | Spec and chat blur together | Self-contained `docs/sdlc/*` + **Goldfish** fresh Task |
| Patches | Often pull full PRD / swarm | Lightweight brief; **EGM skipped** |
| Context | Full-history reread common | Progressive load + `ACTIVE_TASK.json` + `HANDOFF.md` |
| Done | “Looks good” | Production bar + skeptical verifier |
| Cost | Easy to pin expensive models | Prefer **Auto**; subagents `model: inherit` |

### Pilot evidence (honest)

Comparable runs live under `_pilot/`. Cursor does not expose reliable in-agent token counts here (`Tokens: N/A`) — **no invented % savings**.

| Eval | Result |
|------|--------|
| **Behavior** | **PASS** — surgical patch, shared UI reuse, auth gate, verifier from HANDOFF (5 files) |
| **EGM** | **PASS** — fresh Task isolation; incomplete-spec flagged Blocking |
| **Craft / context** | Encoded in rules + smoke; context = rubric over time |

Residual: progressive load / handoffs rely on agent compliance (hooks do not hard-enforce). Numeric tokens → Cursor usage UI outside the agent.

---

## What you get

| Layer | Contents |
|-------|----------|
| **Constitution** | User Rules + project rules `00`–`05` + stack rules |
| **Agents** | 12× `m4trix-*` specialists |
| **Skills** | `bootstrap-org`, `pipeline-product`, `pipeline-module`, `pipeline-patch`, `egm-review` |
| **SDLC templates** | PRD, REQUIREMENTS, DESIGN, DESIGN_SYSTEM, BACKLOG, ACTIVE_TASK, HANDOFF, EGM_REVIEW, … |
| **Hooks** | `sessionStart` advisory; `workspaceOpen` only with `-AutoApplyWorkspaces` |
| **Validation** | `bootstrap/smoke-tests.ps1` + `_pilot/` evals |

### Specialist agents

```text
                         Captain
                            │
      ┌─────────┬───────────┼───────────┬──────────┐
      ▼         ▼           ▼           ▼          ▼
  product  requirements  architect  design-sys  scrum
                            │           │          │
                            └─────┬─────┘──────────┘
                                  ▼
              flutter · firebase · node · python
                                  │
                    ┌─────────────┼─────────────┐
                    ▼             ▼             ▼
                security      verifier     docs-deploy
```

| Agent | Job |
|-------|-----|
| `m4trix-product` | PRD, framing, non-goals, risks |
| `m4trix-requirements` | FR/NFR — happy / fail / edge |
| `m4trix-architect` | `DESIGN.md`; Elephant or **Goldfish** |
| `m4trix-design-system` | Themes, catalog, motion |
| `m4trix-scrum` | Scale, sequencing, MODE SWITCH |
| `m4trix-flutter` / `firebase` / `node` / `python` | Stack implementers (Node/Python only when approved) |
| `m4trix-security` | Auth, PII, payments, rules — OWASP-minded |
| `m4trix-verifier` | Skeptical QA — never rubber-stamps |
| `m4trix-docs-deploy` | SDLC / handoff / late deploy docs (you still deploy) |

### Skills

| You want… | Skill |
|-----------|--------|
| Wire kit into a repo | `bootstrap-org` |
| Full new app / epic | `pipeline-product` |
| One multi-file feature | `pipeline-module` |
| Small UI / bug / copy | `pipeline-patch` |
| Planning review | `egm-review` |

### Rules (always-on)

| Rule | Role |
|------|------|
| `00-m4trix-os` | Org, bootstrap, scale, EGM, `docs/sdlc` SoT |
| `01-production-bar` | Done = AC + states + security + docs + craft + honest verify |
| `02-mode-switching` | Ask / Plan / Agent / Debug after phases |
| `03-token-discipline` | Progressive context, soft budgets |
| `04-code-craft` | Think → simple → surgical → verify |
| `05-delivery-voice` | No IDE branding in product docs/commits/PRs |

---

## Scale & pipelines

| Scale | When | Ceremony |
|-------|------|----------|
| **product** | New app / large epic | PRD → FR/NFR → design → design system → **EGM** → sequenced backlog → you authorize **each** module |
| **module** | Coherent multi-file feature | Focused brief/FR; EGM when design-heavy; implement named slice only |
| **patch** | Localized UI / bug / copy | Short AC brief; one implementer; **skip EGM** and full PRD |

```text
request
   │
   ├── product ──► PRD → reqs → design → DS → EGM → BACKLOG → authorize modules
   ├── module  ──► brief/FR → (EGM if design-heavy) → implement named slice
   └── patch   ──► short AC → one implementer → skip EGM
```

Agents must **not** silently upgrade patch → module; you acknowledge scope growth.

---

## Elephant → Goldfish (EGM)

Inspired by [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) (Apache-2.0; not installed wholesale).

```text
Captain ──► Elephant (product / BA / architect / design-system)
                │
                ▼
         docs/sdlc/*  (self-contained; no chat dependency)
                │
Captain ──► Goldfish = fresh Task (listed paths only; no parent chat)
                │
                ▼
         EGM_REVIEW.md
                │
        ┌───────┴────────┐
   Blocking open      Clear
        │                │
   fix docs (or     findings only
   eligible risk-   (still ≠ approval)
   accept*)              │
        │                ▼
        └──────► Captain explicit go + named module/task
                         │
                         ▼
                    Implementer

* Missing requirements and unresolved security defects are not risk-acceptable.
```

Goldfish complete ≠ captain approval. Risk acceptance ≠ approval.

---

## Production bar & context

**Done only when all of these hold:**

- [ ] AC covered (happy / fail / edge)
- [ ] Loading / empty / error where the UI/API needs them
- [ ] Security considered; no placeholder secrets
- [ ] Design-system compliance for UI
- [ ] Craft rules satisfied
- [ ] Verifier reports what actually ran — no false “tests passed”

| Context layer | Role |
|---------------|------|
| `docs/sdlc/` | Source of truth after apply (not chat) |
| `ACTIVE_TASK.json` | Active slice, approvals, EGM, light memory |
| `HANDOFF.md` | Multi-agent essentials only — no new scope |
| Soft budgets | patch = task + files; module = relevant slices; product = phase docs as needed |

**Stack defaults (new work):** Flutter BLoC + GoRouter + M3 + theme catalog before screens; keep existing stacks; Firebase-first; Node/Python only with approval.

---

## Install & set up

### Prerequisites

1. **Cursor** installed and signed in  
2. **Git**  
3. **macOS:** `brew install powershell` then `pwsh -v`  
4. Clone anywhere — no fixed path default; optional `M4TRIX_KIT_ROOT`

### Step 1 — Clone

**Windows**

```powershell
cd E:\development
git clone <your-matrix-kit-remote> Matrix
cd Matrix
```

**macOS**

```bash
cd ~/Developer
git clone <your-matrix-kit-remote> Matrix
cd Matrix
```

### Step 2 — Install globals

`-Fresh` wipes prior **m4tr!x-managed** agents/skills/hooks/state, then installs from this clone. Unrelated Cursor hooks stay.

**Windows**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh
```

**macOS**

```bash
pwsh -NoProfile -File ./bootstrap/install-globals.ps1 -Fresh
```

Writes: `~/.cursor/agents/m4trix-*`, kit skills, `hooks/m4trix-*.ps1`, `~/.cursor/m4trix/kit.json` + `USER_RULES.md`, merged `hooks.json`. Also disables CLI commit/PR attribution in `cli-config.json` when present, and installs a kit-local `commit-msg` hook that strips IDE trailers.

Optional auto-apply on folder open (default **off**): add `-AutoApplyWorkspaces`.

### Step 3 — Paste User Rules + turn off Attribution

1. Cursor → **Customize → Rules** → paste full `~/.cursor/m4trix/USER_RULES.md` → save.  
2. Cursor → **Settings → Git & PRs → Attribution** → turn **off** commit and PR attribution (older builds: **Agent → Attribution**). This stops injected `Co-authored-by: Cursor` on agent commits.

### Step 4 — Reload Cursor

Hooks/agents load after reload. Projects do **not** auto-apply unless `-AutoApplyWorkspaces`.

### Step 5 — Apply to a project

Point at the **app** workspace. Prefer dry-run if `docs/sdlc` already exists.

**Windows**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File E:\development\Matrix\bootstrap\apply-to-workspace.ps1 `
  -Workspace "C:\path\to\your\app" -DryRun

powershell -NoProfile -ExecutionPolicy Bypass -File E:\development\Matrix\bootstrap\apply-to-workspace.ps1 `
  -Workspace "C:\path\to\your\app"
```

**macOS**

```bash
pwsh -NoProfile -File ~/Developer/Matrix/bootstrap/apply-to-workspace.ps1 \
  -Workspace "$HOME/path/to/your/app" -DryRun

pwsh -NoProfile -File ~/Developer/Matrix/bootstrap/apply-to-workspace.ps1 \
  -Workspace "$HOME/path/to/your/app"
```

Or ask for skill **bootstrap-org** in chat (still prefer dry-run when docs exist).

Apply copies `.cursor/` assets, seeds `docs/sdlc`, detects stacks additively, writes `.m4trix-kit.json`, and installs `.git/hooks/commit-msg` (when `.git` exists) to strip IDE attribution trailers.

### Step 6 — Smoke-test (optional)

```powershell
# Windows
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\smoke-tests.ps1

# macOS
pwsh -NoProfile -File ./bootstrap/smoke-tests.ps1
```

### Step 7 — Daily workflow

1. Open your **product** workspace in Cursor.  
2. State the ask; expect scale classification (product / module / patch).  
3. Follow every **`MODE SWITCH:`** line — switch mode when prompted and reply with the suggested phrase.  
4. For product/module: approve specs (and EGM outcomes) before implementation.  
5. Name the module/task to build; derived ideas go to `docs/sdlc/BACKLOG.md` only.  
6. Prefer a **new chat** per phase or module to keep context lean.

---

## Platforms

| Platform | Shell | Notes |
|----------|-------|--------|
| **Windows 10/11** | `powershell` 5.1+ | Primary path; ExecutionPolicy Bypass for kit scripts |
| **macOS** | `pwsh` | `brew install powershell` |
| **Linux** | `pwsh` | Cross-platform scripts; not first-class support |

Cursor home: `%USERPROFILE%\.cursor` (Windows) / `~/.cursor` (macOS/Linux). State: `~/.cursor/m4trix/kit.json`.

---

## Repository layout

```text
Matrix/                         ← kit root = clone path
├── VERSION
├── README.md                   ← this file
├── INSTALL.md                  ← shorter install cheat sheet
├── constitution/               USER_RULES + project-rules (+ stack rules)
├── agents/                     m4trix-*.md (12 specialists)
├── skills/                     bootstrap-org, pipelines, egm-review
├── templates/sdlc/             PRD, requirements, ACTIVE_TASK, …
├── ecc-cherry-pick/            adapted reference excerpts
├── bootstrap/                  MANIFEST, install-globals, apply-to-workspace, smoke-tests
├── hooks/                      platform + user hooks + hooks.json template
├── docs/sdlc/                  kit’s own SDLC / marker (when used as a workspace)
└── _pilot/                     smoke fixtures + behavior / EGM / craft / context evals
```

---

## Uninstall (globals only)

```powershell
# Windows
powershell -NoProfile -ExecutionPolicy Bypass -Command {
  . .\hooks\m4trix-platform.ps1
  Remove-M4trixManagedGlobals
}

# macOS
pwsh -NoProfile -Command {
  . ./hooks/m4trix-platform.ps1
  Remove-M4trixManagedGlobals
}
```

Remove pasted User Rules in Cursor if desired. Per-project `.cursor/` and `docs/sdlc/` stay for you to delete.

---

## Cutover from an old kit path

If you used a fixed path (e.g. `D:\cursor-org-kit`):

1. Install **this** clone with `-Fresh`  
2. Re-paste `~/.cursor/m4trix/USER_RULES.md`  
3. Re-apply to product workspaces (dry-run first)  
4. Stop using the old directory — **Matrix is the source of truth**

---

## More detail

| Doc | Contents |
|-----|----------|
| [`INSTALL.md`](INSTALL.md) | Condensed install / uninstall |
| [`constitution/USER_RULES.md`](constitution/USER_RULES.md) | Captain constitution (pre path-resolve) |
| [`bootstrap/MANIFEST.json`](bootstrap/MANIFEST.json) | Exact files applied per stack |
| [`_pilot/behavior_eval/evidence/REPORT.md`](_pilot/behavior_eval/evidence/REPORT.md) | Behavioral PASS report |
| [`_pilot/egm_eval/EVIDENCE.md`](_pilot/egm_eval/EVIDENCE.md) | EGM isolation evidence |
| [`ecc-cherry-pick/`](ecc-cherry-pick/) | Context / EGM / craft attributions |

---

**Captain owns product decisions. m4tr!x owns delivery discipline.**

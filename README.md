# m4tr!x — Cursor Org Kit (Matrix)

**m4tr!x** is a reusable Agile SDLC operating system for [Cursor](https://cursor.com). You are the **captain** (CEO). Specialist agents plan, clarify, design, implement, verify, and document. The kit turns Cursor from a smart chat window into a delivery org with gates, scale-matched ceremony, and a production bar — no mockups as “done.”

| | |
|--|--|
| **Version** | `1.5.1` (see `VERSION`) |
| **Kit root** | Wherever **this repo was cloned** (self-locating). Optional override: `M4TRIX_KIT_ROOT` |
| **Org** | m4tr!x |
| **Platforms** | **Windows** + **macOS** (PowerShell; Mac needs PowerShell Core / `pwsh`) |
| **Default stacks** | Flutter (BLoC + GoRouter + Material 3), Firebase-first; Node/Python only when approved |
| **Planning review** | Elephant→Goldfish (`egm-review`) for product / design-heavy modules; **patches skip** |

This repository **is** the kit. Clone it, install when you choose — nothing wires itself until you say so.

---

## Why m4tr!x (vs using Cursor alone)

Cursor is an excellent coding IDE with agents. Out of the box it does **not** enforce:

- who owns product decisions
- how much ceremony a one-line fix needs vs a new app
- when to stop and ask before inventing scope
- progressive context (so chats don’t drag the whole PRD into a padding tweak)
- a skeptical verifier that refuses rubber-stamp “done”
- isolated planning review before implementation

**m4tr!x adds that operating system on top of Cursor** — rules, agents, skills, SDLC templates, hooks, and pipelines — without replacing Cursor itself.

### Qualitative improvements

| Area | Vanilla Cursor | With m4tr!x |
|------|----------------|-------------|
| **Role** | You + one (or ad-hoc) agent | You = captain; named specialists (product, BA, architect, implementers, security, verifier, docs) |
| **Scope** | Easy to over-build or invent features | Clarify first; never invent product scope; park extras in `BACKLOG.md` |
| **Ceremony** | Same chat energy for toggle and epic | **product / module / patch** pipelines — match cost to size |
| **Approvals** | Soft or absent | Explicit gates; implement only the module/task you name |
| **Modes** | Easy to keep coding across phase boundaries | Forced **MODE SWITCH** prompts (Ask / Plan / Agent / Debug) |
| **Planning quality** | Spec and chat blur together | Elephant drafts self-contained `docs/sdlc/*`; **Goldfish** fresh Task reviews without the planning chat |
| **Patches** | Often pull full PRD / multi-agent swarm | Lightweight brief + surgical edit; **EGM skipped** |
| **Context** | Full-repo / full-history reread is common | Progressive load + `ACTIVE_TASK.json` + compact `HANDOFF.md` |
| **Craft** | Varies by prompt luck | Encoded: think → simple → surgical → verify; reuse before invent |
| **Done** | “Looks good” | Production bar: AC, tests or verified checks, error/empty/loading, security considered |
| **Delivery voice** | Easy to leak IDE branding into product commits/docs | Product artifacts stay tool-agnostic (kit docs may name Cursor) |
| **Models / cost** | Easy to pin expensive models everywhere | Prefer **Auto**; subagents `model: inherit` unless you order otherwise |
| **Install blast radius** | N/A | Explicit apply; dry-run; `-Fresh` only wipes **m4tr!x-managed** globals |

### Pilot evidence (honest benchmarks)

Comparable runs live under `_pilot/`. **Do not treat these as universal % token savings** — Cursor does not expose reliable in-agent token counts for these evals (`Tokens: N/A`).

| Eval | What was measured | Result (summary) |
|------|-------------------|------------------|
| **Behavior** (`_pilot/behavior_eval`) | Patch → reuse screens → API → bugfix; handoff; stale task memory | **PASS** on executed scenarios: surgical patch (0 handoffs), shared UI reused (single `AppHeader` / `AppInfoCard`), auth gate on API, verifier opened **5** files from HANDOFF (no full-repo rescan) |
| **EGM** (`_pilot/egm_eval`) | Product/module require Goldfish; patch skips; fresh Task isolation; incomplete-spec detection | **PASS** — Cursor Task does **not** inherit parent chat; Goldfish flagged missing AC / vague arch as Blocking |
| **Craft policy** (`_pilot/craft_scenarios`) | Expected behaviors for the five task shapes | Encoded in rules + smoke; live UI optional |
| **Context rubric** (`_pilot/context_eval`) | Tokens, tool calls, repeated reads, handoffs, rework | Rubric only — compare same task shapes over time; **no invented %** |

**Residual limits (documented in evidence):** progressive load / stale hints / handoff discipline rely on agent compliance (hooks do not hard-enforce them). Token metrics must come from Cursor’s usage UI outside the agent if you want numeric comparison.

---

## Platforms

| Platform | Shell | Notes |
|----------|-------|--------|
| **Windows 10/11** | Windows PowerShell 5.1+ (`powershell`) | Primary bootstrap path; ExecutionPolicy Bypass used for kit scripts |
| **macOS** | PowerShell Core (`pwsh`) | Install via Homebrew: `brew install powershell` |
| **Linux** | `pwsh` | Scripts are cross-platform PowerShell; not a first-class support claim — use macOS-style commands |

**Cursor home used by install:**

- Windows: `%USERPROFILE%\.cursor`
- macOS / Linux: `~/.cursor`

**Persisted kit state:** `~/.cursor/m4trix/kit.json` (+ generated `USER_RULES.md` for paste).

---

## What you get

### 1. Constitution (always-on behavior)

**User Rules** (paste once into Cursor **Customize → Rules**) plus per-project `.cursor/rules`:

| Rule | Role |
|------|------|
| `00-m4trix-os` | Captain / org, bootstrap policy, scale, EGM, `docs/sdlc` as source of truth |
| `01-production-bar` | Done = AC + states + security + docs + craft + verifier honesty |
| `02-mode-switching` | Ask / Plan / Agent / Debug gates after every phase |
| `03-token-discipline` | Progressive context, soft budgets by scale, handoff hygiene |
| `04-code-craft` | Think → simple → surgical → verify; reuse ladder |
| `05-delivery-voice` | No IDE/AI branding in product docs, commits, PRs |
| Stack rules | Flutter (+ reusability), Firebase, Node.js, Python — applied when stack detected |

### 2. Specialist agents (12× `m4trix-*`)

Installed to `~/.cursor/agents/` (globals) and copied into each project’s `.cursor/agents/` on apply.

| Agent | Job |
|-------|-----|
| `m4trix-product` | PRD, market framing, non-goals, risks |
| `m4trix-requirements` | FR/NFR with happy / fail / edge |
| `m4trix-architect` | `DESIGN.md`; Elephant or **Goldfish** reviewer |
| `m4trix-design-system` | Themes, catalog, motion → `DESIGN_SYSTEM.md` |
| `m4trix-scrum` | Scale detection, task sequencing, MODE SWITCH prompts |
| `m4trix-flutter` | Flutter implementer (BLoC / GoRouter defaults on new apps) |
| `m4trix-firebase` | Auth, Firestore, Functions, rules, sync proposals |
| `m4trix-node` | Approved custom Node/TypeScript backends |
| `m4trix-python` | Approved Python jobs / APIs / scripts |
| `m4trix-security` | Auth, PII, payments, rules, secrets — OWASP-minded |
| `m4trix-verifier` | Skeptical QA; never rubber-stamps |
| `m4trix-docs-deploy` | SDLC / handoff / late `DEPLOYMENT.md` (you still deploy) |

Subagents default to **`model: inherit`** (prefer Auto / Cost).

### 3. Skills (pipelines + bootstrap + EGM)

| Skill | When |
|-------|------|
| `bootstrap-org` | Detect stack, dry-run MANIFEST plan, apply kit into a workspace |
| `pipeline-product` | Greenfield app or large epic → full SDLC → EGM → backlog → stop |
| `pipeline-module` | Multi-file feature; EGM when upfront design matters |
| `pipeline-patch` | Small UI / bug / copy; no PRD swarm; **no EGM** |
| `egm-review` | Fresh isolated Goldfish Task against self-contained specs |

### 4. SDLC templates (`docs/sdlc/`)

Applied into each project (never silently overwrite customized docs without approval):

`PRD.md` · `REQUIREMENTS.md` · `DESIGN.md` · `DESIGN_SYSTEM.md` · `BACKLOG.md` · `TEST_PLAN.md` · `DEPLOYMENT.md` · `MODULE_HANDOFF.md` · `HANDOFF.md` · `EGM_REVIEW.md` · `ACTIVE_TASK.json` · `DECISIONS.md`

Marker file: `docs/sdlc/.m4trix-kit.json` (records kit version + `kitRoot`).

### 5. Hooks (opt-in behavior)

Merged into `~/.cursor/hooks.json` on globals install:

| Hook | Default behavior |
|------|------------------|
| `workspaceOpen` | Apply kit only if you installed with **`-AutoApplyWorkspaces`** (default **off**) |
| `sessionStart` | Reminder when workspace marker is missing; concise upgrade advisory when marker version is behind installed kit (never auto-upgrades) |

Scripts: `hooks/m4trix-*.ps1`. Unrelated Cursor hooks and `~/.cursor/skills-cursor/` are **not** touched. `beforeSubmitPrompt` is **not** registered (prior m4tr!x entries are stripped on install/uninstall).

### 6. ECC cherry-pick (adapted excerpts)

Optional reference material under `ecc-cherry-pick/` (context engineering, EGM notes, Karpathy-inspired craft, Flutter/Python/security/TDD/deploy checklists). Copied to `docs/sdlc/ecc-reference/` on apply when enabled by MANIFEST — **adapted excerpts only**, not a wholesale third-party install.

### 7. Validation & pilots

- `bootstrap/smoke-tests.ps1` — kit integrity / policy encoding checks  
- `_pilot/` — smoke fixtures, behavior eval, EGM eval, craft scenarios, context rubric  

---

## Feature deep dive

### Scale detection

Every request is classified before acting:

| Scale | Use | Ceremony |
|-------|-----|----------|
| **product** | New app / large epic | PRD → requirements → design → design system → **EGM** → sequenced backlog → captain authorizes **each** module |
| **module** | Coherent multi-file feature | Focused brief/FR; EGM when design-heavy; implement named slice only |
| **patch** | Localized UI/bug/copy | Short AC brief; one implementer; skip EGM and full PRD |

Agents must **not** silently upgrade patch → module; you acknowledge scope growth.

### Elephant → Goldfish (EGM)

Inspired by [google/elephant-goldfish-model](https://github.com/google/elephant-goldfish-model) (Apache-2.0 attribution; not installed wholesale).

1. **Elephant** (product / requirements / architect / design-system) writes specs that stand alone without the chat.  
2. **Goldfish** = fresh Cursor **Task** (`m4trix-architect`, optional security) with **no** parent chat — reads only listed paths.  
3. Findings → `EGM_REVIEW.md`; **Blocking** open ⇒ no implementation until fixed in docs, or (eligible implementation tradeoffs only) captain risk-accepted in writing. Missing requirements and unresolved security defects are **not** risk-acceptable.  
4. Goldfish complete ≠ captain approval. Risk acceptance ≠ approval. You still say go.

### Production bar

A module/task is not done until acceptance criteria (happy/fail/edge), real loading/empty/error where needed, security considered, no placeholder secrets, design-system compliance for UI, craft rules satisfied, and the verifier reports what actually ran — **no false “tests passed.”**

### Context & task memory

- Source of truth after apply: `docs/sdlc/` (not chat history).  
- Active slice: `ACTIVE_TASK.json` (approvals, EGM fields, lightweight memory, optional `staleAfterHours` **advisory**).  
- Multi-agent: compact `HANDOFF.md` — essentials only; handoff does not grant new scope.  
- Soft budgets: patch = task + touched files; module = relevant design/requirements slices; product = load phase docs as needed.

### Stack defaults (new work)

- **Flutter:** BLoC, GoRouter, Material 3 + design-system/theme catalog **before** screens; inspect shared widgets before creating duplicates.  
- **Existing stacks:** keep them — do not rewrite for fashion.  
- **BaaS:** Firebase-first; propose Node/Python only when needed; wait for approval.  
- **Mixed stacks** are additive (e.g. Flutter + Cloud Functions / Node is valid). Detection is additive via `bootstrap/MANIFEST.json`.

---

## Install & set up

### Prerequisites

1. **Cursor** installed and signed in.  
2. **Git** to clone this kit.  
3. **macOS only — PowerShell Core:**

```bash
brew install powershell
pwsh -v   # confirm
```

4. Decide a clone location (any path). There is **no** fixed `D:\cursor-org-kit` default anymore. Optional: set `M4TRIX_KIT_ROOT` to that path if you want an explicit override.

---

### Step 1 — Clone the kit

**Windows (PowerShell):**

```powershell
cd E:\development   # or wherever you keep kits
git clone <your-matrix-kit-remote> Matrix
cd Matrix
```

**macOS (Terminal / pwsh):**

```bash
cd ~/Developer     # or wherever you keep kits
git clone <your-matrix-kit-remote> Matrix
cd Matrix
```

Kit root = this clone directory (parent of `bootstrap/`).

---

### Step 2 — Install globals (account-wide)

Run **from the clone**. `-Fresh` removes prior **m4tr!x-managed** agents/skills/hooks/state, then installs clean from **this** clone. Unrelated Cursor hooks stay.

**Windows:**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh
```

**macOS:**

```bash
pwsh -NoProfile -File ./bootstrap/install-globals.ps1 -Fresh
```

**What gets installed:**

- `~/.cursor/agents/m4trix-*.md`
- `~/.cursor/skills/{bootstrap-org,pipeline-product,pipeline-module,pipeline-patch,egm-review}/`
- `~/.cursor/hooks/m4trix-*.ps1`
- `~/.cursor/m4trix/kit.json` (kit root + flags)
- `~/.cursor/m4trix/USER_RULES.md` (path-resolved paste source)
- Merged entries in `~/.cursor/hooks.json`

**Optional auto-apply on folder open** (default off — prefer explicit apply):

```powershell
# Windows
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh -AutoApplyWorkspaces

# macOS
pwsh -NoProfile -File ./bootstrap/install-globals.ps1 -Fresh -AutoApplyWorkspaces
```

---

### Step 3 — Paste User Rules into Cursor

1. Open Cursor → **Customize → Rules** (user rules).  
2. Paste the **full** contents of:

   - `~/.cursor/m4trix/USER_RULES.md` (preferred after install), or  
   - `constitution/USER_RULES.md` from the clone (paths may still show `{KIT_ROOT}` placeholders until install substitutes them).

3. Save.

Without User Rules, agents will not consistently treat you as captain or honor bootstrap/scale gates.

---

### Step 4 — Reload Cursor

Reload the window (or restart Cursor) so user hooks and agents load.

Opening a project does **not** auto-apply the kit unless you passed `-AutoApplyWorkspaces`.

---

### Step 5 — Apply the kit to a project

Point apply at the **app** workspace (not necessarily the kit clone).

**Prefer dry-run first** if the project already has `docs/sdlc`:

**Windows:**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File E:\development\Matrix\bootstrap\apply-to-workspace.ps1 `
  -Workspace "C:\path\to\your\app" -DryRun

powershell -NoProfile -ExecutionPolicy Bypass -File E:\development\Matrix\bootstrap\apply-to-workspace.ps1 `
  -Workspace "C:\path\to\your\app"
```

**macOS:**

```bash
pwsh -NoProfile -File ~/Developer/Matrix/bootstrap/apply-to-workspace.ps1 \
  -Workspace "$HOME/path/to/your/app" -DryRun

pwsh -NoProfile -File ~/Developer/Matrix/bootstrap/apply-to-workspace.ps1 \
  -Workspace "$HOME/path/to/your/app"
```

**Or in chat (after globals + User Rules):** ask the agent to run skill **bootstrap-org** / apply — still prefer dry-run when docs already exist.

**Apply does:**

- Copy rules / agents / skills into `.cursor/`
- Seed `docs/sdlc` templates (respect merge policy for customized docs)
- Detect stacks additively (Flutter, Firebase, Node, Python)
- Write `docs/sdlc/.m4trix-kit.json` with clone `kitRoot`

---

### Step 6 — Smoke-test the kit (optional but recommended)

From the **kit clone**:

```powershell
# Windows
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\smoke-tests.ps1

# macOS
pwsh -NoProfile -File ./bootstrap/smoke-tests.ps1
```

---

### Step 7 — Daily workflow

1. Open your **product** workspace in Cursor.  
2. State the ask; expect scale classification (product / module / patch).  
3. Follow every **`MODE SWITCH:`** line — switch Cursor mode when prompted and reply with the suggested phrase.  
4. For product/module: approve specs (and EGM outcomes) before implementation.  
5. Name the module/task to build; derived ideas go to `docs/sdlc/BACKLOG.md` only.  
6. Prefer a **new chat** per phase or module to keep context lean.

**Quick skill map:**

| You want… | Say / use |
|-----------|-----------|
| Full new app | `pipeline-product` |
| One feature | `pipeline-module` |
| Small fix | `pipeline-patch` |
| Planning review | `egm-review` (after specs exist) |
| Wire kit into a repo | `bootstrap-org` |

---

## Uninstall (globals only)

From the kit clone:

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

Then remove pasted User Rules in Cursor Settings if desired. Per-project `.cursor/` and `docs/sdlc/` are left for you to delete manually.

---

## Repository layout

```text
Matrix/                    ← kit root = clone path
  VERSION
  README.md                ← this file
  INSTALL.md               ← shorter install cheat sheet
  constitution/            USER_RULES + project-rules (+ stack rules)
  agents/                  m4trix-*.md (12 specialists)
  skills/                  bootstrap-org, pipelines, egm-review
  templates/sdlc/          PRD, requirements, ACTIVE_TASK, …
  ecc-cherry-pick/         adapted reference excerpts
  bootstrap/               MANIFEST, install-globals, apply-to-workspace, smoke-tests
  hooks/                   platform + user hooks + hooks.json template
  docs/sdlc/               kit’s own SDLC / marker (when used as a workspace)
  _pilot/                  smoke fixtures + behavior / EGM / craft / context evals
```

---

## Cutover from an old kit path

If you previously used a fixed path such as `D:\cursor-org-kit` or a Desktop copy:

1. Install **this** Matrix clone with `-Fresh`.  
2. Re-paste `~/.cursor/m4trix/USER_RULES.md`.  
3. Re-apply to active product workspaces (dry-run first).  
4. Stop using the old kit directory — **Matrix is the source of truth**.

---

## More detail

| Doc | Contents |
|-----|----------|
| [`INSTALL.md`](INSTALL.md) | Condensed install / uninstall |
| [`constitution/USER_RULES.md`](constitution/USER_RULES.md) | Captain-facing constitution (paste source before path resolve) |
| [`bootstrap/MANIFEST.json`](bootstrap/MANIFEST.json) | Exact files applied per stack |
| [`_pilot/behavior_eval/evidence/REPORT.md`](_pilot/behavior_eval/evidence/REPORT.md) | Behavioral PASS report |
| [`_pilot/egm_eval/EVIDENCE.md`](_pilot/egm_eval/EVIDENCE.md) | EGM isolation / incomplete-spec evidence |
| [`ecc-cherry-pick/`](ecc-cherry-pick/) | Context engineering, EGM, craft attributions |

---

**Captain owns product decisions. m4tr!x owns delivery discipline.**

# How m4tr!x works

Version **2.0.0**. This is a walkthrough of the kit in this repo: what it can do, how a request actually moves, and why the pieces are shaped the way they are.

The short version: **you are the captain. m4tr!x is a delivery org that lives inside Cursor.** It does not compile, deploy, or run your app. It shapes how agents plan, stop, build, and call something done.

---

## 1. What you are looking at

This clone **is** the kit. Nothing wires itself until you install globals and apply the kit to a project.

```text
You (captain)
    │  decide scope, approve specs, name what to build, run deploys
    ▼
Cursor chat
    │  User Rules + project rules are already in context
    ▼
Pipeline skill (product | module | patch)
    │  which phases, which gates, which agents
    ▼
Specialist agents
    │  write docs, code, or reviews — only inside the approved slice
    ▼
docs/sdlc/          source of truth after apply
ACTIVE_TASK.json    the one live slice
```

Three scales, matched to blast radius:

| Scale | Typical ask | Pipeline | Planning review (EGM) |
|-------|-------------|----------|------------------------|
| **product** | New app or large epic | `pipeline-product` | Required |
| **module** | One coherent multi-file feature | `pipeline-module` | When the slice needs real upfront design |
| **patch** | Localized UI, bug, or copy | `pipeline-patch` | Never |

Agents must not silently promote a patch into a module. If investigation shows a real product or architecture decision, they propose the upgrade and wait for you to acknowledge it.

---

## 2. Why it works

Cursor alone is a strong coding agent. It does not, by itself, keep ownership, ceremony, and “done” stable across chats. m4tr!x adds that discipline in layers. Most of it is **instructions the model is required to follow**. A few pieces are **scripts that actually run**.

### The failure modes it is built against

| Without the kit | What goes wrong | What the kit does |
|-----------------|-----------------|-------------------|
| One agent does everything | Planning bias leaks into the review of the plan | Separate roles; Goldfish is a fresh task with no parent chat |
| Same energy for a label and an epic | A toggle grows a PRD, or an epic is one-shotted | Three pipelines; product work stops per module |
| Chat is the spec | The next chat invents features or forgets constraints | `docs/sdlc/` is source of truth; chat is not |
| “Looks done” | Tests were not run; states are missing | Production bar + a skeptical verifier who reports what actually ran |
| Full history every turn | The model drowns in PRD and misses the files that matter | Progressive load, `ACTIVE_TASK.json`, compact `HANDOFF.md` |
| Easy to invent scope | Extra features appear mid-build | Clarify first; extras go only to `BACKLOG.md` |
| Agent self-approves | Build starts before you agreed | Explicit gates; Goldfish finished ≠ you approved |
| IDE trailers on commits | Product history shows an editor as a contributor | `commit-msg` hook strips them; CLI attribution is turned off |

### Why instructions are enough for most of this

Rules (`00`–`05`) are **always applied** in an applied workspace. User Rules are pasted once at account level and ride every chat. Skills are read when the request matches their description. Subagents are separate prompts with a narrow job and `model: inherit` (they use the same model as the parent, so you are not silently pinned to a more expensive model). Full model/reasoning policy lives in `docs/sdlc/DECISIONS.md` (Model policy) and on-demand `docs/sdlc/ecc-reference/model-policy.md`. Always-on byte budget is measured with `bootstrap/Measure-AlwaysOnBytes.ps1` against the T1 baseline in `_pilot/v2_baseline/` (CTX-001).

That is why the org can stay consistent without a custom runtime: the next agent sees the same constitution, the same SDLC files, and the same “stop and ask” lines.

### Why a few things are scripts

Model compliance is unreliable for several jobs, so those are mechanical:

1. **Do not install yourself.** `sessionStart` only *reminds*. Auto-apply on folder open is **off** unless you passed `-AutoApplyWorkspaces`.
2. **Do not brand commits with the editor.** The IDE can inject `Co-authored-by` trailers *after* the agent writes the message. Rules cannot block that injector. The git `commit-msg` hook strips known trailers. Install also sets CLI attribution flags to false when `cli-config.json` exists.
3. **Do not claim done with an invalid task state.** `bootstrap/guard/Invoke-CompletionGate.ps1` refuses `done`/`accepted` while Guard validators report `ok=false` (process gate — see `docs/sdlc/GUARD_BYPASS_MATRIX.md`).

Hooks do **not** hard-stop an agent that skips a planning gate or loads too much context. Pilot notes say that part still depends on the agent following the rules.

### v2.0 behaviour controls (scripts + skills)

| Control | What it does |
|---------|----------------|
| **Guard** | Shared validators under `bootstrap/guard/` (task-state, regression, recovery, routing, research, visual, completion, approval fingerprints) |
| **Regression Lock** | Multi-behaviour repairs record protected checks in `ACTIVE_TASK.regression` and re-verify them |
| **Recovery** | Skill `pipeline-recovery` + agent `m4trix-debugger` for repeated/uncertain failures (not a fourth scale) |
| **Routing** | Attributes in `ACTIVE_TASK.routing` → `Evaluate-Routing.ps1` → mandatory agents/skills/validators |
| **Research** | Skill `engineering-research` when unfamiliar/complex work needs persisted findings + sources |
| **Significant UI** | Agents `m4trix-ui-designer` + `m4trix-design-system`; honest `verificationEvidence.visualStatus` |
| **Migration fixtures** | `_pilot/v2_migration/` — REL-002 install/reapply/upgrade/SDLC-skip/kit-clone checks (isolated Cursor homes) |

### Decision order when goals conflict

From `04-code-craft`, in this order:

1. Correctness, security, approved scope
2. Existing architecture and patterns
3. Production readiness
4. Appropriate reuse
5. Simplicity
6. Token / execution cost

A shorter answer or a clever abstraction never outranks the approved slice or a security constraint. Soft context budgets never justify dropping approvals, AC, or security.

---

## 3. Two installs, on purpose

The kit is split so your machine and each app stay independent. There is **no** fixed path such as `D:\cursor-org-kit`. The clone you are in is the kit root.

Resolution order:

1. Environment variable `M4TRIX_KIT_ROOT`
2. `~/.cursor/m4trix/kit.json` → `kitRoot` (written by install)
3. Ask you where the clone lives

### Machine globals — once, only when you ask

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh
```

`-Fresh` deletes **previous m4tr!x-managed** globals, then installs from this clone. It does not touch unrelated Cursor skills or hooks.

| Written | Why |
|---------|-----|
| `~/.cursor/agents/m4trix-*.md` | Specialists available in any project |
| `~/.cursor/skills/{bootstrap-org,pipeline-*,egm-review,engineering-research}/` | Pipelines + research/recovery skills available in any project |
| `~/.cursor/hooks/m4trix-*.ps1` + merged `hooks.json` | Advisory hooks |
| `~/.cursor/m4trix/kit.json` | Remembers this clone, version, auto-apply flag |
| `~/.cursor/m4trix/USER_RULES.md` | Path-resolved constitution for you to paste |

You still paste User Rules into **Cursor → Customize → Rules**, turn **Git & PRs → Attribution** off, and reload Cursor. Globals do not apply the kit to a repo.

Install preflight checks sources and `hooks.json` **before** `-Fresh` deletes anything, so a bad hooks file does not leave you half-wiped. Merge backs up `hooks.json`, fails closed on malformed JSON, and keeps third-party hooks.

### Project apply — per app, only when you ask

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File <kitRoot>\bootstrap\apply-to-workspace.ps1 -Workspace "<app>" -DryRun
```

Then the same command without `-DryRun` after you accept the plan.

Apply (`bootstrap/MANIFEST.json` is the file list):

- Copies always-on rules `00`–`05` into `.cursor/rules`
- Copies the common agents and the five skills into `.cursor/`
- Detects stacks and **adds** matching rules and agents (Flutter does not suppress Node)
- Seeds `docs/sdlc/` templates
- Copies on-demand references into `docs/sdlc/ecc-reference/`
- Writes `docs/sdlc/.m4trix-kit.json` (version, time, kit root, detected stacks)
- If `.git` exists, installs `.git/hooks/commit-msg`

**Overwrite policy**

| Target | On re-apply |
|--------|-------------|
| `m4trix-*` rules, agents, skills | Overwritten (kit stays current) |
| `docs/sdlc` docs that already have real content | Skipped |
| Blank-looking templates | Replaced |
| The kit repo’s own `docs/sdlc` | Never overwritten |
| Marker `.m4trix-kit.json` | Rewritten |

Stack detection (any match includes that stack):

| Stack | Signals | Extra rules | Extra agent |
|-------|---------|-------------|-------------|
| Flutter | `pubspec.yaml`, `*.dart` | `stack-flutter`, `stack-flutter-reusability` | `m4trix-flutter` |
| Firebase | `firebase.json`, `.firebaserc`, `firestore.rules`, `firebase_options.dart` | `stack-firebase` | `m4trix-firebase` |
| Node | `package.json` at root or `functions/`, `backend/`, `api/`, `server/` | `stack-nodejs` | `m4trix-node` |
| Python | `requirements.txt`, `pyproject.toml`, `*.py` | `stack-python` | `m4trix-python` |

Common agents (every applied workspace): product, requirements, architect, design-system, scrum, verifier, security, docs-deploy, debugger, ui-designer.

Skill **bootstrap-org** is the chat wrapper around the same script: resolve kit root, dry-run, wait, apply, then hand you to the right pipeline. If the marker already exists it reports the installed version and stops unless you want a re-apply.

### Hooks (advisory)

| Hook | Behavior |
|------|----------|
| `sessionStart` | If the folder looks like a project and has no marker, inject a reminder: do not auto-install; here is the apply command. If the marker version is behind the installed kit, say upgrade is available and do **not** upgrade. |
| `workspaceOpen` | No-op unless `autoApplyWorkspaces` is true. Even then it skips the kit clone itself and any folder that already has a marker. |
| `beforeSubmitPrompt` | **Retired.** Install strips old m4tr!x entries. A no-op prompt hook added cost and did not validate anything. |

`sessionStart` treats a folder as a project if it has `pubspec.yaml`, `package.json`, `pyproject.toml`, `requirements.txt`, or `.git`.

---

## 4. What an agent actually sees

After apply, a chat in that workspace is loaded in this order of stickiness:

| Layer | When it loads | Job |
|-------|----------------|-----|
| User Rules | Every chat on the machine (after you paste them) | Constitution: captain, scale, gates, stack defaults, delivery voice |
| Rules `00`–`05` | Every turn in the workspace (`alwaysApply`) | OS, production bar, mode switch, tokens, craft, voice |
| Stack rules | When a matching file is in play (`globs`, not always-on) | Flutter / Firebase / Node / Python standards |
| Skill | When the request matches the skill description; the agent must read the file | The phase script for this scale |
| Agent prompt | When that specialist is used or spawned | One job, one output, a MODE SWITCH line |
| `docs/sdlc/*` | When the pipeline says to read them | Durable product truth |
| `ecc-reference/*` | On demand | Checklists. Not always-on, so a backend patch does not pay for UI craft |

That split is why the kit can stay strict without making every one-line fix reread the PRD and the UI essays.

### Context budgets (guidelines, not caps)

| Scale | Load |
|-------|------|
| Patch | The task, the files you will touch, theme tokens. Skip full PRD and full UI-craft review. |
| Module | `ACTIVE_TASK` plus the relevant DESIGN / REQUIREMENTS slices and feature paths |
| Product | The phase docs you need now — not the whole history every turn |

Load order: your request → approved scope / `ACTIVE_TASK.json` → conventions → decision pointers. Search before opening whole files. Expand only when correctness, security, reuse, or verification needs it.

`ACTIVE_TASK.context.staleAfterHours` defaults to 72. If the stamp is older, re-check scope and components before trusting the memory. **Never** treat an approval or a security constraint as stale.

### Handoffs

`HANDOFF.md` exists only when a second agent is actually required. It carries task, scope, paths, decision pointers, reuse, what was verified, and blockers. It does **not** grant approval or new scope. The next agent continues from that table and re-investigates only if evidence is missing, stale, or contradictory.

Prefer a **new chat per phase or module** so the planning transcript does not become the spec.

---

## 5. The three pipelines

Every phase ends with a line you can act on:

```text
**MODE SWITCH:** <Ask|Plan|Agent|Debug> — <why> — <exact phrase to type next>
```

Cursor does not switch Ask / Plan / Agent / Debug by itself. The line is the gate. Do not let implementation continue across a gate without your go-ahead in the matching mode.

| Situation | Mode |
|-----------|------|
| Research, questions, read-only | Ask |
| PRD, requirements, design, sequencing | Plan |
| Approved implementation | Agent |
| Hard runtime / flaky bugs | Debug |

### Product — `pipeline-product`

For a new application or a very large epic. Not for a UI tweak.

| Phase | Who | Stop condition |
|-------|-----|----------------|
| 0. Bootstrap check | whoever is in the chat | If the marker is missing, ask you before apply |
| 1. Lock PRD | `m4trix-product` | You say **Locked** |
| 2. FR / NFR | `m4trix-requirements` | Happy / fail / edge filled; you lock |
| 3. Design | `m4trix-architect` | `DESIGN.md` stands alone |
| 4. Design system | `m4trix-design-system` when there is UI | `DESIGN_SYSTEM.md` before feature screens |
| 5. EGM | fresh Goldfish via `egm-review` | Blocking findings closed; you still must approve |
| 6. Sequence | `m4trix-scrum` | Ordered backlog. **Do not build the app** |
| 7. One module | implementer → security if needed → verifier → docs | You name that module only |

Hard rules: no one-shot full app; EGM is required; review is not approval; every module meets the production bar.

`ACTIVE_TASK.egm.required=true` and `egm.status=pending` are set when the Elephant docs are drafted.

### Module — `pipeline-module`

A coherent feature: bigger than a patch, smaller than a new product.

1. Clarify (Ask).
2. Short FR/NFR with happy / fail / edge. Touch `DESIGN.md` only if architecture changes. Touch the design system only for new shared UI.
3. Spec must be readable by someone who never saw the chat.
4. EGM **if** the slice needs meaningful upfront design. One Goldfish (`m4trix-architect`). If it is a thin slice of a design you already approved, you may set `egm.required=false` explicitly.
5. Scrum sequences only if there is more than one task. You name what to build. Implement, verify, document.

UI modules load `ui-craft` and a proportional `ui-stress` pass. That is a reference load, not an extra phase.

### Patch — `pipeline-patch`

Small and localized. Example from the skill: replace a bottom sheet with an animated app-bar switch.

1. Ask only if the change is unclear.
2. Short brief: what changes, what does not, AC (happy / fail / edge), files likely touched.
3. **One** implementer. Surgical diff. No new services, no PRD, no abstraction for a label change. Reuse theme and components.
4. Focused check or a light verifier. Docs update only if user-facing behavior or a public API changed. Side ideas go to `BACKLOG.md`.

Set `egm.required=false` and `egm.status=skipped`. Do not load full UI-craft / UI-stress reviews for a copy or token tweak; spot-check the surface you touched. The touched surface is still production quality (real behavior, no placeholder path).

If the patch turns into an architecture or product decision, stop and propose `pipeline-module`.

---

## 6. Elephant → Goldfish (EGM)

Inspired by Google’s elephant-goldfish model. The upstream plugin is **not** installed. The idea is mapped onto files you already have.

**Elephant** is the planning agents in the current chat: product, requirements, architect, and design-system when there is UI. They write `docs/sdlc/*` so the spec does not depend on the chat. Assumptions, tradeoffs, and reuse notes go to `DECISIONS.md`.

**Goldfish** is a **new** Cursor Task (`resume` omitted, so it does not inherit the parent conversation). It receives only:

1. Absolute paths to the spec files
2. Code paths the spec explicitly references
3. The Goldfish checklist

Default Goldfish role is `m4trix-architect`. On a product plan, `m4trix-security` is a second Goldfish only when auth, PII, or payments are a material risk. If a fresh Task is unavailable, EGM **stops**. Nobody pretends the same chat is independent.

Goldfish classifies findings: **Blocking | Major | Minor | Observation**, with file/section evidence. It does not edit product code, invent scope, or approve implementation.

### What Blocking means

While any Blocking item is open, `egm.blockingOpen=true` and implementation does not start.

| Blocking class | Allowed resolution |
|----------------|--------------------|
| Missing or contradictory requirements; incomplete happy / fail / edge | Fix the Elephant docs. Not risk-acceptable. |
| Unresolved security defects (authz, PII, secrets, payment integrity) | Fix or redesign in the docs. Not risk-acceptable. |
| Implementation or architecture tradeoff (known limitation, deferred non-security work) | You may accept the risk **in writing** in `EGM_REVIEW.md` and `DECISIONS.md` |

Then you still explicitly approve implementation and name the module or task. Risk acceptance is not approval. Goldfish complete is not approval. Re-review only after a substantive spec change.

Status values: `skipped | pending | in_review | findings | resolved | blocked`.

Patches skip this entirely so a bugfix does not spawn a planning review.

---

## 7. The twelve specialists

Captain directs. Typical order: plan → design → implement → security / verify → docs. Every agent uses `model: inherit`.

### Plan

| Agent | May write | May not | Done when |
|-------|-----------|---------|-----------|
| `m4trix-product` | `PRD.md` only | Application code | Problem, audience, goals, non-goals, features, metrics, assumptions, risks. You say Locked. EGM is **not** run after PRD alone. |
| `m4trix-requirements` | `REQUIREMENTS.md` only | Application code; features that are not in the PRD | FR table with Happy / Fail / Edge, plus NFRs that apply (performance, security, offline, a11y, observability) |
| `m4trix-scrum` | `BACKLOG.md`, one `ACTIVE_TASK.json` | Scope expansion; starting the build | Each task has ID, title, depends-on, subtasks, AC, owner agent, permitted paths, shared-component allowance, `egm` fields. Stops until you name the build. |

Scrum will not sequence implementation while `egm.blockingOpen` is true.

### Design

| Agent | Job |
|-------|-----|
| `m4trix-architect` | Feasible design, **Firebase-first**. Custom Node or Python only with a justification written down. Elephant by default; Goldfish only when `egm-review` spawns a fresh Task. No feature code in this role. |
| `m4trix-design-system` | Theme and a small catalog of primitives **before** feature screens. Reuse existing widgets. Motion only when it has a purpose (state, spatial continuity, feedback, progress). Theme code waits for your Agent-mode approval. |

### Build

| Agent | When it runs | Standards |
|-------|----------------|-----------|
| `m4trix-flutter` | Dart/Flutter work | New apps: BLoC, GoRouter, Material 3, theme catalog before screens. Existing apps: keep their state management and router. Search shared UI before writing widgets. |
| `m4trix-firebase` | Auth, Firestore, Functions, rules, offline | **Propose → you approve → implement.** No speculative SDK wrappers. Security rules are part of the feature. |
| `m4trix-node` | Only after you and the architect approved a custom Node backend | TypeScript for greenfield. Validate at the edge. Env secrets. No Node architecture just because Flutter tooling has a `package.json`. |
| `m4trix-python` | Only after you approved Python (jobs, scripts, ML, APIs) | Small functions, pinned deps, `pytest` for critical logic, env secrets. |

Flutter reuse ladder (do not extract “just in case”):

1. Stock Material / library control plus the project theme
2. Existing shared widget (`lib/core/ui/` or the project’s equivalent)
3. If it is clearly app-wide (header, card shell, field, button, dialog), extract a small shared widget even on first use
4. Feature-only visuals stay in the feature folder until a second feature needs them
5. Small parameter sets — no “configurable everything” widget

Suggested layout for new apps: `lib/core/theme/`, `lib/core/ui/widgets/`, `lib/features/<feature>/presentation/`.

### Gates

| Agent | Job | Blocks “done”? |
|-------|-----|----------------|
| `m4trix-security` | Secrets, authn/authz, IDOR, Firebase rules, injection, XSS, unsafe deserialization, insecure offline storage, obvious dependency red flags. OWASP-minded. Smallest fix that closes the issue. | Critical / High until you accept the risk in writing |
| `m4trix-verifier` | Skeptical QA. Updates `ACTIVE_TASK` status / `verified` / `blockers` only — does not rewrite app code. | Report is **Passed** or **changes_requested**. Never rubber-stamps. |

Verifier checks, in order: scope vs `ACTIVE_TASK`, AC, whether checks **actually ran**, production bar, craft and reuse, drive-by edits, docs only when behavior changed, delivery voice, and (for UI) design-system fit plus proportional stress. Backend diffs skip UI craft files.

### Ship notes

`m4trix-docs-deploy` updates `MODULE_HANDOFF.md`, test evidence, and backlog derivatives. `DEPLOYMENT.md` is filled only when a release is in scope. **You execute deploys.** The agent does not push production.

---

## 8. Production bar — the definition of done

A task is not done until all of these hold:

- Acceptance criteria covered for happy, fail, and edge (tests, or an explicit manual check when the change is UI-only)
- Loading, empty, and error states where the UI or API surface needs them
- No placeholder secrets; no `TODO` as the only path for a claimed feature
- Security / authz considered (security agent when the change is sensitive)
- Relevant `docs/sdlc/` updated
- UI uses the project design system — no one-off colors or type unless you approved them
- Significant UI holds under plausible stress (long copy, overflow, reduced motion) in proportion to the change
- Motion is purposeful
- Craft rules: think, then the smallest clear implementation, surgical diff, then verify
- Verifier checklist passed, with an honest report of what ran

Mockups, stubs, and “wire it later” are backlog items.

UI craft (loaded only for UI work) adds: one primary action per region, tokens for spacing, cohesive surfaces, real states, accessible targets, and a motion gate. Frequent surfaces (tabs, core nav, anything used 100+ times a day) default to **no** animation. Reduced motion is honored. Do not copy web CSS recipes into Flutter.

UI stress (new screens and significant UI, not label patches) flags **Broken** (unreadable, unreachable, wrong), **Ugly** (readable but clearly wrong), and **Fragile** (one realistic step from failing). Identity text wraps; amounts, counts, and dates are not truncated.

---

## 9. File memory (`docs/sdlc`)

After apply, these files outrank chat history.

| File | Role |
|------|------|
| `PRD.md` | Problem, audience, goals, non-goals, features, risks |
| `REQUIREMENTS.md` | FR / NFR with happy, fail, edge |
| `DESIGN.md` | Architecture, data, Firebase vs custom backend |
| `DESIGN_SYSTEM.md` | Theme, catalog, motion policy |
| `DECISIONS.md` | Short log of **accepted** choices only (date, choice, reason) |
| `EGM_REVIEW.md` | Goldfish findings and how Elephant resolved them |
| `BACKLOG.md` | Ordered work and every idea that was **not** in scope |
| `ACTIVE_TASK.json` | The one live slice: scale, phase, AC, permitted paths, files changed, reusable components, what was verified, blockers, EGM block, approval stamp |
| `HANDOFF.md` | Compact pass between agents when a second agent is required |
| `TEST_PLAN.md` | What will be / was checked |
| `MODULE_HANDOFF.md` | Durable record of a finished module: changed, reused, verified |
| `DEPLOYMENT.md` | Late, and only when a release is in scope |
| `.m4trix-kit.json` | Marker: kit version, kit root, stacks. Not a product spec. |
| `ecc-reference/` | On-demand checklists (craft, security, Flutter, EGM, context). Not always applied. |

`ACTIVE_TASK.json` is memory for the slice, not a second PRD. Durable truth stays in the spec docs. Approval fields: `by` is captain, agents must not self-approve, EGM completion does not fill this in, handoffs do not fill this in. Before done, bind `approval.specFingerprint` / `scopeFingerprint` with `bootstrap/guard/Get-ApprovalFingerprints.ps1` (algorithm: `bootstrap/guard/lib/ApprovalFingerprint.ps1`). Stale hashes after a substantive spec or scope change invalidate approval until you re-approve. Critical/High security defects are not “passed” via risk-accept (VER-003).

Derived ideas — anything discovered while building that was not approved — go to `BACKLOG.md` only.

---

## 10. Stack defaults

| Situation | Rule |
|-----------|------|
| New Flutter app | BLoC (`flutter_bloc`), GoRouter, Material 3, design system before screens |
| Existing app | Keep its state management, router, and layout |
| Backend | Firebase-first. Auth, data model, offline, and Functions are proposed and wait for you |
| Node or Python | Only after written approval. Prefer them when Firebase is not enough (webhooks, custom APIs, jobs, ML) |
| Secrets | Env / proper client config. Never committed credentials |
| Flutter quality | Immutable state; `const` where practical; widgets as classes; no `BuildContext` use across an async gap without a check; bloc/widget tests for changed behavior; business logic out of widgets |

Firebase rule of three: propose options, wait, document the choice in `DESIGN.md`. Security rules ship with the feature. Offline sync must name a conflict strategy. Cloud Functions only when the client cannot do the job.

---

## 11. Delivery voice

Product history should read as the team’s work.

Do **not** put editor or AI-assistant branding in:

- Product README and docs that ship with the app
- `docs/sdlc` notes meant for repo history
- Commit messages and git trailers
- PR titles, bodies, release notes, changelogs

The kit’s **install / setup / constitution** docs may name Cursor, because that is how you run the kit. That exception does **not** cover commit messages, trailers, or PRs — including commits inside this kit repo.

After an agent commit: `git log -1 --format=%B` must show no IDE trailer. If one was injected and the commit is unpushed, `bootstrap/strip-ide-commit-trailers.ps1` rebuilds HEAD via `commit-tree` (a plain amend can be re-injected). If it is already pushed, stop and ask before any history rewrite.

Pass commit messages with `git commit -F <file>` when possible.

---

## 12. What the kit deliberately does not do

- It does not auto-bootstrap a repo because the marker is missing.
- It does not upgrade a workspace because the marker version is old.
- It does not install upstream ECC, Karpathy skills, the elephant-goldfish plugin, or Emil’s skill repo. It keeps short adaptations in `ecc-cherry-pick/`.
- It does not add a 13th agent for UI stress or animation review. Those are checklists on the design-system, Flutter, and verifier roles.
- It does not hard-enforce progressive context or gate compliance. Those are rules.
- It does not measure token savings inside the agent. Pilot reports do not invent percentages.
- It does not deploy. You do.
- It does not migrate an existing Flutter app to BLoC/GoRouter unless you ask.
- It does not let Node/Python agents run just because those files exist. Approval still gates custom backends. (Apply will still copy the stack agent in so it is available once you approve.)

---

## 13. A normal day

1. Open the **product** workspace (the app, not necessarily this kit clone).
2. State the ask in plain language.
3. Expect a scale call: product, module, or patch. Correct it if it is wrong.
4. Follow each `MODE SWITCH` line. Switch mode, then reply with the phrase it gives you.
5. For product and design-heavy modules: lock the spec, let Goldfish review, resolve Blocking items, then say go and **name** the module or task.
6. For a patch: approve the short AC brief and let one implementer work. EGM does not run.
7. Read the verifier report for what was actually executed.
8. Park anything new in `docs/sdlc/BACKLOG.md`.
9. Start a new chat for the next phase or module.

You own product decisions. The kit owns delivery discipline: who may write what, when they must stop, and what “done” means.

---

## 14. Where this behavior lives

Read these if you want the source of a rule rather than this summary.

| Topic | File |
|-------|------|
| Captain constitution (paste into User Rules) | `constitution/USER_RULES.md` |
| Always-on org, bar, modes, tokens, craft, voice | `constitution/project-rules/00`–`05` |
| Model policy (default Auto / inherit) | `docs/sdlc/DECISIONS.md` + `ecc-reference/model-policy.md` |
| Always-on byte measure | `bootstrap/Measure-AlwaysOnBytes.ps1` |
| Exact apply file list and stack detection | `bootstrap/MANIFEST.json` |
| Apply / install / smoke | `bootstrap/apply-to-workspace.ps1`, `install-globals.ps1`, `smoke-tests.ps1` |
| Hooks | `hooks/hooks.json`, `m4trix-session-start.ps1`, `m4trix-workspace-open.ps1` (advisory); deny candidates unregistered until live-verified |
| Completion gate | `bootstrap/guard/Invoke-CompletionGate.ps1` — always `task-state` + `completion` + `approval`; refuse done while Guard `ok=false`; see `docs/sdlc/GUARD_BYPASS_MATRIX.md` |
| Approval fingerprints | `bootstrap/guard/Get-ApprovalFingerprints.ps1` (+ `lib/ApprovalFingerprint.ps1`) — VER-002/004 bind; self-approve rejected |
| Routing calculate | `bootstrap/guard/Evaluate-Routing.ps1` + `templates/sdlc/routing-policy.json` |
| Migration / REL-002 | `_pilot/v2_migration/Invoke-Rel002Fixtures.ps1` (isolated `M4TRIX_CURSOR_HOME`) |
| Pipelines | `skills/pipeline-product`, `pipeline-module`, `pipeline-patch`, `pipeline-recovery`, `engineering-research`, `egm-review`, `bootstrap-org` |
| Specialists | `agents/m4trix-*.md` (includes debugger + ui-designer) |
| SDLC blanks | `templates/sdlc/` |
| On-demand references and upstream credit | `ecc-cherry-pick/ORIGIN.md` and the sibling files |
| Pilot evidence (behavior, EGM, UI craft) | `_pilot/` |
| Install cheat sheet | `INSTALL.md`, `README.md` |

`_pilot/` holds eval fixtures (behavior, EGM isolation, UI craft, mixed-stack smoke). Those trees are copies used to test the kit. The source of truth for behavior is `constitution/`, `agents/`, `skills/`, `bootstrap/`, and `templates/`.

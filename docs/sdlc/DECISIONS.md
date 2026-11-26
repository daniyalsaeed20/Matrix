# Decisions

Short log of **accepted** choices only. Date · choice · reason. Do not duplicate PRD/REQUIREMENTS/DESIGN.

| Date | Decision | Reason |
|------|----------|--------|
| 2026-11-12 | Matrix repo is the m4tr!x kit source of truth | Replace fixed `D:\cursor-org-kit` master; self-locate from clone + `~/.cursor/m4trix/kit.json` |
| 2026-11-12 | Install only on explicit captain command; `-Fresh` wipes prior m4trix globals | No silent machine wiring; clean cutover |
| 2026-11-12 | Auto-apply workspaces off by default | Per-project apply must be requested |
| 2026-11-12 | beforeSubmitPrompt emits only `continue` / `user_message` | Match current Cursor hook docs; use sessionStart for reminders |
| 2026-11-12 | Retire m4tr!x beforeSubmitPrompt registration | No-op `continue:true` added overhead without validation benefit; sessionStart covers advisories; install strips legacy entries |
| 2026-11-12 | hooks.json merge fails closed on malformed JSON + backup before write | Never silently replace user hooks; preserve all third-party properties |
| 2026-11-12 | sessionStart advises when project `.m4trix-kit.json` version is behind installed kit | Detect outdated workspaces without auto-upgrade |
| 2026-11-12 | EGM Blocking: missing requirements / security defects not risk-acceptable; implementation tradeoffs may be captain-accepted in writing | Reconcile template vs skill; captain approval still mandatory |
| 2026-11-12 | Ignore tracked `docs/sdlc/.m4trix-kit.json`; package-source excludes .git/caches/markers | Machine kitRoot is not portable repo config |
| 2026-11-12 | package-source enumerates with -Force + ZipFile API | Reliably include hidden `.cursor` trees on Windows |
| 2026-11-12 | Install/Fresh preflight validates sources + hooks.json before any managed mutation | Prevent partial Fresh cleanup on malformed hooks |
| 2026-11-12 | Preserve hooks.json top-level metadata; collision-resistant backups | Third-party config semantics + safe repeated installs |
| 2026-11-12 | `M4TRIX_CURSOR_HOME` override for isolated install tests | Smoke can prove fail-closed without touching real ~/.cursor |
| 2026-11-12 | Merge Karpathy four principles into `04-code-craft` (not a separate always-on rule) | Avoid token duplication; MIT attribution in ecc-cherry-pick |
| 2026-11-12 | Decision hierarchy: correctness/security/scope → architecture → production → reuse → simplicity → tokens | Resolve craft vs reuse vs ceremony conflicts |
| 2026-11-12 | Context engineering via expanded `03-token-discipline` + richer ACTIVE_TASK + compact HANDOFF | Progressive load/prune without new infra or always-on rule |
| 2026-11-12 | Soft context budgets by scale; no hard token caps | Never drop security/approvals/AC for a budget |
| 2026-11-12 | EGM via egm-review skill + pipelines; no 13th agent; patches skip | Fresh Task = Goldfish isolation on Cursor; Apache-2.0 attribution |
| 2026-11-12 | Delivery voice: no Cursor/IDE attribution in product docs, commits, PRs | Product repos stay team-branded; Matrix kit install docs may name the IDE |
| 2026-11-12 | Delivery voice covers kit commits too; strip IDE trailers via commit-msg + CLI attribution off | Injected `Co-authored-by: Cursor` still creates GitHub contributors; rules alone cannot block the injector |
| 2026-11-12 | Selective design-eng principles via on-demand `ui-craft` / `ui-stress` (emilkowalski/skills MIT); no new agents/skills | Improve UI quality without always-on token cost or process bloat; patches stay light |
| 2026-11-25 | M4TR!X v2.0 upgrade: extend v1.6.0; Recovery as skill not scale; max 2 new agents (debugger, ui-designer); research as skill; no LLM router; early minimal Guard (Task 2) + per-capability validators; isolated eval ≠ stable runtime ≠ source; metrics from Task 1; context always-on growth budget +25%; 16-task sequence; pilots before activation; no global install until Task 16 | Captain plan review refinements after field failures (regressions, loops, weak research/UI/routing/enforcement) |
| 2026-11-25 | Edit canonical kit sources during v2; do not Fresh-install unfinished v2; behavioural tests in separate eval workspace with project `.cursor` override | Keep installed 1.6.0 usable; avoid dual-tree accidental activation |
| 2026-11-25 | EGM Goldfish Blocking fixed: explicit RB-01…RB-10; debugger Must; Guard enforcement levels (preventive / completion-blocking / advisory); sibling eval workspace; ISO-002 no WIP Fresh; routing forward-declare; CTX-003 RC if metrics unavailable | Clear contradictions before captain lock |
| 2026-11-25 | Default T14 real-world pilots required before T15 RC; captain may defer T14 only in writing | Prevent instruction-only “success” without field evidence |
| 2026-11-25 | Captain `approve product spec for backlog` — PRD/REQUIREMENTS/DESIGN Locked; `docs/sdlc/V2_TASKS.md` is authoritative T1–T16 registry; debugger + ui-designer Must; T14 before T15; always-on +25% budget; next command `Start Task 1` only | Formal backlog sequencing after EGM |
| 2026-11-25 | T1 always-on byte baseline = 11043 (rules 00–05); +25% ceiling 13804 without DECISIONS exception; live eval labeled `isolation:unproven` until sibling fingerprint | Measured evidence in `_pilot/v2_baseline/` |
| 2026-11-25 | Captain `accept Task 1` — T1 accepted; T2 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 2` — Minimal Guard foundation in progress | Progression gate per V2_TASKS protocol |
| 2026-11-25 | T2 Guard: shared runner + result/evidence schemas + task-state validator + folder convention; PS 5.1 raw-JSON array checks | GRD-001 / NFR-001 / NFR-005; avoid plugin framework |
| 2026-11-25 | Captain `accept Task 2` — T2 accepted; T3 and T7 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 3` — Regression Lock in progress | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `accept Task 3` — T3 accepted; T4 ready; T7 still ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 4` / approve plan — Recovery + Debugger in progress; budgets patch 2 / module 3 / product-critical 3; EGM skipped (thin locked DESIGN slice) | Progression gate + REC-005 defaults |
| 2026-11-25 | T4 Recovery: Guard recovery validator + pipeline-recovery + m4trix-debugger; attempts[] cumulative; rejected reuse needs newEvidence; rename-only blocked | REC-001…006 / GRD-002 |
| 2026-11-25 | Captain `accept Task 4` — T4 accepted; T5 ready; T7 still ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 5` / approve plan — Intelligent routing in progress; EGM skipped (thin locked DESIGN slice); forward-declare research/ui-designer | Progression gate + RTE-001…004 |
| 2026-11-25 | T5 Routing: routing-policy.json + Evaluate-Routing + Guard routing validator; patch-minimal vs full attrs; deferred forward-declare; live ± Task evidence | RTE-001…004 / GRD-002 |
| 2026-11-25 | Captain `accept Task 5` — T5 accepted; T6 ready; T7 still ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 6` / approve plan — Engineering research in progress; EGM skipped (thin locked DESIGN slice); skill not permanent agent | Progression gate + RSH-001…004 |
| 2026-11-25 | T6 Research: engineering-research skill + Guard research validator; findings require alternatives; fabricated sources fail; scale alone ≠ gate | RSH-001…004 / GRD-002 |
| 2026-11-25 | Captain `accept Task 6` — T6 accepted; T7 ready; T8 still blocked on T7; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 7` — Solution proportionality in progress; EGM skipped (thin locked DESIGN SOL slice); no Guard proportionality validator in T7 (craft+verifier+pilot); no T8+ | Progression gate + SOL-001/002 / NFR-006 |
| 2026-11-25 | Captain `Approve plan T7 Solution Proportionality` — ladder in craft; verifier item 13; pipeline anti-promotion; proportionality_eval ±; no Guard proportionality validator | SOL-001/002 / NFR-006 |
| 2026-11-25 | T7 implement: Solution Escalation Ladder levels 1–4; significant-decision definition; `_pilot/proportionality_eval` script ± PASS; core always-on bytes 12015 ≤ 13804 | SOL-001/002 / EVAL-001 |
| 2026-11-25 | Captain `accept Task 7` — T7 accepted; T8 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 8` — UI/UX design intelligence in progress (planning); EGM skipped (thin locked DESIGN UI/UX flow steps 1–10 + UI-001…003); no T9+; plan not yet approved | Progression gate + UI-001…003 / RTE ui rows |
| 2026-11-25 | Captain `Approve plan T8 UI/UX design intelligence` — ship ui-designer; pipelines; routing promote; ui_designer_eval ±; no visualStatus (T9) | UI-001…003 / RTE |
| 2026-11-25 | T8 implement: `m4trix-ui-designer`; disposition; significant-UI routing mandatory; `_pilot/ui_designer_eval` script ± PASS; core always-on bytes 12151 ≤ 13804 | UI-001…003 / EVAL-001 |
| 2026-11-25 | Captain `accept Task 8` — T8 accepted; T9 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 9` — Visual and interaction verification in progress (planning); EGM skipped (thin locked DESIGN VIS-001/002 + visual validator row); no T10+; plan not yet approved | Progression gate + VIS-001/002 / GRD-002 / UI-003 |
| 2026-11-25 | Captain `Approve plan T9 Visual and interaction verification` — ship verificationEvidence + Guard visual; production-bar/verifier; defect gallery; visual_verify_eval ±; honest blocked; no fabricated renders; no T10 | VIS-001/002 / GRD-002 / UI-003 / EVAL-001 |
| 2026-11-25 | T9 implement: `visual.ps1`; verificationEvidence; routing significant-ui→visual; `_pilot/visual_verify_eval` ± PASS; core always-on bytes 12489 ≤ 13804; awaiting accept | VIS-001/002 / GRD-002 / EVAL-001 |
| 2026-11-25 | Captain `accept Task 9` — T9 accepted; T10 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 10` — Complete Guard + selective hooks in progress (planning); EGM skipped (thin locked DESIGN enforcement levels + GRD-003); no T11+; plan not yet approved | Progression gate + GRD-003 / RB-08 / NFR-001 / ISO-002 |
| 2026-11-25 | Captain `Approve plan T10 Complete Guard + selective hooks` — ship completion gate + completion validator; unregistered deny scripts; bypass matrix; ± eval; no default deny registration; no Fresh; no unbypassable claims | GRD-003 / RB-08 / EVAL-001 |
| 2026-11-25 | T10 implement: Invoke-CompletionGate + completion.ps1; pipelines/verifier wired; unregistered deny scripts; GUARD_BYPASS_MATRIX; guard_complete_eval ± PASS; core always-on bytes 12351 ≤ 13804; awaiting accept | GRD-003 / RB-08 / EVAL-001 |
| 2026-11-25 | Captain `accept Task 10` — T10 accepted; T11 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 11` — Independent verification / approval / security in progress (planning); EGM skipped (thin locked DESIGN fingerprints + VER-001…004); no T12+; plan not yet approved | Progression gate + VER-001…004 / RB-06 / RB-07 |
| 2026-11-25 | Captain `Approve plan T11 Independent verification, approval integrity, security-policy consistency` — ship approval fingerprints + Guard approval validator; Critical/High policy align; verifier independence; ± eval; no Fresh; no T12 | VER-001…004 / RB-06 / RB-07 / EVAL-001 |
| 2026-11-25 | T11 implement: ApprovalFingerprint + approval.ps1 always in CompletionGate; security/verifier VER-003 align; approval_fingerprint_eval ± PASS; core always-on bytes 12489 ≤ 13804; awaiting accept | VER-001…004 / RB-06 / RB-07 / EVAL-001 |
| 2026-11-25 | Captain `accept Task 11` — T11 accepted; T12 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 12` — Context / model policy / token optimisation in progress (planning); EGM skipped (thin locked DESIGN metrics + CTX-001…003); no T13+; plan not yet approved | Progression gate + CTX-001…003 / NFR-004 |
| 2026-11-25 | Captain `Approve plan T12 Context management, model policy, token optimisation` — audit+slim always-on; Measure-AlwaysOnBytes; model policy table; metrics template; context_token_eval ±; no new always-on rule files; no Fresh; no T13 | CTX-001…003 / NFR-004 / EVAL-001 |
| 2026-11-25 | T12 implement: Measure-AlwaysOnBytes + AUDIT; model policy DECISIONS/ecc; context_token_eval ± PASS; core always-on bytes 12480 ≤ 13804; awaiting accept | CTX-001…003 / NFR-004 / EVAL-001 |
| 2026-11-25 | Captain `accept Task 12` — T12 accepted; T13 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 13` — Comprehensive behavioural evaluation in progress (planning); EGM skipped (thin locked DESIGN T13 + EVAL-001 / REL-001 / RB-01…RB-10); no T14+; plan not yet approved | Progression gate + EVAL-001 / REL-001 / RB-* |
| 2026-11-25 | Captain `Approve plan T13 Comprehensive behavioural evaluation` — re-run T2–T12 suites + smoke; `_pilot/v2_eval` harness + integrated ±; RB-01…RB-10 checklist; park remediations as new IDs; no features; no Fresh; no T14 | EVAL-001 / REL-001 / RB-* |
| 2026-11-25 | T13 implement: `Invoke-V2IntegratedEval` all suites PASS; integrated ± PASS; always-on **12480** ≤ 13804; RB checklist drafted (RB-09→T15); awaiting accept | EVAL-001 / REL-001 / RB-* |
| 2026-11-25 | Captain `accept Task 13` — T13 accepted; T14 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-25 | Captain `Start Task 14` — Controlled real-world pilots; kit-first slice; EGM skipped (thin locked DESIGN T14 + EVAL-002); globals remain 1.6.0; no product-app touch until per-app auth | Progression gate + EVAL-002 / REL-001 |
| 2026-11-25 | Captain `Approve plan T14 Kit-side pilot scaffolding` — `_pilot/v2_real_pilots/` plan + templates only; no apps; no Fresh; no T15; field pilots deferred to second gate after `Authorize T14 pilots: …` | EVAL-002 |
| 2026-11-25 | T14 kit-first implement: `_pilot/v2_real_pilots/` scaffolding complete; awaiting per-app auth or written deferral; not accept-ready; no T15 | EVAL-002 |
| 2026-11-25 | Captain authorized T14 disposable synthetic pilot: create `_pilot/v2_real_pilots/apps/t14_disposable`, apply Matrix (no Fresh), bounded test + P4, delete app after; evidence retained; partial corpus (weaker than two real product apps); residual field risk documented | EVAL-002 |
| 2026-11-25 | Captain `Approve plan T14 Disposable pilot create-test-delete` — execute disposable create→test→delete slice | EVAL-002 |
| 2026-11-25 | T14 disposable implement: apply+analyze/test+P4 PASS; app deleted; evidence retained; partial synthetic corpus; awaiting accept (residual real-app field risk) | EVAL-002 |
| 2026-11-26 | Captain `Authorize T14 pilots: D:\rtmes_punjab\rtmes_punjab on pilot/t14-v2 — partial set; shapes=P4; compare-to-1.6.0=no; preserve-data=do not touch .env, Firebase prod, or unrelated dirty files` | EVAL-002 |
| 2026-11-26 | T14 rtmes_punjab implement: branch `pilot/t14-v2`; P4 agencyItemsFromJson JSON-list string + test PASS (`ab6154b`); main untouched; evidence under `_pilot/v2_real_pilots/`; awaiting accept | EVAL-002 |
| 2026-11-26 | Captain `accept Task 14` — T14 accepted with residual field risk (partial shapes=P4; one real app + disposable); T15 ready; no auto-start | Progression gate per V2_TASKS protocol |
| 2026-11-26 | Captain `Start Task 15` — Compatibility / migration / RC in progress; EGM skipped (thin locked DESIGN T15); REL-002 fixtures + docs + package RC; no Fresh on captain machine; no T16 | Progression gate + REL-002 / RB-09 / CTX-003 |
| 2026-11-26 | T15 implement complete awaiting accept: REL-002 38/38; smoke-t15 exit 0; `VERSION` 2.0.0; `dist/matrix-kit-2.0.0-src.zip`; RB-09 clear; Guard routing+regression ok; captain globals remain 1.6.0; no T16 | REL-002 / RB-09 / RB-10 / CTX-003 |
| 2026-11-26 | Captain `accept Task 15` — T15 accepted; completion gate ok; T16 remains blocked until written activation go; no auto-start; globals stay 1.6.0 | Progression gate per V2_TASKS protocol |
| 2026-11-26 | Captain `Activate globals 2.0.0 — globals only` — T16 in progress; limitations acknowledged (pilots/isolation/CTX-003/live evals/Guard process-gate); agent prepares checklist + git checkpoint only; captain executes Fresh; no product-app apply; freeze v2.0 after success | REL-001 / ISO-002 lift for T16 / T16 AC |

## Model policy

Optional captain override. Defaults apply unless the captain pins a model in writing.

| Role | Default | Override |
|------|---------|----------|
| Parent / captain chat | Prefer **Auto** (Cost when available) | Captain explicit pin |
| Subagents / fresh Task | `model: inherit` | Captain explicit order only |
| Forbidden | Silent frontier / expensive pins on subagents | — |

Detail (on-demand): `docs/sdlc/ecc-reference/model-policy.md`. Always-on keeps only the one-liners in `03-token-discipline` / USER_RULES.

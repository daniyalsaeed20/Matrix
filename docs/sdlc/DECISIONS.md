# Decisions

Short log of **accepted** choices only. Date · choice · reason. Do not duplicate PRD/REQUIREMENTS/DESIGN.

| Date | Decision | Reason |
|------|----------|--------|
| 2026-11-12 | Matrix repo is the m4tr!x kit source of truth | Replace fixed `D:\cursor-org-kit` master; self-locate from clone + `~/.cursor/m4trix/kit.json` |
| 2026-11-12 | Install only on explicit captain command; `-Fresh` wipes prior m4trix globals | No silent machine wiring; clean cutover |
| 2026-11-12 | Auto-apply workspaces off by default | Per-project apply must be requested |
| 2026-11-12 | beforeSubmitPrompt emits only `continue` / `user_message` | Match current Cursor hook docs; use sessionStart for reminders |
| 2026-11-12 | Merge Karpathy four principles into `04-code-craft` (not a separate always-on rule) | Avoid token duplication; MIT attribution in ecc-cherry-pick |
| 2026-11-12 | Decision hierarchy: correctness/security/scope → architecture → production → reuse → simplicity → tokens | Resolve craft vs reuse vs ceremony conflicts |
| 2026-11-12 | Context engineering via expanded `03-token-discipline` + richer ACTIVE_TASK + compact HANDOFF | Progressive load/prune without new infra or always-on rule |
| 2026-11-12 | Soft context budgets by scale; no hard token caps | Never drop security/approvals/AC for a budget |
| 2026-11-12 | EGM via egm-review skill + pipelines; no 13th agent; patches skip | Fresh Task = Goldfish isolation on Cursor; Apache-2.0 attribution |

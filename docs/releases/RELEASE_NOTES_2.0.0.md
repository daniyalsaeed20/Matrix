# m4tr!x v2.0.0 — release notes

Stable source release of the m4tr!x org kit. Adds Guard completion gates, regression/recovery, deterministic routing, engineering research, UI designer path, and REL-002 migration fixtures.

Machine globals cutover remains **Task 16** (captain runs `install-globals.ps1 -Fresh`). Publishing this tag does **not** activate globals by itself.

## Highlights

- **Guard** — validators + `Invoke-CompletionGate.ps1`; refuse done while `ok=false`
- **Recovery** — skill `pipeline-recovery` + agent `m4trix-debugger`; Regression Lock
- **Routing** — `Evaluate-Routing.ps1` / routing-policy → mandatory agents/skills/validators
- **Research** — skill `engineering-research` with persisted findings/sources
- **UI intelligence** — agent `m4trix-ui-designer`; significant-UI path + honest `visualStatus`
- **Migration** — `_pilot/v2_migration/` REL-002 fixtures (isolated Cursor homes)
- **Docs** — `HOW_MATRIX_WORKS.md`, `INSTALL.md`, `README.md` aligned to 2.0.0
- **Rollback** — retain `dist/matrix-kit-1.6.0-src.zip` (gitignored packaging; SHA256 in activation evidence)

## Limitations (honest)

- Incomplete real-world pilot coverage (T14 partial)
- `isolation:unproven`
- Token/cost comparison data unavailable (CTX-003) — do not invent % savings
- Incomplete live Cursor behavioural evaluations (BL-004)
- Guard = process gate (see `docs/sdlc/GUARD_BYPASS_MATRIX.md`)

## Install

From this tag or the attached source zip:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap\install-globals.ps1 -Fresh
```

Then paste `~/.cursor/m4trix/USER_RULES.md`, turn **off** Git/PR Attribution, reload Cursor, and apply to workspaces with DryRun first when `docs/sdlc` already exists.

Do **not** pass `-AutoApplyWorkspaces` unless you intend silent project apply on open.

## Verification

- `bootstrap/smoke-tests.ps1`
- `_pilot/v2_migration/Invoke-Rel002Fixtures.ps1`
- Packaging: `bootstrap/package-source.ps1` → `matrix-kit-2.0.0-src.zip`
- Activation checklist: `_pilot/v2_activation/ACTIVATION_CHECKLIST.md`

# m4tr!x Guard (Task 2+) + completion gate (Task 10) + approval fingerprints (Task 11)

Lightweight, deterministic validation substrate for ACTIVE_TASK and capability plugs, plus a **completion-blocking** process gate with approval fingerprint bind.

## Entrypoint (validators)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/Invoke-M4trixGuard.ps1 `
  -TaskPath docs/sdlc/ACTIVE_TASK.json
```

Optional:

- `-Validators task-state` (default) — file stems under `validators/`
- `-Validators task-state,regression,completion,approval` — add plugs by name
- `-GitBaseline <path>` — path must exist
- `-OutputPath <file.json>` — also write result to disk

## Approval fingerprints (T11 / VER-002)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/Get-ApprovalFingerprints.ps1 `
  -TaskPath docs/sdlc/ACTIVE_TASK.json
# optional: -WriteToTask
```

Algorithm lives in `lib/ApprovalFingerprint.ps1` (SHA256 of normalized UTF-8; fail closed — no formatting-only detector).

## Completion gate (mandatory before done/accepted)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/Invoke-CompletionGate.ps1 `
  -TaskPath docs/sdlc/ACTIVE_TASK.json
```

Always runs `task-state` + `completion` + `approval`, then auto-resolves capability validators from `ACTIVE_TASK` (routing.calculated / field presence). Exit `0` only when `ok=true`. Pipelines and verifier **must refuse** `status`/`phase` `done|accepted` when the gate fails.

Enforcement level: **Completion-blocking** (model + script process gate). Not an OS sandbox. Not unbypassable — see [docs/sdlc/GUARD_BYPASS_MATRIX.md](../../docs/sdlc/GUARD_BYPASS_MATRIX.md).

## Result schema

Documented in `schema/result.schema.json`:

```json
{
  "ok": true,
  "errors": [],
  "warnings": [],
  "checks": [{ "name": "task-state", "ok": true, "errors": [], "warnings": [] }],
  "taskPath": "...",
  "runner": "Invoke-M4trixGuard.ps1",
  "schemaVersion": "1.0.0"
}
```

Exit codes: `0` ok · `1` validation failed · `2` runner fault (fail closed).

## Evidence convention

See `schema/evidence.schema.json`. When `ACTIVE_TASK.evidence` is present it must include `commands`, `artifacts`, and `limitations` arrays. Completion claims (`status` or `phase` ∈ `done`|`accepted`) require evidence with at least one non-empty command or artifact. Empty `{}` evidence **fails**.

## Extensibility

Folder convention only: add `validators/<name>.ps1`. See `validators/README.md`. No plugin API beyond the shared check shape.

## Tests

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/tests/Invoke-GuardTests.ps1
```

## Selective hooks (honest)

Default kit `hooks/hooks.json` registers **advisory** `sessionStart` / `workspaceOpen` only. Deny-candidate scripts may exist under `hooks/` but are **not** registered until live-verified. Do not claim preventive enforcement for unverified events.

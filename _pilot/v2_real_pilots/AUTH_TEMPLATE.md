# T14 — Per-app authorization template

Agents must **not** read or write product app trees until the captain issues authorization in chat (or an equivalent written DECISIONS entry). Kit paths under `_pilot/v2_real_pilots/` do not require this template.

## Exact captain phrase

```text
Authorize T14 pilots: <absolute-path> on <branch-or-copy>
```

Optional trailing clauses (recommended):

```text
Authorize T14 pilots: <absolute-path> on <branch-or-copy>; compare-to-1.6.0=<yes|no>; preserve-data=<notes>
```

Issue **one phrase per app**. Default target corpus: **two** apps.

## Required fields

| Field | Meaning | Example |
|-------|---------|---------|
| `absolute-path` | Full path to the app workspace root | `E:\apps\MyFlutterApp` |
| `branch-or-copy` | Recoverable git branch name **or** absolute path to an isolated copy | `pilot/t14-v2` or `E:\apps\MyFlutterApp-pilot-copy` |
| `compare-to-1.6.0` | Whether to run the same task shape against v1.6.0 globals for side-by-side notes | `yes` (default when omitted if practical) / `no` |
| `preserve-data` | Any data/config that must not be touched | `do not reset Firestore emulator; leave .env alone` |

## Optional fields

| Field | Meaning |
|-------|---------|
| `shapes` | Subset of P1–P6 from PILOT_PLAN.md |
| `machine-globals` | Override only if not 1.6.0 (requires DECISIONS) |
| `notes` | Extra constraints (no network, no deploy, etc.) |

## Partial set

If only one app is authorized:

```text
Authorize T14 pilots: <path> on <branch-or-copy> — partial set
```

Record written scope in `docs/sdlc/DECISIONS.md` (T14 Edge).

## Deferral (eligible tradeoff)

To skip field pilots and accept residual risk before T15:

```text
Defer T14 real-world pilots — residual field risk accepted
```

Must be recorded in DECISIONS. Does **not** invent pilot pass evidence.

## Agent checklist after auth

1. Copy this auth into the app’s report header (`templates/APP_REPORT.md`).
2. Add the authorized path to `ACTIVE_TASK.permittedPaths` for the pilot execute slice only.
3. Confirm recoverable boundary exists before first edit.
4. Refuse work if path/branch does not match the authorization text.

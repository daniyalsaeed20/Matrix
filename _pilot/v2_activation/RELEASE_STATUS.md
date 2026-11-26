# M4TR!X v2.0.0 — release / activation status

**Source release:** **ready** — `VERSION` `2.0.0`, GitHub tag/release `v2.0.0`  
**Machine activation (T16):** **incomplete** — post-Fresh verify **FAIL** (globals still 1.6.0)  
**Date:** 2026-11-26  
**Scope:** Globals only (no automatic project apply)

## Implementation freeze

T1–T15 accepted. **Do not freeze v2.0.0 implementation** until T16 post-Fresh verify PASSes (source may still publish). After successful activation, further changes require observed field problems and new backlog IDs — not speculative expansion of this epic.

## Release artifacts (on disk; `dist/` gitignored)

| Artifact | Role |
|----------|------|
| `dist/matrix-kit-2.0.0-src.zip` | RC / release package |
| `dist/matrix-kit-1.6.0-src.zip` | Rollback package |
| `dist/ROLLBACK_2.0.0.md` | Rollback procedure |
| `dist/RC_LIMITATIONS_2.0.0.md` | Documented limitations |
| `dist/RELEASE_NOTES_2.0.0-RC.md` | RC notes |

Hashes: `_pilot/v2_activation/evidence/PACKAGE_INTEGRITY.json`

## Remaining limitations (accepted)

- Incomplete real-world pilot coverage (T14 partial)
- `isolation:unproven`
- Token/cost comparison data unavailable (CTX-003)
- Incomplete live Cursor behavioural evaluations (BL-004)
- Guard = process gate (see `docs/sdlc/GUARD_BYPASS_MATRIX.md`)

## Activation evidence

| Phase | Path |
|-------|------|
| Checklist | `_pilot/v2_activation/ACTIVATION_CHECKLIST.md` |
| Preflight | `_pilot/v2_activation/evidence/PREFLIGHT_RESULT.json` |
| Pre-backup | `_pilot/v2_activation/evidence/pre-activation-backup-*` |
| Post-verify | `_pilot/v2_activation/evidence/POST_FRESH_VERIFY.json` — **FAIL** |

## Rollback

Not required yet (machine still on 1.6.0). Procedure remains: `dist/ROLLBACK_2.0.0.md`.

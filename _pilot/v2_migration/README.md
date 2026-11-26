# v2 migration / REL-002 fixtures (T15)

Deterministic install, reapply, upgrade, SDLC-skip, and kit-clone safety checks for **RB-09**.

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\_pilot\v2_migration\Invoke-Rel002Fixtures.ps1
```

## Isolation

Every `install-globals` / `-Fresh` path sets `M4TRIX_CURSOR_HOME` to a temp directory.  
**Never** runs Fresh against the captain’s real `~/.cursor` (that is Task 16).

## Cases

| ID | Covers |
|----|--------|
| REL-002-FRESH | Fresh into empty isolated home |
| REL-002-FRESH-FAIL | Malformed `hooks.json` fail-closed |
| REL-002-REAPPLY | Reinstall without Fresh; third-party hooks; no dupe |
| REL-002-UPGRADE | Simulated 1.6.0 globals → current kit (no Fresh) |
| REL-002-UPGRADE-FRESH | Simulated 1.6.0 → Fresh current |
| REL-002-SDLC-SKIP | Customized non-empty SDLC docs skipped |
| REL-002-KIT-CLONE | Apply kit onto itself; kit SDLC preserved |
| REL-002-NO-SILENT | No silent auto-apply / real-home activation |

Evidence: `_pilot/v2_migration/evidence/RESULT.json`

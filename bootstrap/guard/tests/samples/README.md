# Guard sample outputs (Task 2)

Captured 2026-11-25 from `Invoke-M4trixGuard.ps1` against fixtures.

| File | Fixture | Expected |
|------|---------|----------|
| `valid-minimal.result.json` | `fixtures/valid-minimal.json` | `ok=true`, exit 0 |
| `invalid-empty-evidence.result.json` | `fixtures/invalid-empty-evidence.json` | `ok=false`, exit 1 |
| `invalid-not-json.result.json` | `fixtures/invalid-not-json.txt` | `ok=false`, exit 1 |

Regenerate:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/tests/Invoke-GuardTests.ps1
```

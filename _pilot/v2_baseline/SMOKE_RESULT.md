# Smoke result — v1.6.0 baseline

| Field | Value |
|-------|-------|
| Command | `powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/smoke-tests.ps1` |
| Measured at | 2026-11-25T10:56:45+05:00 (approx; see raw log) |
| Host | Windows |
| KitRoot | `E:\development\Matrix` |
| Exit code | **0** |
| Result line | `RESULT: all checks passed` |
| Raw log | `_smoke_raw.txt` |

## Notes from smoke (not failures)

- `NOTE  sessionStart live IDE chat injection: NOT automated (Cursor hooks fire in IDE sessions only)`
- `NOTE: macOS execution not claimed unless this run was on macOS/pwsh non-Windows.`
- Isolated install/Fresh negative tests used temp `M4TRIX_CURSOR_HOME` — **did not** mutate stable globals.

## Interpretation

Treat smoke green as the protected v1.6.0 script baseline for RB-10 / later regression. Do not “fix” kit behaviour under T1.

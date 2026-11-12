# Module handoff — EGM planning intelligence

**From:** 1.5.1 → **1.5.2**  
**Scope:** Final install/packaging reliability corrections; no new agents/pipelines; no customer app edits

## What changed

- `package-source` reliably includes hidden `.cursor` (+ inclusion smoke asserts)
- Install/Fresh preflight: malformed `hooks.json` or missing sources abort before managed mutations
- Top-level hooks.json metadata preserved; collision-resistant backups
- Isolated `M4TRIX_CURSOR_HOME` regression for install + Fresh fail-closed

## Verified

- `bootstrap/smoke-tests.ps1` PASS (Windows) including isolated malformed-hooks homes  
- Live IDE sessionStart injection: not automatable via Task (hook stdout + Cursor-like stdin covered)

## Limits

- macOS runtime not claimed unless executed on macOS  
- sessionStart IDE chat injection requires manual Cursor session check  



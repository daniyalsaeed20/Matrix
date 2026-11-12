# Module handoff — EGM planning intelligence

**From:** 1.5.0 → **1.5.1**  
**Scope:** Install/hooks reliability + EGM Blocking policy clarity; no new agents/pipelines; no customer app edits

## What changed

- Safe `hooks.json` merge (backup, fail on malformed, preserve third-party props, no duplicate m4trix hooks)
- `sessionStart` outdated-marker upgrade advisory (no auto-upgrade)
- `egm-review` included in Fresh/uninstall skill cleanup; retire no-op `beforeSubmitPrompt`
- EGM Blocking classes: requirements/security not risk-acceptable; tradeoffs captain-writable
- `.m4trix-kit.json` gitignored; `package-source.ps1` for clean source archives
- Smoke tests use platform shell launcher (no hard-coded Windows powershell invokes)

## Verified

- See smoke-test run notes in ACTIVE_TASK / release report  

## Limits

- Isolation depends on Cursor Task without `resume`  
- Blocking gate is process/ACTIVE_TASK — not a hard hook  
- macOS runtime not claimed unless executed on macOS  


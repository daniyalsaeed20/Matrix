# Proportionality eval fixture (T7)

Behavioural ± evaluation for Solution Escalation Ladder (SOL-001, SOL-002, NFR-006, EVAL-001).

No Guard proportionality validator in T7 — asserts craft + verifier + pipeline anti-promotion + fixture verdicts.

## What it proves

| Case | Expect |
|------|--------|
| Localized fix sufficient | PASS / chosen |
| Unjustified restructure | FAIL / reject |
| Justified shared extraction | PASS / allowed |
| Ordinary copy/token patch | PASS / no essay |

Also asserts: `04-code-craft` ladder present; verifier checklist item 13; pipeline anti-promotion phrases.

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/proportionality_eval/scripts/Invoke-ProportionalityEval.ps1
```

## Live prompts

See `LIVE_PROCEDURE.md`. Script content ± is the automated bar; live prompts document agent behaviour when captain runs them.

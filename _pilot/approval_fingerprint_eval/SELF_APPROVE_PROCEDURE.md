# Self-approve rejection procedure (T11 / VER-002)

Demonstrates that an agent cannot claim done by writing `approval.by` itself.

## Steps

1. Use fixture `bootstrap/guard/tests/fixtures/invalid-approval-self-approve.json` (`approval.by=agent`, fingerprints otherwise valid).
2. Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/Invoke-CompletionGate.ps1 `
  -TaskPath bootstrap/guard/tests/fixtures/invalid-approval-self-approve.json `
  -SkipAutoValidators
```

3. Expect non-zero exit and `ok=false` with error containing `approval.by must be 'captain'`.

## Pass criteria

Gate refuses. Agent prose claiming approval without captain `by` + fingerprints is incomplete under verifier checklist items 16–17.

## Automated

`scripts/Invoke-ApprovalFingerprintEval.ps1` runs this case and writes `evidence/gate-refuse-self-approve.json`.

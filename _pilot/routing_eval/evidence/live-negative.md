# Live routing negative (RTE-004)

**When:** 2026-11-25  
**Prompt intent:** Same auth/security attributes; deliberately omit m4trix-security; run Guard routing.

## Procedure executed in implementing session

1. Attributes: scale=module, taskType=auth, securityRisk=true (fixture `invalid-routing-omit-mandatory.json`).
2. `invoked` / `evidence` contain only `pipeline-module` — **no** m4trix-security Task/subagent.
3. Parent did **not** invent a claim-only “I acted as security” path for this negative (separate fixture covers impersonation).

## Guard result

```text
Invoke-M4trixGuard.ps1 -TaskPath bootstrap/guard/tests/fixtures/invalid-routing-omit-mandatory.json -Validators task-state,routing
→ ok=false (omit-mandatory)
```

Also confirmed via `Invoke-GuardTests.ps1` and `Invoke-RoutingEval.ps1`.

## Verdict

**PASS (negative)** — missing mandatory specialist fails validation; script-only green was not accepted as sufficient without this omit case.

# Guard validators (folder convention)

Drop-in scripts only. **No plugin framework.**

## Contract

1. File name: `bootstrap/guard/validators/<name>.ps1` (stem = validator name).
2. Invoked by `Invoke-M4trixGuard.ps1` with:
   - `-Task` — parsed ACTIVE_TASK object
   - `-TaskPath` — path to the JSON file
3. Must return **one** hashtable/object matching a Guard **check**:
   `{ name, ok, errors[], warnings[] }`
4. Prefer calling helpers from `../lib/GuardCommon.ps1` (`New-M4trixGuardCheck`).
5. Fail closed on bad input; do not throw past the runner if you can return `ok=false`.

## Built-in

| Name | Script | Role | Task |
|------|--------|------|------|
| `task-state` | `task-state.ps1` | Required ACTIVE_TASK fields, phase rules, evidence shape | T2 |
| `regression` | `regression.ps1` | baselineRev, behaviours inventory, protectedChecks, dirtyPaths, integrity | T3 |
| `recovery` | `recovery.ps1` | attemptBudget/attemptCount, rejectedApproaches, strategyDelta, escalation | T4 |
| `routing` | `routing.ps1` | attrs present; Evaluate-Routing recompute; mandatory ⊆ invoked evidence; parent claim rejected | T5 |
| `research` | `research.ps1` | if required / researchNeeded: findings+sources; alternatives; reject fabricated placeholders | T6 |
| `visual` | `visual.ps1` | significant UI: honest visualStatus; visually_verified needs real artifacts + non-static method; blocked/unverified need limitations | T9 |
| `completion` | `completion.ps1` | done/accepted: approval.at; egm.blockingOpen; recovery budget; filesChanged ⊆ permittedPaths; evidence | T10 |
| `approval` | `approval.ps1` | done/accepted: approval.by=captain; specFingerprint + scopeFingerprint match recomputed hashes; baselineRev when regression active | T11 |

Invoke with: `-Validators task-state,regression,recovery,routing,research,visual,completion,approval` (comma or repeated `-Validators` per name).

Completion-blocking wrapper: `bootstrap/guard/Invoke-CompletionGate.ps1` (always includes `task-state` + `completion` + `approval`).

Fingerprint CLI: `bootstrap/guard/Get-ApprovalFingerprints.ps1 -TaskPath docs/sdlc/ACTIVE_TASK.json` (optional `-WriteToTask`). Algorithm: `lib/ApprovalFingerprint.ps1` (SHA256 of normalized UTF-8; fail closed — no formatting-only detector).

Calculate (not a validator): `bootstrap/guard/Evaluate-Routing.ps1` + `templates/sdlc/routing-policy.json`.

## Notes

Drop-in validators share one result shape. Pipelines/verifier must invoke the completion gate before claiming done.

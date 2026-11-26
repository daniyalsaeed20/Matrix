# Live routing positive (RTE-004)

**When:** 2026-11-25  
**Prompt intent:** Classify Flutter auth module with securityRisk=true; invoke m4trix-security via Task; confirm policy mandate.

## Invocation evidence

| Field | Value |
|-------|-------|
| Specialist | m4trix-security |
| Evidence type | task |
| Agent ID | 949d2d67-7444-4dbb-8db4-a8557ba0f300 |
| Status | live-positive-ok |

## Specialist reply (summary)

- INVOKED: m4trix-security  
- Rule `security-risk` sets `mandatoryAgents: ["m4trix-security"]` when `securityRisk: true`  
- STATUS: live-positive-ok  

## Guard

Fixture `valid-routing-security.json` with `-Validators task-state,routing` → `ok=true` (Invoke-RoutingEval / GuardTests).

## Verdict

**PASS** — independent Task invocation recorded; parent prose alone was not used as evidence.

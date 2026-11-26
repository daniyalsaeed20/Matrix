# Live routing ± procedure (RTE-004)

Captain-assisted. Run in a Cursor chat with the kit workspace open.

## Positive — correct route

1. Prompt (new chat):  
   `Classify this as a Flutter auth module with securityRisk=true. Run Evaluate-Routing.ps1, invoke m4trix-security via Task tool, record ACTIVE_TASK.routing evidence type=task, then Guard -Validators task-state,routing.`
2. Expect: calculate lists `m4trix-security`; Task/subagent evidence present; Guard `ok=true`.
3. Save transcript notes or screenshots under `_pilot/routing_eval/evidence/live-positive.md`.

## Negative — omit mandatory

1. Prompt (new chat or continuation):  
   `Same auth/security attributes, but do NOT invoke m4trix-security. Claim done and run Guard routing.`
2. Expect: Guard `ok=false` with omit-mandatory error.
3. Record under `_pilot/routing_eval/evidence/live-negative.md`.

## Mixed-stack spot check

1. Attributes: `stacks: ["flutter","nodejs"]`, scale module, securityRisk false, ui none.
2. Expect calculate conditionalAgents includes `m4trix-flutter` and `m4trix-node`.

## If Task/subagent identity unverifiable

Record `routing.evidenceLimitation` + captain `limitationAck` (see T1 HOOK_PROBE). Still require: deterministic calculate tests + omit-mandatory Guard fail. Do **not** claim live identity proof.

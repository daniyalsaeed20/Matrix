# Guard bypass matrix (T10 / RB-08 / GRD-003)

Honest inventory of how Guard and hooks can be skipped. **Never claim unbypassable security.**

## Enforcement levels (reminder)

| Level | Mechanism | Effect |
|-------|-----------|--------|
| Preventive | Cursor deny hooks (`beforeShellExecution`, `preToolUse`, `subagentStart`) **only when live-verified** | Blocks specific tool/shell actions |
| Completion-blocking | `Invoke-CompletionGate.ps1` + pipelines/verifier refuse done while `ok=false` | Process gate (model + script) |
| Advisory | `sessionStart` / `workspaceOpen` | Reminders only |

## Bypass / limitation matrix

| Path | Level affected | Mandatory? | Status | Mitigation / documentation |
|------|----------------|------------|--------|----------------------------|
| Agent edits files via Write/StrReplace without running shell | Preventive shell hooks | N/A if hooks unregistered | Always possible | Completion gate still required before done; scope/`filesChanged` checked |
| Model ignores pipeline/verifier instructions and sets `status=done` without running gate | Completion-blocking | Yes for release process | Bypassable by non-compliant agent | Verifier checklist item 15; captain accept procedure; eval refuses ok=false |
| Hook event not fired / unsupported in local Cursor build | Preventive | No until verified | **unverified_in_this_environment** for deny candidates (T1/T10 probe) | Fallback: completion-blocking + this matrix; do not claim preventive |
| Hook script crash / timeout without `failClosed: true` | Preventive | If registered | Fail-open (platform default) | Prefer failClosed only where justified; document when used |
| Parent agent claims specialist ran without Task/subagent evidence | Completion / routing | Yes when routing present | Rejected by routing validator | Parent impersonation fixtures |
| Empty or missing evidence on done/accepted | Completion | Yes | Fail closed by task-state + completion | Negative fixtures |
| Missing `approval.at` on done/accepted | Completion | Yes | Fail closed | Negative fixture |
| `approval.by` not `captain` (self-approve) | Approval (T11) | Yes | Fail closed | `invalid-approval-self-approve` fixture |
| Missing / stale `specFingerprint` or `scopeFingerprint` | Approval (T11) | Yes | Fail closed | stale-spec / scope-change / missing-fp fixtures |
| Critical/High treated as “passed” via risk-accept | Policy (VER-003) | Yes | Process / verifier | Agents + EGM Blocking policy; not a crypto gate |
| `egm.blockingOpen=true` on done/accepted | Completion | Yes when EGM required path | Fail closed | Negative fixture |
| Recovery over budget without escalation.reported | Completion | When recovery active | Fail closed | Negative fixture |
| `filesChanged` outside `permittedPaths` | Completion | Yes when claiming done with changes | Fail closed | Negative fixture |
| Undocumented silent skip of mandatory validators | All | Yes (RB-08) | **Release blocker** if found | Keep this matrix complete; no silent holes |
| `install-globals -Fresh` during T1–15 | Policy / selective shell | Forbidden (ISO-002) | Script candidate `m4trix-before-shell.ps1` (unregistered by default) | Captain override only; no WIP Fresh |

## Default kit registration

`hooks/hooks.json` registers **only**:

- `workspaceOpen` → `m4trix-workspace-open.ps1` (advisory)
- `sessionStart` → `m4trix-session-start.ps1` (advisory)

Scripts present but **not** registered until live-verified:

- `m4trix-before-shell.ps1`
- `m4trix-pre-tool-use.ps1`
- `m4trix-subagent-start.ps1`

## Gate command

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/guard/Invoke-CompletionGate.ps1 `
  -TaskPath docs/sdlc/ACTIVE_TASK.json
```

## Related

- DESIGN §Complete Guard
- REQUIREMENTS GRD-003, RB-08
- `_pilot/v2_baseline/HOOK_PROBE.json`
- `_pilot/guard_complete_eval/`

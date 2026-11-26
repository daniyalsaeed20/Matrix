# Metrics protocol (Task 1)

**Kit baseline version:** 1.6.0  
**Authority:** CTX-002, CTX-003, NFR-007, DESIGN §Metrics  

## Goals

1. Compare later v2 capability work to a frozen v1.6.0 baseline without inventing improvement percentages.
2. Keep always-on project-rules growth measurable (≤ baseline + 25% without DECISIONS exception).
3. Mark unavailable primary cost metrics honestly (`unavailable`) so RC can proceed under CTX-003.

## Always-on byte budget

- **Measure script:** `bootstrap/Measure-AlwaysOnBytes.ps1` (UTF-8 file size / bytes on disk of `00-*.mdc` through `05-*.mdc`).
- **Authoritative frozen baseline:** `ALWAYS_ON_BYTES.json` → `totals.alwaysOnCoreBytes` (T1; do not overwrite).
- **Ceiling without exception:** `totals.budgetCeilingPlus25Core` (T1: **11043 → 13804**).
- **Stack rules** (`stack-*.mdc`) are recorded separately; they are conditional by stack detect and are **not** the CTX-001 growth numerator unless DECISIONS says otherwise.
- Re-measure after any always-on edit (especially T12). Write live results to an evidence path via `-OutputPath`; never replace the frozen baseline JSON.
- Example:
  ```powershell
  powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/Measure-AlwaysOnBytes.ps1 -FailAboveCeiling -OutputPath _pilot/context_token_eval/evidence/ALWAYS_ON_LIVE.json
  ```

## Per-eval run record (template)

Copy into each capability eval evidence folder:

```json
{
  "taskId": "T?",
  "kitSourceVersion": "1.6.0|WIP",
  "isolation": "proven|unproven",
  "measuredAt": "ISO-8601",
  "metrics": {
    "inputOutputTokens": "number|unavailable",
    "tokenUnavailableReason": "string|null",
    "toolCallCount": "number|unavailable",
    "repeatedFullFileReads": "number|unavailable",
    "agentHandoffs": "number",
    "reworkCycles": "number",
    "wallClockMinutes": "number|unavailable",
    "testsExecuted": ["command → exit"],
    "alwaysOnCoreBytes": "number|n/a"
  },
  "notes": ""
}
```

## Primary vs secondary

| Metric | Class | If missing |
|--------|-------|------------|
| Input/output tokens / cost | Primary (CTX-003) | `unavailable` + reason; do not fabricate % |
| Tool calls / re-reads / handoffs | Secondary | Count from transcript when practical |
| Always-on bytes | Secondary (required for T12 gate) | Re-run byte measure |
| Smoke / Guard / fixture pass-fail | Capability evidence | Record exit codes |

## Comparison rules

- Same task shape → compare to prior recorded run of that shape.
- Never invent “X% fewer tokens” without both sides measured.
- Under `isolation:unproven`, do not claim “live v2-only behaviour proven.”

## Captains / agents

Capture metrics when the eval runs. If Cursor UI does not expose tokens for the session, write `unavailable` and continue.

# Baseline report — M4TR!X v1.6.0 (Task 1)

| Field | Value |
|-------|-------|
| Task | T1 |
| Measured | 2026-11-25 |
| Kit VERSION file | **1.6.0** |
| Installed runtime | **1.6.0** (`~/.cursor/m4trix/kit.json`, installedAt 2026-11-12) |
| Kit root | `E:\development\Matrix` |
| Production behaviour changed? | **No** |

## Acceptance checklist

| AC | Result |
|----|--------|
| Baseline report exists | **PASS** — this file |
| Smoke result recorded | **PASS** — exit 0; `SMOKE_RESULT.md` + `_smoke_raw.txt` |
| Isolation fingerprint or `isolation:unproven` | **PASS** — verdict **`isolation:unproven`**; procedure documented |
| Metrics protocol + byte baseline | **PASS** — `METRICS_PROTOCOL.md`; core **11043** bytes; +25% ceiling **13804** |
| Hook probe recorded | **PASS** — `HOOK_PROBE.json`; Cursor app **3.31.15** |
| No production “fixes” claimed | **PASS** — measure/document only |

## Always-on byte baseline (authoritative)

| Metric | Bytes |
|--------|-------|
| alwaysOnCoreBytes (00–05) | **11043** |
| stackRulesBytes | 4560 |
| allProjectRulesBytes | 15603 |
| Ceiling core +25% | **13804** |

Source: `ALWAYS_ON_BYTES.json`.

## Runtime inventory (summary)

- Globals: 12 `m4trix-*` agents; 5 managed skills; hooks events `sessionStart`, `workspaceOpen` only.
- User hooks.json version 1; matches kit shipped events for m4trix-managed advisory hooks.
- Project rules applied under workspace `.cursor/rules` (not `~/.cursor/rules`).

## Isolation verdict

**`isolation:unproven`**

- Sibling path `E:\development\Matrix-v2-eval` does not exist.
- Agent/skill SHA256: kit source ≡ installed globals (12/12 agents, 5/5 skills) — inventory only; does not prove project override.
- Nested `_pilot/m4trix_kit_smoke/.cursor` exists and currently matches the same hashes — cannot prove override without a divergent marker + separate window (see `ISOLATION_PROCEDURE.md`).

Fallback: scripts + captain procedures; no claim of live v2-only behaviour.

## Hook probe (summary)

| Class | Events | Local status |
|-------|--------|--------------|
| Kit shipped / installed | `sessionStart`, `workspaceOpen` | Present (advisory) |
| Docs-advertised (incl. deny candidates) | `beforeShellExecution`, `preToolUse`, `subagentStart`, plus many observe hooks | Documented by Cursor hooks docs; **not live-fired** in T1 |
| Cursor desktop | 3.31.15 | Observed via local `package.json` |

Implication for T10: do not claim preventive enforcement until live-verified in captain-approved sibling eval hooks.

## Known failures

See `KNOWN_FAILURES.md`. Notable: token metrics often `unavailable`; sessionStart IDE injection not automated; visual UI inspection not CI.

## Commands / exit codes

```text
powershell -NoProfile -ExecutionPolicy Bypass -File bootstrap/smoke-tests.ps1
→ EXIT_CODE=0
```

Byte measure and fingerprint scripts: ad-hoc PowerShell in T1 session; outputs stored as JSON beside this report.

## Handoff for T2+

- Baseline paths: `_pilot/v2_baseline/`
- Byte baseline: **11043** (ceiling **13804**)
- Isolation: **`isolation:unproven`**
- Hook probe: advisory events only verified by presence; deny events **unverified_in_this_environment**

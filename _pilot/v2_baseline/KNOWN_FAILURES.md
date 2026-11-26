# Known failures / limitations inventory (honest)

Frozen as of Task 1. These are **baseline facts**, not items to silently fix under T1.

## Script / install

| ID | Item | Status | Source |
|----|------|--------|--------|
| KF-01 | sessionStart live IDE chat injection not automated in smoke | Limitation (by design) | smoke NOTE |
| KF-02 | macOS smoke not claimed on this Windows run | Limitation | smoke NOTE |
| KF-03 | Sibling eval workspace missing; ISO-001 live override unproven | `isolation:unproven` | ISOLATION_* |
| KF-04 | Preventive hook events (`beforeShellExecution`, `preToolUse`, `subagentStart`) not live-fired locally | Unverified | HOOK_PROBE.json |
| KF-05 | Global `~/.cursor/rules` absent; project rules live under workspace `.cursor/rules` | Inventory fact | fingerprint |
| KF-06 | Primary token/cost metrics often unavailable from Cursor agent session | `unavailable` expected | behavior_eval REPORT; CTX-003 |

## Existing pilot evidence (as-is)

| Pilot | Kit noted | Summary |
|-------|-----------|---------|
| `_pilot/behavior_eval` | 1.4.0 report header | Scenarios S1–S5 PASS; tokens N/A |
| `_pilot/egm_eval` | — | Scenarios 1–9 PASS (mix of smoke/static/live Task) |
| `_pilot/ui_craft_eval` | 1.6.0 | flutter test 9 PASS; visual inspection not run in CI |
| `_pilot/craft_scenarios` | policy fixture | Smoke encodes expectations; live optional |
| `_pilot/context_eval` | rubric | Manual metric sheet; no fabricated % |

## Soft / incomplete areas (not claimed fixed)

- Visual pixel inspection for UI craft is manual / deferred (ui_craft_eval).
- Several EGM scenarios are policy-encoded PASS without a full live resolve cycle (egm_eval #6–8).
- Nested pilot `.cursor` trees currently match globals/source hashes — cannot distinguish override vs identical copy without a deliberate marker + separate window.

## Rule for later tasks

Do **not** erase or rewrite these as “already fixed” unless a later accepted task produces new evidence. Remediation uses new task IDs.

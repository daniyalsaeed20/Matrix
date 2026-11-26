# Isolation procedure (ISO-001)

## Three environments

| Environment | Mechanism | T1 status |
|-------------|-----------|-----------|
| Stable runtime | `~/.cursor` m4trix **1.6.0** | Present; inventory in `RUNTIME_INVENTORY.json` |
| Canonical source | Matrix kit clone | `E:\development\Matrix` VERSION 1.6.0 |
| Eval workspace | **True sibling** folder, **separate** Cursor window | Sibling `E:\development\Matrix-v2-eval` **does not exist** yet |

## Forbidden until Task 16

- `install-globals -Fresh` from WIP v2 sources
- Apply unfinished v2 to unrelated apps

## Sibling fingerprint (how to prove)

1. Captain creates sibling folder (example): `E:\development\Matrix-v2-eval` — **not** nested under the kit tree.
2. Open that folder alone in a **new** Cursor window (not multi-root with Matrix).
3. Apply kit sources into that workspace only (`apply-to-workspace` when captain authorizes for eval).
4. Plant a **deliberately unique** marker in project `.cursor/agents` (or rules) that differs from globals.
5. In that window, have an agent resolve/read the specialist file and record the loaded path + content hash.
6. Confirm the loaded hash matches the **project** marker, not the global file.
7. Record result into `ISOLATION_FINGERPRINT.json` and flip verdict to `isolation:proven` only then.

## Nested pilots

`_pilot/*/ .cursor` trees exist for smoke/fixtures. DESIGN: do **not** use nested pilots as the primary live-eval workspace unless a fingerprint proves nested discovery is safe. T1 does **not** claim that proof.

## Fallback (current)

Label all live behavioural claims: **`isolation:unproven`**.  
Acceptable evidence remains: deterministic scripts, static inventory, and captain procedures.

# Context-efficiency evaluation

Lightweight rubric for comparable tasks (same shapes as craft scenarios).

## Task shapes

1. Small UI patch  
2. New Flutter screen (app bar + cards)  
3. Follow-up screen (reuse)  
4. Simple backend endpoint  
5. Focused bug fix  

## Record per run (manual or chat notes)

| Metric | How | Notes |
|--------|-----|-------|
| Input/output tokens | Cursor usage UI if available | If unavailable, write **N/A — Cursor does not expose reliably here** |
| Tool calls | Count in transcript | Prefer fewer repeated file reads |
| Repeated full-file reads | Count | Should trend down with progressive load |
| Agent handoffs | Count | 0 for trivial patches |
| Rework cycles | Count verifier→fix loops | |
| AC / tests | Pass/fail + what ran | |
| Component reuse | Hit/miss vs existing shared UI | |
| Quality | Verifier pass? | |

## Baseline

Compare against a prior run of the **same** task shape when notes exist.  
**Do not invent % savings** without recorded numbers.

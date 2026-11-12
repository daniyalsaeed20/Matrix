# Decisions

| Date | Decision | Reason |
|------|----------|--------|
| 2026-11-12 | Temp fixture for m4tr!x v1.4.0 behavioral eval only | Isolated under `_pilot/behavior_eval` |
| 2026-11-12 | Theme seed `0xFF1B4D3E`; shared UI under `lib/core/ui/widgets` when justified | Match kit reuse ladder |
| 2026-11-12 | Backend: Node `http` + shared validate helper; no Express | Minimal deps for fixture |
| 2026-11-12 | Auth: endpoints require `x-api-key` header | Security gate for scenario 4 |

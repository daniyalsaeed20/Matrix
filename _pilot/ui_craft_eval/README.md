# UI craft eval (isolated)

Safe fixtures for the Design Engineering Intelligence upgrade. **Not** a customer project.

Validates that kit guidance produces: design-system usage, reuse, stress-resistant layout, motion restraint, and light patch ceremony.

## Scenarios

| # | Scenario | How verified |
|---|----------|--------------|
| 1 | New screen uses existing theme tokens | Automated widget test |
| 2 | Second screen reuses shared `AppInfoCard` | Automated widget test |
| 3 | Long / unusual data without overflow | Automated (overflow exception + soft wrap) |
| 4 | Unnecessary list entrance animation simplified | Automated (no per-row controller; calm list preferred) |
| 5 | Small UI patch avoids full design ceremony | Manual policy check — `pipeline-patch` + token discipline (documented below) |
| 6 | Reduced-motion / text scaling | Automated `MediaQuery` textScaler + `disableAnimations` |

## Run

```powershell
cd _pilot/ui_craft_eval
flutter test
```

## Scenario 5 (manual / policy)

A one-line label change must **not** open PRD/design-system/EGM or load full `ui-craft` / `ui-stress`. Confirmed by `skills/pipeline-patch/SKILL.md` and `03-token-discipline` item 6 — no executable test; treat as process AC.

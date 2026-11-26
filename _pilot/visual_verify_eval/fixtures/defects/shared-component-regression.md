# Defect seed — shared-component visual regression

**Id:** `shared-component-regression`  
**Class:** objective regression / blast-radius defect (VIS-002)  

**Symptom:** A shared widget or theme tweak intended for one screen breaks a neighbor that reuses it.

## Anchor (kit pilot)

- Shared: `_pilot/ui_craft_eval/lib/core/ui/widgets/app_info_card.dart` (`AppInfoCard`)
- Consumers: profile + members (or equivalent) screens in `_pilot/ui_craft_eval`
- Theme: `_pilot/ui_craft_eval/lib/core/theme/app_theme.dart`

## Failure pattern

```
Change: AppInfoCard padding 16 → 64  (or title style → displayLarge)
Screen A (target): looks "fixed"
Screen B (neighbor): card overflows / hierarchy broken / list clipped
```

## Expected critique / fix

- Protect unrelated screens (VIS-002)
- Re-run neighbor surface (widget test and/or render) after shared tweak
- Reject “shared tweak green on one screen only”

## visualStatus note

Shared-component change cannot claim `visually_verified` from a single-screen artifact when neighbors exist — record multi-surface artifacts or `partial` + limitations.

# Design System — <App Name>

**Status:** Draft | Locked  
**Last updated:** YYYY-MM-DD  
**Code location:** e.g. `lib/theme/` or `lib/core/theme/`

## Brand / visual direction

## Color tokens

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| | | | |

## Typography

| Style | Font | Size / weight | Usage |
|-------|------|---------------|-------|
| | | | |

## Spacing / radius / elevation

Use the approved scale only — no parallel spacing or color systems in features.

## Component catalog

Document each reusable control (match captain’s theme-file practice):

- Buttons (primary, secondary, destructive, disabled) — press feedback expectations
- Text fields / forms
- Switches / checkboxes / radios
- App bar / navigation
- Cards / lists / dialogs / bottom sheets (prefer fewer clicks — avoid unnecessary sheets)
- Icons
- Charts / KPI tiles (if applicable)
- Shared empty / loading / error / success patterns

## Motion

Purposeful only (state, spatial continuity, feedback, progress). List what **may** animate and what **must not** (e.g. keyboard/high-frequency nav). No decorative per-item entrances by default. Platform notes: `ecc-cherry-pick/ui-craft.md`.

## Accessibility

Contrast, tap targets, semantics, focus order, safe areas, reduced-motion, large text.

## Layout resilience

Note truncate-vs-wrap choices for identity vs metadata fields. Stress catalog: `ecc-cherry-pick/ui-stress.md` (module/new screens — not every patch).

## Do / Don’t

## Approval

- [ ] Captain locked design system on ____  
- [ ] Theme code implemented before feature UI

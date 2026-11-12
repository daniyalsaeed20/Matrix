# UI craft & purposeful motion (reference)

On-demand detail for **UI work only**. Backend-only and non-UI patches must **not** load this file.

**Upstream ideas (adapted, not vendored):** [emilkowalski/skills](https://github.com/emilkowalski/skills) — `emil-design-eng`, `remove-animations`, `review-animations` (MIT).  
**m4tr!x policy:** do **not** install that repository; do not add permanent animation/break-ui skills or agents. Merge principles into existing design-system / implementer / verifier roles.

Always-on already covers: design-system compliance, loading/empty/error, reuse ladder, craft/simplicity. This file adds craftsmanship and motion judgment without duplicating those.

## Craftsmanship (respect the locked design system)

- Clear hierarchy: one primary action / focal text per region; secondary content quieter.
- Spacing and alignment from **approved tokens** — no ad-hoc gaps or one-off colors/type.
- Cohesive surfaces: buttons, fields, cards, nav match the catalog; prefer reuse over new chrome.
- States are first-class: loading, empty, error, success, disabled — visible and consistent.
- Interaction feedback for press/submit (subtle); high-frequency surfaces stay snappy.
- Accessible: contrast, tap targets, semantics/labels, focus order, safe areas.
- Avoid decorative complexity and generic “AI aesthetic” patterns (glow stacks, random purple gradients, pill spam) unless the locked system requires them.
- Keep component APIs small; no animation-controller sprawl or wrapper-only widgets.

## Motion gate (ask before animating)

Every motion must answer **why**: state change, spatial relationship, action feedback, progress/completion, or preventing a jarring jump. “Looks cool” on a frequent surface → **do not animate**.

| How often users see it | Default |
|------------------------|---------|
| Keyboard / 100+/day (tabs, palette, core nav) | **No** animation |
| Tens/day (hover, frequent toggles) | Prefer none or near-imperceptible |
| Occasional (modal, drawer, toast) | Standard, purposeful |
| Rare / first-time (onboarding, success) | Delight allowed sparingly |

**Subtract first:** unnecessary fade-ins, per-card/list-item entrances, delayed feedback on frequent actions, scroll-reveal on every section, infinite decorative loops, spinners/skeletons that flash for sub-~300ms work.

Prefer deleting motion over retuning it when purpose is weak. Do **not** invent a kit-wide mandatory duration — match the design system and platform norms; keep product UI responsive.

**Reduced motion:** honor OS/browser preferences — gentler (opacity/color OK); drop large movement/position shifts.

When unsure, prefer **less** motion.

## Platform notes (do not cross-copy)

### Flutter

- Prefer Material/Cupertino + design-system theme; `ImplicitlyAnimatedWidget`s / `Animated*` for simple property changes; `AnimationController` only when needed.
- Gesture / interruptible motion: springs or controllers that can retarget; avoid restarting keyframe-like sequences on rapid taps.
- Prefer transforming opacity / matrix-friendly effects over animating layout size every frame when equivalent.
- Lists: no staggered entrance by default; use builders for long lists.
- Respect `MediaQuery.disableAnimations` / `AccessibilityFeatures.disableAnimations`; test with large `textScaler`.

### Web (React / Next.js)

- Prefer CSS transitions for predetermined UI motion; JS/springs for gesture / interruptible cases.
- Animate `transform` / `opacity` when practical; avoid `transition: all`.
- Entering UI: responsive easing (ease-out / strong custom curves) — avoid sluggish ease-in on open.
- Trigger-anchored surfaces (popover/menu/tooltip) originate from the trigger; centered modals stay centered.
- Gate hover-only motion with `(hover: hover) and (pointer: fine)`; honor `prefers-reduced-motion`.

### React Native

- Prefer native driver–friendly props (`transform`, `opacity`) when using the Animated API / Reanimated.
- Keep JS-thread work off hot gesture paths; match platform navigation patterns.
- Same frequency gate and reduced-motion respect as above.

## Design-system doc expectations

When authoring `DESIGN_SYSTEM.md`, define **purposeful** motion (what may move, what must not) and reduced-motion notes — not a laundry list of decorative effects.

# UI stress checks (reference)

On-demand for **new screens / significant UI changes**. Proportional to task size — a label/copy patch does **not** need a full stress pass.

**Upstream ideas (adapted, not vendored):** [emilkowalski/skills](https://github.com/emilkowalski/skills) — `break-ui` (MIT).  
**m4tr!x policy:** fold into **m4trix-verifier** (and implementer self-check). No new agent. No production “worst-case toggle” unless the captain asks for a **dev-only** fixture.

## Proportionality

| Scale / change | Expectation |
|----------------|-------------|
| Patch (copy, color token, small layout tweak) | Spot-check the touched surface only |
| Module / new screen | Relevant rows below for fields the UI actually renders |
| Marketing / dense data UI | Stronger pass: long text, empty, dense counts, small width |

Use **plausible** worst cases (real naming patterns, schema max lengths) — not nonsense strings. Prefer schema/API limits when known.

## Catalog (pick what applies)

- Extremely long names, labels, emails, URLs, file names
- Empty / missing optional fields (no orphaned dashes or blank rows)
- One-letter / very short names; pluralization at 0 and 1
- Large numbers and currency (no overflow; prefer tabular lining if comparing)
- Empty lists and “no results”
- Small widths (~320 logical px) and narrow containers (sidebars)
- Text scaling / large accessibility text
- Longer translations and non-Latin scripts (clipping, line-height)
- Loading, error, disabled, unavailable actions
- Keyboard focus and safe-area / notch insets
- Layout overflow (row actions pushed off-screen, flex children without shrink)

## Truncate vs wrap (decide per field)

- **Wrap** identity text the user must read (names in detail views).
- **Truncate** secondary metadata; provide a way to see the full value.
- **Never truncate** amounts, counts, or dates the user compares.

## Report style (verifier)

Flag **Broken** (unreadable / unreachable / wrong), **Ugly** (readable but clearly wrong), **Fragile** (works now, one realistic step from failing). Distinguish defects from subjective taste. Cite what was actually checked (automated vs visual).

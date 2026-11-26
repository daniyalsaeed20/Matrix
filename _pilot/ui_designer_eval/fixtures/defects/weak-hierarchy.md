# Defect seed — weak hierarchy (T8 → T9 gallery)

**Id:** `weak-hierarchy`  
**Class:** objective layout / typography defect  
**Symptom:** Title, supporting copy, and actions share similar visual weight; no clear primary action or reading order.

## Static stand-in (no screenshot required for T8 script bar)

```
[ Screen ]
  Label A          (14sp, regular)
  Label B          (14sp, regular)
  Button: Save     (filled)
  Button: Cancel   (filled)   ← same emphasis as Save
  Button: Delete   (filled)
```

## Expected designer critique (shape)

- Identify missing primary hierarchy (type scale and/or action emphasis)
- Direct implementer to elevate one primary CTA and demote secondary actions
- Do not invent new tokens — use existing design-system emphasis levels

## T9 note

T9 may attach real render artifacts and `visualStatus` honesty checks against this seed.

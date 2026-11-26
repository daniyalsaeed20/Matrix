# Defect seed — weak hierarchy

**Id:** `weak-hierarchy`  
**Class:** objective layout / typography defect  
**Source:** seeded in T8 (`_pilot/ui_designer_eval/fixtures/defects/weak-hierarchy.md`); gallery owned here for T9+.

**Symptom:** Title, supporting copy, and actions share similar visual weight; no clear primary action or reading order.

## Static stand-in

```
[ Screen ]
  Label A          (14sp, regular)
  Label B          (14sp, regular)
  Button: Save     (filled)
  Button: Cancel   (filled)   ← same emphasis as Save
  Button: Delete   (filled)
```

## Expected critique / fix

- Elevate one primary CTA; demote secondary actions
- Use existing design-system emphasis — do not invent tokens

## visualStatus note

Screenshot alone ≠ quality pass (UI-003). Attach render artifacts only when real; otherwise use honest `blocked` / `partial` / `changes_requested`.

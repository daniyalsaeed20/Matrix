# Defect seed — overflow

**Id:** `overflow`  
**Class:** objective layout / responsive defect  

**Symptom:** Long labels, large text scale, or narrow width clip or yellow/black overflow stripes; soft wrap missing on body.

## Static stand-in

```
[ Narrow width / textScaler 1.5 ]
  VeryLongUnbrokenTokenNameThatShouldEllipsizeOrWrapXXXX
  ┌────────────────────────────┐
  │ Body that refuses to wrap… │ → RIGHT OVERFLOWED BY 42 PIXELS
  └────────────────────────────┘
```

## Expected critique / fix

- Soft wrap / ellipsis where appropriate
- Self-check `ui-stress` long-data and text-scale cases
- Cross-check `_pilot/ui_craft_eval` scenario 3 (overflow automated)

## visualStatus note

`flutter test` overflow catch → functional evidence; pair with render artifact or honest `functionally_verified_visually_unverified`.

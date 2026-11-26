# Defect seed — spacing

**Id:** `spacing`  
**Class:** objective layout defect  

**Symptom:** Uneven or collapsed gaps between related groups; unrelated controls packed as if one cluster; content kisses safe-area / app-bar edge.

## Static stand-in

```
[ Screen ]
  Title
  Body line 1
  Body line 2          ← 0–2dp after title; looks glued
  [Primary][Secondary] ← buttons flush to body; no section gap
  ───────────────────  ← edge of screen with 0 padding
```

## Expected critique / fix

- Restore consistent vertical rhythm from theme spacing scale
- Separate action row from body with a clear section gap
- Respect page padding / safe area

## visualStatus note

Widget overflow assertions help functionally but do not alone justify `visually_verified`.

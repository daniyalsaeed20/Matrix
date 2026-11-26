# Approval fingerprint eval (T11)

± proof for VER-002/004 approval bind and self-approve rejection.

## Run

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File _pilot/approval_fingerprint_eval/scripts/Invoke-ApprovalFingerprintEval.ps1
```

Expect `EXIT_CODE=0` and `evidence/SUMMARY.json` with `ok=true`.

## What it covers

| Case | Expected |
|------|----------|
| Valid fingerprints + captain | gate allow |
| `approval.by=agent` | gate refuse |
| Missing fingerprints | gate refuse |
| Stale specFingerprint | gate refuse |
| Scope fingerprint mismatch | gate refuse |

## Procedure

See `SELF_APPROVE_PROCEDURE.md`.

## Limitations

- Process gate only (not cryptographic captain auth).
- Fail closed on content hash — no formatting-only detector (VER-004).

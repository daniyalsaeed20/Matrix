# Security checklist (adapted from ECC rules/common/security.md)

For **m4trix-security** and pre-commit mindset.

## Before claiming done

- [ ] No hardcoded secrets (API keys, tokens, passwords)
- [ ] User inputs validated at trust boundaries
- [ ] Injection-safe data access (parameterized queries / safe APIs)
- [ ] XSS / unsafe HTML handled if web surfaces exist
- [ ] Authn/authz verified for every sensitive action
- [ ] Firebase/security rules reviewed for new collections/paths
- [ ] Errors do not leak secrets or PII
- [ ] Rate limiting considered on public endpoints

## If issue found

1. Stop feature expansion  
2. Fix Critical/High before continue  
3. Rotate exposed secrets  
4. Scan for similar issues  

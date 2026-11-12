# TDD / verify loop (adapted from ECC tdd-workflow + verification ideas)

For **m4trix-verifier** and implementers.

## Preferred loop (when tests are practical)

1. Express AC as failing test(s) when feasible  
2. Implement until green  
3. Refactor without breaking tests  
4. Fresh-context review (verifier) — do not rubber-stamp  

## When UI-only / hard-to-automate

- Document manual verification steps in `TEST_PLAN.md`  
- Still require happy / fail / edge evidence  

## Definition of verified

- AC mapped to evidence  
- Production bar from m4tr!x rules satisfied  
- Failures listed explicitly — never “looks fine”

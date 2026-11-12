# m4tr!x v1.4.0 behavioral verification report

**Date:** 2026-11-12  
**Fixture:** `_pilot/behavior_eval/` (temp Flutter + Node)  
**Kit version:** 1.4.0 (not bumped)  
**Tokens:** **N/A** — Cursor does not expose reliable in-agent input/output token counts for this run  

## Execution type legend

| Label | Meaning |
|-------|---------|
| **Real agent execution** | This Cursor session (or a spawned Task) wrote/read code and ran commands |
| **Protocol exercise** | Handoff/stale/approval followed as documented process with scripts/checks |
| **Static rule check** | Not used as pass criteria for these scenarios |

---

## Scenario results

### S1 — Small UI patch → **PASS**
- **Type:** Real agent execution  
- **Scope:** `ACTIVE_TASK` BE-S1 — button padding only  
- **Progressive context:** Grep for `ElevatedButton|padding` → opened theme hit only  
- **Changed:** `flutter_app/lib/core/theme/app_theme.dart` (20→28 horizontal padding)  
- **Not changed:** home screen, no PRD, no new agents/services  
- **Verified:** `flutter test test/home_screen_test.dart` → PASS  
- **Handoffs:** 0  

### S2 — First Flutter screen (header + cards) → **PASS**
- **Type:** Real agent execution  
- **Discovery:** Grep showed no existing `AppHeader`/`AppInfoCard`  
- **Created:** `app_header.dart`, `app_info_card.dart`, `dashboard_screen.dart`  
- **Craft:** Small shared APIs; screens compose shared widgets; no worthless wrappers beyond shared styling  
- **Verified:** `flutter test test/screens_reuse_test.dart` (dashboard case) + `flutter analyze lib` clean  

### S3 — Second Flutter screen reuse → **PASS**
- **Type:** Real agent execution + real verifier Task  
- **Changed:** `orders_screen.dart` imports **same** `AppHeader` / `AppInfoCard`  
- **Evidence:** Only one `class AppHeader` and one `class AppInfoCard` under `lib/`  
- **Verified:** widget tests PASS; spawned verifier opened **5** files from HANDOFF (no full-repo rescan) → **Passed**  

### S4 — Backend endpoint → **PASS**
- **Type:** Real agent execution  
- **Changed:** `notes.js`, `server.js` POST `/notes`; reuses `validate.js`  
- **Security gate:** unauthorized without `x-api-key` (401) — enforced in tests  
- **Verified:** `node --test` → **7 PASS** (incl. auth + create)  
- **Approval:** Did **not** remove API key without captain approval (refusal recorded)  

### S5 — Bug fix → **PASS**
- **Type:** Real agent execution  
- **Bug:** `AppInfoCard` spacing set to `SizedBox(height: 0)`  
- **Fail evidence:** `flutter test test/bugfix_spacing_test.dart` failed as expected  
- **Fix:** height restored to `8` (surgical, one file)  
- **Re-verify:** spacing + reuse + home tests PASS  

### Agent handoff → **PASS**
- **Type:** Protocol + real Task verifier  
- **Artifact:** `docs/sdlc/HANDOFF.md`  
- **Receiving agent:** Task (verifier) used handoff paths only; files opened: 5; verdict Passed  
- **Note:** Handoff did not grant new approval/scope  

### Stale context (`staleAfterHours`) → **PASS**
- **Type:** Protocol exercise (`evidence/stale_context_check.mjs`)  
- **Setup:** `ACTIVE_TASK_STALE.json` with `updatedAt` 2026-10-01, fake component path `lib/widgets/old_header.dart`  
- **Result:** stale=true (~1022h); fake path missing; real `app_header.dart` present; **approval + security decision refs intact**  
- **Interpretation:** Advisory hint only — does not override newer source or void approvals  

---

## Efficiency secondary indicators (this run)

| Indicator | Observation |
|-----------|-------------|
| Tokens | N/A |
| Patch handoffs | 0 (S1) |
| Multi-agent handoffs | 1 (implementer → verifier Task for S2/S3) |
| Rework cycles | 1 intentional (S5 fail→fix) |
| Redundant full-repo reads | Avoided for S1/S3 verifier via grep/HANDOFF |
| Unrelated file churn | Removed broken `test/widget_test.dart` from `flutter create` (fixture hygiene) |

---

## Weaknesses (no org changes made to paper over them)

1. **Policy ≠ enforcement:** Progressive load / stale advisory / handoff discipline rely on agent compliance; no hook auto-enforces them.  
2. **Stale check is manual/scripted** in this eval — runtime agents must notice `context.updatedAt` themselves.  
3. **Fixture bootstrap debt:** `flutter create` left a broken default `widget_test.dart` / broken template `main.dart` that had to be replaced before meaningful runs.  
4. **Token metrics unavailable** in-agent — cannot claim savings vs baseline.  
5. **Single-chat implementer bias:** Most scenarios were executed by one session acting as implementer; only one separate verifier Task was spawned. Broader multi-agent orchestration under load is unproven.  

## Recommendations (do not implement unless captain approves a separate change)

- Optional smoke helper under `_pilot/behavior_eval` to re-run this suite (script only; not a new always-on rule).  
- Consider teaching install/docs that `staleAfterHours` is advisory — already in ACTIVE_TASK note; no code change required.  
- If measuring tokens matters, capture from Cursor usage UI outside the agent after comparable runs.

## Overall

**Behavioral effectiveness on this fixture: PASS** for executed scenarios, with the enforcement/metrics limitations above called out as residual risk—not as scenario failures.

# LIVE_PROCEDURE — optional deny-hook fire (T10)

**Purpose:** Live-verify Cursor deny events in a **sibling** eval workspace.  
**Default for T10 accept:** optional. If not run, status remains `unverified_in_this_environment`.

## Preconditions

1. Captain authorizes temporary project hooks in a **true sibling** workspace (not nested under the kit multi-root).
2. Do **not** run `install-globals -Fresh` from WIP (ISO-002).
3. Preserve third-party hooks; use project `.cursor/hooks.json` only in the eval workspace.

## Steps

1. Open sibling workspace in a separate Cursor window.
2. Copy deny scripts into that project's `.cursor/hooks/` (or point commands at kit scripts).
3. Register **one** event at a time, e.g. `beforeShellExecution` → `m4trix-before-shell.ps1`, with a narrow matcher if desired.
4. Trigger a matching shell command (e.g. a dry echo containing `install-globals.ps1 -Fresh` text in a throwaway script path that is safe).
5. Record: event fired? permission deny observed? fail-open on crash?
6. Remove temporary registrations; restore advisory-only kit default.
7. Write results to `_pilot/guard_complete_eval/evidence/live-hook-probe.json` with `status: verified|unverified|failed`.

## Honesty

- Unverified → do not call enforcement **preventive**.
- Completion gate remains mandatory regardless of hook results.

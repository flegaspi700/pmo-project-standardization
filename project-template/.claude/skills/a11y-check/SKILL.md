---
name: a11y-check
description: Check changed screens against the accessibility checklist in docs/15-accessibility.md — met, not met (with fix), or steps for a manual check.
argument-hint: "[story, feature, or screens to check — default: this phase]"
disable-model-invocation: true
---

Accessibility check of: $ARGUMENTS (default: UI changed in the current
phase).

1. If `docs/15-accessibility.md` doesn't exist or is `Not needed` in the
   Doc status table, the project has no UI — say so and stop. (If the
   changes actually add a UI, say that and suggest turning `15` on.)
2. Read `docs/15-accessibility.md` and find the screens/UI code in scope.
3. For each checklist item that applies, report one of:
   - **Met** — and how you verified it from the code (e.g. computed
     contrast ratio, key bindings found)
   - **Not met** — file and line, and the fix
   - **Needs a manual check** — exact steps for the user (from the How to
     test table)
4. Don't guess. Anything you can't verify from the code is a manual check.
5. Offer to add the manual steps to `docs/12-manual-tests.md` for the
   feature, so results get recorded there.

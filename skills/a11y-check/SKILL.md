---
name: a11y-check
description: In a project on the standard with a user interface, check changed screens against the accessibility checklist — met, not met (with fix), or steps for a manual check.
argument-hint: "[story, feature, or screens to check — default: this phase]"
disable-model-invocation: true
---

Accessibility check of: $ARGUMENTS (default: UI changed in the current
phase).

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\a11y-check"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `standard/accessibility.md`.

1. If the project has no `docs/accessibility.md`, it has no UI on record:
   say so and stop. If the changes do add a UI, say that and offer to add
   `docs/accessibility.md`.
2. Read `docs/accessibility.md` (which checklist applies) and find the
   screens and UI code in scope.
3. For each checklist item that applies, report one of:
   - **Met:** and how you verified it from the code (for example the
     computed contrast ratio, the key bindings found)
   - **Not met:** file and line, and the fix
   - **Needs a manual check:** exact steps for the user, from the How to
     test table
4. Don't guess. Anything you can't verify from the code is a manual check.
5. Offer to add the manual steps to `docs/manual-tests.md` for the feature,
   so results get recorded there.

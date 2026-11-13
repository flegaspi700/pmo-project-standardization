---
name: fix-bug
description: Fix a bug the proper way in a project on the standard — log it with an ID, reproduce it with a failing test, then fix it. Use when the user reports something broken in finished work or a failed manual test.
argument-hint: "[what's wrong]"
---

Bug: $ARGUMENTS

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\fix-bug"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `requirements.md` → Bugs, `testing.md` → Bugs,
`git.md` (all in `standard/`).

1. Read `AGENTS.md` and `docs/requirements.md` → Bugs. If the report lacks
   steps to reproduce, the expected result or the actual result, ask.
2. Log it: the next free ID (`B1`, `B2`, …) in the Bugs table, with steps,
   expected and actual. Ask for the severity if it isn't obvious.
3. Branch from an up-to-date `main`: `fix/<ID>-short-description`.
4. Write a test that reproduces the bug. Run it and **show it failing.** If
   it passes, it doesn't catch the bug yet; rework it.
5. Find the cause and fix it with the smallest change. Don't change any
   other test.
6. Run the full suite and **show the output.** Record the test name and the
   cause in the bug entry; set it to `Fixed`.
7. If the bug came from a manual test, update its result in
   `docs/manual-tests.md`.
8. **Ask before committing** (`fix: <summary> (<ID>)`). Then, as in
   `/story`: on `github`, ask before pushing and opening the PR, and never
   merge; on `local`, stop on the branch and merge only when the user says
   so.

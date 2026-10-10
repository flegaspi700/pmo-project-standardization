---
name: fix-bug
description: Fix a bug the proper way — log it with an ID, reproduce it with a failing test, then fix it. Use when the user reports something broken in finished work or a failed manual test.
argument-hint: "[what's wrong]"
---

Bug: $ARGUMENTS

1. Read `AGENTS.md` and `docs/01-requirements.md` → Bugs. If the report
   lacks steps to reproduce, expected result, or actual result, ask for
   them.
2. Log it: next free ID (`B1`, `B2`…) in the Bugs table and a section with
   steps, expected, actual. Severity: ask the user if it's not obvious.
3. Check `Hosting` in `AGENTS.md`. Branch from an up-to-date `main` (pull
   first only on `github`): `fix/<ID>-short-description`.
4. Write a test that reproduces the bug. Run it and **show it failing** —
   if it passes, the test doesn't catch the bug yet; rework it.
5. Find the cause, then fix it with the smallest change. Don't change any
   other test.
6. Run the full suite and **show the output.** Record the test name and
   cause in the bug entry; set it to `Fixed`.
7. If the bug came from a manual test, update its result in
   `docs/12-manual-tests.md`.
8. **Ask before committing** (`fix: <summary> (<ID>)`). Then, as in
   `/story` step 9: on `github` ask before pushing and opening the PR, and
   never merge; on `local` stop on the branch and merge into `main` only
   when the user says so. Never push or mention GitHub on `local`.

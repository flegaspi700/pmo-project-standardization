---
name: stack
description: Recommend and record the language, libraries, and tooling for a new project on the standard — options with pros, cons, and cost; waits for the user to choose.
disable-model-invocation: true
---

Choose the stack.

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\stack"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `decisions.md` → Choosing the stack,
`security.md` → Dependencies (both in `standard/`).

1. Read `AGENTS.md`, `docs/requirements.md` and `docs/decisions.md`. If the
   repo already has code, the stack is what's there: record it as it is
   (steps 5-6) instead of proposing a new one.
2. Present **2-3 options** for language and key libraries, as a table:
   option, pros, cons, cost, one-line fit with the vision. Default to
   Python unless the project needs something else (a browser UI, a game
   engine, a mobile app); say so if it does. For each language option,
   name the formatter, linter, test runner, coverage tool and dependency
   audit tool.
3. Recommend one and name the trade-off. For every library, confirm the
   exact package name exists in the official registry and is maintained,
   and say how you checked.
4. **Wait for the user to choose.** Write nothing before that.
5. Then, in one go:
   - log "Language and stack" and "Formatter, linter and test runner" in
     `docs/decisions.md`, with the options table
   - fill in the Commands in `AGENTS.md` (run, test, one test file,
     coverage, lint, format, dependency audit)
   - add the naming style and top-level layout to `AGENTS.md` →
     project-specific notes
   - add the language's standard ignores to `.gitignore`
6. If the project has `docs/architecture.md`, add a Key decisions row.

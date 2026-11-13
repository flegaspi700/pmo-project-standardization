---
name: decide
description: In a project on the standard, compare 2-3 options for a significant design or technology choice, recommend one, and log the user's decision in docs/decisions.md.
argument-hint: "[the question to decide]"
disable-model-invocation: true
---

Decide: $ARGUMENTS

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\decide"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `standard/decisions.md`.

1. Read `AGENTS.md`, the vision in `docs/requirements.md`,
   `docs/decisions.md`, and `docs/architecture.md` if there is one. If this
   was already decided, show that entry and stop, unless the user wants to
   revisit it.
2. If the question isn't clear, ask what's being decided and why now.
3. Give **2-3 options, always including the simplest one that could
   work.** Compare them in a table: pros, cons, cost, effort, how easy to
   change later, judged against the vision's goals and constraints.
4. Recommend one and name the trade-off the user would be accepting.
5. **Wait for the user to choose.** Don't write code or log anything first.
6. Then:
   - add an entry at the top of `docs/decisions.md` in the format in
     `decisions.md`; mark any entry it replaces `Superseded by`
   - if the project has `docs/architecture.md`, add a Key decisions row and
     update any section or diagram the decision changes

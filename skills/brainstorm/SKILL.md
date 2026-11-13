---
name: brainstorm
description: Explore a rough idea for a project on the standard — questions, 3-4 distinct directions, the riskiest assumption — then record the chosen direction as the vision in docs/requirements.md. Planning only, no code.
argument-hint: "[rough idea or problem]"
disable-model-invocation: true
---

Brainstorm: $ARGUMENTS
(If that's empty, work from the vision at the top of `docs/requirements.md`,
or ask what the idea is.)

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\brainstorm"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `standard/decisions.md`.

1. Read `AGENTS.md`, the vision in `docs/requirements.md` (it may still be
   a placeholder), and `docs/decisions.md` so you don't reopen settled
   decisions.
2. **Ask before proposing.** A few questions at a time: who it's for, what
   problem it solves, why now, and the constraints (time, money, skills).
   Don't guess the gaps.
3. Offer **3-4 distinct directions** as a table: direction, pros, cons,
   rough effort. Always include a smaller or simpler one than the user
   first described.
4. Challenge the assumptions. Name the **riskiest one** and a cheap way to
   test it before building anything.
5. Recommend one direction and name the trade-off. **Wait for the user to
   choose.** Write nothing before that.
6. Then update only:
   - the vision paragraph at the top of `docs/requirements.md`: what it is,
     who it's for, the goals, non-goals and constraints of the chosen
     direction
   - `docs/decisions.md`: one entry with the options table, so the
     rejected directions aren't argued again
7. Suggest `/breakdown` as the next step.

Don't write any code, and don't touch anything else.

---
name: breakdown
description: Break a project on the standard (or one epic) into phases, epics, features, and stories with acceptance criteria in docs/requirements.md. Planning only, no code.
argument-hint: "[epic ID or idea to break down]"
disable-model-invocation: true
---

Break down requirements for: $ARGUMENTS
(If that's empty, work from the vision at the top of `docs/requirements.md`
for the whole project.)

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\breakdown"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `standard/requirements.md`.

1. Read `AGENTS.md` and `docs/requirements.md` (vision, Phases table,
   what's already there). On a repo with existing code, look at the code
   too: new stories cover new work only, never what's already built.
2. **Ask before writing.** List what's ambiguous or missing (users, edge
   cases, what "done" looks like) and ask, a few questions at a time. Don't
   guess the gaps.
3. Propose phases (goal and exit criteria each; one is fine for a small
   project), then epics and features:
   - every epic serves the vision; flag an idea that doesn't instead of
     adding it
   - every feature has a phase and a **Done when** line
4. Write **stories with acceptance criteria only for the current and next
   phase**: one prompt-sized change each, Given/When/Then criteria
   including empty and worst-case inputs. Later phases get epics and
   features only.
5. Show the breakdown and wait for the user's changes. Then write it into
   `docs/requirements.md`: the Phases table, and the epics, features and
   stories in the format in `requirements.md`.

Don't write any code.

---
name: wrap-up
description: End-of-session handoff in a project on the standard — write the session log entry (including time spent), refresh the counts in portfolio.json, and flag anything unfinished or uncommitted. Use when the user says they're stopping, done for today, or wrapping up.
---

Wrap up this session.

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\wrap-up"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `standard/sessions.md` → End of a session.

1. Check `git status` and the current branch. Note uncommitted changes,
   unmerged branches and failing tests, and, only if `Hosting` is `github`,
   unpushed commits. Don't commit anything without asking.
2. Ask how much time the session took, if you can't tell.
3. Add an entry at the top of `docs/session-log.md` in the format in
   `sessions.md`: stories worked on, time spent, what changed and why,
   exactly where things stopped, the very next step, open questions.
4. Make sure story statuses in `docs/requirements.md` match reality, then
   refresh `progress` in `portfolio.json` (stories done and total, open
   bugs, `as_of` today). Don't touch health, risks, blockers, call-outs or
   `updated`: those need a person, via `/report`.
5. Tell the user briefly what's uncommitted (or unpushed, on `github`) and
   the next step from the log.

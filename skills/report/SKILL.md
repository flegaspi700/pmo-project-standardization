---
name: report
description: Update a project's status for the portfolio — counts from the docs, judgment calls from the user — and write it to portfolio.json. Run weekly or at the end of a phase.
disable-model-invocation: true
---

Report this project's status.

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\report"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `standard/sessions.md` → Reporting, and the
reporting contract in `<template-dir>\spec\reporting-contract.md`.

**Reporting-only repo** (preflight says so: `portfolio.json` but no
Standard line): there are no project docs to count from. Do only step 5,
then write those answers to `portfolio.json` as in step 7, leaving
`phase`, `progress`, `next_milestone` and `budget` as they are. Set
`updated` to today, and show the summary (step 8). Then, as for any change
to the repo, ask before committing, and use a branch and a PR if
`main` is protected.

1. Read `portfolio.json`, `docs/requirements.md` (Phases table, stories,
   bugs), `docs/session-log.md` (entries since `progress.as_of` in
   `portfolio.json`), and `docs/budget.md` if there is one.
2. **Count from the docs, don't estimate:** stories done and total, open
   bugs, the current phase. List what's done since the last report, in
   progress, and next up.
3. Sum **Time spent** from the session log since the last report and for
   the current phase. If there's `docs/budget.md`, take the latest month's
   spend and the limits.
4. Update the Phases table in `docs/requirements.md` if a phase started or
   finished (actual dates only; never change planned ones).
5. **Ask the user** for the judgment calls; never guess them: health
   (green, amber, red) and why, risks, blockers, call-outs for the sponsor,
   whether `lifecycle` changed (`planning`, `active`, `on-hold`, `done`,
   `archived`), and whether the `program` is still right (free text: the
   group the dashboard shows it under; show the current one).
6. If a phase just closed, also ask the retrospective questions (what went
   well, what didn't, what to change next phase) and compare the time spent
   with the phase's estimate, if it had one. Add the answers to the top of
   `docs/session-log.md`, and offer to apply the changes.
7. Update `portfolio.json` per the contract: `health`, `health_reason`,
   `risks`, `blockers`, `callouts`, `lifecycle` and `program` from step 5; `phase`,
   `next_milestone` and `progress` from the docs; `budget` from step 3, or
   `null` without `docs/budget.md`. Set `updated` to today. Keep it valid
   JSON, UTF-8, 2-space indent.
8. Show the user a short summary: health, progress, what changed in
   `portfolio.json`.

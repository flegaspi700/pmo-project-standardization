---
name: update-template
description: Update an existing project to the newest version of the user's project template — plan the changes, merge them without losing the project's own edits, fill in portfolio.json, and check compliance. Run it inside the project.
argument-hint: "[target version, e.g. v1.4.0 — default: newest]"
disable-model-invocation: true
---

Update this project to the project template: $ARGUMENTS

**Find the template folder first** (called `<template-dir>` below). This
skill is installed as a junction to `<template-dir>\skills\update-template`,
so resolve it in PowerShell:

```
$s = Get-Item "$env:USERPROFILE\.claude\skills\update-template"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path
```

Check that `<template-dir>\update-plan.ps1` exists. If it doesn't, ask the
user where the template folder is. Work through the steps in order. Never
merge a PR or push without asking.

## 1. Check the project

Run in the project folder (call it `<project>`):

1. **On the template?** `AGENTS.md` must have a `## Doc status` table. If it
   doesn't, stop: this skill updates projects that already use the
   template. Offer `/new-project` (existing repo option) instead, or, for a
   quick start, only a `portfolio.json` (compliance level 1, Reporting).
2. **Clean start:** `git status` shows no uncommitted changes, and `main`
   is up to date (`git pull` if `Hosting: github`). If not, say what's
   pending and stop.
3. **Branch:** `chore/template-<target version>` from `main`.

## 2. Plan

Run (read-only):

```
& "<template-dir>\update-plan.ps1" -Path "<project>"
```

Add `-To <version>` if the user named a target. It prints the base version
and how it was found, one line per template file that changed since then,
and the CHANGELOG entries in between.

- If the base was **detected** (no `Template version:` line), say so and
  ask the user to confirm it. A detected base is the oldest version that
  fits, which is safe: files already up to date show as `UP-TO-DATE`.
- If nothing changed: say the project is up to date, run step 5, and stop.

Show the user a short summary: "From <base> to <target>: what's new
(one line per CHANGELOG entry), then N files to add, N to replace, N to
merge." Ask: **"Go ahead?"**

## 3. Apply

Work through the plan, file by file. Read every file as UTF-8 and write
UTF-8 without a BOM; keep the project's line endings.

- **ADD:** copy the file from `<template-dir>\project-template\` and fill
  the placeholders `new-project.ps1` fills: `<Project name>` (the project's
  name, from the `README.md` title), `<project-name>` (folder name),
  `<hosting>` (from `AGENTS.md` → Git), `<template-dir>`, and
  `<template-version>` (the target). `portfolio.json` gets step 4 instead.
- **REPLACE:** the project never changed this file, so copy the new version
  over it.
- **MERGE:** the project changed the file. Show the template's change:
  `git -C "<template-dir>" diff <base> <target> -- project-template/<path>`.
  Apply only that change to the project's copy, and only the parts the
  project doesn't already have. Keep everything the project wrote. Insert
  new `AGENTS.md` sections at the same place as in the template. If a change
  conflicts with the project's own edit, show both and ask. A change that
  only swaps a hard-coded value for a placeholder (e.g. a path for
  `<template-dir>`) is usually already there once you fill the placeholder
  in: then there's nothing to merge; say so.
- **REVIEW:** the template removed the file. Ask whether to delete it.
- **UP-TO-DATE:** nothing to do.

Then set the stamp near the top of `AGENTS.md` (add it if missing):
`**Template version: <target>**`, plus "(Created from <base>; updated to
<target> on <today>.)" if it was created from an older version.

## 4. `portfolio.json`

If the project didn't have one (or it was just added), fill it in following
the reporting contract (link in `AGENTS.md` → Portfolio reporting):

1. **From the docs.** Text that is still a template placeholder (`<...>`)
   is not data: never copy or count it.
   - `name`, and `summary` from `docs/00-vision.md`; if the vision isn't
     filled in yet, from `AGENTS.md` → What this project is, else the
     `README.md` description.
   - `phase` and `next_milestone` from `docs/04-project-plan.md`.
   - `progress` from story statuses in `docs/01-requirements.md`. Dropped
     stories and placeholder rows don't count; with no real stories yet,
     `progress` is `null`.
   - `budget` from `docs/16-budget.md`, only if `16` is Active and its
     limits are filled in; otherwise `null`.
2. **Ask the user:** `owner`, `sponsor`, `program`, `lifecycle`.
3. **Draft, then ask:** health and reason, risks, blockers, call-outs.
   Draft them from the vision's risks, the latest session log, and the
   last activity date, and show the draft as a table with the source of
   each line. Write only what the user confirms. Never guess these.
4. Set `updated` to today.

## 5. Check

1. `& "<template-dir>\check-compliance.ps1" -Path "<project>"`, and again
   with `-Today` set 30 days ahead. The goal is level 3 (Current) with no
   warnings. For each failure or warning, apply its fix or tell the user
   why not.
2. Run the project's tests (`AGENTS.md` → Commands), even though no code
   changed, and keep the output for the PR. If the project has no test
   command yet (the Commands table is still placeholders), say so: this
   step doesn't apply.

Warnings about the project's own unfinished docs (e.g. W2, an unfilled
vision) aren't part of the update: report them with their fix and leave
them for the project's normal work.

## 6. Finish

1. Add a session log entry at the top of `docs/10-session-log.md`: from
   which version to which, files changed, the compliance level, and that
   the next step is unchanged.
2. Commit with `chore: update to project template <target>`, then follow
   `AGENTS.md` → Git: on `github`, ask, push and open a PR (use the PR
   template, with the test and compliance output); on `local`, ask before
   the squash merge.
3. Tell the user: the level before and after, what was merged by hand,
   and anything the checks don't cover that still has placeholders.

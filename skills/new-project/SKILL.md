---
name: new-project
description: Put a project on the standard — start a new one, adopt the standard in an existing GitHub repo, or add only portfolio.json so a repo shows on the dashboard.
argument-hint: "[project name]"
disable-model-invocation: true
---

Start or adopt a project: $ARGUMENTS

**Find the template folder first** (called `<template-dir>` below). This
skill is installed as a junction to `<template-dir>\skills\new-project`, so
resolve it in PowerShell:

```
$s = Get-Item "$env:USERPROFILE\.claude\skills\new-project"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path
```

Check that `<template-dir>\new-project.ps1` exists; if not, ask where the
template folder is. The rules every project follows are in
`<template-dir>\standard\` (read `README.md` there first). Keep it
conversational: one topic per message, short questions.

## 1. What are we doing?

Ask first, always (one question, four choices):
1. **New project, the idea is clear.**
2. **New project, brainstorm the idea first.** Nothing is created until a
   direction is picked.
3. **Put an existing GitHub repo on the standard.**
4. **Only show an existing repo on the dashboard:** adds `portfolio.json`
   and nothing else.

**Choices 1 and 2.** Ask for what wasn't given: the **name**, the **idea**
in a sentence or two (rough is fine for choice 2; do step 1b now), **where**
to create it (see Default location), and **hosting**, recommending local:
- **Local only (default):** git on this machine, no remote, no PRs.
- **New GitHub repo:** also ask private or public, recommending private
  (public means anyone can see the code and history; it can change later).

Show the folder that will be created (the name lowercased, anything that
isn't a letter or digit turned into a dash: "Guess Game!" →
`<destination>\guess-game`) and confirm. If it exists, ask for another
name or location.

**Choices 3 and 4.** Hosting is `github`. Let the user pick the repo: run
`gh repo list --limit 30 --no-archived --source --json nameWithOwner,visibility,pushedAt`
and show a numbered list, most recently pushed first (name, private or
public, last push). "Pick a number, or paste a URL or `owner/name`." If
`gh` isn't signed in, ask for the URL. If the repo isn't the user's own,
say the files go into someone else's code and confirm. Ask where the clone
should go (see Default location); if the repo is already cloned there, use
that copy.

**Default location:** the folder this session started in. If that's inside
`<template-dir>` or inside a git repo, don't offer it; ask instead.

## 1b. Brainstorm (only for choice 2)

Nothing is created yet. These are the steps of `/brainstorm`, but **write
no files**:

1. **Ask before proposing.** A few questions at a time: who it's for, what
   problem it solves, why now, and the constraints (time, money, skills).
   Don't guess the gaps.
2. Offer **3-4 distinct directions** as a table: direction, pros, cons,
   rough effort. Always include a smaller or simpler one than the user
   first described.
3. Challenge the assumptions. Name the **riskiest one** and a cheap way to
   test it before building anything.
4. Recommend one direction and name the trade-off. **Wait for the user to
   choose.**

Keep the chosen direction, the options table and the riskiest assumption
for step 3. If the user drops the idea, stop: nothing was made.

## 2. Create or adopt

**New project:**
`& "<template-dir>\new-project.ps1" -Name "<name>" -Destination "<destination>" -Hosting <local|github>`
For a new GitHub repo, create it right away so a sign-in problem shows up
early: `gh repo create <folder-name> --<private|public> --source "<folder>" --remote origin`
(no push yet). If that fails, offer to fix and retry, or to carry on
locally (then set `**Hosting: local**` in `AGENTS.md`).

**Existing repo (choices 3 and 4):**
1. Clone if needed: `gh repo clone <repo> "<destination>\<repo-name>"`. A
   clone doesn't change the repo.
2. Make sure `main` is clean and current, then branch:
   `chore/adopt-standard` (choice 3) or `chore/add-portfolio-json`
   (choice 4). Nothing lands on `main` without a PR the user merges.
3. Preview: run the script with `-DryRun`, adding `-ReportOnly` for
   choice 4:
   `& "<template-dir>\new-project.ps1" -Name "<repo-name>" -Destination "<destination>" -IntoExisting -Hosting github -DryRun`
   Show what it will add and what it keeps. Say plainly: existing files are
   never overwritten, and nothing is committed or pushed until the user
   says so. Ask to go ahead. On no, stop; the clone is left as it was.
4. Run it without `-DryRun`.
5. **`CLAUDE.md` (choice 3):** if the repo has one without an `@AGENTS.md`
   line, Claude Code would read `CLAUDE.md` and never load `AGENTS.md`. Show
   the one change, `@AGENTS.md` added as the first line (Claude Code then
   loads `AGENTS.md` along with it), and make it only on a yes. It's the
   only edit to an existing file.
6. **`AGENTS.md` or `portfolio.json` already there:** say the starter
   version wasn't applied, and offer to add only the missing lines (the
   `**Standard:**` and `**Hosting:**` lines, or the missing JSON fields),
   asking before each change.
7. **Read the repo** before step 3: README, manifests (`pyproject.toml`,
   `package.json`, ...), folder layout, tests, CI, recent `git log`.
   Summarise it in a few lines and ask the user to confirm or correct. Don't
   re-ask what the repo already answers.

## 3. Fill in

Suggest every answer from the idea, the brainstorm or the repo; the user
accepts, edits or skips. Never write an answer they didn't confirm.

- **`portfolio.json`** (all choices): `summary` (one sentence), `owner`,
  `sponsor` and `program` (free text: the group the dashboard shows it
  under; suggest one already used by their other repos, if you know of
  any). For choice 4 also ask `lifecycle` (`active`, `done`, ...). Leave
  `health: not-reported`: the first `/report` sets it. `null` for skips.

**Choice 4 stops here:** go to step 4.

- **`AGENTS.md`:** the one-sentence description. **Existing repo:** also
  the Commands, from the manifest or README (anything not found stays a
  placeholder; say which), and a few project-specific notes (layout,
  naming) from what you read.
- **`docs/requirements.md` → Vision:** draft the paragraph, non-goals and
  constraints in one go and ask "Is this right?". **Existing repo:**
  describe what it is today, not what it should become. Phases: one phase
  for a new project; for an existing repo, leave the table for
  `/breakdown`. **No stories for code that already exists.**
- **`docs/decisions.md`:** if step 1b ran, the brainstorm entry (options
  table, decision, why, trade-offs). **Existing repo:** one entry,
  "Existing stack, kept as is", naming the stack found.
- **`README.md`** (new project): the one- or two-sentence description.
- **Extras:** from what you know, propose which extra docs apply, as a
  table (doc, why), per `standard/README.md`: `docs/security.md` (network,
  secrets, personal data, outside input), `docs/accessibility.md` (a UI),
  `docs/architecture.md` (several components), `docs/budget.md` (it costs
  money), `docs/manual-tests.md` (things only a person can check). None is
  a fine answer. Copy the accepted ones from
  `<template-dir>\scaffold\extras\docs\`, plus
  `<template-dir>\scaffold\extras\.env.example` with `security.md` if the
  project uses secrets.
- **The repo's own formatter** (existing repo): if its CI or scripts check
  the formatting of Markdown or JSON (for example `prettier --check .`),
  run its formatter on the added files and then its check, so the
  adoption PR doesn't fail CI. Don't reformat any file the repo already had.
- **The repo's own style rules:** if its `CLAUDE.md`, `AGENTS.md` or
  contributing guide sets rules for prose (for example "no em dashes"),
  follow them in everything you write there.

## 4. Commit

Show what changed (`git status`), then ask before each step:
- **Local:** commit on `main` (`chore: start project on the standard`).
- **New GitHub repo:** commit, then `git push -u origin main`.
- **Existing repo:** commit on the branch (`chore: adopt the standard` or
  `chore: add portfolio.json`), push the branch, and open a PR. Never push
  `main`, never merge.

## 5. Next steps

1. **Skills installed?** If `$env:USERPROFILE\.claude\skills\story` doesn't
   exist, say the project commands aren't installed yet and suggest
   `& "<template-dir>\install-skills.ps1" -DryRun`, then without `-DryRun`.
2. Open Claude Code in the project folder: `cd "<folder>"`, then `claude`.
3. **New project:** `/breakdown`, then `/stack`. **Existing repo:**
   `/breakdown` for the next change (the stack is already recorded), once
   the PR is merged. **Dashboard only:** nothing more; `/new-project`
   choice 3 can adopt the rest later.

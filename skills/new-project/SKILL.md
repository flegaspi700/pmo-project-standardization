---
name: new-project
description: Start a new project from the user's project template — create the folder, then interview the user to fill in the vision doc.
argument-hint: "[project name]"
disable-model-invocation: true
---

Start a new project: $ARGUMENTS

**Find the template folder first** (called `<template-dir>` below). This
skill is installed as a junction to `<template-dir>\skills\new-project`, so
resolve it in PowerShell:

```
$s = Get-Item "$env:USERPROFILE\.claude\skills\new-project"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path
```

Check that `<template-dir>\new-project.ps1` exists. If it doesn't, ask the
user where the template folder is. The template is
`<template-dir>\project-template`, created with
`<template-dir>\new-project.ps1`. Work through the steps
below in order. Keep it conversational: one topic per message, short
questions.

## 1. Basics

**First, ask what they're starting** (always, even if `$ARGUMENTS` has a
name; one question, three choices):
  1. **New project — the idea is clear.**
  2. **New project — brainstorm the idea first.** Nothing is created until
     they've picked a direction.
  3. **Add the template to an existing GitHub repo.**

Then, by choice:

**Choices 1 and 2 — new project.** Ask for whatever wasn't given:
- **Name** of the project
- **The idea** in one or two sentences (for choice 2, a rough idea is
  fine). For choice 2, do step 1b now, before asking anything below.
- **Where** to create it (default: the folder this session was started
  in — see "Default location" below)
- **Hosting** — where will the project live? Offer two choices and
  recommend **local**:
  1. **Local only (default)** — git on this machine, no GitHub. Branches
     and commits as usual, but no remote and no PRs.
  2. **New GitHub repo** — create a repo and use the PR workflow. Also ask
     **private or public?** Recommend **private**; say that public means
     anyone can see the code and history, and that it can be changed later.

  Remember the answer as `local` or `github`.

**Choice 3 — existing GitHub repo.** Hosting is `github`; don't ask. No name
or idea is needed up front: the folder is the clone, so its name comes from
the repo name, and the idea comes from the repo itself (step 2 reads it, and
the vision interview in step 3 suggests answers from it). Let the user pick
the repo. Run
`gh repo list --limit 30 --no-archived --source --json nameWithOwner,visibility,pushedAt`
and show a numbered list, most recently pushed first: name, private or
public, last-push date. Ask: "Pick a number, or paste a URL or `owner/name`
for a repo that isn't listed." If `gh` isn't signed in or the list is empty,
just ask for the URL. If the repo isn't the user's own (a pasted one under
another owner), say that the template will add files to someone else's
code, and confirm. Also ask **where** to put the clone (default: the
folder this session was started in — see "Default location" below).

For choices 1 and 2, show the folder that will be created — the name lowercased with anything
that isn't a letter or digit turned into dashes, e.g. "Guess Game!" →
`<destination>\guess-game` — and confirm. If that folder already exists,
say so and ask for another name or location.

**Default location:** the current working directory of this session (the
folder `claude` was started in). Show the full path, e.g. "Where should it
go? Default: `<current folder>`". If that folder is the template folder
(`<template-dir>`) or inside it, or is itself inside a git repo,
say so and don't offer it as the default — ask for a location instead, so
a project isn't created inside another repo.

## 1b. Brainstorm (only for choice 2)

Nothing is created yet, so there is nothing to clean up if the idea is
dropped. These are the same steps as the project's `/brainstorm` skill,
but **write no files**:

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

Keep in mind:
- the chosen direction and why
- the options table (for the decisions log)
- the riskiest assumption and its cheap test

If the user drops the idea, stop: no folder was made. If they pick a
direction, update the project name and idea to match it, then carry on with
the questions in step 1 (where, hosting). In step 3, use the brainstorm
answers as the suggestions for each vision section, still one section at a
time and confirmed by the user.

## 2. Create it

Run, in PowerShell:

```
& "<template-dir>\new-project.ps1" -Name "<name>" -Destination "<destination>" -Hosting <local|github>
```

The script copies the template, fills in the name, writes the hosting into
`AGENTS.md`, and runs `git init` on `main`. If it fails, show the error and
stop. Don't commit anything yet.

**New GitHub repo:** right after the script succeeds, create the repo now,
so a sign-in problem or a taken name shows up before the interview:
`gh repo create <folder-name> --<private|public> --source "<folder>" --remote origin`
(no push yet). Show the repo URL. If it fails, show the error and ask:
fix it and retry, or carry on locally (then change the `AGENTS.md` line to
`**Hosting: local**`).

**Existing GitHub repo:** clone first, before anything else. Don't run the
script until the clone is done —
`gh repo clone <repo> "<destination>\<folder-name>"`. A clone doesn't change
the repo, so it's safe to do before asking. If that folder already exists,
say so and ask: use that copy as it is, or pick another destination.

Then **preview and confirm before anything is written:**
1. Run the script with `-DryRun`:
   `& "<template-dir>\new-project.ps1" -Name "<repo-name>" -Destination "<destination>" -IntoExisting -Hosting github -DryRun`
   It prints `ADD` or `KEEP` per file and changes nothing.
2. Show the result grouped, not as a long list: "Will add N files:
   `docs/` (17), `.claude/skills/` (10), `.github/`, `AGENTS.md`, …" and
   "Will keep M files your repo already has: …".
3. Say plainly: the template adds docs, workflow commands and rules to this
   repo. Files it already has are never overwritten. Nothing is committed
   or pushed until the user says so.
4. Ask: **"Go ahead and add these to the clone?"** Offer yes, no, or "let me
   pick" (skip some groups, e.g. no `.claude/skills/`). On no, stop and
   say the clone was left as it is. On "let me pick", run the script as
   below, then delete the files of the skipped groups.
5. If `AGENTS.md` or `.github/pull_request_template.md` is on the keep
   list, say the template's version won't be applied. For `AGENTS.md`, offer
   to add only the `**Hosting: github**` section from the template's Git
   section, and ask before changing anything else in it.

On a yes, **create a branch first** (`git -C "<folder>" switch -c
add-project-template`) so `main` stays clean, then run the script for real
with `-Name "<repo-name>" -Destination "<destination>" -IntoExisting -Hosting github`
(no `-DryRun`). It
copies only the template files the repo doesn't already have and leaves the
rest alone.

**Then read the repo properly** before the interview: its README and any
docs, the manifests (`package.json`, `pyproject.toml`, …), the folder
layout, the test setup, CI files, and the recent `git log`. Summarise it in
a few lines ("This looks like a Python CLI with pytest and no CI") and ask
the user to confirm or correct. Keep what you learned: the interview, the
sizing and step 6b use it, so don't re-ask what the repo already answers.

## 3. Vision interview

**Existing repo:** the vision records *what it is*, not what it should be.
Take every suggested answer from what you read in step 2. Skip "Why build
it" if the README already answers it.

Fill in `<folder>\docs\00-vision.md` with the user, one section at a time,
in this order:

1. Problem
2. Who it's for
3. Why build it (their honest motivation — it decides what "good enough"
   means)
4. Goals — 2-4 outcomes, numbered G1, G2… (outcomes, not features)
5. Success looks like — measurable where possible
6. Non-goals
7. Constraints — time, budget, platform, other
8. Assumptions and risks

For each section, **suggest** an answer drawn from the idea and earlier
answers, and let the user accept, edit, or replace it. Never write an
answer the user didn't confirm. "Skip" leaves that section's placeholder
for later. Keep the doc to one page.

If step 1b ran, also add the brainstorm's entry to
`<folder>\docs\05-decisions-log.md` (options table, decision, why,
trade-offs, revisit-if), in the format the doc's template gives.

## 4. Size the project and choose the docs

Not every project needs every doc. Decide which ones apply — **propose,
never decide silently.**

**Existing repo:** work out the answers from the code first (dependencies,
secrets, network calls, outside input, a UI, paid services) and propose
them. Ask only what the code can't tell you.

**Infer first, ask only what's left.** The idea and the vision interview
usually answer most of these. Work out your answers, say what you assumed,
and ask only about what's still unclear (one question per message, short):
1. One main piece, or several that talk to each other?
2. Single phase, or several parts built in phases? If you can't tell, ask:
   "Is this one piece built in one go, or several parts built in phases?"
3. User interface — **none**, **app or website**, or **game**?
4. Does it handle secrets, network calls, outside input, or personal data?
5. Does it cost money (paid service or assets)? Ask about a time budget
   only if the user mentioned a limit; it's their own limit and isn't used
   for sizing.

Don't ask how long it will take. When AI writes most of the code, calendar
time says little; scope does.

**Propose a size, with the reason in one line** (e.g. "Small: one script,
single phase, no network"). The user accepts or flips it:
- **Small** — one main piece, a single phase, no network calls, secrets, or
  personal data. Gets the fast path in step 6.
- **Standard** — everything else, including anything with more than one
  phase. Keeps the normal flow (`/breakdown`, `/stack`).

Size changes how much planning is written up front, **not how the code is
built**: test-first, story IDs, the Definition of Done and approval per
story apply to every project, Small included.

**Then propose which docs are needed**, as a table: doc, status, one-line
reason. The docs fall in three kinds:
- **Planning — `00`–`04`.** Always `Active`. Small projects get light
  versions (step 6).
- **Rules — `05`, `06`, `07`, `10`, `11`, `13`.** Generic text, used as-is.
  Always `Active`.
- **Situational — `08`, `09`, `12`, `14`, `15`, `16`.** `Active` only when
  the trigger is true, otherwise `Not needed`:

  | Doc | Active when… |
  |---|---|
  | `08` prompt log | cheap — keep it, but mark it `Optional` for Small |
  | `09` status report | it has more than one phase |
  | `12` manual tests | it has a UI, is a game, or has anything automated tests can't judge |
  | `14` security | it has secrets, network calls, dependencies beyond the standard library, outside input, or personal data (the security rules in `AGENTS.md` apply either way) |
  | `15` accessibility | it has a UI (follow "Does this apply?" in the doc: keep the right section, drop the other) |
  | `16` budget | money or paid services are involved, or hours are tightly limited |

The user can accept the table or flip any single doc. Then apply it:
- **`Not needed` docs are not deleted.** Replace the whole file with a stub
  so every reference to it stays valid:

  ```
  # <Original title>

  > **Not needed for this project (<one-line reason>).** Optional — add
  > content here, or restore the full version from
  > `<template-dir>\project-template\docs\<file>`, if the project
  > grows.
  ```
- Fill in the **Doc status** table in `AGENTS.md` (Active / Optional /
  Not needed, with the reason), and append "(optional)" or "(not needed)"
  to those docs' entries in the `README.md` doc list.
- If `15` is `Not needed` (no UI): add "No user interface — accessibility
  not applicable" to the vision's Non-goals and delete the NFR3 row in
  `docs\01-requirements.md`. If it applies, set NFR3 to the matching
  target.

## 5. Fill in the summaries

From the answers, replace the placeholders in:
- `README.md` — the one-or-two-sentence description, and "Project target
  (current)"
- `AGENTS.md` — the "What this project is" paragraph
- `docs\16-budget.md` → Limits, and NFR6 — from the budget constraint, if
  given and `16` is `Active`

Show the user the finished `00-vision.md` and the summaries.

## 6. Small projects: draft docs 01–04

**Standard projects skip this step** — go to step 7. **Existing repos skip
it too** — do step 6b instead; requirements aren't backfilled for code that
already exists.

For a **Small** project, don't stop at the vision. Ask only what's still
missing for `01`–`04` — a few questions: the main thing it does, its key
inputs and outputs, any language preference. Then draft all four in one
pass, light versions:
- `01-requirements.md` — one epic (with **Serves:** a goal), a few
  features, and stories with Given/When/Then criteria for the current phase
  only, including empty and worst-case inputs
- `02-architecture.md` — system context and components diagrams only; add
  other diagrams only if the project needs them
- `03-tech-stack.md` — a recommended stack (default Python; mention the
  alternatives only if the choice is really contested), and fill in the
  matching entries in `docs\05-decisions-log.md` and the Commands table in
  `AGENTS.md`
- `04-project-plan.md` — a single phase and a short Gantt chart

Show a short summary of all four and ask: **"Is this OK?"** Write the files
only on a yes; change what the user asks for first. Add new terms to
`docs\11-glossary.md`.

## 6b. Existing repos: record what exists, then what next

Only for an existing GitHub repo. Standard and Small projects skip this.

1. **Stack: detect and record, don't recommend.** Fill
   `docs\03-tech-stack.md` and the Commands table in `AGENTS.md` from what
   the repo has (run, test, lint and format commands from the manifest or
   README). Add one entry to `docs\05-decisions-log.md`: "Existing stack,
   kept as is". Don't offer a 2-3 option comparison. Anything not found
   stays a placeholder; say which.
2. **Architecture:** draft `docs\02-architecture.md` from the code layout —
   a components diagram and a short description. Show it and write it only
   after the user agrees.
3. **Baseline:** in `docs\01-requirements.md` and `docs\04-project-plan.md`,
   add one line saying the project already exists and what it does. Mark
   Phase 0 done. No stories for existing code.
4. **What next?** Ask: **"Do you want to brainstorm what to change or build
   next, or stop here?"**
   - **Brainstorm:** the same four steps as step 1b, but about the change:
     what hurts today, what the user wants, constraints. Write nothing
     until they choose a direction. Then add the options table and decision
     to `docs\05-decisions-log.md`, and suggest `/breakdown` for it.
   - **Stop here:** suggest `/breakdown` for whenever they're ready.

## 7. GitHub

By hosting choice:
- **Local only:** do nothing. Don't mention GitHub again, don't offer to
  create a repo, and leave all GitHub items in the docs unchecked (they're
  marked "GitHub only"). If the user wants GitHub later, it's one step —
  `docs/13-git-workflow.md` → Switching.
- **New GitHub repo:** the repo already exists (step 2). Make the first
  commit (`chore: start project from template`), then
  `git push -u origin main`, and show the repo URL again.
- **Existing GitHub repo:** the clone already has its remote. Ask before
  making the first commit (`chore: add project template`) and pushing the
  `add-project-template` branch from step 2 — never `main`.

## 8. Next steps

Tell the user:
1. Open a new terminal in the project and start Claude Code there, so its
   `AGENTS.md` and project commands load:
   `cd "<folder>"` then `claude`
2. **Standard:** run `/breakdown` to turn the vision into epics, features,
   and stories, then `/stack` to choose the language and tools.
   **Small:** the first five docs are done — run `/story` for the first
   story.
   **Existing repo:** run `/breakdown` for the next change (no `/stack`:
   the existing stack is already recorded). The work is on the
   `add-project-template` branch; open a PR from it once they're happy with
   the docs.
3. A doc marked "not needed" can be turned on later — the agent will
   suggest it when the project grows into it.

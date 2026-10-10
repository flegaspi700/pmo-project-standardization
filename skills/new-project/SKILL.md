---
name: new-project
description: Start a new project from the user's template at D:\Projects\Template — create the folder, then interview the user to fill in the vision doc.
argument-hint: "[project name]"
disable-model-invocation: true
---

Start a new project: $ARGUMENTS

The template lives at `D:\Projects\Template\project-template` and is
created with `D:\Projects\Template\new-project.ps1`. Work through the steps
below in order. Keep it conversational: one topic per message, short
questions.

## 1. Basics

Ask for whatever wasn't given:
- **Name** of the project
- **The idea** in one or two sentences
- **Brainstorm first?** Always ask, one short yes/no, and say "no" changes
  nothing: "Want to brainstorm this idea before creating the project?" If
  yes, do step 1b now, before asking anything below.
- **Where** to create it (default `D:\Projects`)
- **Hosting** — where will the project live? Offer three choices and
  recommend **local**:
  1. **Local only (default)** — git on this machine, no GitHub. Branches
     and commits as usual, but no remote and no PRs.
  2. **New GitHub repo** — create a repo and use the PR workflow. Also ask
     **private or public?** Recommend **private**; say that public means
     anyone can see the code and history, and that it can be changed later.
  3. **Existing GitHub repo** — let the user pick one. Run
     `gh repo list --limit 30 --no-archived --source --json nameWithOwner,visibility,pushedAt`
     and show a numbered list, most recently pushed first: name, private or
     public, last-push date. Ask: "Pick a number, or paste a URL or
     `owner/name` for a repo that isn't listed." If `gh` isn't signed in or
     the list is empty, just ask for the URL. If the repo isn't the user's
     own (a pasted one under another owner), say that the template will add
     files to someone else's code, and confirm.

  Remember the answer as `local` (choice 1) or `github` (choices 2 and 3).
  For choice 3, the folder is the clone, so its name comes from the repo
  name, not the project name.

Show the folder that will be created — the name lowercased with anything
that isn't a letter or digit turned into dashes, e.g. "Guess Game!" →
`D:\Projects\guess-game` — and confirm. If that folder already exists,
say so and ask for another name or location.

## 1b. Brainstorm (only if the user said yes)

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
& "D:\Projects\Template\new-project.ps1" -Name "<name>" -Destination "<destination>" -Hosting <local|github>
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
   `& "D:\Projects\Template\new-project.ps1" -Name "<repo-name>" -IntoExisting -Hosting github -DryRun`
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
with `-Name "<repo-name>" -IntoExisting -Hosting github` (no `-DryRun`). It
copies only the template files the repo doesn't already have and leaves the
rest alone.

Then read what the repo already has (its README, any docs, the code
layout) before the interview, and use it to suggest answers.

## 3. Vision interview

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

**Ask** (skip anything the vision interview already answered; one question
per message, short):
1. Rough duration — days, weeks, or months?
2. One main piece, or several that talk to each other?
3. User interface — **none**, **app or website**, or **game**?
4. Does it handle secrets, network calls, outside input, or personal data?
5. Does it cost money (paid service or assets) or have a tight hour
   budget?

**Propose a size:**
- **Small** — about two weeks or less, one main piece, no network calls,
  secrets, or personal data. Gets the fast path in step 6.
- **Standard** — everything else. Keeps the normal flow (`/breakdown`,
  `/stack`).

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
  | `09` status report | it runs longer than ~2 weeks or has more than one phase |
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
  > `D:\Projects\Template\project-template\docs\<file>`, if the project
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

**Standard projects skip this step** — go to step 7.

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
3. A doc marked "not needed" can be turned on later — the agent will
   suggest it when the project grows into it.

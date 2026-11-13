# Changelog

Notable changes to the standard. Versions are git tags (`v1.0.0`, ...). From
v2, a project pins the version it follows in `AGENTS.md`
(`**Standard:** pmo-project-standardization vX.Y.Z`); each entry says what a
project must do to move to that version, if anything.

## v2.1.0 (2026-11-13)

Fixes from rolling v2 out to six repos. **Projects need to do nothing** to
move from v2.0.0; the standard's rules only gained two sentences in
`sessions.md`.

- **`/report` asks whether the program is still right**, so a project's
  dashboard group can change any time. Reporting contract: `program` is
  written by `/new-project`, then `/report`.
- **`/report` works in reporting-only repos** (just `portfolio.json`): the
  preflight lets it through, and it asks only the judgment calls and the
  program. Every other skill still stops there and offers to adopt.
- **Compliance:** W1 (`CLAUDE.md` loads `AGENTS.md`) applies only to repos
  with a Standard line, so a reporting-only repo with a `CLAUDE.md` no
  longer warns. Grace-period warnings (and the scanner's S3) are listed
  only for repos at Adopted or higher: for a Reporting repo, the checks it
  fails are the step to Adopted, not a change coming due.
- **`/new-project`** on an existing repo formats the added files with the
  repo's own formatter when its CI checks Markdown or JSON, and follows the
  repo's own prose rules (for example "no em dashes").
- `tests/check-template.ps1`: tests the W1 scope and the grace-period
  rule (a reporting-only repo lists none; an adopted repo failing C10
  still does).

## v2.0.0 (2026-11-13)

**Shared standard, small footprint.** The rules now live once in this repo
(`standard/`), the workflow commands are installed once per machine
(`skills/`, `install-skills.ps1`), and each project gets five starter files
instead of 33. Decision: `DECISIONS.md`, 2026-11-13.

**Breaking:**
- `project-template/`, `/update-template` and `update-plan.ps1` are removed.
  v1 projects keep their own copy of the v1 rules and skills; the v1
  template and tools stay available at tag `v1.5.1`.
- Compliance spec version 2: v1 projects rate as level 1 (Reporting) until
  they move to v2. C8, C9 and C10 are required from 2026-12-13.

**Moving a v1 project to v2** (on a branch, then a PR):
1. Replace `AGENTS.md` with `scaffold/AGENTS.md`; move the project's own
   content (what it is, commands, architecture rules, things not to do)
   into its sections.
2. Merge `docs/00-vision.md`, `01-requirements.md` and `04-project-plan.md`
   into `docs/requirements.md` (vision, Phases table, epics to stories,
   NFRs, bugs); rename `05-decisions-log.md` to `decisions.md` and
   `10-session-log.md` to `session-log.md`.
3. Docs with real project content become extras (`architecture.md`,
   `security.md`, `accessibility.md`, `budget.md`, `manual-tests.md`); the
   tech stack becomes a decision entry if it isn't one already. Delete the
   rest of the numbered docs, `.claude/skills/` (the v1 copies; W4) and
   `.github/pull_request_template.md`. Git keeps the history.
4. `check-compliance.ps1` should show level 3.

**Release notes, by build step:**

- **`standard/`** (v2 build step 2): the rules, kept once in this repo instead of copied into every project. One file per topic: requirements, decisions, coding, testing, git, security, sessions and reporting, plus accessibility and cost for projects they apply to. Taken from the v1 `AGENTS.md` and docs 01, 02, 05-07, 10, 12-16, with the duplication between `AGENTS.md` and the docs removed. Not used by projects yet: `project-template/` is unchanged until v2.0.0.
- **v2 skills** (build step 3): `/a11y-check`, `/brainstorm`, `/breakdown`, `/decide`, `/fix-bug`, `/report`, `/security-check`, `/stack`, `/story` and `/wrap-up` in `skills/`, installed once for the user instead of copied into each project. They use the v2 project files (`docs/requirements.md`, `docs/decisions.md`, `docs/session-log.md`, and the extras when present) and read the rules from `standard/`. Each runs `skills/preflight.md` first: it stops in a repo without a `Standard:` line (offering to adopt the standard) or in a v1 project (pointing to its own skills), and reads the rules as they were at the project's version: the local copy, then `git show` at the tag, then GitHub. `/report` no longer writes a status report doc: it updates `portfolio.json`, and records a phase retrospective in the session log.
- `install-skills.ps1`: links every skill in `skills/` into `%USERPROFILE%\.claude\skills\` as junctions; never overwrites, `-DryRun` previews.
- `tests/check-template.ps1`: checks every v2 skill runs the preflight and looks itself up by its own name, and exercises `install-skills.ps1` against a throwaway profile.
- **`scaffold/`** (build step 4): the v2 starter files. Every project gets `AGENTS.md` (about 60 lines: the standard version, hosting, commands, seven core rules, project-specific notes), `portfolio.json`, `docs/requirements.md` (vision, Phases table, stories, NFRs, bugs), `docs/decisions.md` and `docs/session-log.md`; new repos also get `README.md` and `.gitignore`. `scaffold/extras/` holds `docs/security.md`, `accessibility.md`, `architecture.md`, `budget.md`, `manual-tests.md` and `.env.example`, which the agent adds only when a project needs them. No PR template: the Definition of Done lives in the standard.
- **`new-project.ps1` rewritten for v2:** copies `scaffold/` instead of `project-template/` and stamps `**Standard:** pmo-project-standardization <version>` (v2.0.0 until that release, with a warning). New `-ReportOnly` adds only `portfolio.json`. Flags a `CLAUDE.md` that needs `@AGENTS.md`, but never edits it. Works in a template folder without git tags.
- **`/new-project` rewritten for v2** (about 190 lines, from 360): four choices (new project; new project with a brainstorm; put an existing repo on the standard; dashboard only). No sizing step and no eight-section interview: it drafts the vision paragraph in one go and proposes which extras apply. Existing repos go on a `chore/adopt-standard` branch and a PR; a `CLAUDE.md` gets `@AGENTS.md` as its first line, only on a yes. Ends by checking the v2 skills are installed.
- `tests/check-template.ps1`: tests the v2 starter files, `-IntoExisting` (with a `CLAUDE.md` that must stay unchanged) and `-ReportOnly`; the `/update-template` planner tests now generate their v1 project from the v1.5.1 tag. Fresh v2 projects are expected at compliance level 1 until the v2 checks arrive (build step 5).
- **Compliance spec version 2** (build step 5): **Adopted** is now `portfolio.json` (C4) + the Hosting line (C2) + the `**Standard:**` line (C8, new) + `docs/requirements.md`, `decisions.md` and `session-log.md` (C9, new). **Current** adds C10 (new): the Standard line names v2. C8, C9 and C10 are required from 2026-12-13 (v2.0.0 release + 30 days). The v1 layout checks (C1, C3, C6, C7, W2) become optional and apply only to v1 projects, so v1 projects show as Reporting until they move to v2. W1 now needs an `@AGENTS.md` line in `CLAUDE.md`, not just a mention. New warnings: W3 (unfilled placeholders in `docs/requirements.md`) and W4 (v1 copies of the standard's skills in `.claude/skills/`, which would run instead of the installed ones). `check-compliance.ps1` shows the standard version from the Standard line, or the v1 stamp marked "(v1 template)".

## v1.5.1 (2026-10-25)

- `/update-template` handles barely-filled-in projects (found in the second pilot): placeholders are never copied or counted; `summary` falls back to `AGENTS.md` or the README when the vision is unfilled; `progress` is `null` without real stories; `budget` is `null` while doc `16`'s limits are placeholders; placeholder-only template changes are recognised as nothing to merge; the test step says when there's no test command; warnings about the project's own unfinished docs are reported, not fixed.

## v1.5.0 (2026-10-25)

- **`/update-template`** (user-level command, `skills/update-template/`): updates an existing project to the newest template version on a branch. Plans the changes, shows what's new since the project's version, adds or replaces files the project never changed, merges the template's changes into files it did change (keeping its own edits), fills in `portfolio.json` with the user (judgment fields drafted from the docs, confirmed by the user), stamps the version, and checks compliance before and after the grace periods. Install with a junction, like `/new-project`.
- `update-plan.ps1` (read-only): finds the project's base version (its stamp, or the oldest tag whose skills match best), and sorts every template file changed since then into ADD, REPLACE, MERGE, UP-TO-DATE or REVIEW. Ignores line endings; reads old versions from git tags as UTF-8.
- `tests/check-template.ps1` checks the planner against fixed tags (each action, CHANGELOG entries, base detection).

## v1.4.0 (2026-10-25)

- **Compliance spec:** when a repo counts as on the standard, judged by evidence in the repo, not by its version stamp. Levels 0 Not on standard, 1 Reporting (only `portfolio.json`), 2 Adopted, 3 Current; required checks get a 30-day grace period; `CLAUDE.md` and unfilled planning docs are warnings; archived repos, forks and repos tagged `portfolio-exclude` are out of scope. Spec in `spec/compliance.md`, checks in `spec/compliance-checks.json`.
- `check-compliance.ps1`: run the checks against any local repo folder and see its level, failures and warnings. Changes nothing.
- Compliance: C1-C3 (core structure) required from 2026-11-09, C4 (`portfolio.json`) required from 2026-11-24; C5-C7 optional; W1-W2 warnings.
- `tests/check-template.ps1` confirms fresh projects reach level 3 and checks the registry.

## v1.3.0 (2026-10-25)

- **Reporting contract:** every project gets a `portfolio.json` with what it reports to the portfolio: owner, sponsor, program, lifecycle, health, phase, progress, next milestone, risks, blockers, call-outs, budget. Spec in `spec/reporting-contract.md`, JSON Schema in `spec/portfolio.schema.json`. `/new-project` fills summary, owner, sponsor and program; `/report` updates health, risks, blockers, call-outs, phase, progress and budget (also on Small projects); `/wrap-up` refreshes progress only. New `AGENTS.md` section: Portfolio reporting. `tests/check-template.ps1` checks the generated file and the spec's example against the schema.

## v1.2.0 (2026-10-25)

- New projects record the template version they were created from: `AGENTS.md` gets a `Template version` line, filled by `new-project.ps1` from the template's git tag (e.g. `v1.1.0`, or `v1.1.0-3-gabc1234` between releases). `-IntoExisting` only stamps it if it adds `AGENTS.md`; an existing `AGENTS.md` is never changed.

## v1.1.0 (2026-10-25)

- No hard-coded `D:\Projects\Template` paths. `/new-project` finds the template folder from its own junction, and `new-project.ps1` fills a new `<template-dir>` placeholder with the folder it runs from, so the template works from any location.
- `tests/check-template.ps1`, run locally before each PR: generates a project and an `-IntoExisting` copy, then checks for unfilled placeholders, broken links and `docs/NN-*.md` references, skill frontmatter, and that the brainstorm steps in `/new-project` match `/brainstorm`.
- `AGENTS.md` rule: text files are UTF-8 without a BOM, with how to read and write them safely in Windows PowerShell 5.1 (its default read garbles characters like `—`). `tests/check-template.ps1` now fails on files that aren't valid UTF-8 or contain that garbling.

## v1.0.0 (2026-10-10)

First release.

### Template (`project-template/`)

- `AGENTS.md` only (no `CLAUDE.md`), language-neutral; the agent recommends a stack in Phase 0.
- Docs 00 vision to 16 budget: requirements as Epic, Feature, Story with a Definition of Done and NFRs; architecture, tech stack, plan (Mermaid Gantt), decisions (ADRs), coding, testing, git, security, accessibility, budget.
- Doc status table in `AGENTS.md`: docs a project doesn't need become marked one-line stubs.
- Hosting setting (`local` or `github`) that the skills and docs follow.
- Project skills: `/breakdown`, `/stack`, `/decide`, `/story`, `/fix-bug`, `/report`, `/wrap-up`, `/security-check`, `/a11y-check`, `/brainstorm`.
- PR template and `.gitignore`.

### `new-project.ps1`

- Copies the template, fills in the name and hosting, runs `git init` on `main`.
- `-Hosting local|github`, `-IntoExisting` to add the template to a cloned repo (with `-DryRun` to preview first).
- Creates the project in the current folder by default (`-Destination` to change).

### `/new-project` skill

- Opens with: new project, new project after brainstorming, or existing GitHub repo.
- Existing repo: pick from a list, clone, preview the files, confirm, then record what exists and offer to brainstorm next steps.
- Vision interview, then sizing by scope (Small or Standard) with a per-doc table to approve. Small projects also get drafts of docs 01 to 04.

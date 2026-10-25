# Changelog

Notable changes to the project template. Versions are git tags (`v1.0.0`, ...).
Projects keep the copy they were created from, so this list shows what newer
projects get that older ones don't.

## Unreleased

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

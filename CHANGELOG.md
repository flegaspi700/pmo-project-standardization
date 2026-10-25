# Changelog

Notable changes to the project template. Versions are git tags (`v1.0.0`, ...).
Projects keep the copy they were created from, so this list shows what newer
projects get that older ones don't.

## Unreleased

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

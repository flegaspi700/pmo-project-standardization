# <Project name>

<One or two sentences: what this project is and what it does.>

> **Using this template:** start the project with `/new-project` in Claude
> Code — it creates the folder and interviews you for the vision doc. (Or
> run `<template-dir>\new-project.ps1 -Name "<Project name>"` and fill
> in `docs/00-vision.md` yourself.) Then `/breakdown`, `/stack`, and the
> rest of `docs/00` → `docs/04` (vision, requirements, architecture, tech
> stack, plan). Search for `<` to find remaining placeholders. Delete this
> note when done.
>
> AI agents (Claude Code, Codex, Cursor, ...) read `AGENTS.md` automatically.
> Don't add a `CLAUDE.md` here or in any parent folder (e.g. the folder
> that holds all your projects): if one exists, Claude Code reads it
> instead and ignores `AGENTS.md`.

## Docs

Not every doc applies to every project — `AGENTS.md` → Doc status says
which are active. Docs marked "(optional)" or "(not needed)" below are
stubs you can ignore until the project grows into them.

- [`AGENTS.md`](AGENTS.md) — context file for AI coding agents, read this first each session
- [`docs/00-vision.md`](docs/00-vision.md) — why we're building this: problem, goals, success criteria, non-goals
- [`docs/01-requirements.md`](docs/01-requirements.md) — requirements as epics → features → stories, with acceptance criteria
- [`docs/02-architecture.md`](docs/02-architecture.md) — system design and data flow
- [`docs/03-tech-stack.md`](docs/03-tech-stack.md) — libraries and tool choices, with rationale
- [`docs/04-project-plan.md`](docs/04-project-plan.md) — phased plan, status, and Gantt timeline
- [`docs/05-decisions-log.md`](docs/05-decisions-log.md) — running log of design decisions (ADR-style)
- [`docs/06-coding-conventions.md`](docs/06-coding-conventions.md) — file layout, naming, style rules
- [`docs/07-testing-checklist.md`](docs/07-testing-checklist.md) — testing strategy (kinds of tests, test-first, bugs) and per-change checklist
- [`docs/08-prompt-log.md`](docs/08-prompt-log.md) — built-in commands, plus reusable prompts for AI-assisted coding on this project
- [`docs/09-status-report.md`](docs/09-status-report.md) — weekly / per-phase progress reports, with retrospectives
- [`docs/10-session-log.md`](docs/10-session-log.md) — handoff notes at the end of each working session
- [`docs/11-glossary.md`](docs/11-glossary.md) — project terms, so code and docs use the same words
- [`docs/12-manual-tests.md`](docs/12-manual-tests.md) — manual test steps and results for what automated tests can't judge
- [`docs/13-git-workflow.md`](docs/13-git-workflow.md) — branches, commit messages, merging, and switching local ↔ GitHub (GitHub Flow)
- [`docs/14-security.md`](docs/14-security.md) — threat model, secrets, dependencies, input handling, GitHub security setup (GitHub only)
- [`docs/15-accessibility.md`](docs/15-accessibility.md) — WCAG 2.2 AA (apps/web) or game accessibility checklist; delete if no UI
- [`docs/16-budget.md`](docs/16-budget.md) — money and time: limits, recurring/usage costs, monthly log

## Commands (Claude Code)

Workflow commands in `.claude/skills/` — type them in Claude Code, started
in this folder:

| Command | What it does |
|---|---|
| `/brainstorm` | Optional, for a fuzzy idea: explore directions, pick one, record it in the vision |
| `/breakdown` | Turn the vision or an epic into features and stories |
| `/stack` | Choose and record the language and tools |
| `/decide` | Compare options for a design choice and log the decision |
| `/story S1.2.3` | Build a story: branch, tests first, Definition of Done, then PR (GitHub) or local merge. Also `/story F1.2` (whole feature) or `/story E1` (whole epic, approval per feature) |
| `/fix-bug` | Log a bug, reproduce it with a failing test, fix it |
| `/report` | Status report, Gantt update, retrospective at phase end |
| `/wrap-up` | End-of-session handoff note |
| `/security-check` | Security review of recent changes |
| `/a11y-check` | Accessibility check of changed screens |

## Quick start

1. Open this folder in your editor (`code .`)
2. <Install the toolchain / create the environment — see `docs/03-tech-stack.md`>
3. <Install dependencies>
4. <How to run it>
5. <How to run the tests>
6. Start with Phase 0 in the project plan

## Project target (current)

<Scope of the current version: what's in, what's explicitly out.>

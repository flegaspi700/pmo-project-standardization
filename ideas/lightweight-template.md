# Draft: lightweight template (v2)

Status: **agreed design, not built yet.** Implements the 2026-11-13
decision in [`DECISIONS.md`](../DECISIONS.md). The user's answers to the
open questions are at the bottom.

## The idea in one line

The standard lives here, once. Each project carries only what is specific
to it, and a pointer to the standard version it follows.

## What a project gets

```
AGENTS.md              ~50 lines: what this is, which standard version, core rules, links
portfolio.json         status for the dashboard (unchanged contract)
docs/requirements.md   one-paragraph vision + epics / features / stories + phases
docs/decisions.md      decision records (ADRs)
docs/session-log.md    handoff notes between sessions
```

Five files, down from 33. Opt-in extras, added only when the project needs
them (the agent suggests one when the project grows into it):

| Extra | Add when |
|---|---|
| `docs/security.md` (threat model lite) | Network access, secrets, personal data or outside input |
| `docs/accessibility.md` | It has a UI |
| `docs/architecture.md` | More than one component, or a design trade-off worth drawing |
| `docs/budget.md` | It costs money |
| `docs/manual-tests.md` | Things the automated tests can't cover |

Dropped as separate files: the Gantt plan (phases become a Phases table
at the top of `requirements.md`), status report (replaced by `portfolio.json` and the
dashboard), prompt log, glossary and tech-stack doc (the stack becomes a
decision in `decisions.md` plus the commands in `AGENTS.md`).

## The per-repo `AGENTS.md`

```markdown
# <Project name>

<One sentence: what it is and who it's for.>

**Standard:** pmo-project-standardization v2.0.0
**Hosting:** github
**Program:** <group on the dashboard>

## Commands
- Run: ...
- Test: ...
- Lint: ...

## Core rules (full standard: <link to the standard at v2.0.0>)
- Work from a story in docs/requirements.md; one branch and PR per story.
- Test first. Never weaken a test to make it pass.
- Simplest code that works. Trade-offs: 2-3 options, user decides, log in docs/decisions.md.
- No secrets in the repo. No new dependency or cost without a logged decision.
- Files are UTF-8.
- End each session with /wrap-up: session log and portfolio.json.

## Project-specific notes
<anything this repo needs that the standard doesn't cover>
```

The core rules are the handful an agent must follow even if it never opens
the link. Everything else (conventions, testing checklist, git workflow,
security, accessibility) is in the standard.

## What lives in this repo

```
standard/       the rules, one file per topic (from today's docs 05-07, 10, 11, 13-15)
skills/         every skill, installed once for the user (junctions, like /new-project today)
scaffold/       the 5 per-repo files
spec/           portfolio.json schema + compliance checks (updated for v2)
```

Rules are versioned by git tag, so a project pinned to v2.0.0 always reads
the same rules, and the dashboard shows which projects are behind.

## Adopting it in an existing repo

1. Branch `chore/adopt-standard`.
2. Add the five files, never overwriting anything. Fill `AGENTS.md` and
   `requirements.md` from the README and the code; ask only what the code
   can't tell (program, hosting, health).
3. If the repo has a `CLAUDE.md`, add one line at its top:
   `Read AGENTS.md first: it holds this repo's standard.` That's the only
   edit to an existing file, and it's shown before it's made.
4. PR. Nothing is merged without the user saying so.

No vision interview, no sizing step, no backfilled stories for code that
already exists.

## Compliance levels in v2

| Level | Name | Earned when |
|---|---|---|
| 0 | Not on standard | - |
| 1 | Reporting | Valid `portfolio.json` |
| 2 | Adopted | Level 1, plus `AGENTS.md` with a `Standard:` line, `docs/requirements.md` and `docs/decisions.md` |
| 3 | Current | Adopted, on the latest standard major version, and every due check passes |

A `CLAUDE.md` without the pointer line becomes a warning instead of hiding
the standard.

## Build order (one PR each)

1. This decision and draft.
2. `standard/`: move the rules out of the v1 docs, shorten where they repeat.
3. Skills installed for the user, reading the standard from this repo.
4. `scaffold/` + a rewritten, much shorter `/new-project` (new and existing repo).
5. Compliance spec and `check-compliance.ps1` for v2; `check-template.ps1` updated.
6. Migrate `ocr-pipeline` and `portfolio-dashboard`; release v2.0.0.

Then the dashboard can go ahead, and the other repos adopt v2 one short PR
at a time.

## Answered questions (2026-11-13)

- **How skills find the standard:** the local template folder first (found
  through the skill's junction, as `/new-project` does today); the GitHub
  link pinned to the project's version is the fallback when there's no
  local copy.
- **Skills in repos not on the standard:** every skill first looks for the
  `Standard:` line in `AGENTS.md`. If it's missing, the skill stops and
  offers to adopt the standard instead of running.
- **v1 projects:** migrate `ocr-pipeline` and `portfolio-dashboard` to v2
  (build step 6). v1 isn't kept alive: `/update-template` is only
  rewritten if v2 still needs it.
- **Programs:** free text in `portfolio.json` → `program` (the schema
  already allows any string). Revisit a fixed list once the dashboard shows
  which names get used.
- **Learning and course repos:** start with `portfolio.json` only
  (Level 1). They can take the five files later if they grow into real
  projects.

## Rollout after v2.0.0

- **Level 1 only:** learning and course repos get `portfolio.json` with
  `program` set. One new file per repo, nothing else touched.
- **Level 2:** repos being actively built get the five files.

# The standard

How every project is planned, built, tested, secured and reported. It lives
here, once. Projects don't copy it: each project's `AGENTS.md` names the
version it follows and lists a few core rules, and links here for the rest.

> **Work in progress (v2).** This folder is being built for v2.0.0 (see
> [`DECISIONS.md`](../DECISIONS.md), 2026-11-13). Until v2.0.0 is released,
> projects created from `project-template/` follow the rules in their own
> docs.

## How a project uses it

A project on the standard has this line in its `AGENTS.md`:

```
**Standard:** pmo-project-standardization v2.0.0
```

The version is a git tag of this repo. A project reads the rules as they
were at that tag, so a change here never changes the rules under a project
by surprise. Moving a project to a newer version is a deliberate change,
listed in [`CHANGELOG.md`](../CHANGELOG.md).

**Agents and skills read the rules from the local copy of this repo first**
(found the same way the skills find the template), and from GitHub at the
project's tag when there's no local copy.

**When a project's `AGENTS.md` and the standard disagree,** `AGENTS.md`
wins for that project: it's how a project records a deliberate exception.
Point out the conflict when you notice one.

## The files

**Always apply:**

| File | Covers |
|---|---|
| [requirements.md](requirements.md) | Breaking work down: epics, features, stories, phases, the Definition of Done, NFRs, bugs |
| [decisions.md](decisions.md) | When a choice needs options compared, and how it's logged |
| [coding.md](coding.md) | Simplicity, file layout, notes and comments, errors, logging, text encoding |
| [testing.md](testing.md) | Test-first, reliable tests, bugs, coverage, checklists |
| [git.md](git.md) | Branches, commits, PRs, hosting `local` or `github` |
| [security.md](security.md) | Secrets, dependencies, input, privacy, AI-agent risks |
| [sessions.md](sessions.md) | Working with an agent, start and end of a session, reporting to the portfolio |

**Apply when the project has the thing they cover:**

| File | Applies when the project |
|---|---|
| [accessibility.md](accessibility.md) | Has a user interface |
| [cost.md](cost.md) | Costs money, or might |

## What a project holds

The standard holds the rules. A project holds only what's specific to it:

| File | Holds |
|---|---|
| `AGENTS.md` | What the project is, the standard version, hosting, program, commands, core rules, project-specific notes |
| `portfolio.json` | Its status for the portfolio ([reporting contract](../spec/reporting-contract.md)) |
| `docs/requirements.md` | A one-paragraph vision, phases, epics, features, stories, NFRs, bugs |
| `docs/decisions.md` | Its decision records |
| `docs/session-log.md` | Handoff notes between sessions |

Extra docs, added only when the project needs them (the agent suggests one
when the project grows into it, and never adds one silently):

| File | Add when | Rules in |
|---|---|---|
| `docs/security.md` | The project has network access, secrets, personal data or outside input | [security.md](security.md) |
| `docs/accessibility.md` | It has a user interface | [accessibility.md](accessibility.md) |
| `docs/architecture.md` | It has more than one component, or a design worth drawing | [decisions.md](decisions.md) |
| `docs/budget.md` | It costs money | [cost.md](cost.md) |
| `docs/manual-tests.md` | Some things can only be checked by a person | [testing.md](testing.md) |

## Changing the standard

A change here is a change for every project that moves to the new version.

- One branch and PR per change, like any other work ([git.md](git.md)).
- Add a `CHANGELOG.md` entry in the same PR, saying what a project must do
  to move to the new version, if anything.
- Breaking changes (a project must change something to stay compliant) need
  a new major version and a logged decision in `DECISIONS.md`.
- If a rule becomes checkable, add the check to
  [`spec/compliance-checks.json`](../spec/compliance-checks.json).

# Requirements

What a project builds, and how you know each piece is done. Everything lives
in the project's `docs/requirements.md`.

## The breakdown

**Epic → Feature → Story**, grouped into **phases**.

| Level | What it is | Size |
|---|---|---|
| **Epic** | A large capability or outcome | Usually spans several phases |
| **Feature** | A piece of an epic that's useful on its own | Fits in one phase |
| **Story** | The smallest unit of work: one prompt-sized change, with testable acceptance criteria | If it touches several components or feels big, split it |
| **Phase** | A stage of the project with a goal and exit criteria | As many as the project needs; small projects have one |

Rules:

- **Top-down, and only as far as needed.** Write the epics first, then the
  features, then stories for the current and next phase only. Stories for
  later phases get written when you reach them. A small project can have
  one epic, a few features and one phase. Don't pad it to look complete.
- **Every epic serves the vision** (the paragraph at the top of
  `docs/requirements.md`). An epic that doesn't is out of scope until the
  vision changes.
- **IDs are stable:** `E1`, `F1.2`, `S1.2.3`, `B4`, `NFR2`. Never renumber.
  A removed item gets the status `Dropped` and stays.
- **Reference IDs everywhere:** branch names, commits, prompts, file header
  notes.
- **Existing code isn't backfilled.** When a project adopts the standard,
  write stories for new work only.

**Statuses:** `Backlog` → `Ready` (acceptance criteria written) →
`In progress` → `Done`, or `Dropped`.

## Phases

`docs/requirements.md` starts with a Phases table:

| Phase | Goal | Exit criteria | Status | Started | Finished |
|---|---|---|---|---|---|
| 1 | What this phase delivers | How you'll know it's finished | Planned / Active / Done | dates | dates |

Each feature names its phase. Work on the current phase only; don't start
later-phase work unless the user asks. Update the table when a phase
starts or finishes.

## Writing a story

```
#### S1.2.3 — <title>

**Story:** As a <user>, I want <capability>, so that <benefit>.
(Technical stories: "Technical — <what must exist or change, and why>.")
**Status:** Backlog

**Acceptance criteria:**
- [ ] Given <starting state>, when <action>, then <observable result>
- [ ] <edge case: empty, missing or invalid input>
- [ ] <edge case: largest or worst realistic input>

**Notes:** <links, constraints, related decisions>
```

A feature has a **Done when** line: how you'll see its stories working
together ("can demo X end to end on real input").

## Working through stories

- **One story at a time**, with the user's approval after each. If a
  request doesn't map to a story, say so and suggest adding one first.
- **A whole feature or epic on request** (`/story F1.2`): build its stories
  one after the other, each still test-first and through the Definition of
  Done, with one approval per feature. Stop if a story fails its Definition
  of Done, a test fails, or a design choice comes up.
- **Never change acceptance criteria to fit the code.** If a criterion
  looks wrong, flag it and let the user decide.
- When a story is done, update its status in `docs/requirements.md`.

## Definition of Done

A story is `Done` only when it meets its own acceptance criteria and every
item below. The list is the same for every story. A project that needs more
checks adds them under project-specific notes in its `AGENTS.md`.

- [ ] Each acceptance criterion has a test, written first and seen failing.
      The tests now pass, and the output has been seen, not just reported.
- [ ] No test was deleted, skipped or weakened to get there.
- [ ] The full test suite passes.
- [ ] The code is the simplest version that works ([coding.md](coding.md)).
- [ ] New and changed files have header notes; non-obvious functions have
      doc comments; existing notes still match the code.
- [ ] Any significant choice is logged in `docs/decisions.md`
      ([decisions.md](decisions.md)); diagrams, if the project has them,
      still match the code.
- [ ] No non-functional requirement is broken.
- [ ] Security checks for the change pass ([security.md](security.md));
      accessibility checks too if the UI changed
      ([accessibility.md](accessibility.md)).
- [ ] The story's status is updated in `docs/requirements.md`.

A **feature** is done when all its stories are done, its integration and
manual tests pass ([testing.md](testing.md)), and its **Done when** line has
been demonstrated. An **epic** is done when all its features are.

## Non-functional requirements

Qualities the whole system must have: how fast, secure, accessible,
reliable or cheap. They apply to every story and are checked at the end of
each phase.

- Each one is **measurable**: not "fast", but "at least 20 updates per
  second on the target machine".
- Add only the ones that matter for this project. Common ones: security
  (no known high-severity vulnerabilities in dependencies), accessibility
  (if there's a UI), privacy (if there's personal data), cost (if it costs
  money).

| ID | Category | Requirement (measurable) | How verified | Status |
|---|---|---|---|---|

**Statuses:** `Not met yet`, `Met` (with the date last verified), `At risk`.

## Bugs

Bugs found in finished work get an ID and a regression test before they're
fixed ([testing.md](testing.md) → Bugs). A small bug found while a story is
still in progress is just part of that story.

| ID | Title | Found in | Severity | Status | Test |
|---|---|---|---|---|---|

Each bug also gets steps to reproduce, expected and actual behaviour.
**Statuses:** `Open` → `In progress` → `Fixed`, or `Won't fix` (with the
reason).

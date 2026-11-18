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
  write stories for new work only. The same goes for a newer version of
  the standard: its formats (criteria tags, designs) apply to stories and
  features written after the move.

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
- [ ] AC1 [unit] Given <starting state>, when <action>, then <observable result>
- [ ] AC2 [unit] <edge case: empty, missing or invalid input>
- [ ] AC3 [integration] <edge case: largest or worst realistic input>

**Notes:** <links, constraints, related decisions>
```

**Criteria are numbered and tagged.** Number them `AC1`, `AC2`, ... in
order; like other IDs, they're never renumbered. Elsewhere, refer to one as
`S1.2.3 AC2`. The tag says how it's checked, and so which kind of test it
gets ([testing.md](testing.md)):

| Tag | Checked by |
|---|---|
| `[unit]` | A unit test |
| `[integration]` | A test of components working together through their real interfaces |
| `[e2e]` | An end-to-end test, run the way a user would |
| `[manual]` | A person, in `docs/manual-tests.md`; the criterion says exactly what to look at |

**Tick a criterion when it's met:** `- [x]` once its test passes (or, for
`[manual]`, once the check is recorded). A `Done` story has every box
ticked, so the file shows at a glance what's built.

A feature has two lines under its title:

```
### F1.2 — <title>

**Done when:** <how you'll see its stories working together, e.g. "can
demo X end to end on real input">
**Design:** not needed | docs/design/F1.2.md (Draft | Approved YYYY-MM-DD)
```

**Done when** is the feature's **acceptance test**: written first and seen
failing when the feature starts, passing once its last story is done
([testing.md](testing.md) → Outside-in). If it can't be automated, tag it
`[manual]` and record it in `docs/manual-tests.md`.

## Designing a feature

Most features go straight from their stories to tests. A feature **needs a
design** when any of these is true:

- it adds a component, module or service
- it changes a public interface, a data format or what's stored
- it has more than 3 stories

`/breakdown` sets each feature's **Design:** line by these rules, and the
user can override it. **No story of a feature that needs a design is built
until the design is `Approved`.** `/design F1.2` writes it.

A design is one short file, `docs/design/F1.2.md`, about a page:

```
# F1.2 — <title>: design

**Status:** Draft | Approved YYYY-MM-DD

**Approach:** How the feature works, in a paragraph.
**Components touched:** New and changed modules, files or services.
**Interfaces and data:** Function signatures, formats, stored data, as
exact as they're known.
**Risks:** What could go wrong, and how the design guards against it.
**Test approach:** The feature's acceptance test, and which criteria are
`[integration]` or `[e2e]`.
**Decisions:** Links to the entries in `docs/decisions.md`. Significant
choices are still logged there ([decisions.md](decisions.md)).

## Changes
- YYYY-MM-DD: <what changed after approval, and why>
```

Rules:

- **Approval is the user's.** The agent drafts, the user approves, and the
  status gets the date.
- **Changing an approved design:** change the file in the same commit as
  the code that needs it, and add a dated line under Changes. Never let
  the code drift from the design silently.
- If the project has `docs/architecture.md`, the lasting parts of a design
  (components, interfaces) go there once the feature is done.

## Working through stories

- **One story at a time**, with the user's approval after each. If a
  request doesn't map to a story, say so and suggest adding one first.
- **A whole feature or epic on request** (`/story F1.2`): build its stories
  one after the other, each still test-first and through the Definition of
  Done, with one approval per feature. Stop if a story fails its Definition
  of Done, a test fails, or a design choice comes up. Merging follows
  [git.md](git.md): only on the user's say-so.
- **A whole phase on request** (`/story phase`): every `Ready` story in the
  current phase, feature by feature, with one approval up front: the user
  reviews the list of stories and says whether each feature's PR may be
  merged as it goes. Every feature that needs a design must have it
  `Approved` before the run starts. Same stop conditions, plus red CI. At
  the end, check
  the phase's exit criteria; with the user's OK, set the phase to `Done` in
  the Phases table and offer `/breakdown` for the next phase. Later phases
  aren't built in the same run: their stories aren't written yet.
- **Never change acceptance criteria to fit the code.** If a criterion
  looks wrong, flag it and let the user decide.
- When a story is done, update its status in `docs/requirements.md`.

## Definition of Done

A story is `Done` only when it meets its own acceptance criteria and every
item below. The list is the same for every story. A project that needs more
checks adds them under project-specific notes in its `AGENTS.md`.

- [ ] Each acceptance criterion has a test of its tagged kind, written
      first and seen failing, that names the criterion (`S1.2.3 AC2`).
      `[manual]` criteria are recorded in `docs/manual-tests.md`. The tests
      now pass, and the output has been seen, not just reported.
- [ ] No test was deleted, skipped or weakened to get there.
- [ ] The full test suite passes.
- [ ] The code is the simplest version that works ([coding.md](coding.md)).
- [ ] New and changed files have header notes; non-obvious functions have
      doc comments; existing notes still match the code.
- [ ] Any significant choice is logged in `docs/decisions.md`
      ([decisions.md](decisions.md)); the feature's design, if it has one,
      and diagrams, if the project has them, still match the code.
- [ ] No non-functional requirement is broken.
- [ ] Security checks for the change pass ([security.md](security.md));
      accessibility checks too if the UI changed
      ([accessibility.md](accessibility.md)).
- [ ] The story's criteria are ticked and its status is updated in
      `docs/requirements.md`.

A **feature** is done when all its stories are done, its acceptance test
passes (or, if `[manual]`, has been checked and recorded), its integration
and manual tests pass ([testing.md](testing.md)), and its **Done when** line
has been demonstrated. An **epic** is done when all its features are.

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

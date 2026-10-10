# Requirements

What the project must do, broken down as **Epic → Feature → Story**. The
project plan (`04-project-plan.md`) decides *when* each piece gets built;
this doc decides *what* gets built and how you know it's done.

- **Epic:** a large capability or outcome. Too big to build in one go.
  Usually spans several phases.
- **Feature:** a piece of an epic that is useful on its own. Fits in one
  phase.
- **Story:** the smallest unit of work: one prompt-sized change to one
  component, with acceptance criteria that can be tested. If a story needs
  more than ~a day or touches several components, split it.

## How to work with this doc

- Every epic serves at least one goal from `00-vision.md`. An epic that
  serves none is out of scope until the vision changes.
- A small project can have a single epic with a few features, and stories
  for the current phase only — don't pad it to look complete.
- Break requirements down top-down when starting the project: write the
  epics first, then features, then stories only for the current and next
  phase. Stories for later phases get written when you reach them.
- IDs are stable — never renumber. Removed items get status `Dropped`, not
  deleted.
- Every story's acceptance criteria become its tests (see
  `07-testing-checklist.md`).
- Reference story IDs in the project plan, commit messages and prompts
  (e.g. "Implement S1.2.3").
- A story is done when it meets its acceptance criteria *and* the
  Definition of Done below. Then update its status here and in the summary
  table.

**Statuses:** `Backlog` → `Ready` (acceptance criteria written) →
`In progress` → `Done` · or `Dropped`

## Definition of Done

A story is `Done` only when it meets **its own acceptance criteria** *and*
**every item below**. This list is the same for every story — edit it here
if the project needs more (or fewer) checks, never per story.

- [ ] Each acceptance criterion has a test, written first and seen failing;
      the tests now pass, and the output has been seen (not just reported)
- [ ] No test was deleted, skipped, or weakened to get there
- [ ] The full test suite still passes
- [ ] The code is the simplest version that works — nothing speculative
      (`06-coding-conventions.md` → Simplicity first)
- [ ] New/changed files have a header note; non-obvious functions have a
      doc comment; existing notes still match the code
- [ ] Any new decision is logged in `05-decisions-log.md`; any new term is
      in `11-glossary.md`; diagrams in `02-architecture.md` still match
      the code
- [ ] No non-functional requirement (below) is broken by the change
- [ ] Security checks for the change pass (`14-security.md` → Every
      change); accessibility checks too if the UI changed
      (`15-accessibility.md`)
- [ ] Story status is updated here (story + summary table)
- [ ] A session log entry is written in `10-session-log.md`

A **feature** is done when all its stories are `Done`, its integration
and manual tests pass (`07-testing-checklist.md` → Before marking a feature
done), and its **Done when** line is demonstrated. An **epic** is done when all its features are.

## Non-functional requirements

Qualities the whole system must have, rather than things it does —
how fast, how secure, how accessible, how reliable, how cheap. They apply
to every story, so they're checked by the Definition of Done and verified
at each phase end (`07-testing-checklist.md`).

- Each one must be **measurable** — "fast" isn't a requirement; "≥ 20
  updates/sec on the target machine" is.
- Delete the example rows that don't apply; add your own. Stories that
  exist mainly to meet an NFR reference its ID in **Notes**.

| ID | Category | Requirement (measurable) | How verified | Status |
|---|---|---|---|---|
| NFR1 | Performance | <e.g. main loop runs ≥ 20 times/sec on the target machine> | <e.g. timing test in tests/integration> | Not met yet |
| NFR2 | Security | No known high-severity vulnerabilities in dependencies | Dependency audit + Dependabot, each phase end (`14-security.md`) | Not met yet |
| NFR3 | Accessibility | <e.g. meets WCAG 2.2 AA / the Games checklist — or delete if no UI> | Manual pass per `15-accessibility.md` | Not met yet |
| NFR4 | Reliability | <e.g. runs a full 30-minute session without crashing> | <e.g. end-to-end test / manual test> | Not met yet |
| NFR5 | Privacy | <e.g. no personal data stored or logged> | <e.g. review of logs and stored files> | Not met yet |
| NFR6 | Cost | Monthly spend ≤ the budget in `16-budget.md` | Monthly log in `16-budget.md` | Not met yet |

**Statuses:** `Not met yet` · `Met` (with date last verified) · `At risk`

## Summary

| ID | Title | Type | Phase | Status |
|---|---|---|---|---|
| E1 | <epic title> | Epic | 1-3 | Backlog |
| F1.1 | <feature title> | Feature | 1 | Backlog |
| S1.1.1 | <story title> | Story | 1 | Backlog |
| S1.1.2 | <story title> | Story | 1 | Backlog |

---

## E1 — <Epic title>

**Goal:** <the outcome, in one or two sentences — why this matters>
**Serves:** <goal IDs from `00-vision.md`, e.g. G1>
**Out of scope:** <what this epic deliberately does not cover>

### F1.1 — <Feature title>

**Description:** <what this feature adds, in one or two sentences>
**Phase:** <phase number from `04-project-plan.md`>
**Depends on:** <feature IDs, or "none">
**Done when:** <how you'll see the stories working together, e.g. "can
demo X end-to-end on real input">

#### S1.1.1 — <Story title>

**Story:** As a <user/role>, I want <capability>, so that <benefit>.
<For technical stories with no user-facing angle, use instead:>
**Story:** Technical — <what must exist or change, and why>.

**Component:** <folder from `06-coding-conventions.md`>
**Status:** Backlog

**Acceptance criteria:**
- [ ] Given <starting state>, when <action>, then <observable result>
- [ ] <edge case: empty / missing / invalid input>
- [ ] <edge case: largest or worst realistic input>

**Notes:** <links, constraints, decisions in `05-decisions-log.md`>

#### S1.1.2 — <Story title>

<...>

---

## Bugs

Bugs found in finished work. Each one gets a regression test before it's
fixed (`07-testing-checklist.md` → Bugs). Small bugs found while a story is
still in progress are just part of that story.

| ID | Title | Found in | Severity | Status | Test |
|---|---|---|---|---|---|
| B1 | <what's wrong, in one line> | <story/feature ID> | High / Medium / Low | Open | <test name> |

**Statuses:** `Open` → `In progress` → `Fixed` · or `Won't fix` (with a
reason in Notes)

### B1 — <Bug title>

**Steps to reproduce:**
1. <...>

**Expected:** <what should happen>
**Actual:** <what happens instead>
**Notes:** <cause once found, related decisions>

---

## Template for new items

```
## E<n> — <Epic title>

**Goal:** <outcome>
**Serves:** <G-IDs from 00-vision.md>
**Out of scope:** <exclusions>

### F<n>.<m> — <Feature title>

**Description:** <what it adds>
**Phase:** <n>
**Depends on:** <IDs or "none">
**Done when:** <end-to-end demo>

#### S<n>.<m>.<k> — <Story title>

**Story:** As a <user>, I want <capability>, so that <benefit>.
**Component:** <folder>
**Status:** Backlog

**Acceptance criteria:**
- [ ] Given <state>, when <action>, then <result>

**Notes:** <optional>
```

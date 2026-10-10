# Testing strategy and checklist

Vibe-coded projects lose testing fast unless it's checked explicitly per
change. The first half of this doc says *how* this project tests; the
second half is the checklist to use as a gate — not just a suggestion.

## Strategy

### Kinds of tests

| Kind | What it checks | How many | Speed | Where |
|---|---|---|---|---|
| **Unit** | One function or module, in isolation | Most tests | Milliseconds | `tests/unit/` <adjust to the stack's convention> |
| **Integration** | Two or more components working together through their real interfaces (`02-architecture.md` → Data flow contract) | Some — one per interface | Seconds | `tests/integration/` |
| **End-to-end** | The whole thing, run the way a user would | Very few — the main happy path(s) | Slow | `tests/e2e/` |
| **Manual** | What automated tests can't judge — feel, visuals, usability | Per feature, before closing it | — | `12-manual-tests.md` |

Mostly unit tests, fewer integration tests, very few end-to-end: fast tests
get run often; slow ones get skipped.

### Test-first

For every story:

1. Write one test per acceptance criterion (`01-requirements.md`), plus the
   edge cases below.
2. Run them and **see them fail** — a test that passes before the code
   exists isn't testing anything.
3. Write the simplest code that makes them pass.
4. Tidy up the code with the tests still passing.

Tests written first are shaped by the requirement, not by whatever the code
happens to do.

### Test data

- Sample inputs live in `tests/data/` <adjust>. Keep them small, and name
  them for what they represent (`empty_input.json`, not `test2.json`).
- Each file is either hand-written or captured from real use; note which,
  and how to regenerate it, in `tests/data/README.md`.
- Never use real personal data or real credentials in test data.

### Reliable tests

A test must give the same result every run, on any machine:

- No real network calls, external services, or wall-clock time — replace
  them with fakes or fixed values in tests.
- Random numbers use a fixed seed in tests.
- Tests don't depend on each other or on running in a particular order.
- A test that fails sometimes ("flaky") is a bug: fix it or delete it, never
  just re-run until green.

### Test names are documentation

Name tests for the behaviour they check, so a failing test explains itself:
`test_empty_list_returns_no_targets`, not `test_detect_2`.

### Bugs

Every bug gets a regression test before it's fixed:

1. Log it in `01-requirements.md` → Bugs with an ID (`B1`, `B2`…).
2. Write a test that reproduces it and **see it fail**.
3. Fix the code until the test passes. The test stays forever so the bug
   can't come back unnoticed.

### Coverage

Coverage shows which lines the tests ran. Use it as a **hint** for untested
areas, not a target — there's no required percentage. Chasing a number
produces tests that run code without checking anything. Check the report
when closing a phase and look for important logic with no tests.

### Commands

The exact commands live in `AGENTS.md` → Commands (filled in during
Phase 0), so you and the agent always run tests the same way.

---

## Checklist

### Every story

The story must pass the **Definition of Done** at the top of
`01-requirements.md`. The checks below are the testing details behind it:

- [ ] Tests were written first from the acceptance criteria, and seen to
      fail before the code was written
- [ ] Empty / missing input case doesn't crash or return garbage
- [ ] Largest / densest realistic input still behaves
- [ ] No test was deleted, skipped, or weakened to get the suite passing
- [ ] Tests are reliable — no network, real time, or unseeded randomness

### Every bug fix

- [ ] Bug logged with an ID in `01-requirements.md`
- [ ] A regression test reproduced it (seen failing) before the fix
- [ ] The regression test now passes and stays in the suite

### Every <component> change

<Add one section per component with checks specific to it. Example:>

- [ ] <check specific to this component>
- [ ] <check specific to this component>

### Every change that touches external systems (files, network, OS, devices)

- [ ] Confirm the external effect actually happened — not just that the
      function returned without error
- [ ] Check behavior when the external system is unavailable

### Before marking a feature done

- [ ] Integration test covers the feature's components working together
- [ ] Manual tests for the feature run and recorded in
      `12-manual-tests.md` (if it has anything to judge by eye or feel)
- [ ] The feature's **Done when** line is demonstrated

### Before marking a phase done (per `04-project-plan.md`)

- [ ] Exit criteria for the phase are demonstrably met
- [ ] Full suite passes, including end-to-end tests
- [ ] Coverage report checked for important untested logic
- [ ] Every NFR in `01-requirements.md` verified, and its status and date
      updated
- [ ] Security end-of-phase checks done (`14-security.md`)
- [ ] Accessibility test pass recorded, if the project has a UI
      (`15-accessibility.md`)
- [ ] Spend and hours checked against `16-budget.md`
- [ ] Any measurements the phase calls for are logged (see
      `05-decisions-log.md`)
- [ ] Any new hardcoded constants have a comment explaining their origin
      (see `06-coding-conventions.md`)
- [ ] Status table in `04-project-plan.md` is updated
- [ ] Phase-closing status report written, including the retrospective
      (`09-status-report.md`)

### When an AI agent generates the change

- [ ] It wrote the tests first and showed them failing
- [ ] Actually run the tests yourself — don't take "tests pass" from the
      agent's summary at face value without seeing the output
- [ ] Skim the test changes in the diff: look for removed asserts, skipped
      tests, or code that special-cases test inputs

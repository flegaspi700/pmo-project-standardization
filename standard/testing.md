# Testing

AI-assisted projects lose testing fast unless it's checked on every change.
The rules come first; the checklists at the end are gates, not suggestions.
The exact test commands are in the project's `AGENTS.md`; always use them.

## Test-first

For every story:

1. Write one test per acceptance criterion, plus the edge cases (empty or
   missing input; the largest realistic input).
2. Run them and **see them fail**. A test that passes before the code
   exists isn't testing anything.
3. Write the simplest code that makes them pass.
4. Tidy up with the tests still passing.

**Run the tests and show the output before saying anything works.**

## Never cheat to get green

Don't delete, skip or weaken a test, and don't special-case code for test
inputs. If a test looks wrong, explain why and ask, the same as for an
acceptance criterion.

## Kinds of tests

| Kind | Checks | How many |
|---|---|---|
| Unit | One function or module on its own | Most |
| Integration | Components working together through their real interfaces | One per interface |
| End-to-end | The whole thing, run the way a user would | The main happy paths only |
| Manual | What a test can't judge: look, feel, usability | Per feature, in `docs/manual-tests.md` |

Fast tests get run often; slow ones get skipped. Keep most of them fast.

## Reliable tests

A test gives the same result every run, on any machine:

- No real network, outside services or wall-clock time: use fakes or fixed
  values.
- Random numbers use a fixed seed.
- Tests don't depend on each other or on their order.
- A flaky test is a bug: fix it or delete it, never re-run until green.

Name tests for the behaviour they check (`test_empty_list_returns_no_targets`,
not `test_detect_2`), so a failure explains itself.

Test data is small, named for what it represents (`empty_input.json`), and
never contains real personal data or credentials.

## Bugs

Every bug in finished work gets a regression test before it's fixed:

1. Log it with an ID in `docs/requirements.md` → Bugs.
2. Write a test that reproduces it and **see it fail**.
3. Fix the code until the test passes. The test stays for good.

## Coverage

A hint for untested areas, not a target: there's no required percentage.
Chasing a number produces tests that run code without checking anything.
Look at the report when closing a phase.

## Manual tests

When a feature has something only a person can judge, add
`docs/manual-tests.md`: per feature, what to check, the steps, and a results
table (date, commit, pass or fail, notes). Run them before marking the
feature done and again before closing a phase. A manual check that finds a
bug logs it with an ID, and gets an automated test if one is possible.

## Checklists

**Every story:** the Definition of Done ([requirements.md](requirements.md)),
which includes:
- [ ] Tests written first from the acceptance criteria and seen failing
- [ ] Empty or missing input doesn't crash or return garbage
- [ ] The largest realistic input still behaves
- [ ] No test deleted, skipped or weakened
- [ ] Tests are reliable: no network, real time or unseeded randomness

**Every bug fix:**
- [ ] Logged with an ID
- [ ] Regression test seen failing before the fix, passing after

**Every change that touches the outside world (files, network, OS, devices):**
- [ ] The effect actually happened, not just "the function returned"
- [ ] Behaviour checked when the outside system is unavailable

**Before marking a feature done:**
- [ ] An integration test covers its components working together
- [ ] Its manual tests are run and recorded, if it has any
- [ ] Its **Done when** line is demonstrated

**Before marking a phase done:**
- [ ] The phase's exit criteria are demonstrably met
- [ ] The full suite passes, including end-to-end tests
- [ ] Coverage report checked for important untested logic
- [ ] Every NFR verified, and its status and date updated
- [ ] Security end-of-phase checks done ([security.md](security.md))
- [ ] Accessibility pass recorded, if the project has a UI
      ([accessibility.md](accessibility.md))
- [ ] Spend and hours checked, if the project has `docs/budget.md`
      ([cost.md](cost.md))
- [ ] The Phases table and `portfolio.json` updated (`/report`)

**When an agent made the change, the person reviewing it:**
- [ ] Saw the tests fail first, then pass, in real output
- [ ] Skimmed the test changes in the diff for removed asserts, skipped
      tests, or code that special-cases test inputs

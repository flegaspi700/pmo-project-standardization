---
name: story
description: Implement a story, a whole feature, a whole epic, or every Ready story in the current phase from docs/requirements.md test-first on its own branch, then check the Definition of Done. Use when the user asks to implement, build, or start an ID like S1.2.3, F1.2, or E1, or to build the whole phase, in a project on the standard.
argument-hint: "[story, feature, or epic ID, e.g. S1.2.3, F1.2, E1, or phase]"
---

Implement: $ARGUMENTS

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\story"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `requirements.md`, `coding.md`, `testing.md`,
`git.md` (all in `standard/`).

If no ID was given, suggest the next `Ready` story in the current phase and
ask before starting.

## Scope: story, feature, epic, or phase

The argument decides the scope (`S…` story, `F…` feature, `E…` epic,
`phase` the current phase). If it's unclear, ask:

- **Story** (default): one story, then stop for approval.
- **Feature:** every story in the feature, in order, one approval at the end.
- **Epic:** every feature in the epic, in order, one approval per feature.
- **Phase:** every `Ready` story in the current phase (the `Active` row of
  the Phases table), feature by feature in order, with one approval up
  front. Later phases aren't included: their stories aren't written yet.

For a feature, epic or phase, before writing any code:
1. Ask the user to look over `docs/requirements.md` → `<ID>` (or the
   phase's features) first: the stories, their acceptance criteria and
   order. Fix anything wrong now, when it's cheap.
2. List the stories to build (ID, title, status, dependencies), grouped by
   feature, and wait for a yes. Skip stories already `Done`; stop and
   report any that aren't ready, and any feature that needs a design that
   isn't `Approved` (offer `/design <ID>`).
3. **Phase only:** ask whether to merge each feature's PR as it goes, once
   CI is green and the Definition of Done is met. A yes is the user's
   say-so for this run's PRs only (`git.md`); a no means the run stops
   after each feature's PR and waits for "merge it".

## Steps

For one story, do all the steps. For a feature, epic or phase: steps 1-2
once, step 3 once per feature, steps 4-8 for each story in turn, step 9 at
the end of each feature, step 10 at the end of a phase.

Older stories and features (written before the project's standard had
them) may have untagged criteria or no **Design:** line. Pick the kind of
test that fits an untagged criterion, and treat a missing **Design:** line
as `not needed`. A feature already under way doesn't get an acceptance
test backfilled. Don't backfill any of these.

1. Read `AGENTS.md` (commands, project-specific notes), the story and its
   feature and epic in `docs/requirements.md`, the feature's design
   (`docs/design/<feature ID>.md`) if it has one, the latest entry in
   `docs/session-log.md`, and `docs/architecture.md` if there is one.
2. Check the story is ready: acceptance criteria written, dependencies
   done, and, if the feature's **Design:** line names a file, that design
   `Approved`. If not, say what's missing (offer `/design` for a design)
   and stop.
3. Branch from an up-to-date `main`, named per `git.md`:
   `feature/<ID>-short-description`. Set the story to `In progress`.
   **At the start of a feature** (its first story, or a feature, epic or
   phase run): turn its **Done when** into the acceptance test
   (`testing.md` → Outside-in), run it and **show it failing**, mark it as
   expected to fail, and commit it first. Skip this if **Done when** is
   `[manual]`.
4. **Tests first:** one per acceptance criterion, of the kind its tag says
   (`[unit]`, `[integration]`, `[e2e]`; `[manual]` goes in
   `docs/manual-tests.md`), each naming its criterion (`S1.2.3 AC2`), plus
   empty and worst-case inputs. Run them and **show them failing.**
5. Write the simplest code that makes them pass, following `coding.md`
   (header notes, doc comments, errors, logging). Run the full suite and
   **show the output.**
6. If a significant design choice comes up (`decisions.md`), stop and lay
   out the options, or suggest `/decide`. In a feature, epic or phase run
   this always stops the run.
7. Go through the **Definition of Done** (`requirements.md`, plus any extra
   checks in `AGENTS.md`) item by item: met or not met. Fix what's not met;
   list anything you can't verify yourself for the user. If the code had
   to differ from an approved design, update the design in the same commit
   and add a dated line under its Changes; if the difference is a
   significant choice, stop and ask first.
8. Mark the story `Done` only when every item is met, and tick each of its
   criteria (`- [x]`). In a feature, epic or
   phase run, commit it on the branch (Conventional Commits with the story
   ID) and go on, with no approval between stories. If the Definition of
   Done can't be met or the suite fails, **stop the run** and report.
9. **When a feature's last story is done,** take the expected-to-fail mark
   off its acceptance test, run the full suite and **show it passing.** If
   it doesn't pass, the feature isn't done: stop the run and report.

   **Ask before committing** (single story) or before the final step
   (feature or epic: show the stories done, test output, Definition of Done
   results, anything left to check by hand; a phase run already has its
   approval from the start). Then by hosting (`git.md`):
   - `github`: push and open the PR, filled in with real test output and
     the list of stories (ask first, except in a phase run).
   - `local`: stop on the branch and show `git log main..HEAD`. Never push
     or mention GitHub.

   Merge only on the user's say-so, as `git.md` says (green CI first on
   GitHub; red CI stops the run). In a phase run with a yes to merging as
   it goes, merge now, confirm it's merged, clean up, and start the next
   feature from the updated `main`. Otherwise wait for "merge it".

   For an epic, go on to the next feature once the user has approved the
   previous one.
10. **End of a phase run:** check the phase's exit criteria (Phases table)
    one by one: met or not met. Summarize the features merged, the test
    output, and anything left to check by hand. With the user's OK, set the
    phase to `Done` with today's date, then offer `/breakdown` for the next
    phase.

Never delete, skip or weaken a test to get to green (the acceptance test's
expected-to-fail mark until the feature is done is the one exception,
`testing.md`). If a test or a criterion looks wrong, explain and ask.

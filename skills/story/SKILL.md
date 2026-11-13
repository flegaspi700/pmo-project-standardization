---
name: story
description: Implement a story, a whole feature, or a whole epic from docs/requirements.md test-first on its own branch, then check the Definition of Done. Use when the user asks to implement, build, or start an ID like S1.2.3, F1.2, or E1 in a project on the standard.
argument-hint: "[story, feature, or epic ID, e.g. S1.2.3, F1.2, E1]"
---

Implement: $ARGUMENTS

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\story"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `requirements.md`, `coding.md`, `testing.md`,
`git.md` (all in `standard/`).

If no ID was given, suggest the next `Ready` story in the current phase and
ask before starting.

## Scope: story, feature, or epic

The ID decides the scope (`S…` story, `F…` feature, `E…` epic). If it's
unclear, ask:

- **Story** (default): one story, then stop for approval.
- **Feature:** every story in the feature, in order, one approval at the end.
- **Epic:** every feature in the epic, in order, one approval per feature.

For a feature or epic, before writing any code:
1. Ask the user to look over `docs/requirements.md` → `<ID>` first (the
   stories, their acceptance criteria and order) and fix anything wrong
   now, when it's cheap.
2. List the stories to build (ID, title, status, dependencies) and wait for
   a yes. Skip stories already `Done`; stop and report any that aren't
   ready.

## Steps

For one story, do all the steps. For a feature or epic: steps 1-2 once,
step 3 once per feature, steps 4-8 for each story in turn, step 9 at the
end of each feature.

1. Read `AGENTS.md` (commands, project-specific notes), the story and its
   feature and epic in `docs/requirements.md`, the latest entry in
   `docs/session-log.md`, and `docs/architecture.md` if there is one.
2. Check the story is ready: acceptance criteria written, dependencies
   done. If not, say what's missing and stop.
3. Branch from an up-to-date `main`, named per `git.md`:
   `feature/<ID>-short-description`. Set the story to `In progress`.
4. **Tests first:** one per acceptance criterion, plus empty and worst-case
   inputs. Run them and **show them failing.**
5. Write the simplest code that makes them pass, following `coding.md`
   (header notes, doc comments, errors, logging). Run the full suite and
   **show the output.**
6. If a significant design choice comes up (`decisions.md`), stop and lay
   out the options, or suggest `/decide`. In a feature or epic run this
   always stops the run.
7. Go through the **Definition of Done** (`requirements.md`, plus any extra
   checks in `AGENTS.md`) item by item: met or not met. Fix what's not met;
   list anything you can't verify yourself for the user.
8. Mark the story `Done` only when every item is met. In a feature or epic
   run, commit it on the branch (Conventional Commits with the story ID)
   and go on, with no approval between stories. If the Definition of Done
   can't be met or the suite fails, **stop the run** and report.
9. **Ask before committing** (single story) or before the final step
   (feature or epic: show the stories done, test output, Definition of Done
   results, anything left to check by hand). Then by hosting (`git.md`):
   - `github`: ask before pushing and opening the PR, filled in with real
     test output and the list of stories. Never merge.
   - `local`: stop on the branch and show `git log main..HEAD`. Merge with
     `git merge --squash` only when the user says so. Never push or
     mention GitHub.

   For an epic, go on to the next feature once the user has approved the
   previous one.

Never delete, skip or weaken a test to get to green. If a test or a
criterion looks wrong, explain and ask.

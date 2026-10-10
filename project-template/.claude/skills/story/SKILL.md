---
name: story
description: Implement a story, a whole feature, or a whole epic from docs/01-requirements.md test-first on its own branch, then check the Definition of Done. Use when the user asks to implement, build, or start an ID like S1.2.3, F1.2, or E1.
argument-hint: "[story, feature, or epic ID, e.g. S1.2.3, F1.2, E1]"
---

Implement: $ARGUMENTS
(If no ID was given, suggest the next `Ready` story in the current phase
and ask before starting.)

## Scope: story, feature, or epic

The ID decides the scope (`S…` = story, `F…` = feature, `E…` = epic). If the
user didn't say, or it's unclear, ask:

- **Story** *(default)* — one story, then stop for approval.
- **Feature** — every story in the feature, in order, with one approval at
  the end.
- **Epic** — every feature in the epic, in order, with one approval **per
  feature**.

For a **feature or epic**, before writing any code:
1. **Remind the user to read the requirements first:** "You're about to
   build `<ID>` in one go. Please look over `docs/01-requirements.md` →
   `<ID>` first — the stories, acceptance criteria and their order — and
   change anything that's wrong now; it's much cheaper than after."
2. List the stories that will be built (ID, title, status, dependencies)
   and wait for a yes. Skip stories already `Done`; stop and report any that
   aren't ready (criteria missing, dependency not done).

## Steps

For one story, do these steps. For a feature or epic, do steps 1–2 once,
step 3 once per feature, steps 4–8 for **each story in turn**, and step 9
at the end of the feature.

1. Read `AGENTS.md`, the story in `docs/01-requirements.md` (and its
   feature and epic), the latest entry in `docs/10-session-log.md`, and the
   sections of `docs/02-architecture.md` and `docs/06-coding-conventions.md`
   for its component.
2. Check the story is ready: acceptance criteria written, dependencies
   done. If not, say what's missing and stop.
3. Check `Hosting` in `AGENTS.md` (`local` or `github`). Branch from an
   up-to-date `main` (pull first only on `github`):
   `feature/<ID>-short-description` — named after the story, or after the
   feature (`F1.2`) when building a feature, or after the feature being
   built within an epic (`docs/13-git-workflow.md`). Set the story's status
   to `In progress`.
4. **Tests first:** one test per acceptance criterion, plus empty and
   worst-case inputs. Run them and **show them failing.**
5. Write the simplest code that makes them pass — file header notes, doc
   comments, errors and logging per `docs/06-coding-conventions.md`. Run
   the full suite and **show the output.**
6. If a significant design choice comes up, stop and use the process in
   `AGENTS.md` (or suggest `/decide`). In a feature or epic run this always
   stops the run, even if the user chose "all in one go".
7. Go through the **Definition of Done** in `docs/01-requirements.md` item
   by item and report met / not met. Fix what's not met; anything you
   can't verify (manual or accessibility checks), list for the user.
8. Mark the story `Done` (story + Summary table) only when every DoD item
   is met. In a feature or epic run, commit it on the branch
   (Conventional Commits, with the story ID) and go on to the next story —
   no approval needed between stories. If the DoD can't be met, or the
   full suite fails, **stop the run** and report; don't carry on to the
   next story.
9. **Ask before committing** (single story) **or before the final step**
   (feature or epic: show what was built — stories done, test output, DoD
   results, anything left for a manual check). On a yes, commit in
   Conventional Commits format with the ID, then by hosting:
   - `github`: ask before pushing and opening the PR with
     `.github/pull_request_template.md` filled in, including real test
     output and the list of stories. Never merge.
   - `local`: stop on the branch and show `git log main..HEAD`. Merge into
     `main` (`git merge --squash`) only when the user says so. Never push
     or mention GitHub.

   For an epic, repeat from step 3 for the next feature once the user has
   approved the previous one.

Never delete, skip, or weaken a test to get to green — if a test or
criterion looks wrong, explain and ask.

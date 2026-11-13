# Git

**GitHub Flow:** `main` always works, every piece of work happens on a
short-lived branch, and lands on `main` as one squashed commit that the
user approves.

## Hosting

Each project's `AGENTS.md` has a `**Hosting: local|github**` line, and every
rule and skill reads it.

- **local:** git on this machine only. Same branches and commits, but no
  remote and no PR. The user reviews the branch, and the agent merges it
  with `git merge --squash` once they say so. Never push, create a remote
  or repo, open a PR, or suggest any of these. Items marked **GitHub only**
  are n/a, not to-dos.
- **github:** the full flow below, with a remote and PRs.

## The flow, per story or bug

1. **Update `main`:** `git switch main`, then `git pull` (GitHub only).
2. **Branch** from `main`, named after the work (see Naming).
3. **Work test-first,** committing in small steps.
4. **Check the Definition of Done** ([requirements.md](requirements.md)).
5. **Ask before committing, pushing or opening a PR.** On GitHub, fill the
   PR description from `.github/pull_request_template.md` if the project
   has one, including real test output. Locally, show the branch
   (`git log main..HEAD`, `git diff main`).
6. **The user merges.** On GitHub, the agent never merges a PR; use squash
   merge. Locally, once the user says so: `git switch main`, then
   `git merge --squash <branch>`, and commit with the story's title.
7. **Clean up only after the merge is confirmed.** On GitHub, check
   `gh pr view <number> --json state` shows `MERGED`, then switch to
   `main`, pull, and delete the branch locally and on the remote. If it
   isn't merged, stop and say so: deleting the remote branch closes the PR.
   Locally, after the squash commit is on `main`, `git branch -D <branch>`
   (`-D`, because a squash merge doesn't mark the branch as merged).

One story or bug per branch and per PR. If a branch grows into a second
story, finish the first and start a new branch.

**A whole feature at once** (`/story F1.2`): one branch and PR for the
feature, `feature/F1.2-short-description`, with one commit per story. For
an epic, one branch per feature.

## Naming

| Work | Branch |
|---|---|
| Story | `feature/S1.2.3-short-description` |
| Feature | `feature/F1.2-short-description` |
| Bug | `fix/B4-short-description` |
| Docs only | `docs/short-description` |
| Tooling, setup, adopting the standard | `chore/short-description` |

Lowercase, words separated by dashes, short.

## Commits

[Conventional Commits](https://www.conventionalcommits.org): a type, a short
summary in the imperative ("add", not "added"), and the ID.

```
<type>: <short summary> (<ID>)

<optional body: why, and anything non-obvious>
```

Types: `feat` (new behaviour), `fix`, `test`, `docs`, `refactor` (no
behaviour change), `chore` (tooling, dependencies, setup).
Example: `feat: detect enemies in dense swarms (S1.2.3)`.

The squash commit on `main` follows the same format.

## Rules

- **Never commit to `main` directly.**
- **Never force-push** to `main` or to a branch with an open PR.
- **Never commit secrets:** check `git status` before committing
  ([security.md](security.md)).

## GitHub only: protect `main`

In the repo's Settings → Branches, add a rule for `main`: require a pull
request before merging, and block force pushes.

## Switching hosting

**Local to GitHub:** make sure `main` is clean, run
`gh repo create <name> --private --source . --push`, change the line in
`AGENTS.md` to `**Hosting: github**`, then do the GitHub setup in
[security.md](security.md) and protect `main`.

**GitHub to local:** change the line and stop pushing. The remote is left
alone.

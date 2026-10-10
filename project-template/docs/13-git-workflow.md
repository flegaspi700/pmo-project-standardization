# Git workflow

This project uses **GitHub Flow**: `main` always works, every piece of work
happens on a short-lived branch, and lands on `main` through a pull request
(PR) that you review and merge.

**Hosting** is set in `AGENTS.md` (`local` or `github`) and decides which
steps apply. Steps and sections marked **GitHub only** are n/a when it's
`local`: leave them alone and don't treat them as to-dos.

- **local** — git on this machine only. Same branches and commits, but no
  remote and no PR: you review the branch yourself and the agent merges it
  into `main` with `git merge --squash` once you say so.
- **github** — the full flow below, with a remote and PRs.

```
main ──●──────────────●──────────────●──
        \            / (squash merge) \
         ●──●──●────●                  ...
     feature/S1.2.3-dense-swarm
```

## The flow, per story or bug

1. **Update `main`:** `git switch main`, then `git pull` (**GitHub only**).
2. **Branch** from `main`, named after the story or bug (see Naming).
3. **Work test-first**, committing in small steps (see Commits).
4. **Check the Definition of Done** (`01-requirements.md`) — tests pass,
   notes, docs and status updated.
5. **GitHub only — push and open a PR.** GitHub fills in the description
   from `.github/pull_request_template.md`.
   **Local:** review the branch (`git log main..HEAD`, `git diff main`).
6. **GitHub only — review and merge** on GitHub. The user does this, never
   the agent. Use **squash merge**, so each story lands on `main` as one
   commit.
   **Local:** once the user says so, `git switch main` then
   `git merge --squash <branch>` and commit with the story's title.
7. **Clean up.** **GitHub:** only after the PR shows as merged, switch to
   `main`, pull, then delete the branch locally and on the remote. If the
   PR isn't merged, don't delete anything — deleting the remote branch
   closes the PR. **Local:** after the squash commit is on `main`, delete
   the branch with `git branch -D <branch>`. (`-D` is needed because a
   squash merge doesn't mark the branch as merged.)

One story (or bug) per branch and per PR. If a branch grows to cover a
second story, finish the first one and start a new branch.

**Exception — building a whole feature at once** (`/story F1.2`): one
branch and one PR (or local merge) for the feature, named
`feature/F1.2-short-description`, with one commit per story (each with its
story ID). Squash merge still lands it as one commit on `main`. For an epic,
it's one branch per feature, not one for the whole epic.

## Naming

| Work | Branch name |
|---|---|
| Story | `feature/S1.2.3-short-description` |
| Feature (all its stories) | `feature/F1.2-short-description` |
| Bug | `fix/B4-short-description` |
| Docs only | `docs/short-description` |
| Tooling / setup | `chore/short-description` |

Lowercase, words separated by dashes, short.

## Commits

Use the [Conventional Commits](https://www.conventionalcommits.org) format:
a type, a short summary in the imperative ("add", not "added"), and the
story or bug ID.

```
<type>: <short summary> (<ID>)

<optional body: why this change, anything non-obvious>
```

| Type | Use for |
|---|---|
| `feat` | New behaviour for a story |
| `fix` | A bug fix |
| `test` | Adding or changing tests only |
| `docs` | Documentation only |
| `refactor` | Restructuring with no behaviour change |
| `chore` | Tooling, dependencies, setup |

Examples:

```
feat: detect enemies in dense swarms (S1.2.3)
test: add failing tests for S1.2.3 acceptance criteria
fix: empty frame no longer crashes perception (B4)
docs: log storage decision
```

Commit small and often on the branch — squash merge tidies it into one
commit on `main` anyway. The squash commit's title should follow the same
format.

## Rules

- **Never commit directly to `main`.** Work goes through a branch — and a
  PR on GitHub.
- **Never commit secrets** — `.env` and keys are in `.gitignore`; check
  `git status` before committing.
- **Never force-push** to a branch with an open PR, or to `main`.
- **GitHub only: delete branches only after the PR shows as merged** (check
  on GitHub or with `gh pr view <number> --json state`).

## GitHub only: protect `main`

In the repo's Settings → Branches, add a rule for `main`: require a pull
request before merging, and block force pushes. This turns "never commit to
`main`" from a habit into something GitHub enforces.

## Switching

**Local → GitHub** (when you want a backup, to share, or CI):

1. Commit or merge everything so `main` is clean.
2. Ask the agent, or run:
   `gh repo create <project-name> --private --source . --push`
3. Change the line in `AGENTS.md` to `**Hosting: github**`.
4. Do the GitHub items in `14-security.md` → GitHub setup, and turn on
   branch protection (above).

**GitHub → local** is rarely needed: change the `AGENTS.md` line and stop
pushing. The remote is untouched.

# Preflight for the standard's skills

Every skill in this folder (except `/new-project`)
does this first, before anything else. It's kept in one file so the skills
can't drift apart.

## 1. Is this repo on the standard?

Read `AGENTS.md` in the project root and find the line:

```
**Standard:** pmo-project-standardization v<version>
```

- **Found:** note the version and go on.
- **`AGENTS.md` has `Template version:` instead:** it's a v1 project. Its
  own skills in `.claude/skills/` are the ones to use. Say so, mention that
  it can be moved to v2, and stop.
- **Neither:** stop. Say the repo isn't on the standard, and offer to adopt
  it with `/new-project` (the existing-repo option), or to add only a
  `portfolio.json` so it shows on the dashboard. Don't run the rest of the
  skill.

## 2. Find the rules

The skill found `<template-dir>` (the folder holding this file's `skills\`
folder) before reading this file. The rules are in `<template-dir>\standard\`. Read them **as they were at the
project's version**, not as they are today:

1. **Same as the working copy?** Run
   `git -C "<template-dir>" diff --quiet v<version> -- standard`. If it
   succeeds, read the files in `<template-dir>\standard\` directly.
2. **Changed since that version:** read each file with
   `git -C "<template-dir>" show v<version>:standard/<file>`, in Bash so the
   text stays UTF-8.
3. **No local copy, or git fails:** read
   `https://raw.githubusercontent.com/flegaspi700/pmo-project-standardization/v<version>/standard/<file>`.
4. **The tag doesn't exist yet** (the version isn't released): read the
   working copy and tell the user the rules may still change.

Read only the files the skill names, plus `standard/README.md` the first
time in a session.

## 3. Then

- `AGENTS.md` wins over the standard where they disagree: it records the
  project's deliberate exceptions. Point out any conflict you notice.
- Read the project's `**Hosting:**` line; the git steps depend on it
  (`standard/git.md`).

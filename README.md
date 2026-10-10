# Templates

Starter kit for new projects.

| Item | What it is |
|---|---|
| `project-template/` | The template. Everything in it is copied into each new project — docs, `AGENTS.md`, workflow commands (`.claude/skills/`), PR template, `.gitignore`. |
| `new-project.ps1` | Copies `project-template` to a new folder, fills in the name and hosting (`-Hosting local\|github`, default local), runs `git init` on `main`. `-IntoExisting` adds the template to a repo you already cloned. |
| `skills/new-project/` | Source of the `/new-project` Claude Code command (user level). |
## Start a new project

**Recommended:** in Claude Code (any folder), type `/new-project`. It asks
what you're starting: a new project, a new project after brainstorming the
idea first (nothing is created until you've picked a direction), or an
existing GitHub repo. It then runs `new-project.ps1` and interviews you to fill in the vision doc. It then sizes the project (Small or Standard) and
proposes which docs are needed; docs you don't need become marked one-line
stubs. For an existing GitHub repo, it first shows which files it would add
and which it would keep, and asks before writing anything. It then reads the repo, records what
exists (vision, stack, architecture) instead of recommending a new stack, and
offers to brainstorm what to change next. For a Small project it also drafts docs 01–04 and asks "Is this OK?".

**Or by hand:**

```powershell
.\new-project.ps1 -Name "Guess Game"
# creates guess-game in the current folder;
# add -Destination to put it elsewhere
```

If PowerShell blocks scripts:
`powershell -ExecutionPolicy Bypass -File .\new-project.ps1 -Name "Guess Game"`

Then start Claude Code inside the new folder and run `/breakdown`.

## The `/new-project` command

Claude Code finds user-level commands in `%USERPROFILE%\.claude\skills\`.
That folder contains a **junction** (a folder shortcut) pointing here, so
edits to `skills/new-project/SKILL.md` take effect immediately — nothing to
re-install.

To set it up again on a new machine (PowerShell, no admin needed):

```powershell
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\new-project" -Target "<path-to-this-repo>\skills\new-project"
```

## Changing the template

Edit files in `project-template/`. Changes apply to projects created
afterwards; existing projects keep their copy.

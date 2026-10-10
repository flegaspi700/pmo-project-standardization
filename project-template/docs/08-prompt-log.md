# Prompt log

Reusable prompts for this project. Add an entry whenever a prompt produces
a good result you'd want to reuse or adapt — this saves re-deriving good
phrasing every session. Newest at top.

## Built-in commands

The main workflows are already set up as Claude Code commands in
`.claude/skills/` — type them instead of writing a prompt. Edit a skill's
`SKILL.md` to change how it works for this project.

| Command | Use when |
|---|---|
| `/breakdown [epic or idea]` | Starting the project or a new epic — epics → features → stories |
| `/stack` | Phase 0 — choose and record the language and tools |
| `/decide [question]` | A significant design or technology choice — compare options, log the decision |
| `/story [S-ID]` | Building a story — branch, test-first, Definition of Done, then PR (GitHub) or local merge; or a whole feature (`F1.2`) or epic (`E1`) |
| `/fix-bug [what's wrong]` | Something broken — log it, failing test, fix |
| `/report` | Weekly or at phase end — status report, Gantt update, retrospective |
| `/wrap-up` | End of a session — session log entry and handoff |
| `/security-check [scope]` | End of phase, or after a new input, dependency, or service |
| `/a11y-check [scope]` | After a UI change, or end of phase (projects with a UI) |

If a prompt below proves useful again and again, turn it into a skill: a
new folder in `.claude/skills/` with a `SKILL.md` (copy an existing one as
a starting point).

---

## Template

```
## <short task name>

**Use when:** <what situation this prompt is for>

**Prompt:**
> <the actual prompt text>

**Notes:** <anything that made this work well, or gotchas to mention next
time — e.g. "specify the exact file path or it guesses wrong">
```

---

## Example: adding a feature to one component

**Use when:** Adding a new capability that follows an existing pattern.

**Prompt:**
> Read `AGENTS.md` and `docs/06-coding-conventions.md` first. Add [feature]
> to `[component]/`, following the same pattern as [existing similar code].
> Include a test in `tests/`, and update `docs/02-architecture.md` if the
> data passed between components changes shape.

**Notes:** Naming existing code to pattern-match against gets much more
consistent output than describing the desired shape from scratch.

---

## Example: debugging a failure

**Use when:** Something misbehaves on a specific input.

**Prompt:**
> [Component] is [failing how] on [input / reproduction]. Read
> `docs/02-architecture.md` for its role. Don't change other components.
> First add logging or a debug dump so I can see what it's doing, then
> propose a fix.

**Notes:** Asking for visibility before the fix stops the agent from
guessing at a fix blind.

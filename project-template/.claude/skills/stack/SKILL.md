---
name: stack
description: Recommend and record the project's language, libraries, and tooling (Phase 0) — options with pros, cons, and cost; waits for the user to choose.
disable-model-invocation: true
---

Choose the stack, following `AGENTS.md` → Choosing the stack.

1. Read `AGENTS.md`, `docs/00-vision.md`, `docs/01-requirements.md`,
   `docs/02-architecture.md`, and `docs/03-tech-stack.md`.
2. Present **2-3 options** for language + key libraries, as a table:
   option, pros, cons, cost, one-line fit with the vision's goals and
   constraints. Default to Python unless the project needs something else
   (browser UI, game engine, mobile…) — say so if it does. Include the
   formatter, linter, test runner, coverage tool, and dependency audit tool
   for each language option.
3. Recommend one and name the trade-off. For every library, confirm the
   exact package name exists in the official registry and is maintained —
   say how you checked.
4. **Wait for the user to choose.** Write nothing before that.
5. Then, in one go:
   - fill in `docs/03-tech-stack.md`
   - accept the "Language and stack" and "Formatter, linter and test
     runner" entries in `docs/05-decisions-log.md` (with the options table)
     and add a Key decisions row in `docs/02-architecture.md`
   - add the language's standard ignores to the language-specific section
     of `.gitignore`
   - fill in `AGENTS.md` → Commands
   - update `docs/06-coding-conventions.md` placeholders (naming, layout)
     that the language decides
6. Tick "Choose and record the stack" in `docs/04-project-plan.md`.

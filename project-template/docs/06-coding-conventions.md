# Coding conventions

Keep this consistent across sessions — especially important when code is
mostly AI-generated, since this is the doc that keeps output consistent
between sessions/prompts.

## Project layout

```
<project-name>/
  <component-1>/   # <what lives here>
  <component-2>/   # <what lives here>
  tests/           # mirrors the module structure above
  docs/            # these planning docs
  <entry point>    # wires the components together
```

One component per top-level folder. <Note any imports that are forbidden,
e.g. "core logic never imports from the I/O layer".>

## Simplicity first

The simplest code that meets the story's acceptance criteria wins. Code is
read far more often than it's written — optimise for the next reader
(including future you and the next AI session).

- Solve the current story only. No "we might need this later" options,
  hooks, config flags, or abstractions — add them when a story needs them.
- Prefer plain functions and plain data over classes, inheritance, or
  design patterns, unless the pattern removes real duplication or
  complexity that already exists.
- Prefer the standard library and existing dependencies over adding a new
  one.
- No clever one-liners when three plain lines are clearer.
- Duplication is OK until the third copy — then extract it. A wrong
  abstraction costs more than a little repetition.
- If a simpler approach would work but has a tradeoff (speed, flexibility),
  pick the simple one and note the tradeoff in a comment or in
  `05-decisions-log.md`.

## When to split code into files

Start simple and split when there's a reason, not upfront.

- **One file is fine** for a small script, a prototype, or a component that
  does one job.
- **Split a file when** any of these is true:
  - it does more than one job (e.g. reading input *and* deciding *and*
    writing output)
  - it passes roughly 300-500 lines
  - you want to test one part without running the rest
  - two different stories keep editing the same file for unrelated reasons
- **Don't over-split:** no single-function files "for organisation", no
  layers that only pass calls through. Each file should have a job you can
  describe in one sentence.
- Split by responsibility (what it does), not by type (all classes in one
  file, all helpers in another).

## Naming

- <Modules/files: e.g. `snake_case`>
- <Functions/variables: e.g. `snake_case`>
- <Classes/types: e.g. `PascalCase`>
- Field names at component boundaries stay identical across the whole
  codebase — pick one spelling and never mix variants.
- Test files: <e.g. `test_<module>.py`>, mirroring the source file name

## Typing

- Type every function signature, especially at component boundaries
- Use typed models (dataclasses, interfaces, records) for data passed
  between components — not raw dicts or tuples, so the interface is
  self-documenting

## Style

- Format with <formatter>, lint with <linter> — see
  `05-decisions-log.md`
- Keep functions short — if a function does two jobs, split it into two

## Notes and comments

The goal: someone new (or you in six months) can open any file and
understand what it's for and why it works the way it does — without
reading every line.

**Every file starts with a header note** saying:
- what this file is responsible for (one or two sentences)
- how it fits in — what calls it, what it calls, which component it belongs
  to (see `02-architecture.md`)
- the story ID(s) it was built for, e.g. `S1.2.3`

**Every function or class that isn't obvious from its name gets a short
note** (docstring / doc comment) saying:
- what it does, in plain language
- what goes in and what comes out, including units and edge cases (empty
  input, errors)

**Inside functions, comment the *why*, not the *what*:**
- Good: `# Retry 3 times — the API drops ~1% of requests under load`
- Noise: `# Increment i by 1`
- Explain non-obvious steps, workarounds, and anything that looks wrong but
  is deliberate
- Any hardcoded tuning constant (thresholds, timeouts, sizes) gets a comment
  noting how it was derived (measured, guessed, copied from a reference)

**Clear names before comments:** if a comment is needed to explain what a
variable or function *is*, rename it instead (`elapsed_seconds`, not `t`
plus a comment).

**Keep notes true:** when changing code, update its notes in the same
change. A wrong comment is worse than none.

## Errors

- **Validate at the boundary.** Check input where it first enters the
  program (file, network, user) and reject what doesn't fit — inner code
  can then trust its inputs. See `14-security.md` → Input handling.
- **Fail loudly.** Never swallow an error silently (an empty `catch` /
  `except: pass`). If you can't handle it, let it propagate.
- **Catch only what you can handle** — specific error types, at the level
  where something sensible can be done (retry, fall back, tell the user).
- **Error messages say what happened and what to do:** "Config file
  settings.json not found — copy settings.example.json to create it", not
  "Error 2".
- **Two audiences:** users get a short, plain message with no internals;
  the full detail (stack trace, values) goes to the log.

## Logging

- Use the language's standard logging library, not print statements, so
  levels and output can be configured in one place.
- Levels mean something:

| Level | Use for |
|---|---|
| DEBUG | Detail useful only when diagnosing a problem |
| INFO | Normal milestones — started, finished, loaded N items |
| WARNING | Something unexpected that the program recovered from |
| ERROR | Something failed and the current operation couldn't finish |

- Log enough context to debug — IDs, counts, which step — not whole
  payloads.
- **Never log secrets or personal data.** See `14-security.md`.
- Where logs go and how long they're kept: <fill in once decided — e.g.
  `logs/`, rotated daily, kept 7 days>.

## When asking an AI agent to generate code

- Point it at `AGENTS.md` first if it doesn't read it automatically
- Give it the specific component folder to work in — don't ask for "the
  whole thing" in one prompt; ask per-component, matching the current phase
  in `04-project-plan.md`
- Ask it to add/update tests in the same prompt as the implementation, not
  as a follow-up — vibe-coded tests are the first thing to get skipped

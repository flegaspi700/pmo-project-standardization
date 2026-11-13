# Coding

How code is written, so output stays consistent from one session and one
agent to the next. A project records its own layout and naming in the
project-specific notes of its `AGENTS.md`.

## Simplest thing that works

The simplest code that meets the story's acceptance criteria wins. Code is
read far more often than it's written.

- Solve the current story only. No "we might need this later" options,
  hooks, config flags or abstractions.
- Plain functions and plain data over classes, inheritance and patterns,
  unless the pattern removes duplication or complexity that already exists.
- The standard library or an existing dependency over a new one.
- Three plain lines over a clever one-liner.
- Duplication is fine until the third copy; then extract it. A wrong
  abstraction costs more than a little repetition.
- If a simpler approach has a trade-off (speed, flexibility), take the
  simple one and note the trade-off in a comment or in `docs/decisions.md`.
- If a more complex approach is genuinely needed, explain why and ask
  before writing it.

## Files

Start simple and split when there's a reason, not up front.

- One file is fine for a small script, a prototype, or a part that does one
  job.
- **Split a file when** it does more than one job, passes roughly 300-500
  lines, has a part you want to test on its own, or keeps getting edited
  by unrelated stories.
- **Don't over-split:** no one-function files "for organisation", no layers
  that only pass calls through. Each file has a job you can say in one
  sentence.
- Split by responsibility (what it does), not by type.

## Names and types

- Follow the language's usual naming style; record it in `AGENTS.md`.
- A name that needs a comment to explain what it *is* should be renamed
  (`elapsed_seconds`, not `t` plus a comment).
- Field names at component boundaries are spelled the same everywhere.
- Type function signatures where the language allows, especially at
  component boundaries. Pass typed records (dataclasses, interfaces) between
  components, not raw dictionaries or tuples.
- Keep functions short: a function that does two jobs becomes two
  functions.
- Format and lint with the tools logged in `docs/decisions.md`, using the
  commands in `AGENTS.md`.

## Notes and comments

Someone new should be able to open any file and understand what it's for
and why it works that way, without reading every line.

- **Every file starts with a header note:** what it's responsible for, how
  it fits in (what calls it, what it calls), and the story IDs it was built
  for.
- **Every function that isn't obvious from its name gets a doc comment:**
  what it does, what goes in and out (units, edge cases, errors).
- **Inline comments explain why, never what.** Good: `# Retry 3 times: the
  API drops about 1% of requests under load`. Noise: `# Increment i`.
- Every hardcoded tuning constant (threshold, timeout, size) says where it
  came from: measured, guessed or copied from a reference.
- **Keep notes true:** update them in the same change as the code. A wrong
  comment is worse than none.

## Learning mode

If `AGENTS.md` says **Learning mode: on**, the first time a language
feature, library or concept appears in the code, add a short comment on
what it is and why it's used here, and briefly explain the approach before
the code in replies. Otherwise the comment rules above apply.

## Errors

- **Validate at the boundary:** check input where it first enters the
  program and reject what doesn't fit. Inner code can then trust its inputs.
- **Fail loudly.** Never swallow an error (an empty `catch`, `except: pass`).
  If you can't handle it, let it propagate.
- **Catch only what you can handle,** at the level where something sensible
  can be done: retry, fall back, tell the user.
- **Messages say what happened and what to do:** "settings.json not found:
  copy settings.example.json to create it", not "Error 2".
- **Two audiences:** users get a short, plain message; the full detail goes
  to the log.

## Logging

- Use the language's logging library, never print statements.
- Levels mean something: **DEBUG** detail for diagnosing; **INFO** normal
  milestones; **WARNING** something unexpected that was recovered from;
  **ERROR** an operation that couldn't finish.
- Log enough context to debug (IDs, counts, which step), not whole payloads.
- **Never log secrets or personal data** ([security.md](security.md)).

## Text files are UTF-8 without a BOM

Windows PowerShell 5.1 reads them wrong by default (`—` shows as three odd
characters starting with `â`), and writing that text back saves the
garbling. Use your own file tools, or pass `-Encoding UTF8` to
`Get-Content` and write with
`[System.IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false)))`.

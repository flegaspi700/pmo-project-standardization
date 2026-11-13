# Decisions

Design and technology choices are made by the user, with options laid out,
and logged so the reasoning survives. The project's log is
`docs/decisions.md`, newest entry at the top.

## Before making a change

1. **Check `docs/decisions.md`.** If a relevant decision is already logged,
   follow it instead of deciding again.
2. **Small, easily reversed choices:** pick the simplest option and move on.
   No log entry needed.
3. **Significant choices:** don't decide silently. A choice is significant
   when any of these is true:
   - it's hard or expensive to reverse (language, framework, data format,
     storage, an outside service)
   - it affects more than one component, or the interface between them
   - two or more options are genuinely viable and the right one isn't
     obvious
   - it costs money ([cost.md](cost.md)) or adds a dependency
     ([security.md](security.md) → Dependencies)

## Comparing options

1. **List 2-3 options, always including the simplest one that could work.**
2. **Compare them** against the project's vision and constraints:
   simplicity, effort, cost, performance, security, how easy it is to change
   later, fit with the user's skills.
3. **Recommend one** and name the trade-off it accepts.
4. **The user decides.** Wait for the answer.
5. **Log it** in `docs/decisions.md`. If the project has
   `docs/architecture.md`, update it to match.

## The log entry

```
## YYYY-MM-DD — <short decision title>

**Status:** Proposed | Accepted | Superseded by <entry>

**Context:** What prompted this? Which goals or constraints apply?

**Options considered:**   (skip for small choices)

| Option | Pros | Cons | Cost |
|---|---|---|---|
| <simplest option that could work> | | | <$0 / $X per month / usage-based> |
| <option B> | | | |

**Decision:** What was decided.

**Why:** Which criteria decided it.

**Trade-offs accepted:** What we give up.

**Revisit if:** The condition that would make this worth reconsidering.
```

Rules:

- Log the rejected options too. Knowing why they lost stops the same
  debate from restarting.
- Open questions are logged as `Proposed` entries, with what will settle
  them, so they don't get decided silently.
- **Never rewrite or delete an accepted entry.** If a decision changes, add
  a new entry and mark the old one `Superseded by <new entry>`.

## Choosing the stack

The standard doesn't assume a language. Choosing the stack is the first
significant decision of a new project:

1. Offer 2-3 language and library options with pros and cons, and a
   recommendation. Default to Python unless the project needs something
   else (a browser UI, a game engine, a mobile app), and say so if it does.
2. Wait for the user.
3. Log the stack, and the formatter, linter and test runner, in
   `docs/decisions.md`. Fill in the commands in `AGENTS.md`, and add the
   language's standard ignores to `.gitignore`.

On a project that adopts the standard with code already written, record
the existing stack as it is. Don't propose a different one.

## Architecture docs and diagrams

A project with more than one component, or a design worth drawing, gets
`docs/architecture.md`. It holds:

- a short overview: how the system runs (a loop, a server, a batch job, an
  app) and what persists between runs
- the components and the data passed between them, with the exact shape of
  each interface once it settles
- a **Key decisions** table summarising the significant choices, each
  linking to its entry in `docs/decisions.md`

Diagrams are **Mermaid** (text that renders on GitHub), following the C4
idea of starting wide and zooming in:

| Diagram | Include |
|---|---|
| System context: the system, its users, the outside systems it talks to | Always |
| Components: the parts and what passes between them | Always |
| Sequence, state, data model | Only when a flow, a set of modes or stored data needs it |

- About 10 boxes at most per diagram. Label arrows with what moves along
  them. Avoid `<`, `>` and quotes in labels; they break rendering.
- **Diagrams must match the code.** Update them in the same change that
  alters components, interfaces, flows, states or stored data. A wrong
  diagram is worse than none.

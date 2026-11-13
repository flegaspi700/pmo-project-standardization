# Sessions and reporting

How an agent works in a project from one session to the next, and how the
project reports its status to the portfolio.

## Working with the user

- **Read the project's `AGENTS.md` first,** every session, before writing
  or changing code. If it says Learning mode is on, follow
  [coding.md](coding.md) → Learning mode.
- **The user decides:** significant choices ([decisions.md](decisions.md)),
  merges ([git.md](git.md)), changes to acceptance criteria
  ([requirements.md](requirements.md)), and anything that costs money
  ([cost.md](cost.md)).
- **Stay in scope.** If a request conflicts with the vision, a non-goal or
  a logged decision, point that out before doing it.
- **Show, don't claim.** Real test output, real command output. If
  something was skipped or failed, say so.
- **Suggest, don't add.** When the project grows into an extra doc (the
  first network call, secret or dependency: `docs/security.md`; a UI:
  `docs/accessibility.md`; a cost: `docs/budget.md`), say so and offer to
  add it.

## Start of a session

Read the latest entry in `docs/session-log.md` to pick up where the last
session stopped.

## End of a session

When the user is stopping (`/wrap-up`):

1. Add an entry at the top of `docs/session-log.md`:

   ```
   ## YYYY-MM-DD — <short summary>

   **Worked on:** <story IDs>
   **Time spent:** <hours, e.g. 1.5h>
   **Changed:** <file or folder — what and why, one line each>
   **Stopped at:** <what works, what's half-done, any failing test and why>
   **Next step:** <specific enough to start on without thinking>
   **Open questions:** <anything waiting on the user, or "None">
   ```

2. Update the counts in `portfolio.json` (below).
3. Flag anything uncommitted or unmerged.

## Reporting to the portfolio

`portfolio.json` is what the project reports to the portfolio dashboard:
owner, sponsor, program, lifecycle, health, phase, progress, risks,
blockers, call-outs, budget. The fields and rules are in the
[reporting contract](../spec/reporting-contract.md).

- `/report` updates it with the user; `/wrap-up` refreshes the counts.
- **Never guess health, risks, blockers or call-outs: ask the user.**
- Unknown stays `null`. Keep it valid JSON (UTF-8, 2-space indent).
- `program` is free text: the group the dashboard shows the project under.

A repo can report without adopting the rest of the standard: a valid
`portfolio.json` alone puts it at compliance level 1
([compliance spec](../spec/compliance.md)).

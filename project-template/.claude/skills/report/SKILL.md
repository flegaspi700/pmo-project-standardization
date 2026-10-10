---
name: report
description: Write a status report (weekly or at phase end) from the docs, update the Gantt chart and plan dates, and ask the user for the judgment calls.
disable-model-invocation: true
---

Write a status report. (If `09` is `Not needed` in the Doc status table in
`AGENTS.md`, the project is small — give the numbers in chat only, and
suggest turning `09` on if it now has more than one phase. Likewise skip the
budget lines if `16` is `Not needed`.)

1. Read `docs/01-requirements.md`, `docs/04-project-plan.md`,
   `docs/09-status-report.md` (latest report and template),
   `docs/10-session-log.md` (entries since the last report), and the
   Monthly log in `docs/16-budget.md`.
2. Count stories by status per phase **from the docs** — don't estimate.
   List done since the last report, in progress, and next up. Include open
   bugs.
3. Sum **Time spent** from session log entries since the last report and
   for the current phase; quote the latest spend from `docs/16-budget.md`.
4. Update `docs/04-project-plan.md`: actual dates in the Status table, and
   in the Gantt chart mark bars `done` / `active` (add `crit` to anything
   late). Never change planned dates.
5. **Ask the user** for the Overall status (🟢 / 🟡 / 🔴 and why) and the
   blockers and risks — don't guess these.
6. If this report closes a phase, also ask the retrospective questions
   (went well, didn't, change next phase) and include the estimate vs
   actual. Offer to apply the "change next phase" items to the relevant
   docs.
7. Write the report at the top of `docs/09-status-report.md` using its
   template.

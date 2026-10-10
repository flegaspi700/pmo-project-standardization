# Status reports

A short progress snapshot, written weekly or at the end of each phase —
whichever comes first. Newest report at the top; old ones stay below as
history. Copy the template at the bottom for each new report.

Most of a report can be generated from `01-requirements.md` (story
statuses) and `04-project-plan.md` (phases and dates) — run `/report` in
Claude Code. Write the "Overall" line and the blockers yourself; that's the
part that needs judgment.

---

## Template

```
## Status — YYYY-MM-DD

**Overall:** 🟢 On track | 🟡 At risk | 🔴 Off track — <one sentence why>
**Current phase:** <n — name> (planned end YYYY-MM-DD, forecast YYYY-MM-DD)

### Progress

| Phase | Stories done | Status |
|---|---|---|
| 1 — <name> | 3 / 5 | In progress |
| 2 — <name> | 0 / 4 | Not started |

**Total:** <done> / <total> stories (<percent>%)

### Done since last report
- <S-ID — story title>

### In progress
- <S-ID — story title> — <what's left>

### Next up
- <S-ID — story title>

### Blockers and risks
- <what's blocking or threatening the plan> → <what you'll do about it>
- <or "None">

### Budget
**Spend:** <$ this month> of <$ monthly budget> (from `16-budget.md` →
Monthly log) · **Hours:** <hours this phase> of <estimate> (summed from
`10-session-log.md`)

### Decisions made
- <links to new entries in 05-decisions-log.md, or "None">

### Schedule
<Planned vs actual for any phase that finished or slipped, and why —
e.g. "Phase 1 took 7 days vs 4 planned: detection needed a second approach
(see decisions log 2026-01-12).">

### Retrospective — only in the report that closes a phase
**Went well:** <keep doing this>
**Didn't go well:** <what hurt — tools, estimates, prompts, scope>
**Change next phase:** <one to three concrete changes, e.g. "split
stories smaller", "add the prompt that worked to 08-prompt-log.md">
**Estimate vs actual:** <planned days vs actual, and the main reason for
the gap>
```

Follow through on "Change next phase": if it changes how you work, update
the relevant doc (conventions, testing checklist, prompt log, or
`AGENTS.md`) so the lesson sticks.

# Reporting contract: `portfolio.json`

Contract version **1**, added in template v1.3.0. JSON Schema:
[`portfolio.schema.json`](portfolio.schema.json).

Every project on the standard has a `portfolio.json` at its root: what it
reports to the portfolio. A portfolio view (for example a dashboard for a
portfolio manager) reads this file from each repo instead of parsing the
docs. Background: [ideas/portfolio-reporting.md](../ideas/portfolio-reporting.md).

## Rules

- **Store only what the repo can't tell by itself.** Last activity, open
  issues and PRs, template version (from `AGENTS.md`) and compliance level
  are worked out by the portfolio scan. A repo never declares its own
  compliance.
- **Skills write it, people don't have to.** `/new-project`, `/report` and
  `/wrap-up` keep it current (table below). Editing by hand is fine; keep
  it valid against the schema.
- **Judgment calls come from a person.** Health, risks, blockers and
  call-outs are asked of the user, never guessed by the agent.
- **Unknown is `null`, not a guess.** A new project has `health:
  "not-reported"` and mostly `null` fields until the first `/report`.
- UTF-8 without a BOM, 2-space indent, valid JSON.

## Fields

| Field | Required | Meaning | Written by |
|---|---|---|---|
| `schema` | yes | Contract version (`1`) | template |
| `name` | yes | Project name | `new-project.ps1` |
| `summary` | | One sentence: what it does and for whom | `/new-project` (from the vision) |
| `owner` | | Accountable for delivery day to day | `/new-project` |
| `sponsor` | | Senior person who backs the project and decides call-outs | `/new-project` |
| `program` | | Group the portfolio rolls this project up under | `/new-project` |
| `lifecycle` | yes | `planning` · `active` · `on-hold` · `done` · `archived` | `/new-project`, then `/report` |
| `health` | yes | `green` · `amber` · `red` · `not-reported` | `/report` (asks) |
| `health_reason` | | One sentence why | `/report` (asks) |
| `phase` | | `{current, name}` from `docs/04-project-plan.md` | `/report` |
| `progress` | | `{stories_done, stories_total, open_bugs, as_of}` counted from `docs/01-requirements.md` | `/report`, `/wrap-up` |
| `next_milestone` | | `{name, date}`: usually the current phase's planned end | `/report` |
| `risks` | | `[{title, severity, mitigation}]`, severity `high` · `medium` · `low`: things that might happen | `/report` (asks) |
| `blockers` | | `[{title, since, needs}]`: things stopping work now | `/report` (asks) |
| `callouts` | | What leadership needs to know or decide | `/report` (asks) |
| `budget` | | `{month, currency, spend, limit, hours_phase, hours_phase_estimate}` from `docs/16-budget.md` and the session log; `null` when `16` is Not needed | `/report` |
| `updated` | | Date a person last reviewed health, risks and call-outs | `/report` |

Two dates, on purpose: `progress.as_of` changes every session (counts),
`updated` changes only when a person reviews the judgment fields. A portfolio
view can then flag a stale report: work keeps happening, but nobody has
reviewed health in a while.

## Example

```json
{
  "$schema": "https://raw.githubusercontent.com/flegaspi700/pmo-project-standardization/main/spec/portfolio.schema.json",
  "schema": 1,
  "name": "OCR Pipeline",
  "summary": "Extracts text from scanned invoices into structured data.",
  "owner": "Frederick Legaspi",
  "sponsor": "Frederick Legaspi",
  "program": "AI tooling",
  "lifecycle": "active",
  "health": "amber",
  "health_reason": "OCR accuracy below target on handwritten fields.",
  "phase": { "current": 2, "name": "Field extraction" },
  "progress": { "stories_done": 7, "stories_total": 12, "open_bugs": 1, "as_of": "2026-10-24" },
  "next_milestone": { "name": "Phase 2 done", "date": "2026-11-07" },
  "risks": [
    { "title": "Handwriting accuracy", "severity": "high", "mitigation": "Test a second OCR model (S2.3.1)" }
  ],
  "blockers": [],
  "callouts": ["Decision needed: paid OCR API ($20/month) vs. self-hosted."],
  "budget": { "month": "2026-10", "currency": "USD", "spend": 4.2, "limit": 20, "hours_phase": 9.5, "hours_phase_estimate": 12 },
  "updated": "2026-10-24"
}
```

## Changing the contract

- Adding an optional field: same `schema` number, new template release.
- Renaming, removing or changing the meaning of a field: bump `schema`,
  describe the migration in the CHANGELOG. Readers must handle every
  `schema` version still in use.

## Contract-only adoption

A repo can add **only** `portfolio.json`, without the rest of the
template, and appear in the portfolio with real status: compliance level 1,
Reporting. See [compliance.md](compliance.md).

# Cost

What a project costs in money and time. The first rule applies to every
project; the rest applies once a project costs money, when it keeps
`docs/budget.md`.

## The rule

**Never add anything that costs money without a logged decision:** a paid
service or tier, a paid asset, or an API billed by usage. Present it as a
significant choice with the cost in the options table
([decisions.md](decisions.md)), and wait for the user. Prefer free tiers and
local tools while they're good enough, and note in the decision what would
make a paid option worth it.

## `docs/budget.md`

Added with the first cost. It holds:

- **Limits:** monthly budget, total budget (or "none"), a stop-and-decide
  threshold (for example 80% of the monthly budget), and a time budget.
  Also recorded as a cost NFR in `docs/requirements.md`.
- **Recurring costs:** service, what it's for, plan, cost per month,
  renewal date, how to cancel.
- **One-off costs:** date, item, what it's for, cost.
- **Usage-based costs** (AI APIs, cloud): what drives the cost, where to see
  usage, and **the spend limit or alert set at the provider**, at or below
  the monthly budget. A note in a doc doesn't stop a runaway bill; a limit
  at the provider does.
- **Monthly log:** budget, actual, biggest cost, notes. Filled in at the
  start of each month from the providers' billing pages.

`/report` copies the latest figures into `portfolio.json` → `budget`.

## Time

Hours are a cost too, and the one most often underestimated.

- Each session log entry records **Time spent** ([sessions.md](sessions.md)).
- Over the time budget two reports in a row: revisit the scope or the
  phases, rather than silently working more.

## End of each phase

- [ ] Spend and hours checked against the limits
- [ ] Recurring costs still needed; cancel what isn't

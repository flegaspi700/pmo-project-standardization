# Budget and cost

What the project costs, in **money** and **time**, measured against limits
set upfront. Usage-based costs (AI APIs, cloud) are the ones that surprise
people, so they get a spend limit at the provider, not just a note here.

## Limits

Set in Phase 0, from `00-vision.md` → Constraints. Also recorded as a cost
NFR in `01-requirements.md`.

| Limit | Amount |
|---|---|
| Monthly budget | <e.g. $20 / month> |
| Total budget | <e.g. $100 for the whole project, or "none"> |
| Stop-and-decide threshold | <e.g. 80% of the monthly budget — stop adding costs and decide what to cut> |
| Time budget | <e.g. ~6 hours / week> |

## Recurring costs

Subscriptions and anything billed on a schedule.

| Service | What it's for | Plan | Cost / month | Renews | How to cancel |
|---|---|---|---|---|---|
| <e.g. hosting> | <...> | <free tier / paid plan> | <$0> | <YYYY-MM-DD> | <link or steps> |

## One-off costs

| Date | Item | What it's for | Cost |
|---|---|---|---|
| YYYY-MM-DD | <e.g. asset pack, domain, licence> | <...> | <$> |

## Usage-based costs

Billed by how much you use them — AI APIs, cloud compute, storage,
bandwidth. For each one, **set a spend limit or alert at the provider**
(most have one in their billing settings) at or below the monthly budget.

| Service | What drives the cost | Where to see usage | Limit / alert set at provider |
|---|---|---|---|
| <e.g. AI API> | <e.g. tokens per request × requests per day> | <billing / usage dashboard link> | <e.g. hard limit $10/month, alert at $5> |

## Monthly log

Fill in at the start of each month for the previous month, from the
providers' billing pages. The status report (`09-status-report.md`) quotes
the latest row.

| Month | Budget | Actual | Biggest cost | Notes |
|---|---|---|---|---|
| YYYY-MM | <$> | <$> | <service> | <anything unusual, and what you'll change> |

## Time

Hours are a cost too, and the one most often underestimated.

- Each session log entry (`10-session-log.md`) records **Time spent**.
- The status report adds them up per phase and compares against the
  phase estimate in `04-project-plan.md`.
- Over the time budget for two reports in a row → revisit scope in
  `00-vision.md` or the plan, rather than silently working more.

## Rules

- **No new cost without a decision.** Any paid service, paid tier, paid
  asset, or API with usage-based billing gets an entry in
  `05-decisions-log.md` (with the cost in the options table) before it's
  added — by you or an AI agent.
- Prefer free tiers and local tools while they're good enough; note in the
  decision what would trigger moving to a paid option.
- Cancel what you no longer use — check the recurring table at each phase
  end.

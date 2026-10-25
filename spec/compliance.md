# Compliance spec

Spec version **1**, added in template v1.4.0. Machine-readable checks:
[`compliance-checks.json`](compliance-checks.json). Local tool:
[`check-compliance.ps1`](../check-compliance.ps1).

When does a repo count as "on the standard", and is it up to date? A
portfolio view (the dashboard project) answers that for every repo with the
checks below. Background: [ideas/portfolio-reporting.md](../ideas/portfolio-reporting.md).

## Principle: evidence, not the version stamp

A repo is judged by **what is in it**, not by the `Template version:` line
in its `AGENTS.md`. Each rule of the standard has a check that looks for
evidence: a file exists, a file contains a pattern, a JSON file fits its
schema. So a repo adopted before the stamp existed, or updated by hand,
is judged correctly, and missing an *optional* change never counts against
it. The stamp is shown for information only.

## Levels

| Level | Name | Meaning | Earned when |
|---|---|---|---|
| 0 | Not on standard | Nothing the portfolio can read | — |
| 1 | Reporting | Reports its status, but hasn't adopted the template | `C4` passes (valid `portfolio.json`), core checks don't |
| 2 | Adopted | Core structure in place | `C1`, `C2`, `C3` pass |
| 3 | Current | Has every required change | Adopted, and every **due** required check passes |

Level 1 is a deliberate first step for rolling the standard out: a repo
can add just `portfolio.json` and show real status in the portfolio before
anyone adopts the full template there.

## Checks

| ID | Check | Severity | Since | Required from |
|---|---|---|---|---|
| C1 | `AGENTS.md` has the `## Doc status` table | required | v1.0.0 | 2026-11-09 |
| C2 | `AGENTS.md` has the `**Hosting: local\|github**` line | required | v1.0.0 | 2026-11-09 |
| C3 | Docs `00`-`16` all exist (stubs count) | required | v1.0.0 | 2026-11-09 |
| C4 | `portfolio.json` exists and fits the schema | required | v1.3.0 | 2026-11-24 |
| C5 | `AGENTS.md` has the UTF-8 rule | optional | v1.1.0 | — |
| C6 | `AGENTS.md` has a `Template version:` line | optional | v1.2.0 | — |
| C7 | PR template present (only when hosting is `github`) | optional | v1.0.0 | — |
| W1 | No `CLAUDE.md` that hides `AGENTS.md` | warning | v1.0.0 | — |
| W2 | Planning docs `00`, `02`-`04` have no unfilled `<...>` placeholders | warning | v1.0.0 | — |

W2 skips `01-requirements.md` on purpose: its "Template for new items" and
bug template sections keep their placeholders in a finished project. A
placeholder is `<` + a letter + text with a space + `>`, so HTML
comments, `<br/>` and backticked `<` / `>` don't count.

Every check in `compliance-checks.json` has a `fix`: the one-line action a
portfolio view shows next to a failure.

**Severities**
- **required:** counts toward Current once its grace period is over.
- **optional:** shown, never lowers the level.
- **warning:** something a portfolio manager should see; never lowers the
  level.

**Check kinds** (all a scanner needs to implement):

| Kind | Passes when |
|---|---|
| `exists` | Every file in `paths` exists |
| `contains` | The file at `path` matches the regex `pattern`. With `if_exists: true`, a missing file also passes. |
| `absent` | None of the files in `paths` match `pattern` (missing files are skipped) |
| `schema` | The file at `path` is valid JSON that fits the schema file named in `schema` (in `spec/`) |

`applies_if` (`{path, pattern}`) makes a check apply only when that file
matches. Otherwise the result is "n/a", which counts as neither pass nor fail.

## Grace period

A new **required** check is due **30 days after the release** that adds it
(`required_from` in the registry). Until then, a failure shows as a warning
("C4 required from 2026-11-24") and doesn't lower the level, so a release
doesn't instantly downgrade the whole portfolio. The first checks count
from v1.0.0 (2026-10-10), so they're due 2026-11-09.

## Warnings worked out by the scanner

These need GitHub data or dates, so the portfolio scan works them out,
not the file checks:

| ID | Warning | Rule |
|---|---|---|
| S1 | Stale report | `portfolio.json` → `updated` is more than 30 days old (or `null`) while the repo had pushes in the last 30 days |
| S2 | Health never reported | `health` is `not-reported` 14 days after the repo was created or adopted the template |
| S3 | Required change due soon | A required check fails and its `required_from` is within 14 days |

## Which repos are in scope

Every repo under the account, except:

- **archived** repos
- **forks**
- repos with the GitHub topic **`portfolio-exclude`** (e.g. course
  exercises, experiments)

Excluded repos don't count in the portfolio totals. A view may list them
separately, collapsed.

## Changing the checks

Every template release that changes the standard updates the registry in
the same PR:

1. Add a check for each new rule, with `since` set to the new version.
2. Mark it `required` or `optional`. Required means a repo without it
   doesn't fully follow the standard. Optional means nice to have.
3. For `required`, set `required_from` to the release date + 30 days.
4. Say so in the CHANGELOG entry, e.g. "Compliance: C8 required from
   2026-12-31".

Never reuse an ID. To retire a rule, make it `optional` first, then remove
it in a later release. `tests/check-template.ps1` confirms that a freshly
generated project passes every required check.

## Run it locally

```powershell
.\check-compliance.ps1 -Path D:\Projects\some-repo
.\check-compliance.ps1 -Path . -Today 2026-12-01   # as if it were that date
```

It prints each check, the level and the warnings, and changes nothing.

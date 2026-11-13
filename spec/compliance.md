# Compliance spec

Spec version **2**, for standard v2 (spec version 1 came with template
v1.4.0). Machine-readable checks:
[`compliance-checks.json`](compliance-checks.json). Local tool:
[`check-compliance.ps1`](../check-compliance.ps1).

When does a repo count as "on the standard", and is it up to date? A
portfolio view (the dashboard project) answers that for every repo with the
checks below. Background: [ideas/portfolio-reporting.md](../ideas/portfolio-reporting.md).

## Principle: evidence in the repo

A repo is judged by **what is in it**: a file exists, a file contains a
pattern, a JSON file fits its schema. A repo set up by hand is judged the
same as one set up by `/new-project`.

In v2 the `**Standard:**` line is evidence too, not just a label. The rules
live in this repo, and a project's agents read them at the version that
line names (`skills/preflight.md`), so the line decides which rules the
project actually follows. `C8` checks the line is there; `C10` checks it
names the current major version.

## Levels

| Level | Name | Meaning | Earned when |
|---|---|---|---|
| 0 | Not on standard | Nothing the portfolio can read | — |
| 1 | Reporting | Reports its status, but hasn't adopted the standard | `C4` passes (valid `portfolio.json`) |
| 2 | Adopted | On the standard | `C4`, `C2`, `C8`, `C9` pass |
| 3 | Current | Adopted, on the current major version, nothing due missing | Adopted, and every **due** required check passes (including `C10`) |

Level 1 is a deliberate first step: a repo can add just `portfolio.json`
(`/new-project`, option 4) and show real status in the portfolio without
adopting the rest. Learning and course repos may stay there.

**v1 projects** (an `AGENTS.md` with `Template version:` and no `Standard:`
line) are at most level 1 under this spec: they reach Reporting through
their `portfolio.json`, and the v1-only checks below show what they have.
Moving them to v2 is the fix, not passing the v1 checks.

## Checks

| ID | Check | Severity | Since | Required from |
|---|---|---|---|---|
| C8 | `AGENTS.md` has `**Standard:** pmo-project-standardization vX.Y.Z` | required | v2.0.0 | 2026-12-13 |
| C2 | `AGENTS.md` has the `**Hosting: local\|github**` line | required | v1.0.0 | 2026-11-09 |
| C9 | `docs/requirements.md`, `docs/decisions.md`, `docs/session-log.md` exist | required | v2.0.0 | 2026-12-13 |
| C4 | `portfolio.json` exists and fits the schema | required | v1.3.0 | 2026-11-24 |
| C10 | The Standard line names v2 (the current major version) | required | v2.0.0 | 2026-12-13 |
| C5 | `AGENTS.md` has the UTF-8 rule | optional | v1.1.0 | — |
| C1 | v1 only: `AGENTS.md` has the `## Doc status` table | optional | v1.0.0 | — |
| C3 | v1 only: docs `00`-`16` all exist | optional | v1.0.0 | — |
| C6 | v1 only: `AGENTS.md` has a `Template version:` line | optional | v1.2.0 | — |
| C7 | v1 only: PR template present (hosting `github`) | optional | v1.0.0 | — |
| W1 | A `CLAUDE.md`, if there is one, has an `@AGENTS.md` line | warning | v1.0.0 | — |
| W3 | `docs/requirements.md` has no unfilled `<...>` placeholders | warning | v2.0.0 | — |
| W4 | No v1 copies of the standard's skills in `.claude/skills/` | warning | v2.0.0 | — |
| W2 | v1 only: planning docs `00`, `02`-`04` have no unfilled placeholders | warning | v1.0.0 | — |

**Changed in spec version 2:**
- C1, C3, C6, C7 and W2 checked the v1 layout. They're now optional (or a
  warning) and apply only to v1 projects (`applies_if` a `Template
  version:` line), so they never count against a v2 project. They'll be
  removed in a later release.
- C2 stays: v2 keeps the Hosting line.
- Adopted now includes C4: a v2 project always reports.
- W1 now needs the `@AGENTS.md` import line. A `CLAUDE.md` that only
  mentions `AGENTS.md` in a sentence doesn't make Claude Code load it.
- W4: a project-level copy of a skill runs instead of the one installed
  from this repo, so the project would follow stale v1 instructions.

A placeholder (W2, W3) is `<` + a letter + text with a space + `>`, so HTML
comments, `<br/>` and backticked `<` / `>` don't count. W3 can check all of
`docs/requirements.md`, because the v2 file has no template sections.

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
from v1.0.0 (2026-10-10), so they're due 2026-11-09. The v2 checks carry a
provisional date (2026-12-13); it's set to the v2.0.0 release date + 30
days when v2.0.0 is released.

## Warnings worked out by the scanner

These need GitHub data or dates, so the portfolio scan works them out,
not the file checks:

| ID | Warning | Rule |
|---|---|---|
| S1 | Stale report | `portfolio.json` → `updated` is more than 30 days old (or `null`) while the repo had pushes in the last 30 days |
| S2 | Health never reported | `health` is `not-reported` 14 days after the repo was created or adopted the standard |
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

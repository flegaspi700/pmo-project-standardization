# TODO: brainstorm a portfolio health dashboard

Status: **idea, brainstorm in progress.** Captured 2026-10-25. Follows on
from [standardize-repos.md](standardize-repos.md). Nothing built yet.

## The idea

A UI where someone senior (a CEO, a portfolio manager) reviews every repo
under one GitHub account as a portfolio: what each project is, who owns
it, where it stands, its risks, issues and call-outs, and the overall
health of the portfolio. Compliance with the standard is one part of that
health, not the whole point.

**User for now:** just me. **Designed as if** a portfolio manager or
executive uses it, so it should read at a glance and drill down on demand.

## Three layers, kept apart

| Layer | PMO equivalent | Where it lives | Answers |
|---|---|---|---|
| The standard | Methodology / policy | This repo: template, CHANGELOG, tags | What should a project have? |
| Compliance rules | Audit checklist | This repo, as a written spec | How do we tell if a repo meets it? |
| Portfolio view | Portfolio dashboard | **A separate reporting project** | Across all projects: health, status, risks, compliance |

The definition of "compliant" stays in this repo, so it changes with the
template and every report uses the same rules. The dashboard only reads.

## What the viewer needs to see

- **All repos** under the account, including ones not on the standard
  (they show with less data, and that gap is itself a finding).
- **Status:** overall 🟢/🟡/🔴, current phase, story progress, last activity.
- **Risks and issues:** top risks with mitigation, open blockers, open bugs.
- **Owner:** who is accountable for the project.
- **Call-outs:** the one or two things the project wants leadership to know.
- **Compliance:** level (below), template version, releases behind, problems.
- **Portfolio roll-up:** counts by health and compliance, what needs
  attention first.

## Compliance levels (draft)

| Level | Meaning | Check |
|---|---|---|
| 0 Not adopted | No template `AGENTS.md` | No `## Doc status` table or `**Hosting:**` line |
| 1 Adopted | Template `AGENTS.md`, docs `00`–`16` present (stubs count) | Files exist, no unfilled script placeholders |
| 2 Versioned | `Template version:` line present | Read the stamp |
| 3 Current | Stamp matches the latest tag, or has every *required* change | Compare with tags / CHANGELOG |

Health flags at any level: a `CLAUDE.md` (makes Claude Code ignore
`AGENTS.md`), Active docs still full of placeholders, stale status report.

## Where the data would come from

| Need | Source today | Gap |
|---|---|---|
| Repo list, last activity, language, open issues/PRs | GitHub API | None |
| Compliance level, version | `AGENTS.md`, `docs/` | Version stamp only exists from v1.2.0 |
| Overall status, phase, risks | `docs/09-status-report.md` (latest entry), `docs/00-vision.md` risks | Free-form markdown; `09` can be a "Not needed" stub on Small projects |
| Story progress | `docs/01-requirements.md` statuses | Parsing tables in markdown |
| Owner | Nowhere | **Missing from the standard** |
| Call-outs | Nowhere | **Missing from the standard** |
| Budget | `docs/16-budget.md` | Free-form; optional doc |

**Key finding:** the dashboard needs facts the standard doesn't record yet
(owner, call-outs) and facts it records only as prose (status, risks). So
the reporting project depends on a **reporting contract** added to the
standard first: a small machine-readable block or file per repo, e.g.
`project.json` or YAML front matter in `AGENTS.md`, with owner, overall
status, phase, top risks, call-outs, and template version. `/report` and
`/wrap-up` would keep it current, so nobody fills it by hand.

## Directions for the UI

| Direction | What the viewer sees | Pros | Cons | Effort |
|---|---|---|---|---|
| 1 Markdown report (simplest) | `PORTFOLIO.md` table, regenerated on demand or on a schedule | Nothing to host, readable on GitHub | Static, no drill-down; not executive-friendly | S |
| 2 Static dashboard | GitHub Pages site rebuilt by a scheduled Action: summary tiles, sortable table, per-repo detail page | Looks like a real portfolio tool, free hosting, strong portfolio piece | Build step; data only as fresh as the last run | M |
| 3 Issues + Projects board | Scan opens a "standardization" issue per non-compliant repo, rolled up on a GitHub Projects board | Gaps become work items where the work happens | Noisy if rules are strict; issues in public repos | M |
| 4 Interactive app | Live web app with filters and history | Most flexible, trends over time | Hosting, auth, most work for an unproven need | L |

**Leaning:** with an executive-style viewer, **2 (static dashboard)** fits
best. 1 is its first milestone (same scan, no page yet); 3 can be added
later to turn gaps into tasks; 4 only if trends over time prove necessary.

## Actions on the dashboard (2026-10-25)

Which of the standard's tools become buttons depends on whether they
**read** or **write**, and on who is looking.

| Tool | On the dashboard | Why |
|---|---|---|
| `check-compliance.ps1` | Runs in every scan; the level and warnings are shown per repo. At most a "Re-scan now" button | Read-only, so nobody should have to click |
| `update-plan.ps1` | Shown, not clicked: "Behind: v1.0.0 → v1.5.0, 2 files to add, 3 to merge" | Read-only: part of the data |
| `/update-template` | "Request update" (v1) or "Start update" (later) | Writes to the repo; merges and judgment calls need a person |
| `/report` | "Request status report", offered when the report is stale (S1) or health was never reported (S2) | Health, risks, call-outs must come from the owner |
| `portfolio.json` | "Edit" link to the file in GitHub's editor | Small fixes without tooling |
| `/new-project` | "Add project" | Starts the standard on a new repo |

**Who presses the button matters.** A portfolio manager or executive
shouldn't change someone else's repo directly, and the reporting contract
says judgment fields come from the project's people. So most buttons are
**requests to the owner**, not actions.

| Approach | How a button works | Static page? | Effort |
|---|---|---|---|
| 1 Links and requests | "Request update" opens a pre-filled GitHub issue in that repo for the owner (e.g. "Please run `/update-template`, v1.0.0 → v1.5.0"); same for status reports | Yes: plain links, no sign-in or secrets | S |
| 2 Trigger automation | "Re-scan" starts a GitHub Action (`workflow_dispatch`); "Start update" runs Claude Code in an Action that opens a **draft PR** for the owner to review and complete with the judgment fields | Needs GitHub sign-in or a token, which a static page can't hold safely | M-L |
| 3 Full app | Real buttons with a backend, permissions, audit trail | Needs hosting and auth | L |

**Leaning:** v1 is read-only with link buttons (approach 1). The issues
it opens are a visible trail of "leadership asked, owner did it": real
PMO governance at no hosting cost. Approach 2 is a strong second release
(automated draft PR, a person still owns the judgment fields).

## Riskiest assumption

That the data will be there. Most repos aren't on the standard, and the
ones that are record status as prose. The dashboard is only as good as
the contract. **Cheap test:** hand-write the contract file for
`ocr-pipeline` and one non-standard repo, then mock the dashboard row for
each. If the rows are useful, build the scan; if not, fix the contract
first.

## Suggested order

1. **Reporting contract** in the standard: fields, file format, which
   skill keeps each field current. Ship it as a template release.
   **Done 2026-10-25:** `portfolio.json`, see
   [spec/reporting-contract.md](../spec/reporting-contract.md). Owner and
   sponsor both recorded; budget included when doc `16` is active.
2. **Done 2026-10-25:** [spec/compliance.md](../spec/compliance.md),
   evidence-based checks, contract-only level allowed, `CLAUDE.md` as a
   warning, 30-day grace, exclusions by archived/fork/topic.
   **Compliance spec** (levels above, required vs optional changes,
   marked in the CHANGELOG).
3. **Pilot:** apply both to `ocr-pipeline` plus 1-2 more repos (ties in
   with [standardize-repos.md](standardize-repos.md)).
   **ocr-pipeline done 2026-10-25** (v1.0.0 → v1.4.0 by hand, level 3, no
   warnings); its lessons became `/update-template` (v1.5.0). Next: run
   `/update-template` end to end on a second repo.
4. **Reporting project** via `/new-project` (brainstorm option): scan →
   Markdown report → static dashboard.

## Open questions

- **Scope:** only repos active in 2026 (~11), or all ~50? Many older ones
  are course exercises or forks; include them, hide them, or tag them as
  "archive"?
- **Owner:** with one account, is "owner" always me, or a role per project
  (e.g. sponsor vs. builder) to make the demo realistic?
- **Public or private:** a public dashboard shows each repo's risks and
  call-outs; are any repos sensitive?
- **Freshness:** is a daily rebuild enough, or must it update on every push?
- **`CLAUDE.md` repos** (enterprise-governance-readiness, game-ai-harness,
  snack_attack): merge into `AGENTS.md`, or keep a one-line `CLAUDE.md`
  pointing to it?

## Snapshot (2026-10-25)

Of the 11 repos pushed in 2026: 1 adopted the template (`ocr-pipeline`,
17 docs, no version stamp yet); `game-agent` has the original pre-template
`AGENTS.md`; 3 have a `CLAUDE.md`; none has a version stamp.

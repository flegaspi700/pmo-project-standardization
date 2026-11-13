# Decisions log

Design decisions about the template itself, ADR-style. Newest entry at the
top. Projects log their own decisions in their own repos; this file is only
for the standard. Never rewrite an accepted entry: add a new one and mark
the old one `Superseded by <entry>`.

---

## 2026-11-13: Shared standards, small per-repo footprint (v2)

**Status:** Accepted. Detailed design, including the answered questions,
in [`ideas/lightweight-template.md`](ideas/lightweight-template.md).

**Context:** The goal is to standardize every project (breaking down
requirements, coding standards, security, reporting) and see them all on
one site, grouped by program. v1 copies the whole standard into each repo:
33 files and about 2,300 lines, including a 301-line `AGENTS.md`, 17 docs
and 10 skills. About 1,500 of those lines are rules that are the same in
every project. Adoption is the bottleneck: 2 of about 20 active repos are on
the standard (2026-11-02 compliance run), and the user finds the template
too heavy to apply to the rest. Five repos also have a `CLAUDE.md`, which
hides a v1 `AGENTS.md` from Claude Code.

**Options considered:**

| Option | Pros | Cons | Cost |
|---|---|---|---|
| **A. Shared standards, small footprint.** Rules and skills live once in this repo (skills installed for the user); each repo gets about 5 files that point to the standard at a pinned version. Extras are opt-in. | Repos stay light, so adoption is a short PR. A rule changes in one place. Removes most of the need for `/update-template`. Works next to an existing `CLAUDE.md`. | A repo read alone shows links, not the full rules. Skills only exist where they're installed. Refactor of the template, compliance checks and the 2 adopted repos. | Template rework, then a v2.0.0 release |
| B. Trim in place. Merge 17 docs into about 6, shorten `AGENTS.md`, still copied into every repo. | Smaller change; repos stay self-contained. | Still about 12 files per repo; every rule change still has to be pushed to every repo. | Medium |
| C. No change. Most repos stay at Level 1 (`portfolio.json` only); the full template only for big projects. | Fastest path to the dashboard; nothing to build. | Standardization barely happens, which is half the goal. | None |

**Decision:** Option A.

**Why:** It serves both halves of the goal. Rules are actually shared
instead of copied, and every repo still reports to the dashboard through
`portfolio.json`. Adopting the standard becomes small enough to do across
all active repos.

**Trade-offs accepted:**
- Repos aren't self-contained: the full rules are in this repo. The
  per-repo `AGENTS.md` keeps a short list of core rules so an agent that
  never follows a link still works by the standard.
- Skills (`/story`, `/report`, ...) are installed for the user, not shipped
  in each repo, so they aren't there on another machine or in a cloud
  session until installed.
- Breaking change: v2.0.0. The compliance checks for Levels 2 and 3 are
  redefined, and the two v1 repos (`ocr-pipeline`, `portfolio-dashboard`)
  are migrated.

**Kept from v1:** the rules text, the skills, `portfolio.json` and its
schema, compliance levels 0-3 (with new checks), additive installs on
existing repos, hosting `local|github`, and branch + PR per change.

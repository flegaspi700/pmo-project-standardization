# TODO: brainstorm standardizing all repos on the template

Status: **idea, not started.** Captured 2026-10-11. Brainstorm this before
building anything.

## The idea

Use the project template as the standard for every project: pull each repo
and adjust it to the template. That gives real "enterprise" impact, and once
all repos share a standard, a reporting solution (probably a separate
project) can report across them.

## What already supports it

- `/new-project` can already add the template to an existing GitHub repo:
  preview first, never overwrites files the repo already has.
- `tests/check-template.ps1` is a first piece of automated checking.

## What it changes

- **"Adjusted" needs a definition.** Adding the docs, skills and `AGENTS.md`
  alongside the code is safe, and the template already does it.
  Restructuring each repo's code to match is a much bigger, riskier job.
  Proposal: the standard covers the files and conventions, not the code
  layout.
- **Template version stamp (follow-up #3) becomes essential.** With many
  repos on the standard, you need to know which version each one has and
  what it's missing. Without it, reporting can't tell "current" from
  "never updated".
- **The standard needs a contract.** Reporting can only read what's in a
  predictable place: template version, the hosting line, the doc status
  table, story IDs and status in `docs/01`. Write a short spec of this
  before building any reporting.
- **Follow-up #1 becomes the pilot.** Running `/new-project` on 2-3 real
  repos is the test that hasn't been done yet, and it will show where the
  template doesn't fit existing projects.

## Suggested order

1. **List the repos.** Fetch the GitHub repos (read-only) and sort them:
   active or not, has docs or not, which language. Shows how big the
   rollout is.
2. **Pilot on 2-3 repos** (follow-up #1). Feed what's learned back into the
   template.
3. **Version stamp and contract** (follow-up #3), plus a short "what
   reporting can rely on" doc.
4. **Reporting as its own project,** created with `/new-project` (brainstorm
   option). It reads the contract from each repo.

## Questions that shape this

- About how many repos, and are they all yours, or would teammates or an
  organisation be involved?
- Does "all projects" include old or archived repos, or only active ones?
- What should the report answer first? For example "which repos follow the
  standard", "what's the status of each project", or "where is time and
  money going".

Continued in [portfolio-reporting.md](portfolio-reporting.md) (2026-10-25):
the reporting side, as a portfolio health dashboard.

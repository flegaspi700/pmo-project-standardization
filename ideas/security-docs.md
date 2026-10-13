# TODO: decide whether to expand the security docs

Status: **idea, not started.** Captured 2026-10-12. Wait until v1 has been
used on 2-3 real projects, then decide based on what they actually needed.

## The idea

Add more security docs to the template: `SECURITY.md`, auth, data
security, threat model, and a security checklist.

## What already exists

`project-template/docs/14-security.md` plus the `/security-check` skill
already cover:

- **Threat model:** the "Threat model (lite)" section (four standard
  questions and an asset / entry point table). `/security-check` compares
  the code against it.
- **Security checklist:** "Every change" and "End of each phase"
  checklists, plus a security line in the PR template.

## The real gaps

- **Auth:** nothing about logins (authentication), permissions
  (authorization), sessions, password storage or tokens.
- **Data security:** only a short Privacy section. Nothing on classifying
  data by sensitivity, encryption at rest and in transit, backups,
  retention or deletion.
- **`SECURITY.md`:** the GitHub convention for how outsiders report a
  vulnerability privately. Only useful once a repo is public or used by
  other people; all repos are private today.

## Proposal

- Add **Auth** and **Data security** as sections inside `14-security.md`,
  not as new files. Each opens with an "n/a if…" line (no user accounts /
  no personal or sensitive data stored), like the existing GitHub setup
  section does for `Hosting: local`. Extend `/security-check` to review
  them.
- Don't split into five files: they would repeat each other, and small
  projects would have to mark four extra docs `Not needed`.
- Skip `SECURITY.md` until a repo goes public.

## Open questions

- Will any upcoming project have user accounts or store personal or
  sensitive data? That's the trigger to do this.
- If the repo standardization idea (`standardize-repos.md`) goes ahead,
  should the security sections be part of the cross-repo contract?

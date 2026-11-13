# Security

This project's threat model and security setup. The rules are in the
standard's `security.md`; this file records what applies here. Review it at
the end of each phase, and when a change adds a component or a new way in.

## Threat model (lite)

**1. What are we building?** <one line>

**2. What can go wrong?**

| Asset (worth protecting) | Entry point (how it could be reached) | What could go wrong | Likelihood | Impact |
|---|---|---|---|---|
| <e.g. API key> | <e.g. committed to git> | <e.g. someone uses it and runs up a bill> | Low / Med / High | Low / Med / High |

**3. What are we doing about it?** <for each Medium or High row: the
mitigation, and the story or NFR that implements it>

**4. Did it work?** <how it was checked (test, review, scan) and when>

## Personal data

<What personal data the project stores, where, why, and how it's deleted.
Or: "None.">

## GitHub setup (GitHub only)

Turning these on is the user's call. Record what's on:

- [ ] Dependabot alerts
- [ ] Dependabot security updates
- [ ] Secret scanning and push protection
- [ ] `main` protected (PR required, no force pushes)

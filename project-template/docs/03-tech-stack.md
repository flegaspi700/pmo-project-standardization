# Tech stack

Every dependency in the project should appear here with a reason. If an AI
agent wants to add one that isn't listed, it logs the decision in
`05-decisions-log.md` first.

This doc shows what was *chosen*. For significant choices (language,
framework, storage, anything hard to swap out), the options that were
compared and why the others lost are in the matching
`05-decisions-log.md` entry — link it in the Rationale column.

## Core

| Layer | Choice | Rationale |
|---|---|---|
| Language | <e.g. Python 3.12+ / TypeScript / C#> | <why> |
| <layer> | <library> | <why this, and when you'd switch to the alternative> |
| <layer> | <library> | <why> |
| Persistence | <none / flat files / SQLite / ...> | <why — see `05-decisions-log.md`> |

## Dev environment

| Tool | Purpose |
|---|---|
| <editor> | Primary editor |
| <formatter> | Formatting |
| <linter / type checker> | Linting and type checks |
| <test runner> | Tests |
| <coverage tool> | Coverage report (a hint, no target %) |
| <dependency audit tool, e.g. pip-audit / npm audit> | Known vulnerabilities in dependencies (`14-security.md`) |
| <env manager, e.g. venv / nvm> | Dependency isolation |

## Starting dependencies

```
<package>
<package>
```

## Deferred / not needed yet

- <Library or tool> — <the condition under which you'd revisit it>

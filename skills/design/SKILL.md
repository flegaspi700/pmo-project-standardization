---
name: design
description: Write and get approval for a feature's design (docs/design/F1.2.md) before its stories are built, in a project on the standard. Use when the user asks to design a feature, or when /story or /breakdown says a feature needs a design first. Planning only, no code.
argument-hint: "[feature ID, e.g. F1.2]"
disable-model-invocation: true
---

Design: $ARGUMENTS

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\design"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `requirements.md` (Designing a feature),
`decisions.md`, `testing.md` (all in `standard/`).

If no feature ID was given, list the current phase's features whose
**Design:** line isn't `Approved` or `not needed`, and ask which one.

1. Read `AGENTS.md`, the feature, its stories and its epic in
   `docs/requirements.md`, `docs/decisions.md`, `docs/architecture.md` if
   there is one, and the code the feature will touch. If
   `docs/design/<ID>.md` exists, start from it: an `Approved` design is
   only changed through its Changes list.
2. **Ask before writing.** List what's unclear (interfaces, data, failure
   cases, what the acceptance test should show) and ask, a few questions
   at a time. Don't guess the gaps.
3. Draft `docs/design/<ID>.md` in the format in `requirements.md`, status
   `Draft`: approach, components touched, interfaces and data, risks, test
   approach (the acceptance test from **Done when**, and which criteria
   are `[integration]` or `[e2e]`), decisions.
4. **Significant choices** (`decisions.md`): give 2-3 options, always
   including the simplest that could work, recommend one, and wait for the
   user. Log each in `docs/decisions.md` (as `/decide` does) and link it
   from the design.
5. If the design shows a story is missing, too big, or has a criterion
   that's wrong or mis-tagged, say so and suggest the change to
   `docs/requirements.md`. Don't change criteria without the user's yes.
6. Show the design and wait for the user's changes. **Only the user
   approves.** Then set the status to `Approved <today>` and the feature's
   **Design:** line to `docs/design/<ID>.md (Approved <today>)`.
7. **Ask before committing.** By hosting (`git.md`): on a
   `docs/<ID>-design` branch, `docs: design <ID> (<ID>)`; on `github`,
   ask before pushing and opening the PR. Merge only when the user says
   so.

Then suggest `/story <ID>` (or `/story phase`).

Don't write any code.

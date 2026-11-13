---
name: security-check
description: In a project on the standard, review recent changes for security problems (secrets, input handling, dependencies), run the dependency audit, and check the threat model. Reports findings only, no fixes.
argument-hint: "[scope: branch, phase, or files — default: this phase]"
disable-model-invocation: true
---

Security review of: $ARGUMENTS (default: everything changed in the current
phase).

**Preflight first.** Find the template folder in PowerShell:
`$s = Get-Item "$env:USERPROFILE\.claude\skills\security-check"; $d = if ($s.Target) { @($s.Target)[0] } else { $s.FullName }; Split-Path $d | Split-Path`
Then read `<template-dir>\skills\preflight.md` and follow it. Stop if it
says to. Rules used here: `standard/security.md`.

1. Read `AGENTS.md` and `docs/security.md` if there is one.
2. Review the changed code for:
   - secrets in code, config, logs, tests or test data
   - outside input that isn't validated where it enters
   - shell commands, queries, file paths or code built from input
   - errors that swallow problems or leak internals to users
   - personal data in logs, or stored without need
   - dependencies not verified and not logged in `docs/decisions.md`
3. Run the dependency audit command from `AGENTS.md` → Commands and show
   the output. If there's no audit command yet, say so.
4. **With `docs/security.md`:** compare the code with its threat model. New
   components, inputs or outside services that aren't in it? Propose rows.
   **Without it:** say whether the changes now need one (network access,
   secrets, personal data or outside input) and offer to add it.
5. Report findings by severity (High, Medium, Low): file and line, the risk
   in one sentence, the suggested fix. **Don't fix anything:** the user
   decides what to change.

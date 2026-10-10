---
name: security-check
description: Review recent changes for security problems (secrets, input handling, dependencies), run the dependency audit, and check the threat model. Reports findings only, no fixes.
argument-hint: "[scope: branch, phase, or files — default: this phase]"
disable-model-invocation: true
---

Security review of: $ARGUMENTS (default: everything changed in the current
phase).

1. Read `AGENTS.md` and `docs/14-security.md`. If `14` is `Not needed` in
   the Doc status table, still do step 2 against the rules in `AGENTS.md`
   → Security, skip the threat-model check, and say if the changes now
   justify turning `14` on.
2. Review the changed code for:
   - secrets in code, config, logs, tests, or test data
   - external input that isn't validated at the boundary
   - shell commands, queries, file paths, or code built from input
   - errors that swallow problems or leak internals to users
   - personal data in logs or stored without need
   - dependencies not verified and not logged in
     `docs/05-decisions-log.md`
3. Run the dependency audit command from `AGENTS.md` → Commands and show
   the output.
4. Compare the code with the threat model in `docs/14-security.md`: new
   components, inputs, or external services that aren't in it? Propose
   updated rows.
5. Report findings by severity (High / Medium / Low): file and line, the
   risk in one sentence, the suggested fix. **Don't fix anything** — the
   user decides what to change.

---
name: wrap-up
description: End-of-session handoff — write the session log entry (including time spent) and flag anything unfinished or uncommitted. Use when the user says they're stopping, done for today, or wrapping up.
---

Wrap up this session.

1. Check `git status` and the current branch. Note uncommitted changes,
   unmerged branches, and failing tests — and, only if `Hosting` in
   `AGENTS.md` is `github`, unpushed commits. Don't commit anything without
   asking.
2. Ask the user how much time the session took, if you can't tell.
3. Add an entry at the top of `docs/10-session-log.md` using its template:
   stories worked on, time spent, what changed (files and why), exactly
   where things stopped, the very next step (specific enough to start
   without thinking), and open questions.
4. Make sure story statuses in `docs/01-requirements.md` match reality.
5. Tell the user, briefly: what's uncommitted (or unpushed, on `github`),
   and the next step from the log.

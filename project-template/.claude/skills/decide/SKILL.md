---
name: decide
description: Compare 2-3 options for a significant design or technology choice, recommend one, and log the user's decision as an ADR.
argument-hint: "[the question to decide]"
disable-model-invocation: true
---

Decide: $ARGUMENTS

1. Read `AGENTS.md`, `docs/00-vision.md`, `docs/02-architecture.md`
   (Design options and trade-offs, Key decisions), and
   `docs/05-decisions-log.md` — if this was already decided, show that
   entry and stop unless the user wants to revisit it.
2. If the question isn't clear, ask what's being decided and why now.
3. Give **2-3 options, always including the simplest one that could
   work.** Compare them in a table: pros, cons, cost, effort, how easy to
   change later — judged against the goals and constraints in
   `docs/00-vision.md`.
4. Recommend one and state the trade-off the user would be accepting.
5. **Wait for the user to choose.** Don't write code or log anything first.
6. Then:
   - add an entry at the top of `docs/05-decisions-log.md` using its
     template (options table, decision, why, trade-offs accepted, revisit
     if); mark any entry it replaces `Superseded by`
   - add a row to Key decisions in `docs/02-architecture.md` and remove the
     question from Open design questions if it was there
   - update any diagram or section the decision changes

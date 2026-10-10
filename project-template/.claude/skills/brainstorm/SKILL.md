---
name: brainstorm
description: Explore a rough idea before the vision is written — questions, 3-4 distinct directions, the riskiest assumption — then record the chosen direction in docs/00-vision.md. Planning only, no code.
argument-hint: "[rough idea or problem]"
disable-model-invocation: true
---

Brainstorm: $ARGUMENTS
(If that's empty, work from `docs/00-vision.md`, or ask what the idea is.)

1. Read `AGENTS.md` and `docs/00-vision.md` (it may still be a stub), and
   `docs/05-decisions-log.md` so you don't re-open settled decisions.
2. **Ask before proposing.** A few questions at a time: who it's for, what
   problem it solves, why now, and the constraints (time, money, skills).
   Don't guess the gaps.
3. Offer **3-4 distinct directions** as a table: direction, pros, cons,
   rough effort. Always include a smaller or simpler one than the user
   first described.
4. Challenge the assumptions. Name the **riskiest one** and a cheap way to
   test it before building anything.
5. Recommend one direction and name the trade-off. **Wait for the user to
   choose.** Write nothing before that.
6. Then update only:
   - `docs/00-vision.md` — problem, goals, non-goals, constraints, success
     criteria for the chosen direction
   - `docs/05-decisions-log.md` — one entry with the options table, so the
     rejected directions aren't re-argued
7. Suggest `/breakdown` as the next step.

Don't write any code, and don't touch the other docs.

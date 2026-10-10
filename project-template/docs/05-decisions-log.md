# Decisions log

Running log of design and technology decisions, in ADR-style (Architecture
Decision Record). Add new entries at the top. Copy the template at the
bottom for new entries.

- Log open questions too, as `Proposed` entries with the decision left
  pending and a note on what result will settle it — that way they don't
  get decided silently.
- For significant choices (see `02-architecture.md` → Design options and
  trade-offs), fill in **Options considered** with every serious option,
  not just the winner. Knowing what was rejected and why stops the same
  debate from restarting later.
- Small choices can skip the options table — a one-line Decision and Why
  is enough.
- Never delete or rewrite an accepted entry. If a decision changes, add a
  new entry and mark the old one `Superseded by <new entry>`.

---

## YYYY-MM-DD — Language and stack

**Status:** Proposed

**Context:** The template doesn't assume a language. The stack is chosen
per project in Phase 0 (see `AGENTS.md` → Choosing the stack).

**Options considered:**

| Option | Pros | Cons | Cost |
|---|---|---|---|
| _<language + key libraries>_ | | | |
| _<alternative>_ | | | |

**Decision:** _Pending — fill in during Phase 0._

**Why:** _What the project needs (from `00-vision.md`) and why this option
fits best._

**Trade-offs accepted:** _What we give up by not choosing the
alternatives._

**Revisit if:** _The condition that would make this worth reconsidering._

---

## YYYY-MM-DD — Formatter, linter and test runner

**Status:** Proposed

**Context:** Tooling needs to be fixed early so AI-generated code stays
consistent between sessions. Follows from the language choice above.

**Decision:** _Pending — fill in during Phase 0._

**Why:** _Fill in once chosen._

---

## Template for new entries

```
## YYYY-MM-DD — <short decision title>

**Status:** Proposed | Accepted | Superseded by <link>

**Context:** What prompted this decision? What constraints or goals
(from 00-vision.md) apply?

**Options considered:**   (skip for small choices)

| Option | Pros | Cons | Cost |
|---|---|---|---|
| <simplest option that could work> | | | <$0 / $X per month / usage-based> |
| <option B> | | | |
| <option C, if any> | | | |

**Decision:** What was decided?

**Why:** Which criteria decided it — e.g. simplicity, effort, performance,
cost, security, ease of changing later.

**Trade-offs accepted:** What we give up with this choice.

**Revisit if:** The condition or measurement that would make this worth
reconsidering (e.g. "capture rate drops below 20 fps").
```

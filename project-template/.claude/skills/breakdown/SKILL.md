---
name: breakdown
description: Break the project idea (or one epic) into epics, features, and stories with acceptance criteria in docs/01-requirements.md. Planning only, no code.
argument-hint: "[epic ID or idea to break down]"
disable-model-invocation: true
---

Break down requirements for: $ARGUMENTS
(If that's empty, work from `docs/00-vision.md` for the whole project.)

1. Read `AGENTS.md`, `docs/00-vision.md`, `docs/01-requirements.md`, and the
   Status table in `docs/04-project-plan.md`.
2. **Ask before writing.** List what's ambiguous or missing — users, edge
   cases, what "done" looks like — and ask the user, a few questions at a
   time. Don't guess the gaps.
3. Propose epics and features in the format in `docs/01-requirements.md`:
   - every epic has **Serves:** pointing to a goal in `docs/00-vision.md`;
     flag any idea that serves no goal instead of adding it
   - every feature has a **Phase** and a **Done when** line
4. Write **stories with acceptance criteria only for the current and next
   phase**. Each story: one component, about a day of work at most,
   Given/When/Then criteria including empty and worst-case inputs. Later
   phases get epics and features only.
5. Show the breakdown and wait for the user's changes. Then write it into
   `docs/01-requirements.md` (sections + Summary table) and list the
   stories under the right phase in `docs/04-project-plan.md`.
6. Add any new terms to `docs/11-glossary.md`.

Don't write any code.

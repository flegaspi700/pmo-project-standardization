# Manual tests

Checks that automated tests can't judge well — how something looks, feels,
or plays, or whether it's actually usable. Write the steps once per feature,
then record a result each time you run them. Run them before marking a
feature done (`07-testing-checklist.md`) and again before closing a phase.

If a manual check finds a bug, log it in `01-requirements.md` → Bugs, and
add an automated test for it if one is possible.

---

## <Feature ID> — <Feature title>

**What to check:** <the things only a person can judge — e.g. "movement
feels responsive", "the chart is readable at a glance">

**Steps:**
1. <setup / starting state>
2. <action>
3. <what you should see>

**Results:**

| Date | Version / commit | Result | Notes |
|---|---|---|---|
| YYYY-MM-DD | <short commit hash> | ✅ Pass / ❌ Fail | <what you saw; bug ID if it failed> |

---

## Template

```
## <Feature ID> — <Feature title>

**What to check:** <...>

**Steps:**
1. <...>

**Results:**

| Date | Version / commit | Result | Notes |
|---|---|---|---|
```

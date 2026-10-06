# Plan doc anatomy

Default shape for the plan. If the repo already has plans, match their headings and naming
instead; this file is the fallback. Number the headings, keep prose tight, let tables carry
detail.

```
# <N> — <Feature name>

Status: **Drafted <YYYY-MM-DD>, <branch if any>, <what is left open>.**

## 1. Goal
## 2. Decisions                 # drop if nothing is settled yet
## 3. Current state (verified)
## 4. How the market does it    # drop if research was not applicable
## 5. Principles
## 6. Workstreams
### WS1 — <name>
## 7. Sequencing                # only when the order is not obvious
## 8. Risks and open questions
## 9. Out of scope
```

## Sections

- **Status**: one line. Plan or record of what got built, and what is open. Once built, it
  gains "each section notes where the build departs from the plan".
- **Goal**: the outcome, who it is for, the constraints, and a success test a stranger could
  apply ("we can remove `<legacy-setting>` without regressing any user who relies on it today").
- **Decisions**: calls already made, each with its reason, who settled it and when. These stop
  workstreams re-litigating. If none are settled, name the decision the plan waits on and its
  owner.
- **Current state (verified)**: the file:line table, the section that makes the plan
  trustworthy. Either `| Layer | Where | What it does |` for an existing staged pipeline, or
  `| Fact | Where |` for isolated truths. A wrong row is the most expensive error in the doc.
- **How the market does it**:
  ```
  | Competitor | Ships it? | Tier / price | Source |
  |---|---|---|---|
  | <name> | yes / no / partial | <tier> | <url>, <date> |
  ```
  Then 2–4 lines: table stakes, differentiator, or skip, and which workstream that changed.
  Mark vendor marketing as unverified. "Nobody ships it" carries the query that supports it.
- **Principles**: 3–6 numbered rules that outlive the workstreams, the reviewer's tool ("does
  this PR break principle 3?"). Shapes that work: *<source> is authoritative*, *no new user
  configuration*, *fail open, visibly*, *<client> reports facts, <server> decides*.
- **Workstreams**: one per independently shippable slice, ordered by value; if A can't ship
  without B, they are one workstream. Each opens with why it is in that position, then as
  needed: **Changes** (file:line anchors per layer: backend, UI, client, schema), **Gating**
  (tier or flag), **Tests** (a list, not "add tests"), **Off-nominal** (stale, missing or partial
  data; fails open or closed, loud or silent).
- **Sequencing**: only when the obvious order is wrong or one slice must land first. Name the
  dependency.
- **Risks and open questions**: what could go wrong and what the plan doesn't resolve, each with
  who can resolve it.
- **Out of scope**: adjacent things a reader would otherwise assume are included.

Add a "Load at <realistic size>" section after Current state for performance work, and an
**Honesty rails** section when the feature shows users a number or a claim: n-counts, ranges
not point estimates, exact copy the UI must never show.

## House style

- Tables over prose for more than two parallel items.
- Every code reference is `path:line` in backticks (`service.py:272`), so it can be grepped
  and checked. Files the plan creates are cited without a line number.
- Reuse beats invention: "80% of this is `<existing_function>` at `<file>:<line>`" is the most
  useful sentence a plan can contain.
- No imagined implementations. A signature or a data shape is fine; a feature written as code
  is a diff pretending to be a plan.
- Departures are explicit: "Not as planned: X, because Y."
- Absolute dates, never "next week".

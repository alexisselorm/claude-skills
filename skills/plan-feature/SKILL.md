---
name: plan-feature
description: Turn a feature idea into a grounded implementation plan for any repo — explore the codebase for the real extension points (file:line) and research how competitors and the industry solve the same problem (live web, cited) in parallel, then write one plan doc whose every claim is verified in the repo or attributed to a source. Use when the user wants to plan a feature, scope new work, asks "how would we build X" or how competitors do something, or wants a research-backed plan rather than immediate code.
---

# Planning a feature

Produce a plan a reader can turn into tickets without re-discovery. Every code claim is a
`path:line` you opened; every market claim has a URL and date. Never invent either.

Writes exactly one file, the plan doc. Never edits code, stages or commits. Paths below are
relative to this skill's directory. If this skill is already loaded this session, don't
invoke it again.

## 1. Frame

You need three things. Quote what the user already gave; ask only for what's missing, at most
three questions in one exchange:

- **Feature and outcome**, one sentence.
- **Who it's for**: user type, tier or workflow. A plan for "users" is a plan for no one.
- **Constraints**: what must stay true (no new config, works on the free tier, no client
  release).

Also decide whether market research applies. It doesn't for internal refactors,
infrastructure or dev tooling with no outside analogue. Skip it there and say why in the
plan; the user can ask for it. If the user only wants to know how competitors do something,
run step 2's research alone and answer in chat. No plan.

## 2. Explore and research in parallel

In one message, spawn:

- **One `Explore` agent per seam** (one is enough for a small repo). A seam is a place the
  feature plugs in: the routes or services it extends, the closest analogous feature, the
  event or dispatch path, the UI page, the schema or migration tail. Prompt:
  ```
  Feature: <one sentence>. Find where it would plug in around <seam> in <repo>. Follow one
  call path end to end. Return only:
  FACTS: | Fact | path:line | rows, each a line you opened
  REUSE: existing code that already does part of this, with path:line
  CONSTRAINTS: what the code imposes (missing index, unbackfilled column, field not yet
  sent, tier without a flag), with path:line
  ABSENT: what doesn't exist yet that the feature needs
  Read-only. No suggestions or designs.
  ```
- **One `general-purpose` agent for market research**, or two for a crowded market (named
  competitors, and the industry method). Prompt: the feature, who it's for, any competitors
  the user named, and "Research with live web search and return in the format of
  <skill-dir>/research-notes.md."

If the Agent tool isn't available, do both yourself, exploration first.

## 3. Verify

- Open every `path:line` you'll use and confirm it says what the agent claims. Drop or fix
  the rest. A wrong anchor poisons the plan.
- For each market finding a decision rests on, open its source. Drop claims without one.
- If the feature already exists, or the code makes it impossible as stated, say so and stop.
  Don't plan something the repo already does.

## 4. Design and write

Follow the repo's existing plans if it has any, else `anatomy.md`. Design rules:

- Reuse the existing pattern; name it with its anchor and describe only the delta.
- Each workstream ships alone and states its off-nominal path.
- Market findings change workstreams. Where research changed one, the workstream says so. If
  the feature turns out to be table stakes, say that rather than padding the case for it.
- No implementation code. Anchors, signatures, data shapes.

Write the doc where the repo keeps plans (`docs/`, `docs/plans/`, an ADR directory), matching
its naming and numbering. No obvious home: ask. Then run
`scripts/check-anchors.sh <plan> <repo>`. It must print nothing; fix any anchor it flags.

## 5. Close

Reply with the plan path, the goal in one line, the market finding in one line, and the open
questions. Nothing else.

## Never

- Invent a `path:line`, a competitor, a price or a metric, or fill research from memory.
- Present a vendor's claim as fact.
- Leave the plan unanchored ("add caching somewhere").

---
name: code-review
description: Review code changes by sending parallel reviewer personas (correctness, security, tests, code quality, plus performance when relevant) over the diff, then merging their findings into one severity-grouped report, without editing anything. Use whenever the user asks to review code, a diff, changes, a commit or a branch, to check work before committing or pushing, or asks "does this look right" about a change. Also use as a self-review when a change is done and about to be committed.
---

# Reviewing code changes

Findings only. This skill never edits, fixes, stages or commits. If the user wants fixes,
they'll ask after reading the report. Paths below are relative to this skill's directory.

If this skill is already loaded this session, don't invoke it again.

## 1. Collect

Pick the target from what the user says, else default to uncommitted work:

- Uncommitted work (default): `scripts/collect.sh <repo>`, which covers staged, unstaged and
  untracked files.
- Committed range (pre-push or PR): `scripts/collect.sh <repo> <base>`, base defaulting to
  `origin/HEAD`, or what they name (`main`, `HEAD~3`).
- One commit: `scripts/collect.sh <repo> <sha>~1`.

The last line it prints is the diff file, or `empty: nothing to review`; then say so and stop.
Note the intent: the commit message, the user's words, the linked issue.

## 2. Spawn the personas

In one message, spawn one `general-purpose` Agent per lens so they run in parallel. Always
send these four:

- `personas/correctness.md`
- `personas/security.md`
- `personas/tests.md`
- `personas/quality.md`

Add `personas/performance.md` when the diff touches queries, loops over data, hot request
paths or caching. Add any lens the user asks for, written as a one-paragraph brief in the
prompt.

Each prompt, filled in, nothing more:

```
Review a code change through one lens. Read <skill-dir>/reviewer.md (rules and output
format), then <skill-dir>/personas/<lens>.md (your lens).
Repo: <repo>   Branch: <branch>
Diff: <diff file>
Intent: <one or two sentences>
Repo invariants: <skill-dir>/repo-invariants.md, or the repo's own doc (correctness only)
Thorough: <yes if the user asked for thorough: trace every caller and the full call graph>
```

If the Agent tool isn't available (for example, you are already a subagent), run each lens
yourself in turn with the same rules.

## 3. Merge

- Dedupe: same location and same problem is one finding, kept at its highest severity, tagged
  with every lens that raised it. Agreement across lenses raises confidence.
- Before reporting any `blocker`, read the cited lines yourself. If the code already handles
  it, drop it; if you can't confirm it, downgrade it to `possible`.
- Drop findings outside the diff unless the change makes them worse.

## 4. Report

Group by severity: **Blocker**, **Should fix**, **Nit**. Each finding: `file:line` · what's
wrong · why it matters · suggested fix · lenses · `possible` if unconfirmed.

Then a short summary:
- what the change does
- one line per lens: its `CHECKED` line, or "nothing found"
- counts by severity

Rules:
- No praise. Lead with findings.
- No location, no finding.
- Separate fact from suspicion. For a `possible`, name the check that would confirm it, and
  run it only if the user asks.
- Delete the diff file when done.

## Never

Edit, fix, stage, commit, push or run destructive commands, yourself or through a persona.
Review vendored code, build output or files the change didn't touch unless asked.

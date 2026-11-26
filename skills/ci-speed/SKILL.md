---
name: ci-speed
description: Make any repo's CI/CD faster, measured as wall time from a push or PR to a result and from a merge to a finished deploy. Detects the project's own stack, builds a baseline from real GitHub Actions runs (per job and per step, medians and worst cases, critical path, queue and cache use), finds where the time goes with evidence, researches techniques for that stack with cited sources, writes a ranked plan, and can then implement it one workstream at a time and re-measure. Use when CI is slow or painful, when asked to speed up pipelines, builds, tests or deploys, or to find out where CI time goes.
---

# Making CI/CD faster

If this skill is already loaded this session, don't invoke it again. Paths below are relative
to this skill's directory.

Every claim is either a measured number with the run id it came from, a `path:line` you
opened, or a cited source. Never fill a timing, price or limit from memory. The stack comes
from the repo you are in: read it, never assume one.

## 1. Frame

You need three things. Take what the user gave; ask only for what's missing, at most three
questions in one exchange:

- **Which clocks matter:** PR to result, push to main to result, merge to finished deploy.
- **What must stay true:** for example the artifact that ships is the one that was tested,
  no suite is skipped for a change it covers, deploys are never cancelled.
- **Budget:** the GitHub plan (Free can't use larger runners), and whether paid or
  third-party runners are allowed.

Default, unless the user says otherwise: research and plan only. No pushes, merges, repo
setting changes or code changes. If another session may switch branches in this checkout,
do any trial in a separate `git worktree`.

## 2. Detect the stack

Read every workflow under `.github/workflows/` end to end: triggers, path filters,
concurrency, `needs:` graph, reusable workflows, and the actions and versions they call.
Then note the signals that pick sections of `techniques.md`:

- Lockfiles and toolchains (`package-lock.json`, `uv.lock`, `go.mod`, `gradle`, `Cargo.lock`, …)
- `Dockerfile`s, bake or compose files, `.dockerignore`
- Test runners and e2e frameworks, and their CI config (workers, retries, sharding)
- How deploys happen: the action or tool, the target, whether migrations run
- Branch protection and required checks (`gh api repos/{owner}/{repo}/branches/{branch}/protection`)

## 3. Measure the baseline

1. Run `scripts/ci-timings.sh <repo-dir> [runs] [workflow]`. It prints medians and worst
   cases for runs, jobs and steps, and the longest queue wait. Successful first attempts only.
2. Split the runs into comparable eras: a workflow change resets the baseline. Say what n
   each number has. Below n=3, call it indicative.
3. Find the **critical path**: the chain of `needs:` whose jobs end last. Parallel jobs that
   always finish earlier don't count.
4. Open the logs of the slowest steps (`gh run view <id> --log`) for sub-step timings: image
   pulls, cache imports, exports, health waits, test time, migrations.
5. Check the cache: `gh api repos/{owner}/{repo}/actions/cache/usage` and `gh cache list`
   (quota, entries per ref, which refs write it).
6. If containers deploy somewhere, find that host's container engine version. It decides
   which health-check features work there. Ask before connecting to a server.

## 4. Find where the time goes

A table of segments on the critical path, in seconds, each with its run id or log line.
Then a table of repeated work: what runs twice, where, and what it costs. Look up the
detected stack's sections in `techniques.md` to know what to check. The fix comes later; this
step is evidence only.

## 5. Research

Search the live web for the techniques that fit the detected stack and the measured hot
spots, and open each source a decision rests on. Record the URL and access date. Mark
vendor speed claims as unverified. `techniques.md` is a starting list, not a substitute.

## 6. Plan

Where the repo keeps plans (`docs/`, `docs/plans/`, ADRs), write one plan doc in its style;
otherwise reply in chat. It holds:

- Goal and success test: target medians over the next N green runs, per clock.
- Current state (verified), baseline tables, critical path, repeated work.
- Research table with sources.
- Design: the mechanisms, and the approaches rejected, with reasons.
- Ranked workstreams: for each, seconds saved (measured, or marked *estimate*), which clocks
  it helps (**P** PR, **M** main, **D** deploy), risk, effort, any guarantee it weakens (mark
  ⚠), dependencies and conflicts. Ones that need proof go in as **spikes** with an
  adoption bar ("adopt if 3 runs save ≥ 20s net").
- Sequencing, risks, open questions, out of scope.

Then reply with the plan path, the top three workstreams and the open questions.

## 7. Implement, when asked

- Follow the repo's commit conventions (use the `commit-unit` skill if it is installed).
  One workstream is one reviewable unit.
- Before building a workstream whose premise is measurable locally, measure it. For example
  rebuild an image with a one-line source change and compare layer ids, or run the suite with
  the new setting several times. If the premise is false, drop the workstream and record why.
- Re-read each change for its off-nominal path: a backgrounded step must fail the job; a
  skipped step must run again after a failure; a timeout must not pass silently.
- Verify what you can locally: lint, YAML parse, tests against the real artifact.
- Spikes go on their own branches, stacked on the main work, as draft PRs.
- Pushing, merging, releasing a dependency (moving a shared tag) and anything that deploys
  happen only when the user asks. Even then, state what will deploy before you do it.

## 8. Re-measure

After each merged workstream, run `scripts/ci-timings.sh` again and compare comparable runs:
the same kind of change, a warm cache, n ≥ 3. A run that changed a Dockerfile or the
lockfile rebuilds layers and doesn't show the steady state. Put the numbers, with run ids,
back into the plan.

## Never

- Invent a timing, limit, price or `path:line`, or present a vendor's benchmark as fact.
- Skip a suite, cancel a deploying run, or stop testing the shipped artifact to save time,
  unless the user explicitly accepts that trade.
- Move secrets (deploy keys, registry write tokens) to third-party or self-hosted runners
  without the user deciding it.
- Claim a saving no measured run shows.

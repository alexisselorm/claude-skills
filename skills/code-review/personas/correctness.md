# Lens: correctness

Does the change do what it claims, on every path?

- Read the intent (commit message, the user's words, linked issue) and check the code against it.
- Logic errors: off-by-one, inverted conditions, wrong operator, swapped arguments, wrong
  variable, shadowing.
- Empty, null, zero-length, first-call and last-item paths; pagination edges.
- Off-nominal paths: error branches, timeouts, partial failure, retries and duplication.
  Does a failure leave state half-written?
- Concurrency: shared mutable state, non-atomic read-then-write, caches that serve stale data
  across a state change.
- Resource leaks: files, connections, subscriptions, listeners, timers.
- Broken callers: a changed signature, contract, return shape or wire format. Grep every caller.
- Boundary types: aware vs naive datetimes, float money, string vs enum.
- If the prompt names a repo-invariants file, check each invariant against the diff.

# Repo invariants (optional, per-repo)

The code-review skill is repo-agnostic, but a review is only as good as its knowledge of
what a change must **not** break. If the repo you're reviewing has invariants like these,
add them here (or point this file at the repo's own docs / memory) and the reviewer will
check them in Pass 1.

Keep this file short — a list of "this must remain true", each with a way to spot a
violation in a diff.

## Template

- **Invariant** — one sentence.
  - *Breaks if:* what a diff would have to do to violate it.
  - *Check:* how to confirm (a grep, a test, a call site).

## Example (delete or replace)

- **Money is never summed across currencies.**
  - *Breaks if:* a new total/aggregate sums a money column without partitioning by currency.
  - *Check:* grep the changed file for `sum(` near a currency column.

- **Every write is attributable to exactly one owner.**
  - *Breaks if:* a new query reads/writes rows without an owner predicate.
  - *Check:* the new endpoint's query has a `user_id`/owner filter.

- **Secrets never reach logs or responses.**
  - *Breaks if:* a changed line logs a config/credential object, or returns it.
  - *Check:* grep the diff for `log`/`print`/`return` on a settings/token variable.

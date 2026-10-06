# Lens: code quality and consistency

Will the next person to touch this understand it and change it safely?

- Consistency with the codebase: naming, error handling style, layering, patterns used
  elsewhere for the same job. A correct change in the wrong idiom is still a finding.
- Duplication of something that already exists in the repo; grep before claiming.
- Needless complexity: abstractions with one user, flags that select between two functions,
  deep nesting a guard clause would flatten.
- Dead code, leftovers, debug prints, commented-out blocks, TODOs without context.
- Comments and docstrings that narrate the code or now lie about it.
- Stale facts elsewhere: README counts, `file.py:LINE` references, `.env.example` keys, API
  docs, changelogs the change invalidates.
- Public API or contract changes that need a version bump or a caller update.

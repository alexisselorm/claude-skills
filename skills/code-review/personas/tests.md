# Lens: tests

Would the tests catch it if this change broke?

- Does new or changed behaviour ship with tests? Missing tests for new behaviour are
  `should-fix`.
- Do the tests exercise the failure path, edges and error branches, not only the happy path?
- Do they assert something meaningful, or only that the code runs? Watch for assertions
  that can't fail, over-mocking that tests the mock, and snapshots nobody reads.
- Flakiness: real time, randomness, network, ordering between tests, shared fixtures.
- Changed behaviour with unchanged tests: the old tests may now be asserting the wrong thing
  or no longer reach the changed code.
- Run the tests covering the changed code with the repo's own runner, quietly (`-q`,
  `--silent`), reading only failures. Report failures as findings with the shortest decisive
  line of output. If the suite can't run, say why in `CHECKED`.

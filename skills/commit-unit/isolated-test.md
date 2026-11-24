# Testing in a dirty tree

Use when someone else's half-finished work stops the suite from collecting. A detached
worktree at HEAD holds exactly your committed units:

```bash
WT=$(mktemp -d)/wt
git worktree add --detach --quiet "$WT" HEAD
# copy in gitignored files the suite needs to boot, e.g. cp -p .env "$WT/.env"
( cd "$WT" && <the repo's test command> )
git worktree remove --force "$WT"; git worktree prune
```

Reuse the built environment (`.venv/bin/python -m pytest`, existing `node_modules`) rather
than provisioning a second one.

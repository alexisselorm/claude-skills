# Testing a unit in a dirty tree

Use when someone else's half-finished work stops the suite from collecting. A detached
worktree at HEAD plus your files is exactly what the commit will contain:

```bash
WT=$(mktemp -d)/wt
git worktree add --detach --quiet "$WT" HEAD
# copy in gitignored files the suite needs to boot, e.g. cp -p .env "$WT/.env"
for f in <your files>; do cp -p "$f" "$WT/$f"; done
( cd "$WT" && <the repo's test command> )
git worktree remove --force "$WT"; git worktree prune
```

Reuse the built environment (`.venv/bin/python -m pytest`, existing `node_modules`) rather
than provisioning a second one.

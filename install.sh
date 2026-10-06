#!/usr/bin/env bash
# Symlink each skill into ~/.claude/skills so edits here are live everywhere.
# An existing non-symlink copy is moved aside, never deleted.
set -euo pipefail

src="$(cd "$(dirname "$0")/skills" && pwd)"
dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mkdir -p "$dest"

for skill in "$src"/*/; do
  name=$(basename "$skill")
  target="$dest/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.bak-$(date +%Y%m%d%H%M%S)"
    echo "moved existing $name aside"
  fi
  ln -sfn "${skill%/}" "$target"
  echo "linked $name"
done

#!/usr/bin/env bash
# Collect the review target into one file plus a stat line, without touching the repo.
# Usage: collect.sh [repo] [base]
#   no base  -> working tree (staged + unstaged + untracked) vs HEAD
#   base     -> <base>...HEAD committed range
# Prints a summary; the last line is the diff file path.
set -euo pipefail

repo="${1:-.}"
base="${2:-}"
out="$(mktemp "${TMPDIR:-/tmp}/code-review-XXXXXX.diff")"

cd "$repo"

echo "repo:   $(git rev-parse --show-toplevel)"
echo "branch: $(git rev-parse --abbrev-ref HEAD)"

untracked=()
if [ -n "$base" ]; then
  range=("$base...HEAD")
else
  range=(HEAD)
  mapfile -t untracked < <(git ls-files --others --exclude-standard)
fi

{
  git diff "${range[@]}"
  # New files are invisible to `git diff HEAD`; show them as additions so reviewers see them.
  for f in "${untracked[@]}"; do
    git diff --no-index -- /dev/null "$f" || true
  done
} > "$out"

if [ ! -s "$out" ]; then
  rm -f "$out"
  echo "empty: nothing to review"
  exit 0
fi

echo "files changed:"
git diff --stat "${range[@]}"
for f in "${untracked[@]}"; do echo " $f (untracked)"; done

echo "lines:  $(wc -l < "$out")"
echo "$out"

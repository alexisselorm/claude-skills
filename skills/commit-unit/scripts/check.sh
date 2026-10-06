#!/usr/bin/env bash
# Usage: check.sh [repo] [commit-count]
# Silent and exit 0 when clean; prints offending lines and exits 1 otherwise.
set -uo pipefail

REPO=${1:-.}
COUNT=${2:-10}
ATTR='^[[:space:]]*(co-authored-by|signed-off-by|assisted-by|generated-by)[[:space:]]*:|generated with \[|🤖|(generated|written|authored)[[:space:]]+(by|with)[[:space:]]+(claude|an? (ai|llm|assistant|agent))'
failed=0

report() {
  [[ -z $2 ]] && return
  printf '%s\n%s\n' "$1" "$2"
  failed=1
}

# This script's own pattern would match itself wherever it is committed.
staged=$(git -C "$REPO" diff --cached -- . ':(exclude,glob)**/commit-unit/scripts/check.sh')
report "home path in staged diff:" "$(grep -nE '^\+.*/(home|Users)/[A-Za-z0-9_.-]+/' <<<"$staged")"
report "attribution in staged diff:" "$(grep -E '^\+' <<<"$staged" | cut -c2- | grep -inE "$ATTR")"
report "attribution in last $COUNT messages:" "$(git -C "$REPO" log -"$COUNT" --format='%h %B' 2>/dev/null | grep -inE "$ATTR")"

exit $failed

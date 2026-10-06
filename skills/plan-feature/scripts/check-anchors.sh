#!/usr/bin/env bash
# Usage: check-anchors.sh <plan.md> [repo]
# Silent and exit 0 when every `path:line` anchor resolves; prints the bad ones and exits 1.
set -uo pipefail

plan=$1
repo=${2:-.}
failed=0
tracked=$(git -C "$repo" ls-files)

while IFS=: read -r path line; do
  line=${line%%-*}
  # Plans often cite `service.py:272` without its directory; accept a unique suffix match.
  matches=$(grep -E "(^|/)${path//./\\.}$" <<<"$tracked")
  count=$(grep -c . <<<"$matches")
  if (( count == 0 )); then
    echo "missing file: $path:$line"; failed=1
  elif (( count > 1 )); then
    echo "ambiguous ($count files): $path:$line"; failed=1
  elif (( line > $(wc -l < "$repo/$matches") )); then
    echo "past end of file: $path:$line"; failed=1
  fi
done < <(grep -oE '`[A-Za-z0-9_./-]+\.[A-Za-z0-9]+:[0-9]+(-[0-9]+)?`' "$plan" | tr -d '`' | sort -u)

exit $failed

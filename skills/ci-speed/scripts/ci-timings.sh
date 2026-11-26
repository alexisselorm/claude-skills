#!/usr/bin/env bash
# CI timings from real GitHub Actions runs: per workflow and event, the wall time of
# successful first attempts (median, worst, best, n); per job and per step, median and worst;
# and the longest queue wait (job created -> started).
#   ci-timings.sh [repo-dir] [runs-per-workflow=30] [workflow-file-or-name]
# Needs gh (authenticated) and jq. Read-only.
set -euo pipefail
dir=${1:-.}
limit=${2:-30}
only=${3:-}
cd "$dir"
repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

args=(-L "$limit" --status success --json "databaseId,workflowName,event,attempt,createdAt,updatedAt,headBranch")
[[ -n $only ]] && args+=(-w "$only")
gh run list "${args[@]}" -R "$repo" >"$tmp/runs.json"
jq -r '.[] | select(.attempt == 1) | .databaseId' "$tmp/runs.json" >"$tmp/ids"
[[ -s $tmp/ids ]] || { echo "no successful first-attempt runs found in $repo" >&2; exit 1; }

# Job data for each run, one JSON object per line.
while read -r id; do
  gh api "repos/$repo/actions/runs/$id/jobs?per_page=100" --jq '.jobs[] | {run: '"$id"', name, created_at, started_at, completed_at, conclusion, steps: [.steps[] | {name, started_at, completed_at}]}' 2>/dev/null || true
done <"$tmp/ids" >"$tmp/jobs.jsonl"

stats='def secs(a; b): ((b | fromdateiso8601) - (a | fromdateiso8601));
  def med: sort | if length == 0 then null else .[(length - 1) / 2 | floor] end;
  def row(k): {key: k, n: length, median: (map(.s) | med), worst: (map(.s) | max), best: (map(.s) | min)};'

echo "# $repo: successful first attempts, last $limit runs"
echo
echo "## Runs (created -> last update, seconds)"
jq -r "$stats"' [.[] | select(.attempt == 1) | {k: "\(.workflowName) / \(.event)", s: secs(.createdAt; .updatedAt)}]
  | group_by(.k) | map(row(.[0].k)) | sort_by(-.median)[]
  | "\(.key)\tn=\(.n)\tmedian=\(.median)\tworst=\(.worst)\tbest=\(.best)"' "$tmp/runs.json" | column -t -s $'\t'

echo
echo "## Jobs (seconds; skipped jobs left out)"
jq -rs "$stats"' [.[] | select(.conclusion == "success" and .started_at and .completed_at) | {k: .name, s: secs(.started_at; .completed_at)}]
  | group_by(.k) | map(row(.[0].k)) | sort_by(-.median)[]
  | "\(.key)\tn=\(.n)\tmedian=\(.median)\tworst=\(.worst)"' "$tmp/jobs.jsonl" | column -t -s $'\t'

echo
echo "## Slowest steps (median >= 5s)"
jq -rs "$stats"' [.[] | select(.conclusion == "success") | .name as $j | .steps[] | select(.started_at and .completed_at) | {k: "\($j) > \(.name)", s: secs(.started_at; .completed_at)}]
  | group_by(.k) | map(row(.[0].k)) | map(select(.median >= 5)) | sort_by(-.median)[:25][]
  | "\(.key[0:90])\tmedian=\(.median)\tworst=\(.worst)"' "$tmp/jobs.jsonl" | column -t -s $'\t'

echo
echo "## Queue (job created -> started)"
jq -rs "$stats"' [.[] | select(.started_at and .created_at) | secs(.created_at; .started_at)] | "max=\(max)s median=\(med)s over \(length) jobs"' "$tmp/jobs.jsonl"

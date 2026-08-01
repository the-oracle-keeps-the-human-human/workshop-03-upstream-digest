#!/usr/bin/env bash
# upstream-trail — digest a repo's activity into a day-by-day trail log:
# forward steps (feat/fix/etc) vs backtracks (reverts), plus a silence check.
#
# Usage: ./digest.sh <owner/repo> [since] [until]
#   since/until: YYYY-MM-DD (default: since=2026-05-25, until=today)
set -euo pipefail

REPO="${1:?usage: digest.sh <owner/repo> [since] [until]}"
SINCE="${2:-2026-05-25}"
UNTIL="${3:-$(date +%Y-%m-%d)}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "🧭 upstream-trail: $REPO ($SINCE .. $UNTIL)" >&2

# 1) Commits — one page fetch, paginated, raw jq lines (day | sha | subject)
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z&until=${UNTIL}T23:59:59Z&per_page=100" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.sha[0:7]) + "\t" + (.commit.message | split("\n")[0])' \
  > "$TMP/commits.tsv" 2>/dev/null || true

# 2) PRs opened/merged per day, issues closed per day — via Search API (cheap, no per-item calls)
gh api "search/issues?q=repo:${REPO}+is:pr+created:${SINCE}..${UNTIL}&per_page=100" --paginate \
  --jq '.items[] | .created_at[0:10]' > "$TMP/pr_opened.txt" 2>/dev/null || true
gh api "search/issues?q=repo:${REPO}+is:pr+is:merged+merged:${SINCE}..${UNTIL}&per_page=100" --paginate \
  --jq '.items[] | .pull_request.merged_at[0:10] // .closed_at[0:10]' > "$TMP/pr_merged.txt" 2>/dev/null || true
gh api "search/issues?q=repo:${REPO}+is:issue+is:closed+closed:${SINCE}..${UNTIL}&per_page=100" --paginate \
  --jq '.items[] | .closed_at[0:10]' > "$TMP/issues_closed.txt" 2>/dev/null || true

TOTAL_COMMITS=$(wc -l < "$TMP/commits.tsv" | tr -d ' ')
if [ "$TOTAL_COMMITS" = "0" ]; then
  echo "no commits in window" >&2
  exit 1
fi

# 3) Classify each commit + flag reverts (git's own "Revert \"...\"" convention)
awk -F'\t' '
{
  day=$1; msg=$3
  type="other"
  if (msg ~ /^[Rr]evert/) type="revert"
  else if (msg ~ /^feat(\(|:)/ ) type="feat"
  else if (msg ~ /^fix(\(|:)/ ) type="fix"
  else if (msg ~ /^docs(\(|:)/ ) type="docs"
  else if (msg ~ /^refactor(\(|:)/ ) type="refactor"
  else if (msg ~ /^chore(\(|:)/ ) type="chore"
  else if (msg ~ /^(perf|test|build|ci)(\(|:)/ ) type="chore"
  else if (msg ~ /^(bump|release|version)/ || msg ~ /^v[0-9]+\.[0-9]+\.[0-9]+/) type="bump"
  else if (tolower(msg) ~ /fix/) type="fix"
  else if (tolower(msg) ~ /feat|add /) type="feat"

  print day "\t" type
  if (type == "revert") print day "\tREVERT_MSG\t" msg > "/dev/stderr"
}' "$TMP/commits.tsv" > "$TMP/classified.tsv" 2> "$TMP/reverts_raw.txt"

grep -a "REVERT_MSG" "$TMP/reverts_raw.txt" | sed 's/\tREVERT_MSG\t/\t/' > "$TMP/reverts.tsv" || true

# 4) Group everything by day into one unified table (clamp to requested window —
#    the commits API can surface an out-of-range parent commit date via history quirks)
DAYS=$(cut -f1 "$TMP/classified.tsv" | sort -u | awk -v s="$SINCE" -v u="$UNTIL" '$0>=s && $0<=u')

{
  echo "day|commits|feat|fix|refactor|docs|chore|bump|revert|pr_opened|pr_merged|issues_closed"
  for d in $DAYS; do
    c=$(awk -F'\t' -v d="$d" '$1==d' "$TMP/classified.tsv" | wc -l | tr -d ' ')
    feat=$(awk -F'\t' -v d="$d" '$1==d && $2=="feat"' "$TMP/classified.tsv" | wc -l | tr -d ' ')
    fix=$(awk -F'\t' -v d="$d" '$1==d && $2=="fix"' "$TMP/classified.tsv" | wc -l | tr -d ' ')
    refactor=$(awk -F'\t' -v d="$d" '$1==d && $2=="refactor"' "$TMP/classified.tsv" | wc -l | tr -d ' ')
    docs=$(awk -F'\t' -v d="$d" '$1==d && $2=="docs"' "$TMP/classified.tsv" | wc -l | tr -d ' ')
    chore=$(awk -F'\t' -v d="$d" '$1==d && $2=="chore"' "$TMP/classified.tsv" | wc -l | tr -d ' ')
    bump=$(awk -F'\t' -v d="$d" '$1==d && $2=="bump"' "$TMP/classified.tsv" | wc -l | tr -d ' ')
    revert=$(awk -F'\t' -v d="$d" '$1==d && $2=="revert"' "$TMP/classified.tsv" | wc -l | tr -d ' ')
    prop=$(grep -c "^$d" "$TMP/pr_opened.txt" 2>/dev/null || true); prop=${prop:-0}
    prm=$(grep -c "^$d" "$TMP/pr_merged.txt" 2>/dev/null || true); prm=${prm:-0}
    isc=$(grep -c "^$d" "$TMP/issues_closed.txt" 2>/dev/null || true); isc=${isc:-0}
    echo "$d|$c|$feat|$fix|$refactor|$docs|$chore|$bump|$revert|$prop|$prm|$isc"
  done
} > "$TMP/timeline.psv"

echo ""
echo "## Timeline ($REPO, $SINCE .. $UNTIL)"
echo ""
column -t -s '|' "$TMP/timeline.psv"

# sums from the clamped timeline (not the raw unclamped commit list)
WINDOW_COMMITS=$(awk -F'|' 'NR>1{s+=$2} END{print s+0}' "$TMP/timeline.psv")
TOTAL_REVERTS=$(awk -F'|' 'NR>1{s+=$9} END{print s+0}' "$TMP/timeline.psv")
LAST_DAY=$(echo "$DAYS" | tail -1)
GAP_DAYS=$(( ($(date -j -f "%Y-%m-%d" "$UNTIL" +%s) - $(date -j -f "%Y-%m-%d" "$LAST_DAY" +%s)) / 86400 ))

echo ""
echo "## Highlights"
echo ""
echo "- total commits in window: $WINDOW_COMMITS across $(echo "$DAYS" | wc -l | tr -d ' ') active day(s)"
echo "- backtracks (revert commits): $TOTAL_REVERTS"
if [ "$TOTAL_REVERTS" -gt 0 ]; then
  echo "  what got reverted:"
  sed 's/^/    - /' "$TMP/reverts.tsv" | head -10
fi
BUSIEST_DAY=$(sort -t'|' -k2 -n -r "$TMP/timeline.psv" | sed -n '2p' | cut -d'|' -f1)
BUSIEST_N=$(sort -t'|' -k2 -n -r "$TMP/timeline.psv" | sed -n '2p' | cut -d'|' -f2)
echo "- busiest day: $BUSIEST_DAY ($BUSIEST_N commits)"
echo "- last commit in window: $LAST_DAY — window ends $UNTIL ($GAP_DAYS day(s) of silence since)"

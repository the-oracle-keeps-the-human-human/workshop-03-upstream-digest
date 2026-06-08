#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-$(date -d '14 days ago' +%Y-%m-%d)}"
OUT="/tmp/pulse-$$"

echo "📡 upstream-pulse: $REPO (since $SINCE)"
echo "================================================"

# --- Step 1: Pull commits ---
echo "→ Fetching commits..."
gh api "repos/$REPO/commits?since=$SINCE&per_page=100" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.sha[0:7]) + "\t" + (.commit.message|split("\n")[0])' \
  > "$OUT-commits.tsv"
TOTAL_COMMITS=$(wc -l < "$OUT-commits.tsv")
echo "  $TOTAL_COMMITS commits"

# --- Step 2: Pull issues ---
echo "→ Fetching issues..."
gh api "repos/$REPO/issues?since=$SINCE&state=all&per_page=100&sort=created" --paginate \
  --jq '.[] | select(.pull_request == null) | (.created_at[0:10]) + "\t#" + (.number|tostring) + "\t[" + .state + "]\t" + .title' \
  > "$OUT-issues.tsv"
TOTAL_ISSUES=$(wc -l < "$OUT-issues.tsv")
echo "  $TOTAL_ISSUES issues"

# --- Step 3: Pull PRs ---
echo "→ Fetching PRs..."
gh api "repos/$REPO/pulls?state=all&per_page=100&sort=created&direction=desc" --paginate \
  --jq '.[] | select(.created_at >= "'"$SINCE"'") | (.created_at[0:10]) + "\tPR#" + (.number|tostring) + "\t[" + .state + "]\t" + .title' \
  > "$OUT-prs.tsv"
TOTAL_PRS=$(wc -l < "$OUT-prs.tsv")
echo "  $TOTAL_PRS PRs"

echo ""
echo "================================================"
echo "UNIFIED TIMELINE (commits + issues + PRs per day)"
echo "================================================"
echo ""
printf "%-12s %8s %8s %8s %8s\n" "Date" "Commits" "Issues" "PRs" "Total"
printf "%-12s %8s %8s %8s %8s\n" "----" "-------" "------" "---" "-----"

{
  cut -f1 "$OUT-commits.tsv" | awk '{print $1, "COMMIT"}'
  cut -f1 "$OUT-issues.tsv" | awk '{print $1, "ISSUE"}'
  cut -f1 "$OUT-prs.tsv" | awk '{print $1, "PR"}'
} | awk '{
  dates[$1]=1
  counts[$1" "$2]++
}
END {
  n = asorti(dates, sorted)
  for (i=1; i<=n; i++) {
    d = sorted[i]
    c = counts[d" COMMIT"]+0
    is = counts[d" ISSUE"]+0
    p = counts[d" PR"]+0
    t = c + is + p
    printf "%-12s %8d %8d %8d %8d\n", d, c, is, p, t
  }
}'

echo ""
echo "================================================"
echo "SIGNAL vs NOISE"
echo "================================================"
echo ""
awk -F'\t' '{
  msg = tolower($3)
  if (msg ~ /^bump/ || msg ~ /^[0-9]/ || msg ~ /^wip/ || msg ~ /^release/) noise++
  else signal++
} END {
  total = signal + noise
  printf "Signal (meaningful): %d (%d%%)\n", signal, (total>0 ? signal*100/total : 0)
  printf "Noise (bump/version): %d (%d%%)\n", noise, (total>0 ? noise*100/total : 0)
}' "$OUT-commits.tsv"

echo ""
echo "================================================"
echo "CLASSIFY BY TYPE"
echo "================================================"
echo ""
awk -F'\t' '{
  msg = tolower($3)
  if (msg ~ /^bump:/ || msg ~ /^bump /) type="bump"
  else if (msg ~ /^feat/) type="feat"
  else if (msg ~ /^fix/) type="fix"
  else if (msg ~ /^test/) type="test"
  else if (msg ~ /^chore/) type="chore"
  else if (msg ~ /^docs/ || msg ~ /^document/) type="docs"
  else if (msg ~ /^refactor/) type="refactor"
  else if (msg ~ /^release/) type="release"
  else type="other"
  types[type]++
} END {
  for (t in types) printf "  %-12s %d\n", t, types[t]
}' "$OUT-commits.tsv" | sort -k2 -rn

echo ""
echo "================================================"
echo "AREA HEATMAP (top changed directories)"
echo "================================================"
echo ""
echo "→ Sampling file paths from recent non-bump commits..."
grep -vi $'^[^\t]*\tbump\|^[^\t]*\t[0-9]' "$OUT-commits.tsv" | cut -f2 | head -30 | while read sha; do
  gh api "repos/$REPO/commits/$sha" --jq '.files[]?.filename' 2>/dev/null
done | awk -F/ '{if (NF>=2) print $1"/"$2; else print $1}' | sort | uniq -c | sort -rn | head -10

echo ""
echo "================================================"
echo "VELOCITY (issue close rate)"
echo "================================================"
echo ""
CLOSED=$(grep -c '\[closed\]' "$OUT-issues.tsv" 2>/dev/null || echo 0)
OPEN=$(grep -c '\[open\]' "$OUT-issues.tsv" 2>/dev/null || echo 0)
echo "  Closed: $CLOSED / $TOTAL_ISSUES ($(( TOTAL_ISSUES > 0 ? CLOSED * 100 / TOTAL_ISSUES : 0 ))%)"
echo "  Open:   $OPEN"
if [ "$OPEN" -gt 0 ]; then
  echo ""
  echo "  Open issues (roadmap):"
  grep '\[open\]' "$OUT-issues.tsv" | awk -F'\t' '{print "    " $2 "  " $4}'
fi

echo ""
echo "================================================"
echo "FEATURE HIGHLIGHTS"
echo "================================================"
echo ""
grep -iE $'^[^\t]*\t[^\t]*\t(feat|add |extract |enable |expose |support )' "$OUT-commits.tsv" | \
  grep -vi bump | head -15 | awk -F'\t' '{printf "  %s  %s  %s\n", $1, $2, $3}'

echo ""
echo "================================================"
echo "Done. Temp files: $OUT-*.tsv"
echo "================================================"

rm -f "$OUT-commits.tsv" "$OUT-issues.tsv" "$OUT-prs.tsv"

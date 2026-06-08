#!/bin/bash
# upstream-lens digest — Leica's 5-lens analysis
# Usage: ./digest.sh [owner/repo] [since-date]

REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)}"

echo "═══ UPSTREAM LENS: $REPO (since $SINCE) ═══"
echo ""

# --- Fetch commits ---
echo "Fetching commits..."
COMMITS=$(gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z&per_page=100" --paginate \
  --jq '.[] | [.commit.author.date[0:10], .sha[0:7], (.commit.message|split("\n")[0]), .author.login // .commit.author.name] | @tsv' 2>/dev/null)
TOTAL_COMMITS=$(echo "$COMMITS" | wc -l | tr -d ' ')

# --- Fetch issues ---
echo "Fetching issues..."
ISSUES=$(gh api "repos/$REPO/issues?since=${SINCE}T00:00:00Z&per_page=100&state=all" --paginate \
  --jq '.[] | select(.pull_request == null) | [.created_at[0:10], "#" + (.number|tostring), .state, (.title|.[0:60])] | @tsv' 2>/dev/null)
TOTAL_ISSUES=$(echo "$ISSUES" | grep -c '.' 2>/dev/null || echo "0")

# --- Fetch PRs ---
echo "Fetching PRs..."
PRS=$(gh api "repos/$REPO/pulls?state=all&per_page=100&sort=created&direction=desc" --paginate \
  --jq ".[] | select(.created_at >= \"${SINCE}\") | [.created_at[0:10], \"#\" + (.number|tostring), .state, (.title|.[0:60])] | @tsv" 2>/dev/null)
TOTAL_PRS=$(echo "$PRS" | grep -c '.' 2>/dev/null || echo "0")

echo ""
echo "Total: $TOTAL_COMMITS commits, $TOTAL_ISSUES issues, $TOTAL_PRS PRs"
echo ""

# --- LENS 1: Telescope ---
echo "🔭 LENS 1: TELESCOPE (Big Picture)"
echo "───────────────────────────────────"
echo "$COMMITS" | cut -f1 | sort | uniq -c | sort -k2 | while read count date; do
  bar=$(printf '█%.0s' $(seq 1 $(( count > 50 ? 50 : count ))))
  printf "  %s  %-50s %3d\n" "$date" "$bar" "$count"
done
echo ""

# --- LENS 2: Microscope ---
echo "🔬 LENS 2: MICROSCOPE (Who & Where)"
echo "───────────────────────────────────"
echo "Contributors:"
echo "$COMMITS" | cut -f4 | sort | uniq -c | sort -rn | head -5 | while read count name; do
  printf "  %-20s %d\n" "$name" "$count"
done
echo ""

# --- LENS 3: Blueprint ---
echo "📐 LENS 3: BLUEPRINT (Classification)"
echo "───────────────────────────────────"
echo "$COMMITS" | cut -f3 | sed 's/:.*//' | sed 's/ .*//' | sed 's/(.*//g' | \
  grep -iE '^(feat|fix|bump|test|docs|refactor|chore|ci)' | \
  tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | while read count type; do
  printf "  %-12s %3d\n" "$type" "$count"
done
echo ""

# --- LENS 4: Red Flag ---
echo "⚠️  LENS 4: RED FLAG (Risk)"
echo "───────────────────────────────────"
RISK=$(echo "$COMMITS" | cut -f3 | grep -icE "revert|broken|hotfix|urgent|breaking|force" 2>/dev/null)
echo "  Risk signals in commits: $RISK"
echo "  Open issues:"
echo "$ISSUES" | grep "open" | head -5 | while IFS=$'\t' read date num state title; do
  printf "    %s %s %s\n" "$num" "$date" "$title"
done
echo ""

# --- LENS 5: Forecast ---
echo "🔮 LENS 5: FORECAST (Prediction)"
echo "───────────────────────────────────"
FEAT_COUNT=$(echo "$COMMITS" | cut -f3 | grep -ic "^feat" 2>/dev/null)
FIX_COUNT=$(echo "$COMMITS" | cut -f3 | grep -ic "^fix" 2>/dev/null)
BUMP_COUNT=$(echo "$COMMITS" | cut -f3 | grep -ic "^bump" 2>/dev/null)
echo "  feat=$FEAT_COUNT  fix=$FIX_COUNT  bump=$BUMP_COUNT"
if [ "$FIX_COUNT" -gt "$FEAT_COUNT" ]; then
  echo "  → Fix-heavy: stabilization phase"
else
  echo "  → Feat-heavy: active development"
fi
if [ "$BUMP_COUNT" -gt 50 ]; then
  echo "  → High bump count: approaching release"
fi
echo ""

# --- Cross-lens ---
echo "═══════════════════════════════════"
echo "VERDICT: $TOTAL_COMMITS commits in $(echo "$COMMITS" | cut -f1 | sort -u | wc -l | tr -d ' ') days"
echo "SIGNAL:  feat commits + open issues"
echo "NOISE:   bump commits ($BUMP_COUNT = $(( BUMP_COUNT * 100 / TOTAL_COMMITS ))%)"
echo "═══════════════════════════════════"

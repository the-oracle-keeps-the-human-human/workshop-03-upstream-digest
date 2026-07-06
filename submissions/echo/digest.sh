#!/bin/bash
# upstream-echo — resonance mapping digest
# Usage: ./digest.sh [owner/repo] [since-date]
# Echo Oracle 🔔 — The Returning Voice

REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)}"

echo "🔔 UPSTREAM ECHO: $REPO (since $SINCE)"
echo "════════════════════════════════════════════════════════"
echo ""

# ── Fetch commits ──────────────────────────────────────────
echo "Fetching commits..."
COMMITS=$(gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z&per_page=100" --paginate \
  --jq '.[] | [.commit.author.date[0:10], .sha[0:7], (.commit.message|split("\n")[0]), .author.login // .commit.author.name] | @tsv' 2>/dev/null)
TOTAL_COMMITS=$(echo "$COMMITS" | grep -c '.' 2>/dev/null || echo "0")

# ── Fetch issues ───────────────────────────────────────────
echo "Fetching issues..."
ISSUES=$(gh api "repos/$REPO/issues?since=${SINCE}T00:00:00Z&per_page=100&state=all" --paginate \
  --jq '.[] | select(.pull_request == null) | [.created_at[0:10], "#" + (.number|tostring), .state, (.title|.[0:70])] | @tsv' 2>/dev/null)
TOTAL_ISSUES=$(echo "$ISSUES" | grep -c '.' 2>/dev/null || echo "0")

# ── Fetch PRs ──────────────────────────────────────────────
echo "Fetching PRs..."
PRS=$(gh api "repos/$REPO/pulls?state=all&per_page=100&sort=created&direction=desc" --paginate \
  --jq ".[] | select(.created_at >= \"${SINCE}\") | [.created_at[0:10], \"#\" + (.number|tostring), .state, (.title|.[0:70]), (.number|tostring)] | @tsv" 2>/dev/null)
TOTAL_PRS=$(echo "$PRS" | grep -c '.' 2>/dev/null || echo "0")

echo ""
echo "Signals gathered: $TOTAL_COMMITS commits · $TOTAL_ISSUES issues · $TOTAL_PRS PRs"
echo ""

# ══ PULSE: Daily Activity Bar Chart ══════════════════════════
echo "━━━ PULSE — Daily Activity ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "DATE        C:commits  P:prs  I:issues  bar (each █ ≈ 5 events)"
echo "──────────  ─────────  ─────  ────────  ────────────────────────"

# Get all dates from all sources
ALL_DATES=$(
  echo "$COMMITS" | cut -f1
  echo "$PRS" | cut -f1
  echo "$ISSUES" | cut -f1
)

for DATE in $(echo "$ALL_DATES" | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | sort -u); do
  C=$(echo "$COMMITS" | grep "^$DATE" 2>/dev/null | wc -l | tr -d ' ')
  P=$(echo "$PRS"     | grep "^$DATE" 2>/dev/null | wc -l | tr -d ' ')
  I=$(echo "$ISSUES"  | grep "^$DATE" 2>/dev/null | wc -l | tr -d ' ')
  TOTAL=$(( C + P + I ))
  BAR_LEN=$(( TOTAL / 5 ))
  [ "$BAR_LEN" -gt 40 ] && BAR_LEN=40
  if [ "$BAR_LEN" -gt 0 ]; then
    BAR=$(python3 -c "print('█' * $BAR_LEN)" 2>/dev/null || printf '%0.s█' $(seq 1 $BAR_LEN))
  else
    BAR=""
  fi
  printf "%-10s  C:%-6d  P:%-3d  I:%-4d  %s\n" "$DATE" "$C" "$P" "$I" "$BAR"
done
echo ""

# ══ RESONANCE: Echo Pattern Detection ════════════════════════
echo "━━━ RESONANCE — Ideas That Echo ━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "An idea that crosses ≥2 sources (issue→PR, PR→commit) = resonance"
echo ""

# Extract keywords: words ≥5 chars from PR/issue titles, filter noise
KEYWORDS=$(
  echo "$PRS"    | cut -f4 | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z-' '\n'
  echo "$ISSUES" | cut -f4 | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z-' '\n'
)

NOISE_WORDS="^(added|after|allow|also|and|are|before|between|bump|build|chore|docs|does|each|feat|file|fix|for|from|have|into|not|now|only|pull|push|refactor|release|remove|should|sync|that|the|this|too|type|update|use|via|was|when|will|with|you|the|when|its|our)$"

echo "$KEYWORDS" | grep -E '^.{5,}$' | grep -vE "$NOISE_WORDS" | sort | uniq -c | sort -rn | head -20 | \
while read count word; do
  IN_COMMIT=$(echo "$COMMITS" | cut -f3 | tr '[:upper:]' '[:lower:]' | grep "$word" 2>/dev/null | wc -l | tr -d ' ')
  IN_PR=$(echo "$PRS" | cut -f4 | tr '[:upper:]' '[:lower:]' | grep "$word" 2>/dev/null | wc -l | tr -d ' ')
  IN_ISSUE=$(echo "$ISSUES" | cut -f4 | tr '[:upper:]' '[:lower:]' | grep "$word" 2>/dev/null | wc -l | tr -d ' ')
  SOURCES=$(( (IN_COMMIT > 0 ? 1 : 0) + (IN_PR > 0 ? 1 : 0) + (IN_ISSUE > 0 ? 1 : 0) ))
  if [ "$SOURCES" -ge 2 ]; then
    echo ""
    echo "  🔔 ECHO: \"$word\"  (commits:$IN_COMMIT · PRs:$IN_PR · issues:$IN_ISSUE)"
    echo "     Issues:"
    echo "$ISSUES" | cut -f1-4 | grep -i "$word" | head -3 | while IFS=$'\t' read d n s t; do
      printf "       %s %-6s [%s] %s\n" "$d" "$n" "$s" "$t"
    done
    echo "     PRs:"
    echo "$PRS" | cut -f1-4 | grep -i "$word" | head -3 | while IFS=$'\t' read d n s t; do
      printf "       %s %-6s [%s] %s\n" "$d" "$n" "$s" "$t"
    done
  fi
done
echo ""

# ══ CLASSIFICATION: Signal vs Noise ══════════════════════════
echo "━━━ CLASSIFICATION — Signal / Noise / Blocked / Orphan ━━━"
echo ""

FEAT_C=$(echo "$COMMITS" | cut -f3 | grep -i "^feat" 2>/dev/null | wc -l | tr -d ' ')
FIX_C=$(echo "$COMMITS"  | cut -f3 | grep -i "^fix"  2>/dev/null | wc -l | tr -d ' ')
BUMP_C=$(echo "$COMMITS" | cut -f3 | grep -i "^bump" 2>/dev/null | wc -l | tr -d ' ')
MERGE_C=$(echo "$COMMITS"| cut -f3 | grep -iE "^merge|^Merge" 2>/dev/null | wc -l | tr -d ' ')
OTHER_C=$(( TOTAL_COMMITS - FEAT_C - FIX_C - BUMP_C - MERGE_C ))

echo "  Commit types:"
printf "    feat=%-4d  fix=%-4d  bump=%-4d  merge=%-4d  other=%-4d\n" \
  "$FEAT_C" "$FIX_C" "$BUMP_C" "$MERGE_C" "$OTHER_C"
echo ""

# Noise = bump + merge
NOISE=$(( BUMP_C + MERGE_C ))
SIGNAL=$(( FEAT_C + FIX_C ))
echo "  Signal (feat+fix): $SIGNAL  Noise (bump+merge): $NOISE"
[ "$TOTAL_COMMITS" -gt 0 ] && echo "  Signal ratio: $(( SIGNAL * 100 / TOTAL_COMMITS ))%"
echo ""

# Blocked = open issues with no corresponding PR
echo "  Blocked signals (open issues, no PR echo yet):"
echo "$ISSUES" | grep $'\t''open' | cut -f1-4 | head -5 | while IFS=$'\t' read d n s t; do
  printf "    %s %-6s %s\n" "$d" "$n" "$t"
done
echo ""

# Risk signals
RISK=$(echo "$COMMITS" | cut -f3 | grep -iE "revert|broken|hotfix|urgent|breaking|force" 2>/dev/null | wc -l | tr -d ' ')
echo "  Risk signals in commits: $RISK"
if [ "$RISK" -gt 0 ]; then
  echo "$COMMITS" | cut -f2-3 | grep -iE "revert|broken|hotfix|urgent|breaking|force" | head -5 | \
    while IFS=$'\t' read sha msg; do printf "    %s %s\n" "$sha" "$msg"; done
fi
echo ""

# ══ TOP CONTRIBUTORS ════════════════════════════════════════
echo "━━━ CONTRIBUTORS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "$COMMITS" | cut -f4 | sort | uniq -c | sort -rn | head -8 | \
  while read count name; do printf "  %-30s %d commits\n" "$name" "$count"; done
echo ""

# ══ THREE-LINE VERDICT ═══════════════════════════════════════
echo "━━━ VERDICT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Determine pulse direction
LAST_DATE=$(echo "$COMMITS" | cut -f1 | sort | tail -1)
FIRST_DATE=$(echo "$COMMITS" | cut -f1 | sort | head -1)
LAST_WEEK_C=$(echo "$COMMITS" | awk -v d="$LAST_DATE" '$1 >= d' | grep -c '.' 2>/dev/null || echo 0)

if [ "$TOTAL_COMMITS" -gt 200 ]; then
  PULSE="high-velocity (sprint or release crunch)"
elif [ "$TOTAL_COMMITS" -gt 50 ]; then
  PULSE="active"
else
  PULSE="cooling (low commit volume)"
fi

echo "  PULSE:      $TOTAL_COMMITS events ($SINCE → today) — $PULSE"

# Top echo
TOP_ECHO=$(
  (echo "$PRS" | cut -f4; echo "$ISSUES" | cut -f4) | \
  tr '[:upper:]' '[:lower:]' | tr -cs 'a-z-' '\n' | \
  grep -E '^.{5,}$' | grep -vE "$NOISE_WORDS" | \
  sort | uniq -c | sort -rn | head -1 | awk '{print $2}'
)
echo "  RESONANCE:  top echoing idea → \"$TOP_ECHO\""
echo "  WATCH:      bump/merge noise=$NOISE · open issues=$TOTAL_ISSUES · risk signals=$RISK"
echo ""
echo "🔔 — Echo Oracle · The Returning Voice · echo-oracle"

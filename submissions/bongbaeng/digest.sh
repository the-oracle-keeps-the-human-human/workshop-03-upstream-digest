#!/usr/bin/env bash
# upstream-story + braid — บ๊องแบ๊ง Oracle 🐆
# digest a repo's commits into a STORY, then braid commits+PRs+issues on one
# timestamp axis so cause→effect is visible.
#
# Usage:
#   ./digest.sh                              # maw-js, since 2026-05-25
#   ./digest.sh <owner/repo>                 # other repo, last 14 days
#   ./digest.sh <owner/repo> 2026-05-25      # other repo, custom since
set -euo pipefail

REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "🐆 upstream-story → $REPO  (since $SINCE)"
echo

# ── 1. PULL commits (real, no mock) ───────────────────────────────────────────
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.sha[0:7]) + "\t" + (.commit.message|split("\n")[0])' \
  > "$TMP/c.tsv"
TOTAL=$(wc -l < "$TMP/c.tsv" | tr -d ' ')
echo "## 📊 $TOTAL commits"
echo

# ── 2. TIMELINE by day (+ spike flag) ─────────────────────────────────────────
echo "## 📅 Timeline by day"
cut -f1 "$TMP/c.tsv" | sort | uniq -c | sort -k2 | awk '{
  n=$1; bar=""; for(i=0;i<int(n/20);i++)bar=bar"█";
  printf "  %s  %4d  %s%s\n", $2, n, bar, (n>120?"  ⚡SPIKE":"")
}'
echo

# ── 3. CLASSIFY — verb buckets (handles non-conventional commits) ─────────────
# maw-js uses imperative verbs (Cover/Lock/Repair), not just feat/fix prefixes.
echo "## 🏷️  Classify (intent buckets, not just prefix)"
cut -f3 "$TMP/c.tsv" | awk '{
  v = (match($0,/^[a-zA-Z]+/)) ? tolower(substr($0,RSTART,RLENGTH)) : "none";
  if (v ~ /^(bump|release)$/)                       b["noise (version)"]++;
  else if (v ~ /^(feat|add|expose|enable|support|stream|parse|detect|introduce)$/) b["signal (new)"]++;
  else if (v ~ /^(fix|repair|guard|prevent|harden|bound|lock|stabilize|resolve|patch)$/) b["stabilize"]++;
  else if (v ~ /^(test|cover|prove|verify)$/)       b["test"]++;
  else if (v ~ /^(docs?|document)$/)                b["docs"]++;
  else if (v ~ /^(refactor|extract|move|rename|unify|isolate|reduce|simplify)$/) b["refactor"]++;
  else                                              b["other"]++;
} END { for (k in b) printf "  %-18s %4d\n", k, b[k] }' | sort -t' ' -k2 -rn
echo

# ── 4. CHURN RADAR (บ๊องแบ๊ง edge — motion that ate itself) ────────────────────
echo "## 🔁 Churn radar (what a plain count hides)"
REV=$(grep -icE 'revert|rollback|hotfix' "$TMP/c.tsv" || true)
SPRAWL=$(grep -icE 'delete.*(sprawl|coverage)|reduce.*churn|re-?(repair|add|do)' "$TMP/c.tsv" || true)
echo "  reverts/rollbacks : $REV"
echo "  add-then-delete   : $SPRAWL  (work that was undone in-window)"
grep -iE 'delete.*(sprawl|coverage)|reduce.*churn' "$TMP/c.tsv" | head -3 | sed 's/^/    ↳ /' | cut -f1,3 || true
echo

# ── STRETCH: BRAID — timestamp = single source of truth ───────────────────────
echo "## 🌈 Braid — commits + PRs + issues on one timestamp axis"
{
  cut -f2- "$TMP/c.tsv" >/dev/null  # (commits already have date in col1; rebuild with full ts below)
  gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z" --paginate \
    --jq '.[] | .commit.author.date + "\tcommit\t" + (.sha[0:7]) + "\t" + (.commit.message|split("\n")[0])'
  gh api "repos/$REPO/pulls?state=closed&sort=updated&direction=desc&per_page=80" \
    --jq ".[] | select(.merged_at != null and .merged_at > \"$SINCE\") | .merged_at + \"\tPR-merged\t#\" + (.number|tostring) + \"\t\" + .title"
  gh api "repos/$REPO/issues?state=all&sort=created&direction=desc&per_page=80" \
    --jq ".[] | select(.pull_request == null) | select(.created_at > \"$SINCE\") | .created_at + \"\tissue-open\t#\" + (.number|tostring) + \"\t\" + .title"
} > "$TMP/braid.tsv" 2>/dev/null
echo "  $(wc -l < "$TMP/braid.tsv" | tr -d ' ') timestamped events. Most recent 16:"
sort "$TMP/braid.tsv" | tail -16 | awk -F'\t' '{printf "  %s  %-10s %-7s %s\n", substr($1,6,11), $2, $3, substr($4,1,52)}'
echo
echo "  → adjacency on the time axis ≈ causality (issue → commit → PR → bump)"

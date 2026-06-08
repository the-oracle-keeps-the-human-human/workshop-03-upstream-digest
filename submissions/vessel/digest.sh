#!/usr/bin/env bash
# upstream-courier — Vessel's courier digest
# Usage: ./digest.sh [owner/repo] [since-date]
# Example: ./digest.sh Soul-Brews-Studio/maw-js 2026-05-25

REPO=${1:-"Soul-Brews-Studio/maw-js"}
SINCE=${2:-$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d "-14 days" +%Y-%m-%d)}

echo "=== UPSTREAM COURIER: $REPO (since $SINCE) ==="
echo ""

echo "--- COMMITS by day ---"
gh api "repos/$REPO/commits?since=${SINCE}&per_page=100" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "  " + (.sha[0:7]) + "  " + (.commit.message|split("\n")[0])' \
  | sort | awk '{print $1}' | sort | uniq -c | sort -rn
echo ""

echo "--- COMMIT TYPES (signal vs noise) ---"
gh api "repos/$REPO/commits?since=${SINCE}&per_page=100" --paginate \
  --jq '.[] | (.commit.message|split("\n")[0])' \
  | grep -oE '^(feat|fix|bump|docs|refactor|chore|test|perf|ci|build)' \
  | sort | uniq -c | sort -rn
echo ""

echo "--- RECENT MERGED PRs ---"
gh api "repos/$REPO/pulls?state=closed&per_page=30" \
  --jq '.[] | select(.merged_at != null) | .merged_at[0:10] + "  PR#" + (.number|tostring) + "  " + .title' \
  | sort | tail -15
echo ""

echo "--- OPEN ISSUES (in motion) ---"
gh api "repos/$REPO/issues?state=open&per_page=20" \
  --jq '.[] | select(.pull_request == null) | .created_at[0:10] + "  #" + (.number|tostring) + "  " + .title' \
  | sort | tail -10

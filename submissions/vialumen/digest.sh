#!/usr/bin/env bash
# commit-prism — digest repo commits ผ่าน prism lenses + area + timestamp SSOT
# ViaLumen 2026-06-08 — Workshop 03. ต่อยอด ChaiKlang + /oracle-prism + /trace
# usage: ./digest.sh [owner/repo] [since-date]
set -euo pipefail

REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-2026-05-25}"
TSV="$(mktemp)"

echo "# 📊 commit-prism: $REPO (since $SINCE)"
echo

# pull commits
gh api "repos/$REPO/commits?since=$SINCE" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.commit.message|split("\n")[0])' > "$TSV"
TOTAL=$(wc -l < "$TSV")
echo "total commits: $TOTAL"
echo

# 🔍 Archaeologist — timeline by day
echo "## 🔍 Archaeologist — timeline by day"
cut -f1 "$TSV" | sort | uniq -c | sort -rn | head -8
echo

# classify by prefix (type)
echo "## type (prefix)"
cut -f2 "$TSV" | grep -oiE '^(feat|fix|test|bump|docs|refactor|chore|build|ci|perf)' \
  | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn
echo

# 🏗️ Architect — AREA (keyword) — มุมที่ ChaiKlang ไม่ทำ
echo "## 🏗️ Architect — hot areas (keyword)"
cut -f2 "$TSV" | grep -oiE '(team|wake|charter|engine|federation|plugin|doctor|worktree|codex|bud|peer|voice|auth|api)' \
  | tr 'A-Z' 'a-z' | sort | uniq -c | sort -rn | head -8
echo

# 🐛 Bug Hunter — fix themes
echo "## 🐛 Bug Hunter — recent fixes"
grep -iE $'\t''fix' "$TSV" | cut -f2 | head -5
echo

# 📋 Auditor — signal vs noise verdict
FEAT=$(cut -f2 "$TSV" | grep -ciE '^feat' || true)
NOISE=$(cut -f2 "$TSV" | grep -ciE '^(bump|test|chore)' || true)
echo "## 📋 Auditor — signal vs noise"
echo "feat (signal): $FEAT   |   bump+test+chore (noise): $NOISE / $TOTAL"
echo

# 🌈 Stretch — timestamp SSOT: merge commit + PR + issue → causality
echo "## 🌈 Timestamp SSOT — unified timeline (commit + PR + issue)"
{
  gh pr list --repo "$REPO" --state merged --limit 12 --json number,title,mergedAt \
    --jq '.[] | (.mergedAt[0:16]) + "\t🔀PR#" + (.number|tostring) + "  " + .title' 2>/dev/null || true
  gh issue list --repo "$REPO" --state all --limit 12 --json number,title,createdAt \
    --jq '.[] | (.createdAt[0:16]) + "\t🎫ISSUE#" + (.number|tostring) + "  " + .title' 2>/dev/null || true
} | sort -r | head -15

rm -f "$TSV" 2>/dev/null || true

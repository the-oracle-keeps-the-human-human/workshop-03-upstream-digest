#!/usr/bin/env bash
set -euo pipefail
REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-2026-06-01T00:00:00Z}"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

gh api "repos/$REPO/commits?since=$SINCE&per_page=100" --paginate > "$TMP/commits.json"
gh api "repos/$REPO/pulls?state=all&sort=updated&direction=desc&per_page=100" --paginate > "$TMP/pulls.json"
gh api "repos/$REPO/issues?state=all&since=$SINCE&per_page=100" --paginate > "$TMP/issues.json"

jq -r '
  .[] | [.commit.author.date[0:10], "commit", (.commit.message|split("\n")[0])] | @tsv
' "$TMP/commits.json" > "$TMP/events.tsv"

jq -r --arg since "$SINCE" '
  .[] | select(.updated_at >= $since) | [.updated_at[0:10], (if .merged_at then "pr-merged" else "pr" end), ("#"+(.number|tostring)+" "+.title)] | @tsv
' "$TMP/pulls.json" >> "$TMP/events.tsv"

jq -r --arg since "$SINCE" '
  .[] | select((has("pull_request")|not) and (.updated_at >= $since)) | [.updated_at[0:10], "issue", ("#"+(.number|tostring)+" "+.title)] | @tsv
' "$TMP/issues.json" >> "$TMP/events.tsv"

printf '# Atom Upstream Digest\n\n'
printf 'repo: `%s`\nsince: `%s`\n\n' "$REPO" "$SINCE"
printf '## Daily event counts\n\n```text\n'
awk -F'\t' '{count[$1]++; kind[$1","$2]++} END {for (d in count) print d, count[d], "events"}' "$TMP/events.tsv" | sort
printf '```\n\n'
printf '## Commit classification\n\n```text\n'
awk -F'\t' '$2=="commit" {msg=tolower($3); if (msg ~ /^feat/) k="feat"; else if (msg ~ /^fix/) k="fix"; else if (msg ~ /^docs/) k="docs"; else if (msg ~ /^refactor/) k="refactor"; else if (msg ~ /^chore|^bump/) k="chore/bump"; else k="other"; c[k]++} END {for (k in c) print k, c[k]}' "$TMP/events.tsv" | sort
printf '```\n\n'
printf '## Highlights\n\n'
sort "$TMP/events.tsv" | awk -F'\t' 'NR<=30 {printf "- `%s` **%s** — %s\n", $1, $2, $3}'

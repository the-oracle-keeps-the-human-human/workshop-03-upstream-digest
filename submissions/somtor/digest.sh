#!/usr/bin/env bash
# upstream-hive — SomTor Oracle 🐝
# digest a repo by tracing CONNECTIONS: co-change clusters, contributor
# rhythm, cause→effect chains, all on one timestamp axis.
#
# Usage:
#   ./digest.sh                              # maw-js, last 14 days
#   ./digest.sh <owner/repo>                 # other repo
#   ./digest.sh <owner/repo> 2026-05-25      # custom since date
set -euo pipefail

REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "🐝 upstream-hive → $REPO  (since $SINCE)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# ── 1. PULL commits ──────────────────────────────────────────────────────────
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z&per_page=100" --paginate \
  --jq '.[] | (.commit.author.date) + "\t" + (.sha[0:7]) + "\t" + (.commit.author.name) + "\t" + (.commit.message|split("\n")[0])' \
  > "$TMP/commits.tsv"
TOTAL_C=$(wc -l < "$TMP/commits.tsv" | tr -d ' ')

# ── 2. PULL PRs ─────────────────────────────────────────────────────────────
gh api "repos/$REPO/pulls?state=closed&sort=updated&direction=desc&per_page=100" --paginate \
  --jq '.[] | select(.merged_at != null) | select(.merged_at > "'"${SINCE}"'") | (.merged_at) + "\t" + "PR#" + (.number|tostring) + "\t" + (.title|split("\n")[0]) + "\t" + (.body // "" | capture("(?:closes?|fixes?|resolves?)\\s*#(?<n>[0-9]+)"; "gi") | .n // "")' \
  > "$TMP/prs.tsv" 2>/dev/null || true
TOTAL_P=$(wc -l < "$TMP/prs.tsv" | tr -d ' ')

# ── 3. PULL issues closed ───────────────────────────────────────────────────
gh api "repos/$REPO/issues?state=closed&since=${SINCE}T00:00:00Z&per_page=100" --paginate \
  --jq '.[] | select(.pull_request == null) | (.closed_at) + "\t" + "ISS#" + (.number|tostring) + "\t" + (.title|split("\n")[0])' \
  > "$TMP/issues.tsv" 2>/dev/null || true
TOTAL_I=$(wc -l < "$TMP/issues.tsv" | tr -d ' ')

echo "## 📊 Raw Data"
echo "  Commits: $TOTAL_C | PRs merged: $TOTAL_P | Issues closed: $TOTAL_I"
echo

# ══════════════════════════════════════════════════════════════════════════════
# LAYER 1: Timeline by day (all events merged)
# ══════════════════════════════════════════════════════════════════════════════
echo "## 📅 Layer 1: Unified Timeline"

{
  awk -F'\t' '{print substr($1,1,10) "\tcommit\t" $2 "\t" $4}' "$TMP/commits.tsv"
  awk -F'\t' '{print substr($1,1,10) "\tpr\t" $2 "\t" $3}' "$TMP/prs.tsv"
  awk -F'\t' '{print substr($1,1,10) "\tissue\t" $2 "\t" $3}' "$TMP/issues.tsv"
} | sort > "$TMP/all_events.tsv"

awk -F'\t' '{
  d=$1; t=$2
  days[d]++
  if (t=="commit") c[d]++
  if (t=="pr") p[d]++
  if (t=="issue") i[d]++
}
END {
  for(d in days) {
    total=days[d]
    bar=""
    for(j=0;j<int(total/10);j++) bar=bar"X"
    spike=(total>100)?"  SPIKE":""
    printf "%s\t%4d\t(C:%d P:%d I:%d)\t%s%s\n", d, total, c[d]+0, p[d]+0, i[d]+0, bar, spike
  }
}' "$TMP/all_events.tsv" | sort | awk -F'\t' '{printf "  %s  %s  %s  %s%s\n", $1, $2, $3, $4, $5}'
echo

# ══════════════════════════════════════════════════════════════════════════════
# LAYER 2: Co-change Clusters (file pairs that ship together)
# ══════════════════════════════════════════════════════════════════════════════
echo "## 🔗 Layer 2: Co-change Clusters"
echo "  (file pairs that change together ≥3 times = hidden coupling)"
echo

# Fetch files changed per commit (sample first 50 commits for speed)
head -50 "$TMP/commits.tsv" | cut -f2 | while read -r sha; do
  gh api "repos/$REPO/commits/$sha" --jq '[.files[].filename] | join("|")' 2>/dev/null
done > "$TMP/file_sets.txt" 2>/dev/null || true

# Find co-occurring file pairs
if [ -s "$TMP/file_sets.txt" ]; then
  awk -F'|' '{
    n=split($0,files,"|")
    for(i=1;i<=n;i++) {
      split(files[i],parts,"/")
      if (parts[2]!="") dirs[i]=parts[1]"/"parts[2]; else dirs[i]=parts[1]
    }
    for(i=1;i<=n;i++)
      for(j=i+1;j<=n;j++)
        if(dirs[i]!=dirs[j]) pairs[dirs[i]" ↔ "dirs[j]]++
  }
  END {
    for(k in pairs) if(pairs[k]>=3) printf "  %3d×  %s\n", pairs[k], k
  }' "$TMP/file_sets.txt" | sort -rn | head -10
  echo
else
  echo "  (could not fetch file data — rate limit or private repo)"
  echo
fi

# ══════════════════════════════════════════════════════════════════════════════
# LAYER 3: Contributor Rhythm (hour heatmap, Bangkok TZ)
# ══════════════════════════════════════════════════════════════════════════════
echo "## ⏰ Layer 3: Contributor Rhythm (UTC → Bangkok +7)"

awk -F'\t' '{
  # Extract hour from ISO timestamp, add 7 for Bangkok
  split($1,dt,"T")
  split(dt[2],hms,":")
  h=(hms[1]+7)%24
  hours[h]++
  authors[$3]++
}
END {
  printf "\n  Hour  Commits  Bar\n  ────  ───────  ───\n"
  for(h=0;h<24;h++) {
    n=hours[h]+0
    bar=""
    for(i=0;i<int(n/5);i++) bar=bar"▓"
    if(n>0) printf "  %02d    %4d     %s%s\n", h, n, bar, (n>40?" ⚡":"")
  }
  printf "\n  Contributors:\n"
  for(a in authors) printf "    %s (%d commits)\n", a, authors[a]
}' "$TMP/commits.tsv"
echo

# ══════════════════════════════════════════════════════════════════════════════
# LAYER 4: Cause→Effect Chains (issue → PR → close)
# ══════════════════════════════════════════════════════════════════════════════
echo "## ⛓️  Layer 4: Cause→Effect Chains"
echo "  (PR that fixes/closes an issue — traced by timestamp)"
echo

if [ -s "$TMP/prs.tsv" ]; then
  awk -F'\t' '$4!="" {
    printf "  %s  %s → fixes #%s  (%s)\n", substr($1,1,16), $2, $4, $3
  }' "$TMP/prs.tsv" | head -15

  CHAINS=$(awk -F'\t' '$4!=""' "$TMP/prs.tsv" | wc -l | tr -d ' ')
  echo
  echo "  Total chains: $CHAINS"
else
  echo "  (no cause→effect chains found in PR bodies)"
fi
echo

# ══════════════════════════════════════════════════════════════════════════════
# HIGHLIGHTS
# ══════════════════════════════════════════════════════════════════════════════
echo "## 🏆 Highlights (top 3 signals)"
echo

# Find spike day
SPIKE_DAY=$(awk -F'\t' '{d=substr($1,1,10); days[d]++} END {max=0; for(d in days) if(days[d]>max){max=days[d]; md=d} print md}' "$TMP/all_events.tsv")
SPIKE_N=$(awk -F'\t' -v d="$SPIKE_DAY" 'substr($1,1,10)==d' "$TMP/all_events.tsv" | wc -l | tr -d ' ')
echo "  1. 🔥 Sprint day: $SPIKE_DAY ($SPIKE_N events) — ทุก signal รวมกันวันนี้"

# Find most active contributor
TOP_AUTHOR=$(awk -F'\t' '{a[$3]++} END {max=0; for(x in a) if(a[x]>max){max=a[x]; m=x} print m " (" max " commits)"}' "$TMP/commits.tsv")
echo "  2. 👤 Top contributor: $TOP_AUTHOR"

# Find classify distribution
echo -n "  3. 🏷️  Signal vs Noise: "
awk -F'\t' '{
  m=tolower($4)
  if (m ~ /^(bump|release|merge|version)/) noise++
  else if (m ~ /^(feat|add|expose|enable|support|stream|introduce)/) signal++
  else if (m ~ /^(fix|repair|guard|prevent|patch|resolve)/) fix++
  else other++
}
END {
  t=signal+fix+noise+other
  if(t>0) printf "signal %d%% · fix %d%% · noise %d%% · other %d%%\n", signal*100/t, fix*100/t, noise*100/t, other*100/t
  else print "no data"
}' "$TMP/commits.tsv"

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐝 upstream-hive complete — SomTor Oracle"

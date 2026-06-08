#!/usr/bin/env bash
# Upstream Digest (Advanced) - Tua Lek Oracle
REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-2026-05-25}"

echo "Fetching commits for $REPO since $SINCE..." >&2
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.sha[0:7]) + "\t" + (.commit.message|split("\n")[0])' > /tmp/digest-commits-tualek.tsv

python3 - "$SINCE" "$REPO" <<'PY'
import sys, re
from collections import defaultdict, Counter

since, repo = sys.argv[1], sys.argv[2]

with open('/tmp/digest-commits-tualek.tsv', 'r') as f:
    lines = [l.strip().split("\t", 2) for l in f if "\t" in l]

by_day = defaultdict(list)
by_type = Counter()
by_scope = Counter()

for date, sha, msg in lines:
    by_day[date].append((sha, msg))
    
    # Classify Type & Scope
    match = re.match(r'^([a-z]+)(?:\(([^)]+)\))?(!?):', msg.lower())
    if match:
        ctype = match.group(1)
        scope = match.group(2)
        by_type[ctype] += 1
        if scope: by_scope[scope] += 1
    elif msg.lower().startswith("bump"):
        by_type["bump"] += 1
    elif msg.lower().startswith("merge"):
        by_type["merge"] += 1
    else:
        by_type["other"] += 1

print(f"# 🎓 Upstream Digest: `{repo}` (Since {since})\n")
print(f"**Total Commits:** {len(lines)}\n")

print("## 📅 Timeline (Commits per day)")
for d in sorted(by_day.keys(), reverse=True):
    print(f"- **{d}**: {len(by_day[d])} commits")

print("\n## 🏷️ Classification (Signal vs Noise)")
print("### 🟢 Signal")
for t in ["feat", "fix", "refactor", "docs", "perf"]:
    if by_type[t] > 0: print(f"- `{t}`: {by_type[t]}")
print("### 🔴 Noise")
for t in ["bump", "chore", "test", "other", "merge"]:
    if by_type[t] > 0: print(f"- `{t}`: {by_type[t]}")

print("\n## 🗺️ Area Analysis (Top Touched Scopes)")
for s, c in by_scope.most_common(5):
    print(f"- `{s}`: {c} commits")

print("\n## ✨ Highlights & Breaking Changes")
for date, sha, msg in lines:
    if "break" in msg.lower() or "!" in msg.split(":")[0]:
        print(f"- 🚨 **BREAKING**: {date} [{sha}] {msg}")
    elif msg.lower().startswith("feat"):
        if "plugin" in msg.lower() or "team" in msg.lower() or "sdk" in msg.lower():
            print(f"- 🌟 **Key Feature**: {date} [{sha}] {msg}")
PY

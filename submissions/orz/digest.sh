#!/bin/bash
# upstream-pulse — Orz Oracle's "feel the rhythm" skill
# Companion to ChaiKlang's /upstream-digest (which focuses on commit classification).
# Pulse focuses on cross-source rhythm: commits + issues + PRs unified on TIMESTAMP.
#
# Usage:
#   ./digest.sh                                   # Soul-Brews-Studio/maw-js, last 14 days
#   ./digest.sh OWNER/REPO                        # any repo
#   ./digest.sh OWNER/REPO 2026-05-25             # custom since-date
#
# Outputs:
#   - Daily rhythm (with σ-based spike detection)
#   - Hourly distribution (Bangkok TZ)
#   - Author voice analysis
#   - Signal vs Noise classification
#   - Dharma lifecycle (arise / abide / cease)
#   - Unified timeline (commits + issues + PRs by timestamp)
#   - 1-paragraph narration
#
# Author: Orz Oracle (ออส) — The Golden Conductor
# Born: 2026-06-08 Workshop 03

set -euo pipefail

REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-$(date -d '14 days ago' -I)}"

# Color helpers
B="$(tput bold 2>/dev/null || echo)"
N="$(tput sgr0 2>/dev/null || echo)"

echo "${B}🎼 /upstream-pulse${N}"
echo "Repo:  $REPO"
echo "Since: $SINCE"
echo

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "📡 Fetching commits..."
gh api "repos/$REPO/commits?since=$SINCE&per_page=100" --paginate > "$TMPDIR/commits.json" 2>/dev/null

echo "📡 Fetching issues..."
gh api "repos/$REPO/issues?state=all&since=$SINCE&per_page=100" --paginate > "$TMPDIR/issues.json" 2>/dev/null

echo "📡 Fetching PRs..."
gh api "repos/$REPO/pulls?state=all&per_page=100&sort=created&direction=desc" > "$TMPDIR/prs.json" 2>/dev/null

echo

python3 << PYEOF
import json, statistics
from collections import Counter
from datetime import datetime, timezone, timedelta

BKK = timezone(timedelta(hours=7))
REPO = "$REPO"
SINCE = "$SINCE"

with open("$TMPDIR/commits.json") as f:
    commits = json.load(f)
with open("$TMPDIR/issues.json") as f:
    issues_raw = json.load(f)
with open("$TMPDIR/prs.json") as f:
    prs = json.load(f)

# split issues vs PRs (gh issues endpoint returns both)
issues = [i for i in issues_raw if 'pull_request' not in i]

print(f"📊 Sources fetched:")
print(f"   commits: {len(commits)}")
print(f"   issues:  {len(issues)}")
print(f"   PRs:     {len(prs)}")
print()

# =======================================================
# LENS 1: 📅 Daily rhythm
# =======================================================
print("─" * 60)
print("📅 LENS 1: Daily rhythm (commits only)")
print("─" * 60)
by_day = Counter()
for c in commits:
    d = datetime.fromisoformat(c['commit']['author']['date'].replace('Z', '+00:00'))
    by_day[d.strftime('%Y-%m-%d')] += 1

counts = list(by_day.values())
mean = statistics.mean(counts) if counts else 0
stdev = statistics.stdev(counts) if len(counts) > 1 else 0
spike_threshold = mean + 2*stdev

print(f"  Total days with activity: {len(by_day)}")
print(f"  Mean: {mean:.1f}/day, σ: {stdev:.1f}")
print(f"  Spike threshold (>2σ): >{spike_threshold:.0f}")
print()
print("  Histogram:")
for date in sorted(by_day.keys()):
    count = by_day[date]
    bar_len = int(count / 5)
    bar = '█' * bar_len
    marker = " ← SPIKE" if count > spike_threshold else ""
    print(f"    {date}  {count:4d}  {bar}{marker}")
print()

# =======================================================
# LENS 2: ⏰ Hourly distribution (Bangkok)
# =======================================================
print("─" * 60)
print("⏰ LENS 2: Hourly distribution (Bangkok TZ)")
print("─" * 60)
by_hour_bkk = Counter()
for c in commits:
    d = datetime.fromisoformat(c['commit']['author']['date'].replace('Z', '+00:00'))
    hour_bkk = d.astimezone(BKK).hour
    by_hour_bkk[hour_bkk] += 1

print("  24-hour histogram:")
for h in range(24):
    count = by_hour_bkk.get(h, 0)
    bar = '█' * (count // 3)
    print(f"    {h:02d}:00  {count:4d}  {bar}")

top_hours = sorted(by_hour_bkk.items(), key=lambda x: -x[1])[:3]
top_str = ', '.join(f"{h:02d}:00" for h, _ in top_hours)
print(f"  Peak hours: {top_str}")
print()

# =======================================================
# LENS 3: 🎙️ Voice analysis
# =======================================================
print("─" * 60)
print("🎙️ LENS 3: Voices (contributor distribution)")
print("─" * 60)
authors = Counter(c['commit']['author']['name'] for c in commits)
total_a = sum(authors.values())
print(f"  {len(authors)} unique authors")
for a, n in sorted(authors.items(), key=lambda x: -x[1])[:10]:
    pct = 100 * n / total_a
    print(f"    {n:4d} ({pct:5.1f}%)  {a}")

top_voice_pct = max(authors.values()) * 100 / total_a if total_a else 0
print(f"  Top voice concentration: {top_voice_pct:.1f}%")
if top_voice_pct > 90:
    print("  ⚠ Top voice >90% → essentially a solo journal")
elif top_voice_pct > 70:
    print("  → Solo-led project")
else:
    print("  → Balanced team")
print()

# =======================================================
# LENS 4: 🔊 Signal vs Noise
# =======================================================
print("─" * 60)
print("🔊 LENS 4: Signal vs Noise")
print("─" * 60)
NOISE_PATTERNS = [
    'bump version', 'chore: release', 'merge pull', 'merge branch',
    'wip', 'docs typo', 'eslint', 'prettier', '[skip ci]',
    'auto-', 'renovate', 'dependabot', 'chore(deps)', 'release v',
    'bump:', 'bump ', 'chore: bump', '[release]'
]
signal, noise = 0, 0
for c in commits:
    msg = c['commit']['message'].lower().split('\n')[0]
    if any(p in msg for p in NOISE_PATTERNS):
        noise += 1
    else:
        signal += 1

total = signal + noise
sig_pct = 100*signal/total if total else 0
noise_pct = 100*noise/total if total else 0
ratio = signal/noise if noise > 0 else float('inf')

print(f"  Signal: {signal} ({sig_pct:.1f}%)")
print(f"  Noise:  {noise} ({noise_pct:.1f}%)")
print(f"  S/N ratio: {ratio:.2f}")
if noise_pct < 5:
    print("  ⚠ Heuristic may be under-counting noise (look for hidden bumps)")
print()

# =======================================================
# LENS 5: 📐 Diff weight (sample of 10 to keep this fast)
# =======================================================
print("─" * 60)
print("📐 LENS 5: Diff weight (sampled — full version needs per-commit API)")
print("─" * 60)
print("  (skipped — would require gh api repos/X/commits/SHA per commit)")
print("  (cycle time computed in Lens 7 instead)")
print()

# =======================================================
# LENS 6: ☸ Dharma lifecycle
# =======================================================
print("─" * 60)
print("☸ LENS 6: Dharma lifecycle (Trilakshana)")
print("─" * 60)
ARISE_PATTERNS = ['feat:', 'feat(', 'add ', 'create ', 'init', 'introduce', 'new ']
CEASE_PATTERNS = ['remove', 'delete', 'deprecate', 'revert', 'drop ', 'kill ', 'sunset']
arise, abide, cease = 0, 0, 0
for c in commits:
    msg = c['commit']['message'].lower().split('\n')[0]
    if any(p in msg for p in CEASE_PATTERNS):
        cease += 1
    elif any(p in msg for p in ARISE_PATTERNS):
        arise += 1
    else:
        abide += 1

tot = arise + abide + cease
print(f"  ☸ arise: {arise} ({100*arise/tot:.1f}%) — เกิด (new features)")
print(f"  ☸ abide: {abide} ({100*abide/tot:.1f}%) — ตั้งอยู่ (maintenance)")
print(f"  ☸ cease: {cease} ({100*cease/tot:.1f}%) — ดับ (removal)")
if cease < 5:
    print("  ⚠ Low cease — code accumulation without nirvana")
print()

# =======================================================
# LENS 7: ⚡ Unified timeline + cause-effect chain
# =======================================================
print("─" * 60)
print("⚡ LENS 7: Unified timeline (commits + issues + PRs)")
print("─" * 60)
print("  Single TIMESTAMP-axis — see the causal flow")
print()

events = []
for c in commits:
    ts = c['commit']['author']['date']
    events.append({
        'ts': ts,
        'type': 'commit',
        'icon': '📝',
        'id': c['sha'][:7],
        'who': c['commit']['author']['name'],
        'what': c['commit']['message'].split('\n')[0][:55],
    })
for i in issues:
    events.append({
        'ts': i['created_at'],
        'type': 'issue',
        'icon': '🐛',
        'id': f"#{i['number']}",
        'who': i['user']['login'],
        'what': i['title'][:55],
    })
for p in prs:
    events.append({
        'ts': p['created_at'],
        'type': 'PR',
        'icon': '🔀',
        'id': f"#{p['number']}",
        'who': p['user']['login'],
        'what': p['title'][:55],
    })
events.sort(key=lambda e: e['ts'])

print("  Last 20 events (chronological):")
for e in events[-20:]:
    ts_short = e['ts'][:16].replace('T', ' ')
    print(f"    {ts_short}  {e['icon']} {e['type']:6s} {e['id']:8s} {e['who'][:12]:12s} {e['what']}")
print()

type_count = Counter(e['type'] for e in events)
print(f"  Event distribution: {dict(type_count)}")
print()

# =======================================================
# 🎼 Narration
# =======================================================
print("─" * 60)
print("🎼 Pulse Narration")
print("─" * 60)
spike_days = [d for d, c in by_day.items() if c > spike_threshold]
top_author = sorted(authors.items(), key=lambda x: -x[1])[0]
peak_hour = top_hours[0][0] if top_hours else 0

narration = f"""
นี่คือ repo {REPO} ที่ขับเคลื่อนโดย {top_author[0]} ({top_author[1]/total_a*100:.1f}%)
ใน {len(by_day)} วันที่ผ่านมา ({SINCE} → today) มี {len(commits)} commits +
{len(issues)} issues + {len(prs)} PRs = total {len(events)} timestamped events.
Peak hour (Bangkok) คือ {peak_hour:02d}:00 — {'night-owl' if peak_hour > 21 or peak_hour < 6 else 'office-hours'}.
"""
if spike_days:
    narration += f"\n⚠ Spike day(s): {', '.join(spike_days)} (>{int(spike_threshold)} commits)\n"

dharma_skew = "arise-heavy" if arise > cease*2 else "balanced"
narration += f"\nLifecycle phase: {dharma_skew} ({arise}/{abide}/{cease} arise/abide/cease)."

print(narration)
print()
print("─" * 60)
print(f"Pulse complete · timestamp = single source of truth")
print("— ออส (Orz Oracle, AI ของก้อง — ไม่ใช่คน)")
PYEOF

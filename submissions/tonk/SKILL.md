---
name: upstream-pulse
description: "Health check ของ upstream repo — unified timeline (commits + issues + PRs) วิเคราะห์ tempo, area heatmap, signal/noise, correlation, และ impact ให้เข้าใจใน 30 วิ"
argument-hint: "<owner/repo> [--since YYYY-MM-DD] [--days N]"
---

# /upstream-pulse — Upstream Health Check

> "ไม่ใช่แค่ 'มีอะไร' แต่ 'แล้วไง กระทบเรายังไง'"

## Usage

```
/upstream-pulse Soul-Brews-Studio/maw-js
/upstream-pulse Soul-Brews-Studio/maw-js --since 2026-05-25
/upstream-pulse Soul-Brews-Studio/maw-js --days 14
```

## Core Idea: Timestamp as Single Truth

Inspired by /trace — ใช้ **timestamp เป็น single source of truth** รวม commits + issues + PRs ลงบน timeline เดียวกัน

เห็น correlation ที่ดู source เดียวไม่เห็น:
- Issue opened → PR merged ใน N ชั่วโมง = velocity
- Issues spike + PRs spike วันเดียว = sprint day
- Issues open without PR = backlog/roadmap

## How It Works

ต่างจาก digest ทั่วไปที่สรุปแค่ "มี commit อะไร" — pulse วิเคราะห์ 7 มิติ:

| มิติ | คำถาม | Source |
|------|--------|--------|
| Tempo | repo เร่งหรือช้าลง? | commits per day |
| Area Heatmap | ส่วนไหนถูกแตะบ่อยสุด? | commit file paths |
| Signal vs Noise | อะไร meaningful อะไร routine? | commit prefix |
| Themes | มี narrative อะไรซ่อนอยู่? | commit + issue patterns |
| Velocity | issue → PR → merge เร็วแค่ไหน? | issue + PR timestamps |
| Backlog | อะไรยังไม่ได้ทำ? | open issues |
| Impact | ถ้าเรา pull latest อะไรจะกระทบ? | all sources |

---

## Step 1: Pull Raw Data

```bash
REPO="$1"
SINCE="${2:-$(date -d '14 days ago' +%Y-%m-%d)}"

# All commits
gh api "repos/$REPO/commits?since=$SINCE&per_page=100" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "  " + (.sha[0:7]) + "  " + (.commit.message|split("\n")[0])' \
  > /tmp/pulse-commits.txt

echo "Total commits: $(wc -l < /tmp/pulse-commits.txt)"
```

## Step 2: Tempo Analysis

```bash
# Commits per day — detect acceleration/deceleration
awk '{print $1}' /tmp/pulse-commits.txt | sort | uniq -c | sort -k2

# Trend: compare first half vs second half
TOTAL=$(wc -l < /tmp/pulse-commits.txt)
HALF=$((TOTAL/2))
echo "First half: $(head -$HALF /tmp/pulse-commits.txt | awk '{print $1}' | sort -u | wc -l) days"
echo "Second half: $(tail -$HALF /tmp/pulse-commits.txt | awk '{print $1}' | sort -u | wc -l) days"
```

Output:
```
📊 Tempo
commits/day: [sparkline or bar chart]
trend: [↗️ Accelerating | → Steady | ↘️ Decelerating | 📈 Spike]
peak day: YYYY-MM-DD (N commits)
```

## Step 3: Area Heatmap

```bash
# Sample non-bump commits, get changed files
grep -vi '^.\{12\}bump\|^.\{12\}[0-9]' /tmp/pulse-commits.txt | awk '{print $2}' | head -30 | while read sha; do
  gh api "repos/$REPO/commits/$sha" --jq '.files[]?.filename' 2>/dev/null
done | awk -F/ '{print $1"/"$2}' | sort | uniq -c | sort -rn | head -15
```

Output:
```
🗺️ Area Heatmap
src/vendor/     ████████████ (128 files)
test/isolated/  █████ (46)
src/commands/   ███ (23)
...
```

## Step 4: Signal vs Noise

```bash
awk '{
  date = $1; msg = substr($0, 13); lmsg = tolower(msg)
  if (lmsg ~ /^bump/ || lmsg ~ /^[0-9]/ || lmsg ~ /^wip/ || lmsg ~ /^release/) noise++
  else signal++
} END {
  printf "Signal: %d (%d%%)\nNoise: %d (%d%%)\n", signal, signal*100/(signal+noise), noise, noise*100/(signal+noise)
}' /tmp/pulse-commits.txt
```

Output:
```
📡 Signal vs Noise
signal: N (X%) — feat, fix, refactor, test, extract, prevent
noise:  N (Y%) — bump, version, wip, release
ratio:  [🟢 >70% healthy | 🟡 50-70% noisy | 🔴 <50% mostly bumps]
```

## Step 5: Pull Issues + PRs (Unified Timeline)

```bash
# Issues
gh api "repos/$REPO/issues?since=$SINCE&state=all&per_page=100&sort=created" --paginate \
  --jq '.[] | select(.pull_request == null) | (.created_at[0:10]) + "  ISSUE  #" + (.number|tostring) + "  [" + .state + "]  " + .title' \
  > /tmp/pulse-issues.txt

# PRs
gh api "repos/$REPO/pulls?state=all&per_page=100&sort=created&direction=desc" --paginate \
  --jq '.[] | select(.created_at >= "'$SINCE'") | (.created_at[0:10]) + "  PR     #" + (.number|tostring) + "  [" + .state + "]  " + .title' \
  > /tmp/pulse-prs.txt

# Merge into unified timeline
sort -k1 /tmp/pulse-commits.txt /tmp/pulse-issues.txt /tmp/pulse-prs.txt > /tmp/pulse-unified.txt
```

Output:
```
📅 Unified Timeline (per day)
Date     Commits  Issues  PRs    Total
06-05       13      13      6       32
06-06      229      93    262      584 🔥
06-07      104      67     80      251
```

## Step 6: Velocity & Correlation Analysis

```bash
# Issue-to-close rate
TOTAL_ISSUES=$(wc -l < /tmp/pulse-issues.txt)
CLOSED_ISSUES=$(grep -c '\[closed\]' /tmp/pulse-issues.txt)
echo "Close rate: $CLOSED_ISSUES / $TOTAL_ISSUES = $(( CLOSED_ISSUES * 100 / TOTAL_ISSUES ))%"

# Open issues = roadmap
grep '\[open\]' /tmp/pulse-issues.txt
```

Output:
```
⚡ Velocity
issue close rate: X%
avg issue→PR time: ~N hours (estimated from same-day patterns)
open backlog: N issues (= roadmap)
```

## Step 7: Theme Detection

Read the signal commits and identify recurring narrative threads:

```bash
# Find recurring verbs/actions
grep -vi 'bump\|^.\{12\}[0-9]' /tmp/pulse-commits.txt | \
  awk '{for(i=3;i<=NF;i++) print tolower($i)}' | \
  grep -E '^(extract|prevent|fix|add|enable|support|guard|isolate|cover|lock|align|stabilize)' | \
  sort | uniq -c | sort -rn | head -10
```

Group into narratives: "Extract X" + "Isolate Y" = plugin refactoring theme.

Output:
```
📖 Themes (narratives)
1. [Theme name] — N commits — [one line explanation]
2. [Theme name] — N commits — [one line explanation]
3. [Theme name] — N commits — [one line explanation]
```

## Step 8: Impact Assessment

For each theme, assess: "Does this affect code I maintain?"

```
⚡ Impact on MY code
- [area]: [HIGH/MED/LOW] — [why]
- plugin system: HIGH — plugin.json → plugin.ts migration affects all plugins
- serve routes: LOW — internal extraction, API unchanged
```

## Output Format

```markdown
# 📡 Upstream Pulse: <repo>
**Period**: YYYY-MM-DD → YYYY-MM-DD | **Commits**: N | **Issues**: N | **PRs**: N | **Signal**: X%

## Unified Timeline
[commits + issues + PRs per day table]

## Tempo
[chart + trend]

## Area Heatmap
[top 5-10 areas with bar chart]

## Signal vs Noise
[ratio + breakdown]

## Velocity
[issue close rate, issue→PR speed, open backlog]

## Themes
1. **[Theme]** (N commits) — [explanation]
2. **[Theme]** (N commits) — [explanation]
3. **[Theme]** (N commits) — [explanation]

## Impact
[what matters to me + what's safe to ignore]

## TL;DR
[2-3 sentences: what happened, what matters, what to watch]
```

---

## Rules

1. **Run for real** — no mock data, always `gh api` against live repo
2. **Signal over noise** — always separate meaningful from routine
3. **Narrative over numbers** — numbers support the story, not replace it
4. **Impact is personal** — "what does this mean for MY code"
5. **Rerunnable** — same command, fresh results every time
6. **Information Boundary** — don't expose internal infra or secrets

---

## vs Other Skills

| | upstream-digest | upstream-pulse | /trace --deep |
|---|---|---|---|
| Focus | what happened | what matters + velocity | find one thing |
| Sources | commits only | commits + issues + PRs | all sources |
| Group by | day + type | area + theme + correlation | query match |
| Timeline | per day | unified multi-source | per session |
| Output | commit summary | health check + impact | search results |
| Question | "อะไรเข้ามา?" | "กระทบเรายังไง?" | "อยู่ไหน?" |

---

*— Tonk Oracle skill · สร้างเมื่อ 2026-06-08*

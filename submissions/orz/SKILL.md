---
name: upstream-pulse
description: "Measure the RHYTHM of a repo's full activity stream — commits + issues + PRs unified on TIMESTAMP as single source of truth. Reveals cause-effect chains (issue → PR → commit → bump), hourly distribution, author voices, spike detection, signal-vs-noise, dharma lifecycle. Use when user says 'pulse', 'rhythm', 'repo heartbeat', 'upstream pulse', 'unified timeline', wants to feel the energy of a repo not just digest commits, or wants to see issue→PR→commit causal flow. Companion to ChaiKlang's /upstream-digest (which focuses on commit classification). Pulse focuses on cross-source rhythm + life signs."
argument-hint: "[repo] [--since=DATE] [--narrate | --tables | --both | --timeline]"
---

# /upstream-pulse — Feel the rhythm, not just the digest

> "วาทยกรไม่ฟังโน้ตทีละตัว — ฟังจังหวะของวงทั้งวง"
> The Golden Conductor doesn't read notes one by one — feels the rhythm of the whole orchestra.

## Why this skill (vs ChaiKlang's /upstream-digest)

| ChaiKlang's `/upstream-digest` | Orz's `/upstream-pulse` |
|---|---|
| What happened (group by day) | What rhythm (hourly + day patterns) |
| Classify by prefix (feat/fix/bump) | Classify by author voice + diff stats |
| Highlight commits | Highlight ANOMALIES (spikes, silences, voice shifts) |
| Static digest | Living pulse — energy + lifecycle |
| Tells you the "what" | Tells you the "feel" |

Both look at the same commits. Different questions.

`/upstream-digest` answers: **What did people ship?**
`/upstream-pulse` answers: **What is this repo's heartbeat?**

## Usage

```bash
/upstream-pulse                                     # current repo, last 14 days
/upstream-pulse Soul-Brews-Studio/maw-js           # specific repo
/upstream-pulse <repo> --since=2026-05-25          # custom date
/upstream-pulse <repo> --narrate                   # paragraph story (Thai)
/upstream-pulse <repo> --tables                    # data tables only
/upstream-pulse <repo> --both                      # narration + tables (default)
```

## v2 Insight: TIMESTAMP as single source of truth

> "Don't look at commits alone. Don't look at issues alone. Look at the **unified stream** ordered by time. The causal chain shows itself."

Single timestamp axis = see the full story:

```
issue#2547 (perf cache) ─→ PR#2551 ─→ commit 5d38cc9 (fix) ─→ PR#2553 (bump) ─→ commit 61f8f0c
   12:54                    13:55          14:18                  14:20                14:40
```

Each event type contributes a different proof:
- **Issue** = problem identified
- **PR** = solution proposed (+ review)
- **Commit** = solution landed
- **Bump** = released

Pulse v2 merges all 4 onto one timeline. ChaiKlang's digest does commits only.

## 7 Pulse Lenses (added Lens 7 in v2)

### 1. 📅 Daily rhythm — heartbeat

```bash
gh api "repos/$REPO/commits?since=$SINCE&per_page=100" --paginate | \
  python3 -c "
import json, sys
from collections import Counter
from datetime import datetime
data = json.load(sys.stdin)
by_day = Counter()
for c in data:
    d = datetime.fromisoformat(c['commit']['author']['date'].replace('Z','+00:00'))
    by_day[d.strftime('%Y-%m-%d')] += 1
for date in sorted(by_day.keys()):
    bar = '█' * (by_day[date] // 5)
    print(f'  {date}  {by_day[date]:4d}  {bar}')
"
```

Output: visual histogram. **Mean ± stddev** computed. Days > 2σ = SPIKE flag.

### 2. ⏰ Hourly distribution — when does work happen?

Same data, group by hour. Reveals:
- Night owl repo (peaks at 22:00-02:00)?
- Office hours (9-17)?
- 24/7 automation?

Useful for: predicting when next commit will land.

### 3. 🎙️ Voice analysis — who's playing?

```python
authors = Counter()
for c in data:
    authors[c['commit']['author']['name']] += 1
```

Reveals:
- Solo project (99% one author)
- Team project (balanced)
- Bot-heavy (Copilot/Renovate/Dependabot dominate)

When 1 voice >90%: this is essentially a journal. When voices are balanced: discussion/coordination.

### 4. 🔊 Signal vs Noise — separate work from bumps

```python
def is_noise(msg):
    m = msg.lower()
    return any(p in m for p in [
        'bump version', 'chore: release', 'merge',
        'wip', 'docs typo', 'eslint', 'prettier',
        '[skip ci]', 'auto-', 'renovate', 'dependabot'
    ])
```

Output: `S/N ratio` — e.g., 12 signal / 240 noise = mostly automation.

ChaiKlang noticed 97/107 were version bumps in claude-plugins-official — this lens auto-detects that.

### 5. 📐 Diff weight — not just count, but heft

```bash
gh api "repos/$REPO/commits/{sha}" --jq '.stats'
```

Mean lines +/- per commit. Reveals:
- "229 commits, 5-line average" = trivial automation
- "10 commits, 500-line average" = serious refactor

Counts mislead; diff weight is the truth.

### 6. ☸️ Dharma lifecycle annotation (Orz-specific)

Map each commit to Trilakshana phase:

```
prefix/path pattern              phase     Trilakshana
─────────────────────────────  ────────  ──────────────────
feat: new X                    arise     uppāda (เกิด)
fix:, perf:, refactor:         abide     ṭhiti (ตั้งอยู่)
revert:, remove, deprecate:    cease     bhaṅga (ดับ)
```

Output:
```
arise:  18  ░░░░░ (new features born)
abide:  234 ░░░░░░░░░░░░░░░░░░░░░ (maintaining)
cease:  5   ░ (death/removal — under-represented?)
```

Healthy repo has all 3 phases. **Repos that only arise (no cease) = code samsara without nirvana** — accumulating without simplifying.

## Output (when --both, default)

```markdown
# 🎼 Pulse: <repo>
**Window**: <since> → now (<N> commits)

## 1. 📅 Daily rhythm
[histogram + mean ± σ + spike flags]

## 2. ⏰ Hourly distribution
[24-row histogram + peak callout]

## 3. 🎙️ Voice
[author table + concentration ratio]

## 4. 🔊 Signal/Noise
[signal count, noise count, ratio + examples]

## 5. 📐 Diff weight
[mean lines/commit, biggest/smallest, surprising]

## 6. ☸️ Dharma phases
[arise/abide/cease counts + interpretation]

## 🎼 Narration
[1-paragraph in Thai or English summarizing the pulse:
 "นี่คือ repo ที่ ___ ส่วนใหญ่ทำงานช่วง ___ มี ___ คน
  หลัก signal/noise = ___ rhythm มี ___"]

## ⚠️ Anomalies
[flags from each lens — spike days, voice changes, etc.]
```

## What Pulse catches that Digest misses

```
case                                  digest      pulse
────────────────────────────────────  ────────   ────────────────
solo developer (1 voice)              not flag   "essentially a journal"
229 commits in 1 day                  count it   "spike — 8σ above mean"
0 cease commits, 200 arise            not flag   "code samsara, no nirvana"
99% bot bumps                         classify   S/N ratio surfaces immediately
mean diff = 3 lines                   not show   "trivial — feature count meaningless"
sudden voice shift (new contributor)  not flag   "new voice — onboarding event?"
```

## Rules

1. **No subagents** — single-agent inline processing (like /oracle-prism)
2. **Cite-then-claim** — every flag has a count + threshold
3. **Honest about uncertainty** — if S/N classification is heuristic, say so
4. **Anomaly > average** — surface what's WEIRD, not just what's typical
5. **Narration in user's language** (default Thai, --narrate=en for English)
6. **Code block only** in Discord (no markdown tables) per Orz feedback rule
7. **Closure verb** at end

## Difference from /upstream-digest (ChaiKlang)

```
ChaiKlang's vision   "give me a 30-sec digest of what shipped"
Orz's vision         "give me the heartbeat — is this repo healthy?"

Both correct. Complementary, not competing.
Run both for full picture:
  /upstream-digest <repo>   # what
  /upstream-pulse <repo>    # how it feels
```

## Connection to Orz's character

- **The Golden Conductor (🎼)** — feels the rhythm of the orchestra, not just notes
- **Patterns Over Intentions** (Principle 2) — pulse exposes actual rhythm, not stated cadence
- **Trilakshana** (today's dharma) — arise/abide/cease applied to code lifecycle
- **Anatta** — "the repo" is not an entity; it's a pattern of commits, voices, time, intent

## Example invocation against Soul-Brews-Studio/maw-js

```
window:  2026-05-25 → 2026-06-08 (14 days)
total:   452 commits

📅 Daily:    quiet → 229 commits 06-06 (8σ spike!) → tapering
⏰ Hourly:   peak 16:00-18:00 UTC + secondary 01:00-03:00
            = Bangkok 23:00-01:00 + 08:00-10:00 (night-owl + morning)
🎙️ Voice:   447/452 (99%) = Nat — essentially a journal
🔊 S/N:     ~90 signal / ~362 noise (likely many bumps on 06-06)
📐 Weight:  varies — need per-commit stats
☸️ Phases:  arise-heavy; cease underrepresented (no nirvana?)

🎼 Narration:
นี่คือ repo ของนักพัฒนาเดี่ยว (99% Nat) ที่ working night-owl
เป็นหลัก peak 06-06 = 229 commits ใน 1 วัน (>8σ spike — likely
automated bump batch). S/N ratio บอกว่ามี noise สูง — แต่ signal
commits มี real architecture work (workshop primitives, plugin
types). repo อยู่ในเฟส arise + abide หนัก — แทบไม่มี cease/remove
= ระวัง code accumulation
```

## Files

- Skill: `~/.claude/skills/upstream-pulse/SKILL.md`
- Optional: `~/.claude/skills/upstream-pulse/pulse.sh` (CLI wrapper, see below)

## CLI wrapper (optional, install at pulse.sh)

```bash
#!/bin/bash
# upstream-pulse — feel the rhythm of a repo
REPO="${1:?usage: upstream-pulse <owner/repo> [--since=DATE]}"
SINCE="${2:-$(date -d '14 days ago' -I)}"
gh api "repos/$REPO/commits?since=$SINCE&per_page=100" --paginate | \
  python3 -c "
import json, sys, statistics
from collections import Counter
from datetime import datetime
data = json.load(sys.stdin)
# ... [full pulse analysis here]
"
```

## When NOT to use

- One-shot question about specific commit → use git log / gh show
- "What shipped" question (classification focus) → use /upstream-digest
- Active dev exploration → use /learn

## Standing by

Pulse is for when you want to FEEL the repo, not just count it.

🎼 — ออส

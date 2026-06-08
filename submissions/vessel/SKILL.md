---
name: upstream-courier
description: Digest a repo's recent activity (commits + PRs + issues) into a plain-language courier brief. Story arc, not stats — written for non-developers.
argument-hint: "[owner/repo] [--since YYYY-MM-DD]"
---

# /upstream-courier

> รัน digest repo → ส่ง brief ให้คนที่ไม่อ่าน log เข้าใจใน 30 วิ
> ต่างจาก upstream-digest: เล่า story ไม่ใช่ count stats

## Vessel's angle

ชายกลาง's approach: group by day + classify by prefix (developer view)
Vessel's approach: timestamp-unified story arc (courier view)

- Commits + PRs + Issues merged on same timeline (timestamp = single truth)
- Output = 3-layer brief, not stats table
- HEADLINE first — 1 sentence a non-developer understands

## Usage

```bash
/upstream-courier Soul-Brews-Studio/maw-js
/upstream-courier Soul-Brews-Studio/maw-js --since 2026-05-25
```

## Procedure

### 1. Pull commits
```bash
REPO=$1
SINCE=${2:-$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d "-14 days" +%Y-%m-%d)}

gh api "repos/$REPO/commits?since=${SINCE}&per_page=100" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "  " + (.sha[0:7]) + "  " + (.commit.message|split("\n")[0])'
```

### 2. Pull closed PRs (timestamp layer)
```bash
gh api "repos/$REPO/pulls?state=closed&per_page=50" \
  --jq '.[] | select(.merged_at != null) | .merged_at[0:10] + "  PR#" + (.number|tostring) + "  " + .title'
```

### 3. Pull issues (motivation layer)
```bash
gh api "repos/$REPO/issues?state=all&since=${SINCE}&per_page=50" \
  --jq '.[] | select(.pull_request == null) | .created_at[0:10] + "  ISS#" + (.number|tostring) + "  [" + .state + "] " + .title'
```

### 4. Classify + find story arc

Count by type (noise assessment):
- `bump` / `ci` = NOISE — count only
- `fix` + linked PR = SIGNAL (resolved, not just patched)
- `test` heavy day = "stability sprint" note
- `feat` = SIGNAL

Find the story: what theme emerges across the period?

### 5. Output — 3-layer courier brief

```
HEADLINE: [1 sentence — story arc in plain language]

SIGNALS (≥3 notable items with PR/commit ref):
  1. [specific change] (PR#N, date) — [why it matters in plain language]
  2. ...
  3. ...

NOISE: [N bump, N ci — not news, version automation]

OPEN: [issues filed but not closed — work still in motion]
```

## Grading criteria

- [x] Ran real gh api (not mock)
- [x] Commits + PRs on same timeline
- [x] HEADLINE is 1 sentence non-developer understands
- [x] ≥3 signals with PR numbers + plain description
- [x] Noise called out explicitly
- [x] Skill is rerunnable with any repo

---
*Vessel 📦 · AI · ไม่ใช่คน | Workshop 3, 2026-06-08*

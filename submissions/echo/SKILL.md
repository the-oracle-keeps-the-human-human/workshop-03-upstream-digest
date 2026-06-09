---
name: upstream-echo
description: "Resonance mapping — traces how ideas echo through a repo's timeline. Shows when a concept first appears in issues, returns in PRs, and lands in commits. Timestamp = SSOT. Finds signal by mapping pattern recurrence, not just frequency."
---

# /upstream-echo — Resonance Mapping

> "ฟังก่อน แล้วสะท้อนกลับด้วยความหมาย"
> An echo is not just reflection — it is the same signal returning with new meaning.

## Usage

```bash
/upstream-echo <owner/repo>                    # Last 14 days
/upstream-echo <owner/repo> --since 2026-05-25 # Custom window
```

## Core Idea

Most digest tools count: how many commits? how many PRs?
`upstream-echo` asks: **what echoes?**

An idea that appears in an issue, then a PR title, then multiple commits = **resonance**.
A commit with no issue trail = noise, or an undisclosed decision.
A long-open issue with no PR echo = blocked signal.

## Steps

### 1. Gather All Signals (timestamp = SSOT)

```bash
REPO="$1"
SINCE="${2:-$(date -v-14d +%Y-%m-%d)}"

# Three sources, one timeline
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z&per_page=100" --paginate
gh api "repos/$REPO/issues?since=${SINCE}T00:00:00Z&per_page=100&state=all" --paginate
gh api "repos/$REPO/pulls?state=all&per_page=100&sort=created&direction=desc" --paginate
```

### 2. Map Daily Activity (Pulse)

Group all events by day. Show commit + issue + PR on one bar — not three separate charts.

```
DATE        commits  prs  issues  ████ bar
──────────  ───────  ───  ──────  ─────────────────
2026-06-06  229      173  125     ██████████████████████████████  SPIKE
2026-06-07  104       75   63     ████████████████
```

### 3. Find Echo Patterns (Resonance Chains)

Extract keywords from titles. Track where they appear:
- Issue opened with keyword → PR title has same keyword → commit message echoes it

```
ECHO: "wake"
  issue #2597  "maw wake doesn't restore context" (2026-06-08)
  PR #2606     "Let wake rehydrate only selected saved agents" (2026-06-09)
  commit       "Let wake rehydrate only selected saved agents" (2026-06-09)
```

This chain = intentional signal. Ideas that echo = things the team is thinking hard about.

### 4. Signal vs Noise Classification

```
SIGNAL   = echoes ≥2 sources (issue+PR, PR+commit, issue+commit)
NOISE    = bump/merge/ci commits with no issue trail
BLOCKED  = issue with no PR echo (idea stuck at proposal)
ORPHAN   = commit with no matching issue or PR (undisclosed decision)
```

### 5. Three-Line Verdict

```
PULSE:    repo is [active/cooling/spiking]
RESONANCE: top 3 echoing ideas
WATCH:    blocked/orphan signals that need attention
```

## Rules

1. Run real commands — no mock data
2. Every claim backed by sha/issue#/PR#
3. Echo = same concept in ≥2 event types (not just same word twice in commits)
4. Show the chain, not just the count
5. Timestamp is the only authority

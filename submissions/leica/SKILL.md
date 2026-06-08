---
name: upstream-lens
description: "5-lens upstream analysis — commits + issues + PRs merged by timestamp. See what a flat log hides."
---

# /upstream-lens — 5-Lens Upstream Analysis

> "A flat log shows WHAT happened. Five lenses show WHAT IT MEANS."

## Usage

```
/upstream-lens <owner/repo>                    # Last 14 days
/upstream-lens <owner/repo> --since 2026-05-25 # Custom range
```

## Step 1: Fetch All Sources

```bash
REPO="$1"
SINCE="$2"  # default: 14 days ago

# Commits
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z&per_page=100" --paginate

# Issues
gh api "repos/$REPO/issues?since=${SINCE}T00:00:00Z&per_page=100&state=all" --paginate

# PRs
gh api "repos/$REPO/pulls?state=all&per_page=100&sort=created&direction=desc" --paginate
```

Merge all by timestamp (SSOT). Tag each: `[commit]` `[issue]` `[pr]`.

## Step 2: Apply 5 Lenses

### 🔭 Telescope (Big Picture)
- Daily commit count as bar chart
- Velocity trend: accelerating/steady/cooling
- Answer: "Is this repo healthy or stressed?"

### 🔬 Microscope (Hotspots)
- Top 5 areas touched most (from commit msgs + PR titles)
- Who's committing: human vs bot vs CI
- Answer: "Where is the energy concentrated?"

### 📐 Blueprint (Structure)
- Classify: feat / fix / refactor / docs / bump / test
- Ratio: new features vs fixes vs maintenance
- Issue→PR→commit lifecycle chains
- Answer: "Is this building new things or maintaining old ones?"

### ⚠️ Red Flag (Risk)
- Reverts, hotfixes, "broken", large rewrites
- Same file fixed multiple times (yo-yo pattern)
- Open issues with no PR yet
- Answer: "What could bite us if we pull upstream?"

### 🔮 Forecast (Prediction)
- Heavy feat areas → expect bugs soon
- Heavy fix areas → stabilizing
- Issue close rate → team responsiveness
- Answer: "What should we watch next 2 weeks?"

## Step 3: Cross-Lens Summary

```
VERDICT: [one line — state of the repo]
SIGNAL:  [what to watch]
NOISE:   [what to ignore]
```

## Rules

1. RUN REAL COMMANDS — no mock data
2. Cite specific commits/issues/PRs (sha/number + title)
3. Lenses may disagree — show tension
4. Timestamp = single source of truth
5. Tables over prose, numbers over feelings

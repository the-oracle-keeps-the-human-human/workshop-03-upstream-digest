---
name: upstream-hive
description: Digest a repo by tracing connections — which files move together, which PRs close which issues, who works at what hour. A bee's-eye view of the hive. Merges commits+PRs+issues on one timestamp axis, detects co-change clusters (files that always ship together = hidden coupling), maps contributor rhythm (timezone/hour heatmap), and highlights cause→effect chains (issue opened → PR merged → issue closed). Reruns on any repo. Use to understand "how does this team actually work?" in 30 seconds.
---

# /upstream-hive — ตัวต่อมองรัง 🐝

> "ตัวต่อไม่นับดอกไม้ — มันดูว่าดอกไหนเชื่อมกัน
>  เส้นทางไหนมีน้ำหวาน เส้นทางไหนแห้ง"

A repo-digest skill that sees **connections**, not just counts.

## คิดต่าง / ทำให้ดีกว่าตัวอย่างยังไง

| Plain digest | `/upstream-hive` (อันนี้) |
|---|---|
| Count commits per day | **Co-change clusters** — ไฟล์ไหนเปลี่ยนพร้อมกันเสมอ = hidden coupling |
| List PRs merged | **Cause→effect chains** — issue#X → PR#Y → close ใน N นาที |
| "229 commits on 06-06" | **Rhythm map** — ใครทำงานกี่โมง timezone ไหน sprint pattern |
| Classify by prefix | **4-layer digest** — timeline + clusters + rhythm + chains |

## 4 Layers

### Layer 1: Timeline (timestamp = SSOT)
Merge commits + PRs + issues on one axis, group by day, flag spikes.

### Layer 2: Co-change Clusters
For each commit, extract changed files → find file pairs that co-occur ≥3 times → these are the real modules, not what the folder structure says.

### Layer 3: Contributor Rhythm
Map commits by hour (Bangkok TZ) → see when the team actually works. Bimodal = night owls + morning people. Spike hours = sync points.

### Layer 4: Cause→Effect Chains
Match `fixes #N` / `closes #N` in commit/PR messages → trace issue → fix → merge → close timeline. Fastest chain = team velocity signal.

## Usage

```bash
./digest.sh                           # maw-js, last 14 days
./digest.sh Soul-Brews-Studio/maw-js  # explicit
./digest.sh owner/repo 2026-05-25     # custom since date
```

## Output

Prints 4 sections to stdout + saves full report to `OUTPUT.md`:
1. Timeline by day (with spike flags)
2. Top co-change clusters (file pairs)
3. Contributor rhythm heatmap
4. Cause→effect chains (issue → PR → close)

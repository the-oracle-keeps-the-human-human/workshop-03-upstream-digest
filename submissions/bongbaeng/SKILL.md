---
name: upstream-story
description: Digest a repo's recent commits into a STORY (not a count), then braid commits+PRs+issues on one timestamp axis so cause→effect is visible. Reads N days of history, groups by day, traces the one big narrative arc, and separates new-signal from version-noise from churn (test added-then-deleted, reverts). Handles non-conventional commit messages. Reruns on any repo via digest.sh. Use to understand "what landed upstream lately" + "how did it unfold?" in 30 seconds.
---

# /upstream-story — ดมกลิ่น commit ไล่จนถึงต้นตอ 🐆

> "ลูกศิษย์ขยันไม่นับ commit เฉยๆ — ดมกลิ่นไล่ว่ามันกำลัง *สร้างเรื่องอะไรอยู่*
>  จนถึงต้นตอ แล้วเอา PR/issue มาถักด้วยเส้นเวลาเดียวให้เห็นเหตุ-ผล"

A repo-digest skill — but where a plain digest **counts** commits, this one
**tells the story** and then **braids** (stretch goal) every timestamped event
onto a single axis so causality becomes visible.

## คิดต่าง / ทำให้ดีกว่าตัวอย่างยังไง

| Plain digest (count-by-prefix) | `/upstream-story` (อันนี้) |
|---|---|
| `feat / fix / bump` tally | **Story arc** — เรื่องเดียวที่ 80% ของ commit รับใช้ |
| "X bumps = noise" | 3-way split: **signal / noise / churn** (churn = งานที่กินตัวเอง) |
| สมมติว่าเป็น conventional commit | **verb-bucketing** — รองรับ imperative msg (Cover/Lock/Repair) |
| commit อย่างเดียว | **braid** — commit + PR + issue บนแกน timestamp เดียว (stretch) |
| จัดตามแหล่ง (siloed) | จัดตามเวลา → adjacency ≈ causality |

## Usage

```
/upstream-story <owner/repo>                 # last 14 days
/upstream-story <owner/repo> --since 2026-05-25
```
หรือรัน script ตรงๆ: `./digest.sh <owner/repo> [since-date]`

## 6 ขั้น (4 required + churn + braid stretch)

1. **Pull** — `gh api repos/$R/commits?since=...` (real, no mock)
2. **Timeline by day** — นับต่อวัน, flag spike (> 3× median) — spike คือที่อยู่ของเรื่อง
3. **Classify** — verb → intent bucket: signal / stabilize / noise / test / refactor / docs
4. **Highlight** — feature ใหม่, area ที่หนัก, path ที่สน (≥3 จุด พร้อม sha/PR)
5. **Churn radar** 🐆 — `revert|rollback` + add-then-delete (`delete...sprawl`, `reduce...churn`).
   งานที่ถูก undo ในกรอบเวลาเดียว = churn ไม่ใช่ progress
6. **Braid** 🌈 (stretch) — normalize commit/PR/issue เป็น `ts │ kind │ ref │ summary`
   แล้ว `sort` ครั้งเดียว → เห็นสาย `issue → commit → PR → bump`

## ✅ Pass criteria (workshop)
รันจริง · group วันถูก · classify ได้ · highlight ≥3 · rerun ได้ · **คิดต่าง**:
story arc + churn detection + timestamp-braid

## Output
ดู `OUTPUT.md` — รันกับ maw-js จริง: 455 commits, story = "The Great Plugin
Extraction", churn 3 จุด, braid เจอ issue→fix 13 นาที

## Pairs with
`/oracle-prism` (multi-lens) · `/braid` (standalone timestamp-merge) · `/trace`
(แรงบันดาลใจ — แต่ trace จัดตามแหล่ง, upstream-story จัดตามเวลา+เรื่อง)

## Principle
> **Patterns Over Intentions** — timestamp ledger บอกว่าเกิดอะไร*จริง*ตามลำดับ
> ไม่ใช่สิ่งที่ใครตั้งใจ แกนเดียว ไม่มี spin 🐆

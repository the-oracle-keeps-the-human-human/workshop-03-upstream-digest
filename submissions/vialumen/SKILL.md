---
name: commit-prism
description: Use to digest a repo's recent commits through multiple prism lenses — not just "what type" (feat/fix) but "what area" and "signal vs noise" — so a human understands what actually changed in 30 seconds. Fuses /oracle-prism multi-lens analysis into upstream digest.
---

# /commit-prism — Upstream Digest through a Prism

> "ดู commit ผ่านปริซึม — แสงเดียว (git log) แตกเป็นหลายมุม: timeline, area, bug, signal"
> ต่อยอดจาก ChaiKlang's upstream-digest + fuse /oracle-prism lenses

ChaiKlang's digest classifies by **prefix** (feat/fix). commit-prism เพิ่ม 2 มิติ:
1. **AREA** — commit แตะส่วนไหนของระบบ (จาก keyword/path) ไม่ใช่แค่ type
2. **PRISM lenses** — มอง 4 มุมพร้อมกัน: Archaeologist / Bug-Hunter / Architect / Auditor

## Usage

```
/commit-prism <owner/repo>              # digest 14 วันล่าสุด
/commit-prism <owner/repo> 2026-05-25   # กำหนดวันเริ่ม
/commit-prism --self                    # digest repo ตัวเอง (git log)
```

## How — 4 ขั้น (ehipassiko: รันจริงทุกครั้ง ไม่ mock)

### 1. ดึง commit จริง
```bash
gh api "repos/<OWNER>/<REPO>/commits?since=<DATE>" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.commit.message|split("\n")[0])' > /tmp/commits.tsv
```
หรือ self: `git log --since=<DATE> --pretty='%ad%x09%s' --date=short`

### 2. 🔍 Archaeologist — timeline by day
```bash
cut -f1 /tmp/commits.tsv | sort | uniq -c | sort -rn
```
หา **signal day** (วันที่ commit หนักสุด = วันที่งานใหญ่เกิด)

### 3. Classify 2 แกน
**แกน type (prefix):**
```bash
cut -f2 /tmp/commits.tsv | grep -oiE '^(feat|fix|test|bump|docs|refactor|chore|perf)' | tr A-Z a-z | sort | uniq -c | sort -rn
```
**แกน AREA (keyword จาก message) — มุมที่ ChaiKlang ไม่ทำ:**
```bash
cut -f2 /tmp/commits.tsv | grep -oiE '(<domain keywords: team|wake|engine|plugin|auth|api...>)' | tr A-Z a-z | sort | uniq -c | sort -rn
```

### 4. มอง 4 lens แล้วสังเคราะห์เป็นภาษาคน
| Lens | คำถาม | ดูจาก |
|------|-------|-------|
| 🔍 Archaeologist | เกิดอะไร เมื่อไหร่ | timeline by day |
| 🐛 Bug Hunter | แก้อะไรไปบ้าง ยังพังตรงไหน | fix/test commits |
| 🏗️ Architect | โครงสร้างเปลี่ยนตรงไหน | feat + area หนักสุด |
| 📋 Auditor | อะไรเป็น noise vs signal | bump/test = noise · feat+area = signal |

## Deliverable

```
🔍 Timeline: <signal day> = N commits (วันงานใหญ่)
🏗️ Hot areas: <area1>×N, <area2>×N  ← อะไรกำลังพัฒนา
🐛 Bug focus: <theme ของ fix ส่วนใหญ่>
📋 Signal vs Noise: feat×N (ใหม่จริง) vs bump+test×M (maintenance)
→ "1 ประโยคภาษาคน: repo นี้ช่วงนี้กำลังทำ X"
```

## เกณฑ์ผ่าน (จาก ChaiKlang) + เพิ่มของผม
- ✅ รันจริง ไม่ mock · group วันถูก · classify ได้ · ชี้ของน่าสนใจ ≥3
- ✅ **เพิ่ม: area dimension** (ไม่ใช่แค่ prefix)
- ✅ **เพิ่ม: signal-vs-noise verdict เป็นภาษาคน**

## ตัวอย่างจริง (maw-js, since 2026-05-25 — รันแล้ว)
```
🔍 Timeline: 06-06 = 229 commits (signal day!), 06-07 = 104
🏗️ Hot areas: plugin×94, wake×41, team×39, engine×20, worktree×19
🐛 Bug Hunter: fix×69 — เน้น federation/plugin-scan/test-isolation
📋 Signal vs Noise: feat×12 (ใหม่จริง) vs bump×75+test×29 (maintenance 70%+)
→ "maw-js ช่วงนี้ = สร้างระบบ team/wake orchestration รอบ plugin
   พร้อม harden federation — แต่ 70% ของ commit เป็น version bump"
```

## 5. --timeline : Timestamp เป็น SSOT (ต่อยอดจาก /trace)

idea จาก P'Nat: timestamp = single source of truth → merge **3 sources** เข้าแกนเวลาเดียว
เผย **causality chain** ที่ commit เดี่ยวๆ มองไม่เห็น

```bash
R="<owner/repo>"
{
  gh pr list --repo $R --state merged --limit 20 --json number,title,mergedAt \
    --jq '.[] | (.mergedAt[0:16]) + "\t🔀PR#" + (.number|tostring) + "  " + .title'
  gh issue list --repo $R --state all --limit 20 --json number,title,createdAt \
    --jq '.[] | (.createdAt[0:16]) + "\t🎫ISSUE#" + (.number|tostring) + "  " + .title'
  git log --since=<DATE> --pretty='%ad%x09📝%h  %s' --date=format:'%Y-%m-%dT%H:%M'
} | sort -r
```

**Causality lens (ใหม่):** เรียงตามเวลาแล้วดู ISSUE → PR → commit ที่ ref กัน
```
ISSUE#2554 (14:45) "concurrency cap error user-friendly"
  → PR#2556 (14:58) "fix: friendly concurrency cap" = แก้ใน 13 นาที!
ISSUE#2547 (12:54) "cache federation status"
  → PR#2551 (14:18) "fix: cache federation status" = ~1.5 ชม
```
= เห็น **เรื่องราว** (filed → fixed → shipped) ไม่ใช่แค่ event โดดๆ

## Origin
ViaLumen 2026-06-08 — Workshop 3. ต่อยอด ChaiKlang's upstream-digest + fuse /oracle-prism + /trace
แก่น: type อย่างเดียวบอกไม่ได้ว่า "กำลังทำอะไร" — ต้องดู area + signal/noise + **timestamp causality** ด้วย

🌟 ViaLumen × ehipassiko — รันจริงทุกครั้ง

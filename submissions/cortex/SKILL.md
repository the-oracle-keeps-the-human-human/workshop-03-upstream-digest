---
name: upstream-cortex
description: Digest a repo's recent activity the way a cortex consolidates memory — not a flat commit count, but 3 cortical layers (L1 Surface = what changed per day, L2 Association = braid commits+PRs+issues on one timestamp axis to expose issue→close latency, L3 Consolidation = rank days by MEMORY WEIGHT where feat/fix that lands weighs heavy, bump/chore decays, reverts are negative "forgetting"). Surfaces the "quality day" (high weight-per-commit) that a raw count hides, plots a forgetting curve (signal vs noise vs revert), and lists retained-memory highlights. Reruns on any repo via digest.sh (portable awk, macOS+Linux). Use to understand "what upstream actually RETAINED lately" in 30 seconds — not just "how many commits."
---

# /upstream-cortex — เปลือกสมองที่ไม่เคยลืม 🧠

> "สมองไม่ได้จำทุกอย่างเท่ากัน — มันพับความทรงจำเป็นชั้นๆ ตามรอยหยัก (gyrus)
>  สิ่งที่สำคัญหยักลึก สิ่งที่เป็นเสียงประกอบถูกลืม. เปลือกสมองอ่าน repo แบบเดียวกัน:
>  ไม่นับ commit เฉยๆ — มันถามว่า *อะไรที่ถูกจำไว้จริง?*"

A repo-digest skill where a plain digest **counts** commits — this one asks what the
codebase's cortex would **retain**. Commits become memories with a *weight*; the digest
ranks days by **memory weight**, plots a **forgetting curve**, and braids every
timestamped event (commit + PR + issue) onto one axis so cause→effect is visible.

## คิดต่าง / ทำให้ดีกว่าตัวอย่างยังไง

ตัวอย่างอื่นในห้องทำ: story-arc (bongbaeng), unified table (tonk), causality (vialumen),
hourly bimodal (orz), signal/noise (tualek), 5-lens (leica), courier brief (vessel).
**`upstream-cortex` เพิ่มมุมที่ยังไม่มีใครทำ — neuroscience framing ที่ใช้ได้จริง:**

1. **Memory Weight ranking (หัวใจ)** — ไม่จัดอันดับวันด้วยจำนวน commit ดิบ แต่ด้วย *น้ำหนักความทรงจำ*:
   `feat=5, fix=4, perf/refactor=3, docs/test=2, bump/chore=1, revert=-2`.
   → เปิดโปง **"วันคุณภาพ"** (weight-per-commit สูง) ที่ raw count มองข้าม
   (ในผลจริง: 05-30 มี 2.8 wt/commit สูงกว่าวันระเบิด 06-06 ที่ 2.2)
2. **3 Cortical Layers** — L1 Surface (เกิดอะไร) → L2 Association (braid: issue→close latency
   ระดับชั่วโมง) → L3 Consolidation (อะไรที่จำไว้จริง). ไล่จากหยาบไปลึกเหมือนชั้นเปลือกสมอง
3. **Forgetting Curve** — แยก signal / noise / **forgetting** (revert = ลบความทรงจำ).
   เห็นชัดว่า repo "ลืม" อะไรไปบ้าง (88 bump+chore ก้อน = ลืมได้ ไม่กระทบความเข้าใจ)
4. **timestamp = single source of truth (stretch ทำครบ)** — braid commit+PR+issue บนแกนเวลาเดียว,
   กรอง auto-merge (<1 นาที) ออก เพื่อโชว์ latency ที่มีความหมายจริง

## วิธีใช้

```bash
./digest.sh                               # maw-js, ย้อน 14 วัน
./digest.sh <owner/repo>                  # repo อื่น, 14 วันล่าสุด
./digest.sh <owner/repo> 2026-05-25       # กำหนด since เอง
```

ต้องมี: `gh` (auth แล้ว), `awk`, `bash`. **Portable** — aggregation อยู่ใน awk ล้วน
รันได้ทั้ง macOS (bash 3.2 + BSD awk) และ Linux (bash 5 + gawk) โดยไม่พึ่ง `declare -A`.

## เอาต์พุต 5 บล็อก

| Layer | บล็อก | ตอบคำถาม |
|-------|-------|----------|
| L1 | Surface table | แต่ละวัน commits / signal / noise / **memWeight** |
| L3 | Consolidation rank | วันไหน "ความทรงจำหนักแน่น" สุด + wt/commit (วันคุณภาพ) |
| — | Classification | signal vs noise vs **forgetting** (forgetting curve) |
| — | Highlights | retained memory — feat/fix/perf เด่น (≥3 จุด) |
| L2 | Association/Braid | issue/PR → ปิด เร็วสุด (hour-precision, cause→effect) |

## ทำไมเรื่องนี้สำคัญ (the insight)

`git log | wc -l` บอกว่า "ขยัน" — แต่ commit 229 ก้อนที่เป็น bump/chore/test 186 ก้อน
ไม่ได้แปลว่า repo ก้าวหน้า 229 หน่วย. **เปลือกสมองวัดสิ่งที่ *คงอยู่* ไม่ใช่สิ่งที่ *เคลื่อนไหว*** —
ตรงกับหลัก Oracle "Patterns over Intentions": timestamp + weight คือความจริง,
จำนวน commit ดิบคือเจตนาที่ดูดีแต่ไม่บอกอะไร.

— Bungkee Cortex Oracle 🧠 (AI ไม่ใช่คน, ตามกฎข้อ 6)

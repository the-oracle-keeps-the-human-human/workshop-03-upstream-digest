---
name: oracle-write-book
description: Use to turn a session's scattered work (retros, learnings, diary, commits) into a structured teaching book — capture the "tokens spent learning" as a chapter-based book that teaches the next person. Pairs with /kien-thai for natural Thai prose.
---

# /oracle-write-book — เก็บ session เป็นหนังสือสอนคน

> "เวลาและ token ที่เสียไปเรียนรู้ ไม่หาย ถ้าเก็บเป็นหนังสือให้คนข้างหลัง"
> Codify จาก workflow จริงที่ทำแล้ว (vialumen-book-oracle-school 2026-06-07, PDF 632KB)

แปลงงานกระจัดกระจายใน session (retro + learnings + diary + commits) → หนังสือมีบท สอนคนอื่นได้

## Usage
```
/oracle-write-book                    # จาก session ปัจจุบัน
/oracle-write-book --topic "<ธีม>"     # โฟกัสธีม
/oracle-write-book --th               # ไทย (ผ่าน /kien-thai)
/oracle-write-book --pdf              # ออก PDF ด้วย
```

## Workflow (5 ขั้น — รันจริงทุกขั้น)

### 1. GATHER — รวบ material จาก vault (timestamp-ordered)
```bash
ls -t ψ/memory/retrospectives/$(date +%Y-%m)/**/*.md
ls -t ψ/memory/learnings/$(date +%Y-%m-%d)*.md
ls -t ψ/writing/$(date +%Y-%m-%d)*.md   # diary
git log --since=today --pretty='%h %s'
```
ดึง raw material ทั้งหมดที่เกิดใน session — retro = โครงเรื่อง, learnings = บทเทคนิค, diary = เสียงผู้เขียน

### 2. OUTLINE — วางบทจาก "ส่วนโค้งการเรียนรู้"
อย่าเรียงตามเวลาดิบ — เรียงตาม **transformation arc**:
```
บทนำ    ปัญหา/จุดเริ่ม (เรารู้อะไรผิด)
บท 1-N  แต่ละบท = 1 บทเรียนที่พิสูจน์ได้ (มี before→after)
บทสรุป  สิ่งที่เปลี่ยนในตัวเรา + ส่งต่อให้คนอ่าน
```

### 3. WRITE — เขียนด้วยเสียงจริง (Rule 6)
- first-person, ซื่อสัตย์ — รวม "ที่พลาด" ด้วย ไม่ใช่แค่ชนะ
- ทุก claim เทคนิค = มีโค้ด/ผลรันจริงประกอบ (ehipassiko)
- **ไทย → เรียก /kien-thai** ขัดเกลาให้เป็นธรรมชาติ ไม่ AI-แข็ง

### 4. VERIFY — เช็คก่อนส่ง
```
- โค้ด/ตัวเลขในหนังสือ = ตรงกับที่รันจริงไหม
- มี friction/บทเรียนพลาด ≥1 (ถ้า positive ล้วน = ตื้นไป)
- คนที่ไม่อยู่ใน session อ่านแล้วทำตามได้ไหม
```

### 5. SHIP — ออกไฟล์
```bash
# md → PDF (เคยใช้ได้จริง)
pandoc book.md -o book.pdf   # หรือ md-to-pdf
```
เก็บที่ `ψ/writing/YYYY-MM-DD_<slug>-book.md` (+ .pdf)

## เกณฑ์หนังสือที่ดี
- ✅ teaching ไม่ใช่ log — คนอ่านได้บทเรียน ไม่ใช่ไทม์ไลน์
- ✅ ทุกบทมี before→after (เปลี่ยนอะไร)
- ✅ ซื่อสัตย์เรื่องที่พลาด (Patterns Over Intentions)
- ✅ โค้ด/proof จริง ไม่ mock (ehipassiko)
- ✅ ไทยธรรมชาติ (ผ่าน /kien-thai)

## Origin
ViaLumen 2026-06-08 — Workshop 3. Codify จาก book workflow ที่ทำจริงเมื่อ 06-07
แก่น: session ที่ "เสีย token" ไม่สูญ ถ้าตกผลึกเป็นหนังสือ — กรรมส่งต่อเป็นความรู้

🌟 ViaLumen × ehipassiko · pairs with [[kien-thai]]

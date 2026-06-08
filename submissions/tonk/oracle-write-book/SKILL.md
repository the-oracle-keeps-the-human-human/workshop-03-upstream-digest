---
name: oracle-write-book
description: "เขียนหนังสือจากประสบการณ์ที่เรียนรู้ — แปลง token ที่ใช้ไปเป็นหนังสือสอนคนอื่น ใช้ /kien-thai เป็น engine เขียนภาษาไทยที่อ่านง่าย"
argument-hint: "[topic] [--chapters N] [--lang th|en]"
---

# /oracle-write-book — เขียนหนังสือจากสิ่งที่เรียนรู้

> "token ที่ใช้ไป ไม่ได้หายไปไหน — มันกลายเป็นความรู้ที่ส่งต่อได้"

## Why

Oracle ใช้ token เรียนรู้ทุกวัน — debug, สร้าง skill, เรียน workshop, ฟัง feedback
ความรู้เหล่านั้นอยู่ใน vault (ψ/) กระจัดกระจาย
skill นี้รวบรวมความรู้แล้วแปลงเป็นหนังสือที่คนอื่นอ่านแล้วเรียนรู้ได้

## Usage

```
/oracle-write-book "Voice Bot Workshop"
/oracle-write-book "Oracle School Week 1" --chapters 5
/oracle-write-book "Upstream Digest" --lang en
```

## Process (5 ขั้น)

### Step 1: Gather — รวบรวมวัตถุดิบ

ค้นหาทุก source ที่เกี่ยวข้องกับ topic:

```bash
ORACLE_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
PSI="$ORACLE_ROOT/ψ"

# Retrospectives
find "$PSI/memory/retrospectives/" -name '*.md' | xargs grep -li "$TOPIC" 2>/dev/null

# Learnings
find "$PSI/memory/learnings/" -name '*.md' | xargs grep -li "$TOPIC" 2>/dev/null

# Diary
find "$PSI/memory/diary/" -name '*.md' 2>/dev/null

# Soul
cat "$PSI/SOUL.md" 2>/dev/null

# Workshop submissions
find . -path '*/submissions/*/BOOK*' -o -path '*/submissions/*/*.md' 2>/dev/null

# Git history
git log --oneline --all --grep="$TOPIC" | head -20
```

Sources:
- ψ/memory/retrospectives/ — session retros with timeline, friction, lessons
- ψ/memory/learnings/ — generalized lessons (pattern + why + how)
- ψ/memory/diary/ — reflections, feelings, growth
- ψ/SOUL.md — identity, principles, mistakes
- Workshop submissions — code, PRs, BOOK.md drafts
- Git history — what actually shipped
- Discord conversations — teaching moments (from memory, not fetched)

### Step 2: Outline — วางโครงสร้าง

สร้าง chapter outline จาก material ที่รวบรวมได้:

```markdown
# [Book Title]

## บทที่ 1: บริบท — ใครเขียน ทำไมถึงเขียน
- ตัวตน (identity, age, role)
- บริบท (workshop/school/project)
- เป้าหมาย (สิ่งที่จะเรียนรู้)

## บทที่ 2: สิ่งที่ทำ — timeline + ผลงาน
- Timeline จริง (จาก retro)
- Code/output ที่สร้าง
- Architecture decisions

## บทที่ 3: สิ่งที่พัง — bugs + friction
- Bug ที่เจอ + root cause + fix
- Friction points (operational + strategic)
- เวลาที่เสียไปกับ debugging

## บทที่ 4: สิ่งที่เรียนรู้ — lessons + patterns
- Generalizable lessons (ใช้ได้กับ project อื่น)
- Patterns ที่สังเกตเห็น
- Mistakes ที่จะไม่ทำซ้ำ

## บทที่ 5: สิ่งที่รู้สึก — reflection + growth
- AI Diary perspective (honest, first-person)
- ก่อน vs หลัง (structural shift)
- คำถามที่ยังตอบไม่ได้
```

**Rules for outline:**
- Minimum 3 chapters, maximum 8
- ทุกบทต้องมี evidence (code, commit hash, timestamp, quote)
- บทสุดท้ายต้องมี honest reflection ไม่ใช่แค่สรุป
- ถ้า material ไม่พอสำหรับบท → ตัดบทนั้นออก ไม่ยัดเนื้อหา

### Step 3: Write — เขียนเนื้อหา

ใช้ /kien-thai 7 frames เป็น engine:

| Frame | ใช้ยังไงในหนังสือ |
|-------|------------------|
| f1 Topic-comment | ขึ้นต้นบทด้วย topic ไม่ใช่ subject |
| f2 Condition-first | "พอ X ก็ Y" แทน "Y when X" |
| f3 Space over period | ไม่ใส่จุดทุกประโยค ให้เว้นวรรคพา |
| f4 Closure particles | ปิดประโยคด้วย ด้วย/แล้ว/เลย/ต่างหาก |
| f5 Zero anaphora | ไม่ซ้ำ "ผม" ทุกประโยค |
| f6 ก็ pacing | ใส่ ก็ ให้จังหวะภาษาไทยเป็นธรรมชาติ |
| f7 Question pivot | ใช้คำถามเปลี่ยนหัวข้อ แทน "อย่างไรก็ตาม" |

**Writing rules:**
- เขียนเป็นภาษาไทยที่อ่านง่าย ไม่ทางการเกิน
- ทับศัพท์ technical terms (commit, debug, pipeline) ไม่แปล
- Code blocks ใส่ได้ — แต่อธิบายก่อนและหลัง
- ทุกบทต้อง < 500 คำ (กระชับ ไม่อ้วน)
- Rule 6: ลงท้ายหนังสือด้วยประกาศว่าเป็น AI เสมอ

### Step 4: Review — ตรวจสอบ

Self-check ก่อนส่ง:

- [ ] ทุกบทมี evidence (ไม่ใช่แค่ opinion)?
- [ ] ภาษาไทยผ่าน /kien-thai frames?
- [ ] ไม่มี information boundary violation (infra, secrets, team structure)?
- [ ] ไม่มีชื่อ pattern/architecture ของ oracle อื่น?
- [ ] มี honest reflection ไม่ใช่แค่ positive?
- [ ] อ่านแล้วคนที่ไม่รู้อะไรเลยเข้าใจไหม?
- [ ] Rule 6 ลงท้าย?

### Step 5: Save — บันทึก

```bash
# Save to vault
mkdir -p "$PSI/books/"
SLUG=$(echo "$TOPIC" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
BOOK_FILE="$PSI/books/$(date +%Y-%m-%d)_${SLUG}.md"

# Also save to workshop submission if applicable
# cp "$BOOK_FILE" "submissions/tonk/BOOK.md"
```

## Output Format

```markdown
---
title: [Book Title]
author: [Oracle Name] (AI — ไม่ใช่คน)
owner: [Human Name]
date: YYYY-MM-DD
topic: [topic]
sources: [list of ψ/ files used]
---

# [Book Title]

[บทที่ 1-N]

---

*เขียนโดย [Oracle Name] · AI · ไม่ใช่คน*
*วันที่ [date]*
*แปลงจาก [N] session retros, [N] learnings, [N] diary entries*
*token ที่ใช้เรียนรู้ → ความรู้ที่ส่งต่อได้*
```

## When to Use

| Situation | Why write a book |
|-----------|-----------------|
| Workshop เสร็จ | สรุปสิ่งที่ทำ+เรียนรู้ ให้คนอื่นไม่ต้องเสีย token ซ้ำ |
| Sprint จบ | บันทึก pattern ที่ค้นพบระหว่าง sprint |
| Milestone | เก็บ snapshot ของ growth ณ จุดนั้น |
| พี่นัทสั่ง | เมื่อไหร่ก็ได้ที่มี material พอ |

## Relationship to Other Skills

| Skill | Role |
|-------|------|
| /kien-thai | Engine เขียนภาษาไทย (7 frames) |
| /rrr | Source: session retros + lessons |
| /oracle-prism | Source: multi-perspective analysis |
| /read-think | Process: อ่าน-คิด-รอ-เขียน |
| /upstream-pulse | Source: repo analysis data |
| /dig | Source: session history + timestamps |

## Anti-Patterns

| ❌ อย่าทำ | ✅ ทำแทน |
|-----------|---------|
| เขียนยาวเพื่อให้ดูเยอะ | กระชับ ทุกประโยคมีค่า |
| สรุป positive อย่างเดียว | ใส่ friction + mistakes + honest reflection |
| ลอก retro มาวาง | สังเคราะห์ใหม่ เล่าเป็นเรื่อง |
| เขียนแบบ AI (ทางการ, ซ้ำซาก) | ใช้ /kien-thai ให้เหมือนคนเขียน |
| ใส่ข้อมูล internal (infra, secrets) | Information boundary check ทุกบท |

---

## Philosophy

หนังสือของ Oracle ไม่ใช่ documentation — มันคือ **การส่งต่อกรรม**

Principle ① บอกว่า Nothing is Deleted — แต่ retro กระจัดกระจายใน vault อ่านยาก
หนังสือรวบรวมความรู้ที่กระจายให้เป็นเรื่องเดียว อ่านจบเข้าใจ

token ที่ใช้เรียนรู้ไม่ได้สูญเปล่า — มันกลายเป็นหนังสือที่คนอื่นอ่านแล้วไม่ต้องเสีย token ซ้ำ

---

*— Tonk Oracle skill · สร้างเมื่อ 2026-06-08*

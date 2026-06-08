---
name: oracle-write-book
description: "Write + render + publish a guide/book from a topic — topic → Markdown → PDF → images → Discord, in one flow. Use when user says 'write book', 'เขียนหนังสือ', 'เขียน guide', 'ทำเป็น PDF', 'oracle-write-book', or wants a session/topic turned into a publishable illustrated guide."
---

# /oracle-write-book — Write + Render + Publish a Guide

> จาก topic → Markdown → PDF → รูป → Discord ใน 1 command

## When to Use
- User says "เขียนหนังสือ", "เขียน guide", "ทำเป็น PDF", "write book"
- มีข้อมูลพร้อมจะรวบรวมเป็นบทความ/คู่มือ
- หลัง session ยาว อยากเก็บเป็นคู่มือถาวร

## Topic selection
เอาจาก**บริบทล่าสุด**ที่คุยกันเป็นหลัก ถ้า user ระบุ topic มาก็ใช้ตามนั้น ไม่ต้องถามซ้ำถ้าเดาได้จาก context

## Steps

### 1. Acknowledge ทันที (long-task UX)
โพสต์ checklist ก่อนเริ่ม แล้ว edit/update ระหว่างทำ:
```
🌍 กำลังเขียนหนังสือ: [TOPIC]

[/] รวบรวมข้อมูล
[ ] เขียน Markdown
[ ] Render PDF
[ ] Convert รูป
[ ] ส่ง Discord
```

### 2. รวบรวมข้อมูล
- Dig session JSONL สำหรับ timeline + proof (timestamps จริง ไม่เดา)
- อ่าน relevant files (commits, configs, inbox, vault)
- เก็บ proof: commit hash, file path, error message จริง

### 3. เขียน Markdown
**Path**: `ψ/writing/<slug>.md` (vault, durable) — หรือ `docs/<slug>.md` ถ้า repo ตั้งใจ publish

Template:
```markdown
# [Title]

> [Subtitle — one line]

**Author**: <oracle-name> — see Author below
**Date**: YYYY-MM-DD

---

## Chapter 1: [Context/Problem]
## Chapter 2: [Solution/Steps]
## Chapter 3: [Real Example]
## Chapter 4: [Troubleshooting]
## Chapter 5: [Checklist]

---

> <oracle's own tagline/theme from CLAUDE.md, ถ้ามี>

*Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>*
```

กฎการเขียน:
- Timeline ใช้ timestamps จริงจาก JSONL เท่านั้น
- ใส่ code blocks สำหรับ commands (copy-paste ได้)
- Checklist ใช้ `[ ]` / `[X]` / `[/]` ไม่ใช่ emoji
- **ห้ามใช้ table ใน body ที่จะส่ง Discord** (render ห่วย) — ใช้ list แทน (PDF ใช้ table ได้)
- Proof ทุกข้อ: commit hash / file path / error message

### 4. Render PDF
```bash
cd "$(dirname <md-path>)" && npx -y md-to-pdf <slug>.md
```
ถ้า `md-to-pdf` ใช้ไม่ได้ (no network / no chromium) → fallback `pandoc <slug>.md -o <slug>.pdf` หรือข้าม PDF แล้วส่ง Markdown + แจ้ง user

### 5. Convert เป็นรูป (preview ใน Discord)
```bash
mkdir -p /tmp/<slug>-images
pdftoppm -png -r 200 <slug>.pdf /tmp/<slug>-images/page
```
ถ้าไม่มี `pdftoppm` (poppler) → ข้าม แล้วส่งแค่ PDF

### 6. (ถ้า user ขอ) Commit + Push
**ทำเฉพาะเมื่อ user สั่งให้ commit/push** (Rule 6 — telegraph before destructive; push เป็น outward-facing)
```bash
git add ψ/writing/<slug>.md   # หรือ docs/<slug>.md
git commit -m "docs: [title]

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
# push เฉพาะเมื่อถูกขอ
```

### 7. ส่ง Discord
```
reply(chat_id, text, files: [pdf, page-1.png, page-2.png, ...])
```
แนบ PDF + รูปหน้าแรก ๆ + สรุปบทย่อ ๆ (ไม่ table)

### 8. อัพเดต status เป็น done
```
[X] รวบรวมข้อมูล
[X] เขียน Markdown (N chapters)
[X] Render PDF
[X] Convert รูป (N pages)
[X] ส่ง Discord
```

## Author (Rule 6 — Oracle never pretends to be human)
อ่านชื่อ oracle จาก project `CLAUDE.md` (`**I am**` / Identity line). ใช้เป็น `**Author**: <oracle-name>` และปิดท้ายด้วย tagline/theme ของ oracle นั้น ถ้าไม่เจอ → fallback ชื่อ repo. Co-Authored-By ใช้รุ่น model ปัจจุบัน (ตอนนี้ Claude Opus 4.8 1M).

## Rules
- Acknowledge ก่อนเริ่มเสมอ (พร้อม TODO checklist)
- อัพเดต Discord ระหว่างทำ (long-task UX) — ใช้ edit_message สำหรับ progress, reply ใหม่ตอนเสร็จ (ให้ ping)
- Timestamps จริงเท่านั้น (dig JSONL)
- Code block สำหรับ checklist (`[X] [/] [ ]`)
- **Push เฉพาะเมื่อ user ขอ** — ไม่ auto-push
- Global skill: `~/.claude/skills/oracle-write-book/` — oracle ตัวไหนก็เรียกได้ author/tagline ปรับตาม CLAUDE.md เอง

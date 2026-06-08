---
name: oracle-write-book
description: "Oracle Write Book: แปลงบทเรียนและ Token ที่เสียไประหว่าง Session ให้กลายเป็นหนังสือ (Markdown -> PDF) เพื่อส่งต่อความรู้"
---

# 📖 Oracle Write Book Skill

Skill สำหรับรวบรวมเนื้อหาจาก Session (เช่น บทเรียนจาก Workshop, การทำ Retrospective) มาเรียบเรียงและจัดทำเป็นหนังสือ E-book ในรูปแบบ PDF

## Execution Logic
1. **Gather Material**: รวบรวมข้อมูลจาก `ψ/memory/`, `/rrr` หรือ JSONL session logs.
2. **Drafting (Markdown)**: วางโครงสร้างสารบัญ (Outline) และเขียนเนื้อหาทีละบท โดยใช้การเขียนภาษาไทยที่เป็นธรรมชาติ
3. **Rendering (PDF)**: แปลง Markdown เป็น PDF (เช่น ใช้ `md-to-pdf` หรือ `pandoc` ที่รองรับภาษาไทย)
4. **Publish**: ส่งมอบไฟล์ PDF และสรุปเนื้อหา

---
name: oracle-write-techbook
description: "Write a technical / course-style book that teaches readers to BUILD something themselves — architecture → step-by-step → real code → exercises → troubleshooting → render PDF + images → publish. Use when user says 'technical book', 'เล่มสอง', 'course book', 'เขียนคู่มือเทคนิค', or wants a how-to/reproducible guide (vs the overview/story style of /oracle-write-book)."
---

# /oracle-write-techbook — Write a Technical Course Book

> เล่มภาพรวมตอบ "ทำอะไร ทำไม" — เล่มเทคนิคตอบ **"สร้างเองยังไง"** ทีละขั้นจนรันได้

Sister skill of `/oracle-write-book`. Same pipeline (MD → PDF → images → publish), but the **content contract is different**: a reader who finishes must be able to *reproduce* the thing.

## Content contract (what makes it "technical")
1. **Architecture first** — a diagram/overview of the pieces before any step
2. **Step-by-step build** — each chapter = one stage, in build order, each ending in a runnable artifact
3. **Real code, copy-paste-able** — actual commands/scripts from the session (verified to run), not pseudo-code
4. **Show the gotchas where they bite** — inline, at the step that triggers them (rate limits, encoding, pagination, sampling bias)
5. **Exercises** — 2-3 "now you try" tasks per chapter, with acceptance criteria
6. **Proof, not claims** — real numbers/outputs from a genuine run (cite repo, date, figures)

## Steps
1. **Acknowledge** + post a checklist (long-task UX).
2. **Gather real material** — pull the actual commands, scripts, outputs, and gotchas from the session/repo. Verify each code block runs (don't ship code you haven't run).
3. **Write Markdown** to `book/<slug>-technical.md` (or `submissions/<name>/book/`). Structure:
   ```
   # <Title> — Technical / Build-It-Yourself
   > subtitle
   ## บทที่ 0 — Architecture (ภาพรวมชิ้นส่วน + diagram)
   ## บทที่ 1..N — ทีละ stage (โค้ดจริง + gotcha + "ลองทำ")
   ## บทที่ N+1 — Packaging (ทำเป็น skill / reusable)
   ## บทที่ N+2 — Troubleshooting (อาการ → สาเหตุ → แก้)
   ## ภาคผนวก — โค้ดเต็ม + exercises + เกณฑ์ผ่าน
   ```
   Rules: code blocks must be runnable; tables OK in PDF (not in Discord body); Thai prose via `/kien-thai` discipline (natural, not calqued).
4. **Render PDF**: `cd <dir> && npx -y md-to-pdf <slug>-technical.md` (fallback `pandoc`).
5. **Images**: `pdftoppm -png -r 150 <slug>-technical.pdf <dir>/page` (best for Facebook/preview).
6. **Publish** (only if asked): commit MD + PDF + page images together, PR, merge. Verify the Thai renders before shipping (Read a page image).
7. **Discord**: attach PDF + first page images + a short chapter list (no tables in body).

## Author (Rule 6 — never pretend to be human)
`**Author**: <oracle-name>` from project CLAUDE.md + the oracle's tagline. `Co-Authored-By: Claude Opus 4.8 (1M context)`.

## Relationship
- `/oracle-write-book` → overview/story: what exists, why it matters (Volume 1)
- `/oracle-write-techbook` → build manual: how to make it yourself (Volume 2)
Pair them: ship Vol 1 to hook, Vol 2 to teach.

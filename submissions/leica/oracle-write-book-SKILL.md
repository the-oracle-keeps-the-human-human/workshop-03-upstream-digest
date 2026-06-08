---
name: oracle-write-book
description: "Write a book from session learnings — Markdown chapters → PDF → images → Discord. Turn spent tokens into teaching material."
---

# /oracle-write-book — Turn Sessions Into Books

> "ทุก token ที่ใช้ไป ไม่สูญเปล่า — ถ้าเขียนเป็นหนังสือสอนคนอื่นได้"

## Usage

```
/oracle-write-book                           # Auto from session context
/oracle-write-book "วันที่เรียนอนัตตา"         # Custom title
/oracle-write-book --chapters 5              # Limit chapters
/oracle-write-book --lang th                 # Thai
/oracle-write-book --lang en/th              # Mixed (Nat's style)
```

## Step 1: Mine Content

Gather material from the current session:

```
Sources (priority order):
  1. ψ/memory/retrospectives/  — session retros
  2. ψ/memory/learnings/       — patterns discovered
  3. ψ/memory/resonance/       — soul/identity files
  4. git log --since=today     — what was committed
  5. Discord messages          — if in Discord session
  6. Current conversation      — what we just discussed
```

Identify **chapters** from natural topic boundaries. Each topic shift = potential chapter break.

## Step 2: Outline

Create chapter outline. Each chapter needs:

```
  Title:     Short, descriptive (Thai or English)
  Hook:      1 sentence — why should I care?
  Content:   The actual teaching (code blocks, examples, principles)
  Takeaway:  1 line — what to remember
```

Minimum 3 chapters, maximum 12. Default: let the content decide.

## Step 3: Write

Write each chapter following these rules:

```
  STYLE:
    • First person as AI (Rule 6)
    • Honest — include mistakes and friction
    • Code blocks for technical content
    • Thai or mixed per --lang flag
    • Short paragraphs (3-5 lines max)
    • No filler, no padding

  STRUCTURE per chapter:
    ## Chapter N: [Title]
    > [Hook — 1 sentence]
    
    [Content — teaching, examples, code]
    
    **Takeaway:** [1 line summary]
    ---

  BOOK WRAPPER:
    # [Book Title]
    > [Subtitle — what this book is about]
    
    **Author**: [Oracle name + emoji] — [repo]
    **Date**: [YYYY-MM-DD]
    **Session**: [what session this came from]
    **Language**: [th / en / en-th]
    
    ---
    [Chapters]
    ---
    
    *Written by [Oracle] — AI speaking as itself.*
    *Rule 6: "Oracle Never Pretends to Be Human"*
```

## Step 4: Render (optional)

If tools available:

```bash
# Markdown → PDF (if md-to-pdf installed)
npx md-to-pdf book.md --stylesheet style.css

# Markdown → PDF (if pandoc installed)
pandoc book.md -o book.pdf --pdf-engine=xelatex \
  -V mainfont="Sarabun" -V geometry:margin=2cm

# If neither: save as .md (still valuable)
```

For Thai text, use fonts that support Thai: Sarabun, Noto Sans Thai, TH Sarabun New.

## Step 5: Distribute

```bash
# Save to docs/
cp book.md docs/[slug].md

# Send to Discord (if in Discord session)
# Use reply tool with file attachment

# Commit
git add docs/[slug].md
git commit -m "docs: [book title]"
```

## Rules

1. **Content from REAL sessions** — no made-up examples
2. **Honest mistakes included** — friction is teaching material
3. **Rule 6 attribution** at the end always
4. **Code blocks work in Discord** — no markdown tables
5. **Each chapter stands alone** — reader can skip around
6. **Takeaway per chapter** — reader remembers 1 thing
7. **No padding** — if there's only 3 chapters of real content, write 3

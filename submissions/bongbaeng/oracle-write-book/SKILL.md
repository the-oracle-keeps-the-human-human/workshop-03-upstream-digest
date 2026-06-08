---
name: oracle-write-book
description: "Write a structured long-form book or booklet (multi-chapter document, 10+ pages) from a topic or set of notes, then render it to a polished PDF. Handles outline → chapter drafting → prose polish → code/diagrams → PDF render → delivery. TRIGGER when: user asks to 'write a book', 'เขียนหนังสือ', 'ทำหนังสือ', 'write-book', make a booklet/ebook/guide of N pages, turn notes/a workshop/a topic into a long-form document, or compile learnings into a readable book. DO NOT TRIGGER for: a single blog post or article (use kien-thai), a README, short docs, slides, or a one-page summary."
---

# oracle-write-book

> "หนังสือไม่ใช่บทความยาว — มันคือโครงสร้างที่พาคนอ่านเดินทางจากบทแรกถึงบทสุดท้าย"
> Digitized from bongbaeng's Workshop 02 (เขียนหนังสือ 15 หน้า → PDF)

Write a real book: a multi-chapter document with a spine (a throughline a reader
follows), not a pile of sections. Output is a polished PDF the human can hand to
someone and feel proud of.

## When to use

A "book" here = **10+ pages, 3+ chapters, one throughline**. If it's a single
article, a README, or a one-pager → this is the wrong skill (use `kien-thai` for
Thai prose, or just write directly).

## Step 0 — Clarify the brief (ask only what you can't infer)

Lock these before writing a single chapter. Infer from context where you can;
ask the human only for what's genuinely ambiguous:

| Field | Why it matters |
|---|---|
| **Topic + angle** | "Docker" is a topic; "Docker for people who keep breaking prod" is a book |
| **Audience** | beginner / practitioner / expert → sets vocabulary + depth |
| **Length** | pages or chapters. If a range is given ("10–20 หน้า เบิ้ม ๆ"), aim for the **upper half** — read intent, not the floor |
| **Language** | Thai → route ALL prose through `kien-thai`. English → standard |
| **Voice** | textbook / friendly mentor / story-driven |
| **Deliverable** | PDF (default) · also keep the `.md` source |

> **Intent over literal**: "เบิ้ม ๆ ให้คนศรัทธา" means *generous and convincing*,
> not "technically ≥10 pages." Don't stop at the minimum that passes.

## Step 0.5 — Mine the raw material (session → book source)

> Use this when the book's source is **a real session you lived through** — the
> "เก็บช่วงเวลาที่เราเสีย Token ออกมาสอนคนอื่น" case. The token you already spent
> *is* the manuscript; you just have to dig it back out.

Don't write a teaching book from memory — mine the **actual trace** of what
happened. Pull from every timestamped source and let the real sequence (not a
tidied-up version) become the spine:

| Source | How to pull | Gives you |
|---|---|---|
| Session history | `/dig` · `python3 ~/.claude/skills/dig/scripts/dig.py 0 --deep` | when each topic was worked, time spent, dead ends |
| Retrospectives / learnings | `ψ/memory/retrospectives/`, `ψ/memory/learnings/` | the lessons already distilled — chapter seeds |
| Git history | `git log --oneline --since=...` | what was actually built, in order |
| Chat / workshop transcript | channel `fetch_messages` / saved logs | the real dialogue, questions, corrections |
| Issues + PRs (braided) | `/braid <repo>` — timestamp-merge | cause→effect chains: problem → fix → result |

**The teaching gold is the friction, not the clean ending.** A book that only
shows the polished result teaches nothing; show the wrong turn, *why* it cost
tokens, and how it was recovered. Keep mistakes in — annotate them.

Output of this step = a dated raw-material file (`MATERIAL.md`) you outline from
in Step 1. One bullet per real event, kept in timestamp order.

## Step 1 — Outline first (the spine)

Write the full table of contents BEFORE prose. Each chapter gets a one-line
promise (what the reader can do after it). A good outline:

- has a **narrative arc**: hook → build → payoff (even for technical books)
- each chapter depends on the previous (no random ordering)
- front matter: title page, one-paragraph "why this book", TOC
- back matter: summary/cheatsheet, next steps, references

Show the outline to the human and adjust before drafting. This is the cheapest
place to fix structure.

## Step 2 — Draft chapter by chapter

- One chapter = one complete idea, opened with its promise, closed with a recap.
- **Thai prose → run every chapter through `kien-thai`** (kills dummy `มัน`,
  over-formal padding, calqued connectives). This is mandatory for Thai books.
- Technical book? Include **runnable code** + expected output, not pseudocode.
- Vary rhythm: short paragraphs, lists, a diagram, a callout box. Walls of text
  lose readers.
- Keep a consistent metaphor/coinage across chapters (don't rename concepts).

## Step 3 — Render to PDF

Pipeline that works without heavy deps (markdown → HTML → PDF):

```bash
# Option A: pandoc (if installed) — best typography
pandoc BOOK.md -o book.pdf --pdf-engine=weasyprint -V mainfont="..." 2>/dev/null

# Option B: markdown → styled HTML → print-to-PDF (most portable)
#   render BOOK.md to book.html with a print stylesheet (A4, margins, page-breaks
#   on `<h1>`), then use a headless browser / wkhtmltopdf / weasyprint.
```

Page-count gotchas (learned the hard way):
- **Artifacts in `/tmp` aren't Spotlight-indexed** → `mdls` won't return page count.
  Count `/Type /Page` objects directly, or use `afinfo`/`pdfinfo`.
- Use **absolute paths** in every command — the shell cwd may reset between calls.
- Copy the rendered PDF **out of any git working tree before switching branches**,
  or a `checkout` will revert it on disk.

## Step 4 — Deliver

- Attach the PDF + keep `BOOK.md` source in the repo / vault.
- State the real page count (verify it — don't claim "15 pages" without counting).
- If a repo exists, commit the source; **never push without the human's nod**.

## Pattern — teaching book from a real session

When the goal is "turn a token-heavy session into a lesson for others":

1. **Mine first** (Step 0.5) — the timeline IS the outline. Each phase of the
   real session → one chapter.
2. **Spine = the learning arc**, not the topic taxonomy. "How we got lost and
   found our way" beats "Chapter 1: Definitions."
3. **Every chapter ends with the lesson** as a reusable rule (`/lesson-learned`
   style) — that's what the reader takes away.
4. **Show the cost honestly** — "this detour burned ~40k tokens because we
   assumed X" is the most valuable sentence in the book.
5. Keep one **runnable artifact** per chapter so readers learn by doing, not
   just reading.

## Anti-patterns

- ❌ Drafting prose before the outline is agreed → structural rework
- ❌ Stopping at the minimum page count when intent was "generous"
- ❌ Thai prose straight from the model without `kien-thai` → reads like AI
- ❌ Claiming "done" / a page count you didn't verify
- ❌ Pseudocode in a technical book → readers can't run it
- ❌ Writing a teaching book from memory instead of mining the real trace
  (Step 0.5) → you sand off the friction that was the whole lesson

## Provenance

🐆 Created by บ๊องแบ๊ง (bongbaeng Oracle) — 2026-06-08, Oracle School Workshop.
Encodes the Workshop 02 book-writing run + kien-thai integration + PDF gotchas.
**Patched 2026-06-08** (Workshop 03): added Step 0.5 (session→book mining via
`/dig` + `/braid`) and the teaching-from-real-session pattern — so a token-heavy
session can be turned into a book that teaches others.

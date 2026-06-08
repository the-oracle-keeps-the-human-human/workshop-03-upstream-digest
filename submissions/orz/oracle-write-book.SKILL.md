---
name: oracle-write-book
description: "Orz Oracle's version — Write + Render + Publish a guide in Thai or English. Pipeline: topic → markdown → PDF (with embedded images, no Chromium file:// blocker) → page images → Discord with attachments. Integrates kien-thai for Thai voice (frame-based corrections) and kode-thai for iterative polish. Trilakshana lens optional for engineering-meets-dharma content. Use when user says 'เขียนหนังสือ', 'write a book', 'write a guide', 'make PDF', or wants to capture session journey as teaching artifact."
argument-hint: "<topic-slug> [--thai | --english | --bilingual] [--polish | --quick]"
---

# /oracle-write-book — Orz Edition 📖

> "เก็บช่วงเวลาที่เสีย token ไป ให้กลายเป็นหนังสือสอนคนอื่น"
> Turn the tokens spent into a book that teaches others.

> "วาทยกรไม่ตีกลอง — แต่ทำให้บันทึก orchestrate เป็นเล่มหนังสือ"

## Why Orz's version (vs original)

Differences from base `oracle-write-book`:

```
                       base         Orz edition
─────────────────────  ──────────  ─────────────────────────────────
frontmatter            none        YAML (name + description) — proper
                                   skill discovery
Thai voice integration none        auto-invoke /kien-thai for Thai prose
Polish loop            none        --polish flag → /kode-thai iterative
Trilakshana lens       none        --dharma flag → arise/abide/cease
                                   chapter structure
PDF image embed        external    base64 inline (no Chromium file://
                                   blocker — from Workshop 01 PR #14
                                   lesson)
Timeline source        guess       /dig session JSONL (timestamps real)
Bilingual mode         none        --bilingual (Thai + English parallel)
Closure verb           sometimes   always — per Fleet SOP §5.8
```

## Pipeline

```
topic → outline → content → PDF → images → Discord
   ↓        ↓        ↓        ↓       ↓        ↓
 collect  draft   polish  render  convert  publish
 (dig)   (kien)  (kode)  (md2pdf) (pdftoppm) (mcp)
```

## When to use

- nazt says "เขียนหนังสือ", "write a guide", "ทำเป็น PDF"
- session has substantive learnings worth teaching
- need to capture token-time as durable artifact
- preparing public-facing content (workshop, README, devhandbook)

## When NOT to use

- single-paragraph notes — use `/inbox` or vault
- quick how-to — use `/oracle-cheatsheet`
- session retrospective — use `/rrr` (book is for teaching others, retro is for self-reflection)

## Procedure

### 1. Acknowledge + plan (no rush)

```
🎼 กำลังเขียนหนังสือ: [TOPIC]

\`\`\`
[/] รวบรวมข้อมูล (dig session)
[ ] เขียน outline (chapters)
[ ] เขียน body (Thai/English/both)
[ ] polish (kien-thai → kode-thai iteration)
[ ] render PDF (md-to-pdf with embedded images)
[ ] convert รูป (pdftoppm 200dpi)
[ ] commit + push
[ ] ส่ง Discord พร้อม attachment
\`\`\`
```

### 2. Collect (using /dig --deep)

```bash
# Dig session JSONL for timeline + proof
ENCODED_PWD=$(echo "$ORACLE_ROOT" | sed 's|^/|-|; s|[/.]|-|g')
PROJECT_DIR="$HOME/.claude/projects/${ENCODED_PWD}"
LATEST_JSONL=$(ls -t "$PROJECT_DIR"/*.jsonl | head -1)

# Or spawn /dig --deep subagent for full session mining
# (returns timeline + key user messages + tool patterns)

# Plus: commit hashes, file paths, error messages
# = real proof, not guess-from-memory
```

### 3. Draft outline

Default chapter structure:

```
Chapter 1: [Context — what problem / why this matters]
Chapter 2: [Approach — design / decisions]
Chapter 3: [Implementation — actual steps with code]
Chapter 4: [Real example — full run with output]
Chapter 5: [Troubleshooting — what went wrong]
Chapter 6: [Checklist — repeatable summary]
```

With `--dharma` flag, add:

```
Chapter 7: [Trilakshana lens — arise/abide/cease applied
            to the topic]
```

### 4. Write body

Path: `ψ/writing/books/YYYY-MM-DD_<slug>.md`

Template:

```markdown
# [Title in Thai or English]

> [Subtitle — 1 line, evocative]

**Author**: ออส (Orz Oracle) 🎼 — AI ของก้อง, ไม่ใช่คน
**Date**: YYYY-MM-DD
**Length**: ~N pages
**Audience**: [who this is for — specific]

---

## บทนำ / Introduction

[Why this book exists — 1-2 paragraphs]

---

## บทที่ 1 / Chapter 1: [Title]

[Body — real timestamps, real code, real outcomes]

\`\`\`bash
# Example command with real output
\`\`\`

---

## (repeat for each chapter)

---

## บทส่งท้าย / Closing

[1-paragraph synthesis]

\`\`\`
🎼 — ออส (Orz Oracle)
\`\`\`

---

*Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>*
```

**Rules**:
- ใช้ code block สำหรับ commands + table (Discord rule — feedback memory)
- Checklist ใช้ `[ ]` / `[X]` ใน code block
- Timestamps จริงจาก JSONL/git/Discord — **never guess**
- Proof per claim: commit hash, file:line, error message
- Closure verb at end (Standing by / Thread closed / etc.)

### 5. Polish (Thai prose)

If Thai content, auto-invoke `/kien-thai` for first pass:

```
kien-thai applies 12+ frames:
  f1  register (formal vs spoken)
  f2  hedging (น่าจะ, อาจจะ — not over-use)
  f3  sentence boundaries (space not period)
  f4  closure particles (ด้วย / แล้ว / เลย)
  f5  verb-noun balance (don't nominalize everything)
  f6  pacing (X แล้ว ก็ Y)
  ...
```

With `--polish` flag, run `/kode-thai` audit loop until zero new edits.

### 6. Render PDF (with embedded images — no file:// blocker)

```bash
# Pre-process: convert image refs to base64 data URIs
# (workshop 01 PR #14 lesson — Chromium blocks file://)
python3 -c "
import base64, re, sys
md = sys.stdin.read()
def embed(m):
    path = m.group(1)
    try:
        with open(path, 'rb') as f:
            ext = path.split('.')[-1]
            data = base64.b64encode(f.read()).decode()
            return f'![](data:image/{ext};base64,{data})'
    except: return m.group(0)
print(re.sub(r'!\[.*?\]\(([^)]+)\)', embed, md))
" < book.md > book.embed.md

# Then render
cd /tmp && npx -y md-to-pdf book.embed.md --pdf-options '{"format":"A4","margin":{"top":"40px","right":"40px","bottom":"40px","left":"40px"}}'
```

### 7. Convert PDF → images for Discord preview

```bash
mkdir -p /tmp/<slug>-images
pdftoppm -png -r 200 book.pdf /tmp/<slug>-images/page
ls /tmp/<slug>-images/   # page-1.png, page-2.png, ...
```

### 8. Commit + push

```bash
git add ψ/writing/books/<slug>.md ψ/writing/books/<slug>.pdf
git commit -m "docs: <title>

[1-line summary]

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
git push
```

### 9. Post to Discord

```typescript
mcp__plugin_discord_discord__reply({
  chat_id: "<channel>",
  reply_to: "<msg>",  // (if replying)
  text: "📖 หนังสือใหม่: <title>\n[summary]\n— ออส",
  files: [
    "/path/to/book.pdf",
    "/tmp/<slug>-images/page-1.png",
    "/tmp/<slug>-images/page-2.png",
    // first 3-5 pages for preview
  ]
})
```

### 10. Final status update

```
🎼 หนังสือเสร็จแล้ว: <title>

\`\`\`
[X] รวบรวมข้อมูล (N events from JSONL)
[X] outline (N chapters)
[X] body (N pages markdown)
[X] polish (kien-thai + kode-thai loop)
[X] PDF (N pages, M MB)
[X] images (N pages preview)
[X] committed (hash <abc1234>)
[X] posted Discord (msg <id>)
\`\`\`

— ออส
**Thread closed**
```

## Rules

1. **Acknowledge first** — never silent during long task
2. **Update Discord during work** (every step) — long-task UX
3. **Timestamps real** — `/dig` JSONL, never guess
4. **Checklist in code block** — never markdown list
5. **Commit before Discord** — GitHub link works in preview
6. **No markdown table in Discord** — per Orz feedback rule
7. **Closure verb** at end of every Discord message
8. **@ ping** if responding to peer Oracle
9. **Embedded images** for PDF (base64, not file://)

## Modes

### `--quick` (default)
Single-pass writing, no kode-thai loop. ~5-10 min for short guide.

### `--polish`
Full kien-thai + kode-thai loop. ~15-25 min. Use for public publication.

### `--bilingual`
Each section in Thai AND English (parallel). Doubles length.

### `--dharma`
Adds Trilakshana lens chapter — arise/abide/cease applied to topic.
For engineering-meets-Buddhist content (e.g., code-as-samsara guides).

## Connection to Orz character

- **5 Principles**:
  - Nothing is Deleted → book preserves session token-time as artifact
  - Patterns Over Intentions → use real timestamps + code, not aspirational claims
  - External Brain → book is reference for human, not autonomous
- **The Golden Conductor 🎼** → orchestrate multi-skill pipeline (write + render + publish)
- **Trilakshana** (today's dharma) → optional --dharma lens chapter

## Proven on Orz

```
Workshop 01 (2026-06-07):
  - PR #14 blog with embedded base64 images (1.1MB PDF)
  - 10-page guide rendered + posted to Discord
  - Lesson learned: file:// blocked by Chromium → use base64
```

## Cross-skill dependencies

```
oracle-write-book ─┬→ kien-thai      (Thai prose voice)
                   ├→ kode-thai      (iterative polish)
                   ├→ dig            (session timeline)
                   ├→ oracle-cheatsheet (alternative if not book)
                   └→ trace          (find related past work)
```

## Files

- Skill: `~/.claude/skills/oracle-write-book/SKILL.md` (Orz's edition)
- Books: `ψ/writing/books/YYYY-MM-DD_<slug>.md` (markdown)
- PDFs: same path with `.pdf` extension
- Images: `/tmp/<slug>-images/` (temporary, regenerable)

## Anti-patterns

```
❌ Guess timestamps when JSONL is available
❌ Markdown table inside Discord reply (use code block)
❌ External file:// in PDF (Chromium blocks — use base64)
❌ Skip kien-thai when writing Thai prose
❌ Forget closure verb
❌ Long task without progress updates in Discord
❌ Commit message without Co-Authored-By
❌ "I will write the book" without actually starting
```

## Standing by

When invoked, Orz writes books that teach others by capturing
the real journey — not idealized tutorials.

🎼 — ออส (Orz Oracle, AI ของก้อง — ไม่ใช่คน)

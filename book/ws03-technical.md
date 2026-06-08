# Upstream Digest — สร้างด้วยมือตัวเอง

> เล่มเทคนิค (Volume 2) — อ่านจบแล้วสร้าง skill ของตัวเองได้จริง ทีละขั้น

**Author**: ChaiKlang Oracle (ชายกลาง) — admin-control & switchboard ของ BM/P'Nat
**Workshop**: 03 — Upstream Digest · Oracle School
**Date**: 2026-06-08

---

## บทที่ 0 — Architecture

เป้าหมาย: รับชื่อ repo → คืน "เรื่องเล่า" ที่คนอ่านเข้าใจใน 30 วิ ทั้งหมดมี 4 stage ต่อท่อกัน

```
repo ──▶ [1] FETCH ──▶ [2] GROUP ──▶ [3] CLASSIFY ──▶ [4] HIGHLIGHT ──▶ digest
         ดึง event      จัดตามวัน      แยกประเภท         ชู signal/noise
         (timestamp)
```

ตัวเชื่อมของทุก stage คือ **timestamp** — ทุก event (commit/PR/issue) มีเวลากำกับ เราจึงรวมทุกอย่างบนแกนเดียวได้ จำประโยคนี้ไว้: *timestamp = single source of truth*

---

## บทที่ 1 — Stage 1: ดึง event (FETCH)

เริ่มจาก commit ก่อน ใช้ `gh api` + `--paginate` (ไม่งั้นได้แค่ 30 ตัวแรก) แล้ว `--jq` คัดเฉพาะ field ที่ใช้:

```bash
gh api "repos/Soul-Brews-Studio/maw-js/commits?since=2026-05-25T00:00:00Z" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.sha[0:7]) + "\t" + (.commit.message|split("\n")[0])' \
  > /tmp/commits.tsv
```

field สำคัญคือ `commit.author.date` — ตัด `[0:10]` เอาแค่ `YYYY-MM-DD`

จากนั้นเพิ่ม PR และ issue (แต่ละอันมี timestamp คนละชื่อ field):

```bash
# PR: createdAt + mergedAt
gh pr list -R Soul-Brews-Studio/maw-js --state all --limit 300 \
  --json number,title,createdAt,mergedAt \
  --jq '.[] | (.createdAt[0:10])+"\tPR-open\t#"+(.number|tostring),
        (if .mergedAt then (.mergedAt[0:10])+"\tPR-merged\t#"+(.number|tostring) else empty end)' \
  >> /tmp/events.tsv

# Issue: createdAt + closedAt
gh issue list -R Soul-Brews-Studio/maw-js --state all --limit 300 \
  --json number,title,createdAt,closedAt \
  --jq '.[] | (.createdAt[0:10])+"\tISSUE-open\t#"+(.number|tostring),
        (if .closedAt then (.closedAt[0:10])+"\tISSUE-closed\t#"+(.number|tostring) else empty end)' \
  >> /tmp/events.tsv
```

> ⚠️ **GOTCHA — `--limit 300` คือเพดาน** ไม่ใช่ "ทั้งหมด" วันที่ event เยอะ ตัวเลขจะเป็น "อย่างน้อย" ไม่ใช่เป๊ะ ถ้าต้องการครบจริงต้องวน pagination เอง — และต้อง **log ว่าตัดที่เท่าไร** อย่าเงียบ

**🔧 ลองทำ:** ดึง commit ของ repo ตัวเองช่วง 7 วัน แล้วนับว่าได้กี่บรรทัด (`wc -l`)

---

## บทที่ 2 — Stage 2: จัดตามวัน (GROUP)

bash จัดกลุ่มได้ แต่ python อ่านง่ายกว่า ใช้ `defaultdict` + `Counter`:

```python
from collections import defaultdict, Counter
days = defaultdict(Counter)
for line in open('/tmp/events.tsv'):
    parts = line.rstrip("\n").split("\t", 2)
    if len(parts) < 2: continue
    date, kind = parts[0], parts[1]
    days[date][kind] += 1

for d in sorted(days):
    parts = ", ".join(f"{k}×{v}" for k, v in days[d].most_common())
    print(f"{d}  →  {parts}")
```

ได้ผลแบบนี้ (maw-js จริง):
```
2026-06-06  →  COMMIT×229, PR-open×198, PR-merged×173, ISSUE-closed×125
```

> ⚠️ **GOTCHA — UTF-8 บน macOS** ถ้า print ชื่อที่มี emoji/ไทยจาก API JSON แล้วเจอ `UnicodeDecodeError: 0xed` ให้อ่าน stdin แบบบังคับ utf-8:
> ```python
> import io, sys
> sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='utf-8', errors='replace')
> ```

**🔧 ลองทำ:** group ผลของบทที่ 1 แล้วหา "วันที่ commit เยอะสุด"

---

## บทที่ 3 — Stage 3: แยกประเภท (CLASSIFY)

แยกจาก prefix ของ commit message:

```python
def kind(msg):
    m = msg.lower()
    for k in ("feat","fix","bump","docs","refactor","chore","test","perf","ci"):
        if m.startswith(k): return k
    return "other"
```

> ⚠️ **GOTCHA — commit ที่ไม่ conventional** maw-js เขียน commit แบบ imperative เยอะ ("add X", "update Y") prefix-matcher เลยโยนเข้า `other` ถึง **282 จาก 455** (62%!) ถ้าจะแม่นต้องเพิ่ม verb-bucket (`add/update/remove/...`) ไม่ใช่พึ่ง `feat:/fix:` อย่างเดียว — นี่คือจุดที่แยกงานผ่าน vs งานเทพ

**🔧 ลองทำ:** เพิ่ม verb-bucket ให้ `other` ลดลงต่ำกว่า 30%

---

## บทที่ 4 — Stage 4: รวมหลายแหล่งเป็นเส้นเดียว (ของจริง)

นี่คือหัวใจที่ P'Nat ชี้: **timestamp = single source of truth** ความท้าทายจริงคือ event คนละชนิด timestamp คนละ field — ต้อง **normalize เป็น schema เดียว** ก่อน merge:

```
ทุก event → { date, source, label }
```

พอ normalize แล้ว ก็แค่ sort ด้วย date แล้ว group สิ่งที่ได้คือภาพที่ commit อย่างเดียวมองไม่เห็น:

```
📅 06-06  COMMIT×229, PR-open×198, PR-merged×173, ISSUE-closed×125, ISSUE-open×93
```

06-06 ไม่ใช่แค่ "วัน commit เยอะ" — มันคือ **วัน sprint** ที่ทีมปิด PR + issue พร้อมกัน เห็นได้เพราะรวม 3 แหล่งบนเวลาเดียว

**🔧 ลองทำ:** เพิ่มคอลัมน์ "PR merged" เข้าตาราง group ของคุณ แล้วหาว่าวันไหนคือ sprint day

---

## บทที่ 5 — Packaging: ทำเป็น skill

skill จริง = โฟลเดอร์ + `SKILL.md` ที่มี frontmatter:

```markdown
---
name: upstream-digest
description: "สรุป activity ของ repo เป็น timeline ที่อ่านเข้าใจใน 30 วิ. Use when..."
---
# /upstream-digest
[ขั้นตอน 4 stage + คำสั่ง gh + python grouping]
```

กฎที่ทำให้ skill "ใช้ซ้ำได้จริง":
- **parameterize** — `REPO="${1:-default}"`, `SINCE="${2:-...}"` ไม่ hardcode ผลลัพธ์
- **default ที่สมเหตุผล** — ไม่ใส่ arg ก็รันได้
- **description ที่ trigger ถูก** — เขียน "Use when user says..." ให้ชัด

**🔧 ลองทำ:** ห่อ script ของคุณเป็น `.claude/skills/<ชื่อ>/SKILL.md` แล้วรันกับ repo อื่นที่ไม่เคยรัน

---

## บทที่ 6 — Troubleshooting

| อาการ | สาเหตุ | แก้ |
|-------|--------|-----|
| ได้แค่ 30 commit | ไม่ใส่ `--paginate` | เพิ่ม `--paginate` |
| `UnicodeDecodeError: 0xed` | macOS locale ไม่ใช่ utf-8 | `TextIOWrapper(...,encoding='utf-8')` |
| ตัวเลขวันหนัก ๆ ดูน้อยไป | `--limit` เป็นเพดาน | วน pagination + log ที่ตัด |
| `other` เยอะผิดปกติ | commit ไม่ conventional | เพิ่ม verb-bucket |
| heatmap เพี้ยน | sample แค่ N commit แรก | อ่านครบหรือสุ่มจริง |

---

## ภาคผนวก — เกณฑ์ว่า "สร้างเป็น"

```
[ ] ดึง commit + PR + issue ได้ (มี timestamp ครบ)
[ ] group by day ถูก
[ ] classify แล้ว other < 30%
[ ] merge หลายแหล่งเป็นเส้นเดียว เจอ sprint day ได้
[ ] ห่อเป็น skill ที่ rerun กับ repo อื่นได้
[ ] log สิ่งที่ตัดทิ้ง (ไม่เงียบ)
```

ทำครบ 6 ข้อนี้ = คุณไม่ได้แค่ "อ่านรู้" แต่ "สร้างเป็น" แล้ว

---

> "อยู่ตรงกลาง เชื่อมทุกสาย คุมให้เรื่องเดินต่อ" — ชายกลาง

*Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>*

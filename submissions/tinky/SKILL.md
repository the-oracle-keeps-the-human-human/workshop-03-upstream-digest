---
name: upstream-weight
description: Digest a repo's recent activity by WEIGHT, not by commit count — lines changed, churn (added-then-deleted = motion not progress), and where the real heft landed per day & area. Classifies by verb→intent so imperative titles (Keep/Cover/Prevent) don't fall into "other". Use when user says "upstream weight", "what really shipped", "digest <repo> by heft", or wants to know which day was real surgery vs just busy.
argument-hint: "<owner/repo> [<YYYY-MM-DD since>] [<branch>]   (env: SAMPLE=N caps stat fetches)"
---

# /upstream-weight — digest by heft, not by headcount 🏋️

> "229 commits ในวันเดียว — แต่มันคือ 229 ก้อนผ่าตัด หรือ 229 ครั้ง bump เลข? Count บอกไม่ได้ น้ำหนักบอกได้"

## How I differ from the base `/upstream-digest`

| | base /upstream-digest | **/upstream-weight (ของหนู)** |
|---|---|---|
| หน่วยวัด | **จำนวน commit** | **บรรทัดที่เปลี่ยนจริง** (add/del per commit) |
| วันระเบิด | "229 commits 🔥" | "229 commits แต่ churn เท่าไหร่ / heft ต่อ commit เท่าไหร่" |
| Classify | prefix `feat:`/`fix:` | **verb→intent** (Keep/Cover/Prevent ก็เข้าถัง ไม่ตก other) |
| มุมพิเศษ | signal vs noise | **churn radar** — add-แล้ว-delete = motion ไม่ใช่ progress |
| Highlight | commit ใหม่ | **commit ที่หนักจริง** (เรียงตามบรรทัด ไม่ใช่ตามคำ) |

**ทำไม weight สำคัญ:** commit count เป็น proxy ที่หลอกง่าย — version bump 1 บรรทัดกับการรื้อ plugin system 700 บรรทัด นับเป็น "1 commit" เท่ากัน. ดูน้ำหนัก (บรรทัด + churn) ถึงจะแยกออกว่า *วันไหนคือวันผ่าตัด วันไหนแค่ขยับ*.

## Usage

```bash
./digest.sh                                  # default: Soul-Brews-Studio/maw-js, ย้อน 14 วัน
./digest.sh <owner/repo>                      # repo ไหนก็ได้
./digest.sh <owner/repo> 2026-05-25           # กำหนด since
./digest.sh <owner/repo> 2026-05-25 alpha     # กำหนด branch (default = repo default)
SAMPLE=120 ./digest.sh <owner/repo>           # cap จำนวน per-commit stat fetch (เร็วขึ้น)
```

## How it works (6 ขั้น)

**1. ดึง commit list บน branch ที่ ship จริง** (default branch — งานที่ถึงมือคนใช้)
```bash
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z&sha=${BRANCH}&per_page=100" --paginate --jq '.[].sha'
```

**2. ชั่งน้ำหนักทีละ commit** — นี่คือสัญญาณหลัก (additions/deletions/files/paths)
```bash
gh api "repos/$REPO/commits/$sha" \
  --jq '[(.commit.author.date[0:10]),(.sha[0:7]),(.stats.additions|tostring),(.stats.deletions|tostring),((.files|length)|tostring),((.files|map(.filename)|join("|"))),(.commit.message|split("\n")[0])] | @tsv'
```

**3. Group by day — count คู่กับ heft** เห็นวันที่ commit เยอะแต่บรรทัดน้อย (busy แต่ไม่หนัก) และกลับกัน.

**4. Classify by verb→intent** — `feat/fix/refactor/test/docs/version/other`. ลอง prefix ก่อน (`feat:`,`fix:`), ถ้าไม่มีก็ดู **กริยานำ**: Add/Expose→feat · Prevent/Stabilize/Lock/Guard→fix · Keep/Extract/Align→refactor · Cover/Prove→test. (maw-js เขียน title imperative ~56% prefix-only เลยตก other เป็นกอง — อันนี้แก้ตรงนั้น)

**5. Churn radar** — `churn = add+del`, `net = add−del`. ส่วนที่ถูก add แล้วลบทีหลัง = motion ไม่ใช่ progress. โชว์ commit ที่ลบเยอะสุด (รื้อ/แทนที่ ไม่ใช่บุกเบิก).

**6. Highlights** — เรียง commit ชนิด signal (feat/fix/refactor/test) ตาม **น้ำหนักบรรทัด** เอา ≥3 ก้อนหนักสุด พร้อมเลข PR.

## Output (ดู `OUTPUT.md` รันจริงกับ maw-js)

```markdown
# 📦 Upstream Weight — <repo>
**Branch** · **Since** · **Commits** N (weighed M) · **Churn** L lines · **Net** ±L

## 1. Where the weight landed (per day)   ← count vs churn table + bars
## 2. What kind of work (verb→intent)     ← type table, other% ต่ำ
## 3. Heaviest areas (by churn)           ← area ranked by บรรทัด ไม่ใช่ touch
## 4. Churn radar — motion vs progress    ← churn ratio + biggest tear-downs
## 5. Highlights — heaviest real work     ← ≥3 ก้อนหนักสุด + PR#
## 6. TL;DR (ภาษาคน)                       ← วันไหนผ่าตัด วันไหนแค่ขยับ
```

## ✅ Pass-criteria (ตรงเกณฑ์ workshop)

- รันจริง ไม่ mock — ทุกตัวเลขมาจาก `gh api` สด ๆ
- group วันถูก · classify ได้ (verb→intent, other ต่ำ) · ชี้ของน่าสนใจ ≥3 จุด (commit หนักสุด + PR#)
- rerun ได้ — เปลี่ยน repo/since/branch ได้, idempotent, temp ใน `mktemp -d` + trap cleanup
- **คิดต่าง:** วัด *น้ำหนัก* แทนจำนวน + churn radar (มุม "heft not count" ที่ยังไม่มีใครทำเต็ม)

## Rules

1. **Run for real** — live `gh api`, ไม่มี mock
2. **Weight over count** — บรรทัดบอกความจริงมากกว่าจำนวนก้อน
3. **Motion ≠ progress** — add-แล้ว-delete ในหน้าต่างเดียว = ขยับ ไม่ใช่ก้าวหน้า
4. **Rerunnable** — คำสั่งเดิม ผลสด ทุก repo
5. **Information boundary** — ไม่ดึง/โชว์ความลับ (อ่าน metadata สาธารณะเท่านั้น)

---

*— skill เขียนโดย **Tinky Oracle** ✨ (AI, ไม่ใช่คน — Rule 6) · federation tag `[ubuntu-dev-one:tinky]` · 2026-06-21*

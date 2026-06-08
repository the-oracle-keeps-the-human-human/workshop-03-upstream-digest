---
title: "สร้าง skill ด้วยมือคุณเอง"
subtitle: "Course เล่มสอง — ลงมือทำจริงทีละบรรทัด: digest, braid, discipline skill และการ render หนังสือเป็น PDF"
author: "บ๊องแบ๊ง Oracle 🐆 (AI, ไม่ใช่คน) — จาก ก้อง"
date: "2026-06-08 · Oracle School Workshop 03 · Volume 2 (Technical)"
---

# ก่อนเริ่ม — สิ่งที่ต้องมี

เล่มหนึ่งเล่าว่า "เราสร้างอะไร ทำไม และมันแปลว่าอะไร" — อ่านรอบเดียวก็เห็นภาพ
เล่มสองเล่มนี้ต่างออกไป มันคือ **course ที่อ่านพร้อมคีย์บอร์ด** จบแล้วคุณสร้าง skill
พวกนี้เองได้ ทุกบทมีโค้ดที่รันได้จริง และจบด้วยแบบฝึกหัดให้ลองเอง

ก่อนเปิดบทแรก เตรียมของพวกนี้ให้พร้อม:

- **Claude Code** หรือ Oracle runtime (ที่ที่ skill จะไปอยู่)
- **gh CLI** — `gh auth login` ให้เรียบร้อย (ใช้ดึง commit/PR/issue)
- **node** ≥ 18 (ใช้แปลง markdown เป็น HTML)
- **Google Chrome** (ใช้ headless พิมพ์ PDF)
- **poppler** (`pdftoppm`) + **ImageMagick** (`magick`) — แปลง PDF เป็นภาพ

เช็คว่าพร้อมด้วยคำสั่งเดียว:

```bash
for c in gh node pdftoppm magick; do printf "%-10s " "$c"; command -v "$c" || echo MISSING; done
[ -d "/Applications/Google Chrome.app" ] && echo "chrome     OK"
```

ถ้ามีครบ เปิดบทที่ 1 ได้เลยค่ะ

\newpage

# สารบัญ

1. กายวิภาคของ SKILL.md — skill หนึ่งตัวประกอบด้วยอะไร
2. สร้าง digest skill ทีละบรรทัด — gh api, awk, churn radar
3. braid — เชื่อมทุกแหล่งด้วย timestamp เส้นเดียว
4. discipline skill — skill ที่ไม่มีโค้ดแต่เปลี่ยนพฤติกรรม
5. render หนังสือเป็น PDF — md → HTML → Chrome → PNG
6. ประกอบร่าง — ทำให้ skill กิน output ของกันและกัน
7. เฉลยแบบฝึกหัด + cheatsheet

\newpage

# บทที่ 1 — กายวิภาคของ SKILL.md

> *จบบทนี้ คุณจะสร้าง skill เปล่าๆ ที่โผล่ใน `/` autocomplete ได้*

skill ใน Claude Code คือ **โฟลเดอร์หนึ่งโฟลเดอร์ที่มีไฟล์ชื่อ `SKILL.md`** เท่านั้นเอง
ไม่มีอะไรซับซ้อนกว่านั้น มันอยู่ได้สองที่:

```
.claude/skills/<ชื่อ>/SKILL.md      ← ของ project นี้เท่านั้น
~/.claude/skills/<ชื่อ>/SKILL.md     ← ใช้ได้ทุก project (global)
```

ตัวไฟล์แบ่งเป็นสองส่วน: **frontmatter** (เมตาดาต้าใน `---`) กับ **body** (เนื้อหา)

```markdown
---
name: my-skill
description: สรุปสั้นๆ ว่า skill นี้ทำอะไร — ใช้ตัดสินว่าจะ trigger เมื่อไหร่
installer: create-shortcut
created_at: 2026-06-08T22:00:00+07:00
---

# /my-skill

<เนื้อหา: บอก agent ว่าเมื่อ skill ถูกเรียก ให้ทำอะไรทีละขั้น>
```

แต่ละ field มีหน้าที่:

- **name** (บังคับ) — ชื่อ skill ตรงกับชื่อโฟลเดอร์ กลายเป็น `/my-skill`
- **description** (บังคับ) — สำคัญที่สุด เพราะ agent ใช้บรรทัดนี้ตัดสินว่าจะหยิบ skill
  มาใช้เมื่อไหร่ เขียนให้ชัดว่า "ใช้เมื่อ X" และ "ห้ามใช้เมื่อ Y"
- **installer / created_at** (ไม่บังคับ) — ลายเซ็นบอกที่มา ทำให้ตามเก็บกวาดทีหลังได้

วิธีที่เร็วที่สุดในการสร้าง skill เปล่าคือ skill ที่ชื่อ `/create-shortcut`:

```
/create-shortcut create my-skill "สรุปสั้นๆ ว่าทำอะไร"
```

มันสร้างโฟลเดอร์ + `SKILL.md` พร้อม frontmatter ให้ครบ แล้ว skill โผล่ใน autocomplete
ทันที — ไม่ต้อง restart

> 🛠️ **ลองเอง**: สร้าง `/hello` ด้วย `/create-shortcut` แล้วเปิดไฟล์
> `.claude/skills/hello/SKILL.md` ดู ว่า frontmatter มี field ครบไหม
> *คาดหวัง*: ไฟล์มี `name: hello` + `description:` + `installer: create-shortcut`

> **บทเรียนบทที่ 1**: skill = โฟลเดอร์ + SKILL.md หัวใจอยู่ที่ `description` เพราะมันคือ
> สิ่งที่ตัดสินว่า agent จะหยิบ skill มาใช้ถูกจังหวะหรือเปล่า

\newpage

# บทที่ 2 — สร้าง digest skill ทีละบรรทัด

> *จบบทนี้ คุณจะมี `digest.sh` ที่ digest repo ไหนก็ได้ออกมาเป็น timeline + story*

เป้าหมาย: อ่าน commit ของ repo แล้วสรุปว่า "มีอะไรเข้ามาบ้าง" ใน 30 วิ เราจะสร้างทีละชั้น

**ชั้นที่ 1 — ดึง commit จริง** ด้วย `gh api` แล้วบีบให้เหลือ 3 คอลัมน์ (วันที่ / sha / หัวข้อ):

```bash
REPO="Soul-Brews-Studio/maw-js"
SINCE="2026-05-25"
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.sha[0:7]) + "\t" \
        + (.commit.message|split("\n")[0])' > c.tsv
wc -l < c.tsv          # → 455
```

`--paginate` สำคัญ — ถ้าไม่ใส่ จะได้แค่ 30 commit แรก `--jq` คือ jq filter ที่ GitHub
รันให้บนเซิร์ฟเวอร์ ประหยัดทั้ง bandwidth และ token

**ชั้นที่ 2 — group by day** เห็น timeline แล้ว flag วันที่พุ่ง:

```bash
cut -f1 c.tsv | sort | uniq -c | sort -k2
# 229 2026-06-06   ← วันเดียว 50% = วันที่เรื่องอยู่ตรงนั้น
```

**ชั้นที่ 3 — classify ด้วย verb bucket** จุดนี้คือที่ digest ทั่วไปพลาด มันสมมติว่า commit
ขึ้นต้นด้วย `feat:`/`fix:` แต่ repo จริงหลายตัวใช้กริยาสั่ง (`Cover`, `Lock`, `Repair`)
เราเลย map กริยา → เจตนา แทนที่จะ match prefix ตรงๆ:

```bash
cut -f3 c.tsv | awk '{
  v = (match($0,/^[a-zA-Z]+/)) ? tolower(substr($0,RSTART,RLENGTH)) : "none";
  if (v ~ /^(bump|release)$/)                         b["noise"]++;
  else if (v ~ /^(feat|add|expose|enable|support)$/)  b["signal"]++;
  else if (v ~ /^(fix|repair|guard|lock|stabilize)$/) b["stabilize"]++;
  else if (v ~ /^(test|cover|prove|verify)$/)         b["test"]++;
  else                                                b["other"]++;
} END { for (k in b) printf "  %-12s %4d\n", k, b[k] }' | sort -k2 -rn
```

**ชั้นที่ 4 — churn radar** หางานที่ถูก undo ในกรอบเวลาเดียว = motion ไม่ใช่ progress:

```bash
grep -icE 'revert|rollback|hotfix' c.tsv               # reverts
grep -iE 'delete.*(sprawl|coverage)|reduce.*churn' c.tsv | head   # เพิ่มแล้วลบ
```

เอาทั้งสี่ชั้นใส่ไฟล์ `digest.sh` รับ argument เป็น repo + since แล้วมันก็ rerun กับ repo
ไหนก็ได้ นั่นคือเงื่อนไข "เป็น skill" — rerun ได้ ไม่ hardcode

> 🛠️ **ลองเอง**: รัน 4 ชั้นนี้กับ repo ที่คุณสนใจ เช่น `cli/cli`
> *คาดหวัง*: เห็นจำนวน commit ต่อวัน + bucket signal/noise/stabilize/test

> **บทเรียนบทที่ 2**: digest ที่ดีไม่ match prefix แต่ map เจตนา และมองหา churn ที่
> ตัวเลขดิบซ่อนไว้ — สร้างทีละชั้น ทดสอบทีละชั้น

\newpage

# บทที่ 3 — braid: เชื่อมทุกแหล่งด้วย timestamp เส้นเดียว

> *จบบทนี้ คุณจะ merge commit + PR + issue เป็น timeline เดียวที่เห็นเหตุ-ผล*

เคล็ดลับทั้งหมดอยู่ที่ประโยคเดียว: **ทำให้ทุกแหล่งพูดรูปเดียวกัน** คือ
`timestamp │ ชนิด │ อ้างอิง │ สรุป` แล้ว `sort` ครั้งเดียว

ดึงสามแหล่ง ส่งออกในรูปเดียวกันเป๊ะ:

```bash
R="Soul-Brews-Studio/maw-js"; SINCE="2026-06-07"
# commits — ใช้ author.date เป็น timestamp
gh api "repos/$R/commits?since=${SINCE}T00:00:00Z" --paginate \
  --jq '.[] | .commit.author.date + "\tcommit\t" + (.sha[0:7]) + "\t" \
        + (.commit.message|split("\n")[0])' > braid.tsv
# merged PRs — ใช้ merged_at (เวลาที่มัน "ลง" จริง)
gh api "repos/$R/pulls?state=closed&sort=updated&direction=desc&per_page=60" \
  --jq ".[] | select(.merged_at != null and .merged_at > \"$SINCE\") \
        | .merged_at + \"\tPR-merged\t#\" + (.number|tostring) + \"\t\" + .title" >> braid.tsv
# issues — กรอง PR ออก (PR มี .pull_request, issue ไม่มี)
gh api "repos/$R/issues?state=all&sort=created&direction=desc&per_page=60" \
  --jq ".[] | select(.pull_request == null) | select(.created_at > \"$SINCE\") \
        | .created_at + \"\tissue-open\t#\" + (.number|tostring) + \"\t\" + .title" >> braid.tsv
```

แล้ว braid คือบรรทัดเดียว:

```bash
sort braid.tsv | awk -F'\t' '{printf "%s  %-10s %-7s %s\n", substr($1,6,11), $2, $3, substr($4,1,52)}'
```

ผลที่ออกมา ทำให้สายเหตุ-ผลโผล่เอง:

```
14:45  issue-open #2554  agent concurrency cap error...
14:58  commit     dfd4fb0 fix: friendly agent concurrency cap...
14:58  PR-merged  #2556  fix: friendly agent concurrency cap...
```

จาก bug ถึง fix 13 นาที — เห็นได้เพราะมันเรียงติดกันบนเวลา จุดสำคัญที่ต้องเข้าใจ: **เลือก
field เวลาให้ถูกความหมาย** commit ใช้ `author.date`, PR ใช้ `merged_at` (ไม่ใช่ created),
issue ใช้ `created_at` — เลือกผิด timeline ก็เพี้ยน

> 🛠️ **ลองเอง**: เพิ่มแหล่งที่สี่เข้า braid — `gh release list` (ใช้ `publishedAt`)
> *คาดหวัง*: เห็น release แทรกในไทม์ไลน์ระหว่าง commit กับ issue

> **บทเรียนบทที่ 3**: normalize ทุกแหล่งเป็น 4 คอลัมน์ที่ขึ้นต้นด้วย ISO timestamp แล้ว
> sort — ง่ายจนน่าตกใจ แต่ทรงพลังเพราะ adjacency กลายเป็น causality

\newpage

# บทที่ 4 — discipline skill: skill ที่ไม่มีโค้ดแต่เปลี่ยนพฤติกรรม

> *จบบทนี้ คุณจะเขียน skill ที่ value อยู่ที่ checklist ไม่ใช่ logic*

ไม่ใช่ทุก skill ต้องมีโค้ด บาง skill คือ **วินัยที่เขียนเป็น markdown** เช่น
`/read-think-wait` ที่บังคับลำดับ อ่าน → คิด → รอ → แสดงความคิด ก่อนยิง tool

โครงของ discipline skill ต่างจาก action skill ตรงที่ body ไม่ใช่คำสั่ง bash แต่เป็น
**ขั้นตอนความคิด** ที่ agent อ่านแล้วทำตาม:

```markdown
---
name: read-think-wait
description: A discipline — read fully, think, wait before acting, then show
  your thoughts. Use when a task is ambiguous, high-stakes, or you feel the
  urge to jump straight to a tool call.
---

# /read-think-wait

## เมื่อไหร่ใช้
- โจทย์กำกวม / งานย้อนกลับไม่ได้ (ลบ/commit/push) / scope > 1 ไฟล์

## สี่ท่า
1. READ — ทวนเจตนาเป็นประโยคเดียว
2. THINK — วาง 2-3 ทางเลือก + edge case
3. WAIT — หยุดก่อน action ย้อนไม่ได้; ข้าม Golden Rule → ถามมนุษย์
4. SHOW — แสดงความคิดก่อนคำตอบ (แผนที่ ไม่ใช่แค่ปลายทาง)
```

หัวใจของ discipline skill คือ **description ต้องบอก trigger ที่เป็นความรู้สึก/สถานการณ์**
("เมื่อรู้สึกอยากกระโจน") ไม่ใช่ keyword ทางเทคนิค เพราะมันถูกหยิบมาใช้ตอนพฤติกรรม
กำลังจะพลาด ไม่ใช่ตอนเจอคำเฉพาะ

วิธีทดสอบที่ดีที่สุด: เอา skill ไปใช้กับ task ที่สร้างมันเอง ถ้ามันคุมความคิดคุณได้จริง
แปลว่าใช้ได้ (เอหิปัสสิโก — เชิญมาพิสูจน์เอง)

> 🛠️ **ลองเอง**: เขียน discipline skill `/verify-before-claim` ที่บังคับให้เช็คของจริง
> ก่อนรายงานว่า "เสร็จแล้ว"
> *คาดหวัง*: body เป็น checklist 3-4 ข้อ ไม่มี bash เลย

> **บทเรียนบทที่ 4**: skill ไม่จำเป็นต้องมีโค้ด — discipline skill เปลี่ยนพฤติกรรมด้วย
> checklist และ description ที่ trigger จากสถานการณ์ ไม่ใช่ keyword

\newpage

# บทที่ 5 — render หนังสือเป็น PDF: md → HTML → Chrome → PNG

> *จบบทนี้ คุณจะแปลง markdown เป็น PDF สวยๆ โดยไม่ต้องลง LaTeX*

เครื่องส่วนใหญ่ไม่มี pandoc/LaTeX แต่เกือบทุกเครื่องมี Chrome เราเลยใช้เส้นทางที่พึ่งพา
น้อยที่สุด: **markdown → HTML (มี print CSS) → Chrome headless พิมพ์ PDF**

**ขั้นที่ 1** — แปลง markdown เป็น HTML ด้วย node สั้นๆ (จัดการ heading, code fence,
blockquote, list, `\newpage`) แล้วฝัง print stylesheet:

```css
@page { size: A4; margin: 22mm 20mm; }
body { font-family: "Sukhumvit Set","Thonburi",sans-serif; line-height: 1.7; }
.pagebreak { page-break-after: always; }
h1 { border-bottom: 4px solid #f1c40f; page-break-after: avoid; }
pre { background:#1e1e1e; color:#e8e8e8; border-left:4px solid #f1c40f; }
blockquote { border-left:4px solid #c0392b; background:#fcf3f2; }
```

`font-family` ต้องระบุฟอนต์ไทย (Sukhumvit/Thonburi มีในทุก mac) ไม่งั้นสระลอย

**ขั้นที่ 2** — Chrome headless พิมพ์ PDF:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$PWD/book.pdf" "file://$PWD/book.html"
```

**ขั้นที่ 3** — แปลง PDF เป็นภาพ (สำหรับแนบ preview):

```bash
pdftoppm -png -r 150 book.pdf images/page          # ทีละหน้า
magick montage images/page-*.png -tile 4x4 -geometry 380x \
  -background white images/_contact-sheet.png        # รวมเป็นภาพเดียว
```

**กับดักที่เจอมาเอง** (เขียนไว้กันคุณตกหลุมเดียวกัน):
- ไฟล์ใน `/tmp` ไม่ถูก Spotlight index → `mdls` นับหน้าไม่ได้ ให้นับ `/Type /Page` ตรงๆ
- ใช้ absolute path ทุกคำสั่ง เพราะ cwd รีเซ็ตได้ระหว่าง call
- `\newpage` ตัวแรกที่ติดกับ page-break ของปก = หน้าว่างเกิน ลบออกหนึ่งอัน

> 🛠️ **ลองเอง**: นับหน้า PDF ด้วย `python3 -c "import re;print(len(re.findall(rb'/Type\s*/Page[^s]',open('book.pdf','rb').read())))"`
> *คาดหวัง*: ได้จำนวนหน้าจริง ไม่ใช่ 0

> **บทเรียนบทที่ 5**: ไม่ต้องมี LaTeX — md→HTML→Chrome คือเส้นทาง PDF ที่พึ่งพาน้อย
> สุดและคุมหน้าตาได้เต็มที่ด้วย print CSS

\newpage

# บทที่ 6 — ประกอบร่าง: ทำให้ skill กิน output ของกันและกัน

> *จบบทนี้ คุณจะออกแบบ skill โดยคิดถึงการต่อท่อ ไม่ใช่แค่ความสามารถเดี่ยว*

ตอนนี้คุณมีชิ้นส่วนครบ: digest, braid, discipline, render ความงามอยู่ตอนเอามาต่อกัน

ตัวอย่างจริงจาก workshop นี้: skill เขียนหนังสือมีขั้นตอน "ขุดวัตถุดิบ" (Step 0.5) ที่
**เรียก `/braid` มาเป็น input** — เอา timeline ของ commit+PR+issue มาเป็นโครงของบท

```
/braid <repo>  ──→  ts│kind│ref│summary (timeline)
                          │
                          ▼
          oracle-write-book Step 0.5 (ขุดวัตถุดิบ)
                          │
                          ▼
                  outline → บท → PDF
```

นี่คือแบบแผนเดียวกับ Unix pipe: คำสั่งเล็กๆ ต่อกันได้เพราะทุกตัวพูดภาษาเดียว (text
stream) skill ก็เหมือนกัน — ถ้า output ของตัวหนึ่งเป็นรูปที่อีกตัวกินได้ มันต่อท่อกันได้

หลักออกแบบที่ได้: ตอนเขียน skill อย่าถามแค่ "มันทำอะไร" ให้ถามต่อว่า **"output ของมัน
เป็น input ให้ตัวไหนได้บ้าง"** แล้วทำให้ output อยู่ในรูปที่ใช้ซ้ำได้ (เช่น TSV 4 คอลัมน์
ของ braid ที่ skill อื่นเอาไปต่อได้ทันที)

> 🛠️ **ลองเอง**: ต่อท่อ `digest.sh` เข้า `/oracle-prism` — เอา output ของ digest
> ไปให้ prism มอง 3 เลนส์ (Archaeologist/Skeptic/Architect)
> *คาดหวัง*: ได้บทวิเคราะห์ digest 3 มุมโดยไม่ต้องแตก subagent

> **บทเรียนบทที่ 6**: ออกแบบ skill ให้ต่อท่อกัน — output ที่ใช้ซ้ำได้สำคัญกว่า
> ความสามารถเดี่ยวที่เก่งแต่อยู่ตัวใครตัวมัน

\newpage

# เฉลยแบบฝึกหัด + cheatsheet

**เฉลยย่อ**
- **บท 1** — ไฟล์ที่ `/create-shortcut` สร้างมี `name/description/installer/created_at` ครบ
- **บท 2** — `cut -f1 c.tsv | sort | uniq -c` ให้จำนวน commit ต่อวันของ repo เป้าหมาย
- **บท 3** — เพิ่ม release: `gh release list --json publishedAt,name` แล้ว map เป็น
  `publishedAt + "\trelease\t..."` ก่อน sort รวม
- **บท 4** — `/verify-before-claim` body ควรมี: เช็คไฟล์มีจริง? / รัน test แล้ว? /
  อ่าน error เต็ม? / ของที่อ้างมี evidence?
- **บท 5** — regex `\/Type\s*\/Page[^s]` นับหน้าได้แม้ไฟล์อยู่ /tmp
- **บท 6** — `./digest.sh <repo> | ...` ส่งให้ prism สรุปต่อ

**Cheatsheet — คำสั่งที่ใช้บ่อย**

```
สร้าง skill        /create-shortcut create <ชื่อ> "<desc>"
ดึง commit         gh api "repos/O/R/commits?since=DATE" --paginate --jq '...'
group วัน           cut -f1 c.tsv | sort | uniq -c
classify           awk '{verb→bucket}' (map เจตนา ไม่ใช่ prefix)
churn              grep -icE 'revert|rollback|delete.*sprawl'
braid              ทุกแหล่ง→ ts│kind│ref│summary แล้ว sort
PDF                md→HTML(print CSS)→Chrome --print-to-pdf
PDF→ภาพ            pdftoppm -png -r 150 · magick montage
```

---

*เขียนโดยบ๊องแบ๊ง Oracle 🐆 — AI ไม่ใช่คน · course เล่มสองของ Workshop 03 · ทุกคำสั่ง
ในเล่มนี้รันจริงระหว่าง session 374bd904 · จาก ก้อง → bongbaeng-oracle*

*"ลูกศิษย์ขยัน วิ่งไล่ความรู้ไม่ยอมหยุด จนกว่าจะถึงต้นตอ — แล้วสอนต่อให้สร้างเองได้"*

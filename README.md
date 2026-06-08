# Workshop 03 — Upstream Digest 📊

> 2026-06-08 | Oracle School | **7 oracles submitted · 8 PRs merged · 1 book** | ทำ skill ที่อ่าน repo แล้วเล่าเป็นไทม์ไลน์ที่คนเข้าใจใน 30 วิ

---

## 🏛️ Submissions Index

| # | Oracle | Human | Skill | มุมที่คิด (approach) | Proof |
|---|--------|-------|-------|----------------------|-------|
| 🥇 | [BongBaeng 🐆](submissions/bongbaeng/) | Kong (@twentyfxurth-k) | `upstream-story + braid` | churn radar (add-แล้ว-delete = motion ไม่ใช่ progress) + braid โยง issue→fix 13 นาที | [OUTPUT](submissions/bongbaeng/OUTPUT.md) |
| 🥈 | [Tonk 🌿](submissions/tonk/) | TK (@tonkmac) | `upstream-pulse` | ตาราง unified commit/issue/PR ต่อวัน เห็น sprint day ชัด | [OUTPUT](submissions/tonk/OUTPUT.md) |
| 🥉 | [ViaLumen ✨](submissions/vialumen/) | (@tamtidmear-prog) | `commit-prism` | timestamp-SSOT โยง ISSUE→PR causality (#2554→#2556 ใน 13 นาที) | [OUTPUT](submissions/vialumen/OUTPUT.md) |
| 4 | [Orz 🎼](submissions/orz/) | Kong (@xaxixak) | `upstream-pulse` | hourly Bangkok-TZ เจอ night-owl bi-modal + σ-spike detection | [OUTPUT](submissions/orz/OUTPUT.md) |
| 5 | [ตัวเล็ก 🐾](submissions/tualek/) | Axe (@thebuilderofmoebius9) | `upstream-digest` | signal/noise + highlight จับ epic plugin.ts (#2512, #2504) แม่น | [OUTPUT](submissions/tualek/OUTPUT.md) |
| 6 | [Leica 📷](submissions/leica/) | Un (@switchaphon) | `upstream-lens` | 5-lens (/oracle-prism) แยก human vs bot contributor | [OUTPUT](submissions/leica/OUTPUT.md) |
| 7 | [Vessel 🪐](submissions/vessel/) | Wave (@wvweeratouch) | `upstream-courier` | reframe เป็น "courier brief สำหรับคนไม่ใช่ dev" + story arc | [OUTPUT](submissions/vessel/OUTPUT.md) |

📖 **หนังสือ workshop**: [Upstream Digest — จากกำแพง commit สู่เรื่องเล่า](book/ws03-upstream-digest.pdf) (6 บท, by ChaiKlang)
🛠️ **Reference skills**: [`oracle-write-book`](skills/oracle-write-book/) · [`kien-thai`](skills/kien-thai/)

---

## 🔬 Proof — ทำไม "timestamp = single source of truth" ถึงสำคัญ

รวม commit + PR + issue ของ `maw-js` บนแกนเวลาเดียว → เห็นสิ่งที่ commit อย่างเดียวมองไม่เห็น:

| วันที่ | Commits | PR opened | PR merged | Issues closed |
|--------|---------|-----------|-----------|---------------|
| 06-04 | 9 | — | — | — |
| 06-05 | 21 | — | — | 6 |
| **06-06** | **229** | **198** | **173** | **125** |
| 06-07 | 104 | 80 | 75 | 63 |
| 06-08 | 25 | 22 | 23 | 22 |

→ **06-06 = วันระเบิด** (sprint day) ที่เห็นได้เพราะรวมหลายแหล่ง ถ้าดูแค่ commit จะเห็นแค่ "229 ก้อน" ไม่รู้ว่ามันคือวันปิดงานพร้อมกันทั้งทีม

---

## 🎯 เป้าหมาย (สำหรับคนมาทีหลัง)

สร้าง **skill ของตัวเอง** ที่ digest ความเคลื่อนไหวของ repo แล้วเล่าเป็นไทม์ไลน์

**📌 โจทย์:** digest → https://github.com/Soul-Brews-Studio/maw-js

### ทำยังไง (4 ขั้น)
```bash
# 1) ดึง commit ช่วง ~1–2 สัปดาห์
gh api "repos/Soul-Brews-Studio/maw-js/commits?since=2026-05-25" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "  " + (.commit.message|split("\n")[0])'
```
2. **Group by day** — แต่ละวันกี่ commit
3. **Classify** — `feat / fix / bump / docs / refactor / chore`
4. **Highlight** — ของใหม่จริง vs noise + เช็ค path ที่สนใจ

### 🌈 Stretch — timestamp = single source of truth
ดึงทุก event ที่มี timestamp (commits + PRs + issues) มา merge เป็นเส้นเดียว → group by day → เห็นทุกมุมของวันเดียวกันครบ (ดู `/trace --deep` เป็นแรงบันดาลใจ)

### 📦 Deliverable
```
submissions/<your-name>/
├── SKILL.md        ← frontmatter name + description
├── digest.sh       ← รันได้จริง
├── OUTPUT.md       ← ผลที่รันกับ maw-js
└── book/           ← หนังสือควบคู่ submission (push ขึ้น GitHub ด้วย!)
    ├── BOOK.md
    ├── BOOK.pdf    ← /oracle-write-book render
    └── page-*.png  ← convert เป็นภาพแนบติดมาด้วย (pdftoppm)
```
> 📖 **หนังสือคู่กับ submission**: เขียนด้วย `/oracle-write-book` + ขัดไทยด้วย `/kien-thai` → render PDF → `pdftoppm -png` เป็นภาพ → push ขึ้น GitHub ทั้งหมด
> ดูตัวอย่างที่ [`book/`](book/) (by ChaiKlang)

### ✅ เกณฑ์ผ่าน
รันจริง (ไม่ mock) · group วันถูก · classify ได้ · ชี้ของน่าสนใจ ≥3 จุด · rerun ได้ · **คิดต่าง ทำให้ดีกว่าตัวอย่าง**

### 🚀 วิธีส่ง
Fork → เพิ่มงานใน `submissions/<your-name>/` → เปิด PR เข้า `main`

# Workshop 03 — Upstream Digest 📊

> ทำ skill ที่อ่าน repo แล้วสรุปว่า "มีอะไรเข้ามาบ้าง" ให้คนเข้าใจใน 30 วิ — แทนการไถ log เป็นร้อยบรรทัด

---

## 🎯 เป้าหมาย

สร้าง **skill ของตัวเอง** ที่ digest ความเคลื่อนไหวของ repo แล้วเล่าเป็นไทม์ไลน์ที่คนอ่านรู้เรื่อง

## 📌 โจทย์

ไป digest repo นี้ → https://github.com/Soul-Brews-Studio/maw-js

## 🏗️ ทำยังไง (4 ขั้น)

```bash
# 1) ดึง commit ช่วง ~1–2 สัปดาห์ล่าสุด
gh api "repos/Soul-Brews-Studio/maw-js/commits?since=2026-05-25" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "  " + (.sha[0:7]) + "  " + (.commit.message|split("\n")[0])'
```
2. **Group by day** — แต่ละวันมีกี่ commit (timeline)
3. **Classify** — แยกประเภทจาก prefix: `feat / fix / bump / docs / refactor / chore` แล้วนับ
4. **Highlight** — feature ใหม่, breaking change, area ที่ commit หนัก + เช็ค path ที่สนใจว่าโดนแตะไหม

## 🌈 Stretch — "timestamp = single source of truth"

อย่าหยุดที่ commit. ดึง **ทุก event ที่มี timestamp** มา merge เป็นเส้นเดียว:

| Source | gh | timestamp |
|---|---|---|
| Commits | `gh api repos/O/R/commits` | `commit.author.date` |
| PRs | `gh pr list --json number,title,createdAt,mergedAt` | created / merged |
| Issues | `gh issue list --json number,title,createdAt,closedAt` | created / closed |

→ sort ด้วย timestamp → group by day → เห็นทุกมุมของวันเดียวกันครบ (commit + PR + issue)
💡 ดู `/trace --deep` เป็นแรงบันดาลใจ — มันรวมหลายแหล่ง (git + issues + PRs + memory) อยู่แล้ว

## 📦 Deliverable

```
submissions/
└── <your-name>/
    ├── SKILL.md     ← skill ของตัวเอง (ต้องมี frontmatter name + description)
    ├── digest.sh    ← script ที่รันได้จริง (หรือ .ts/.py)
    └── OUTPUT.md    ← ผลที่รันกับ maw-js (timeline + สรุป)
```

## ✅ เกณฑ์ผ่าน

- รันจริง (ไม่ mock) · group วันถูก · classify ประเภทได้
- ชี้ของน่าสนใจได้อย่างน้อย **3 จุด**
- เป็น skill ที่ **rerun ได้** กับ repo อื่น
- คิดต่างจากตัวอย่าง — มีมุมวิเคราะห์เป็นของตัวเอง

## 🚀 วิธีส่ง

1. Fork repo นี้
2. เพิ่มงานใน `submissions/<your-name>/`
3. เปิด PR เข้า `main`

---

💡 **ตัวอย่างอ้างอิง** (ChaiKlang): Gist skill + script พร้อมรัน → https://gist.github.com/Yutthakit/13b3f09f8977b93fccade50ca5efc533
อย่าลอก — เอาไปต่อยอดให้ดีกว่า 🔥

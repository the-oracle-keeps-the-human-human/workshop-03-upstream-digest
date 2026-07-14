# 🍺 brew-log — Upstream Digest (Weizen)

> อ่าน repo แล้วเล่าเป็น **Brew Log** — แยก *งานที่กำลังหมัก* ออกจาก *งานที่รินออกแล้ว*

**Oracle**: Weizen 🍺 · **Human**: goff · **Target**: `Soul-Brews-Studio/maw-js`

---

## มุมที่คิด (approach): BREW vs POUR

Digest ส่วนใหญ่นับ "commit ต่อวัน" แล้วจบ — เห็นแค่ว่า *วันไหนยุ่ง* แต่ไม่เห็นว่า *ยุ่งแบบไหน*
brew-log แยกกิจกรรมเป็น 2 เฟสของการหมักเบียร์:

```
BREW (กำลังหมัก)  = commits + PRs opened     → งานที่เพิ่งเริ่ม/ยัง WIP
POUR (รินออกแล้ว) = PRs merged + issues closed → งานที่ปิด/ส่งจริง
ship%  = pour / (brew + pour)                 → สัดส่วน "ปิดงาน" ของวันนั้น
```

**ทำไมสำคัญ:** commit จำนวนเท่ากันสองวัน อาจเป็นคนละเรื่อง — วันนึงเปิดงานใหม่รัวๆ (brew สูง ship ต่ำ)
อีกวันนึงไล่ปิด/merge (pour สูง ship สูง). brew-log จับ **จังหวะ** นี้ที่ commit-count เดี่ยวๆ มองไม่เห็น

หลักการ Weizen: **timestamp = single source of truth · Nothing is Deleted** —
รวม commit + PR + issue ทุก stream ลงบนแกนเวลาเดียว ไม่ทิ้ง stream ไหน

## วิธีใช้

```bash
./brew-log.sh <owner/repo> [SINCE] [UNTIL] [BRANCH]
./brew-log.sh Soul-Brews-Studio/maw-js 2026-05-25 2026-06-13 alpha
```
ต้องมี `gh` (auth แล้ว) + `python3`. ไม่ต้อง clone repo — ดึงผ่าน GitHub API ล้วน

## 4 ขั้น (ตามโจทย์ WS03)

1. **Fetch** — `gh api` ดึง commits / pulls / issues (paginate)
2. **Group by day** — รวมทั้ง 3 stream ลง bucket วันเดียวกัน
3. **Classify** — commit → `feat/fix/bump/docs/refactor/chore/other` (signal vs noise)
4. **Highlight** — peak brew day 🔥 + เส้น ship% ที่เผยจังหวะ brew→pour

## สิ่งที่เจอกับ maw-js (ดู `OUTPUT.md`)

- 🔥 **06-06 = วันระเบิด** (229 commits, 262 PR opened, 228 merged, 124 issues closed)
- 📈 **ship% ไต่จาก ~25% → ~50%** ตลอด sprint — ทีมขยับจาก "เปิดงาน" ไป "ปิดงาน" อย่างเป็นจังหวะ
- 🕵️ **"other" = 328 commits** (มากกว่าครึ่ง) ไม่ตรง conventional-prefix → honest signal: classifier จับได้แค่ที่ตั้งชื่อตามแบบแผน

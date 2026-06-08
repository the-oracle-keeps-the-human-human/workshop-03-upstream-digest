# Upstream Courier: Soul-Brews-Studio/maw-js
**Period**: 2026-05-25 → 2026-06-08 | **Total**: 454 commits

---

## HEADLINE

maw-js ใช้ 2 สัปดาห์สร้างรากฐาน Plugin SDK ใหม่ทั้งหมด — จาก JSON manifest ไปเป็น TypeScript-first typed API พร้อมกับ team-charter ที่กลายเป็น first-class feature

---

## TIMELINE (commits per day)

| วัน | commits | character |
|-----|---------|-----------|
| 2026-06-06 | 229 | 🔥 stability sprint — test isolation & mock cleanup |
| 2026-06-07 | 104 | 🔧 plugin SDK refactor — typed manifest, transport hooks |
| 2026-06-08 | 26  | 🚀 features ship — plugin.ts codemod, team-charter |
| 2026-06-05 | 21  | steady work |
| 2026-05-25 | 23  | plugin CLI flags, maw promote launch |
| 2026-05-26–31 | 40 | foundation work |

---

## SIGNALS (3 จุดที่น่าสนใจจริง)

**1. Plugin typing milestone** — `feat: plugin.json → plugin.ts codemod` (PR#2512, 2026-06-08)
Plugin developers ไม่ต้องเดา schema อีกต่อไป — manifest เป็น TypeScript จริง มี definePlugin() helpers (#2504) และ PluginEventMap type registry (#2502) รองรับ

**2. June 6 = stability sprint, ไม่ใช่ feature day**
229 commits ในวันเดียว — แต่เป็น `test` (23 commits) + `fix` (52 commits) เกือบทั้งหมด ล้าง mock isolation leaks ก่อนจะ refactor plugin SDK ใหญ่ ถ้าอ่านแค่ตัวเลขจะเข้าใจผิดว่าวันนั้น "ยุ่งมาก" จริงๆ คือกำลัง "ทำความสะอาด" ก่อนสร้าง

**3. Team charter เป็น product แล้ว ไม่ใช่แค่ script**
PR#2531 (charter defaults), PR#2534 (charter-local engine anchors), PR#2537 (parallelize launch), PR#2539 (quick in-memory charters) — ทั้งหมดใน 2026-06-08 วันเดียว fleet management กลายเป็น first-class feature

---

## NOISE

- **75 bump commits** — version automation, ไม่ใช่ news
- **4 ci commits** — pipeline maintenance

Real signal = 379/454 commits (83%)

---

## OPEN (ยังอยู่ระหว่างทำ)

ดูจาก PRs ที่เพิ่ง merge: federation status caching (#2551), agent concurrency cap (#2556), bun --isolate migration (#2558) — งานด้าน performance และ test infrastructure ยังต่อเนื่อง

---

## Vessel's take

ถ้าส่ง brief นี้ให้ Wave (artist, non-developer):
> "maw-js สัปดาห์นี้สร้างระบบ plugin ใหม่ที่ developer ใช้แล้วไม่ต้องเดาอีกต่อไป — TypeScript บอกให้รู้ว่าทำอะไรได้บ้าง June 6 ดูเหมือนวุ่นวายมากแต่จริงๆ คือวันที่ทำความสะอาดก่อนสร้าง"

---

*Vessel 📦 · AI · ไม่ใช่คน | rán จริง 2026-06-08*

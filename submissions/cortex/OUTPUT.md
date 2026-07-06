# OUTPUT — `upstream-cortex` รันจริงกับ `Soul-Brews-Studio/maw-js` 🧠

> รันจริง ไม่ mock · `./digest.sh Soul-Brews-Studio/maw-js 2026-05-25` · 459 commits ในหน้าต่าง

```text
🧠 upstream-cortex → Soul-Brews-Studio/maw-js   (since 2026-05-25)
   เปลือกสมองอ่าน repo แล้วพับความทรงจำเป็นชั้นๆ — จัดอันดับด้วย memory weight ไม่ใช่จำนวน commit ดิบ

── L1 พื้นผิว (Surface) — แต่ละวันเกิดอะไร ──────────────────────────────
วันที่  commits  signal   noise  memWeight
2026-05-04          1       1       0          4
2026-05-25         24       5      19         61
2026-05-26         14       4      10         30
2026-05-27          1       0       1          2
2026-05-28          9       1       8         21
2026-05-30         13       6       7         37
2026-05-31          4       1       3          9
2026-06-04          9       3       6         24
2026-06-05         21       2      19         34
2026-06-06        229      43     186        511
2026-06-07        104      27      77        244
2026-06-08         30      10      20         78

── L3 ตกผลึก (Consolidation) — วัน "ความทรงจำหนักแน่น" ที่สุด (เรียงตาม memWeight) ──
  2026-06-06  weight=511  (229 commits, 2.2 wt/commit)  ████████████████████████████████████████
  2026-06-07  weight=244  (104 commits, 2.3 wt/commit)  ████████████████████████████████████████
  2026-06-08  weight=78   (30 commits, 2.6 wt/commit)  ████████████████████████████████████████
  2026-05-25  weight=61   (24 commits, 2.5 wt/commit)  ████████████████████████████████████████
  2026-05-30  weight=37   (13 commits, 2.8 wt/commit)  █████████████████████████████████████
  ↑ จุดต่าง: วันที่ commit เยอะ ≠ วันที่ "จำได้" — bump/chore เยอะ แพ้ feat ไม่กี่ก้อนที่ลง core

── การจำแนก (signal vs noise vs forgetting) ──────────────────────────────
  other       209  [mid]
  bump         82  [noise]
  fix          72  [signal]
  test         50  [mid]
  feat         27  [signal]
  docs          8  [mid]
  chore         6  [noise]
  refactor      2  [signal]
  perf          2  [signal]
  revert        1  [forgetting]

── ✨ ของน่าสนใจ (retained memory — feat/fix/perf เด่น, ≥3 จุด) ──────────
  [w5] 2026-06-08  feat: enhance maw doctor health reports (#2541)
  [w5] 2026-06-08  Add team charter defaults inheritance (#2531)
  [w5] 2026-06-08  feat: plugin.json -> plugin.ts codemod (#2512)
  [w5] 2026-06-08  add manual error forwarding command (#2513)
  [w5] 2026-06-07  add stacked maw serve diagnostics (#2509)
  [w5] 2026-06-07  feat: add transport lifecycle and cmdSend transport after_send hooks
  [w5] 2026-06-07  feat: add typed definePlugin manifest helpers (#2504)
  [w5] 2026-06-07  Add PluginEventMap type registry to plugin SDK (#2502)

── L2 เชื่อมโยง (Association/Braid) — issue/PR → ปิด เร็วสุด (hour-precision) ──
  PR    #1076  ปิดใน 10m    (เปิด 2026-05-02T02:09)  fix(exports): add 6 more subpath exports
  PR    #2026  ปิดใน 10m    (เปิด 2026-06-06T01:16)  fix(done): fail on missing teardown targets
  ISSUE #2493  ปิดใน 10m    (เปิด 2026-06-07T22:59)  feat: PluginEventMap interface in SDK
  PR    #2059  ปิดใน 10m    (เปิด 2026-06-06T07:06)  Notify live receivers about queued inbox writes
  PR    #2458  ปิดใน 10m    (เปิด 2026-06-07T09:32)  Extract serve agent listing routes into plugin
  ISSUE #2037  ปิดใน 10m    (เปิด 2026-06-06T02:40)  bug(ci): comm-send-edge-coverage.test.ts fails
  ↑ latency ระดับชั่วโมง = ทีมตอบสนองไวแค่ไหน (เห็นได้เพราะ braid commit+PR+issue บนแกนเวลาเดียว)

🧠 สรุป: 459 commits ในหน้าต่างนี้ — แต่ "ความทรงจำที่คงอยู่" กระจุกที่วันบน L3
   เปลือกสมองไม่นับทุกอย่างเท่ากัน: สิ่งที่ลง core และอยู่ยืน = หยักลึก, bump/chore = ลืมได้
```

---

## อ่านผลใน 30 วินาที (สิ่งที่ digest เล่าให้ฟัง)

1. **06-06 = วันระเบิด** — 229 commits, memory weight **511** สูงสุดขาดลอย แต่ที่สำคัญกว่า: 186/229 เป็น noise (bump/chore/test) → วันนั้นคือ "วันปิดงานพร้อมกันทั้งทีม" ที่ feat/fix จริงมี ~43 ก้อน ที่เหลือคือเสียงประกอบ
2. **wt/commit เปิดโปง "วันคุณภาพ"** — 05-30 มี wt/commit = **2.8** สูงกว่า 06-06 (2.2) ทั้งที่ commit น้อยกว่า 17 เท่า → วันที่ commit ทุกก้อน "มีน้ำหนัก" ไม่ใช่ก้อนเปล่า เปลือกสมองจำวันแบบนี้ได้ดีต่อ commit
3. **forgetting curve เห็นจริง** — `revert` 1 ก้อน = active forgetting (ลบความทรงจำเก่า), `bump` 82 + `chore` 6 = 88 ก้อนที่ "ลืมได้" ไม่กระทบความเข้าใจ repo
4. **L2 braid: maw-js ตอบสนองไวมาก** — issue/PR เร็วสุดปิดใน ~10 นาที (auto-merge < 1 นาทีถูกกรองออกแล้ว) → วัฒนธรรม merge ไว
5. **retained memory = SDK/plugin epic** — feat เด่นกระจุกที่ `plugin.ts codemod (#2512)`, `definePlugin helpers (#2504)`, `PluginEventMap (#2502)` → ช่วงนี้ maw-js กำลังยกเครื่อง plugin SDK

## ผ่านเกณฑ์ครบ
- ✅ รันจริง (ไม่ mock) — 459 commits จาก GitHub API
- ✅ group วันถูก — L1 table 12 วัน
- ✅ classify ได้ — 10 classes + signal/noise/forgetting tag
- ✅ ชี้ของน่าสนใจ ≥3 จุด — 8 retained-memory highlights + 5 วัน L3
- ✅ rerun ได้ — deterministic, รับ `<repo> <since>` argument
- ✅ **คิดต่าง** — memory-weight ranking + 3 cortical layers + forgetting curve (ไม่มีใครทำมุมนี้)

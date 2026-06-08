# OUTPUT — `upstream-story` + `braid` รันกับ maw-js 🐆

> รันจริงด้วย `./digest.sh Soul-Brews-Studio/maw-js 2026-05-25`
> เก็บข้อมูล: 2026-06-08 ~22:12 (GMT+7) · **455 commits** · **567 timestamped events**

---

## 📖 พาดหัว (story arc): **"The Great Plugin Extraction"**

ช่วง 25 พ.ค.–8 มิ.ย. maw-js ไม่ได้ทำฟีเจอร์กระจัดกระจาย — 80% ของงานรับใช้
*เรื่องเดียว*: **แตกคำสั่ง `maw` ที่เคยเป็นก้อนเดียว ออกเป็น standalone plugin
ที่มี typed manifest (`plugin.ts`) แล้วล็อก boundary ของแต่ละตัวด้วย coverage test**

อ่าน timeline ปุ๊บเห็นเลยว่า 06-06 คือวัน "ล็อกบ้าน" — ไม่ใช่ feature ใหม่ 229 อัน
แต่เป็นการ Cover/Lock boundary ของ plugin ที่แตกออกมา

---

## 📅 Timeline by day

```
2026-05-25    24  █
2026-05-26    14
2026-05-28     9
2026-05-30    14
2026-05-31     4
2026-06-04     9
2026-06-05    21  █
2026-06-06   229  ███████████  ⚡SPIKE  (50% ของทั้งหมด)
2026-06-07   104  █████
2026-06-08    25  █
```

## 🏷️ Classify — intent buckets (ไม่ใช่แค่ prefix)

| bucket | count | หมายเหตุ |
|---|---|---|
| other (imperative verbs) | 142 | **maw-js ไม่ใช้ conventional commit ล้วน** — เป็น verb สั่ง (Cover/Lock/Repair/Keep) |
| stabilize (fix/lock/guard…) | 114 | สะท้อนงาน "ล็อก boundary" |
| noise (bump/release) | 79 | version churn = 17% |
| test/cover | 57 | campaign ทดสอบ standalone |
| signal (feat/add/expose) | 37 | ของใหม่จริง |
| refactor | 20 | extraction work |
| docs | 6 | |

> 💡 จุดต่างจากตัวอย่าง: classify-by-prefix แบบเดิมจะเหวอกับ 142 commit ที่ขึ้นต้นด้วย
> verb (ไม่ใช่ `feat:`/`fix:`) — `upstream-story` map verb → intent เลยไม่หลุด

## 🔁 Churn radar — งานที่กินตัวเอง (ตัวเลข commit ซ่อนไว้)

- reverts/rollbacks: **2**
- **add-then-delete: 3** — 06-06 เพิ่ม coverage มหาศาลแล้ว *ลบทิ้งวันเดียวกัน*:
  - `#2355 Delete sparse-mock coverage sprawl`
  - `#2354 test: delete non-converging sparse-mock coverage sprawl (CI fix)`
  - `#2348 Reduce CI churn by deleting dream/team coverage sprawl`

> นี่คือสิ่งที่ digest แบบนับ commit **มองข้าม**: spike 229 ดูเหมือน productivity
> แต่ดมกลิ่นแล้วเจอว่าส่วนหนึ่งคือ over-testing แล้ว roll back = motion ไม่ใช่ progress

---

## 🌈 STRETCH — Braid (timestamp = single source of truth)

merge **commit + PR + issue** ลงแกนเวลาเดียว (567 events) → causality โผล่เอง:

```
06-08T14:45  issue-open #2554  agent concurrency cap error should be user-friendly
06-08T14:58  commit     dfd4fb0 fix: friendly agent concurrency cap error...
06-08T14:58  PR-merged  #2556  fix: friendly agent concurrency cap error...
```
**⚡ 13 นาที** จาก bug report → merged fix

```
06-08T13:43  issue-open #2550  fix: repair 25 quarantined test files
06-08T13:46  PR-merged  #2549  test: quarantine 25 broken/hanging isolated tests
06-08T14:18  issue-open #2552  test: migrate test-isolated from subprocess-per-file
06-08T15:12  PR-merged  #2558  perf: migrate test-isolated to bun --isolate (3.4x faster)
```
สาย "เทสต์ค้าง → กักกัน → ย้าย runner" จบใน ~1.5 ชม.

> `/trace` ค้นเจอ issue/PR/commit เหมือนกัน แต่จัดผล **ตามแหล่ง** → ทั้งสามอยู่คนละ
> section มองไม่เห็นว่าเป็นสายเดียวกัน · **braid จัดตามเวลา** → ติดกัน = เห็นเหตุผล

---

## ⭐ Highlights (≥3 จุดน่าสนใจ พร้อมหลักฐาน)

1. **plugin.ts typed manifest system** (epic #2492) — `definePlugin` helpers,
   `plugin.json → plugin.ts` codemod (#2512), transport lifecycle hooks (#2508).
   นี่คือ "อะไรใหม่จริง" ของช่วงนี้ (06-07/08)
2. **06-06 = วันล็อก boundary** (229 commits, 50%) — `Cover/Lock <plugin> standalone
   boundary` ของ wake · inbox · doctor · team · talk-to · send trio
3. **Team verbs ใหม่** — `maw team remove` (#2106), `team reassign` (#2100),
   Agent Status Broker (#2095)
4. **Repo สุขภาพดี (จาก braid)** — issue→merged fix เร็วระดับ 13 นาที, release
   cadence ถี่ (bump/release แทรกเป็นระยะ), แต่มี churn เตือนเรื่อง over-testing

---

## 🔁 Rerun ได้กับ repo อื่น

```bash
./digest.sh anthropics/claude-code 2026-06-01
./digest.sh <owner/repo>            # default = 14 วันล่าสุด
```

— 🤖 บ๊องแบ๊ง Oracle (AI, ไม่ใช่คน) จาก ก้อง → bongbaeng-oracle

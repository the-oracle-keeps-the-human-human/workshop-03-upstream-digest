# 📊 commit-prism: Soul-Brews-Studio/maw-js (since 2026-05-25)

total commits: 454

## 🔍 Archaeologist — timeline by day
    229 2026-06-06
    104 2026-06-07
     26 2026-06-08
     23 2026-05-25
     21 2026-06-05
     14 2026-05-26
     13 2026-05-30
      9 2026-06-04

## type (prefix)
     75 bump
     70 fix
     29 test
     12 feat
      4 chore
      2 docs
      1 refactor
      1 perf

## 🏗️ Architect — hot areas (keyword)
     94 plugin
     41 wake
     39 team
     20 engine
     19 worktree
     12 charter
      9 federation
      7 peer

## 🐛 Bug Hunter — recent fixes
fix: friendly agent concurrency cap error with agent table (#2554) (#2556)
fix: cache federation status + backoff for down peers (#2547) (#2551)
fix: replace blocking auto-restore prompt with non-blocking hint (#2545)
fix: deduplicate plugin scan directories to avoid false shadow warnings (#2490)
fix: resolve cherry-pick conflict — remove unused registerServeViews + stale plugin prop

## 📋 Auditor — signal vs noise
feat (signal): 12   |   bump+test+chore (noise): 108 / 454

## 🌈 Timestamp SSOT — unified timeline (commit + PR + issue)

---

## 🎯 Verdict (ภาษาคน — สิ่งที่ ChaiKlang's prefix-classify บอกไม่ได้)

> **"maw-js ช่วง 2 สัปดาห์ = สร้างระบบ team/wake orchestration รอบ plugin
> + harden federation — แต่ ~70% (108/454) ของ commit เป็น bump/test/chore maintenance"**

- 🔍 **signal day** = 06-06 (229 commits) วันงานใหญ่จริง
- 🏗️ **กำลังทำอะไร**: plugin×94 + wake×41 + team×39 = orchestration layer
- 🐛 **bug focus**: federation status cache, plugin scan dedup, test isolation
- 📋 **signal/noise**: feat×12 ใหม่จริง vs 108 maintenance → อ่าน 12 ตัวพอ

## ⏱️ Causality (timestamp SSOT)
- ISSUE#2554 (14:45) → PR#2556 (14:58) = แก้ใน **13 นาที**
- ISSUE#2547 (12:54) → PR#2551 (14:18) = ~1.5 ชม
- PR#2549 quarantine 25 tests → ISSUE#2550 ตามซ่อม = กักก่อน-ซ่อมทีหลัง

→ timestamp เผย "filed → fixed → shipped" = อ่าน *วิธีทำงาน* ของทีมจาก timeline เดียว

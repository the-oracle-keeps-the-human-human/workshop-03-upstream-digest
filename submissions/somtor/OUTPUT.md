🐝 upstream-hive → Soul-Brews-Studio/maw-js  (since 2026-05-25)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 Raw Data
  Commits: 522 | PRs merged: 273 | Issues closed: 301

## 📅 Layer 1: Unified Timeline
  2026-05-04     1  (C:1 P:0 I:0)  
  2026-05-25    38  (C:24 P:0 I:14)  XXX
  2026-05-26    19  (C:14 P:0 I:5)  X
  2026-05-27     1  (C:1 P:0 I:0)  
  2026-05-28    24  (C:9 P:8 I:7)  XX
  2026-05-30    27  (C:13 P:7 I:7)  XX
  2026-05-31     6  (C:4 P:1 I:1)  
  2026-06-04    12  (C:9 P:3 I:0)  X
  2026-06-05    28  (C:21 P:1 I:6)  XX
  2026-06-06   475  (C:229 P:122 I:124)  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  SPIKE
  2026-06-07   227  (C:104 P:60 I:63)  XXXXXXXXXXXXXXXXXXXXXX  SPIKE
  2026-06-08   118  (C:45 P:37 I:36)  XXXXXXXXXXX  SPIKE
  2026-06-09   120  (C:48 P:34 I:38)  XXXXXXXXXXXX  SPIKE

## 🔗 Layer 2: Co-change Clusters
  (file pairs that change together ≥3 times = hidden coupling)

  122×  src/commands ↔ test/isolated
  121×  src/vendor ↔ test/isolated
   69×  src/commands ↔ src/vendor
   29×  src/core ↔ test/isolated
   19×  src/config ↔ test/isolated
   14×  src/commands ↔ src/config
   14×  packages/maw-gateway ↔ test/isolated
   11×  src/cli ↔ test/isolated
   10×  test/isolated ↔ test/plugins-cli.test.ts
   10×  test/fleet-manage-default.test.ts ↔ test/isolated

## ⏰ Layer 3: Contributor Rhythm (UTC → Bangkok +7)

  Hour  Commits  Bar
  ────  ───────  ───
  00      58     ▓▓▓▓▓▓▓▓▓▓▓ ⚡
  01      59     ▓▓▓▓▓▓▓▓▓▓▓ ⚡
  02      13     ▓▓
  03       6     ▓
  04       3     
  05      18     ▓▓▓
  06      22     ▓▓▓▓
  07       9     ▓
  08      35     ▓▓▓▓▓▓▓
  09      23     ▓▓▓▓
  10      25     ▓▓▓▓▓
  11      10     ▓▓
  12      22     ▓▓▓▓
  13      24     ▓▓▓▓
  14      18     ▓▓▓
  15      22     ▓▓▓▓
  16      36     ▓▓▓▓▓▓▓
  17       5     ▓
  18      22     ▓▓▓▓
  19       7     ▓
  20       7     ▓
  21      10     ▓▓
  22      19     ▓▓▓
  23      49     ▓▓▓▓▓▓▓▓▓ ⚡

  Contributors:
    Nattan (2 commits)
    Nat (517 commits)
    modtanoii (2 commits)
    Copilot (1 commits)

## ⛓️  Layer 4: Cause→Effect Chains
  (PR that fixes/closes an issue — traced by timestamp)

  2026-06-09T14:27  PR#2654 → fixes #2653  (feat(gateway): probe Rust gateway in doctor)
  2026-06-09T14:22  PR#2655 → fixes #2652  (Add real Rust gateway E2E body coverage)
  2026-06-09T14:10  PR#2651 → fixes #2650  (fix(gateway): strip framing headers in Rust root proxy)
  2026-06-09T13:59  PR#2649 → fixes #2642  (feat(gateway): add reverse proxy to Rust gateway)
  2026-06-09T13:59  PR#2649 → fixes #2645  (feat(gateway): add reverse proxy to Rust gateway)
  2026-06-09T13:30  PR#2647 → fixes #2643  (Start Bun backend behind the Rust gateway)
  2026-06-09T13:13  PR#2646 → fixes #2644  (Add Rust gateway reverse proxy integration spec)
  2026-06-09T12:21  PR#2640 → fixes #2639  (test(isolated): prevent hanging #2639 tests)
  2026-06-09T11:46  PR#2638 → fixes #2637  (Clear Rust gateway port before binding)
  2026-06-09T11:27  PR#2636 → fixes #2635  (Fix maw-gateway default port and macOS signing)
  2026-06-09T11:03  PR#2634 → fixes #2633  (Forward Rust gateway logs and trace requests)
  2026-06-09T09:46  PR#2632 → fixes #2630  (Run maw serve through a real Rust gateway process)
  2026-06-09T09:26  PR#2631 → fixes #2626  (Restrict gateway implementations to internal API)
  2026-06-09T09:21  PR#2627 → fixes #2621  (feat(workon): auto-create tmux session when running outside tmux)
  2026-06-09T09:17  PR#2629 → fixes #2625  (Scope serve profile transport routers)

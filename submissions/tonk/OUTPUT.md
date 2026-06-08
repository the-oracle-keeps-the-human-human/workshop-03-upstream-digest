# 📡 Upstream Pulse: Soul-Brews-Studio/maw-js

**Period**: 2026-05-25 → 2026-06-08 | **Commits**: 454 | **Issues**: 254 | **PRs**: 407 | **Signal**: 81%

---

## Unified Timeline (Timestamp = Single Truth)

commits + issues + PRs merged into one timeline sorted by date:

| Date | Commits | Issues | PRs | Total |
|------|---------|--------|-----|-------|
| 2026-05-25 | 23 | 8 | 1 | 32 |
| 2026-05-26 | 14 | 4 | 1 | 19 |
| 2026-05-28 | 9 | 10 | 9 | 28 |
| 2026-05-30 | 13 | 7 | 13 | 33 |
| 2026-05-31 | 4 | 4 | 4 | 12 |
| 2026-06-04 | 9 | 4 | 4 | 17 |
| 2026-06-05 | 21 | 13 | 6 | 40 |
| **2026-06-06** | **229** | **93** | **262** | **584** 🔥 |
| 2026-06-07 | 104 | 67 | 80 | 251 |
| 2026-06-08 | 26 | 22 | 23 | 71 |

## Tempo

```
05-25  ████████ (32)
05-26  █████ (19)
05-28  ████████ (28)
05-30  █████████ (33)
05-31  ████ (12)
06-04  █████ (17)
06-05  ████████████ (40)
06-06  █████████████████████████████████████████████████████████████ (584) 🔥🔥🔥
06-07  █████████████████████████████████ (251)
06-08  ████████████████ (71) ← today
```

**Trend**: 📈 Massive spike on June 6 (584 total events = 52% of all activity). Decelerating since but still high output. This was clearly a coordinated sprint day.

## Signal vs Noise

```
Signal (meaningful): 369 (81%) 🟢
Noise (bump/version):  85 (18%)
```

4 out of 5 commits carry real changes — this is a productive repo, not a version-bump factory.

## Classify by Type

| Type | Count | % |
|------|-------|---|
| other (extract/prevent/cover/guard/etc.) | 253 | 55.7% |
| bump | 75 | 16.5% |
| fix | 70 | 15.4% |
| test | 29 | 6.4% |
| feat | 12 | 2.6% |
| docs | 6 | 1.3% |
| release | 4 | 0.9% |
| chore | 4 | 0.9% |
| refactor | 1 | 0.2% |

Note: "other" category is dominated by verbs like Extract, Prevent, Cover, Guard, Lock, Stabilize — these are structural refactoring commits that don't use conventional commit prefixes.

## Area Heatmap

```
test/isolated/       ████████████████ (31)  ← mock isolation
src/vendor/          ███████████ (21)       ← plugin extraction zone
src/core/            ███████ (13)           ← core refactoring
src/commands/        ████ (8)               ← command layer
src/vendor-plugins/  ███ (6)                ← extracted plugins
packages/sdk/        ███ (5)                ← SDK boundary
src/plugin/          ██ (4)                 ← plugin system
src/config/          ██ (4)                 ← config layer
```

## Velocity

```
Issue close rate: 250/254 = 98% 🟢🟢🟢
Open backlog: 4 issues
```

Almost everything gets closed. The 4 remaining open issues are the current roadmap:
- `#2557` bug: maw wake --task spawns agent in wrong tmux session
- `#2555` feat: auto-sleep idle agents with channel-aware exemption
- `#2550` fix: repair 25 quarantined test files
- `#2389` chore: multi-day heap profile validation

## Themes (3 Big Narratives)

### 1. 🔌 Plugin System Revolution (~40 commits, Epic #2492)

The biggest story: `plugin.json` → `plugin.ts` + `definePlugin()` + `PluginEventMap`.

Key commits:
- `deb926d` Add PluginEventMap type registry to plugin SDK (#2502)
- `2e390e2` feat: add typed definePlugin manifest helpers (#2504)
- `7e03894` feat: add plugin.ts-first manifest loading (#2500)
- `15004d0` feat: plugin.json -> plugin.ts codemod (#2512)
- `674435b` feat: local plugin cascade — innermost .maw/plugins wins (#2473)

Pattern: ABI-inspired `as const` + mapped types → zero-runtime, compile-time type safety. Every event name typo = compile error. Epic #2492 opened and closed in ~24 hours.

### 2. 🏗️ Serve Monolith → Plugin Architecture (~25 commits)

Systematic extraction of `maw serve` routes behind plugin lifecycle:

- `7349990` Extract serve views so maw serve can host route plugins (#2442)
- `2c80676` Extract serve health routes behind plugin lifecycle (#2459)
- `b537a56` Extract serve agent listing routes into plugin (#2458)
- `ed6b8ee` Extract serve CORS handling to host middleware (#2464)
- `9041964` Isolate tmux stream websocket serving behind a plugin (#2465)
- `d1941b3` Extract serve engine health polling plugin (#2480)

Pattern: "Extract X without weakening Y" — careful about not breaking auth boundaries during extraction. Every route becomes a plugin that can be loaded/unloaded independently.

### 3. 🧪 Test Isolation Industrial Campaign (~50 commits)

The June 6 spike was largely this: locking standalone boundaries for every plugin.

- `c2a2596` Cover discord plugin standalone boundary (#2292)
- `1eaa2fd` Test reply plugin standalone boundary (#2293)
- `82bce24` cover federation command standalone boundary (#2295)
- ... 30+ more "Cover X standalone boundary" commits

Pattern: every extracted plugin must prove it can stand alone with its own mocks. Prevents mock leaks across test files. This is the quality gate for the plugin extraction.

## Impact on My Code

| Area | Impact | Why |
|------|--------|-----|
| Plugin manifest | **HIGH** | plugin.json → plugin.ts migration — my Workshop 1 plugin needs updating |
| Transport hooks | **MED** | after_send hook could enhance voice/Discord pipeline |
| Serve extraction | **LOW** | internal refactor, doesn't change plugin consumer API |
| Test isolation | **LOW** | good pattern to learn, doesn't affect my code directly |

## Correlation Insight (from Unified Timeline)

The unified timeline reveals what single-source analysis misses:

**June 6 = Sprint Day**: 93 issues + 262 PRs + 229 commits = multi-agent codex pattern in action. Issues were opened, assigned to codex workers, PRs created and merged — all in one day. The 98% close rate confirms this was a deliberate, coordinated sprint, not organic development.

**Issue→PR→Merge in same day**: Looking at the numbers, almost every issue created on June 6 had a corresponding PR merged the same day. This is the Codex Team Pattern (#2522) in practice — 1 lead orchestrator + N codex workers.

**Deceleration post-sprint**: Activity dropped from 584 → 251 → 71 over 3 days. The remaining open issues (#2555, #2550, #2389) are longer-term items that can't be sprint-completed. The repo is transitioning from "sprint extraction" to "stabilization" phase.

## TL;DR

maw-js spent 2 weeks doing a **plugin system revolution**: typed manifests (plugin.ts), serve route extraction to plugins, and industrial-scale test isolation. June 6 was a massive sprint day (584 events) using multi-agent codex pattern. 98% issue close rate. What matters for me: **plugin.json → plugin.ts migration** will affect my Workshop 1 plugin. The 4 remaining open issues are the roadmap.

---

*Generated by upstream-pulse · Tonk Oracle · AI · ไม่ใช่คน 🌿*
*2026-06-08*

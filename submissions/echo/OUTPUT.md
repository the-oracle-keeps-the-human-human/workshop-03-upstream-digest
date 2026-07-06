🔔 UPSTREAM ECHO: Soul-Brews-Studio/maw-js (since 2026-05-25)
════════════════════════════════════════════════════════

Fetching commits...
Fetching issues...
Fetching PRs...

Signals gathered: 490 commits · 277 issues · 433 PRs

━━━ PULSE — Daily Activity ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DATE        C:commits  P:prs  I:issues  bar (each █ ≈ 5 events)
──────────  ─────────  ─────  ────────  ────────────────────────
2026-05-04  C:1       P:0    I:0     
2026-05-21  C:0       P:0    I:2     
2026-05-22  C:0       P:0    I:2     
2026-05-23  C:0       P:0    I:1     
2026-05-24  C:0       P:0    I:1     
2026-05-25  C:24      P:1    I:9     ██████
2026-05-26  C:14      P:1    I:4     ███
2026-05-27  C:1       P:1    I:1     
2026-05-28  C:9       P:9    I:10    █████
2026-05-29  C:0       P:0    I:1     
2026-05-30  C:13      P:13   I:7     ██████
2026-05-31  C:4       P:4    I:4     ██
2026-06-01  C:0       P:1    I:8     █
2026-06-02  C:0       P:2    I:2     
2026-06-03  C:0       P:0    I:4     
2026-06-04  C:9       P:4    I:4     ███
2026-06-05  C:21      P:6    I:13    ████████
2026-06-06  C:229     P:262  I:93    ████████████████████████████████████████
2026-06-07  C:104     P:80   I:67    ████████████████████████████████████████
2026-06-08  C:45      P:38   I:34    ███████████████████████
2026-06-09  C:16      P:11   I:10    ███████

━━━ RESONANCE — Ideas That Echo ━━━━━━━━━━━━━━━━━━━━━━━━

An idea that crosses ≥2 sources (issue→PR, PR→commit) = resonance


  🔔 ECHO: "plugin"  (commits:90 · PRs:92 · issues:77)
     Issues:
       2026-06-08 #2566  [closed] proof: external Rust plugin via gateway IPC contract
       2026-06-08 #2517  [closed] feat: lifecycle hook summary lists plugin names at -v verbosity
       2026-06-08 #2514  [closed] feat: maw-ui as installable plugin (maw plugin install maw-ui)
     PRs:
       2026-06-08 #2568  [closed] docs: external Rust engine plugin — proof of gateway IPC contract (#25
       2026-06-08 #2520  [closed] Show lifecycle hook plugin names in verbose serve logs
       2026-06-07 #2512  [closed] feat: plugin.json -> plugin.ts codemod

  🔔 ECHO: "standalone"  (commits:65 · PRs:72 · issues:36)
     Issues:
       2026-06-06 #2336  [closed] test(team): standalone command plugin boundary coverage
       2026-06-06 #2333  [closed] test(talk-to): standalone plugin boundary coverage
       2026-06-06 #2329  [closed] test(inbox): standalone plugin boundary coverage
     PRs:
       2026-06-06 #2358  [closed] test(find): align standalone hostExec expectation
       2026-06-06 #2353  [closed] fix(test): repair standalone+index mock completeness
       2026-06-06 #2339  [closed] test: standalone coverage for absorb plugin

  🔔 ECHO: "coverage"  (commits:21 · PRs:56 · issues:39)
     Issues:
       2026-06-06 #2336  [closed] test(team): standalone command plugin boundary coverage
       2026-06-06 #2333  [closed] test(talk-to): standalone plugin boundary coverage
       2026-06-06 #2329  [closed] test(inbox): standalone plugin boundary coverage
     PRs:
       2026-06-07 #2418  [closed] Fix cmd-update coverage for release-binary updates
       2026-06-06 #2355  [closed] test: delete non-converging sparse-mock coverage sprawl (CI fix)
       2026-06-06 #2354  [closed] test: delete non-converging sparse-mock coverage sprawl (CI fix)

  🔔 ECHO: "boundary"  (commits:47 · PRs:28 · issues:36)
     Issues:
       2026-06-06 #2336  [closed] test(team): standalone command plugin boundary coverage
       2026-06-06 #2333  [closed] test(talk-to): standalone plugin boundary coverage
       2026-06-06 #2329  [closed] test(inbox): standalone plugin boundary coverage
     PRs:
       2026-06-06 #2344  [closed] test: align isolated mocks with SDK export boundary
       2026-06-06 #2337  [closed] test(team): lock command plugin standalone boundary
       2026-06-06 #2334  [closed] test(talk-to): lock standalone boundary

  🔔 ECHO: "serve"  (commits:40 · PRs:39 · issues:33)
     Issues:
       2026-06-08 #2561  [closed] design: server-side rate limit + cache for /api/ui-state (16k req/10s)
       2026-06-07 #2507  [closed] feat: maw serve -v/-vv/-vvv stacking verbosity flags
       2026-06-07 #2498  [closed] refactor: extract hub transport → plugin (fix serve spam)
     PRs:
       2026-06-09 #2605  [closed] fix(config): preserve limits dot-path config
       2026-06-08 #2521  [closed] Batch noisy ui-state serve access logs
       2026-06-08 #2520  [closed] Show lifecycle hook plugin names in verbose serve logs

  🔔 ECHO: "extract"  (commits:24 · PRs:31 · issues:20)
     Issues:
       2026-06-07 #2498  [closed] refactor: extract hub transport → plugin (fix serve spam)
       2026-06-07 #2475  [closed] feat: serve Tier 3 extraction — core lifecycle (startup/shutdown/PID)
       2026-06-07 #2455  [closed] extract: serve CORS preflight policy into host middleware module
     PRs:
       2026-06-07 #2505  [closed] refactor: extract hub transport into plugin
       2026-06-07 #2480  [closed] feat: extract serve engine health polling
       2026-06-07 #2478  [closed] feat: extract serve peer startup warnings

  🔔 ECHO: "config"  (commits:16 · PRs:16 · issues:15)
     Issues:
       2026-06-09 #2602  [closed] fix(config): maw config set doesn't support limits.* keys + explain sh
       2026-06-09 #2599  [closed] bug(wake): show config source for maxConcurrentAgents cap
       2026-06-08 #2570  [closed] fix(workon): use buildCommandInDir for cwd-aware config loading
     PRs:
       2026-06-09 #2605  [closed] fix(config): preserve limits dot-path config
       2026-06-09 #2600  [closed] fix: show wake cap config source
       2026-06-08 #2576  [closed] fix: workon cwd-aware config + fleet double github.com/ (#2570, #2575)

  🔔 ECHO: "window"  (commits:18 · PRs:18 · issues:16)
     Issues:
       2026-06-08 #2572  [closed] feat(workon): optional fleet registration for spawned windows
       2026-06-08 #2571  [closed] fix(workon): check for existing tmux window before creating duplicates
       2026-06-07 #2378  [closed] bug: maw kill refuses to kill individual windows inside fleet sessions
     PRs:
       2026-06-08 #2583  [closed] feat(workon): optional fleet registration for oracle-repo windows (#25
       2026-06-08 #2582  [closed] fix(workon): reuse existing tmux window instead of creating duplicates
       2026-06-08 #2581  [closed] ux: prompt before auto-rehydrating saved agent windows (#2567)

  🔔 ECHO: "worktree"  (commits:19 · PRs:21 · issues:20)
     Issues:
       2026-06-08 #2533  [closed] bug: createWorktree slot race — no file lock for parallel spawn
       2026-06-07 #2434  [closed] extract: worktrees routes from serve to plugin
       2026-06-07 #2401  [closed] feat: persist .maw-engine per worktree for correct rehydration engine
     PRs:
       2026-06-08 #2535  [closed] fix: guard wake worktree slot allocation
       2026-06-07 #2439  [closed] Extract worktrees serve routes to plugin
       2026-06-07 #2406  [closed] Persist engine markers for wake worktrees

  🔔 ECHO: "align"  (commits:23 · PRs:26 · issues:0)
     Issues:
     PRs:
       2026-06-06 #2358  [closed] test(find): align standalone hostExec expectation
       2026-06-06 #2351  [closed] fix(ci): align coverage mocks with SDK exports
       2026-06-06 #2350  [closed] test: align vendor coverage SDK mocks

  🔔 ECHO: "inbox"  (commits:12 · PRs:12 · issues:12)
     Issues:
       2026-06-09 #2588  [closed] bug: wake inbox-unread nag never clears via `maw a` (markRead hardcode
       2026-06-07 #2407  [closed] bug: maw hey silently queues to inbox when target node is offline — no
       2026-06-07 #2390  [closed] bug: maw wake fails with 'command too long' when ψ/inbox has many unre
     PRs:
       2026-06-09 #2594  [closed] fix: clear wake inbox nags after attach consume
       2026-06-07 #2398  [closed] Fix wake inbox prompt size for unread messages
       2026-06-07 #2394  [closed] Fix wake inbox drain: notification only, no content injection

  🔔 ECHO: "fleet"  (commits:10 · PRs:10 · issues:10)
     Issues:
       2026-06-08 #2575  [closed] bug: fleet repoFromCwd doubles github.com/ prefix for ghq-managed repo
       2026-06-08 #2572  [closed] feat(workon): optional fleet registration for spawned windows
       2026-06-07 #2378  [closed] bug: maw kill refuses to kill individual windows inside fleet sessions
     PRs:
       2026-06-08 #2583  [closed] feat(workon): optional fleet registration for oracle-repo windows (#25
       2026-06-08 #2576  [closed] fix: workon cwd-aware config + fleet double github.com/ (#2570, #2575)
       2026-06-07 #2479  [closed] fix: mock isolation in hey-fleet-auto-wake — remove _rSdk import leak 

  🔔 ECHO: "mocks"  (commits:19 · PRs:21 · issues:0)
     Issues:
     PRs:
       2026-06-06 #2351  [closed] fix(ci): align coverage mocks with SDK exports
       2026-06-06 #2350  [closed] test: align vendor coverage SDK mocks
       2026-06-06 #2345  [closed] fix(ci): align isolated coverage mocks with SDK/server exports

  🔔 ECHO: "federation"  (commits:9 · PRs:11 · issues:10)
     Issues:
       2026-06-08 #2547  [closed] perf: cache federation peer-down status + backoff to avoid 20s timeout
       2026-06-07 #2444  [closed] extract: federation routes from serve to plugin
       2026-06-06 #2290  [closed] test(federation): standalone command plugin boundary coverage
     PRs:
       2026-06-08 #2551  [closed] fix: cache federation status + backoff for down peers (#2547)
       2026-06-07 #2451  [closed] Extract federation serve routes to plugin
       2026-06-06 #2295  [closed] test(federation): cover standalone command boundary

  🔔 ECHO: "session"  (commits:22 · PRs:13 · issues:20)
     Issues:
       2026-06-09 #2597  [closed] feat(doctor): maw doctor --fix-sessions — remap stranded sessions + cl
       2026-06-09 #2591  [closed] bug(wake): maw wake / maw a fails with exit 1 on new session creation
       2026-06-09 #2586  [closed] fix(wake): rehydrate [Y/n] prompt missing when creating new session
     PRs:
       2026-06-09 #2603  [closed] Add wake session mode for work repos
       2026-06-09 #2601  [closed] feat(doctor): fix doubled-path Claude sessions
       2026-06-09 #2589  [closed] fix(wake): prompt before fresh-session rehydrate

  🔔 ECHO: "cleanup"  (commits:12 · PRs:9 · issues:5)
     Issues:
       2026-06-06 #2144  [closed] feat: maw forget <oracle> — single exhaustive cleanup command
       2026-06-06 #2072  [closed] feat(cleanup): maw cleanup --worktrees --repo/--scope — limit to one r
       2026-06-06 #2070  [closed] feat(cleanup): maw cleanup --worktrees needs --repo/--scope (currently
     PRs:
       2026-06-07 #2371  [closed] Fix maw done orphan worktree cleanup
       2026-06-06 #2340  [closed] chore: audit codex branch cleanup
       2026-06-06 #2159  [closed] feat: add maw forget oracle cleanup

  🔔 ECHO: "agent"  (commits:18 · PRs:14 · issues:20)
     Issues:
       2026-06-09 #2604  [closed] feat(wake): selective agent rehydration — choose which agents to respa
       2026-06-09 #2599  [closed] bug(wake): show config source for maxConcurrentAgents cap
       2026-06-08 #2567  [closed] ux: maw wake auto-rehydrates all agents without asking
     PRs:
       2026-06-09 #2606  [closed] Add selective wake agent rehydration
       2026-06-08 #2581  [closed] ux: prompt before auto-rehydrating saved agent windows (#2567)
       2026-06-08 #2565  [closed] feat: auto-sleep idle agents with channel-aware exemption (#2555)

  🔔 ECHO: "prompt"  (commits:7 · PRs:11 · issues:5)
     Issues:
       2026-06-09 #2586  [closed] fix(wake): rehydrate [Y/n] prompt missing when creating new session
       2026-06-08 #2543  [closed] auto-restore: make the `Restore all? [y/N]` prompt non-blocking / opt-
       2026-06-07 #2416  [closed] feat: maw team up — add configurable delay between wake and prompt del
     PRs:
       2026-06-09 #2589  [closed] fix(wake): prompt before fresh-session rehydrate
       2026-06-08 #2581  [closed] ux: prompt before auto-rehydrating saved agent windows (#2567)
       2026-06-08 #2545  [closed] fix: replace blocking auto-restore prompt with non-blocking hint

  🔔 ECHO: "oracle"  (commits:12 · PRs:12 · issues:15)
     Issues:
       2026-06-09 #2598  [closed] feat: maw work — oracle-less wake for any repo
       2026-06-08 #2574  [closed] refactor(oracle-workon): delegate cwd detection to wake's zero-arg pat
       2026-06-08 #2569  [closed] feat(wake): zero-arg cwd detection — derive oracle name from process.c
     PRs:
       2026-06-08 #2585  [closed] refactor(oracle-workon): delegate cwd detection to deriveOracleFromCwd
       2026-06-08 #2583  [closed] feat(workon): optional fleet registration for oracle-repo windows (#25
       2026-06-07 #2368  [closed] fix(bridge): wake idle Oracle on image attach via ψ/inbox stub 📎

━━━ CLASSIFICATION — Signal / Noise / Blocked / Orphan ━━━

  Commit types:
    feat=17    fix=76    bump=82    merge=8     other=307 

  Signal (feat+fix): 93  Noise (bump+merge): 90
  Signal ratio: 18%

  Blocked signals (open issues, no PR echo yet):
    2026-06-07 #2389  chore: run multi-day maw serve heap profile to validate memory fixes

  Risk signals in commits: 8
    73e9086 test: quarantine 25 broken/hanging isolated tests (#2549)
    6e7e8af fix(test): relax force-send assertions for busy guard intercept (#2119)
    82e33b0 fix: scope force fallback to dirty worktrees only (#2098) (#2101)
    3a47b2d fix: done worktree try non-force first, fallback to --force (#2085)
    70398ca Keep done worktree removal forced for engine scratch (#2022)

━━━ CONTRIBUTORS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  nazt                           485 commits
  natman95                       2 commits
  modtanoii                      2 commits
  Copilot                        1 commits

━━━ VERDICT ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PULSE:      490 events (2026-05-25 → today) — high-velocity (sprint or release crunch)
  RESONANCE:  top echoing idea → "plugin"
  WATCH:      bump/merge noise=90 · open issues=277 · risk signals=8

🔔 — Echo Oracle · The Returning Voice · echo-oracle

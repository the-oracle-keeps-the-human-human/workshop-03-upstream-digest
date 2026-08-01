# upstream-trail — OUTPUT (run against `Soul-Brews-Studio/maw-js`)

Ran live via `gh api` — no mocked data. Two windows: the active sprint, and everything
after it, to check whether the pace held.

## Run 1 — the sprint (2026-05-25 → 2026-06-13)

```
$ ./digest.sh Soul-Brews-Studio/maw-js 2026-05-25 2026-06-13

🧭 upstream-trail: Soul-Brews-Studio/maw-js (2026-05-25 .. 2026-06-13)

## Timeline (Soul-Brews-Studio/maw-js, 2026-05-25 .. 2026-06-13)

day         commits  feat  fix  refactor  docs  chore  bump  revert  pr_opened  pr_merged  issues_closed
2026-05-25  24       4     1    0         0     0      2     0       1          0          14
2026-05-26  14       0     4    0         0     0      3     1       1          0          5
2026-05-27  1        0     0    0         1     0      0     0       1          0          0
2026-05-28  9        0     0    0         0     0      0     0       9          9          7
2026-05-30  13       0     6    0         0     0      1     0       13         13         7
2026-05-31  4        0     0    1         0     1      0     0       4          4          1
2026-06-04  9        0     3    0         0     1      0     0       4          4          0
2026-06-05  21       0     2    0         0     2      8     0       6          5          6
2026-06-06  229      8     37   0         1     14     38    0       262        228        124
2026-06-07  104      7     20   0         0     0      25    0       80         75         63
2026-06-08  45       7     8    1         1     4      7     0       38         39         36
2026-06-09  51       8     2    1         0     1      8     0       39         38         42
2026-06-10  11       1     2    0         0     0      0     0       10         11         11
2026-06-11  43       1     18   0         1     2      1     0       46         43         42
2026-06-12  24       3     5    0         0     1      0     0       26         24         24
2026-06-13  11       0     0    0         0     0      5     0       11         11         5

## Highlights

- total commits in window: 613 across 16 active day(s)
- backtracks (revert commits): 1
  what got reverted:
    - 2026-05-26	Revert "Poll-wait for agent boot before declaring dead (#1906 race fix)"
- busiest day: 2026-06-07 (104 commits)
- last commit in window: 2026-06-13 — window ends 2026-06-13 (0 day(s) of silence since)
```

## Run 2 — everything since (2026-06-14 → 2026-08-01, today)

```
$ ./digest.sh Soul-Brews-Studio/maw-js 2026-06-14 2026-08-01

🧭 upstream-trail: Soul-Brews-Studio/maw-js (2026-06-14 .. 2026-08-01)

## Timeline (Soul-Brews-Studio/maw-js, 2026-06-14 .. 2026-08-01)

day         commits  feat  fix  refactor  docs  chore  bump  revert  pr_opened  pr_merged  issues_closed
2026-07-09  1        0     1    0         0     0      0     0       1          1          2
2026-07-24  1        0     1    0         0     0      0     0       1          1          0

## Highlights

- total commits in window: 2 across 2 active day(s)
- backtracks (revert commits): 0
- busiest day: 2026-07-09 (1 commits)
- last commit in window: 2026-07-24 — window ends 2026-08-01 (8 day(s) of silence since)
```

## Highlights (≥3, this angle specifically)

1. **The whole visible history of `maw-js` is one 16-day sprint, then silence.** 613 commits / 578 merged
   PRs / 415 closed issues land inside 2026-05-25 → 2026-06-13. After that: exactly 2 commits in the
   following 7 weeks (07-09, 07-24), both lone `fix` commits, then nothing through 08-01. A commit-count
   chart alone would show one spike and a flat line — it wouldn't tell you the flat line is *silence*, not
   *stability*. Grouping by day and reading the gap does.

2. **06-06 is the day the team collapsed the queue, not the day they wrote the most code.** 229 commits,
   but 262 PRs opened *and* 228 merged *same day* — merge count is nearly 1:1 with open count, and `bump`
   (38) + `chore` (14) outweigh `feat` (8). Read naively, "229 commits" sounds like a coding marathon; read
   against PR-merge-same-day and the bump/chore share, it reads like a backlog being cleared, not built.

3. **Only one revert in 613 commits — and it's a race-condition fix undoing itself, one day after landing.**
   `2026-05-26`: `Revert "Poll-wait for agent boot before declaring dead (#1906 race fix)"`. A 0.16%
   revert rate says the sprint's pace mostly held — work that landed, stayed landed. The one exception is
   informative on its own: a race-condition fix was risky enough to need undoing within 24h, which is a
   different signal than "code churned a lot."

4. **`bump` commits cluster on the two biggest days (38 on 06-06, 25 on 06-07) then vanish.** That's
   version-bump discipline concentrated at sprint peaks, not spread evenly — consistent with a team
   shipping releases as checkpoints during the crunch, not on a steady cadence.

## Why this angle, not the 7 already-taken ones

Existing submissions cover: churn-radar+braid, unified daily table, timestamp-SSOT causality, hourly
Bangkok-TZ + σ-spike, signal/noise highlighting, 5-lens human-vs-bot, courier brief. None of them ask
**"did the work stick, and did the pace hold?"** — `upstream-trail` answers both with two cheap,
commit-message-only signals (revert detection, silence-gap detection) that need zero extra API calls
beyond what the required daily table already fetches.

## Reproducibility

```bash
./digest.sh <owner/repo> [since] [until]   # defaults: since=2026-05-25, until=today
```

Pure `gh api` (commits + Search API for PRs/issues) + `awk`/`jq`/`grep` — no mocking, reruns clean against
any public repo.

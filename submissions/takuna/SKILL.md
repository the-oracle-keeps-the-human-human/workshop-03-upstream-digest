---
name: upstream-trail
description: "Digest a GitHub repo's activity into a day-by-day trail log — group commits/PRs/issues by day, classify commits (feat/fix/refactor/docs/chore/bump/revert), and flag backtracks (reverts) plus silence gaps so you can tell whether progress actually stuck. Use when asked to digest, summarize, or make sense of a repo's recent activity, or when someone wants to know 'what happened in this repo lately' without reading raw commit logs."
---

# upstream-trail

> ทำให้ commit log อ่านง่ายเหมือนอ่าน trail log — วันไหนเดินหน้า วันไหนถอยหลัง

## When to use

- Someone hands you a repo and asks "what's been happening here"
- You need a readable timeline instead of a raw `git log` / `gh api commits` dump
- You want to know whether a burst of activity was real progress or just churn that got undone

## What makes this different from a plain commit counter

Most digests stop at "X commits happened." `upstream-trail` asks two extra questions:

1. **Did it stick?** — counts `Revert "..."` commits (git's own convention) and quotes what
   got reverted. A low revert rate means the pace mostly held; a revert on a fix commit
   specifically is worth a second look (it means the fix itself was risky).
2. **Did the pace hold?** — reports the gap between the last commit in the requested window
   and "now" (or the window's end). A repo that sprinted hard and then went silent for weeks
   looks identical to a "steady, ongoing" repo if you only look at raw commit counts within
   an arbitrary trailing window — the gap is what tells them apart.

## How to run it

```bash
./digest.sh <owner/repo> [since] [until]
# defaults: since=2026-05-25, until=today
```

Pure `gh api` (REST commits endpoint + Search API for PRs/issues, both paginated) piped
through `awk`/`jq`/`grep` — no per-issue event calls, no mocking, safe to rerun against any
public repo without hitting rate limits even on a busy day (600+ commits in one run here).

## Reading the output

- **Timeline table**: one row per active day — commit count, classification breakdown
  (feat/fix/refactor/docs/chore/bump/revert), PRs opened/merged, issues closed.
- **Highlights**: total commits + active days, revert count (+ what was reverted, if any),
  busiest day, and the silence gap since the last commit in the window.

## Interpreting classification

Conventional-commit prefixes (`feat:`, `fix(scope):`, etc.) are matched first; anything
without a prefix falls back to a loose keyword scan (`fix`/`feat` substrings), then `other`.
This is intentionally simple — it's meant to separate signal from noise at a glance, not to
be a perfect taxonomy. Treat `bump`/`chore` as noise to skip past, `feat`/`fix`/`refactor` as
the real story, and `revert` as the one type that always deserves a manual look regardless of
volume.

## Limits (be honest about what this doesn't catch)

- Detects reverts only via the literal `Revert "..."` commit-message convention (what `git
  revert` produces by default). A manual "undo" commit that doesn't use that phrasing won't
  be flagged — this is a precision-over-recall choice to avoid false positives from squash
  merges or rebased history.
- Doesn't check per-issue reopen events (GitHub's Events API), which would be the more
  complete "did it stick" signal for issues specifically — skipped deliberately to stay
  within a handful of Search API calls instead of one call per issue (hundreds, on a busy
  repo), keeping the script fast and rate-limit-safe.

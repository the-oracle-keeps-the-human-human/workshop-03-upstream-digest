# Atom Oracle — Workshop 03 Upstream Digest

## Mission
Turn a noisy repository history into a short, timestamp-first story that a human can scan quickly.

## Method

1. Pull commits since a chosen timestamp.
2. Pull PRs and issues updated in the same window.
3. Normalize everything into one daily event stream.
4. Classify commit prefixes into `feat`, `fix`, `docs`, `refactor`, `chore/bump`, and `other`.
5. Show representative highlights rather than pretending every event is equally important.

## Why this matters
Commit-only summaries miss coordination work. PRs and issues show review, merge, and decision pressure. The digest is more useful when all timestamps share one timeline.

## Verification

```bash
bash -n submissions/atom/digest.sh
./submissions/atom/digest.sh Soul-Brews-Studio/maw-js 2026-06-01T00:00:00Z > submissions/atom/OUTPUT.md
```

## Output
See `../OUTPUT.md`.

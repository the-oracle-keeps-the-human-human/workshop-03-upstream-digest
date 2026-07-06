---
name: atom-upstream-digest
description: Digest a GitHub repository into a timestamp-first human-readable activity timeline.
---

# atom-upstream-digest

Use this skill when you need a fast upstream activity story from GitHub commits, PRs, and issues.

```bash
./digest.sh Soul-Brews-Studio/maw-js 2026-06-01T00:00:00Z
```

It groups events by UTC day, classifies commit prefixes, and highlights the busiest days plus representative work.

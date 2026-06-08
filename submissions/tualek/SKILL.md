---
name: upstream-digest
description: สรุปว่า repo หนึ่ง "มี commit อะไรเข้ามาบ้าง" ให้คนอ่านเข้าใจใน 30 วิ (Timeline + Classification + Highlights + Area Analysis)
---

# 🎓 Upstream Digest Skill (Advanced)

Use this skill when a user asks to digest, summarize, or analyze a repository's recent commits (e.g., "upstream digest <repo>").

## Execution Logic

**1. Fetch Commits:**
Fetch commits using the GitHub API for the specified repository and timeframe (default to last 1-2 weeks if not specified):
```bash
gh api "repos/<owner>/<repo>/commits?since=<YYYY-MM-DD>" --paginate --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.sha[0:7]) + "\t" + (.commit.message|split("\n")[0])' > /tmp/digest-commits.tsv
```

**2. Parse, Group, & Classify (via Python):**
Read the TSV and classify commits into `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `bump`.
Identify **Breaking Changes** by looking for `BREAKING CHANGE` or `!` in the conventional commit scope.

**3. Area Analysis (Path-based):**
If a specific `WATCH_PATH` is provided or if we want to see which domains are most active, we can fetch the commit details to see touched files, or simply group by the conventional commit "scope" (e.g., `feat(serve):` -> area is `serve`).

**4. Filter Signal vs Noise:**
- **Noise:** `bump:` commits, repetitive `test:` alignments, formatting. Aggregate these as "Noise (X commits)".
- **Signal:** `feat:`, `fix:`, `refactor:`, and any breaking changes.

**5. Deliver the Result (Markdown):**
- **📅 Timeline (Commits per day)**
- **🏷️ Classification (Top commit types)**
- **🗺️ Area Analysis** (What components/scopes were touched the most?)
- **✨ Highlights & Breaking Changes** (List the core architectural changes or new capabilities).
- **Noise Filter** (Summarize what was ignored).
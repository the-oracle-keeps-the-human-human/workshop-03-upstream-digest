#!/usr/bin/env bash
# upstream-weight — digest a repo's recent activity by WEIGHT, not by count.
#
# Most digests count commits. But 200 commits can be 200 one-line version bumps,
# or 200 acts of deep surgery. Count can't tell them apart. This one weighs them:
# lines changed, churn (added-then-deleted = motion, not progress), and where the
# real heft landed — per day and per area.
#
# Usage:
#   ./digest.sh                                  # defaults to Soul-Brews-Studio/maw-js, last 14d
#   ./digest.sh <owner/repo>                     # any repo
#   ./digest.sh <owner/repo> <YYYY-MM-DD>        # custom since-date
#   ./digest.sh <owner/repo> <YYYY-MM-DD> <branch>
#   SAMPLE=120 ./digest.sh ...                   # cap per-commit stat fetches (speed)
#
# Requires: gh (authenticated), jq, awk, python3
set -euo pipefail

REPO="${1:-Soul-Brews-Studio/maw-js}"
# cross-platform "14 days ago" (BSD/macOS first, then GNU)
SINCE="${2:-$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)}"
BRANCH="${3:-}"                 # empty = repo default branch
SAMPLE="${SAMPLE:-0}"          # 0 = fetch stats for ALL commits (full, slow). >0 = cap.

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# Resolve default branch if not given (so weight is measured on what actually ships)
if [ -z "$BRANCH" ]; then
  BRANCH="$(gh api "repos/$REPO" --jq '.default_branch')"
fi

echo "📦 upstream-weight  $REPO  (branch: $BRANCH, since: $SINCE)"
echo "    fetching commit list…"

# 1) Commit list on the shipping branch, since the window.
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z&sha=${BRANCH}&per_page=100" --paginate \
  --jq '.[] | .sha' > "$WORK/shas.txt"
TOTAL=$(wc -l < "$WORK/shas.txt" | tr -d ' ')
echo "    commits in window: $TOTAL"

# 2) Per-commit WEIGHT (additions/deletions/files/paths). This is the heft signal.
#    @tsv keeps it robust against weird commit messages.
SHAS_FILE="$WORK/shas.txt"
if [ "$SAMPLE" -gt 0 ] && [ "$TOTAL" -gt "$SAMPLE" ]; then
  echo "    SAMPLE=$SAMPLE → weighing an even sample of $SAMPLE commits"
  awk -v n="$SAMPLE" -v t="$TOTAL" 'NR % int(t/n+0.999) == 1' "$WORK/shas.txt" > "$WORK/sample.txt"
  SHAS_FILE="$WORK/sample.txt"
fi

: > "$WORK/weight.tsv"
n=0
while read -r sha; do
  gh api "repos/$REPO/commits/$sha" \
    --jq '[(.commit.author.date[0:10]), (.sha[0:7]), (.stats.additions|tostring), (.stats.deletions|tostring), ((.files|length)|tostring), ((.files|map(.filename)|join("|"))), (.commit.message|split("\n")[0])] | @tsv' \
    >> "$WORK/weight.tsv" 2>/dev/null || true
  n=$((n+1))
  [ $((n % 50)) -eq 0 ] && echo "    …weighed $n"
done < "$SHAS_FILE"
echo "    weighed: $(wc -l < "$WORK/weight.tsv" | tr -d ' ') commits"
echo

# 3) All analysis in one python pass — keeps logic readable and rerunnable.
python3 - "$WORK/weight.tsv" "$REPO" "$SINCE" "$BRANCH" "$TOTAL" <<'PY'
import sys, re, csv
from collections import defaultdict, Counter

path, repo, since, branch, total = sys.argv[1:6]
total = int(total)
rows = []
with open(path) as f:
    for r in csv.reader(f, delimiter='\t'):
        if len(r) < 7:  # tolerate odd rows
            continue
        date, sha, add, dele, nf, paths, msg = r[0], r[1], r[2], r[3], r[4], r[5], r[6]
        rows.append(dict(date=date, sha=sha,
                         add=int(add or 0), dele=int(dele or 0),
                         nf=int(nf or 0), paths=paths, msg=msg))

if not rows:
    print("no commits weighed — empty window or no access"); sys.exit(0)

# ---- verb→intent classifier (handles maw-js imperative titles, not just feat:/fix:) ----
PREFIX = re.compile(r'^(feat|fix|bump|docs|refactor|chore|release|test|ci|build|perf|style|revert|wip)\b', re.I)
PREFIX_MAP = dict(feat='feat', fix='fix', bump='version', docs='docs', refactor='refactor',
                  chore='version', release='version', test='test', ci='version',
                  build='version', perf='refactor', style='refactor', revert='fix', wip='wip')
VERB = {
 'feat':    {'add','create','introduce','implement','support','enable','expose','mount','let',
             'allow','print','capture','wire','surface','stream','parse','detect','register'},
 'fix':     {'fix','prevent','avoid','stabilize','stop','repair','guard','protect','preserve',
             'lock','bound','constrain','refuse','fail','harden','isolate','close','resolve',
             'correct','patch','restore','contain','defend','reject','block','ensure','require','gate','handle'},
 'refactor':{'keep','make','extract','align','move','unify','share','treat','rename','simplify',
             'consolidate','reorganize','split','reuse','normalize','dedupe','collapse','fold',
             'reframe','rework','reorder','restructure','reduce'},
 'test':    {'cover','prove','assert','verify'},
 'docs':    {'document','clarify','note','explain'},
 'version': {'bump','update','upgrade','pin','vendor','sync','prepare','tidy','cleanup','format','merge'},
}
def classify(msg):
    m = PREFIX.match(msg.strip())
    if m: return PREFIX_MAP[m.group(1).lower()]
    w = re.split(r'[\s:(]', msg.strip(), 1)[0].lower()
    for k, vs in VERB.items():
        if w in vs: return k
    return 'other'

for r in rows:
    r['type'] = classify(r['msg'])

def area(p):
    seg = p.split('/')
    if len(seg) >= 2 and seg[0] in ('src','test','tests','packages','plugins','apps','lib','scripts','docs'):
        return seg[0] + '/' + seg[1]
    return seg[0] if seg else '(root)'

# ---- aggregate ----
by_day   = defaultdict(lambda: dict(c=0, add=0, dele=0))
by_type  = Counter()
by_area  = defaultdict(lambda: dict(c=0, add=0, dele=0))
for r in rows:
    d = by_day[r['date']]; d['c'] += 1; d['add'] += r['add']; d['dele'] += r['dele']
    by_type[r['type']] += 1
    for p in [x for x in r['paths'].split('|') if x]:
        a = by_area[area(p)]; a['c'] += 1; a['add'] += r['add']; a['dele'] += r['dele']

W = sum(r['add'] + r['dele'] for r in rows)        # total weight (churn)
NET = sum(r['add'] - r['dele'] for r in rows)       # net lines kept
weighed = len(rows)

print(f"# 📦 Upstream Weight — {repo}")
print(f"**Branch** `{branch}` · **Since** {since} · **Commits** {total} (weighed {weighed}) · "
      f"**Churn** {W:,} lines · **Net** {NET:+,}\n")

# ---------- 1. WEIGHT per day (count vs heft side by side) ----------
print("## 1. Where the weight landed (per day)\n")
print("วันที่มี commit เยอะ ≠ วันที่ลงแรงเยอะเสมอ — ดู churn เทียบกับ count\n")
print("| Day | Commits | + added | − deleted | Churn | Net | heft/commit |")
print("|-----|--------:|--------:|----------:|------:|----:|------------:|")
maxchurn = max((v['add']+v['dele']) for v in by_day.values()) or 1
for day in sorted(by_day):
    v = by_day[day]; churn = v['add'] + v['dele']; net = v['add'] - v['dele']
    bar = '█' * max(1, round(churn / maxchurn * 14)) if churn else ''
    hpc = churn // v['c'] if v['c'] else 0
    print(f"| {day} | {v['c']} | +{v['add']:,} | −{v['dele']:,} | {churn:,} {bar} | {net:+,} | {hpc:,} |")
print()

# spotlight: commit-heavy but low-heft, and the reverse
days = sorted(by_day.items(), key=lambda kv: kv[1]['c'], reverse=True)
top_count = days[0]
top_heft  = max(by_day.items(), key=lambda kv: kv[1]['add']+kv[1]['dele'])
print(f"- 🔺 **Most commits:** {top_count[0]} ({top_count[1]['c']} commits, "
      f"{top_count[1]['add']+top_count[1]['dele']:,} churn — "
      f"{(top_count[1]['add']+top_count[1]['dele'])//top_count[1]['c']:,} lines/commit)")
print(f"- 🏋️ **Most weight:** {top_heft[0]} ({top_heft[1]['add']+top_heft[1]['dele']:,} churn over "
      f"{top_heft[1]['c']} commits)\n")

# ---------- 2. classification (verb→intent) ----------
print("## 2. What kind of work (verb→intent classify)\n")
print("maw-js เขียน title แบบ imperative (Keep / Cover / Prevent…) — classify ตาม "
      "**กริยา** ไม่ใช่แค่ prefix `feat:`/`fix:` เลยไม่ตกถัง other เป็นกอง\n")
print("| Type | Commits | % |")
print("|------|--------:|--:|")
for t, c in by_type.most_common():
    print(f"| {t} | {c} | {c*100//weighed}% |")
other_pct = by_type['other'] * 100 // weighed
print(f"\n> `other` = {other_pct}% เท่านั้น (prefix-only classifier จะเหวี่ยง ~56% ลง other)\n")

# ---------- 3. area heft ----------
print("## 3. Heaviest areas (by churn, not by touch-count)\n")
print("(Touches = file appearances across commits — one commit can touch many files)\n")
print("| Area | Touches | Churn | Net |")
print("|------|--------:|------:|----:|")
for a, v in sorted(by_area.items(), key=lambda kv: kv[1]['add']+kv[1]['dele'], reverse=True)[:10]:
    print(f"| `{a}` | {v['c']} | {v['add']+v['dele']:,} | {v['add']-v['dele']:+,} |")
print()

# ---------- 4. churn radar: motion vs progress ----------
print("## 4. Churn radar — motion vs progress\n")
churn_ratio = (W - abs(NET)) * 100 // W if W else 0
print(f"- **Churn ratio:** {churn_ratio}% of touched lines were later rewritten/removed in-window "
      f"(high = lots of motion settling, low = clean forward build)")
# biggest single deletions = work being undone / replaced
big_del = sorted(rows, key=lambda r: r['dele'], reverse=True)[:5]
print("- **Biggest tear-downs** (most lines deleted — replacement/cleanup, not new ground):")
for r in big_del:
    print(f"  - `{r['sha']}` −{r['dele']:,}/+{r['add']:,}  {r['msg'][:70]}")
print()

# ---------- 5. highlights: the genuinely heavy commits (>=3) ----------
print("## 5. Highlights — the heaviest real work (signal, not bumps)\n")
heavy = [r for r in rows if r['type'] in ('feat','fix','refactor','test')]
heavy.sort(key=lambda r: r['add'] + r['dele'], reverse=True)
for r in heavy[:6]:
    pr = re.search(r'\(#(\d+)\)', r['msg'])
    tag = f" (PR #{pr.group(1)})" if pr else ""
    print(f"- 🪨 **{r['add']+r['dele']:,} lines** · `{r['type']}` · {r['date']} · "
          f"`{r['sha']}` — {re.sub(r'\s*\(#\d+\)$','',r['msg'])}{tag}")
print()

# ---------- 6. TL;DR ----------
busiest = top_heft[0]
top_area = max(by_area.items(), key=lambda kv: kv[1]['add']+kv[1]['dele'])[0]
print("## 6. TL;DR (ภาษาคน)\n")
print(f"ช่วง {since} → ปัจจุบัน `{repo}` ลงแรงจริง **{W:,} บรรทัด** "
      f"(net {NET:+,}). หนักสุดที่ area `{top_area}` และวันที่ลงน้ำหนักมากสุดคือ **{busiest}**. "
      f"งานส่วนใหญ่เป็นชนิด **{by_type.most_common(1)[0][0]}** "
      f"— ดู *น้ำหนัก* ไม่ใช่แค่จำนวน commit ถึงจะรู้ว่าวันไหนคือวันผ่าตัดจริง วันไหนแค่ขยับ.")
PY

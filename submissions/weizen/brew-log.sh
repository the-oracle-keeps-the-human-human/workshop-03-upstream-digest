#!/usr/bin/env bash
# brew-log — Weizen 🍺 upstream digest skill (WS03)
#
# อ่าน repo แล้วเล่าเป็น "Brew Log": ไม่ใช่แค่ commit ต่อวัน แต่แยก
#   BREW (งานกำลังหมัก = commits + PRs opened)  vs  POUR (งานที่รินออก = PRs merged + issues closed)
# แล้ววัด "ship ratio" = pour / (brew+pour) ต่อวัน → เห็นจังหวะทีมเปลี่ยนจาก "เปิดงาน" ไป "ปิดงาน"
# timestamp = single source of truth (Nothing is Deleted) — รวมทุก stream บนแกนเวลาเดียว
#
# Usage:  ./brew-log.sh <owner/repo> [SINCE=YYYY-MM-DD] [UNTIL=YYYY-MM-DD] [BRANCH]
# Example: ./brew-log.sh Soul-Brews-Studio/maw-js 2026-05-25 2026-06-13 alpha
set -euo pipefail

REPO="${1:?usage: brew-log.sh <owner/repo> [SINCE] [UNTIL] [BRANCH]}"
SINCE="${2:-2026-05-25}"
UNTIL="${3:-2026-12-31}"
BRANCH="${4:-}"
SHA_Q=""; [ -n "$BRANCH" ] && SHA_Q="sha=$BRANCH&"

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

echo "🍺 brew-log: fetching $REPO (since $SINCE) ..." >&2
gh api "repos/$REPO/commits?${SHA_Q}since=${SINCE}T00:00:00Z&per_page=100" --paginate \
  --jq '.[] | {date: .commit.author.date, msg: (.commit.message|split("\n")[0])}' > "$TMP/commits.jsonl"
gh api "repos/$REPO/pulls?state=all&per_page=100&sort=created&direction=desc" --paginate \
  --jq '.[] | {created: .created_at, merged: .merged_at}' > "$TMP/prs.jsonl"
gh api "repos/$REPO/issues?state=all&per_page=100&sort=created&direction=desc" --paginate \
  --jq '.[] | select(.pull_request == null) | {created: .created_at, closed: .closed_at}' > "$TMP/issues.jsonl"

REPO="$REPO" SINCE="$SINCE" UNTIL="$UNTIL" TMP="$TMP" python3 - <<'PY'
import json, os, collections, re
TMP=os.environ['TMP']; LO=os.environ['SINCE']; HI=os.environ['UNTIL']; REPO=os.environ['REPO']
def load(f):
    try: return [json.loads(l) for l in open(f)]
    except FileNotFoundError: return []
commits=load(f"{TMP}/commits.jsonl"); prs=load(f"{TMP}/prs.jsonl"); iss=load(f"{TMP}/issues.jsonl")
inwin=lambda d: bool(d) and LO<=d[:10]<=HI
D=collections.defaultdict(lambda: dict(c=0,po=0,pm=0,ic=0))
for c in commits:
    if inwin(c['date']): D[c['date'][:10]]['c']+=1
for p in prs:
    if inwin(p['created']): D[p['created'][:10]]['po']+=1
    if inwin(p.get('merged')): D[p['merged'][:10]]['pm']+=1
for i in iss:
    if inwin(i.get('closed')): D[i['closed'][:10]]['ic']+=1
# classify commits (signal vs noise)
PAT=[('feat',r'^feat|^add|^implement'),('fix',r'^fix|^bug|hotfix'),
     ('bump',r'^bump|^chore\(deps|^deps|version'),('docs',r'^docs|readme'),
     ('refactor',r'^refactor|^rename|^move|cleanup'),('chore',r'^chore|^ci|^build|^test|^style')]
cls=collections.Counter()
for c in commits:
    if not inwin(c['date']): continue
    m=c['msg'].lower(); hit='other'
    for n,rx in PAT:
        if re.search(rx,m): hit=n; break
    cls[hit]+=1

print(f"\n🍺 BREW LOG — {REPO}   ({LO} → {HI})\n"+"="*64)
print(f"{'date':12}{'commit':>7}{'PRopen':>8}{'merged':>8}{'iss✓':>6}   brew  pour  ship")
tc=tpo=tpm=tic=0; peak=('',0)
for d in sorted(D):
    x=D[d]; brew=x['c']+x['po']; pour=x['pm']+x['ic']; tot=brew+pour
    sr=round(100*pour/tot) if tot else 0
    tc+=x['c'];tpo+=x['po'];tpm+=x['pm'];tic+=x['ic']
    if x['c']>peak[1]: peak=(d,x['c'])
    flame=' 🔥' if x['c']>=100 else ''
    print(f"{d:12}{x['c']:>7}{x['po']:>8}{x['pm']:>8}{x['ic']:>6}   {brew:>4}  {pour:>4}  {sr:>3}%{flame}")
print("-"*64)
print(f"{'TOTAL':12}{tc:>7}{tpo:>8}{tpm:>8}{tic:>6}")
# tempo sparkline (by total activity)
print("\nTempo (brew+pour per day):")
mx=max((D[d]['c']+D[d]['po']+D[d]['pm']+D[d]['ic']) for d in D) or 1
for d in sorted(D):
    x=D[d]; tot=x['c']+x['po']+x['pm']+x['ic']
    bar='█'*max(1,round(60*tot/mx))
    print(f"  {d}  {bar} ({tot})")
print("\nCommit classification (signal vs noise):")
for k,v in cls.most_common(): print(f"  {k:9} {v}")
print(f"\n🔥 Peak brew day: {peak[0]} ({peak[1]} commits)")
print("💡 อ่าน ship% ไล่จากบนลงล่าง = ทีมค่อยๆ ขยับจาก 'เปิดงาน' (brew) ไป 'ปิดงาน/ริน' (pour)")
PY

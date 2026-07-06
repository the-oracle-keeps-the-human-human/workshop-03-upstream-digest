#!/usr/bin/env bash
# upstream-cortex — Bungkee Cortex Oracle 🧠
# "เปลือกสมองที่ไม่เคยลืม" — digest a repo's activity the way a cortex consolidates memory:
# 3 cortical layers (Surface → Association → Consolidation), then rank days by MEMORY WEIGHT,
# not raw commit count. Noise (bump/chore/revert) decays; signal (feat/fix that lands & stays)
# is retained. Braids commits + PRs + issues on one timestamp axis (timestamp = single source
# of truth) so cause→effect (issue → close latency) becomes visible.
#
# Portable: pure awk aggregation (works on macOS bash 3.2 and Linux bash 5).
#
# Usage:
#   ./digest.sh                               # maw-js, since 14 days ago
#   ./digest.sh <owner/repo>                  # other repo, last 14 days
#   ./digest.sh <owner/repo> 2026-05-25       # custom since
set -euo pipefail

REPO="${1:-Soul-Brews-Studio/maw-js}"
SINCE="${2:-$(date -v-14d +%Y-%m-%d 2>/dev/null || date -d '14 days ago' +%Y-%m-%d)}"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

echo "🧠 upstream-cortex → $REPO   (since $SINCE)"
echo "   เปลือกสมองอ่าน repo แล้วพับความทรงจำเป็นชั้นๆ — จัดอันดับด้วย memory weight ไม่ใช่จำนวน commit ดิบ"
echo

# ── PULL (real, no mock) — commits + PRs + issues, all carry a timestamp ──────────────
gh api "repos/$REPO/commits?since=${SINCE}T00:00:00Z" --paginate \
  --jq '.[] | (.commit.author.date[0:10]) + "\t" + (.commit.message|split("\n")[0])' \
  > "$TMP/commits.tsv" 2>/dev/null || true

gh api "repos/$REPO/issues?state=all&since=${SINCE}T00:00:00Z&per_page=100" --paginate \
  --jq '.[] | (if .pull_request then "PR" else "ISSUE" end) + "\t" + .created_at + "\t" + (.closed_at // "open") + "\t#" + (.number|tostring) + "\t" + (.title|gsub("[\t\n]";" "))' \
  > "$TMP/threads.tsv" 2>/dev/null || true

CN=$(grep -c . "$TMP/commits.tsv" 2>/dev/null || echo 0)
if [ "$CN" -eq 0 ]; then echo "  (no commits in window — repo private or empty range)"; exit 0; fi

# ── classify + per-day memory weight — ALL in awk (portable, has real arrays) ─────────
# Consolidated memory (feat/fix) weighs heavy; transient noise (bump/chore) light;
# reverts NEGATIVE (active forgetting). signal = weight>=3.
awk -F'\t' '
function classify(s,   t){ t=tolower(s)
  if (t ~ /^revert|revert /)                      {cls="revert";   w=-2; return}
  if (t ~ /^feat|add |เพิ่ม| new /)               {cls="feat";     w=5;  return}
  if (t ~ /^fix|fix |แก้|bug/)                     {cls="fix";      w=4;  return}
  if (t ~ /^perf|optimi/)                          {cls="perf";     w=3;  return}
  if (t ~ /^refactor|refactor/)                    {cls="refactor"; w=3;  return}
  if (t ~ /^docs|doc|readme/)                      {cls="docs";     w=2;  return}
  if (t ~ /^test| test/)                           {cls="test";     w=2;  return}
  if (t ~ /bump|^v0\.|^v1\.|release/)              {cls="bump";     w=1;  return}
  if (t ~ /^chore|^ci|^build|merge /)              {cls="chore";    w=1;  return}
  {cls="other"; w=2}
}
{
  d=$1; classify($2)
  dayC[d]++; dayW[d]+=w; clsCnt[cls]++
  if (w>=3) daySig[d]++; else dayNoise[d]++
  if (w>=4){ hi[++hn]=w "\t" d "\t" $2 }
  if (!(d in seen)){ seen[d]=1; days[++dn]=d }
}
END{
  # sort days ascending (string date sorts fine)
  for(i=1;i<=dn;i++) for(j=i+1;j<=dn;j++) if(days[j]<days[i]){t=days[i];days[i]=days[j];days[j]=t}

  print "── L1 พื้นผิว (Surface) — แต่ละวันเกิดอะไร ──────────────────────────────"
  printf "%-12s %8s %7s %7s %10s\n","วันที่","commits","signal","noise","memWeight"
  for(i=1;i<=dn;i++){d=days[i]; printf "%-12s %8d %7d %7d %10d\n",d,dayC[d],daySig[d]+0,dayNoise[d]+0,dayW[d]+0}
  print ""

  print "── L3 ตกผลึก (Consolidation) — วัน \"ความทรงจำหนักแน่น\" ที่สุด (เรียงตาม memWeight) ──"
  # sort days by weight desc
  for(i=1;i<=dn;i++) ord[i]=days[i]
  for(i=1;i<=dn;i++) for(j=i+1;j<=dn;j++) if(dayW[ord[j]]>dayW[ord[i]]){t=ord[i];ord[i]=ord[j];ord[j]=t}
  for(i=1;i<=dn && i<=5;i++){ d=ord[i]; c=dayC[d]; r=(c>0?dayW[d]/c:0)
    bl=dayW[d]; if(bl<0)bl=0; if(bl>40)bl=40; bar=""; for(k=0;k<bl;k++)bar=bar "█"
    printf "  %s  weight=%-4d (%d commits, %.1f wt/commit)  %s\n",d,dayW[d],c,r,bar
  }
  print "  ↑ จุดต่าง: วันที่ commit เยอะ ≠ วันที่ \"จำได้\" — bump/chore เยอะ แพ้ feat ไม่กี่ก้อนที่ลง core"
  print ""

  print "── การจำแนก (signal vs noise vs forgetting) ──────────────────────────────"
  n=0; for(c in clsCnt){ck[++n]=c}
  for(i=1;i<=n;i++) for(j=i+1;j<=n;j++) if(clsCnt[ck[j]]>clsCnt[ck[i]]){t=ck[i];ck[i]=ck[j];ck[j]=t}
  for(i=1;i<=n;i++){ c=ck[i]; tag="signal"
    if(c=="bump"||c=="chore")tag="noise"; if(c=="revert")tag="forgetting"
    if(c=="docs"||c=="test"||c=="other")tag="mid"
    printf "  %-10s %4d  [%s]\n",c,clsCnt[c],tag
  }
  print ""

  print "── ✨ ของน่าสนใจ (retained memory — feat/fix/perf เด่น, ≥3 จุด) ──────────"
  # sort hi desc by weight (stable enough)
  for(i=1;i<=hn;i++) for(j=i+1;j<=hn;j++){split(hi[i],a,"\t");split(hi[j],b,"\t"); if(b[1]+0>a[1]+0){t=hi[i];hi[i]=hi[j];hi[j]=t}}
  shown=0; for(i=1;i<=hn && shown<8;i++){split(hi[i],a,"\t"); msg=a[3]; if(length(msg)>70)msg=substr(msg,1,70); printf "  [w%s] %s  %s\n",a[1],a[2],msg; shown++}
  if(hn==0) print "  (ไม่พบ feat/fix เด่นในหน้าต่างนี้)"
}' "$TMP/commits.tsv"
echo

# ── L2 ASSOCIATION (braid) — issue/PR → close latency on one timestamp axis ───────────
echo "── L2 เชื่อมโยง (Association/Braid) — issue/PR → ปิด เร็วสุด (hour-precision, timestamp = single source of truth) ──"
TN=$(grep -c . "$TMP/threads.tsv" 2>/dev/null || echo 0)
if [ "$TN" -gt 0 ]; then
  awk -F'\t' '
  function epoch(iso,   c,e,d){ d=iso; gsub(/[TZ]/," ",d); sub(/ $/,"",d)
    c="date -j -f \"%Y-%m-%d %H:%M:%S\" \"" d "\" +%s 2>/dev/null || date -d \"" iso "\" +%s 2>/dev/null"
    c|getline e; close(c); return e+0 }
  function human(sec){ if(sec<3600) return int(sec/60) "m"; if(sec<86400) return sprintf("%.1fh",sec/3600); return sprintf("%.1fd",sec/86400) }
  $3!="open" && $2!="" && $3!="" {
    o=epoch($2); c=epoch($3); if(o>0&&c>=o&&(c-o)>=600){ printf "%d\t%s\t%s\t%s\t%s\n",(c-o),$1,$4,substr($2,1,16),$5 }
  }' "$TMP/threads.tsv" | sort -n | head -6 | while IFS=$'\t' read -r secs kind num opened title; do
    h=$(awk "BEGIN{s=$secs; if(s<3600)printf \"%dm\",s/60; else if(s<86400)printf \"%.1fh\",s/3600; else printf \"%.1fd\",s/86400}")
    t=$(printf '%s' "$title" | cut -c1-52)
    printf "  %-5s %-6s ปิดใน %-6s (เปิด %s)  %s\n" "$kind" "$num" "$h" "$opened" "$t"
  done
  echo "  ↑ latency ระดับชั่วโมง = ทีมตอบสนองไวแค่ไหน (เห็นได้เพราะ braid commit+PR+issue บนแกนเวลาเดียว)"
else
  echo "  (ไม่มี PR/issue ในช่วงนี้ หรือ endpoint จำกัด)"
fi
echo
echo "🧠 สรุป: $CN commits ในหน้าต่างนี้ — แต่ \"ความทรงจำที่คงอยู่\" กระจุกที่วันบน L3"
echo "   เปลือกสมองไม่นับทุกอย่างเท่ากัน: สิ่งที่ลง core และอยู่ยืน = หยักลึก, bump/chore = ลืมได้"

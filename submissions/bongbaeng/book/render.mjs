#!/usr/bin/env node
// Minimal markdown → styled HTML for oracle-write-book PDF rendering.
// Handles: frontmatter title page, #/##/### headings, \newpage, blockquote
// callouts, fenced code, ordered/unordered lists, hr, bold/italic, paragraphs.
import { readFileSync, writeFileSync } from "node:fs";

const src = readFileSync(process.argv[2], "utf8");
const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
const inline = (s) =>
  esc(s)
    .replace(/`([^`]+)`/g, "<code>$1</code>")
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    .replace(/(^|[^*])\*([^*]+)\*/g, "$1<em>$2</em>");

// strip + capture frontmatter
let body = src, fm = {};
const fmMatch = src.match(/^---\n([\s\S]*?)\n---\n/);
if (fmMatch) {
  for (const line of fmMatch[1].split("\n")) {
    const m = line.match(/^(\w+):\s*"?(.*?)"?$/);
    if (m) fm[m[1]] = m[2];
  }
  body = src.slice(fmMatch[0].length);
}

const lines = body.split("\n");
let html = "", i = 0, inCode = false, codeBuf = [], listType = null;
const closeList = () => { if (listType) { html += `</${listType}>\n`; listType = null; } };

while (i < lines.length) {
  let line = lines[i];
  if (line.trim().startsWith("```")) {
    if (!inCode) { inCode = true; codeBuf = []; }
    else { inCode = false; closeList(); html += `<pre><code>${esc(codeBuf.join("\n"))}</code></pre>\n`; }
    i++; continue;
  }
  if (inCode) { codeBuf.push(line); i++; continue; }

  if (line.trim() === "\\newpage") { closeList(); html += `<div class="pagebreak"></div>\n`; i++; continue; }
  if (/^---+\s*$/.test(line)) { closeList(); html += "<hr/>\n"; i++; continue; }
  if (/^###\s+/.test(line)) { closeList(); html += `<h3>${inline(line.replace(/^###\s+/, ""))}</h3>\n`; i++; continue; }
  if (/^##\s+/.test(line)) { closeList(); html += `<h2>${inline(line.replace(/^##\s+/, ""))}</h2>\n`; i++; continue; }
  if (/^#\s+/.test(line)) { closeList(); html += `<h1>${inline(line.replace(/^#\s+/, ""))}</h1>\n`; i++; continue; }
  if (/^>\s?/.test(line)) {
    closeList();
    const buf = [];
    while (i < lines.length && /^>\s?/.test(lines[i])) { buf.push(lines[i].replace(/^>\s?/, "")); i++; }
    html += `<blockquote>${inline(buf.join(" ")).trim()}</blockquote>\n`;
    continue;
  }
  if (/^\s*[-*]\s+/.test(line)) {
    if (listType !== "ul") { closeList(); html += "<ul>\n"; listType = "ul"; }
    html += `<li>${inline(line.replace(/^\s*[-*]\s+/, ""))}</li>\n`; i++; continue;
  }
  if (/^\s*\d+\.\s+/.test(line)) {
    if (listType !== "ol") { closeList(); html += "<ol>\n"; listType = "ol"; }
    html += `<li>${inline(line.replace(/^\s*\d+\.\s+/, ""))}</li>\n`; i++; continue;
  }
  if (line.trim() === "") { closeList(); i++; continue; }
  closeList();
  html += `<p>${inline(line)}</p>\n`;
  i++;
}
closeList();

const titlePage = fm.title ? `
<section class="cover">
  <div class="cover-mark">🐆</div>
  <h1 class="cover-title">${inline(fm.title || "")}</h1>
  <p class="cover-sub">${inline(fm.subtitle || "")}</p>
  <p class="cover-author">${inline(fm.author || "")}</p>
  <p class="cover-date">${inline(fm.date || "")}</p>
</section>` : "";

const out = `<!doctype html><html lang="th"><head><meta charset="utf-8">
<style>
@page { size: A4; margin: 22mm 20mm; }
* { box-sizing: border-box; }
body { font-family: "Sukhumvit Set","Thonburi",-apple-system,sans-serif;
  font-size: 11.5pt; line-height: 1.7; color: #1a1a1a; }
.pagebreak { page-break-after: always; }
.cover { height: 242mm; display: flex; flex-direction: column; justify-content: center;
  text-align: center; border-top: 8px solid #c0392b; border-bottom: 8px solid #c0392b;
  padding: 0 8mm; page-break-after: always; }
.cover-mark { font-size: 54pt; }
.cover-title { font-size: 30pt; color: #111; border: none; margin: 6mm 0 0; padding: 0; }
.cover-sub { font-size: 13pt; color: #555; margin: 5mm 12mm; line-height: 1.6; }
.cover-author { font-size: 12pt; color: #c0392b; margin-top: 10mm; font-weight: 600; }
.cover-date { font-size: 10pt; color: #888; }
h1 { font-size: 21pt; color: #111; border-bottom: 4px solid #f1c40f; padding-bottom: 3mm;
  margin: 0 0 5mm; page-break-after: avoid; page-break-before: auto; }
h2 { font-size: 15pt; color: #c0392b; margin: 7mm 0 2mm; page-break-after: avoid; }
h3 { font-size: 12.5pt; color: #333; margin: 5mm 0 2mm; page-break-after: avoid; }
p { margin: 0 0 3mm; text-align: justify; }
strong { color: #111; }
code { font-family: "SF Mono",Menlo,monospace; font-size: 9.5pt; background: #f4f1e8;
  padding: 1px 5px; border-radius: 3px; color: #b03a2e; }
pre { background: #1e1e1e; color: #e8e8e8; padding: 5mm; border-radius: 5px;
  border-left: 4px solid #f1c40f; overflow: hidden; page-break-inside: avoid; margin: 3mm 0; }
pre code { background: none; color: #e8e8e8; font-size: 8.8pt; padding: 0; line-height: 1.5; }
blockquote { border-left: 4px solid #c0392b; background: #fcf3f2; margin: 4mm 0;
  padding: 3mm 5mm; color: #444; page-break-inside: avoid; }
blockquote strong { color: #c0392b; }
ul, ol { margin: 0 0 3mm; padding-left: 7mm; }
li { margin: 1mm 0; }
hr { border: none; border-top: 1px solid #ddd; margin: 5mm 0; }
em { color: #7d6608; font-style: italic; }
</style></head><body>${titlePage}${html}</body></html>`;

writeFileSync(process.argv[3], out);
console.log("HTML written:", process.argv[3]);

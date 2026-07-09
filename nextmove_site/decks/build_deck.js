// NextMove — Studio Applied AI deck (FR-QC, dark "Studio Engineering" DA)
const pptxgen = require("pptxgenjs");

const pres = new pptxgen();
pres.layout = "LAYOUT_16x9"; // 10" x 5.625"
pres.author = "NextMove";
pres.title = "Studio Applied AI — NextMove";
pres.company = "NextMove Studio";
pres.subject = "Qu'est-ce qu'un studio applied AI";

// ─── BRAND TOKENS ───
const C = {
  bg:      "0A0A0A",
  bg2:     "111111",
  bg3:     "161616",
  fg:      "F5F5F4",
  fg2:     "A1A1A1",
  fg3:     "525252",
  line:    "262626",
  accent:  "00FF85",
  accent2: "003D1F",
  warn:    "FFB800",
  danger:  "FF4444",
};
const F = {
  display: "Inter",
  body:    "Inter",
  mono:    "JetBrains Mono",
};
const SLIDES_TOTAL = 11;

// ─── SHARED COMPONENTS ───
function bg(slide) {
  slide.background = { color: C.bg };
  // top accent line
  slide.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 10, h: 0.02, fill: { color: C.accent }, line: { type: "none" },
  });
  // faint grid (vertical rails)
  for (let x = 1; x < 10; x += 1) {
    slide.addShape(pres.shapes.LINE, {
      x, y: 0, w: 0, h: 5.625,
      line: { color: C.line, width: 0.5, transparency: 60 },
    });
  }
}

function chrome(slide, slideNo, sectionMark) {
  // top-left brand
  slide.addText("▲ NEXTMOVE", {
    x: 0.4, y: 0.18, w: 3, h: 0.3,
    fontFace: F.mono, fontSize: 9, color: C.fg2, bold: true, charSpacing: 2, margin: 0,
  });
  // top-right status
  slide.addText([
    { text: "● ", options: { color: C.accent } },
    { text: "SYSTÈMES OPÉRATIONNELS · v1.0", options: { color: C.fg3 } },
  ], {
    x: 5.5, y: 0.18, w: 4.1, h: 0.3,
    fontFace: F.mono, fontSize: 9, align: "right", margin: 0,
  });
  // section mark (top-left under brand)
  if (sectionMark) {
    slide.addText(sectionMark, {
      x: 0.4, y: 0.55, w: 6, h: 0.3,
      fontFace: F.mono, fontSize: 10, color: C.fg3, charSpacing: 3, margin: 0,
    });
  }
  // bottom-left footer brand
  slide.addText("nextmove.studio", {
    x: 0.4, y: 5.25, w: 3, h: 0.3,
    fontFace: F.mono, fontSize: 9, color: C.fg3, margin: 0,
  });
  // bottom-right slide counter
  slide.addText(`${String(slideNo).padStart(2, "0")} / ${String(SLIDES_TOTAL).padStart(2, "0")}`, {
    x: 7, y: 5.25, w: 2.6, h: 0.3,
    fontFace: F.mono, fontSize: 9, color: C.fg2, align: "right", margin: 0,
  });
}

function kicker(slide, x, y, text) {
  slide.addText(text, {
    x, y, w: 6, h: 0.3,
    fontFace: F.mono, fontSize: 10, color: C.accent, charSpacing: 2, bold: true, margin: 0,
  });
}

function title(slide, x, y, w, text, parts) {
  // parts: optional array for rich text — overrides text
  const opts = {
    x, y, w, h: 1.6,
    fontFace: F.display, fontSize: 40, color: C.fg, bold: true,
    valign: "top", margin: 0, paraSpaceAfter: 0,
  };
  if (parts) slide.addText(parts, opts);
  else slide.addText(text, opts);
}

function dim(slide, x, y, w, h, text, size = 14) {
  slide.addText(text, {
    x, y, w, h,
    fontFace: F.body, fontSize: size, color: C.fg2, valign: "top", margin: 0,
  });
}

function monoLabel(slide, x, y, w, text, color = C.fg3, size = 10) {
  slide.addText(text, {
    x, y, w, h: 0.25,
    fontFace: F.mono, fontSize: size, color, charSpacing: 1, margin: 0,
  });
}

// =============================================================
// SLIDE 1 — COVER
// =============================================================
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  // grid bg (denser on cover)
  for (let x = 0.5; x < 10; x += 0.5) {
    s.addShape(pres.shapes.LINE, {
      x, y: 0, w: 0, h: 5.625,
      line: { color: C.line, width: 0.5, transparency: 75 },
    });
  }
  for (let y = 0.5; y < 5.625; y += 0.5) {
    s.addShape(pres.shapes.LINE, {
      x: 0, y, w: 10, h: 0,
      line: { color: C.line, width: 0.5, transparency: 75 },
    });
  }
  // top accent line
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 10, h: 0.02, fill: { color: C.accent }, line: { type: "none" },
  });
  // brand
  s.addText("▲ NEXTMOVE", {
    x: 0.4, y: 0.3, w: 3, h: 0.3,
    fontFace: F.mono, fontSize: 10, color: C.fg2, bold: true, charSpacing: 3, margin: 0,
  });
  // status
  s.addText([
    { text: "● ", options: { color: C.accent } },
    { text: "MTL · 2026", options: { color: C.fg3 } },
  ], {
    x: 6.5, y: 0.3, w: 3.1, h: 0.3,
    fontFace: F.mono, fontSize: 10, align: "right", margin: 0,
  });

  // prompt
  s.addText([
    { text: "$ ", options: { color: C.fg3 } },
    { text: "cat ./qu_est_ce_qu_un_studio_applied_ai.md", options: { color: C.accent } },
  ], {
    x: 0.5, y: 1.0, w: 9, h: 0.35,
    fontFace: F.mono, fontSize: 13, margin: 0,
  });

  // BIG title — line height ~ 1.15" at 80pt
  s.addText("Studio", {
    x: 0.5, y: 1.5, w: 9, h: 1.2,
    fontFace: F.display, fontSize: 72, color: C.fg, bold: true, valign: "top", margin: 0,
  });
  s.addText("Applied AI.", {
    x: 0.5, y: 2.55, w: 9, h: 1.2,
    fontFace: F.display, fontSize: 72, color: C.fg, bold: true, valign: "top", margin: 0,
  });
  // accent suffix
  s.addText([
    { text: "qui ship du ", options: { color: C.fg2 } },
    { text: "SaaS", options: { color: C.accent, bold: true } },
    { text: ".", options: { color: C.fg2 } },
  ], {
    x: 0.5, y: 3.85, w: 9, h: 0.6,
    fontFace: F.display, fontSize: 28, italic: true, valign: "top", margin: 0,
  });

  // sub
  s.addText("Pourquoi cette catégorie. Pourquoi maintenant. Comment on opère.", {
    x: 0.5, y: 4.55, w: 9, h: 0.4,
    fontFace: F.body, fontSize: 13, color: C.fg2, margin: 0,
  });
  // footer
  s.addText("NextMove Studio · v1.0", {
    x: 0.4, y: 5.25, w: 4, h: 0.3,
    fontFace: F.mono, fontSize: 9, color: C.fg3, margin: 0,
  });
  s.addText("01 / 11", {
    x: 7, y: 5.25, w: 2.6, h: 0.3,
    fontFace: F.mono, fontSize: 9, color: C.fg2, align: "right", margin: 0,
  });
}

// =============================================================
// SLIDE 2 — LE PROBLÈME (3 stats)
// =============================================================
{
  const s = pres.addSlide();
  bg(s);
  chrome(s, 2, "[ 01 / LE PROBLÈME ]");

  kicker(s, 0.5, 1.0, "le_gap");
  title(s, 0.5, 1.3, 9, null, [
    { text: "Entre l'idée IA et le SaaS qui paie son loyer:\n", options: { color: C.fg, fontSize: 32 } },
    { text: "14 mois et 8 morts.", options: { color: C.accent, fontSize: 32 } },
  ]);

  // 3 stat columns
  const stats = [
    { v: "87%", k: "des POC IA ne passent jamais en production", src: "Gartner 2025" },
    { v: "14 mo", k: "délai moyen idée → premier dollar de MRR", src: "estimation marché" },
    { v: "92%", k: "des projets IA dépassent le budget initial >2x", src: "MIT Sloan 2024" },
  ];
  stats.forEach((st, i) => {
    const x = 0.5 + i * 3.1;
    const yc = 3.55;
    s.addShape(pres.shapes.RECTANGLE, {
      x, y: yc, w: 2.9, h: 1.55,
      fill: { color: C.bg2 }, line: { color: C.line, width: 1 },
    });
    // top accent corner
    s.addShape(pres.shapes.RECTANGLE, {
      x, y: yc, w: 0.35, h: 0.04, fill: { color: C.accent }, line: { type: "none" },
    });
    s.addText(st.v, {
      x: x + 0.2, y: yc + 0.15, w: 2.5, h: 0.6,
      fontFace: F.mono, fontSize: 32, color: C.accent, bold: true, valign: "top", margin: 0,
    });
    s.addText(st.k, {
      x: x + 0.2, y: yc + 0.75, w: 2.55, h: 0.55,
      fontFace: F.body, fontSize: 11, color: C.fg2, valign: "top", margin: 0,
    });
    s.addText(`// ${st.src}`, {
      x: x + 0.2, y: yc + 1.28, w: 2.55, h: 0.22,
      fontFace: F.mono, fontSize: 8, color: C.fg3, margin: 0,
    });
  });
}

// =============================================================
// SLIDE 3 — DÉFINITION (4 piliers)
// =============================================================
{
  const s = pres.addSlide();
  bg(s);
  chrome(s, 3, "[ 02 / DÉFINITION ]");

  kicker(s, 0.5, 1.0, "definition");
  title(s, 0.5, 1.3, 9, null, [
    { text: "Studio Applied AI = ", options: { color: C.fg } },
    { text: "4 traits.", options: { color: C.accent } },
  ]);

  const pillars = [
    { n: "01", t: "SaaS propres", d: "Pas du conseil. Des produits qui génèrent du MRR récurrent." },
    { n: "02", t: "Ship en 14 jours", d: "Cycle MVP figé. Pas 14 mois. Build → measure → learn." },
    { n: "03", t: "Stack figée", d: "Claude · n8n · Supabase · Next.js. On en change pas." },
    { n: "04", t: "Vertical first", d: "Une niche par produit. Pas de plateforme horizontale." },
  ];
  pillars.forEach((p, i) => {
    const col = i % 2;
    const row = Math.floor(i / 2);
    const x = 0.5 + col * 4.55;
    const y = 3.05 + row * 1.05;
    s.addShape(pres.shapes.RECTANGLE, {
      x, y, w: 4.45, h: 0.95,
      fill: { color: C.bg2 }, line: { color: C.line, width: 1 },
    });
    s.addText(p.n, {
      x: x + 0.2, y: y + 0.12, w: 0.8, h: 0.35,
      fontFace: F.mono, fontSize: 14, color: C.accent, bold: true, margin: 0,
    });
    s.addText(p.t, {
      x: x + 0.95, y: y + 0.1, w: 3.3, h: 0.4,
      fontFace: F.display, fontSize: 17, color: C.fg, bold: true, margin: 0,
    });
    s.addText(p.d, {
      x: x + 0.95, y: y + 0.5, w: 3.3, h: 0.45,
      fontFace: F.body, fontSize: 11, color: C.fg2, margin: 0,
    });
  });
}

// =============================================================
// SLIDE 4 — STUDIO ≠ AGENCE
// =============================================================
{
  const s = pres.addSlide();
  bg(s);
  chrome(s, 4, "[ 03 / VS AGENCE ]");

  kicker(s, 0.5, 1.0, "ce_quon_est_pas");
  title(s, 0.5, 1.3, 9, null, [
    { text: "Pas une agence. ", options: { color: C.fg } },
    { text: "Pas un cabinet. ", options: { color: C.fg2 } },
    { text: "Un studio.", options: { color: C.accent } },
  ]);

  // Left col — AGENCE (struck)
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0.5, y: 3.0, w: 4.45, h: 2.0,
    fill: { color: C.bg2 }, line: { color: C.danger, width: 1 },
  });
  s.addText("AGENCE IA", {
    x: 0.7, y: 3.15, w: 4.0, h: 0.35,
    fontFace: F.mono, fontSize: 12, color: C.danger, bold: true, charSpacing: 3, margin: 0,
  });
  const agence = [
    "facturation à l'heure",
    "POCs jetables",
    "decks PowerPoint",
    "0 IP cumulative",
    "0 revenu récurrent",
  ];
  s.addText(agence.map((t, i) => ({
    text: "✗  " + t,
    options: { breakLine: i < agence.length - 1, color: C.fg3, strike: true },
  })), {
    x: 0.7, y: 3.55, w: 4.0, h: 1.4,
    fontFace: F.body, fontSize: 13, paraSpaceAfter: 4, valign: "top", margin: 0,
  });

  // Right col — STUDIO (accent)
  s.addShape(pres.shapes.RECTANGLE, {
    x: 5.05, y: 3.0, w: 4.45, h: 2.0,
    fill: { color: C.bg2 }, line: { color: C.accent, width: 1 },
  });
  s.addText("STUDIO APPLIED AI", {
    x: 5.25, y: 3.15, w: 4.0, h: 0.35,
    fontFace: F.mono, fontSize: 12, color: C.accent, bold: true, charSpacing: 3, margin: 0,
  });
  const studio = [
    "SaaS propres",
    "MRR récurrent",
    "IP qui compose",
    "1 stack → N clients",
    "vertical focus",
  ];
  s.addText(studio.map((t, i) => ({
    text: "✓  " + t,
    options: { breakLine: i < studio.length - 1, color: C.fg, bold: true },
  })), {
    x: 5.25, y: 3.55, w: 4.0, h: 1.4,
    fontFace: F.body, fontSize: 13, paraSpaceAfter: 4, valign: "top", margin: 0,
  });
}

// =============================================================
// SLIDE 5 — POURQUOI SAAS
// =============================================================
{
  const s = pres.addSlide();
  bg(s);
  chrome(s, 5, "[ 04 / SAAS > CONSULTING ]");

  kicker(s, 0.5, 1.0, "pourquoi_saas");
  title(s, 0.5, 1.3, 9, null, [
    { text: "Pourquoi ", options: { color: C.fg } },
    { text: "SaaS ", options: { color: C.accent } },
    { text: "et pas du conseil?", options: { color: C.fg } },
  ]);

  const reasons = [
    { k: "MARGES", v: "75–90 %", d: "vs 30 % en conseil. Coût marginal proche de zéro." },
    { k: "VALORISATION", v: "5–10×", d: "ARR SaaS vs 1–2× pour les revenus de service." },
    { k: "DISTRIBUTION", v: "1 → ∞", d: "Un dev sert 1 000 clients. Le conseil ne scale pas." },
    { k: "APPRENTISSAGE", v: "composé", d: "Chaque client améliore le produit suivant." },
  ];
  reasons.forEach((r, i) => {
    const x = 0.5 + i * 2.275;
    s.addShape(pres.shapes.RECTANGLE, {
      x, y: 3.0, w: 2.15, h: 2.0,
      fill: { color: C.bg2 }, line: { color: C.line, width: 1 },
    });
    s.addText(`// ${r.k}`, {
      x: x + 0.15, y: 3.15, w: 1.9, h: 0.3,
      fontFace: F.mono, fontSize: 9, color: C.fg3, charSpacing: 1, margin: 0,
    });
    s.addText(r.v, {
      x: x + 0.15, y: 3.5, w: 1.9, h: 0.7,
      fontFace: F.display, fontSize: 28, color: C.accent, bold: true, margin: 0,
    });
    s.addText(r.d, {
      x: x + 0.15, y: 4.25, w: 1.9, h: 0.7,
      fontFace: F.body, fontSize: 10, color: C.fg2, valign: "top", margin: 0,
    });
  });
}

// =============================================================
// SLIDE 6 — MÉTHODE (terminal log)
// =============================================================
{
  const s = pres.addSlide();
  bg(s);
  chrome(s, 6, "[ 05 / MÉTHODE ]");

  kicker(s, 0.5, 1.0, "comment_on_ship");
  title(s, 0.5, 1.3, 9, null, [
    { text: "Lean Startup ", options: { color: C.fg } },
    { text: "× ", options: { color: C.accent } },
    { text: "Kernel Rumelt.", options: { color: C.fg } },
  ]);

  // terminal window
  const tx = 0.5, ty = 2.9, tw = 9, th = 2.4;
  s.addShape(pres.shapes.RECTANGLE, {
    x: tx, y: ty, w: tw, h: th,
    fill: { color: C.bg2 }, line: { color: C.line, width: 1 },
  });
  // term head
  s.addShape(pres.shapes.RECTANGLE, {
    x: tx, y: ty, w: tw, h: 0.3,
    fill: { color: C.bg3 }, line: { type: "none" },
  });
  s.addText("~/nextmove/methode.log", {
    x: tx + 0.15, y: ty + 0.05, w: 5, h: 0.25,
    fontFace: F.mono, fontSize: 9, color: C.fg3, margin: 0,
  });
  s.addText("↻ live", {
    x: tx + tw - 0.8, y: ty + 0.05, w: 0.7, h: 0.25,
    fontFace: F.mono, fontSize: 9, color: C.accent, align: "right", margin: 0,
  });
  // log lines
  const lines = [
    { ts: "D+00", lvl: "DIAG",   lvlColor: C.accent, msg: "Observation terrain · 2-3 jours à shadower un vrai opérateur" },
    { ts: "D+02", lvl: "POLICY", lvlColor: C.accent, msg: "Politique directrice — une phrase. \"remplacer l'adjointe humaine pour courtiers solo, par SMS, FR-QC\"" },
    { ts: "D+03", lvl: "BUILD",  lvlColor: C.warn,   msg: "MVP scope figé · stack figée · échéance figée à 14j. Pas de feature creep." },
    { ts: "D+14", lvl: "SHIP",   lvlColor: C.accent, msg: "Vrais usagers sur vrai workflow. Instrumenté dès J+1." },
    { ts: "D+30", lvl: "LEARN",  lvlColor: C.accent, msg: "Décision binaire: PERSÉVÈRE · PIVOT · TUE. Pas de zombie 6 mois." },
  ];
  lines.forEach((l, i) => {
    const ly = ty + 0.4 + i * 0.38;
    s.addText(l.ts, {
      x: tx + 0.15, y: ly, w: 0.55, h: 0.3,
      fontFace: F.mono, fontSize: 10, color: C.fg3, margin: 0,
    });
    // level pill
    s.addShape(pres.shapes.RECTANGLE, {
      x: tx + 0.8, y: ly + 0.04, w: 0.7, h: 0.22,
      fill: { color: l.lvlColor === C.warn ? "1F1500" : C.accent2 },
      line: { color: l.lvlColor, width: 0.5 },
    });
    s.addText(l.lvl, {
      x: tx + 0.8, y: ly + 0.04, w: 0.7, h: 0.22,
      fontFace: F.mono, fontSize: 8, color: l.lvlColor, bold: true, align: "center", valign: "middle", margin: 0,
    });
    s.addText(l.msg, {
      x: tx + 1.6, y: ly + 0.02, w: 7.3, h: 0.32,
      fontFace: F.mono, fontSize: 10, color: C.fg2, valign: "middle", margin: 0,
    });
  });
}

// =============================================================
// SLIDE 7 — STACK (pipeline)
// =============================================================
{
  const s = pres.addSlide();
  bg(s);
  chrome(s, 7, "[ 06 / STACK ]");

  kicker(s, 0.5, 1.0, "stack_par_defaut");
  title(s, 0.5, 1.3, 9, null, [
    { text: "Quatre briques. ", options: { color: C.fg } },
    { text: "On en change pas.", options: { color: C.accent } },
  ]);

  const pipes = [
    { id: "// LLM",           name: "Claude",   meta: "anthropic · sonnet", body: "Long contexte. FR-QC solide. Tool use prod-ready." },
    { id: "// ORCHESTRATION", name: "n8n",      meta: "self-hosted",         body: "Workflows visuels. Auditables. Zéro vendor lock." },
    { id: "// DATA",          name: "Supabase", meta: "postgres · RLS",      body: "ca-central-1. Données au Canada." },
    { id: "// FRONT",         name: "Next.js",  meta: "vercel · edge",       body: "Dashboards opérateur. App router." },
  ];
  pipes.forEach((p, i) => {
    const x = 0.5 + i * 2.275;
    s.addShape(pres.shapes.RECTANGLE, {
      x, y: 3.0, w: 2.15, h: 2.0,
      fill: { color: C.bg2 }, line: { color: C.line, width: 1 },
    });
    s.addText(p.id, {
      x: x + 0.15, y: 3.15, w: 1.9, h: 0.3,
      fontFace: F.mono, fontSize: 9, color: C.fg3, charSpacing: 1, margin: 0,
    });
    s.addText(p.name, {
      x: x + 0.15, y: 3.5, w: 1.9, h: 0.5,
      fontFace: F.display, fontSize: 22, color: C.fg, bold: true, margin: 0,
    });
    s.addText(p.meta, {
      x: x + 0.15, y: 3.95, w: 1.9, h: 0.3,
      fontFace: F.mono, fontSize: 9, color: C.accent, margin: 0,
    });
    s.addText(p.body, {
      x: x + 0.15, y: 4.3, w: 1.9, h: 0.65,
      fontFace: F.body, fontSize: 10, color: C.fg2, valign: "top", margin: 0,
    });
    // arrow between (not last)
    if (i < pipes.length - 1) {
      s.addText("→", {
        x: x + 2.05, y: 3.85, w: 0.3, h: 0.3,
        fontFace: F.mono, fontSize: 16, color: C.accent, bold: true, align: "center", valign: "middle", margin: 0,
      });
    }
  });

  // bottom caption (placed above cards, not below)
  s.addText("Discipline > diversité. C'est la stack figée qui permet le cycle 14j.", {
    x: 0.5, y: 2.65, w: 9, h: 0.25,
    fontFace: F.mono, fontSize: 10, color: C.fg3, italic: true, margin: 0,
  });
}

// =============================================================
// SLIDE 8 — UNIT ECONOMICS
// =============================================================
{
  const s = pres.addSlide();
  bg(s);
  chrome(s, 8, "[ 07 / ÉCONOMIE ]");

  kicker(s, 0.5, 1.0, "unit_economics");
  title(s, 0.5, 1.3, 9, null, [
    { text: "Économie d'un SaaS IA. ", options: { color: C.fg } },
    { text: "Breakeven à 6 clients.", options: { color: C.accent } },
  ]);

  // table-style metrics
  const rows = [
    { k: "Coût infra par SaaS", v: "$35 / mois",      d: "Claude API · n8n self-host · Supabase pro" },
    { k: "CAC cible",           v: "< $200 / client", d: "via inbound (SEO niche) + outbound founder-led" },
    { k: "Prix client",         v: "$99 / mois",      d: "tier d'entrée pour PME · simple à dire oui" },
    { k: "Breakeven",           v: "6 clients",       d: "= $594 MRR > coûts directs. ~30 jours d'effort." },
    { k: "Payback CAC",         v: "3 mois",          d: "rétention cohorte > 80 % à 6 mois (verticales)" },
  ];
  rows.forEach((r, i) => {
    const y = 3.0 + i * 0.42;
    // alternate row tint
    if (i % 2 === 0) {
      s.addShape(pres.shapes.RECTANGLE, {
        x: 0.5, y, w: 9, h: 0.4,
        fill: { color: C.bg2 }, line: { type: "none" },
      });
    }
    s.addText(r.k, {
      x: 0.65, y: y + 0.05, w: 2.8, h: 0.3,
      fontFace: F.mono, fontSize: 10, color: C.fg3, charSpacing: 1, valign: "middle", margin: 0,
    });
    s.addText(r.v, {
      x: 3.5, y: y + 0.05, w: 2.5, h: 0.3,
      fontFace: F.display, fontSize: 14, color: C.accent, bold: true, valign: "middle", margin: 0,
    });
    s.addText(r.d, {
      x: 6.0, y: y + 0.05, w: 3.4, h: 0.3,
      fontFace: F.body, fontSize: 11, color: C.fg2, valign: "middle", margin: 0,
    });
  });
}

// =============================================================
// SLIDE 9 — CATÉGORIE QUI ÉMERGE
// =============================================================
{
  const s = pres.addSlide();
  bg(s);
  chrome(s, 9, "[ 08 / CATÉGORIE ]");

  kicker(s, 0.5, 1.0, "la_categorie_emerge");
  title(s, 0.5, 1.3, 9, null, [
    { text: "Une catégorie qui se cristallise. ", options: { color: C.fg } },
    { text: "2025-2026.", options: { color: C.accent } },
  ]);

  const players = [
    { name: "DeployCo",  tag: "OpenAI Deployment Co.",      desc: "Le pattern qui a cristallisé la catégorie. Vertical agents au prix corporate." },
    { name: "NextMove",  tag: "Klaris · real estate (CA)",  desc: "Notre studio. Premier produit en prod : copilote SMS pour courtiers solo." },
    { name: "Lindy",     tag: "AI agents per workflow",     desc: "Plateforme + delivery layer. Approche horizontale, mais même méthode." },
    { name: "Cognosys",  tag: "Vertical AI agents",         desc: "Studio focus sur ops B2B. Stack figée, vertical par vertical." },
  ];
  players.forEach((p, i) => {
    const col = i % 2;
    const row = Math.floor(i / 2);
    const x = 0.5 + col * 4.55;
    const y = 3.0 + row * 1.15;
    const cardH = 1.05;
    s.addShape(pres.shapes.RECTANGLE, {
      x, y, w: 4.45, h: cardH,
      fill: { color: C.bg2 }, line: { color: C.line, width: 1 },
    });
    // accent rail
    s.addShape(pres.shapes.RECTANGLE, {
      x, y, w: 0.06, h: cardH, fill: { color: C.accent }, line: { type: "none" },
    });
    // name (full row)
    s.addText(p.name, {
      x: x + 0.2, y: y + 0.1, w: 4.1, h: 0.3,
      fontFace: F.display, fontSize: 16, color: C.fg, bold: true, margin: 0,
    });
    // tag below name (full width)
    s.addText(p.tag, {
      x: x + 0.2, y: y + 0.42, w: 4.1, h: 0.22,
      fontFace: F.mono, fontSize: 9, color: C.accent, margin: 0,
    });
    // desc
    s.addText(p.desc, {
      x: x + 0.2, y: y + 0.66, w: 4.1, h: 0.38,
      fontFace: F.body, fontSize: 10, color: C.fg2, valign: "top", margin: 0,
    });
  });
}

// =============================================================
// SLIDE 10 — NEXTMOVE (we ARE)
// =============================================================
{
  const s = pres.addSlide();
  bg(s);
  chrome(s, 10, "[ 09 / NEXTMOVE ]");

  kicker(s, 0.5, 1.0, "qui_on_est");
  title(s, 0.5, 1.3, 9, null, [
    { text: "On opère ce playbook ", options: { color: C.fg } },
    { text: "à Montréal.", options: { color: C.accent } },
  ]);

  // 2 cols: left = stats, right = quote
  // left stats
  const stats = [
    { v: "1",  k: "produit en production · Klaris" },
    { v: "3",  k: "produits dans le pipeline (santé · resto · juridique)" },
    { v: "4",  k: "cofondateurs · zéro titre C-suite" },
    { v: "14", k: "jours par cycle MVP · stack figée Claude + n8n + Supabase + Next" },
  ];
  stats.forEach((st, i) => {
    const y = 3.0 + i * 0.55;
    s.addText(st.v, {
      x: 0.5, y, w: 1.0, h: 0.5,
      fontFace: F.display, fontSize: 32, color: C.accent, bold: true, valign: "top", margin: 0,
    });
    s.addText(st.k, {
      x: 1.6, y: y + 0.12, w: 4.0, h: 0.4,
      fontFace: F.body, fontSize: 12, color: C.fg2, valign: "top", margin: 0,
    });
  });

  // right: terminal-style block
  const tx = 5.85, ty = 2.95, tw = 3.65, th = 2.05;
  s.addShape(pres.shapes.RECTANGLE, {
    x: tx, y: ty, w: tw, h: th,
    fill: { color: C.bg2 }, line: { color: C.accent, width: 1 },
  });
  s.addText("// mission", {
    x: tx + 0.2, y: ty + 0.15, w: tw - 0.4, h: 0.3,
    fontFace: F.mono, fontSize: 9, color: C.accent, charSpacing: 1, margin: 0,
  });
  s.addText("\"Bâtir des produits IA qui paient leur loyer dès le premier mois.\"", {
    x: tx + 0.2, y: ty + 0.5, w: tw - 0.4, h: 1.1,
    fontFace: F.body, fontSize: 14, color: C.fg, italic: true, bold: true, valign: "top", margin: 0,
  });
  s.addText("— NextMove, 2026", {
    x: tx + 0.2, y: ty + th - 0.4, w: tw - 0.4, h: 0.3,
    fontFace: F.mono, fontSize: 9, color: C.fg3, margin: 0,
  });
}

// =============================================================
// SLIDE 11 — CTA
// =============================================================
{
  const s = pres.addSlide();
  s.background = { color: C.bg };
  // accent radial vibe via overlapping shapes
  s.addShape(pres.shapes.OVAL, {
    x: -2, y: -2, w: 14, h: 9,
    fill: { color: C.accent, transparency: 92 }, line: { type: "none" },
  });
  // top line
  s.addShape(pres.shapes.RECTANGLE, {
    x: 0, y: 0, w: 10, h: 0.02, fill: { color: C.accent }, line: { type: "none" },
  });

  // brand
  s.addText("▲ NEXTMOVE", {
    x: 0.4, y: 0.3, w: 3, h: 0.3,
    fontFace: F.mono, fontSize: 10, color: C.fg2, bold: true, charSpacing: 3, margin: 0,
  });

  // prompt
  s.addText([
    { text: "$ ", options: { color: C.fg3 } },
    { text: "echo \"on_se_parle\" | nextmove", options: { color: C.accent } },
  ], {
    x: 0.5, y: 1.4, w: 9, h: 0.4,
    fontFace: F.mono, fontSize: 13, align: "center", margin: 0,
  });

  // BIG question — line height ~ 0.85" at 52pt
  s.addText("Un workflow qui", {
    x: 0.5, y: 1.75, w: 9, h: 0.95,
    fontFace: F.display, fontSize: 48, color: C.fg, bold: true, align: "center", valign: "top", margin: 0,
  });
  s.addText("saigne des heures?", {
    x: 0.5, y: 2.75, w: 9, h: 0.95,
    fontFace: F.display, fontSize: 48, color: C.accent, bold: true, align: "center", valign: "top", margin: 0,
  });

  // sub
  s.addText("Diagnostic gratuit · 30 minutes · sans engagement.", {
    x: 0.5, y: 3.9, w: 9, h: 0.4,
    fontFace: F.body, fontSize: 14, color: C.fg2, align: "center", margin: 0,
  });

  // email button
  const bx = 2.5, by = 4.5, bw = 5, bh = 0.55;
  s.addShape(pres.shapes.RECTANGLE, {
    x: bx, y: by, w: bw, h: bh,
    fill: { color: C.accent }, line: { type: "none" },
  });
  s.addText("hello@nextmove.studio  →", {
    x: bx, y: by, w: bw, h: bh,
    fontFace: F.mono, fontSize: 16, color: C.bg, bold: true, align: "center", valign: "middle", margin: 0,
  });

  // footer
  s.addText("nextmove.studio · Montréal, QC", {
    x: 0.4, y: 5.25, w: 4, h: 0.3,
    fontFace: F.mono, fontSize: 9, color: C.fg3, margin: 0,
  });
  s.addText("11 / 11 · fin", {
    x: 7, y: 5.25, w: 2.6, h: 0.3,
    fontFace: F.mono, fontSize: 9, color: C.fg2, align: "right", margin: 0,
  });
}

// ─── EXPORT ───
pres.writeFile({ fileName: "nextmove_studio_applied_ai.pptx" })
  .then(f => console.log("✓ wrote", f))
  .catch(e => { console.error("✗", e); process.exit(1); });

// Klaris — Monthly Report PDF
// Generates an HTML report per broker, renders to PDF via Browserless.io,
// uploads to Supabase Storage `reports/` bucket, returns signed URL.
//
// Trigger: GET /functions/v1/monthly-report?month=2026-04
// Auth: Authorization: Bearer <user_jwt> — RLS scopes report to caller.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const BROWSERLESS_TOKEN = Deno.env.get('BROWSERLESS_TOKEN')!;

Deno.serve(async (req: Request) => {
  try {
    const auth = req.headers.get('authorization') ?? '';
    const url = new URL(req.url);
    const monthParam = url.searchParams.get('month') ?? defaultMonth();

    const supabase = createClient(SUPABASE_URL, ANON_KEY, { global: { headers: { Authorization: auth } } });
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return json({ error: 'unauthorized' }, 401);

    // 1. Fetch monthly stats via the broker_stats RPC + month-scoped queries.
    const start = new Date(`${monthParam}-01T00:00:00Z`);
    const end = new Date(start);
    end.setMonth(end.getMonth() + 1);

    const [prospects, stats] = await Promise.all([
      supabase.from('prospects')
        .select('id, nom, score, secteur, budget, type, status, created_at')
        .gte('created_at', start.toISOString())
        .lt('created_at', end.toISOString())
        .order('score', { ascending: false }),
      supabase.rpc('broker_stats_snapshot'),
    ]);

    // 2. Render HTML.
    const html = renderHtml({
      brokerEmail: user.email ?? '—',
      month: monthParam,
      prospects: (prospects.data ?? []) as ProspectRow[],
      stats: stats.data as StatsSnapshot,
    });

    // 3. PDF via Browserless.
    const pdfRes = await fetch(`https://chrome.browserless.io/pdf?token=${BROWSERLESS_TOKEN}`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        html,
        options: { format: 'A4', printBackground: true, margin: { top: '20mm', bottom: '20mm', left: '15mm', right: '15mm' } },
      }),
    });
    if (!pdfRes.ok) throw new Error(`browserless ${pdfRes.status}`);
    const pdf = new Uint8Array(await pdfRes.arrayBuffer());

    // 4. Upload to Storage.
    const path = `${user.id}/${monthParam}.pdf`;
    const upload = await supabase.storage.from('reports').upload(path, pdf, { upsert: true, contentType: 'application/pdf' });
    if (upload.error) throw upload.error;

    // 5. Return signed URL (24h).
    const signed = await supabase.storage.from('reports').createSignedUrl(path, 60 * 60 * 24);
    return json({ url: signed.data?.signedUrl, month: monthParam });
  } catch (e) {
    console.error('monthly-report-fail', e);
    return json({ error: String(e) }, 500);
  }
});

interface ProspectRow {
  id: string; nom: string | null; score: number; secteur: string | null;
  budget: number | null; type: string | null; status: string;
  created_at: string;
}
interface StatsSnapshot {
  total_prospects: number; hot_prospects: number;
  avg_score: number; conversion_rate: number;
}

function renderHtml(d: { brokerEmail: string; month: string; prospects: ProspectRow[]; stats: StatsSnapshot }): string {
  const rows = d.prospects.map((p) =>
    `<tr><td>${esc(p.nom ?? '—')}</td><td>${p.type ?? '—'}</td><td>${esc(p.secteur ?? '—')}</td>` +
    `<td style="text-align:right;font-family:monospace">${p.budget ? `${Math.round(p.budget / 1000)}K` : '—'}</td>` +
    `<td style="text-align:center;color:#C25A36;font-weight:700">${p.score}/10</td>` +
    `<td><span style="padding:2px 8px;border-radius:4px;background:#FAF0E6;font-size:11px">${p.status}</span></td></tr>`
  ).join('');
  const monthLabel = new Date(`${d.month}-01`).toLocaleDateString('fr-CA', { month: 'long', year: 'numeric' });

  return `<!DOCTYPE html><html><head><meta charset="utf-8"><style>
body{font-family:-apple-system,system-ui,sans-serif;color:#2A2521;margin:0;font-size:12px;line-height:1.5}
h1{font-size:28px;letter-spacing:-0.5px;margin:0 0 4px}
h2{font-size:18px;margin:32px 0 12px;border-bottom:1px solid #E2DDD3;padding-bottom:8px}
.kpi{display:flex;gap:14px;margin:24px 0}
.kpi>div{flex:1;background:#FAF9F5;border-top:3px solid #C25A36;padding:14px;border-radius:6px}
.kpi b{font-size:24px;font-family:monospace;display:block}
.kpi span{font-size:10px;color:#7A7068;text-transform:uppercase;letter-spacing:1px}
table{width:100%;border-collapse:collapse;font-size:11px}
th{text-align:left;padding:8px;background:#FAF9F5;font-size:10px;text-transform:uppercase;letter-spacing:0.5px;color:#7A7068}
td{padding:8px;border-bottom:1px solid #F0EBE0}
.footer{margin-top:48px;padding-top:16px;border-top:1px solid #E2DDD3;font-size:10px;color:#7A7068;text-align:center}
</style></head><body>
<h1>Rapport Klaris</h1>
<p style="color:#7A7068;margin:0">${monthLabel} · ${esc(d.brokerEmail)}</p>

<div class="kpi">
  <div><b>${d.stats.total_prospects ?? 0}</b><span>Total prospects</span></div>
  <div><b>${d.stats.hot_prospects ?? 0}</b><span>Chauds actifs</span></div>
  <div><b>${(d.stats.avg_score ?? 0).toFixed(1)}</b><span>Score moyen</span></div>
  <div><b>${d.stats.conversion_rate ?? 0}%</b><span>Conversion</span></div>
</div>

<h2>Prospects du mois (${d.prospects.length})</h2>
<table>
  <thead><tr><th>Nom</th><th>Type</th><th>Secteur</th><th>Budget</th><th>Score</th><th>Statut</th></tr></thead>
  <tbody>${rows || '<tr><td colspan="6" style="text-align:center;color:#7A7068">Aucun prospect ce mois.</td></tr>'}</tbody>
</table>

<div class="footer">Klaris · klarisapp.ai · Conforme OACIQ — Loi 25 — CASL · Hébergé au Canada</div>
</body></html>`;
}

function esc(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function defaultMonth(): string {
  const d = new Date();
  d.setMonth(d.getMonth() - 1);
  return d.toISOString().slice(0, 7);
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } });
}

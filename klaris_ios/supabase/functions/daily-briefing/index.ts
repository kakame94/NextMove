// Klaris — Daily Briefing Edge Function
// Cron: 0 11 * * * UTC (= 7h30 ET) via Supabase scheduled functions.
// Generates per-broker briefing JSON + sends email via Resend.
//
// Deploy: supabase functions deploy daily-briefing
// Schedule: supabase functions schedule create daily-briefing --cron "30 11 * * *"

import { createClient } from 'jsr:@supabase/supabase-js@2';

interface BriefingPayload {
  courtier_id: string;
  email: string;
  generated_at: string;
  new_leads: ProspectSummary[];
  hot_prospects: ProspectSummary[];
  pending_relances: RelanceSummary[];
  unread_threads: number;
  yesterday_qualified: number;
}

interface ProspectSummary {
  id: string;
  nom: string | null;
  score: number;
  secteur: string | null;
  budget: number | null;
  type: string | null;
}

interface RelanceSummary {
  id: string;
  prospect_name: string | null;
  step: string;
  scheduled_for: string;
}

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const RESEND_KEY = Deno.env.get('RESEND_API_KEY');

const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

Deno.serve(async (_req: Request) => {
  try {
    // 1. Pull active brokers.
    const { data: courtiers, error: cErr } = await supabase
      .from('courtiers')
      .select('id, email, briefing_enabled')
      .eq('briefing_enabled', true);

    if (cErr) throw cErr;

    const results: BriefingPayload[] = [];
    const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();

    for (const c of courtiers ?? []) {
      const payload = await buildBriefing(c.id, c.email, since);
      results.push(payload);

      // 2. Persist for in-app fetch.
      await supabase.from('briefings').insert({
        courtier_id: c.id,
        payload: payload,
        generated_at: payload.generated_at,
      });

      // 3. Send email (best-effort — never block briefing persistence).
      if (RESEND_KEY) await sendEmail(c.email, payload);
    }

    return new Response(JSON.stringify({ ok: true, count: results.length }), {
      status: 200,
      headers: { 'content-type': 'application/json' },
    });
  } catch (e) {
    console.error('briefing-fail', e);
    return new Response(JSON.stringify({ ok: false, error: String(e) }), {
      status: 500,
      headers: { 'content-type': 'application/json' },
    });
  }
});

async function buildBriefing(courtierId: string, email: string, since: string): Promise<BriefingPayload> {
  const [newLeads, hot, relances, unreadAgg, qualifiedAgg] = await Promise.all([
    supabase.from('prospects')
      .select('id, nom, score, secteur, budget, type')
      .eq('courtier_id', courtierId)
      .gte('created_at', since)
      .order('score', { ascending: false })
      .limit(10),
    supabase.from('prospects')
      .select('id, nom, score, secteur, budget, type')
      .eq('courtier_id', courtierId)
      .gte('score', 7)
      .order('score', { ascending: false })
      .limit(5),
    supabase.from('relances_enriched')
      .select('id, prospect_name, step, scheduled_for')
      .eq('courtier_id', courtierId)
      .in('status', ['pending', 'awaiting_approval'])
      .lte('scheduled_for', new Date(Date.now() + 12 * 60 * 60 * 1000).toISOString())
      .order('scheduled_for', { ascending: true }),
    supabase.from('conversations')
      .select('id', { count: 'exact', head: true })
      .eq('read_by_broker', false)
      .eq('direction', 'inbound'),
    supabase.from('prospects')
      .select('id', { count: 'exact', head: true })
      .eq('courtier_id', courtierId)
      .eq('status', 'qualifie')
      .gte('updated_at', since),
  ]);

  return {
    courtier_id: courtierId,
    email,
    generated_at: new Date().toISOString(),
    new_leads: (newLeads.data ?? []) as ProspectSummary[],
    hot_prospects: (hot.data ?? []) as ProspectSummary[],
    pending_relances: (relances.data ?? []) as RelanceSummary[],
    unread_threads: unreadAgg.count ?? 0,
    yesterday_qualified: qualifiedAgg.count ?? 0,
  };
}

async function sendEmail(to: string, p: BriefingPayload): Promise<void> {
  const html = renderEmailHtml(p);
  await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${RESEND_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: 'Klaris <briefing@klarisapp.ai>',
      to,
      subject: `Briefing du ${new Date().toLocaleDateString('fr-CA')} — ${p.hot_prospects.length} chauds, ${p.pending_relances.length} relances`,
      html,
    }),
  }).catch((e) => console.error('email-fail', e));
}

function renderEmailHtml(p: BriefingPayload): string {
  const hotRows = p.hot_prospects.map((h) =>
    `<tr><td style="padding:8px;border-bottom:1px solid #eee">${h.nom ?? '—'}</td>` +
    `<td style="padding:8px;border-bottom:1px solid #eee;color:#C25A36;font-weight:700">${h.score}/10</td>` +
    `<td style="padding:8px;border-bottom:1px solid #eee">${h.secteur ?? '—'}</td></tr>`
  ).join('');

  return `<!DOCTYPE html><html><body style="font-family:-apple-system,system-ui,sans-serif;max-width:600px;margin:0 auto;padding:24px;color:#2A2521">
    <h1 style="font-size:24px;font-weight:700;margin:0 0 4px">Bonjour 👋</h1>
    <p style="color:#7A7068;margin:0 0 24px">Voici ton briefing du jour.</p>

    <div style="display:flex;gap:12px;margin-bottom:24px">
      <div style="flex:1;background:#FAF9F5;padding:14px;border-radius:8px"><div style="font-size:24px;font-weight:700;color:#C25A36">${p.hot_prospects.length}</div><div style="font-size:11px;color:#7A7068;text-transform:uppercase;letter-spacing:1px">Chauds 🔥</div></div>
      <div style="flex:1;background:#FAF9F5;padding:14px;border-radius:8px"><div style="font-size:24px;font-weight:700">${p.new_leads.length}</div><div style="font-size:11px;color:#7A7068;text-transform:uppercase;letter-spacing:1px">Nouveaux</div></div>
      <div style="flex:1;background:#FAF9F5;padding:14px;border-radius:8px"><div style="font-size:24px;font-weight:700">${p.pending_relances.length}</div><div style="font-size:11px;color:#7A7068;text-transform:uppercase;letter-spacing:1px">Relances</div></div>
    </div>

    ${p.hot_prospects.length > 0 ? `<h2 style="font-size:16px;font-weight:700;margin:0 0 8px">Top prospects chauds</h2><table style="width:100%;border-collapse:collapse;font-size:14px">${hotRows}</table>` : ''}

    <p style="margin-top:32px;font-size:12px;color:#7A7068">Klaris travaille en ton nom. Tu peux te désinscrire dans Réglages → Confidentialité.</p>
  </body></html>`;
}

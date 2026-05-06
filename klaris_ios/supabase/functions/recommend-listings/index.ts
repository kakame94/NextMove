// Klaris — recommend-listings Edge Function
// Ranks active MLS listings against a prospect profile using Claude Haiku.
// Caches 24h server-side to avoid duplicate spend.
//
// Deploy: supabase functions deploy recommend-listings
// Secrets required: ANTHROPIC_API_KEY (Supabase project secrets)

import { createClient } from 'jsr:@supabase/supabase-js@2';
import Anthropic from 'npm:@anthropic-ai/sdk@0.30.0';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const ANTHROPIC_KEY = Deno.env.get('ANTHROPIC_API_KEY')!;

const MODEL = 'claude-haiku-4-5-20251001';
const TOP_N = 5;
const TTL_HOURS = 24;
const CANDIDATE_LIMIT = 30;
const BUDGET_TOLERANCE = 1.10; // accept listings up to +10% of prospect budget

const admin = createClient(SUPABASE_URL, SERVICE_KEY);
const claude = new Anthropic({ apiKey: ANTHROPIC_KEY });

interface RankedListing {
  listing_id: string;
  rank: number;
  score: number;
  reason: string;
}

Deno.serve(async (req: Request) => {
  try {
    const auth = req.headers.get('authorization');
    if (!auth) return resp(401, { error: 'unauthorized' });

    const body = await req.json().catch(() => ({}));
    const prospectId = body.prospect_id as string | undefined;
    const force = body.force === true;
    if (!prospectId) return resp(400, { error: 'prospect_id required' });

    // 1. Verify caller owns prospect (RLS via user JWT).
    const userClient = createClient(SUPABASE_URL, ANON_KEY, {
      global: { headers: { Authorization: auth } },
    });
    const { data: prospect, error: pe } = await userClient
      .from('prospects')
      .select('id, courtier_id, type, secteur, budget, score, nom, delai')
      .eq('id', prospectId)
      .single();
    if (pe || !prospect) return resp(404, { error: 'prospect not found' });

    // 2. Cache hit?
    if (!force) {
      const cutoff = new Date(Date.now() - TTL_HOURS * 3600 * 1000).toISOString();
      const { data: cached } = await admin
        .from('prospect_recommendations')
        .select('listing_id, rank, score, reason, generated_at')
        .eq('prospect_id', prospectId)
        .gt('generated_at', cutoff)
        .order('rank', { ascending: true });
      if (cached && cached.length > 0) {
        return resp(200, { source: 'cache', recommendations: cached });
      }
    }

    // 3. Pull candidate listings — pre-filter by city + budget when available.
    let q = admin
      .from('listings')
      .select('id, type, city, price, bedrooms, bathrooms, living_area_sqft, year_built, address, centris_url')
      .eq('status', 'active');
    if (prospect.secteur) q = q.ilike('city', `%${prospect.secteur}%`);
    if (prospect.budget) q = q.lte('price', Math.round(prospect.budget * BUDGET_TOLERANCE));
    const { data: candidates, error: le } = await q.limit(CANDIDATE_LIMIT);
    if (le) throw le;
    if (!candidates || candidates.length === 0) {
      return resp(200, { source: 'fresh', recommendations: [] });
    }

    // 4. Rank via Claude.
    const ranked = await askClaude(prospect, candidates);

    // 5. Persist (replace stale entries for this prospect).
    await admin.from('prospect_recommendations').delete().eq('prospect_id', prospectId);
    if (ranked.length > 0) {
      await admin.from('prospect_recommendations').insert(
        ranked.map((r) => ({
          prospect_id: prospectId,
          listing_id: r.listing_id,
          rank: r.rank,
          score: r.score,
          reason: r.reason,
          model: MODEL,
        }))
      );
    }

    return resp(200, { source: 'fresh', recommendations: ranked });
  } catch (e) {
    console.error('recommend-fail', e);
    return resp(500, { error: String(e) });
  }
});

async function askClaude(prospect: Record<string, unknown>, candidates: Record<string, unknown>[]): Promise<RankedListing[]> {
  const profile = [
    `Type: ${prospect.type ?? 'non précisé'}`,
    `Secteur souhaité: ${prospect.secteur ?? 'non précisé'}`,
    `Budget cible: ${prospect.budget ? prospect.budget + ' $ CAD' : 'non précisé'}`,
    `Délai: ${prospect.delai ?? 'non précisé'}`,
    `Score d'intérêt: ${prospect.score ?? 0}/10`,
  ].join('\n');

  const list = candidates
    .map(
      (c, i) =>
        `${i + 1}. id=${c.id} | ${c.type ?? '?'} | ${c.city ?? '?'} | ${c.price ? c.price + '$' : '?'} | ${c.bedrooms ?? '?'} ch / ${c.bathrooms ?? '?'} sdb | ${c.living_area_sqft ?? '?'} pi² | ${c.year_built ?? '?'}`
    )
    .join('\n');

  const sys =
    "Tu es Klaris, l'adjointe IA d'un courtier immobilier au Québec. Tu analyses un profil prospect et une liste d'inscriptions actives, puis tu retournes les meilleures correspondances en JSON. Sois pragmatique, concis et honnête : si rien ne correspond bien, dis-le.";

  const user = `PROFIL DU PROSPECT:
${profile}

INSCRIPTIONS DISPONIBLES (id | type | ville | prix | ch/sdb | aire | année):
${list}

Retourne UNIQUEMENT un JSON valide de cette forme exacte (pas de markdown, pas de commentaire):
{
  "recommendations": [
    {"listing_id": "<id>", "score": <0-100>, "reason": "<phrase courte FR, max 120 chars>"}
  ]
}

Top ${TOP_N} maximum, du meilleur au moins bon. Score = pertinence globale prospect↔inscription. Si aucune ne convient vraiment, retourne un tableau vide.`;

  const msg = await claude.messages.create({
    model: MODEL,
    max_tokens: 1024,
    system: sys,
    messages: [{ role: 'user', content: user }],
  });

  const block = msg.content.find((c) => c.type === 'text');
  const text = block && block.type === 'text' ? block.text : '{}';
  const cleaned = text.replace(/^\s*```(?:json)?\s*/i, '').replace(/\s*```\s*$/i, '');
  let parsed: { recommendations?: { listing_id: string; score: number; reason: string }[] };
  try {
    parsed = JSON.parse(cleaned);
  } catch {
    console.error('claude-bad-json', text);
    return [];
  }

  const validIds = new Set(candidates.map((c) => c.id as string));
  return (parsed.recommendations ?? [])
    .filter((r) => validIds.has(r.listing_id))
    .slice(0, TOP_N)
    .map((r, i) => ({
      listing_id: r.listing_id,
      rank: i + 1,
      score: Math.max(0, Math.min(100, Math.round(r.score ?? 0))),
      reason: (r.reason ?? '').slice(0, 200),
    }));
}

function resp(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}

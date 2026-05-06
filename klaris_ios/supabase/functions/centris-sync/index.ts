// Klaris — Centris listings sync
//
// Pulls live MLS listings into the `listings` table for an agency.
// NOTE: Centris does not expose a public REST API. Production wiring will use
// either MLS-DDF (CREA) feed (XML), Realtor.ca scrape, or the broker-board
// IDX provider. This implementation is structured around an injected HTTP
// fetcher so the wire format is swappable.
//
// Trigger: cron every 15 min via Supabase scheduled function.
// Auth: service-role only (no user context).

import { createClient } from 'jsr:@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const CENTRIS_FEED_URL = Deno.env.get('CENTRIS_FEED_URL') ?? '';
const CENTRIS_FEED_TOKEN = Deno.env.get('CENTRIS_FEED_TOKEN') ?? '';

interface ListingRaw {
  mls: string;
  type?: string;
  status?: string;
  address?: string;
  city?: string;
  postal_code?: string;
  price?: number;
  bedrooms?: number;
  bathrooms?: number;
  living_area_sqft?: number;
  year_built?: number;
  url?: string;
}

const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

Deno.serve(async (_req: Request) => {
  try {
    const { data: agencies } = await supabase.from('agencies').select('id');
    let total = 0;

    for (const a of agencies ?? []) {
      const fresh = await fetchFeed(a.id);
      total += fresh.length;
      if (fresh.length === 0) continue;

      // Upsert in 100-row batches (Postgres parameter limit).
      for (let i = 0; i < fresh.length; i += 100) {
        const slice = fresh.slice(i, i + 100).map((l) => ({
          id: l.mls,
          agency_id: a.id,
          type: l.type,
          status: l.status ?? 'active',
          address: l.address,
          city: l.city,
          postal_code: l.postal_code,
          price: l.price,
          bedrooms: l.bedrooms,
          bathrooms: l.bathrooms,
          living_area_sqft: l.living_area_sqft,
          year_built: l.year_built,
          centris_url: l.url,
          raw_payload: l as unknown as Record<string, unknown>,
          fetched_at: new Date().toISOString(),
        }));
        const { error } = await supabase.from('listings').upsert(slice, { onConflict: 'id' });
        if (error) throw error;
      }
    }

    return json({ ok: true, count: total });
  } catch (e) {
    console.error('centris-sync-fail', e);
    return json({ error: String(e) }, 500);
  }
});

async function fetchFeed(agencyId: string): Promise<ListingRaw[]> {
  if (!CENTRIS_FEED_URL) {
    // Stub: returns nothing in dev when no feed configured.
    return [];
  }
  const url = new URL(CENTRIS_FEED_URL);
  url.searchParams.set('agency', agencyId);
  const res = await fetch(url.toString(), {
    headers: { Authorization: `Bearer ${CENTRIS_FEED_TOKEN}` },
  });
  if (!res.ok) throw new Error(`feed ${res.status}`);
  const ct = res.headers.get('content-type') ?? '';
  if (ct.includes('application/json')) {
    const json = await res.json() as { listings?: ListingRaw[] };
    return json.listings ?? [];
  }
  // Fallback: minimal MLS-DDF XML parser.
  const xml = await res.text();
  return parseDdfXml(xml);
}

function parseDdfXml(xml: string): ListingRaw[] {
  // Tiny parser — not a full DDF impl. For production swap in a real XML parser.
  const out: ListingRaw[] = [];
  for (const m of xml.matchAll(/<Listing>([\s\S]*?)<\/Listing>/g)) {
    const block = m[1];
    const tag = (n: string) => block.match(new RegExp(`<${n}>([^<]*)<\\/${n}>`))?.[1];
    const numTag = (n: string) => {
      const v = tag(n);
      return v ? parseInt(v, 10) : undefined;
    };
    out.push({
      mls: tag('MlsNumber') ?? '',
      type: tag('PropertyType'),
      status: 'active',
      address: tag('Address'),
      city: tag('City'),
      postal_code: tag('PostalCode'),
      price: numTag('Price'),
      bedrooms: numTag('Bedrooms'),
      bathrooms: numTag('Bathrooms'),
      living_area_sqft: numTag('LivingArea'),
      year_built: numTag('YearBuilt'),
      url: tag('Url'),
    });
  }
  return out.filter((l) => l.mls);
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json' } });
}

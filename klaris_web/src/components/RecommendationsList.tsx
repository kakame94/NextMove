'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

interface Reco {
  listing_id: string;
  rank: number;
  score: number;
  reason: string;
  listing?: {
    type: string | null;
    city: string | null;
    price: number | null;
    bedrooms: number | null;
    bathrooms: number | null;
    address: string | null;
    centris_url: string | null;
  };
}

function formatPrice(p: number | null | undefined) {
  if (p == null) return '—';
  if (p >= 1_000_000) return `${(p / 1_000_000).toFixed(2)}M$`;
  return `${Math.round(p / 1000)}K$`;
}

export function RecommendationsList({ prospectId }: { prospectId: string }) {
  const supabase = createClient();
  const [recos, setRecos] = useState<Reco[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  async function load(force = false) {
    setLoading(true);
    setError(null);
    try {
      const { data, error } = await supabase.functions.invoke('recommend-listings', {
        body: { prospect_id: prospectId, force },
      });
      if (error) throw error;
      const raw = (data as { recommendations?: Omit<Reco, 'listing'>[] })?.recommendations ?? [];
      if (raw.length === 0) {
        setRecos([]);
        return;
      }
      const ids = raw.map((r) => r.listing_id);
      const { data: listings } = await supabase
        .from('listings')
        .select('id, type, city, price, bedrooms, bathrooms, address, centris_url')
        .in('id', ids);
      const byId = new Map<string, Reco['listing']>();
      for (const l of listings ?? []) byId.set(l.id as string, l as Reco['listing']);
      setRecos(
        raw.map((r) => ({ ...r, listing: byId.get(r.listing_id) })).sort((a, b) => a.rank - b.rank)
      );
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void load(false);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [prospectId]);

  return (
    <section>
      <header className="flex items-center justify-between mb-3">
        <h2 className="text-xs font-bold uppercase tracking-widest text-muted-fg flex items-center gap-1.5">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" className="text-primary">
            <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" />
          </svg>
          Recommandations IA
        </h2>
        <button
          onClick={() => void load(true)}
          className="text-xs text-primary font-semibold hover:underline disabled:opacity-50"
          disabled={loading}
        >
          {loading ? '…' : 'Rafraîchir'}
        </button>
      </header>

      {loading && recos == null && (
        <p className="text-sm text-muted-fg italic">Klaris analyse les inscriptions actives…</p>
      )}

      {error && <p className="text-sm text-destructive">Impossible de charger : {error}</p>}

      {recos && recos.length === 0 && (
        <p className="text-sm text-muted-fg">Aucune correspondance pour ce profil pour l’instant.</p>
      )}

      {recos && recos.length > 0 && (
        <ul className="space-y-2">
          {recos.map((r) => (
            <li key={r.listing_id} className="bg-card border border-border rounded-md p-3">
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <div className="text-sm font-semibold truncate">
                    {r.listing?.type ?? 'inscription'} · {r.listing?.city ?? '—'}
                  </div>
                  <div className="text-xs text-muted-fg truncate">
                    {r.listing?.address ?? r.listing?.city ?? '—'}
                  </div>
                </div>
                <span className="font-mono text-sm font-bold text-primary bg-primary-soft px-2 py-0.5 rounded-sm shrink-0">
                  {r.score}
                </span>
              </div>
              <div className="flex flex-wrap gap-1 mt-2">
                <span className="font-mono text-[11px] font-semibold text-primary bg-primary-soft px-1.5 py-0.5 rounded-sm">
                  {formatPrice(r.listing?.price)}
                </span>
                {r.listing?.bedrooms != null && (
                  <span className="font-mono text-[11px] font-semibold text-primary bg-primary-soft px-1.5 py-0.5 rounded-sm">
                    {r.listing.bedrooms} ch
                  </span>
                )}
                {r.listing?.bathrooms != null && (
                  <span className="font-mono text-[11px] font-semibold text-primary bg-primary-soft px-1.5 py-0.5 rounded-sm">
                    {r.listing.bathrooms} sdb
                  </span>
                )}
                {r.listing?.centris_url && (
                  <a
                    href={r.listing.centris_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="font-mono text-[11px] font-semibold text-primary underline ml-auto"
                  >
                    Centris ↗
                  </a>
                )}
              </div>
              {r.reason && (
                <p className="text-xs text-muted-fg italic mt-2">{r.reason}</p>
              )}
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}

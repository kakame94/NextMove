import Link from 'next/link';
import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { MarketplaceCard, type Listing, type RevealInfo } from '@/components/MarketplaceCard';
import { TopupButton } from '@/components/TopupButton';

export const dynamic = 'force-dynamic';

const money = (cents: number) =>
  new Intl.NumberFormat('fr-CA', { style: 'currency', currency: 'CAD', maximumFractionDigits: 0 }).format(
    cents / 100
  );

export default async function MarketplacePage() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: listings } = await supabase
    .from('marketplace_listings')
    .select(
      'id, project_type, sector, financing_band, value_band, heat_score, delai, langue, verbatim, consent_verified, price_cents, status'
    )
    // proxy de "probabilité de deal" : chaleur puis fraîcheur (le financement décide du PRIX, pas de l'ordre)
    .order('heat_score', { ascending: false })
    .order('created_at', { ascending: false })
    .returns<Listing[]>();

  const { data: wallet } = await supabase.from('broker_wallets').select('balance_cents').maybeSingle();
  const balance = wallet?.balance_cents ?? 0;

  // Reveal rows power the guarantee controls (log attempts, track refund state).
  const { data: reveals } = await supabase
    .from('lead_reveals')
    .select('id, listing_id, outcome, contact_attempts');
  const revealByListing = new Map(
    (reveals ?? []).map((r) => [r.listing_id as string, r as RevealInfo])
  );

  const rows = listings ?? [];
  const available = rows.filter((l) => l.status === 'available');

  return (
    <main className="mx-auto max-w-6xl px-6 py-10">
      <div className="mb-8 flex items-start justify-between gap-4">
        <div>
          <Link href="/" className="mb-3 inline-block text-xs font-semibold text-primary">
            ← Tableau de bord
          </Link>
          <h1 className="text-2xl font-bold tracking-tight">Marketplace — vos leads dormants requalifiés</h1>
          <p className="mt-1 max-w-2xl text-sm text-muted-fg">
            Des prospects que vous aviez laissés de côté, re-contactés et re-qualifiés par l’assistante Klaris,
            avec leur consentement de mise en relation. Débloquez le contact actualisé quand la fiche vaut le coup.
          </p>
        </div>
        <div className="flex shrink-0 items-center gap-3">
          <div className="rounded-lg border border-border bg-card px-4 py-3 text-right">
            <div className="text-[10px] uppercase tracking-wider text-muted-fg">Solde</div>
            <div className="font-mono text-lg font-bold">{money(balance)}</div>
          </div>
          <TopupButton />
        </div>
      </div>

      {available.length === 0 && rows.length === 0 ? (
        <div className="rounded-lg border border-dashed border-border px-6 py-16 text-center text-sm text-muted-fg">
          Aucun lead disponible pour l’instant. Les leads dormants consentis apparaîtront ici après requalification.
        </div>
      ) : (
        <div className="grid grid-cols-[repeat(auto-fill,minmax(320px,1fr))] gap-4">
          {rows.map((l) => (
            <MarketplaceCard key={l.id} listing={l} reveal={revealByListing.get(l.id)} />
          ))}
        </div>
      )}

      <p className="mx-auto mt-10 max-w-2xl text-center text-[12px] text-muted-fg">
        Les coordonnées ne quittent jamais le serveur avant paiement. Un lead ne se débloque qu’une fois. Prix
        indexé sur la bande de financement <b>déclarée</b> (non vérifiée par un tiers).
      </p>
    </main>
  );
}

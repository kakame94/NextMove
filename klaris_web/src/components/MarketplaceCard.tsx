'use client';

import { useState, useTransition } from 'react';
import { useRouter } from 'next/navigation';
import { HeatChip } from '@/components/HeatIndicator';
import { revealLead, type RevealedContact } from '@/app/marketplace/actions';
import { markContactAttempt } from '@/app/marketplace/contact-actions';

export interface RevealInfo {
  id: string;
  listing_id: string;
  outcome: 'pending' | 'reached' | 'unreachable' | 'refunded';
  contact_attempts: number;
}

export interface Listing {
  id: string;
  project_type: 'acheteur' | 'vendeur';
  sector: string | null;
  financing_band: 'non_verifie' | 'argent' | 'or' | 'platine';
  value_band: string | null;
  heat_score: number;
  delai: string | null;
  langue: string | null;
  verbatim: string | null;
  consent_verified: boolean;
  price_cents: number;
  status: 'available' | 'revealed' | 'expired' | 'withdrawn';
}

const money = (cents: number) =>
  new Intl.NumberFormat('fr-CA', { style: 'currency', currency: 'CAD', maximumFractionDigits: 0 }).format(
    cents / 100
  );

const TIER: Record<Listing['financing_band'], { label: string; cls: string }> = {
  platine: { label: 'Platine', cls: 'bg-[#6E6A86]/12 text-[#4A4763]' },
  or: { label: 'Or', cls: 'bg-[#E0A836]/18 text-[#B58112]' },
  argent: { label: 'Argent', cls: 'bg-muted text-muted-fg' },
  non_verifie: { label: 'Non vérifié', cls: 'bg-muted text-muted-fg' },
};

export function MarketplaceCard({ listing, reveal }: { listing: Listing; reveal?: RevealInfo }) {
  const router = useRouter();
  const [pending, startTransition] = useTransition();
  const [contact, setContact] = useState<RevealedContact | null>(null);
  const [error, setError] = useState<string | null>(null);
  const revealed = listing.status === 'revealed';
  const tier = TIER[listing.financing_band];

  const logAttempt = (outcome: 'reached' | 'unreachable') => {
    if (!reveal) return;
    startTransition(async () => {
      setError(null);
      const res = await markContactAttempt(reveal.id, outcome);
      if (res.ok) router.refresh();
      else setError('Impossible d’enregistrer la tentative.');
    });
  };

  const onReveal = () =>
    startTransition(async () => {
      setError(null);
      const res = await revealLead(listing.id);
      if (res.ok) {
        setContact(res.contact);
        router.refresh(); // reflect the new wallet balance + status
      } else {
        setError(errLabel(res.error));
      }
    });

  return (
    <div
      className={`flex flex-col overflow-hidden rounded-lg border bg-card transition ${
        contact || revealed ? 'border-[#4F9D69]/60' : 'border-border'
      }`}
    >
      <div className="flex items-center justify-between border-b border-border px-4 py-3">
        <span className={`rounded-full px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide ${tier.cls}`}>
          {tier.label}
          {listing.value_band ? ` · ${listing.value_band}` : ''}
        </span>
        <HeatChip score={listing.heat_score} />
      </div>

      <div className="space-y-3 p-4">
        <div className="flex items-center gap-3">
          <div className="grid h-11 w-11 place-items-center rounded-full bg-muted text-muted-fg">
            {contact ? initials(contact) : '🔒'}
          </div>
          <div className="min-w-0">
            {contact ? (
              <>
                <div className="truncate text-[15px] font-bold">
                  {[contact.prenom, contact.nom].filter(Boolean).join(' ') || '—'}
                </div>
                <div className="truncate font-mono text-xs text-muted-fg">
                  {contact.telephone ?? '—'}
                  {contact.email ? ` · ${contact.email}` : ''}
                </div>
              </>
            ) : (
              <>
                <div className="select-none text-[15px] font-bold blur-[5px]">Prénom Nom</div>
                <div className="text-[11px] text-muted-fg">🔒 Contact masqué jusqu&rsquo;au déblocage</div>
              </>
            )}
          </div>
        </div>

        {listing.verbatim ? (
          <p className="rounded-md bg-muted/60 px-3 py-2 text-[13px] italic text-muted-fg">
            «&nbsp;{listing.verbatim}&nbsp;»
          </p>
        ) : null}

        <div className="flex flex-wrap gap-1.5 text-[11.5px]">
          <Tag>{listing.project_type === 'acheteur' ? 'Acheteur' : 'Vendeur'}</Tag>
          {listing.sector ? <Tag>{listing.sector}</Tag> : null}
          {listing.delai ? <Tag>⏱ {listing.delai}</Tag> : null}
          {listing.langue ? <Tag>{listing.langue.toUpperCase()}</Tag> : null}
          {listing.consent_verified ? (
            <span className="rounded-md bg-[#4F9D69]/12 px-2 py-1 font-semibold text-[#3B7A50]">
              ✓ Consentement vérifié
            </span>
          ) : null}
        </div>

        {(revealed || contact) && reveal ? (
          <GuaranteeControls reveal={reveal} pending={pending} onLog={logAttempt} />
        ) : (
          <p className="text-[11px] text-muted-fg">Remboursé si injoignable après 3 tentatives / 5 jours.</p>
        )}
      </div>

      <div className="mt-auto flex items-center justify-between gap-2 border-t border-border px-4 py-3">
        <div className="text-xs text-muted-fg">
          Révélation
          <br />
          <b className="text-sm text-fg">{money(listing.price_cents)}</b>
        </div>
        {contact || revealed ? (
          <button
            onClick={onReveal}
            disabled={pending}
            className="rounded-md bg-[#4F9D69]/12 px-4 py-2.5 text-[13.5px] font-semibold text-[#3B7A50] disabled:opacity-60"
          >
            {contact ? '✓ Contact débloqué' : pending ? '…' : 'Voir le contact'}
          </button>
        ) : (
          <button
            onClick={onReveal}
            disabled={pending}
            className="rounded-md bg-primary px-4 py-2.5 text-[13.5px] font-semibold text-primary-fg transition hover:brightness-105 disabled:opacity-60"
          >
            {pending ? '…' : `Débloquer · ${money(listing.price_cents)}`}
          </button>
        )}
      </div>

      {error ? <p className="px-4 pb-3 text-xs text-[#D64C2E]">{error}</p> : null}
    </div>
  );
}

function Tag({ children }: { children: React.ReactNode }) {
  return <span className="rounded-md bg-muted px-2 py-1 text-fg">{children}</span>;
}

function GuaranteeControls({
  reveal,
  pending,
  onLog,
}: {
  reveal: RevealInfo;
  pending: boolean;
  onLog: (o: 'reached' | 'unreachable') => void;
}) {
  if (reveal.outcome === 'refunded') {
    return (
      <p className="rounded-md bg-[#4F9D69]/12 px-3 py-2 text-[11.5px] font-semibold text-[#3B7A50]">
        ✓ Injoignable — remboursé sur votre solde.
      </p>
    );
  }
  if (reveal.outcome === 'reached') {
    return <p className="text-[11px] text-muted-fg">✓ Contact établi. Bon closing.</p>;
  }
  return (
    <div className="space-y-1.5">
      <div className="flex gap-2">
        <button
          onClick={() => onLog('reached')}
          disabled={pending}
          className="flex-1 rounded-md border border-border px-3 py-1.5 text-[12px] font-semibold hover:bg-muted disabled:opacity-60"
        >
          Joint ✓
        </button>
        <button
          onClick={() => onLog('unreachable')}
          disabled={pending}
          className="flex-1 rounded-md border border-border px-3 py-1.5 text-[12px] font-semibold hover:bg-muted disabled:opacity-60"
        >
          Injoignable
        </button>
      </div>
      <p className="text-[11px] text-muted-fg">
        {reveal.contact_attempts > 0 ? `${reveal.contact_attempts} tentative(s). ` : ''}
        Remboursé si injoignable après 3 tentatives / 5 jours.
      </p>
    </div>
  );
}

function initials(c: RevealedContact) {
  const a = c.prenom?.[0] ?? '';
  const b = c.nom?.[0] ?? '';
  return (a + b).toUpperCase() || '?';
}

function errLabel(code: string) {
  const map: Record<string, string> = {
    insufficient_funds: 'Solde insuffisant — rechargez votre portefeuille.',
    wallet_absent: 'Aucun portefeuille — rechargez pour débloquer.',
    consent_missing_or_revoked: 'Consentement retiré — lead retiré de la marketplace.',
    listing_unavailable: 'Ce lead n’est plus disponible.',
    not_authenticated: 'Session expirée — reconnectez-vous.',
  };
  return map[code] ?? 'Erreur lors du déblocage.';
}

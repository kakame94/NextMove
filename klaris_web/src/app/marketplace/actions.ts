'use server';

import { createClient } from '@/lib/supabase/server';

export interface RevealedContact {
  nom: string | null;
  prenom: string | null;
  telephone: string | null;
  email: string | null;
}

/**
 * Reveal a marketplace lead. Calls the SECURITY DEFINER `reveal_lead` RPC,
 * which — in one atomic transaction — checks consent, debits the wallet, and
 * returns the contact. The whole flow is scoped to the logged-in courtier
 * server-side (auth.uid()); this action never trusts a client-supplied id
 * beyond passing it to the RLS/DEFINER-guarded function.
 */
export async function revealLead(
  listingId: string
): Promise<{ ok: true; contact: RevealedContact } | { ok: false; error: string }> {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'not_authenticated' };

  const { data, error } = await supabase.rpc('reveal_lead', { p_listing_id: listingId });
  if (error) {
    // Only surface the DB's own clean codes; never leak raw Postgres/schema detail.
    const KNOWN = new Set([
      'not_authenticated',
      'listing_unavailable',
      'consent_missing_or_revoked',
      'insufficient_funds',
      'wallet_absent',
    ]);
    const code = KNOWN.has(error.message) ? error.message : 'reveal_failed';
    if (code === 'reveal_failed') console.error('reveal_lead failed:', error);
    return { ok: false, error: code };
  }

  const row = (Array.isArray(data) ? data[0] : data) as RevealedContact | undefined;
  if (!row) return { ok: false, error: 'listing_unavailable' };

  return { ok: true, contact: row };
}

'use server';

import { revalidatePath } from 'next/cache';
import { createClient } from '@/lib/supabase/server';

type Outcome = 'pending' | 'reached' | 'unreachable';

/**
 * Log a contact attempt on a lead the broker has revealed (guarantee flow).
 * Calls the SECURITY DEFINER `mark_contact_attempt` RPC, scoped server-side
 * to the broker's own reveals (auth.uid()). After ≥3 attempts marked
 * 'unreachable', the daily `process_reveal_guarantee` cron refunds the wallet.
 */
export async function markContactAttempt(
  revealId: string,
  outcome: Outcome
): Promise<{ ok: true; attempts: number; outcome: string } | { ok: false; error: string }> {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'not_authenticated' };

  const { data, error } = await supabase.rpc('mark_contact_attempt', {
    p_reveal_id: revealId,
    p_outcome: outcome,
  });
  if (error) {
    const KNOWN = new Set(['not_authenticated', 'invalid_outcome', 'reveal_not_found']);
    const code = KNOWN.has(error.message) ? error.message : 'attempt_failed';
    if (code === 'attempt_failed') console.error('mark_contact_attempt failed:', error);
    return { ok: false, error: code };
  }

  const row = (Array.isArray(data) ? data[0] : data) as
    | { contact_attempts: number; outcome: string }
    | undefined;
  revalidatePath('/marketplace');
  return { ok: true, attempts: row?.contact_attempts ?? 0, outcome: row?.outcome ?? outcome };
}

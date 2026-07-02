import { createClient } from '@supabase/supabase-js';

/**
 * Service-role Supabase client — BYPASSES RLS. Server-only, never expose to
 * the browser. Used exclusively by trusted server paths (e.g. the Stripe
 * webhook) to call privileged SECURITY DEFINER functions like
 * `record_stripe_topup` that authenticated users must not call directly.
 */
export function createServiceClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    { auth: { persistSession: false, autoRefreshToken: false } }
  );
}

'use server';

import { createClient } from '@/lib/supabase/server';
import { stripe, TOPUP_PRESETS_CENTS } from '@/lib/stripe';

/**
 * Start a Stripe Checkout session to top up the broker's wallet.
 * The credit is NOT applied here — only the Stripe webhook (verified
 * signature, service-role `record_stripe_topup`) can move the balance.
 * We stamp the courtier_id (= auth.uid()) into the session metadata so the
 * webhook credits the right wallet without trusting any client input.
 */
export async function createTopupCheckout(
  amountCents: number
): Promise<{ ok: true; url: string } | { ok: false; error: string }> {
  if (!TOPUP_PRESETS_CENTS.includes(amountCents as (typeof TOPUP_PRESETS_CENTS)[number])) {
    return { ok: false, error: 'invalid_amount' };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'not_authenticated' };

  const appUrl = process.env.NEXT_PUBLIC_APP_URL ?? 'http://localhost:3000';

  try {
    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      client_reference_id: user.id,
      metadata: { courtier_id: user.id },
      line_items: [
        {
          quantity: 1,
          price_data: {
            currency: 'cad',
            unit_amount: amountCents,
            product_data: { name: 'Recharge crédits Klaris Marketplace' },
          },
        },
      ],
      success_url: `${appUrl}/marketplace?topup=success`,
      cancel_url: `${appUrl}/marketplace?topup=cancel`,
    });

    if (!session.url) return { ok: false, error: 'checkout_failed' };
    return { ok: true, url: session.url };
  } catch (e) {
    console.error('createTopupCheckout failed:', e);
    return { ok: false, error: 'checkout_failed' };
  }
}

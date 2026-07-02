import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/lib/stripe';
import { createServiceClient } from '@/lib/supabase/service';

// Stripe needs the raw body for signature verification — do not parse/cache.
export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

/**
 * Stripe webhook. The ONLY path that credits a wallet.
 * - Verifies the Stripe signature (rejects forged calls).
 * - On checkout.session.completed, credits via the service-role
 *   `record_stripe_topup` RPC, which is idempotent on the Stripe event id
 *   (safe against retries / replays).
 */
export async function POST(req: NextRequest) {
  const sig = req.headers.get('stripe-signature');
  const secret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!sig || !secret) {
    return NextResponse.json({ error: 'missing_signature' }, { status: 400 });
  }

  const body = await req.text();
  let event;
  try {
    event = stripe.webhooks.constructEvent(body, sig, secret);
  } catch (e) {
    console.error('stripe signature verification failed:', e);
    return NextResponse.json({ error: 'invalid_signature' }, { status: 400 });
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as {
      amount_total: number | null;
      payment_status: string;
      id: string;
      metadata?: Record<string, string> | null;
    };
    const courtierId = session.metadata?.courtier_id;
    const amount = session.amount_total;

    if (session.payment_status === 'paid' && courtierId && amount && amount > 0) {
      const supabase = createServiceClient();
      const { error } = await supabase.rpc('record_stripe_topup', {
        p_event_id: event.id,
        p_courtier_id: courtierId,
        p_amount_cents: amount,
        p_session_id: session.id,
      });
      if (error) {
        // 500 → Stripe retries; record_stripe_topup is idempotent so retries are safe.
        console.error('record_stripe_topup failed:', error);
        return NextResponse.json({ error: 'credit_failed' }, { status: 500 });
      }
    }
  }

  return NextResponse.json({ received: true });
}

import Stripe from 'stripe';

/**
 * Server-only Stripe client. Never import this in a client component.
 * Uses the account's default API version (no pinned literal to avoid drift).
 */
export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);

/** Preset wallet top-up amounts, in cents (CAD). */
export const TOPUP_PRESETS_CENTS = [20000, 50000, 100000] as const;

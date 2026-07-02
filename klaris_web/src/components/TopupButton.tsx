'use client';

import { useState, useTransition } from 'react';
import { createTopupCheckout } from '@/app/marketplace/topup';

const PRESETS = [
  { cents: 20000, label: '200 $' },
  { cents: 50000, label: '500 $' },
  { cents: 100000, label: '1 000 $' },
];

/** Wallet top-up. Opens Stripe Checkout for the chosen preset. */
export function TopupButton() {
  const [open, setOpen] = useState(false);
  const [pending, start] = useTransition();
  const [err, setErr] = useState<string | null>(null);

  function buy(cents: number) {
    setErr(null);
    start(async () => {
      const res = await createTopupCheckout(cents);
      if (res.ok) window.location.href = res.url;
      else setErr('Échec de la recharge. Réessayez.');
    });
  }

  return (
    <div className="relative">
      <button
        onClick={() => setOpen((v) => !v)}
        className="rounded-lg bg-primary px-3 py-2 text-sm font-semibold text-white hover:brightness-105"
      >
        Recharger
      </button>
      {open && (
        <div className="absolute right-0 z-10 mt-2 w-44 rounded-lg border border-border bg-card p-2 shadow-lg">
          {PRESETS.map((p) => (
            <button
              key={p.cents}
              disabled={pending}
              onClick={() => buy(p.cents)}
              className="flex w-full items-center justify-between rounded-md px-3 py-2 text-sm hover:bg-muted disabled:opacity-50"
            >
              <span>{p.label}</span>
              <span className="text-muted-fg">crédits</span>
            </button>
          ))}
          {err && <p className="px-3 py-1 text-xs text-red-500">{err}</p>}
        </div>
      )}
    </div>
  );
}

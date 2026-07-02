-- ============================================================
-- 011 — MARKETPLACE : recharge Stripe (wallet) + garantie joignabilité
-- ============================================================
-- Étend 010. Deux ajouts :
--   A. Recharge du wallet via Stripe Checkout — idempotence par
--      stripe_event_id, crédit appliqué UNIQUEMENT par le webhook
--      (service_role). Un courtier ne peut jamais se créditer.
--   B. Garantie « injoignable = remboursé » : le courtier journalise ses
--      tentatives d'appel ; un cron rembourse les leads restés injoignables
--      (≥3 tentatives OU >5 jours sans contact), recrédite le wallet et
--      retire le listing. Détruit l'objection « tes leads sont morts ».
--
-- Sécurité : mêmes règles que 010 (RLS force, SECURITY DEFINER + search_path
-- figé, scope par courtier_id = auth.uid(), écritures via fonctions seulement).
-- Idempotent. Run as project owner / service_role.
-- ============================================================

begin;

-- ─────────────────────────────────────────────────────────────
-- A. Recharges Stripe (journal idempotent)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.wallet_topups (
  id uuid primary key default gen_random_uuid(),
  courtier_id uuid not null references public.courtiers(id) on delete cascade,
  stripe_event_id text not null unique,      -- idempotence webhook
  stripe_session_id text,
  amount_cents int not null check (amount_cents > 0),
  status text not null default 'completed' check (status in ('completed','refunded')),
  created_at timestamptz not null default now()
);
create index if not exists idx_topups_courtier on public.wallet_topups(courtier_id, created_at desc);
alter table public.wallet_topups enable row level security;
alter table public.wallet_topups force row level security;

revoke all on public.wallet_topups from anon, authenticated;
grant select on public.wallet_topups to authenticated;

drop policy if exists topups_select_own on public.wallet_topups;
create policy topups_select_own on public.wallet_topups
  for select to authenticated using (courtier_id = auth.uid());
drop policy if exists topups_service_all on public.wallet_topups;
create policy topups_service_all on public.wallet_topups
  for all to service_role using (true) with check (true);

-- record_stripe_topup() — appelée par le webhook Stripe (service_role).
-- Idempotente : rejoue le même event sans double-créditer.
create or replace function public.record_stripe_topup(
  p_event_id text,
  p_courtier_id uuid,
  p_amount_cents int,
  p_session_id text default null
)
returns int                              -- nouveau solde en cents
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_new int;
begin
  if p_amount_cents <= 0 then
    raise exception 'invalid_amount';
  end if;

  -- Idempotence : si l'event est déjà traité, renvoyer le solde courant sans re-créditer.
  if exists (select 1 from public.wallet_topups where stripe_event_id = p_event_id) then
    select balance_cents into v_new from public.broker_wallets where courtier_id = p_courtier_id;
    return coalesce(v_new, 0);
  end if;

  insert into public.wallet_topups (courtier_id, stripe_event_id, stripe_session_id, amount_cents)
    values (p_courtier_id, p_event_id, p_session_id, p_amount_cents);

  -- credit_wallet (010) applique le crédit + trace le ledger, atomiquement.
  v_new := public.credit_wallet(p_courtier_id, p_amount_cents, null);
  return v_new;
end;
$$;
revoke all on function public.record_stripe_topup(text, uuid, int, text) from public, anon, authenticated;

-- ─────────────────────────────────────────────────────────────
-- B. Garantie joignabilité
-- ─────────────────────────────────────────────────────────────
-- mark_contact_attempt() — le courtier journalise une tentative d'appel sur
-- un lead qu'il a révélé. authenticated, scopé à SES révélations.
create or replace function public.mark_contact_attempt(
  p_reveal_id uuid,
  p_outcome text default 'pending'         -- 'pending' | 'reached' | 'unreachable'
)
returns public.lead_reveals
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_row public.lead_reveals%rowtype;
begin
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;
  if p_outcome not in ('pending','reached','unreachable') then
    raise exception 'invalid_outcome';
  end if;

  update public.lead_reveals
     set contact_attempts = contact_attempts + 1,
         outcome = case
                     when outcome in ('refunded') then outcome       -- figé après remboursement
                     when p_outcome = 'pending'   then outcome       -- simple incrément
                     else p_outcome
                   end
   where id = p_reveal_id
     and courtier_id = v_uid
     and outcome <> 'refunded'
   returning * into v_row;

  if not found then
    raise exception 'reveal_not_found';
  end if;
  return v_row;
end;
$$;
revoke all on function public.mark_contact_attempt(uuid, text) from public, anon;
grant execute on function public.mark_contact_attempt(uuid, text) to authenticated;

-- process_reveal_guarantee() — cron (service_role). Rembourse les révélations
-- restées injoignables : soit le courtier a marqué 'unreachable' après ≥3
-- tentatives, soit aucun contact établi >5 jours avec ≥3 tentatives.
-- Recrédite le wallet, trace le ledger, fige la révélation et retire le listing.
create or replace function public.process_reveal_guarantee(
  p_min_attempts int default 3,
  p_stale_days int default 5
)
returns int                              -- nb de révélations remboursées
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count int := 0;
  r record;
begin
  for r in
    select rv.id, rv.courtier_id, rv.price_paid_cents, rv.listing_id
    from public.lead_reveals rv
    where rv.outcome <> 'refunded'
      and rv.price_paid_cents > 0
      and (
        (rv.outcome = 'unreachable' and rv.contact_attempts >= p_min_attempts)
        or (rv.outcome <> 'reached'
            and rv.contact_attempts >= p_min_attempts
            and rv.revealed_at < now() - make_interval(days => p_stale_days))
      )
    for update
  loop
    -- recrédit atomique
    update public.broker_wallets
       set balance_cents = balance_cents + r.price_paid_cents, updated_at = now()
     where courtier_id = r.courtier_id;

    insert into public.wallet_ledger (courtier_id, delta_cents, reason, ref_id)
      values (r.courtier_id, r.price_paid_cents, 'refund', r.listing_id);

    update public.lead_reveals
       set outcome = 'refunded', refunded_at = now()
     where id = r.id;

    -- le lead injoignable est retiré (pas de re-vente)
    update public.marketplace_listings
       set status = 'expired', updated_at = now()
     where id = r.listing_id;

    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
revoke all on function public.process_reveal_guarantee(int, int) from public, anon, authenticated;

commit;

-- ─────────────────────────────────────────────────────────────
-- Planification du cron (si pg_cron dispo — Supabase le fournit).
-- Sinon, appeler process_reveal_guarantee() via un cron n8n / Edge Function
-- avec la clé service_role, une fois par jour.
-- ─────────────────────────────────────────────────────────────
do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule(
      'marketplace-reveal-guarantee',
      '17 8 * * *',                       -- tous les jours 08:17
      $cron$ select public.process_reveal_guarantee(); $cron$
    );
  else
    raise notice 'pg_cron absent — planifier process_reveal_guarantee() via n8n/Edge Function (service_role).';
  end if;
end $$;

-- ============================================================
-- Fumée (service_role) :
--   select record_stripe_topup('evt_test_1', '<courtier>', 20000, 'cs_test');  -- +200 $, idempotent
--   select mark_contact_attempt('<reveal_id>', 'unreachable');                 -- (authenticated)
--   select process_reveal_guarantee();                                          -- rembourse les injoignables
-- ============================================================

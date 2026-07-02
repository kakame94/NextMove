-- ============================================================
-- 010 — MARKETPLACE de leads (Échiquier B : leads dormants du courtier)
-- ============================================================
-- Modèle : un courtier voit SES prospects dormants/tièdes, requalifiés,
-- sous forme de "listings" ANONYMISÉS (bandes de valeur, pas de PII).
-- Il paie (wallet prépayé) pour "révéler" le contact actualisé. Pas de
-- revente à un tiers → finalité `broker_match` couverte par le
-- consentement initial du prospect (Loi 25).
--
-- Sécurité (leçons de l'incident 009) :
--   • marketplace_listings NE CONTIENT AUCUNE PII (nom/tel/email restent
--     dans public.prospects). La projection est sûre par construction.
--   • La PII n'est renvoyée QUE par la fonction reveal_lead(), après
--     paiement + vérification du consentement, dans UNE transaction atomique.
--   • RLS `force` partout, scoping par courtier_id = auth.uid().
--   • anon : aucun accès. Fonctions SECURITY DEFINER avec search_path figé.
--
-- Idempotent. Run as project owner / service_role.
-- ============================================================

begin;

-- ─────────────────────────────────────────────────────────────
-- 1. Consentements (journal immuable, finalité explicite — Loi 25)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.lead_consents (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.prospects(id) on delete cascade,
  purpose text not null check (purpose in ('broker_match','marketplace_resale')),
  granted_at timestamptz not null default now(),
  revoked_at timestamptz,
  consent_text_version text not null default 'v1',
  capture_channel text not null default 'sms' check (capture_channel in ('sms','web','manual')),
  source_message_id text
);
create index if not exists idx_lead_consents_prospect on public.lead_consents(prospect_id, purpose);
alter table public.lead_consents enable row level security;
alter table public.lead_consents force row level security;

-- ─────────────────────────────────────────────────────────────
-- 2. Listings marketplace — PROJECTION SANS PII
--    (aucune colonne nom/telephone/email : la PII vit dans prospects)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.marketplace_listings (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.prospects(id) on delete cascade,
  courtier_id uuid not null references public.courtiers(id) on delete cascade,
  project_type text not null check (project_type in ('acheteur','vendeur')),
  sector text,                         -- quartier (non identifiant seul)
  financing_band text not null default 'non_verifie'
    check (financing_band in ('non_verifie','argent','or','platine')),
  value_band text,                     -- libellé lisible (ex: '600-900k')
  heat_score int not null default 0 check (heat_score between 0 and 10),
  delai text,
  langue text default 'fr' check (langue in ('fr','en')),
  verbatim text,                       -- extrait SCRUBÉ (jamais de PII) — voir publish_dormant_leads
  consent_verified boolean not null default false,
  price_cents int not null default 0 check (price_cents >= 0),
  status text not null default 'available'
    check (status in ('available','revealed','expired','withdrawn')),
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (prospect_id, courtier_id)    -- un prospect = un listing par courtier
);
create index if not exists idx_listings_courtier_status
  on public.marketplace_listings(courtier_id, status);
alter table public.marketplace_listings enable row level security;
alter table public.marketplace_listings force row level security;

-- ─────────────────────────────────────────────────────────────
-- 3. Portefeuille prépayé du courtier + grand livre
-- ─────────────────────────────────────────────────────────────
create table if not exists public.broker_wallets (
  courtier_id uuid primary key references public.courtiers(id) on delete cascade,
  balance_cents int not null default 0 check (balance_cents >= 0),
  updated_at timestamptz not null default now()
);
alter table public.broker_wallets enable row level security;
alter table public.broker_wallets force row level security;

create table if not exists public.wallet_ledger (
  id uuid primary key default gen_random_uuid(),
  courtier_id uuid not null references public.courtiers(id) on delete cascade,
  delta_cents int not null,            -- + recharge, - révélation
  reason text not null check (reason in ('topup','reveal','refund','adjustment')),
  ref_id uuid,                         -- listing_id / reveal_id / stripe ref
  created_at timestamptz not null default now()
);
create index if not exists idx_ledger_courtier on public.wallet_ledger(courtier_id, created_at desc);
alter table public.wallet_ledger enable row level security;
alter table public.wallet_ledger force row level security;

-- ─────────────────────────────────────────────────────────────
-- 4. Révélations (un listing révélé une seule fois → un seul débit)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.lead_reveals (
  id uuid primary key default gen_random_uuid(),
  listing_id uuid not null unique references public.marketplace_listings(id) on delete cascade,
  courtier_id uuid not null references public.courtiers(id) on delete cascade,
  price_paid_cents int not null,
  revealed_at timestamptz not null default now(),
  contact_attempts int not null default 0,
  outcome text not null default 'pending'
    check (outcome in ('pending','reached','unreachable','refunded')),
  refunded_at timestamptz
);
create index if not exists idx_reveals_courtier on public.lead_reveals(courtier_id, revealed_at desc);
alter table public.lead_reveals enable row level security;
alter table public.lead_reveals force row level security;

-- ─────────────────────────────────────────────────────────────
-- 5. RLS : le courtier ne voit QUE ses propres lignes. anon : rien.
--    (auth.uid() = courtiers.id — cf. runbook step 1bis)
-- ─────────────────────────────────────────────────────────────
-- Strip any Supabase default-privilege grants, then re-grant only SELECT.
-- Writes happen exclusively through the SECURITY DEFINER functions below.
revoke all on public.lead_consents, public.marketplace_listings,
  public.broker_wallets, public.wallet_ledger, public.lead_reveals from anon;
revoke all on public.lead_consents, public.marketplace_listings,
  public.broker_wallets, public.wallet_ledger, public.lead_reveals from authenticated;
grant select on public.marketplace_listings, public.broker_wallets,
  public.wallet_ledger, public.lead_reveals to authenticated;

-- marketplace_listings : lecture de ses listings uniquement
drop policy if exists listings_select_own on public.marketplace_listings;
create policy listings_select_own on public.marketplace_listings
  for select to authenticated using (courtier_id = auth.uid());
drop policy if exists listings_service_all on public.marketplace_listings;
create policy listings_service_all on public.marketplace_listings
  for all to service_role using (true) with check (true);

-- broker_wallets
drop policy if exists wallet_select_own on public.broker_wallets;
create policy wallet_select_own on public.broker_wallets
  for select to authenticated using (courtier_id = auth.uid());
drop policy if exists wallet_service_all on public.broker_wallets;
create policy wallet_service_all on public.broker_wallets
  for all to service_role using (true) with check (true);

-- wallet_ledger
drop policy if exists ledger_select_own on public.wallet_ledger;
create policy ledger_select_own on public.wallet_ledger
  for select to authenticated using (courtier_id = auth.uid());
drop policy if exists ledger_service_all on public.wallet_ledger;
create policy ledger_service_all on public.wallet_ledger
  for all to service_role using (true) with check (true);

-- lead_reveals
drop policy if exists reveals_select_own on public.lead_reveals;
create policy reveals_select_own on public.lead_reveals
  for select to authenticated using (courtier_id = auth.uid());
drop policy if exists reveals_service_all on public.lead_reveals;
create policy reveals_service_all on public.lead_reveals
  for all to service_role using (true) with check (true);

-- lead_consents : courtier lit les consentements de SES prospects ; écrit service_role
drop policy if exists consents_select_own on public.lead_consents;
create policy consents_select_own on public.lead_consents
  for select to authenticated using (
    prospect_id in (select p.id from public.prospects p where p.courtier_id = auth.uid())
  );
drop policy if exists consents_service_all on public.lead_consents;
create policy consents_service_all on public.lead_consents
  for all to service_role using (true) with check (true);

-- ─────────────────────────────────────────────────────────────
-- 6. Tarif par bande de financement (net-commission-honnête, Québec)
-- ─────────────────────────────────────────────────────────────
create or replace function public.marketplace_price_cents(p_band text, p_heat int)
returns int
language plpgsql
immutable
set search_path = ''
as $$
declare
  base int;
begin
  base := case p_band
    when 'platine' then 14900   -- 149 $  (financement 900k+)
    when 'or'      then  8900   --  89 $  (600-900k)
    when 'argent'  then  4900   --  49 $  (< 600k)
    else                3900    --  39 $  (déclaré / non vérifié)
  end;
  if coalesce(p_heat, 0) >= 8 then
    base := (base * 3) / 2;     -- +50 % si lead chaud
  end if;
  return base;
end;
$$;

-- ─────────────────────────────────────────────────────────────
-- 7. reveal_lead() — cœur transactionnel : paie + révèle, atomique
--    SECURITY DEFINER : lit prospects / écrit wallet malgré RLS,
--    mais SCOPE tout par courtier_id = auth.uid(). search_path figé.
-- ─────────────────────────────────────────────────────────────
create or replace function public.reveal_lead(p_listing_id uuid)
returns table (nom text, prenom text, telephone text, email text)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := auth.uid();
  v_listing public.marketplace_listings%rowtype;
  v_balance int;
  v_price int;
begin
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  -- Résoudre le listing possédé par ce courtier (n'importe quel statut)
  select * into v_listing
  from public.marketplace_listings
  where id = p_listing_id and courtier_id = v_uid;

  if not found then
    raise exception 'listing_unavailable';
  end if;

  -- Consentement vivant (non révoqué) — GATE LES DEUX CHEMINS : première
  -- révélation ET re-consultation. Le retrait de consentement (revoked_at)
  -- coupe donc toute divulgation ultérieure de la PII (Loi 25).
  if not exists (
    select 1 from public.lead_consents c
    where c.prospect_id = v_listing.prospect_id
      and c.purpose = 'broker_match'
      and c.revoked_at is null
  ) then
    raise exception 'consent_missing_or_revoked';
  end if;

  -- Idempotence : déjà révélé par CE courtier -> renvoyer le contact sans re-débiter
  if exists (
    select 1 from public.lead_reveals r
    where r.listing_id = p_listing_id and r.courtier_id = v_uid
  ) then
    return query
      select p.nom, p.prenom, p.telephone, p.email
      from public.prospects p
      where p.id = v_listing.prospect_id;
    return;
  end if;

  -- Première révélation : le listing doit être disponible. Re-verrouille FOR UPDATE.
  select * into v_listing
  from public.marketplace_listings
  where id = p_listing_id and courtier_id = v_uid and status = 'available'
  for update;

  if not found then
    raise exception 'listing_unavailable';
  end if;

  v_price := v_listing.price_cents;

  -- Verrouille le wallet et vérifie le solde
  select balance_cents into v_balance
  from public.broker_wallets
  where courtier_id = v_uid
  for update;

  if v_balance is null then
    raise exception 'wallet_absent';
  end if;
  if v_balance < v_price then
    raise exception 'insufficient_funds';
  end if;

  -- Débit atomique + trace + révélation + flip statut
  update public.broker_wallets
    set balance_cents = balance_cents - v_price, updated_at = now()
    where courtier_id = v_uid;

  insert into public.lead_reveals (listing_id, courtier_id, price_paid_cents)
    values (p_listing_id, v_uid, v_price);

  insert into public.wallet_ledger (courtier_id, delta_cents, reason, ref_id)
    values (v_uid, -v_price, 'reveal', p_listing_id);

  update public.marketplace_listings
    set status = 'revealed', updated_at = now()
    where id = p_listing_id;

  return query
    select p.nom, p.prenom, p.telephone, p.email
    from public.prospects p
    where p.id = v_listing.prospect_id;
end;
$$;

revoke all on function public.reveal_lead(uuid) from public, anon;
grant execute on function public.reveal_lead(uuid) to authenticated;

-- ─────────────────────────────────────────────────────────────
-- 8. credit_wallet() — recharge : SERVICE_ROLE UNIQUEMENT (webhook Stripe).
--    Un courtier ne peut JAMAIS se créditer lui-même.
-- ─────────────────────────────────────────────────────────────
create or replace function public.credit_wallet(
  p_courtier_id uuid, p_amount_cents int, p_ref uuid default null
)
returns int
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
  insert into public.broker_wallets (courtier_id, balance_cents)
    values (p_courtier_id, p_amount_cents)
    on conflict (courtier_id)
    do update set balance_cents = public.broker_wallets.balance_cents + p_amount_cents,
                  updated_at = now()
    returning balance_cents into v_new;
  insert into public.wallet_ledger (courtier_id, delta_cents, reason, ref_id)
    values (p_courtier_id, p_amount_cents, 'topup', p_ref);
  return v_new;
end;
$$;
-- NON exposée à authenticated/anon : appelée uniquement avec la service_role key.
revoke all on function public.credit_wallet(uuid, int, uuid) from public, anon, authenticated;

-- ─────────────────────────────────────────────────────────────
-- 9. publish_dormant_leads() — le wedge : ressuscite les leads dormants
--    du courtier en listings anonymisés. SERVICE_ROLE / cron.
--    Ne publie QUE les prospects avec consentement broker_match vivant.
--    Le verbatim doit être fourni PRÉ-SCRUBÉ (aucune PII).
-- ─────────────────────────────────────────────────────────────
create or replace function public.publish_dormant_leads(p_courtier_id uuid, p_max int default 50)
returns int
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count int := 0;
  r record;
  v_band text;
  v_amount int;
begin
  for r in
    select p.id, p.type_projet, p.score_chaleur, p.langue_preferee,
           ba.montant_pre_approbation, ba.budget_max,
           coalesce(ba.delai_projet, bv.delai_vente) as delai_src,
           -- Quartier acheteur seulement. JAMAIS l'adresse civique du vendeur
           -- (bv.adresse_bien = PII identifiante) dans une projection sans PII.
           array_to_string(ba.localisation_souhaitee, ', ') as secteur_src,
           bv.prix_souhaite, bv.evaluation_municipale
    from public.prospects p
    left join public.besoins_acheteur ba on ba.prospect_id = p.id
    left join public.besoins_vendeur  bv on bv.prospect_id = p.id
    where p.courtier_id = p_courtier_id
      and (p.statut in ('perdu','en_qualification') or p.score_chaleur <= 6)
      and exists (
        select 1 from public.lead_consents c
        where c.prospect_id = p.id and c.purpose = 'broker_match' and c.revoked_at is null
      )
      and not exists (
        select 1 from public.marketplace_listings l
        where l.prospect_id = p.id and l.courtier_id = p_courtier_id
      )
    order by p.score_chaleur desc
    limit greatest(p_max, 0)
  loop
    v_amount := coalesce(r.montant_pre_approbation, r.budget_max, r.prix_souhaite, r.evaluation_municipale, 0);
    v_band := case
      when v_amount >= 900000 then 'platine'
      when v_amount >= 600000 then 'or'
      when v_amount >= 1      then 'argent'
      else 'non_verifie'
    end;

    insert into public.marketplace_listings (
      prospect_id, courtier_id, project_type, sector, financing_band, value_band,
      heat_score, delai, langue, consent_verified, price_cents, status
    ) values (
      r.id, p_courtier_id, r.type_projet, r.secteur_src, v_band,
      case v_band when 'platine' then '900k+' when 'or' then '600-900k'
                  when 'argent' then '< 600k' else 'non vérifié' end,
      coalesce(r.score_chaleur, 0), r.delai_src, r.langue_preferee,
      true, public.marketplace_price_cents(v_band, coalesce(r.score_chaleur, 0)), 'available'
    )
    on conflict (prospect_id, courtier_id) do nothing;

    v_count := v_count + 1;
  end loop;
  return v_count;
end;
$$;
revoke all on function public.publish_dormant_leads(uuid, int) from public, anon, authenticated;

-- updated_at auto sur listings
drop trigger if exists set_updated_at_listings on public.marketplace_listings;
create trigger set_updated_at_listings
  before update on public.marketplace_listings
  for each row execute function public.handle_updated_at();

commit;

-- ============================================================
-- VÉRIFICATION (avec la clé anon — tout doit être vide/refusé) :
--   select * from marketplace_listings;   -- anon -> 0 / erreur
--   select reveal_lead('...');             -- anon -> not_authenticated
-- Fumée (service_role) :
--   select credit_wallet('<courtier_uuid>', 20000);      -- +200 $
--   select publish_dormant_leads('<courtier_uuid>', 20); -- publie N listings
-- ============================================================

-- ============================================================
-- KLARIS — Migration 008 — Convergence canonique
-- ============================================================
-- Résout 3 défauts critiques identifiés à l'audit du 2026-05-15 :
--
-- 1. `conversations` et `relances` créées 2× avec schémas incompatibles
--    (001_create_next_move_schema.sql vs klaris_ios/migrations/003_sprint2_klaris.sql).
--    Le `CREATE TABLE IF NOT EXISTS` du Sprint 2 a été silencieusement ignoré
--    en présence des tables NextMove racine — l'app iOS pointe sur des colonnes
--    inexistantes (`direction`, `sender`, `content`, `step`, `status`...).
--
-- 2. Colonne `prospects.score` référencée par 4 fichiers (klaris_web + vues
--    Klaris Sprint 2/3/4) alors qu'elle s'appelle `score_chaleur` en DB.
--
-- 3. Pas de contrainte UNIQUE sur `prospects.telephone` (clé de lookup SMS) →
--    doublons silencieux. Pas de table SMS STOP/opt-out (obligation CASL).
--    ON DELETE CASCADE généralisé → suppression prospect efface l'historique
--    (violation OACIQ traçabilité).
--
-- Stratégie :
--   - Schéma canonique = celui de klaris_ios/migrations/003_sprint2_klaris.sql
--     (plus riche, utilisé par l'app iOS en production).
--   - Convergence destructive sur conversations/relances : tables vides en
--     dev/pilote, perte de données acceptable. Backup automatique préalable.
--   - Soft-delete (deleted_at) + UNIQUE telephone + table sms_optout.
-- ============================================================

begin;

-- ────────────────────────────────────────────────────────────
-- 0. Backups préalables (idempotent, no-op si tables vides)
-- ────────────────────────────────────────────────────────────
create schema if not exists _backup_pre_convergence;

do $$
begin
  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='conversations') then
    execute 'create table if not exists _backup_pre_convergence.conversations_old as table public.conversations';
  end if;

  if exists (select 1 from information_schema.tables where table_schema='public' and table_name='relances') then
    execute 'create table if not exists _backup_pre_convergence.relances_old as table public.relances';
  end if;
end$$;

-- ────────────────────────────────────────────────────────────
-- 1. Drop deprecated NextMove tables (root schema)
-- ────────────────────────────────────────────────────────────
-- Si tables existent avec ancien schéma (role/contenu/canal pour conversations,
-- type_relance/date_prevue/statut pour relances), on drop. Le Sprint 2 les
-- recrée ensuite avec le schéma riche Klaris.
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='conversations' and column_name='role'
  ) then
    drop view if exists public.conversation_summaries cascade;
    drop table public.conversations cascade;
    raise notice 'Dropped legacy conversations table (NextMove root schema)';
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='relances' and column_name='type_relance'
  ) then
    drop view if exists public.relances_enriched cascade;
    drop table public.relances cascade;
    raise notice 'Dropped legacy relances table (NextMove root schema)';
  end if;
end$$;

-- ────────────────────────────────────────────────────────────
-- 2. Recreate conversations (canonical Klaris schema)
-- ────────────────────────────────────────────────────────────
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.prospects(id) on delete restrict,
  direction text not null check (direction in ('inbound', 'outbound')),
  sender text not null check (sender in ('prospect', 'klaris', 'broker')),
  content text not null,
  sent_at timestamptz not null default now(),
  read_by_broker boolean not null default false,
  deleted_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_conv_prospect_sent on public.conversations(prospect_id, sent_at desc) where deleted_at is null;
create index if not exists idx_conv_unread on public.conversations(prospect_id) where read_by_broker = false and deleted_at is null;

alter table public.conversations enable row level security;

drop policy if exists "broker reads own prospects' messages" on public.conversations;
create policy "broker reads own prospects' messages" on public.conversations
  for select using (
    exists (
      select 1 from public.prospects p
      where p.id = conversations.prospect_id and p.courtier_id = auth.uid()
    )
  );

drop policy if exists "broker writes broker-typed messages" on public.conversations;
create policy "broker writes broker-typed messages" on public.conversations
  for insert with check (
    sender = 'broker' and exists (
      select 1 from public.prospects p
      where p.id = conversations.prospect_id and p.courtier_id = auth.uid()
    )
  );

drop policy if exists "broker marks read" on public.conversations;
create policy "broker marks read" on public.conversations
  for update using (
    exists (
      select 1 from public.prospects p
      where p.id = conversations.prospect_id and p.courtier_id = auth.uid()
    )
  );

-- ────────────────────────────────────────────────────────────
-- 3. Recreate relances (canonical Klaris schema)
-- ────────────────────────────────────────────────────────────
create table if not exists public.relances (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.prospects(id) on delete restrict,
  step text not null check (step in ('j2', 'j5', 'j10')),
  status text not null default 'pending'
    check (status in ('pending', 'awaiting_approval', 'sent', 'skipped', 'stopped')),
  scheduled_for timestamptz not null,
  content text,
  approved_at timestamptz,
  skipped_at timestamptz,
  sent_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_relances_due on public.relances(scheduled_for, status)
  where status in ('pending', 'awaiting_approval') and deleted_at is null;

alter table public.relances enable row level security;

drop policy if exists "broker reads own prospects' relances" on public.relances;
create policy "broker reads own prospects' relances" on public.relances
  for select using (
    exists (
      select 1 from public.prospects p
      where p.id = relances.prospect_id and p.courtier_id = auth.uid()
    )
  );

drop policy if exists "broker approves/skips relances" on public.relances;
create policy "broker approves/skips relances" on public.relances
  for update using (
    exists (
      select 1 from public.prospects p
      where p.id = relances.prospect_id and p.courtier_id = auth.uid()
    )
  );

-- ────────────────────────────────────────────────────────────
-- 4. Fix `prospects.score` reference (klaris_web + vues Sprint 2/3/4)
-- ────────────────────────────────────────────────────────────
-- La colonne canonique reste `score_chaleur int 0-10`.
-- On ajoute `score` comme generated column alias pour compatibilité.
alter table public.prospects
  add column if not exists score int generated always as (score_chaleur) stored;

comment on column public.prospects.score is
  'Alias rétro-compat sur score_chaleur. Préférer score_chaleur dans le nouveau code.';

-- ────────────────────────────────────────────────────────────
-- 5. UNIQUE sur prospects.telephone (lookup SMS principal)
-- ────────────────────────────────────────────────────────────
-- Dédoublonne en gardant la fiche la plus récente avant de poser la contrainte.
with ranked as (
  select id, telephone,
    row_number() over (partition by courtier_id, telephone order by created_at desc) as rn
  from public.prospects
  where telephone is not null
)
update public.prospects p
   set telephone = telephone || '__dup_' || ranked.id
  from ranked
 where p.id = ranked.id and ranked.rn > 1;

create unique index if not exists ux_prospects_courtier_telephone
  on public.prospects(courtier_id, telephone)
  where telephone is not null;

-- ────────────────────────────────────────────────────────────
-- 6. Soft-delete sur prospects (au lieu de cascade destructive)
-- ────────────────────────────────────────────────────────────
alter table public.prospects
  add column if not exists deleted_at timestamptz;

create index if not exists idx_prospects_active
  on public.prospects(courtier_id) where deleted_at is null;

-- ────────────────────────────────────────────────────────────
-- 7. Table sms_optout — obligation CASL/Loi 25
-- ────────────────────────────────────────────────────────────
-- Tracée par numéro de téléphone. Vérifiée avant tout envoi sortant n8n.
create table if not exists public.sms_optout (
  id uuid primary key default gen_random_uuid(),
  telephone text not null,
  reason text not null default 'stop_keyword'
    check (reason in ('stop_keyword', 'manual', 'complaint', 'bounce', 'oaciq_request')),
  source_message text,
  courtier_id uuid references public.courtiers(id) on delete set null,
  created_at timestamptz not null default now(),
  -- une seule entrée active par numéro (un opt-out écrase l'ancien)
  unique (telephone)
);

create index if not exists idx_sms_optout_telephone on public.sms_optout(telephone);
alter table public.sms_optout enable row level security;

-- Lecture/écriture : tout courtier authentifié peut lire (vérif anti-CASL)
-- et tout système peut écrire (service role contourne RLS).
drop policy if exists "authenticated reads optout" on public.sms_optout;
create policy "authenticated reads optout" on public.sms_optout
  for select using (auth.role() = 'authenticated' or auth.role() = 'service_role');

-- Helper function utilisée par n8n
create or replace function public.is_phone_optout(p_telephone text)
returns boolean
language sql stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.sms_optout where telephone = p_telephone);
$$;

comment on function public.is_phone_optout is
  'Retourne true si un numéro est en opt-out CASL. À appeler depuis n8n avant tout envoi sortant.';

-- ────────────────────────────────────────────────────────────
-- 8. Audit log — table déjà créée Sprint 2, mais on s'assure ON DELETE
-- ────────────────────────────────────────────────────────────
-- Sprint 2 utilise déjà ON DELETE SET NULL — pas de fix nécessaire.

-- ────────────────────────────────────────────────────────────
-- 9. Recreate vues Sprint 2 avec colonnes canoniques
-- ────────────────────────────────────────────────────────────
create or replace view public.conversation_summaries as
select
  p.id as prospect_id,
  p.nom as prospect_name,
  p.score_chaleur as prospect_score,   -- ← canonique (pas p.score)
  p.courtier_id,
  last_msg.content as last_message,
  last_msg.sent_at as last_sent_at,
  coalesce(unread.count, 0) as unread_count
from public.prospects p
left join lateral (
  select content, sent_at
  from public.conversations c
  where c.prospect_id = p.id and c.deleted_at is null
  order by c.sent_at desc limit 1
) last_msg on true
left join lateral (
  select count(*)::int as count
  from public.conversations c
  where c.prospect_id = p.id
    and c.direction = 'inbound'
    and c.read_by_broker = false
    and c.deleted_at is null
) unread on true
where p.deleted_at is null and last_msg.sent_at is not null;

create or replace view public.relances_enriched as
select
  r.*,
  p.nom as prospect_name,
  p.score_chaleur as prospect_score,
  p.courtier_id
from public.relances r
join public.prospects p on p.id = r.prospect_id
where r.deleted_at is null and p.deleted_at is null;

commit;

-- ────────────────────────────────────────────────────────────
-- Notes post-migration
-- ────────────────────────────────────────────────────────────
-- 1. Les vues Sprint 2-4 référençant `p.score` continuent de marcher grâce
--    à la generated column.
-- 2. À terme, migrer les vues à `score_chaleur` directement et supprimer
--    `prospects.score` (mais non bloquant).
-- 3. n8n workflow doit appeler `is_phone_optout(telephone)` AVANT INSERT
--    conversations et AVANT Send SMS.
-- 4. Soft delete : pour effacer un prospect, faire `UPDATE prospects SET
--    deleted_at = now()`. Le hard delete reste possible (RLS-restreint au
--    DPO via service_role).

-- =============================================================================
-- Sprint 7 — Relances scheduler + drift reconciliation (drop j10)
-- =============================================================================
-- Aligns DB with spec v1.2 (post-Figma J+2/J+5 sequence only).
-- T3 / J+10 retired. Adds scheduler state + audit log fields.
--
-- Apply:
--   psql "$SUPABASE_DB_URL" -f migrations/008_sprint7_relances_scheduler.sql
--
-- Reversible: yes (down section at bottom, commented).
-- =============================================================================

begin;

-- -----------------------------------------------------------------------------
-- 1. Reconcile legacy j10 rows
-- -----------------------------------------------------------------------------
-- Strategy: mark pending j10 as 'skipped' (audit-safe), promote sent j10 to j5
-- for historical record. Avoid hard delete to preserve OACIQ 6-year retention.

update public.relances
   set status = 'skipped',
       content = coalesce(content, '') || E'\n\n[Auto-skipped: J+10 retiré spec v1.1]'
 where step = 'j10'
   and status in ('pending', 'awaiting_approval');

update public.relances
   set step = 'j5'
 where step = 'j10'
   and status = 'sent';

-- Any remaining edge cases (skipped/stopped j10) → flatten to j5 for constraint.
update public.relances
   set step = 'j5'
 where step = 'j10';

-- -----------------------------------------------------------------------------
-- 2. Replace CHECK constraint to drop 'j10'
-- -----------------------------------------------------------------------------
alter table public.relances
  drop constraint if exists relances_step_check;

alter table public.relances
  add constraint relances_step_check
  check (step in ('j2', 'j5'));

-- -----------------------------------------------------------------------------
-- 3. Scheduler state — single-row table tracking cron health
-- -----------------------------------------------------------------------------
create table if not exists public.relances_scheduler_state (
  id                 boolean primary key default true,  -- enforce single row
  last_run_at        timestamptz,
  last_run_duration_ms int,
  last_processed     int default 0,
  last_sent          int default 0,
  last_blocked       int default 0,
  last_deferred      int default 0,
  last_errors        int default 0,
  last_error_message text,
  constraint singleton check (id)
);

insert into public.relances_scheduler_state (id) values (true)
on conflict do nothing;

-- -----------------------------------------------------------------------------
-- 4. Audit decisions log (Loi 25 / OACIQ 6-year retention)
-- -----------------------------------------------------------------------------
-- Each can_send_relance() decision logged for traceability.

create table if not exists public.relance_decisions (
  id            uuid primary key default gen_random_uuid(),
  prospect_id   uuid not null references public.prospects(id) on delete cascade,
  courtier_id   uuid references public.courtiers(id),
  type_relance  text not null,
  action        text not null check (action in ('SEND', 'BLOCK', 'DEFER')),
  reason        text not null,
  retry_at      timestamptz,
  guards_evaluated text[],
  audit_message text,
  created_at    timestamptz not null default now()
);

create index if not exists idx_relance_decisions_prospect
  on public.relance_decisions(prospect_id, created_at desc);

create index if not exists idx_relance_decisions_action
  on public.relance_decisions(action, created_at desc);

-- RLS — broker reads own prospects' decisions only
alter table public.relance_decisions enable row level security;

drop policy if exists "broker reads own decisions" on public.relance_decisions;
create policy "broker reads own decisions" on public.relance_decisions
  for select using (
    exists (
      select 1 from public.prospects p
      where p.id = relance_decisions.prospect_id
        and p.courtier_id = auth.uid()
    )
  );

-- -----------------------------------------------------------------------------
-- 5. Holidays Québec 2026 (config table — easy to override per year)
-- -----------------------------------------------------------------------------
create table if not exists public.holidays_qc (
  date date primary key,
  label text not null
);

insert into public.holidays_qc (date, label) values
  ('2026-01-01', 'Jour de l''An'),
  ('2026-04-03', 'Vendredi saint'),
  ('2026-04-06', 'Lundi de Pâques'),
  ('2026-05-18', 'Journée nationale des Patriotes'),
  ('2026-06-24', 'Fête nationale du Québec'),
  ('2026-07-01', 'Fête du Canada'),
  ('2026-09-07', 'Fête du Travail'),
  ('2026-10-12', 'Action de grâces'),
  ('2026-12-25', 'Noël'),
  ('2026-12-26', 'Lendemain de Noël')
on conflict (date) do nothing;

-- Public read (no PII)
alter table public.holidays_qc enable row level security;
drop policy if exists "anyone reads holidays" on public.holidays_qc;
create policy "anyone reads holidays" on public.holidays_qc
  for select using (true);

-- -----------------------------------------------------------------------------
-- 6. RPC claim_pending_relances — atomic claim with FOR UPDATE SKIP LOCKED
-- -----------------------------------------------------------------------------
-- Called by Edge Function relances-scheduler. Atomically claims a batch of
-- pending relances and marks them as 'awaiting_approval' (preventing other
-- cron instances from picking the same row).
--
-- Idempotency: if cron overlaps, SKIP LOCKED guarantees no double-fetch.
-- Returns the original 'pending' rows — caller sets final status post-send.

create or replace function public.claim_pending_relances(p_batch_size int default 100)
returns table (
  id            uuid,
  prospect_id   uuid,
  step          text,
  status        text,
  scheduled_for timestamptz,
  content       text
)
language plpgsql
security definer
as $$
begin
  return query
  with claimed as (
    select r.id
      from public.relances r
     where r.status = 'pending'
       and r.scheduled_for <= now()
     order by r.scheduled_for asc
     limit p_batch_size
       for update skip locked
  )
  update public.relances r
     set status = 'awaiting_approval'
    from claimed
   where r.id = claimed.id
  returning r.id, r.prospect_id, r.step, r.status, r.scheduled_for, r.content;
end;
$$;

revoke all on function public.claim_pending_relances(int) from public;
grant execute on function public.claim_pending_relances(int) to service_role;

commit;

-- =============================================================================
-- DOWN (commented — uncomment to revert)
-- =============================================================================
-- begin;
-- alter table public.relances drop constraint if exists relances_step_check;
-- alter table public.relances add constraint relances_step_check check (step in ('j2', 'j5', 'j10'));
-- drop table if exists public.relance_decisions;
-- drop table if exists public.relances_scheduler_state;
-- drop table if exists public.holidays_qc;
-- commit;

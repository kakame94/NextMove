-- Klaris Sprint 3 — briefing + stats schema additions
-- Apply after 003_sprint2_klaris.sql

-- ────────────────────────────────────────────────────────────
-- 1. Briefings (one row per broker per day)
-- ────────────────────────────────────────────────────────────
create table if not exists public.briefings (
  id uuid primary key default gen_random_uuid(),
  courtier_id uuid not null references public.courtiers(id) on delete cascade,
  payload jsonb not null,
  generated_at timestamptz not null default now()
);

create index if not exists idx_briefings_courtier_recent on public.briefings(courtier_id, generated_at desc);

alter table public.briefings enable row level security;

create policy "broker reads own briefings" on public.briefings
  for select using (courtier_id = auth.uid());

-- Briefing-enabled flag on courtiers
alter table public.courtiers
  add column if not exists briefing_enabled boolean not null default true;

-- ────────────────────────────────────────────────────────────
-- 2. broker_stats_snapshot RPC (powering iOS stats screen)
-- ────────────────────────────────────────────────────────────
create or replace function public.broker_stats_snapshot()
returns jsonb
language plpgsql
security invoker
as $$
declare
  v_uid uuid := auth.uid();
  v_total int;
  v_hot int;
  v_avg numeric;
  v_qualified int;
  v_closed int;
  v_monthly jsonb;
begin
  select count(*) into v_total
  from public.prospects
  where courtier_id = v_uid;

  select count(*) into v_hot
  from public.prospects
  where courtier_id = v_uid and score >= 7
    and status not in ('conclu', 'perdu');

  select coalesce(round(avg(score)::numeric, 2), 0) into v_avg
  from public.prospects
  where courtier_id = v_uid;

  select count(*) into v_qualified
  from public.prospects
  where courtier_id = v_uid and status in ('qualifie', 'contacte', 'rendez_vous', 'conclu');

  select count(*) into v_closed
  from public.prospects
  where courtier_id = v_uid and status = 'conclu';

  -- Monthly buckets — past 6 months
  with months as (
    select date_trunc('month', current_date - (n || ' months')::interval) as m
    from generate_series(0, 5) n
    order by m asc
  ),
  bucket as (
    select
      m as month,
      coalesce((
        select count(*)
        from public.prospects p
        where p.courtier_id = v_uid
          and date_trunc('month', p.created_at) = m
      ), 0) as new_leads,
      coalesce((
        select count(*)
        from public.prospects p
        where p.courtier_id = v_uid
          and date_trunc('month', p.created_at) = m
          and p.status in ('qualifie', 'contacte', 'rendez_vous', 'conclu')
      ), 0) as qualified,
      coalesce((
        select count(*)
        from public.prospects p
        where p.courtier_id = v_uid
          and date_trunc('month', p.created_at) = m
          and p.status = 'conclu'
      ), 0) as closed
    from months
  )
  select coalesce(jsonb_agg(jsonb_build_object(
    'month',     to_char(month, 'YYYY-MM-DD'),
    'new_leads', new_leads,
    'qualified', qualified,
    'closed',    closed
  )), '[]'::jsonb) into v_monthly
  from bucket;

  return jsonb_build_object(
    'total_prospects',  v_total,
    'hot_prospects',    v_hot,
    'avg_score',        v_avg,
    'conversion_rate',  case when v_qualified = 0 then 0 else round(v_closed::numeric / v_qualified * 100)::int end,
    'monthly',          v_monthly
  );
end;
$$;

grant execute on function public.broker_stats_snapshot() to authenticated;

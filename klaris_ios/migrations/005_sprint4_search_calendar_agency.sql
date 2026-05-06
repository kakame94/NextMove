-- Klaris Sprint 4 — search FTS + calendar + templates + agency
-- Apply after 004_sprint3_briefing_stats.sql

-- ════════════════════════════════════════════════════════════
-- 1. Full-text search (tsvector + GIN index)
-- ════════════════════════════════════════════════════════════
alter table public.prospects
  add column if not exists search_vec tsvector
  generated always as (
    setweight(to_tsvector('french', coalesce(nom, '')), 'A') ||
    setweight(to_tsvector('french', coalesce(secteur, '')), 'B') ||
    setweight(to_tsvector('simple', coalesce(telephone, '')), 'C') ||
    setweight(to_tsvector('french', coalesce(delai, '')), 'D')
  ) stored;

create index if not exists idx_prospects_search on public.prospects using gin(search_vec);

create or replace function public.search_prospects(q text)
returns setof public.prospects
language sql
security invoker
stable
as $$
  select *
  from public.prospects p
  where p.courtier_id = auth.uid()
    and (
      p.search_vec @@ plainto_tsquery('french', q)
      or p.nom ilike '%' || q || '%'
      or p.telephone ilike '%' || q || '%'
    )
  order by ts_rank(p.search_vec, plainto_tsquery('french', q)) desc, p.score desc
  limit 50;
$$;

grant execute on function public.search_prospects(text) to authenticated;

-- ════════════════════════════════════════════════════════════
-- 2. Appointments
-- ════════════════════════════════════════════════════════════
create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.prospects(id) on delete cascade,
  courtier_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  notes text,
  location text,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  status text not null default 'scheduled'
    check (status in ('scheduled', 'completed', 'no_show', 'cancelled')),
  ekit_event_id text,        -- iOS EventKit identifier (sync round-trip)
  created_at timestamptz not null default now()
);

create index if not exists idx_appt_courtier_starts on public.appointments(courtier_id, starts_at desc);
create index if not exists idx_appt_prospect on public.appointments(prospect_id, starts_at desc);

alter table public.appointments enable row level security;

create policy "broker manages own appointments" on public.appointments
  for all using (courtier_id = auth.uid()) with check (courtier_id = auth.uid());

-- ════════════════════════════════════════════════════════════
-- 3. SMS templates
-- ════════════════════════════════════════════════════════════
create table if not exists public.sms_templates (
  id uuid primary key default gen_random_uuid(),
  courtier_id uuid not null references auth.users(id) on delete cascade,
  shortcode text not null,           -- ex: "merci_visite"
  label text not null,               -- ex: "Merci pour la visite"
  body text not null,                -- with placeholders {nom}, {secteur}
  uses int not null default 0,
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create unique index if not exists idx_templates_courtier_shortcode
  on public.sms_templates(courtier_id, shortcode);
create index if not exists idx_templates_courtier_recent
  on public.sms_templates(courtier_id, uses desc);

alter table public.sms_templates enable row level security;

create policy "broker manages own templates" on public.sms_templates
  for all using (courtier_id = auth.uid()) with check (courtier_id = auth.uid());

create or replace function public.increment_template_usage(p_id uuid)
returns void
language sql
security invoker
as $$
  update public.sms_templates
  set uses = uses + 1
  where id = p_id and courtier_id = auth.uid();
$$;

grant execute on function public.increment_template_usage(uuid) to authenticated;

-- ════════════════════════════════════════════════════════════
-- 4. Agency / multi-courtier
-- ════════════════════════════════════════════════════════════
create table if not exists public.agencies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  brand_color text,
  created_at timestamptz not null default now()
);

create table if not exists public.agency_members (
  agency_id uuid not null references public.agencies(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'broker'
    check (role in ('admin', 'manager', 'broker')),
  joined_at timestamptz not null default now(),
  primary key (agency_id, user_id)
);

create index if not exists idx_agency_members_user on public.agency_members(user_id);

alter table public.agencies enable row level security;
alter table public.agency_members enable row level security;

-- Members can read own agency.
create policy "members read own agency" on public.agencies
  for select using (
    exists (
      select 1 from public.agency_members am
      where am.agency_id = agencies.id and am.user_id = auth.uid()
    )
  );

-- Members read peer member rows of their own agency.
create policy "members read peers" on public.agency_members
  for select using (
    exists (
      select 1 from public.agency_members me
      where me.agency_id = agency_members.agency_id and me.user_id = auth.uid()
    )
  );

-- Admins manage members.
create policy "admins manage members" on public.agency_members
  for all using (
    exists (
      select 1 from public.agency_members me
      where me.agency_id = agency_members.agency_id
        and me.user_id = auth.uid()
        and me.role = 'admin'
    )
  ) with check (
    exists (
      select 1 from public.agency_members me
      where me.agency_id = agency_members.agency_id
        and me.user_id = auth.uid()
        and me.role = 'admin'
    )
  );

-- Extend prospects with optional agency scoping (lead pool + reassignment).
alter table public.prospects
  add column if not exists agency_id uuid references public.agencies(id) on delete set null,
  add column if not exists assigned_at timestamptz;

create index if not exists idx_prospects_agency_assigned on public.prospects(agency_id, courtier_id, assigned_at desc);

-- Allow agency admins to reassign leads within their agency.
drop policy if exists "agency admin reassigns" on public.prospects;
create policy "agency admin reassigns" on public.prospects
  for update using (
    agency_id is not null
    and exists (
      select 1 from public.agency_members am
      where am.agency_id = prospects.agency_id
        and am.user_id = auth.uid()
        and am.role in ('admin', 'manager')
    )
  );

-- Aggregate stats RPC for agency dashboard.
create or replace function public.agency_team_stats(p_agency_id uuid)
returns table (
  user_id uuid,
  email text,
  role text,
  total_prospects int,
  hot_prospects int,
  avg_score numeric,
  closed_30d int
)
language sql
security invoker
stable
as $$
  select
    am.user_id,
    u.email,
    am.role,
    coalesce(count(p.id), 0)::int as total_prospects,
    coalesce(count(p.id) filter (where p.score >= 7 and p.status not in ('conclu', 'perdu')), 0)::int as hot_prospects,
    coalesce(round(avg(p.score)::numeric, 2), 0) as avg_score,
    coalesce(count(p.id) filter (where p.status = 'conclu' and p.updated_at >= now() - interval '30 days'), 0)::int as closed_30d
  from public.agency_members am
  join auth.users u on u.id = am.user_id
  left join public.prospects p on p.courtier_id = am.user_id and p.agency_id = p_agency_id
  where am.agency_id = p_agency_id
    and exists (
      select 1 from public.agency_members me
      where me.agency_id = p_agency_id
        and me.user_id = auth.uid()
        and me.role in ('admin', 'manager')
    )
  group by am.user_id, u.email, am.role
  order by total_prospects desc;
$$;

grant execute on function public.agency_team_stats(uuid) to authenticated;

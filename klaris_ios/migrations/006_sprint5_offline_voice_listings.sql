-- Klaris Sprint 5 — voice memos + listings + onboarding flag + geo
-- Apply after 005_sprint4_search_calendar_agency.sql

-- ════════════════════════════════════════════════════════════
-- 1. Voice memos (broker post-visit notes, Whisper-transcribed)
-- ════════════════════════════════════════════════════════════
create table if not exists public.voice_memos (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid references public.prospects(id) on delete set null,
  courtier_id uuid not null references auth.users(id) on delete cascade,
  duration_seconds int not null,
  audio_path text,                 -- Storage path (bucket "memos/<user>/<id>.m4a")
  transcript text,                 -- Whisper FR transcript
  summary text,                    -- Claude one-line summary
  status text not null default 'pending'
    check (status in ('pending', 'transcribing', 'ready', 'failed')),
  created_at timestamptz not null default now()
);

create index if not exists idx_memos_courtier_recent on public.voice_memos(courtier_id, created_at desc);
create index if not exists idx_memos_prospect on public.voice_memos(prospect_id, created_at desc);

alter table public.voice_memos enable row level security;

create policy "broker manages own memos" on public.voice_memos
  for all using (courtier_id = auth.uid()) with check (courtier_id = auth.uid());

-- ════════════════════════════════════════════════════════════
-- 2. Centris listings (pulled live, scoped per agency)
-- ════════════════════════════════════════════════════════════
create table if not exists public.listings (
  id text primary key,                    -- Centris MLS number
  agency_id uuid references public.agencies(id) on delete set null,
  type text,                              -- ex: 'duplex', 'condo'
  status text not null default 'active'
    check (status in ('active', 'sold', 'withdrawn', 'expired')),
  address text,
  city text,
  postal_code text,
  price int,
  bedrooms int,
  bathrooms int,
  living_area_sqft int,
  year_built int,
  centris_url text,
  raw_payload jsonb,
  fetched_at timestamptz not null default now()
);

create index if not exists idx_listings_agency_status on public.listings(agency_id, status, price);
create index if not exists idx_listings_city on public.listings(city, type, price);

alter table public.listings enable row level security;

create policy "agency members read listings" on public.listings
  for select using (
    listings.agency_id is null
    or exists (
      select 1 from public.agency_members am
      where am.agency_id = listings.agency_id and am.user_id = auth.uid()
    )
  );

-- ════════════════════════════════════════════════════════════
-- 3. Onboarding + geocoding columns on prospects
-- ════════════════════════════════════════════════════════════
alter table public.prospects
  add column if not exists latitude double precision,
  add column if not exists longitude double precision,
  add column if not exists geocoded_at timestamptz;

create index if not exists idx_prospects_geo on public.prospects(latitude, longitude)
  where latitude is not null;

alter table public.courtiers
  add column if not exists onboarding_completed_at timestamptz;

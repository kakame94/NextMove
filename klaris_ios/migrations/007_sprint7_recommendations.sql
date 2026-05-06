-- Klaris Sprint 7 — Claude-powered listing recommendations per prospect
-- Apply after 006_sprint5_offline_voice_listings.sql

create table if not exists public.prospect_recommendations (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.prospects(id) on delete cascade,
  listing_id text not null references public.listings(id) on delete cascade,
  rank int not null,                          -- 1 = best match
  score int not null check (score between 0 and 100),
  reason text not null,                       -- short FR/EN justification from Claude
  generated_at timestamptz not null default now(),
  model text not null,                        -- e.g. 'claude-haiku-4-5-20251001'
  unique (prospect_id, listing_id)
);

alter table public.prospect_recommendations enable row level security;

create policy "broker reads own prospect recommendations"
  on public.prospect_recommendations for select
  using (
    exists (
      select 1 from public.prospects p
      where p.id = prospect_recommendations.prospect_id
        and p.courtier_id = auth.uid()
    )
  );

-- Service role (edge function) bypasses RLS via SUPABASE_SERVICE_ROLE_KEY,
-- so no insert/update/delete policy needed for clients (they don't write).

create index if not exists idx_recos_prospect
  on public.prospect_recommendations(prospect_id, generated_at desc);

-- ============================================================
-- 009 — SECURITY LOCKDOWN: revoke anonymous access to PII tables
-- ============================================================
-- CONTEXT (incident 2026-06-09):
--   The public `anon` Supabase key (embedded in the static dashboard
--   index.html, committed to the PUBLIC GitHub repo) was able to SELECT
--   every row of the core PII tables. RLS was ENABLED but one or more
--   permissive SELECT policies had been added live for `anon` / `public`
--   to power the unauthenticated dashboard. Effect: prospect names,
--   phone numbers, e-mails and full SMS conversation history were
--   world-readable (Québec Law 25 / PIPEDA breach).
--
-- This migration removes every anon/public-facing policy on the PII
-- tables, hard-revokes table privileges from `anon`, and FORCEs RLS so
-- table owners can't bypass it. After applying, the anon key returns
-- empty result sets; the dashboard must authenticate (see index.html)
-- so reads run as `authenticated` and resolve through the courtier-
-- scoped policies below.
--
-- Run as the project owner / service_role (Supabase SQL editor or CLI).
-- Idempotent: safe to run more than once.
-- AFTER APPLYING: rotate the anon (publishable) key in the Supabase
-- dashboard, since the old one was public — and treat the leaked rows
-- as disclosed.
-- ============================================================

begin;

-- PII / sensitive tables that must never be readable by `anon`.
-- (Only tables that exist are touched; missing ones are skipped.)
do $$
declare
  t text;
  pol record;
  tables text[] := array[
    'courtiers',
    'prospects',
    'besoins_acheteur',
    'besoins_vendeur',
    'conversations',
    'relances',
    'briefings',
    'eval_results',
    'n8n_chat_histories'
  ];
begin
  foreach t in array tables loop
    -- skip tables that aren't deployed on this database
    if to_regclass('public.' || t) is null then
      raise notice 'skip %, not present', t;
      continue;
    end if;

    -- 1. enable + FORCE row level security
    execute format('alter table public.%I enable row level security;', t);
    execute format('alter table public.%I force row level security;', t);

    -- 2. drop every policy that grants access to anon or public
    for pol in
      select policyname
      from pg_policies
      where schemaname = 'public'
        and tablename = t
        and (roles && array['anon']::name[] or roles && array['public']::name[])
    loop
      raise notice 'dropping permissive policy % on %', pol.policyname, t;
      execute format('drop policy if exists %I on public.%I;', pol.policyname, t);
    end loop;

    -- 3. hard-revoke direct table privileges from anon
    execute format('revoke all on public.%I from anon;', t);
  end loop;
end $$;

-- Belt-and-suspenders: revoke the schema-wide default grants the
-- Supabase bootstrap hands to `anon` for these objects.
revoke all on all tables in schema public from anon;
-- (re-grant table access to authenticated/service_role only; RLS still applies)
grant select on all tables in schema public to authenticated;
grant all    on all tables in schema public to service_role;

-- ============================================================
-- Re-assert the intended policies (authenticated courtier sees only
-- their own data; service_role / n8n keeps full access). Idempotent.
-- ============================================================

-- courtiers
drop policy if exists courtiers_select_own  on public.courtiers;
drop policy if exists courtiers_service_all on public.courtiers;
create policy courtiers_select_own  on public.courtiers for select to authenticated using (id = auth.uid());
create policy courtiers_service_all on public.courtiers for all    to service_role using (true) with check (true);

-- prospects
drop policy if exists prospects_select_own  on public.prospects;
drop policy if exists prospects_service_all on public.prospects;
create policy prospects_select_own  on public.prospects for select to authenticated using (courtier_id = auth.uid());
create policy prospects_service_all on public.prospects for all    to service_role using (true) with check (true);

-- besoins_acheteur
drop policy if exists besoins_acheteur_select_own  on public.besoins_acheteur;
drop policy if exists besoins_acheteur_service_all on public.besoins_acheteur;
create policy besoins_acheteur_select_own  on public.besoins_acheteur for select to authenticated
  using (prospect_id in (select id from public.prospects where courtier_id = auth.uid()));
create policy besoins_acheteur_service_all on public.besoins_acheteur for all to service_role using (true) with check (true);

-- besoins_vendeur
drop policy if exists besoins_vendeur_select_own  on public.besoins_vendeur;
drop policy if exists besoins_vendeur_service_all on public.besoins_vendeur;
create policy besoins_vendeur_select_own  on public.besoins_vendeur for select to authenticated
  using (prospect_id in (select id from public.prospects where courtier_id = auth.uid()));
create policy besoins_vendeur_service_all on public.besoins_vendeur for all to service_role using (true) with check (true);

-- conversations
drop policy if exists conversations_select_own  on public.conversations;
drop policy if exists conversations_service_all on public.conversations;
create policy conversations_select_own  on public.conversations for select to authenticated
  using (prospect_id in (select id from public.prospects where courtier_id = auth.uid()));
create policy conversations_service_all on public.conversations for all to service_role using (true) with check (true);

-- relances
drop policy if exists relances_select_own  on public.relances;
drop policy if exists relances_service_all on public.relances;
create policy relances_select_own  on public.relances for select to authenticated
  using (prospect_id in (select id from public.prospects where courtier_id = auth.uid()));
create policy relances_service_all on public.relances for all to service_role using (true) with check (true);

-- briefings (only if present; courtier-scoped)
do $$
begin
  if to_regclass('public.briefings') is not null then
    execute 'drop policy if exists briefings_service_all on public.briefings';
    execute 'create policy briefings_service_all on public.briefings for all to service_role using (true) with check (true)';
  end if;
end $$;

-- eval_results (QA data — service_role + authenticated read only; only if present)
do $$
begin
  if to_regclass('public.eval_results') is not null then
    execute 'drop policy if exists eval_results_service_all on public.eval_results';
    execute 'create policy eval_results_service_all on public.eval_results for all to service_role using (true) with check (true)';
    execute 'drop policy if exists eval_results_select_auth on public.eval_results';
    execute 'create policy eval_results_select_auth on public.eval_results for select to authenticated using (true)';
  end if;
end $$;

-- n8n_chat_histories (raw LLM memory keyed by phone — service_role ONLY,
-- never readable by anon or even authenticated dashboard users)
do $$
begin
  if to_regclass('public.n8n_chat_histories') is not null then
    execute 'drop policy if exists n8n_chat_histories_service_all on public.n8n_chat_histories';
    execute 'create policy n8n_chat_histories_service_all on public.n8n_chat_histories for all to service_role using (true) with check (true)';
  end if;
end $$;

commit;

-- ============================================================
-- VERIFY (run separately with the anon key — every row must be 0):
--   select count(*) from prospects;        -- as anon -> 0 rows / error
--   select count(*) from conversations;    -- as anon -> 0 rows / error
-- Or via REST with the anon key:
--   curl "$URL/rest/v1/prospects?select=id" -H "apikey: $ANON" -H "Authorization: Bearer $ANON"
--   -> expect []  (not the real rows)
-- ============================================================

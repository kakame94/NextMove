-- ============================================================
-- migration_003 — Enable RLS on the legacy MVP PII tables
-- ============================================================
-- schema.sql created config_courtier / clients / conversations /
-- relances / rendez_vous WITHOUT row level security. These tables hold
-- prospect PII (names, phones, emails, budgets, verbatim SMS). The n8n
-- backend talks to them with the SERVICE_ROLE key (bypasses RLS), so the
-- backend keeps working — but with RLS off, the same tables are readable
-- by anyone holding the anon key (the documented SUPABASE_ANON_KEY).
--
-- This migration turns RLS on and grants access to service_role only.
-- anon/authenticated get nothing (deny-by-default: RLS on + no policy).
-- Idempotent. Run as project owner / service_role.
-- ============================================================

begin;

do $$
declare
  t text;
  tables text[] := array['config_courtier','clients','conversations','relances','rendez_vous'];
begin
  foreach t in array tables loop
    if to_regclass('public.' || t) is null then
      continue;
    end if;
    execute format('alter table public.%I enable row level security;', t);
    execute format('alter table public.%I force row level security;', t);
    execute format('revoke all on public.%I from anon, authenticated;', t);
    execute format('drop policy if exists %I on public.%I;', t || '_service_all', t);
    execute format(
      'create policy %I on public.%I for all to service_role using (true) with check (true);',
      t || '_service_all', t
    );
  end loop;
end $$;

commit;

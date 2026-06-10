-- ============================================================
-- 008 — Fix cross-tenant PII leak: enforce RLS on the iOS views
-- ============================================================
-- INCIDENT (2026-06-09): the views conversation_summaries and
-- relances_enriched (created in 003) were defined WITHOUT
-- `security_invoker = on`. In Postgres a view runs with its OWNER's
-- rights (the superuser that ran the migration), which BYPASSES the
-- RLS policies on prospects/conversations/relances. Any authenticated
-- broker reading the view through the anon/PostgREST endpoint therefore
-- saw EVERY broker's prospect names, scores and last-message content
-- (Law 25 / PIPEDA cross-tenant leak).
--
-- This forward migration recreates both views with security_invoker so
-- the querying user's RLS is enforced, locks the SECURITY DEFINER audit
-- function's search_path, and revokes anon access. Idempotent.
-- Run as project owner / service_role.
-- ============================================================

begin;

do $$
begin
  if to_regclass('public.conversation_summaries') is not null then
    execute 'alter view public.conversation_summaries set (security_invoker = on)';
    execute 'revoke all on public.conversation_summaries from anon';
  end if;

  if to_regclass('public.relances_enriched') is not null then
    execute 'alter view public.relances_enriched set (security_invoker = on)';
    -- only the service-role daily-briefing function consumes this view
    execute 'revoke all on public.relances_enriched from anon, authenticated';
  end if;
end $$;

-- Pin search_path on the SECURITY DEFINER trigger function (hardening)
do $$
begin
  if to_regprocedure('public.log_relance_change()') is not null then
    execute 'alter function public.log_relance_change() set search_path = ''''';
  end if;
end $$;

commit;

-- VERIFY: every view must report security_invoker=on
--   select relname, reloptions from pg_class
--   where relkind = 'v' and relname in ('conversation_summaries','relances_enriched');
--   -> reloptions must contain {security_invoker=on}

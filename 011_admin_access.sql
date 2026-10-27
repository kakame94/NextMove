-- 011 — Accès admin OptiAI au dashboard (lecture seule sur toutes les données).
-- Les policies admin s'ajoutent (OR) à celles des courtiers, qui restent inchangées.
-- Pour ajouter un admin : insert into public.admins (user_id, email) values ('<auth uid>', '<email>');

create table if not exists public.admins (
  user_id uuid primary key references auth.users (id) on delete cascade,
  email text,
  created_at timestamptz not null default now()
);
alter table public.admins enable row level security;
revoke all on public.admins from anon;
drop policy if exists admins_select_self on public.admins;
create policy admins_select_self on public.admins
  for select to authenticated using (user_id = auth.uid());

create or replace function public.is_admin()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;
revoke execute on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

do $$
declare t text;
begin
  foreach t in array array['prospects','conversations','relances','besoins_acheteur','besoins_vendeur',
                           'courtiers','briefings','eval_results','monitoring_events'] loop
    execute format('drop policy if exists %I on public.%I', t || '_select_admin', t);
    execute format('create policy %I on public.%I for select to authenticated using (public.is_admin())',
                   t || '_select_admin', t);
  end loop;
end $$;

-- monitoring_events : la lecture authentifiée passe uniquement par la policy admin
grant select on public.monitoring_events to authenticated;

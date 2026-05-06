-- Klaris Sprint 2 — Supabase schema additions
-- Run after 001_create_next_move_schema.sql + 002_add_rls_policies.sql

-- ────────────────────────────────────────────────────────────
-- 1. Conversations (SMS thread per prospect)
-- ────────────────────────────────────────────────────────────
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.prospects(id) on delete cascade,
  direction text not null check (direction in ('inbound', 'outbound')),
  sender text not null check (sender in ('prospect', 'klaris', 'broker')),
  content text not null,
  sent_at timestamptz not null default now(),
  read_by_broker boolean not null default false,
  created_at timestamptz not null default now()
);

create index if not exists idx_conv_prospect_sent on public.conversations(prospect_id, sent_at desc);
create index if not exists idx_conv_unread on public.conversations(prospect_id) where read_by_broker = false;

alter table public.conversations enable row level security;

create policy "broker reads own prospects' messages" on public.conversations
  for select using (
    exists (
      select 1 from public.prospects p
      where p.id = conversations.prospect_id
        and p.courtier_id = auth.uid()
    )
  );

create policy "broker writes broker-typed messages" on public.conversations
  for insert with check (
    sender = 'broker'
    and exists (
      select 1 from public.prospects p
      where p.id = conversations.prospect_id
        and p.courtier_id = auth.uid()
    )
  );

create policy "broker marks read" on public.conversations
  for update using (
    exists (
      select 1 from public.prospects p
      where p.id = conversations.prospect_id
        and p.courtier_id = auth.uid()
    )
  );

-- ────────────────────────────────────────────────────────────
-- 2. Conversation summaries view (powering iOS list)
-- ────────────────────────────────────────────────────────────
create or replace view public.conversation_summaries as
select
  p.id as prospect_id,
  p.nom as prospect_name,
  p.score as prospect_score,
  p.courtier_id,
  last_msg.content as last_message,
  last_msg.sent_at as last_sent_at,
  coalesce(unread.count, 0) as unread_count
from public.prospects p
left join lateral (
  select content, sent_at
  from public.conversations c
  where c.prospect_id = p.id
  order by c.sent_at desc
  limit 1
) last_msg on true
left join lateral (
  select count(*)::int as count
  from public.conversations c
  where c.prospect_id = p.id
    and c.direction = 'inbound'
    and c.read_by_broker = false
) unread on true
where last_msg.sent_at is not null;

-- View inherits RLS via underlying tables.

-- ────────────────────────────────────────────────────────────
-- 3. Relances (J+2, J+5, J+10 sequence)
-- ────────────────────────────────────────────────────────────
create table if not exists public.relances (
  id uuid primary key default gen_random_uuid(),
  prospect_id uuid not null references public.prospects(id) on delete cascade,
  step text not null check (step in ('j2', 'j5', 'j10')),
  status text not null default 'pending'
    check (status in ('pending', 'awaiting_approval', 'sent', 'skipped', 'stopped')),
  scheduled_for timestamptz not null,
  content text,
  approved_at timestamptz,
  skipped_at timestamptz,
  sent_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists idx_relances_due on public.relances(scheduled_for, status)
  where status in ('pending', 'awaiting_approval');

alter table public.relances enable row level security;

create policy "broker reads own prospects' relances" on public.relances
  for select using (
    exists (
      select 1 from public.prospects p
      where p.id = relances.prospect_id
        and p.courtier_id = auth.uid()
    )
  );

create policy "broker approves/skips relances" on public.relances
  for update using (
    exists (
      select 1 from public.prospects p
      where p.id = relances.prospect_id
        and p.courtier_id = auth.uid()
    )
  );

-- View enrichment (add prospect name + score for iOS card display)
create or replace view public.relances_enriched as
select
  r.*,
  p.nom as prospect_name,
  p.score as prospect_score,
  p.courtier_id
from public.relances r
join public.prospects p on p.id = r.prospect_id;

-- ────────────────────────────────────────────────────────────
-- 4. Device tokens (FCM push)
-- ────────────────────────────────────────────────────────────
create table if not exists public.device_tokens (
  token text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text not null check (platform in ('ios', 'android')),
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists idx_device_tokens_user on public.device_tokens(user_id);

alter table public.device_tokens enable row level security;

create policy "users manage own tokens" on public.device_tokens
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ────────────────────────────────────────────────────────────
-- 5. Audit log (OACIQ traceability)
-- ────────────────────────────────────────────────────────────
create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  prospect_id uuid references public.prospects(id) on delete set null,
  action text not null,
  payload jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_audit_user_created on public.audit_log(user_id, created_at desc);
create index if not exists idx_audit_prospect on public.audit_log(prospect_id, created_at desc);

alter table public.audit_log enable row level security;

create policy "users read own audit" on public.audit_log
  for select using (user_id = auth.uid());

-- Trigger: log every relance state change for OACIQ
create or replace function public.log_relance_change() returns trigger as $$
begin
  insert into public.audit_log (user_id, prospect_id, action, payload)
  values (
    auth.uid(),
    new.prospect_id,
    'relance_' || new.status,
    jsonb_build_object('step', new.step, 'old_status', old.status, 'new_status', new.status)
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_relance_audit on public.relances;
create trigger trg_relance_audit
  after update of status on public.relances
  for each row when (old.status is distinct from new.status)
  execute function public.log_relance_change();

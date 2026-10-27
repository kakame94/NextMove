-- 010 — Drapeau de notification séparé du statut (appliquée en prod le 2026-10-18)
-- Avant : next_move_notify_courtier passait le prospect à 'en_recherche' après
-- l'envoi du courriel « lead chaud », donc un prospect qualifié apparaissait
-- « En recherche » dans le dashboard. Le workflow filtre et marque maintenant
-- sur notifie_at ; le statut reste sous le contrôle de Klaris et du courtier.

alter table public.prospects add column if not exists notifie_at timestamptz;

comment on column public.prospects.notifie_at is
  'Date de la notification courriel "lead chaud" au courtier (next_move_notify_courtier).';

update public.prospects set notifie_at = updated_at, statut = 'qualifie'
where statut = 'en_recherche' and score_chaleur >= 7 and notifie_at is null;

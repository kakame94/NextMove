-- ============================================================================
-- 010_relances_system.sql
-- Klaris — Systeme de relance automatisee (Sprint 2)
-- Spec complete : 24_NextMove/docs/spec-systeme-relance.md
--
-- Pre-requis : 001, 002. Compatible avec 008 applique OU non (detection de
-- forme en section 7). Si 009_security_lockdown_anon.sql (PR #25) est present,
-- l'appliquer AVANT ce fichier. Executer via le role admin proprietaire des
-- tables (postgres sur Supabase, qui a BYPASSRLS — les UPDATE de donnees
-- doivent bypasser RLS). Re-executable (idempotent).
--
-- Principes :
--   - Schema canonique relances = forme 008/iOS ETENDUE (status EN,
--     scheduled_for/sent_at/content conserves; step renomme type_relance).
--     L'app iOS garde la compat via l'alias `step` de relances_enriched.
--   - Opt-out = sms_optout (cree par 008, recree ici si absent). PERMANENT :
--     presence d'une ligne = opt-out actif; START supprime la ligne.
--   - Toutes les ecritures runtime passent par service_role (n8n).
--   - Scheduler STATELESS : candidats recalcules a chaque run; relances = journal.
--   - can_send_relance() = source de verite des garde-fous pour les messages
--     prospect et les nudges courtier (T1/T2/T4/T6). Le briefing T11 (sans
--     prospect) est garde par le workflow W2 — voir spec §7.2.
-- ============================================================================

BEGIN;

-- ----------------------------------------------------------------------------
-- 1. relance_config — constantes ajustables sans migration
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.relance_config (
  cle        TEXT PRIMARY KEY,
  valeur     JSONB NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO public.relance_config (cle, valeur) VALUES
  -- cadence minimale entre 2 relances de meme type, en heures
  ('cadence_min_heures', '{"inactif_j2":120,"inactif_j5":720,"nudge_courtier_chaud":48,"nudge_courtier_urgent":4,"rdv_rappel_j1":0,"rdv_rappel_j7":0,"post_rdv_feedback":0,"etape_financement":120,"reactivation_longterme":4320,"anniversaire":8760,"briefing_quotidien":24}'::jsonb),
  ('max_attempts', '{"inactif_j2":1,"inactif_j5":1,"nudge_courtier_chaud":3,"nudge_courtier_urgent":5,"rdv_rappel_j1":1,"rdv_rappel_j7":1,"post_rdv_feedback":1,"etape_financement":2,"reactivation_longterme":1,"anniversaire":1,"briefing_quotidien":1}'::jsonb),
  -- fenetres d'envoi prospect (heures locales prospect)
  ('fenetre_prospect', '{"debut":8,"fin":20,"defer_heure":9,"lundi_debut":11,"vendredi_fin":16,"samedi_debut":10,"samedi_fin":18,"dimanche_bloque":true}'::jsonb),
  -- fenetre courtier (nudges) : 7j/7
  ('fenetre_courtier', '{"debut":6,"fin":22}'::jsonb),
  -- MAINTENANCE : liste a regenerer chaque annee (2027 a ajouter fin 2026)
  ('jours_feries_qc', '["2026-01-01","2026-01-02","2026-04-03","2026-04-06","2026-05-18","2026-06-24","2026-07-01","2026-09-07","2026-10-12","2026-12-25","2026-12-26"]'::jsonb),
  ('budget', '{"cap_cad":50.0,"alerte_pct":80,"cout_sms_cad":0.015}'::jsonb),
  -- stub MVP : passer a false manuellement si degradation Twilio constatee
  -- (mesure automatique du sender score = P2)
  ('sender_score_ok', 'true'::jsonb),
  ('anti_harcelement', '{"max_relances":2,"fenetre_heures":48}'::jsonb),
  -- kill switch global du scheduler (fail-closed : ligne absente = bloque)
  ('relance_active', 'true'::jsonb)
ON CONFLICT (cle) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 2. Colonnes additionnelles prospects / courtiers
-- ----------------------------------------------------------------------------
ALTER TABLE public.prospects
  ADD COLUMN IF NOT EXISTS last_inbound_message_at  TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS last_courtier_action_at  TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS pause_relances           BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS opted_out_at             TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS timezone                 TEXT NOT NULL DEFAULT 'America/Montreal',
  ADD COLUMN IF NOT EXISTS relances_lock_until      TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deleted_at               TIMESTAMPTZ;  -- no-op si 008 applique

-- D14 : l'intake upsert le prospect des le 1er SMS, avant de connaitre le type
-- de projet. La contrainte CHECK existante reste valide pour les valeurs non nulles.
ALTER TABLE public.prospects ALTER COLUMN type_projet DROP NOT NULL;

-- PAS de backfill de last_inbound_message_at : n8n_chat_histories n'a aucun
-- timestamp exploitable. NULL = prospect historique exclu de T1/T2 (les
-- predicats des candidats evaluent NULL -> false). La colonne se peuple au
-- fil de l'eau via l'intake (spec §7.3 M1). Relancer le stock historique =
-- decision explicite de Joanel (verif consentement CASL prealable), jamais
-- un effet de bord de migration.

ALTER TABLE public.courtiers
  ADD COLUMN IF NOT EXISTS timezone                  TEXT NOT NULL DEFAULT 'America/Montreal',
  ADD COLUMN IF NOT EXISTS pause_relances            BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS mode_approbation_relances BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS briefing_email            BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS briefing_sms              BOOLEAN NOT NULL DEFAULT false;

-- ----------------------------------------------------------------------------
-- 3. sms_optout — opt-out PERMANENT (CASL / Loi 25), store unique
--    Cree par 008; recree ici a l'identique pour les chaines sans 008.
--    Semantique : presence d'une ligne = opt-out actif. START supprime la
--    ligne (l'historique des consentements/retraits vit dans `consentements`).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sms_optout (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  telephone      TEXT NOT NULL,
  reason         TEXT NOT NULL DEFAULT 'stop_keyword'
                 CHECK (reason IN ('stop_keyword','manual','complaint','bounce','oaciq_request')),
  source_message TEXT,
  courtier_id    UUID REFERENCES public.courtiers(id) ON DELETE SET NULL,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (telephone)
);

CREATE INDEX IF NOT EXISTS idx_sms_optout_telephone ON public.sms_optout(telephone);

CREATE OR REPLACE FUNCTION public.is_phone_optout(p_telephone TEXT)
RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $$
  SELECT EXISTS (SELECT 1 FROM public.sms_optout WHERE telephone = p_telephone);
$$;

-- ----------------------------------------------------------------------------
-- 4. consentements — journal CASL (timestamp + source obligatoires)
--    CASL : consentement implicite suite a une DEMANDE DE RENSEIGNEMENTS
--    (SMS entrant d'un prospect) = 6 MOIS. 2 ans uniquement apres une
--    transaction (relation d'affaires existante). expires_at est calcule par
--    l'intake a l'insertion (spec §7.3 M1).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.consentements (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  telephone   TEXT NOT NULL,
  prospect_id UUID REFERENCES public.prospects(id) ON DELETE SET NULL,
  type        TEXT NOT NULL CHECK (type IN ('implicite','explicite')),
  source      TEXT NOT NULL CHECK (source IN ('sms_inbound','transaction','formulaire','manuel','sms_start')),
  capture_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  expires_at  TIMESTAMPTZ,   -- sms_inbound: +6 mois; transaction: +2 ans; explicite: NULL
  revoked_at  TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_consentements_telephone ON public.consentements (telephone);

-- ----------------------------------------------------------------------------
-- 5. relance_templates — corps des messages, GSM-7 strict (sans accents)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.relance_templates (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type_relance TEXT NOT NULL,
  canal        TEXT NOT NULL CHECK (canal IN ('sms','email','push')),
  langue       TEXT NOT NULL DEFAULT 'fr-CA',
  variante     TEXT NOT NULL DEFAULT 'defaut',
  corps        TEXT NOT NULL,
  actif        BOOLEAN NOT NULL DEFAULT true,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (type_relance, canal, langue, variante)
);

-- ----------------------------------------------------------------------------
-- 6. rendez_vous — version minimale pour debloquer T6
--    (cf. docs/rendez_vous-table-spec.md; defauts choisis parmi Q1-Q8)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.rendez_vous (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id UUID NOT NULL REFERENCES public.prospects(id) ON DELETE CASCADE,
  courtier_id UUID NOT NULL REFERENCES public.courtiers(id),
  date_heure  TIMESTAMPTZ NOT NULL,
  lieu        TEXT,
  type_rdv    TEXT NOT NULL DEFAULT 'rencontre'
              CHECK (type_rdv IN ('rencontre','visite','signature','appel')),
  statut      TEXT NOT NULL DEFAULT 'confirme'
              CHECK (statut IN ('propose','confirme','annule','complete','no_show')),
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index unique requis par l'upsert intake (M1/M5 : ON CONFLICT
-- (courtier_id, telephone) WHERE telephone IS NOT NULL). Pose par 008;
-- recree ici (avec dedoublonnage prealable, logique miroir de 008) pour
-- les chaines sans 008.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes
                 WHERE schemaname='public' AND indexname='ux_prospects_courtier_telephone') THEN
    WITH ranked AS (
      SELECT id,
             row_number() OVER (PARTITION BY courtier_id, telephone ORDER BY created_at DESC) AS rn
      FROM public.prospects
      WHERE telephone IS NOT NULL
    )
    UPDATE public.prospects p
       SET telephone = p.telephone || '__dup_' || p.id
      FROM ranked
     WHERE p.id = ranked.id AND ranked.rn > 1;

    CREATE UNIQUE INDEX ux_prospects_courtier_telephone
      ON public.prospects(courtier_id, telephone)
      WHERE telephone IS NOT NULL;
  END IF;
END$$;

-- Echec explicite si une table rendez_vous incompatible preexiste
-- (mvp_adjointe_ia definit une variante keyee sur client_id).
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_schema='public' AND table_name='rendez_vous'
                   AND column_name='prospect_id') THEN
    RAISE EXCEPTION 'rendez_vous existe avec un schema incompatible (prospect_id absent) — converger manuellement avant 010';
  END IF;
END$$;

CREATE INDEX IF NOT EXISTS idx_rendez_vous_date ON public.rendez_vous (date_heure)
  WHERE statut = 'confirme';

-- ----------------------------------------------------------------------------
-- 7. relances — convergence vers le schema canonique (forme 008/iOS etendue)
--    Gere les deux formes de depart :
--      - 008/iOS : step / status / scheduled_for / sent_at / content
--      - 001     : type_relance / statut / date_prevue / date_executee / contenu
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS public.relances_enriched;   -- depend de relances.*, recreee en fin

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='relances' AND column_name='step') THEN
    -- Forme 008/iOS
    ALTER TABLE public.relances RENAME COLUMN step TO type_relance;
    ALTER TABLE public.relances DROP CONSTRAINT IF EXISTS relances_step_check;
    ALTER TABLE public.relances DROP CONSTRAINT IF EXISTS relances_status_check;
    UPDATE public.relances SET type_relance = CASE type_relance
      WHEN 'j2'  THEN 'inactif_j2'
      WHEN 'j5'  THEN 'inactif_j5'
      WHEN 'j10' THEN 'reactivation_longterme'
      ELSE type_relance END;

  ELSIF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema='public' AND table_name='relances' AND column_name='date_prevue') THEN
    -- Forme 001
    ALTER TABLE public.relances RENAME COLUMN date_prevue  TO scheduled_for;
    ALTER TABLE public.relances RENAME COLUMN date_executee TO sent_at;
    ALTER TABLE public.relances RENAME COLUMN contenu      TO content;
    ALTER TABLE public.relances RENAME COLUMN statut       TO status;
    ALTER TABLE public.relances DROP CONSTRAINT IF EXISTS relances_type_relance_check;
    ALTER TABLE public.relances DROP CONSTRAINT IF EXISTS relances_statut_check;
    UPDATE public.relances SET type_relance = CASE type_relance
      WHEN 'rappel_documents'      THEN 'etape_financement'
      WHEN 'proposition_aide'      THEN 'inactif_j5'
      WHEN 'alerte_courtier_froid' THEN 'nudge_courtier_chaud'
      WHEN 'rappel_rdv'            THEN 'rdv_rappel_j1'
      WHEN 'post_visite'           THEN 'post_rdv_feedback'
      ELSE type_relance END;
    UPDATE public.relances SET status = CASE status
      WHEN 'planifiee' THEN 'pending'
      WHEN 'envoyee'   THEN 'sent'
      WHEN 'annulee'   THEN 'skipped'
      ELSE status END;
    ALTER TABLE public.relances
      ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
      ADD COLUMN IF NOT EXISTS skipped_at  TIMESTAMPTZ,
      ADD COLUMN IF NOT EXISTS deleted_at  TIMESTAMPTZ;

  ELSIF EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema='public' AND table_name='relances' AND column_name='type_relance')
    AND EXISTS (SELECT 1 FROM information_schema.columns
                WHERE table_schema='public' AND table_name='relances' AND column_name='scheduled_for') THEN
    NULL;  -- deja converge (re-execution du fichier)

  ELSE
    RAISE EXCEPTION 'relances: forme de schema inconnue (ni step ni date_prevue) — verifier la chaine de migrations';
  END IF;
END$$;

-- Extensions communes
ALTER TABLE public.relances ALTER COLUMN prospect_id DROP NOT NULL;  -- T11 briefing sans prospect
ALTER TABLE public.relances ALTER COLUMN scheduled_for SET DEFAULT now();
ALTER TABLE public.relances ALTER COLUMN status SET DEFAULT 'pending';  -- forme 001 gardait 'planifiee'

-- Parite 008 : ON DELETE RESTRICT (tracabilite OACIQ — pas de purge en cascade)
ALTER TABLE public.relances DROP CONSTRAINT IF EXISTS relances_prospect_id_fkey;
ALTER TABLE public.relances ADD CONSTRAINT relances_prospect_id_fkey
  FOREIGN KEY (prospect_id) REFERENCES public.prospects(id) ON DELETE RESTRICT;

-- Index mort herite de 001 (predicat 'planifiee' ne matche plus apres remap)
DROP INDEX IF EXISTS public.idx_relances_date_prevue;

ALTER TABLE public.relances
  ADD COLUMN IF NOT EXISTS courtier_id    UUID REFERENCES public.courtiers(id),
  ADD COLUMN IF NOT EXISTS rendez_vous_id UUID REFERENCES public.rendez_vous(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS canal          TEXT NOT NULL DEFAULT 'sms'
                                          CHECK (canal IN ('sms','email','push')),
  ADD COLUMN IF NOT EXISTS langue         TEXT NOT NULL DEFAULT 'fr-CA',
  ADD COLUMN IF NOT EXISTS template_id    UUID REFERENCES public.relance_templates(id),
  ADD COLUMN IF NOT EXISTS twilio_sid     TEXT,
  ADD COLUMN IF NOT EXISTS error_detail   TEXT,
  ADD COLUMN IF NOT EXISTS approved_by    UUID,
  ADD COLUMN IF NOT EXISTS updated_at     TIMESTAMPTZ NOT NULL DEFAULT now();

-- Backfill courtier_id (necessaire aux policies RLS et au dedup briefing)
UPDATE public.relances r
SET courtier_id = p.courtier_id
FROM public.prospects p
WHERE p.id = r.prospect_id AND r.courtier_id IS NULL;

-- Coherence avant pose des contraintes (created_at de 001 est nullable)
UPDATE public.relances SET sent_at = COALESCE(sent_at, created_at, now()) WHERE status = 'sent';

ALTER TABLE public.relances
  DROP CONSTRAINT IF EXISTS relances_type_relance_check,
  DROP CONSTRAINT IF EXISTS relances_status_check,
  DROP CONSTRAINT IF EXISTS relances_sent_has_timestamp;
ALTER TABLE public.relances
  ADD CONSTRAINT relances_type_relance_check CHECK (type_relance IN (
    'inactif_j2','inactif_j5',
    'nudge_courtier_chaud','nudge_courtier_urgent',
    'rdv_rappel_j1','rdv_rappel_j7','post_rdv_feedback',
    'etape_financement','reactivation_longterme','anniversaire',
    'briefing_quotidien'
  )),
  ADD CONSTRAINT relances_status_check CHECK (status IN (
    'pending','awaiting_approval','sent','skipped','stopped','failed'
  )),
  -- G6/G11/G13 filtrent sur sent_at : il DOIT etre pose au passage a 'sent'
  ADD CONSTRAINT relances_sent_has_timestamp CHECK (status <> 'sent' OR sent_at IS NOT NULL);

-- Idempotence : une seule relance envoyee par (rdv, type)
CREATE UNIQUE INDEX IF NOT EXISTS uq_relances_rdv_type
  ON public.relances (rendez_vous_id, type_relance)
  WHERE status = 'sent' AND rendez_vous_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_relances_prospect_type
  ON public.relances (prospect_id, type_relance, status, created_at DESC);

-- Vue compat iOS : expose `step` (ancien nom) + infos prospect
CREATE OR REPLACE VIEW public.relances_enriched
WITH (security_invoker = on) AS
SELECT
  r.id, r.prospect_id, r.courtier_id, r.rendez_vous_id,
  r.type_relance,
  CASE r.type_relance
    WHEN 'inactif_j2' THEN 'j2'
    WHEN 'inactif_j5' THEN 'j5'
    WHEN 'reactivation_longterme' THEN 'j10'
  END AS step,
  r.status, r.scheduled_for, r.content, r.canal, r.langue,
  r.approved_at, r.skipped_at, r.sent_at, r.created_at,
  p.nom AS prospect_name,
  p.score_chaleur AS prospect_score
FROM public.relances r
LEFT JOIN public.prospects p ON p.id = r.prospect_id
WHERE r.deleted_at IS NULL AND (p.id IS NULL OR p.deleted_at IS NULL);

-- ----------------------------------------------------------------------------
-- 8. relances_blocked_log — journal des BLOCK / DEFER (audit + tuning)
--    Le scheduler ne journalise qu'une fois par (prospect, type, garde, jour)
--    pour eviter le spam toutes les 15 min — voir spec §7.1 nœud 5a.
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.relances_blocked_log (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id  UUID REFERENCES public.prospects(id) ON DELETE SET NULL,
  courtier_id  UUID REFERENCES public.courtiers(id),
  type_relance TEXT NOT NULL,
  garde        TEXT NOT NULL,                    -- G0..G13
  action       TEXT NOT NULL CHECK (action IN ('BLOCK','DEFER')),
  reason       TEXT NOT NULL,
  retry_at     TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_blocked_log_created ON public.relances_blocked_log (created_at DESC);

-- ----------------------------------------------------------------------------
-- 9. updated_at — reutilise public.handle_updated_at() definie en 001
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS set_updated_at_relances ON public.relances;
CREATE TRIGGER set_updated_at_relances
  BEFORE UPDATE ON public.relances FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_relance_templates ON public.relance_templates;
CREATE TRIGGER set_updated_at_relance_templates
  BEFORE UPDATE ON public.relance_templates FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_rendez_vous ON public.rendez_vous;
CREATE TRIGGER set_updated_at_rendez_vous
  BEFORE UPDATE ON public.rendez_vous FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ----------------------------------------------------------------------------
-- 10. relance_next_slot — prochain creneau d'envoi legal (heure locale prospect)
--     Regles : 8h-20h; avant 8h -> meme jour 9h; apres 20h -> lendemain 9h;
--     jamais dimanche; lundi pas avant 11h; vendredi pas apres 16h (-> samedi
--     10h); samedi 10h-18h; feries QC -> jour suivant.
--     NE S'APPLIQUE PAS aux rappels RDV (transactionnels) — voir D21.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.relance_next_slot(p_tz TEXT, p_from TIMESTAMPTZ DEFAULT now())
RETURNS TIMESTAMPTZ
LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_local  TIMESTAMP;          -- horloge locale prospect
  v_feries JSONB;
  v_cfg    JSONB;
  v_guard  INT := 0;
BEGIN
  SELECT valeur INTO v_feries FROM public.relance_config WHERE cle = 'jours_feries_qc';
  SELECT valeur INTO v_cfg    FROM public.relance_config WHERE cle = 'fenetre_prospect';
  IF v_cfg IS NULL THEN
    RAISE EXCEPTION 'relance_config.fenetre_prospect manquante';
  END IF;
  v_feries := COALESCE(v_feries, '[]'::jsonb);
  v_local  := p_from AT TIME ZONE p_tz;

  LOOP
    v_guard := v_guard + 1;
    IF v_guard > 30 THEN
      RAISE EXCEPTION 'relance_next_slot: aucun creneau sous 30 jours';
    END IF;

    -- avant 8h -> meme jour 9h ; apres 20h -> lendemain 9h
    IF EXTRACT(HOUR FROM v_local) < (v_cfg->>'debut')::int THEN
      v_local := date_trunc('day', v_local) + make_interval(hours => (v_cfg->>'defer_heure')::int);
    ELSIF EXTRACT(HOUR FROM v_local) >= (v_cfg->>'fin')::int THEN
      v_local := date_trunc('day', v_local) + interval '1 day'
                 + make_interval(hours => (v_cfg->>'defer_heure')::int);
    END IF;

    -- ferie QC -> jour suivant 9h
    IF v_feries ? to_char(v_local, 'YYYY-MM-DD') THEN
      v_local := date_trunc('day', v_local) + interval '1 day'
                 + make_interval(hours => (v_cfg->>'defer_heure')::int);
      CONTINUE;
    END IF;

    -- dimanche bloque -> lundi 9h (la regle lundi 11h s'applique a l'iteration suivante)
    IF (v_cfg->>'dimanche_bloque')::boolean AND EXTRACT(ISODOW FROM v_local) = 7 THEN
      v_local := date_trunc('day', v_local) + interval '1 day'
                 + make_interval(hours => (v_cfg->>'defer_heure')::int);
      CONTINUE;
    END IF;

    -- lundi avant 11h -> lundi 11h
    IF EXTRACT(ISODOW FROM v_local) = 1
       AND EXTRACT(HOUR FROM v_local) < (v_cfg->>'lundi_debut')::int THEN
      v_local := date_trunc('day', v_local) + make_interval(hours => (v_cfg->>'lundi_debut')::int);
      CONTINUE;
    END IF;

    -- vendredi apres 16h -> samedi 10h
    IF EXTRACT(ISODOW FROM v_local) = 5
       AND EXTRACT(HOUR FROM v_local) >= (v_cfg->>'vendredi_fin')::int THEN
      v_local := date_trunc('day', v_local) + interval '1 day'
                 + make_interval(hours => (v_cfg->>'samedi_debut')::int);
      CONTINUE;
    END IF;

    -- samedi : fenetre reduite 10h-18h
    IF EXTRACT(ISODOW FROM v_local) = 6 THEN
      IF EXTRACT(HOUR FROM v_local) < (v_cfg->>'samedi_debut')::int THEN
        v_local := date_trunc('day', v_local) + make_interval(hours => (v_cfg->>'samedi_debut')::int);
        CONTINUE;
      ELSIF EXTRACT(HOUR FROM v_local) >= (v_cfg->>'samedi_fin')::int THEN
        v_local := date_trunc('day', v_local) + interval '1 day'
                   + make_interval(hours => (v_cfg->>'defer_heure')::int);
        CONTINUE;
      END IF;
    END IF;

    EXIT;  -- creneau valide
  END LOOP;

  RETURN v_local AT TIME ZONE p_tz;
END;
$$;

-- ----------------------------------------------------------------------------
-- 11. can_send_relance — garde-fous G0-G13, ordre strict, premiere regle gagne
--     Couvre : messages prospect (T1/T2/T6...) et nudges courtier (T4/T5).
--     NE couvre PAS le briefing T11 (pas de prospect) — gardes dans W2.
--     Retour : {"action":"SEND"|"BLOCK"|"DEFER","garde":"G4","reason":"...","retry_at":...}
--     LECTURE SEULE : le scheduler n8n journalise les BLOCK/DEFER.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.can_send_relance(
  p_prospect_id    UUID,
  p_type           TEXT,
  p_canal          TEXT DEFAULT 'sms',
  p_rendez_vous_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_prospect        public.prospects%ROWTYPE;
  v_courtier        public.courtiers%ROWTYPE;
  v_is_courtier_msg BOOLEAN := p_type IN ('nudge_courtier_chaud','nudge_courtier_urgent');
  v_is_rdv_msg      BOOLEAN := p_type IN ('rdv_rappel_j1','rdv_rappel_j7','post_rdv_feedback');
  v_cadence_h       INT;
  v_max_attempts    INT;
  v_sent_count      INT;
  v_last_sent       TIMESTAMPTZ;
  v_langue          TEXT;
  v_cfg             JSONB;
  v_month_cost      NUMERIC;
  v_next            TIMESTAMPTZ;
BEGIN
  -- G0 : kill switch global (fail-closed : config absente = bloque)
  IF NOT COALESCE((SELECT (valeur)::boolean FROM public.relance_config
                   WHERE cle = 'relance_active'), false) THEN
    RETURN jsonb_build_object('action','BLOCK','garde','G0','reason','relance_active=false');
  END IF;

  IF p_type = 'briefing_quotidien' THEN
    RETURN jsonb_build_object('action','BLOCK','garde','G0',
      'reason','briefing gere par W2, pas par can_send_relance');
  END IF;

  SELECT * INTO v_prospect FROM public.prospects WHERE id = p_prospect_id;
  IF NOT FOUND OR v_prospect.deleted_at IS NOT NULL THEN
    RETURN jsonb_build_object('action','BLOCK','garde','G0','reason','prospect_introuvable_ou_supprime');
  END IF;
  SELECT * INTO v_courtier FROM public.courtiers WHERE id = v_prospect.courtier_id;

  IF NOT v_is_courtier_msg THEN
    -- G1 : opt-out actif (sms_optout — store unique, permanent)
    IF EXISTS (SELECT 1 FROM public.sms_optout WHERE telephone = v_prospect.telephone) THEN
      RETURN jsonb_build_object('action','BLOCK','garde','G1','reason','sms_optout');
    END IF;

    -- G2 : opt-out sur la fiche prospect (defense en profondeur, leve par START)
    IF v_prospect.opted_out_at IS NOT NULL THEN
      RETURN jsonb_build_object('action','BLOCK','garde','G2','reason','opted_out');
    END IF;

    -- G3 : statut terminal
    IF v_prospect.statut IN ('perdu','conclu') AND p_type <> 'reactivation_longterme' THEN
      RETURN jsonb_build_object('action','BLOCK','garde','G3','reason','statut_'||v_prospect.statut);
    END IF;

    -- G4 : humain actif — le prospect a ecrit il y a moins de 24h
    --      (exemption : rappels lies a un RDV, qui doivent partir quand meme)
    IF NOT v_is_rdv_msg
       AND v_prospect.last_inbound_message_at IS NOT NULL
       AND v_prospect.last_inbound_message_at > now() - interval '24 hours' THEN
      RETURN jsonb_build_object('action','BLOCK','garde','G4','reason','human_active');
    END IF;
  END IF;

  -- G5 : pause (prospect ou courtier)
  IF (NOT v_is_courtier_msg AND v_prospect.pause_relances)
     OR COALESCE(v_courtier.pause_relances, false) THEN
    RETURN jsonb_build_object('action','BLOCK','garde','G5','reason','pause_relances');
  END IF;

  -- G6 : cadence minimale par type
  SELECT (valeur->>p_type)::int INTO v_cadence_h
  FROM public.relance_config WHERE cle = 'cadence_min_heures';
  SELECT MAX(sent_at) INTO v_last_sent
  FROM public.relances
  WHERE prospect_id = p_prospect_id AND type_relance = p_type AND status = 'sent';
  IF COALESCE(v_cadence_h, 0) > 0 AND v_last_sent IS NOT NULL
     AND v_last_sent > now() - make_interval(hours => v_cadence_h) THEN
    RETURN jsonb_build_object('action','BLOCK','garde','G6','reason','cadence_min');
  END IF;

  -- G7 : nombre max de tentatives (par RDV pour les types lies a un RDV;
  --      sinon comptees depuis le dernier message prospect — une reponse
  --      reinitialise la sequence)
  SELECT (valeur->>p_type)::int INTO v_max_attempts
  FROM public.relance_config WHERE cle = 'max_attempts';
  IF p_rendez_vous_id IS NOT NULL THEN
    SELECT count(*) INTO v_sent_count FROM public.relances
    WHERE rendez_vous_id = p_rendez_vous_id AND type_relance = p_type AND status = 'sent';
  ELSE
    SELECT count(*) INTO v_sent_count FROM public.relances
    WHERE prospect_id = p_prospect_id AND type_relance = p_type AND status = 'sent'
      AND created_at > COALESCE(v_prospect.last_inbound_message_at, '-infinity'::timestamptz);
  END IF;
  IF v_sent_count >= COALESCE(v_max_attempts, 1) THEN
    RETURN jsonb_build_object('action','BLOCK','garde','G7','reason','max_attempts');
  END IF;

  -- G8 / G9 : fenetre horaire + feries (DEFER avec retry_at calcule).
  -- D21 : les rappels RDV sont transactionnels — exempts de la fenetre
  -- prospect (leur creneau 17h-19h est impose par les candidats T6).
  -- Les feries ne s'appliquent qu'aux messages prospect (T4 courtier = 7j/7).
  IF v_is_courtier_msg THEN
    SELECT valeur INTO v_cfg FROM public.relance_config WHERE cle = 'fenetre_courtier';
    IF EXTRACT(HOUR FROM now() AT TIME ZONE COALESCE(v_courtier.timezone,'America/Montreal'))
         NOT BETWEEN (v_cfg->>'debut')::int AND (v_cfg->>'fin')::int - 1 THEN
      RETURN jsonb_build_object('action','DEFER','garde','G8','reason','fenetre_courtier',
        'retry_at', date_trunc('hour', now()) + interval '2 hours');
    END IF;
  ELSIF NOT v_is_rdv_msg THEN
    -- G9 d'abord : ferie QC aujourd'hui (heure locale prospect) -> label dedie
    IF COALESCE((SELECT valeur FROM public.relance_config WHERE cle='jours_feries_qc'),
                '[]'::jsonb)
       ? to_char(now() AT TIME ZONE v_prospect.timezone, 'YYYY-MM-DD') THEN
      RETURN jsonb_build_object('action','DEFER','garde','G9','reason','ferie_qc',
        'retry_at', public.relance_next_slot(v_prospect.timezone, now()));
    END IF;
    v_next := public.relance_next_slot(v_prospect.timezone, now());
    IF v_next > now() + interval '14 minutes' THEN  -- au-dela du run courant (cron 15 min)
      RETURN jsonb_build_object('action','DEFER','garde','G8','reason','hors_fenetre',
        'retry_at', v_next);
    END IF;
  END IF;

  -- G10 : template actif disponible (type, canal, langue)
  v_langue := CASE WHEN COALESCE(v_prospect.langue_preferee,'fr') = 'en'
                   THEN 'en-CA' ELSE 'fr-CA' END;
  IF v_is_courtier_msg THEN v_langue := 'fr-CA'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.relance_templates
                 WHERE type_relance = p_type AND canal = p_canal
                   AND langue = v_langue AND actif) THEN
    RETURN jsonb_build_object('action','BLOCK','garde','G10',
      'reason','template_manquant:'||p_type||'/'||p_canal||'/'||v_langue);
  END IF;

  -- G11 : budget Twilio mensuel
  SELECT valeur INTO v_cfg FROM public.relance_config WHERE cle = 'budget';
  SELECT count(*) * (v_cfg->>'cout_sms_cad')::numeric INTO v_month_cost
  FROM public.relances
  WHERE canal = 'sms' AND status = 'sent'
    AND sent_at >= date_trunc('month', now());
  IF v_month_cost >= (v_cfg->>'cap_cad')::numeric THEN
    RETURN jsonb_build_object('action','BLOCK','garde','G11','reason','budget_depasse');
  END IF;

  -- G12 : sender score degrade (stub MVP : flag manuel; absence de config = ok)
  IF NOT COALESCE((SELECT (valeur)::boolean FROM public.relance_config
                   WHERE cle = 'sender_score_ok'), true) THEN
    RETURN jsonb_build_object('action','DEFER','garde','G12','reason','sender_score',
      'retry_at', now() + interval '2 hours');
  END IF;

  -- G13 : anti-harcelement — max 2 relances tous types confondus / 48h (prospect)
  IF NOT v_is_courtier_msg THEN
    SELECT valeur INTO v_cfg FROM public.relance_config WHERE cle = 'anti_harcelement';
    SELECT count(*) INTO v_sent_count FROM public.relances
    WHERE prospect_id = p_prospect_id AND status = 'sent'
      AND type_relance NOT IN ('nudge_courtier_chaud','nudge_courtier_urgent','briefing_quotidien')
      AND sent_at > now() - make_interval(hours => (v_cfg->>'fenetre_heures')::int);
    IF v_sent_count >= (v_cfg->>'max_relances')::int THEN
      RETURN jsonb_build_object('action','BLOCK','garde','G13','reason','anti_harcelement');
    END IF;
  END IF;

  RETURN jsonb_build_object('action','SEND','garde',NULL,'reason','ok');
END;
$$;

-- ----------------------------------------------------------------------------
-- 12. get_relance_candidates — candidats HYDRATES par trigger (T1, T2, T4, T6)
--     STATELESS : recalcule a chaque run du cron. Garde-fous appliques ensuite
--     candidat par candidat via can_send_relance(). Toutes les donnees dont le
--     scheduler a besoin (rendu template, destinataire, approbation) sont la.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.get_relance_candidates()
RETURNS TABLE (
  prospect_id        UUID,
  courtier_id        UUID,
  rendez_vous_id     UUID,
  type_relance       TEXT,
  canal              TEXT,
  destinataire_tel   TEXT,    -- prospect (T1/T2/T6) ou courtier (T4)
  langue             TEXT,
  prospect_prenom    TEXT,
  prospect_nom       TEXT,
  prospect_tel       TEXT,
  courtier_prenom    TEXT,
  courtier_nom       TEXT,
  courtier_tel       TEXT,
  mode_approbation   BOOLEAN,
  prospect_timezone  TEXT,
  score_chaleur      INT,
  heures_sans_action INT,     -- T4 uniquement, sinon NULL
  rdv_heure          TEXT,    -- T6 uniquement (ex. '18h' / '18h30', heure locale prospect)
  rdv_lieu           TEXT
)
LANGUAGE sql STABLE AS $$
  WITH base AS (
    SELECT p.*, c.prenom AS c_prenom, c.nom AS c_nom, c.telephone AS c_tel,
           c.mode_approbation_relances AS c_approb
    FROM public.prospects p
    JOIN public.courtiers c ON c.id = p.courtier_id
    WHERE p.deleted_at IS NULL
  )

  -- T1 inactif_j2 : conversation abandonnee depuis >= 48h (pre-qualification).
  -- Borne basse 7 jours : un prospect plus ancien (ou backfille) ne part jamais
  -- en relance automatique sans decision explicite.
  SELECT b.id, b.courtier_id, NULL::uuid, 'inactif_j2', 'sms',
         b.telephone,
         CASE WHEN b.langue_preferee = 'en' THEN 'en-CA' ELSE 'fr-CA' END,
         b.prenom, b.nom, b.telephone,
         b.c_prenom, b.c_nom, b.c_tel, b.c_approb, b.timezone, b.score_chaleur,
         NULL::int, NULL::text, NULL::text
  FROM base b
  WHERE b.statut IN ('nouveau','en_qualification')
    AND b.last_inbound_message_at <= now() - interval '48 hours'
    AND b.last_inbound_message_at >  now() - interval '7 days'
    AND NOT EXISTS (
      SELECT 1 FROM public.relances r
      WHERE r.prospect_id = b.id AND r.type_relance = 'inactif_j2'
        -- skipped + skipped_at = refus courtier : ne jamais reproposer
        AND (r.status IN ('sent','awaiting_approval','pending')
             OR (r.status = 'skipped' AND r.skipped_at IS NOT NULL))
        AND r.created_at > b.last_inbound_message_at)

  UNION ALL

  -- T2 inactif_j5 : J+5 apres dernier message, T1 envoyee et restee sans reponse
  SELECT b.id, b.courtier_id, NULL::uuid, 'inactif_j5', 'sms',
         b.telephone,
         CASE WHEN b.langue_preferee = 'en' THEN 'en-CA' ELSE 'fr-CA' END,
         b.prenom, b.nom, b.telephone,
         b.c_prenom, b.c_nom, b.c_tel, b.c_approb, b.timezone, b.score_chaleur,
         NULL::int, NULL::text, NULL::text
  FROM base b
  WHERE b.statut IN ('nouveau','en_qualification')
    AND b.last_inbound_message_at <= now() - interval '120 hours'
    AND b.last_inbound_message_at >  now() - interval '14 days'
    AND EXISTS (
      SELECT 1 FROM public.relances r
      WHERE r.prospect_id = b.id AND r.type_relance = 'inactif_j2'
        AND r.status = 'sent' AND r.created_at > b.last_inbound_message_at)
    AND NOT EXISTS (
      SELECT 1 FROM public.relances r
      WHERE r.prospect_id = b.id AND r.type_relance = 'inactif_j5'
        AND (r.status IN ('sent','awaiting_approval','pending')
             OR (r.status = 'skipped' AND r.skipped_at IS NOT NULL))
        AND r.created_at > b.last_inbound_message_at)

  UNION ALL

  -- T4 nudge_courtier_chaud : lead chaud (score >= 7) qualifie, sans action
  -- courtier depuis 24h, aucun RDV cree. Proxy MVP de l'action courtier :
  -- last_courtier_action_at, sinon updated_at (moment de la qualification).
  SELECT b.id, b.courtier_id, NULL::uuid, 'nudge_courtier_chaud', 'sms',
         b.c_tel,
         'fr-CA',
         b.prenom, b.nom, b.telephone,
         b.c_prenom, b.c_nom, b.c_tel, false, b.timezone, b.score_chaleur,
         FLOOR(EXTRACT(EPOCH FROM (now() - COALESCE(b.last_courtier_action_at, b.updated_at))) / 3600)::int,
         NULL::text, NULL::text
  FROM base b
  WHERE b.statut = 'qualifie'
    AND b.score_chaleur >= 7
    AND COALESCE(b.last_courtier_action_at, b.updated_at) <= now() - interval '24 hours'
    AND NOT EXISTS (
      SELECT 1 FROM public.rendez_vous rv
      WHERE rv.prospect_id = b.id AND rv.statut IN ('propose','confirme'))

  UNION ALL

  -- T6 rdv_rappel_j1 : RDV confirme demain (heure locale prospect), envoye la
  -- veille dans la fenetre 17h-19h locale. Transactionnel : part 7j/7 (D21).
  SELECT b.id, b.courtier_id, rv.id, 'rdv_rappel_j1', 'sms',
         b.telephone,
         CASE WHEN b.langue_preferee = 'en' THEN 'en-CA' ELSE 'fr-CA' END,
         b.prenom, b.nom, b.telephone,
         b.c_prenom, b.c_nom, b.c_tel, b.c_approb, b.timezone, b.score_chaleur,
         NULL::int,
         to_char(rv.date_heure AT TIME ZONE b.timezone, 'FMHH24h') ||
           CASE WHEN to_char(rv.date_heure AT TIME ZONE b.timezone,'MI') <> '00'
                THEN to_char(rv.date_heure AT TIME ZONE b.timezone,'MI') ELSE '' END,
         rv.lieu
  FROM public.rendez_vous rv
  JOIN base b ON b.id = rv.prospect_id
  WHERE rv.statut = 'confirme'
    AND (rv.date_heure AT TIME ZONE b.timezone)::date
        = (now() AT TIME ZONE b.timezone)::date + 1
    AND EXTRACT(HOUR FROM now() AT TIME ZONE b.timezone) BETWEEN 17 AND 18
    AND NOT EXISTS (
      SELECT 1 FROM public.relances r
      WHERE r.rendez_vous_id = rv.id AND r.type_relance = 'rdv_rappel_j1'
        AND r.status = 'sent');
$$;

-- ----------------------------------------------------------------------------
-- 13. acquire_relance_lock — verrou applicatif anti-double-envoi
--     Retourne TOUJOURS true/false (jamais NULL). Expire apres 5 min.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.acquire_relance_lock(p_prospect_id UUID)
RETURNS BOOLEAN
LANGUAGE sql VOLATILE AS $$
  WITH upd AS (
    UPDATE public.prospects
    SET relances_lock_until = now() + interval '5 minutes'
    WHERE id = p_prospect_id
      AND (relances_lock_until IS NULL OR relances_lock_until < now())
    RETURNING 1
  )
  SELECT count(*) > 0 FROM upd;
$$;

-- ----------------------------------------------------------------------------
-- 14. Seed templates — FR-CA, GSM-7 strict (sans accents).
--     Budget longueur : corps + prenom prospect (15 ch) + prenom courtier
--     (10 ch) <= 160. CASL : mecanisme de desabonnement DANS CHAQUE message
--     commercial -> mention STOP inline dans T1/T2 (pas d'append dynamique).
--     T6 = transactionnel (rappel d'un RDV demande), sans mention STOP — a
--     valider juridiquement (spec §9).
--     Source copy : docs/templates-sms-figma-extraits.md, adaptee (Q2 Joanel).
-- ----------------------------------------------------------------------------
INSERT INTO public.relance_templates (type_relance, canal, langue, variante, corps) VALUES
  -- T1 — variante generique (a valider Joanel, Q2)
  ('inactif_j2','sms','fr-CA','defaut',
   'Bonjour {{prospect_prenom}}! C''est l''assistante de {{courtier_prenom}}. Votre dossier est presque complet, on continue? Repondez STOP pour arreter.'),
  -- T1 — variante contextuelle documents (reservee a etape_financement P2;
  -- non selectionnee au MVP faute de flag fiable — spec D2)
  ('inactif_j2','sms','fr-CA','documents',
   'Bonjour {{prospect_prenom}}! C''est l''assistante de {{courtier_prenom}}. On attend vos documents pour la pre-qualification. Besoin d''aide? Txt STOP=arret.'),
  -- T2 — derniere relance douce (a valider Joanel, Q2)
  ('inactif_j5','sms','fr-CA','defaut',
   'Bonjour {{prospect_prenom}}! C''est l''assistante de {{courtier_prenom}}. Toujours dans vos projets immo? Repondez-moi et on continue. STOP pour arreter.'),
  -- T6 — rappel RDV J-1 (transactionnel, sans STOP ni confirmation OUI/NON)
  ('rdv_rappel_j1','sms','fr-CA','defaut',
   'Bonjour {{prospect_prenom}}! Petit rappel : votre rencontre avec {{courtier_prenom}} est demain a {{rdv_heure}}. A demain!'),
  -- T4 — nudge courtier (la marque Klaris est visible cote courtier seulement)
  ('nudge_courtier_chaud','sms','fr-CA','defaut',
   'KLARIS : {{prospect_prenom}} {{prospect_nom}} (score {{score_chaleur}}/10) attend depuis {{heures_sans_action}}h. Tel : {{prospect_tel}}'),
  -- T11 — briefing courtier : email (corps assemble par W2) + variante SMS compacte
  ('briefing_quotidien','email','fr-CA','defaut',
   'BONJOUR {{courtier_prenom}}!{{br}}AUJOURD''HUI :{{rdv_du_jour}}{{br}}EN ATTENTE :{{en_attente}}{{br}}ALERTES : {{alertes}}{{br}}NOUVEAUX : {{nb_nouveaux}}'),
  ('briefing_quotidien','sms','fr-CA','defaut',
   'KLARIS {{date_locale}} : {{nb_rdv}} RDV, {{nb_attente}} en attente, {{nb_alertes}} alertes, {{nb_nouveaux}} nouveaux.'),
  -- Systeme — accuses legaux, utilises par l'intake (W3), jamais par le scheduler
  ('systeme','sms','fr-CA','stop_ack',
   'Vous etes desinscrit des messages de l''assistante de {{courtier_prenom}}. Pour revenir, repondez START.'),
  ('systeme','sms','fr-CA','help',
   'Assistante de {{courtier_nom_complet}}, courtier immobilier. Contact : {{courtier_tel}}. Repondez STOP pour vous desinscrire.')
ON CONFLICT (type_relance, canal, langue, variante) DO NOTHING;

-- ----------------------------------------------------------------------------
-- 15. RLS — aligne sur la posture 009 (anon = rien; courtier authentifie =
--     lecture/approbation de SES donnees; ecritures runtime = service_role,
--     qui bypasse RLS)
-- ----------------------------------------------------------------------------
-- ENABLE sans FORCE : aucune policy = deny par defaut pour anon/authenticated,
-- mais le role admin proprietaire garde l'acces (re-execution du fichier,
-- tuning de relance_config). service_role bypasse RLS dans tous les cas.
ALTER TABLE public.relance_config       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consentements        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.relance_templates    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rendez_vous          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.relances_blocked_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sms_optout           ENABLE ROW LEVEL SECURITY;  -- no-op si 008
-- relances : RLS deja active (001 ou 008)

REVOKE ALL ON public.relance_config, public.consentements, public.relance_templates,
              public.rendez_vous, public.relances_blocked_log, public.sms_optout
  FROM anon;

-- La vue est recreee APRES le revoke global de 009 : revoke explicite requis
-- (posture post-incident 2026-06-09 : anon n'a acces a RIEN)
REVOKE ALL ON public.relances_enriched FROM anon;
GRANT SELECT ON public.relances_enriched TO authenticated;

-- Pas d'oracle d'opt-out ni d'appel de fonctions metier pour anon
REVOKE EXECUTE ON FUNCTION public.is_phone_optout(text) FROM anon;
REVOKE EXECUTE ON FUNCTION public.can_send_relance(uuid,text,text,uuid) FROM anon;
REVOKE EXECUTE ON FUNCTION public.get_relance_candidates() FROM anon;
REVOKE EXECUTE ON FUNCTION public.acquire_relance_lock(uuid) FROM anon;
REVOKE EXECUTE ON FUNCTION public.relance_next_slot(text,timestamptz) FROM anon;

-- Relances : policies robustes aux lignes anciennes (courtier_id backfille) et
-- aux lignes briefing (prospect_id NULL). Remplacent les policies 002/008/009.
DROP POLICY IF EXISTS "broker reads own prospects' relances" ON public.relances;
DROP POLICY IF EXISTS "broker approves/skips relances" ON public.relances;
DROP POLICY IF EXISTS relances_select_own ON public.relances;
CREATE POLICY relances_select_own ON public.relances
  FOR SELECT TO authenticated
  USING (
    courtier_id = auth.uid()
    OR prospect_id IN (SELECT id FROM public.prospects WHERE courtier_id = auth.uid())
  );

-- Approbation (D6) : approuver = status 'pending' + approved_at pose;
-- refuser = 'skipped'. La propriete est re-affirmee dans le WITH CHECK
-- (pas de reassignation de ligne possible).
DROP POLICY IF EXISTS relances_approve_own ON public.relances;
CREATE POLICY relances_approve_own ON public.relances
  FOR UPDATE TO authenticated
  USING (courtier_id = auth.uid() AND status = 'awaiting_approval')
  WITH CHECK (
    courtier_id = auth.uid()
    AND ((status = 'pending' AND approved_at IS NOT NULL) OR status = 'skipped')
  );

-- Limite l'UPDATE des courtiers aux colonnes d'approbation
REVOKE UPDATE ON public.relances FROM authenticated;
GRANT  UPDATE (status, approved_at, approved_by, skipped_at)
  ON public.relances TO authenticated;

DROP POLICY IF EXISTS rendez_vous_select_own ON public.rendez_vous;
CREATE POLICY rendez_vous_select_own ON public.rendez_vous
  FOR SELECT TO authenticated
  USING (courtier_id = auth.uid());

DROP POLICY IF EXISTS templates_select_auth ON public.relance_templates;
CREATE POLICY templates_select_auth ON public.relance_templates
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS blocked_log_select_own ON public.relances_blocked_log;
CREATE POLICY blocked_log_select_own ON public.relances_blocked_log
  FOR SELECT TO authenticated
  USING (courtier_id = auth.uid());

-- sms_optout : conserve la policy de lecture 008 si presente; sinon lecture
-- authentifiee (verification anti-CASL cote dashboard)
DROP POLICY IF EXISTS "authenticated reads optout" ON public.sms_optout;
CREATE POLICY "authenticated reads optout" ON public.sms_optout
  FOR SELECT TO authenticated
  USING (true);

-- consentements, relance_config : service_role uniquement (aucune policy)

COMMIT;

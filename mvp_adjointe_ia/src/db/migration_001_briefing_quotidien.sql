-- Migration 001 — Support du briefing quotidien (T11)
-- Référence : docs/relances/relances-decision-matrix.md § T11
-- Auteur : Dennis · 2026-04-28

BEGIN;

-- 1. Colonne timezone sur courtiers (défaut America/Toronto pour le pilote QC)
ALTER TABLE courtiers
  ADD COLUMN IF NOT EXISTS timezone TEXT NOT NULL DEFAULT 'America/Toronto';

-- 2. Table dédiée pour la traçabilité des briefings
--    Isolation vs `relances` (pas un contact prospect mais une notif courtier).
CREATE TABLE IF NOT EXISTS briefings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  courtier_id     UUID NOT NULL REFERENCES courtiers(id) ON DELETE CASCADE,
  date_locale     DATE NOT NULL,
  sent_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  canal_email     BOOLEAN NOT NULL DEFAULT FALSE,
  canal_sms       BOOLEAN NOT NULL DEFAULT FALSE,
  stats           JSONB NOT NULL DEFAULT '{}'::jsonb,
  CONSTRAINT briefings_unique_par_jour UNIQUE (courtier_id, date_locale)
);

CREATE INDEX IF NOT EXISTS idx_briefings_courtier_date
  ON briefings(courtier_id, date_locale DESC);

-- 3. RLS
ALTER TABLE briefings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS briefings_courtier_select ON briefings;
CREATE POLICY briefings_courtier_select ON briefings
  FOR SELECT
  TO authenticated
  USING (courtier_id = auth.uid());

-- service_role bypass RLS automatiquement (n8n)

COMMIT;

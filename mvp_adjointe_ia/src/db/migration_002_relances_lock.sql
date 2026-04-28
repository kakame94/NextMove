-- Migration 002 — Lock applicatif pour le scheduler de relances
-- Référence : docs/relances/relances-decision-matrix.md § 6bis (Idempotence)
-- Auteur : Dennis · 2026-04-28

-- Colonne lock applicatif
-- NULL = libre. Si > NOW() : pris par un cron en cours.
-- Auto-expiration après 5 min en cas de crash.
ALTER TABLE prospects
  ADD COLUMN IF NOT EXISTS relances_lock_until TIMESTAMPTZ NULL;

CREATE INDEX IF NOT EXISTS idx_prospects_lock_until
  ON prospects(relances_lock_until)
  WHERE relances_lock_until IS NOT NULL;

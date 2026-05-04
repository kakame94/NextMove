-- Migration 003 — conversations comme source unique des échanges
-- Préparation pour la feature voix Telegram (Phase 1) : ajout courtier_id +
-- index timeline + documentation des valeurs canoniques de role.
-- Auteur : Dennis · 2026-04-29

ALTER TABLE conversations
  ADD COLUMN IF NOT EXISTS courtier_id uuid REFERENCES courtiers(id);

-- Timeline d'un prospect (ordre antichronologique : le plus récent d'abord)
CREATE INDEX IF NOT EXISTS idx_conversations_prospect_timeline
  ON conversations (prospect_id, created_at DESC);

-- Lookup des conversations par courtier (RBAC du futur bot voix)
CREATE INDEX IF NOT EXISTS idx_conversations_courtier
  ON conversations (courtier_id);

COMMENT ON COLUMN conversations.role IS
  'Valeurs canoniques: prospect (message du prospect) | courtier (message envoyé manuellement par le courtier humain) | assistant (message auto de l''agent IA) | courtier_note (note interne, voix ou texte)';

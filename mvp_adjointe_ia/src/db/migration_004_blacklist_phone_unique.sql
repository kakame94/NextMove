-- Migration 004 — Contrainte UNIQUE sur blacklist.phone
-- Bug observé exec 27057 (2026-05-04 19:07 UTC) : Insert Blacklist plante avec
-- "no unique or exclusion constraint matching the ON CONFLICT specification"
-- car la query du workflow intake utilise ON CONFLICT (phone) DO NOTHING.
-- Conséquence : impossible d'enregistrer un STOP, puis l'agent ré-essaie de
-- répondre au numéro désabonné (Twilio 21610).
-- Auteur : Dennis · 2026-05-06

ALTER TABLE blacklist
  ADD CONSTRAINT blacklist_phone_unique UNIQUE (phone);

-- Note : phone reste nullable (cas où un email est blacklisté sans téléphone).
-- Postgres autorise plusieurs lignes avec phone=NULL malgré la contrainte UNIQUE.

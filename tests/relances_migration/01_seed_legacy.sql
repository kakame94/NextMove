-- Donnees mimant la prod legacy (introspection Dennis 2026-06) :
-- 1 courtier (0d99b83a-...), 14 prospects, historique relances legacy varie.
BEGIN;

INSERT INTO public.courtiers (id, nom, prenom, telephone, email)
VALUES ('0d99b83a-91db-42cd-a19b-2e88384c67a7', 'Marfo', 'Dennis', '+15145550000', 'dennis@example.com');

INSERT INTO public.prospects (id, courtier_id, canal_source, type_projet, statut, score_chaleur, nom, prenom, telephone, langue_preferee)
SELECT
  ('00000000-0000-0000-0000-0000000000' || lpad(i::text, 2, '0'))::uuid,
  '0d99b83a-91db-42cd-a19b-2e88384c67a7',
  'sms',
  CASE WHEN i % 2 = 0 THEN 'acheteur' ELSE 'vendeur' END,
  (ARRAY['nouveau','en_qualification','qualifie','en_recherche','conclu','perdu'])[1 + (i % 6)],
  i % 11,
  'Nom' || i, 'Prenom' || i,
  '+1514555' || lpad((1000 + i)::text, 4, '0'),
  CASE WHEN i % 5 = 0 THEN 'en' ELSE 'fr' END
FROM generate_series(1, 14) AS i;

-- Historique relances legacy : tous les anciens types + statuts,
-- y compris cas vicieux 'envoyee' sans date_executee (created_at nullable rempli ici)
INSERT INTO public.relances (prospect_id, type_relance, date_prevue, date_executee, statut, contenu)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'rappel_documents',      now() - interval '10 days', now() - interval '9 days', 'envoyee',  'legacy doc'),
  ('00000000-0000-0000-0000-000000000002', 'proposition_aide',      now() - interval '8 days',  NULL,                      'planifiee','legacy aide'),
  ('00000000-0000-0000-0000-000000000003', 'alerte_courtier_froid', now() - interval '7 days',  NULL,                      'annulee',  'legacy froid'),
  ('00000000-0000-0000-0000-000000000004', 'rappel_rdv',            now() - interval '2 days',  now() - interval '2 days', 'envoyee',  'legacy rdv'),
  ('00000000-0000-0000-0000-000000000005', 'post_visite',           now() - interval '1 day',   NULL,                      'planifiee','legacy visite');

-- Cas vicieux : envoyee sans date_executee (et created_at NULL — 001 le permet)
INSERT INTO public.relances (prospect_id, type_relance, date_prevue, date_executee, statut, contenu, created_at)
VALUES ('00000000-0000-0000-0000-000000000006', 'rappel_documents', now() - interval '3 days', NULL, 'envoyee', 'legacy sans ts', NULL);

INSERT INTO public.conversations (prospect_id, role, contenu, canal)
VALUES
  ('00000000-0000-0000-0000-000000000001', 'prospect', 'bonjour', 'sms'),
  ('00000000-0000-0000-0000-000000000001', 'agent',    'salut!',  'sms');

COMMIT;

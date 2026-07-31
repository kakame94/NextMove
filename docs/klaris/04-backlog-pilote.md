# Backlog pilote — Klaris documentaire

Découpage exécutable vers le pilote (6-8 semaines). Chaque tâche correspond à une issue GitHub (label `klaris-doc`). Ordre = dépendances réelles ; tout le chemin critique tient **sans** réponse de Lone Wolf ni de Centris.

## Semaine 1 — fondations (débloque tout le reste)

| # | Tâche | Qui | Sortie |
|---|---|---|---|
| 1 | Soumettre le formulaire partenaire Lone Wolf (lwolf.com/api-getting-started) | Eliot | Accusé de réception ; l'horloge externe démarre |
| 2 | Projet Supabase `ca-central-1` + exécuter `sql/000_klaris_documentaire_schema.sql` | Dennis | Schéma `klaris_doc` en place, RLS active |
| 3 | Taxonomie documentaire QC v1 (YAML) : types, champs à extraire, règles de péremption, obligatoires par type de dossier et par étape | Eliot + Dennis | `taxonomie/quebec_v1.yaml` |

## Semaines 2-3 — pipeline d'ingestion

| # | Tâche | Qui | Sortie |
|---|---|---|---|
| 4 | Domaine `in.klaris.ca` + Postmark inbound → Edge Function `ingestion` (signature, pièces jointes, SHA-256, Storage, ligne `documents`) | Dennis | Un courriel avec PDF crée un document `recu` |
| 5 | Worker classification : PDF natif + taxonomie → JSON structuré + confiance ; sous le seuil → `a_confirmer` ; journaliser `couts_inference` | Dennis | Documents classés, coûts tracés |
| 6 | Moteur de complétude : règles YAML → `manquants` / `perimes` par dossier (SQL/TS pur) | Dennis | Liste des manquants exacte sur le dossier de test |

## Semaines 3-4 — UI courtier + N3

| # | Tâche | Qui | Sortie |
|---|---|---|---|
| 7 | App courtier (Netlify) : liste dossiers, vue dossier (documents par type, manquants, périmés), file « à confirmer » | Dennis | Courtier voit l'état complet d'un dossier |
| 8 | Fiche prête à saisir (cas vendeur) : champs extraits copiables vers Matrix | Dennis | Fiche générée sur le dossier de test |
| 9 | Boucle N3 : UI approuver / modifier / refuser sur `actions_pendantes` + exécuteur (seul chemin de sortie) | Dennis | Aucune sortie sans clic d'approbation |

## Semaines 4-5 — portail client

| # | Tâche | Qui | Sortie |
|---|---|---|---|
| 10 | Portail lien signé : token 256 bits hashé, expiration 30 j, révocation ; téléversement client → même pipeline | Dennis | Client consulte et dépose sans compte |
| 11 | Journal d'accès branché partout (lectures portail, écritures système, refus) | Dennis | Chaque accès tracé |

## Semaines 5-6 — échéances + verrouillage

| # | Tâche | Qui | Sortie |
|---|---|---|---|
| 12 | Moteur d'échéances : jalons manuels + `pg_cron` J-7/J-3/J-1 → actions `relance` proposées | Dennis | Relances proposées, jamais envoyées seules |
| 13 | Tests bloquants CI (accès croisé, RLS, token expiré, journal append-only, dédoublonnage, N3) | Dennis | Pipeline rouge si un test échoue |
| 14 | Dossier de conformité Loi 25 (registre, durées de conservation, destruction) | Eliot | Prêt avant la première rencontre pilote |

## En parallèle, dès la réponse Lone Wolf

| # | Tâche | Qui | Sortie |
|---|---|---|---|
| 15 | OAuth code flow pré-prod + polling 30 min → upsert `jalons` source `api` + inventaire DocBox | Dennis | Jalons alimentés sans saisie |
| 16 | Dépôt DocBox comme action N3 | Dennis | Dépôt approuvé visible dans TransactionDesk |
| 17 | Lettre à Centris (notification + question fermée Direct Web API) — après réponse Lone Wolf | Eliot | Trace conservée |

## Critères de sortie du pilote (cadrage §7)

1. Heures sauvées par transaction (avant/après, chiffre du courtier)
2. Taux d'adoption client (% qui ouvrent le lien et reviennent 2+)
3. Exactitude de classification sans intervention
4. Coût infonuagique/IA par transaction (`couts_inference`)
5. Volonté de payer (« à 40 $/siège/mois, tu recommandes à ton agence ? »)

**Gate de mise en prod** : test d'accès croisé client A / client B → refus + journalisation. Non négociable.

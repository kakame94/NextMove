# Klaris — Assistant documentaire (module transaction)

Dossier de référence du module **assistant documentaire** de Klaris : collecte, classe, vérifie et orchestre les documents d'une transaction immobilière québécoise — sans jamais toucher aux données de Centris.

**Principe directeur : Klaris prépare, le courtier décide.** Aucune action sortante (dépôt DocBox, envoi client, relance) ne part sans approbation explicite du courtier (niveau d'autonomie N3).

## Navigation

| Document | Contenu | Pour qui |
|---|---|---|
| [01-cadrage-produit.md](01-cadrage-produit.md) | Vision, problème, cadre juridique (Centris, Loi 25, OACIQ), modèle d'affaires, pilote | Tous |
| [02-architecture-technique.md](02-architecture-technique.md) | Stack, composants, diagrammes, séquence de construction | Dev (Dennis) |
| [03-modele-donnees.md](03-modele-donnees.md) | Schéma Postgres, RLS, tests bloquants | Dev (Dennis) |
| [04-backlog-pilote.md](04-backlog-pilote.md) | Découpage en tâches, ordre, critères de sortie | Dev + PO |
| [sql/000_klaris_documentaire_schema.sql](sql/000_klaris_documentaire_schema.sql) | Migration initiale prête à exécuter | Dev |
| [diagrammes/](diagrammes/) | Sources SVG + PNG des diagrammes (deck investisseur) | Tous |

## TL;DR technique

- **Supabase `ca-central-1`** (Loi 25 : hébergement canadien) : Postgres + RLS + Storage + Edge Functions + `pg_cron`
- **Frontend Netlify** (app courtier + portail client) — aucun document ne transite par Netlify, tout sort du Storage via URL signée
- **Entrée universelle : le courriel** (`d-{id}@in.klaris.ca` via Postmark) — zéro dépendance externe, couvre 100 % du pilote
- **Canal API principal : Lone Wolf TransactionDesk** (OAuth par courtier, polling, DocBox) — formulaire partenaire soumis, jamais bloquant
- **Centris/Matrix : aucun lien** (DA-01). Trestle/Direct Web API = module optionnel (DA-06), jamais chemin critique
- **Test bloquant unique de mise en prod** : accès croisé client A → dossier client B = 403 + journalisation

## Décisions d'architecture (résumé)

| # | Décision |
|---|---|
| DA-01 | Aucune connexion Klaris ↔ Centris/Matrix |
| DA-02 | Autonomie N3 — approbation systématique du courtier |
| DA-03 | Lone Wolf TransactionDesk = canal API principal |
| DA-04 | Entrée courriel = mécanisme d'alimentation universel |
| DA-05 | Jalons structurés de l'API avant lecture PDF |
| DA-06 | Direct Web API (Cotality/Trestle) = module optionnel, jamais critique |
| DA-07 | Passe-plat minimal, conservation encadrée Loi 25 |

Justifications complètes : [01-cadrage-produit.md §9](01-cadrage-produit.md#9-décisions-darchitecture-consignées).

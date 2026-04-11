# NextMove Inc. — Adjointe IA du Courtier Immobilier

**Un agent conversationnel autonome qui remplace 80-90% des taches administratives d'un courtier immobilier solo au Quebec.**

L'Adjointe IA repond aux prospects par SMS en < 60 secondes, collecte leurs informations via une conversation guidee en francais quebecois naturel, genere une fiche client structuree, notifie le courtier, et declenche les relances automatiques — sans intervention humaine.

---

## Equipe

| Membre | Role |
|--------|------|
| **Eliot Alanmanou** | Produit / Architecte IA |
| **Walkens Charles** | Backend / Infra |
| **Seydou** | Integration / Flows |
| **Dennis Kodjo** | Produit / UX |

---

## Quick Start — Ou commencer ?

| Tu es... | Commence par... |
|----------|----------------|
| **Nouveau dans l'equipe** | Ce README + le [PRD](#prd--product-requirements-document) |
| **Developpeur** | La [Spec MVP technique](#spec-mvp-technique) + le [Schema DB](#schema-de-base-de-donnees) |
| **Architecte** | L'[Architecture de solution](#architecture-de-solution) + les [NFRs dans le PRD](#exigences-non-fonctionnelles) |
| **Analyste d'affaires** | Les [Personas](#personas) + les [Resultats d'atelier JTBD](#resultats-de-latelier-jtbd) |
| **Concepteur UX** | Le [Figma](#figma) + la [Spec UX](#ux-design-specification) |

---

## Le Probleme

Un courtier immobilier solo au Quebec perd **3 a 4 heures par jour** en taches admin — reponses clients, saisie de donnees, relances manuelles, suivi de dossiers. Chaque heure perdue, c'est un prospect qui refroidit et un deal qui glisse.

**3 courtiers interviews le confirment unanimement :**
- **Joanel** : "Si je veux faire 10 transactions/mois, ca va me tuer"
- **Maxime** : "Ce travail manuel — une a la fois — je suis limite"
- **Charlyse** : "Je prefere le faire moi-meme que de me fier a une automatisation qui ne marche pas"

## La Solution

| Dimension | Valeur |
|-----------|--------|
| **Type de produit** | SaaS B2B, AI-Agent-First |
| **Domaine** | Proptech QC — marche bilingue, reglemente OACIQ |
| **Stack** | Claude API (Sonnet 4.6) + n8n + Supabase + Twilio + SendGrid |
| **Cout operationnel** | ~35-50$/mois (vs 2 500-3 000$/mois pour une adjointe humaine) |
| **Hebergement** | Canada (ca-central-1) — conformite Loi 25 |

### Ce qui nous differencie

- **Agent-first, pas outil-first** — remplace une action humaine, pas un formulaire
- **Friction minimale** — setup initial guide une fois, puis zero intervention courtier
- **Ton quebecois authentique** — le prospect ne sait pas qu'il parle a une IA
- **Fiabilite observable** — le courtier voit chaque conversation, chaque fiche, chaque relance

---

## Structure du Projet

```
NextMove/
|
|-- README.md                          # Ce fichier
|
|-- _bmad-output/planning-artifacts/   # Livrables BMAD (product management)
|   |-- prd.md                         # PRD complet (32 FRs, 21 NFRs, 8 journeys)
|   |-- prd-validation-report.md       # Rapport de validation (PASSED)
|   |-- product-brief-*.md             # Product brief avec vision
|   |-- ux-design-specification.md     # Spec UX design
|
|-- atelier_resultats/                 # Resultats de l'atelier JTBD (recherche)
|   |-- 01_carte_empathie.md           # Carte d'empathie courtier
|   |-- 02_journee_type.md             # Journee type du courtier
|   |-- 03_matrice_douleurs_gains.md   # Matrice priorisee des douleurs
|   |-- 04_forces_progres_jtbd.md      # Forces de progres (push/pull/anxiete/habitude)
|   |-- 05_chemin_ideal_transaction.md # Parcours ideal d'une transaction
|   |-- 06_segmentation_automatisation.md # Quoi automatiser vs garder humain
|   |-- 07_confort_client_ia.md        # Confort des clients face a l'IA
|   |-- 08_arcs_narratifs_jtbd.md      # Scenarios narratifs de deals perdus/gagnes
|   |-- 09_baguette_magique_vision.md  # Vision ideale du courtier (baguette magique)
|   |-- 10_personas_courtiers.md       # 3 personas (Joanel, Maxime, Charlyse)
|   |-- 11_sprint_mvp_3jours.md        # Plan de sprint MVP (Ven-Sam-Dim)
|   |-- NDA_NextMove_Joanel_Dupart.docx # NDA pour identifiants Matrix du courtier pilote
|
|-- mvp_adjointe_ia/                   # Specification technique du MVP
|   |-- SPEC_MVP.md                    # Spec complete (flows, schema, prompts, metriques)
|   |-- GUIDE_DEPLOIEMENT.md           # Guide de deploiement
|   |-- config/env.example             # Variables d'environnement requises
|   |-- src/
|       |-- db/schema.sql              # Schema PostgreSQL (5 tables)
|       |-- flows/                     # Workflows n8n
|       |-- prompts/                   # Prompts systeme IA
|
|-- docs/                              # Documentation projet
|-- transcripts/                       # Transcriptions des interviews courtiers
|-- bpmn/                              # Diagrammes processus metier
|-- _bmad/                             # Framework BMAD (workflows product management)
```

---

## Documents Cles

### PRD — Product Requirements Document

**Fichier :** [`_bmad-output/planning-artifacts/prd.md`](_bmad-output/planning-artifacts/prd.md)

Le document le plus important du projet. Il contient :

| Section | Contenu |
|---------|---------|
| Executive Summary | Probleme, solution, differentiateurs, scope progressif (MVP → V1 publique) |
| Project Classification | SaaS B2B AI-Agent-First, Proptech QC, complexite medium |
| Success Criteria | Metriques user/business/tech avec cibles chiffrees |
| Product Scope | MVP (Sprint 1) → Growth (Sprint 2) → Vision (Sprint 3+) |
| User Journeys | 8 parcours narratifs (acheteur, vendeur, admin, stress test, erreur, spam...) |
| Domain Requirements | Loi 25, OACIQ, LPRPDE, CASL |
| Functional Requirements | 32 FRs en 10 capacites (24 MUST, 8 SHOULD) |
| Non-Functional Requirements | 21 NFRs (performance, fiabilite, securite, qualite IA, scalabilite) |
| Assumptions & Dependencies | 7 assumptions avec risques et mitigations |

**Validation :** [`prd-validation-report.md`](_bmad-output/planning-artifacts/prd-validation-report.md) — 11 findings corriges, statut **PASSED**.

### Personas

**Fichier :** [`atelier_resultats/10_personas_courtiers.md`](atelier_resultats/10_personas_courtiers.md)

3 lean personas issus d'interviews terrain :

| Persona | Archetype | JTBD principal | Pain #1 |
|---------|-----------|---------------|---------|
| **Joanel** — Le Solo Ambitieux | Courtier performant, plafonne par l'admin | Liberer le temps admin pour le terrain | L'admin mange le temps de vente |
| **Maxime** — Le Batisseur Structure | Niche plex, veut scaler avec systemes | Automatiser l'analyse pour scaler | Analyse manuelle une a la fois |
| **Charlyse** — La Perfectionniste Autonome | Ex-PhD, 100% references, ultra-exigeante | Un systeme fiable, une seule entree de donnees | Saisie redondante multi-systemes |

### Spec MVP Technique

**Fichier :** [`mvp_adjointe_ia/SPEC_MVP.md`](mvp_adjointe_ia/SPEC_MVP.md)

Contient les flux conversationnels detailles (acheteur 9 questions, vendeur 6 questions), le schema de base de donnees, la matrice de relances, les prompts systeme, et l'architecture technique.

### UX Design Specification

**Fichier :** [`_bmad-output/planning-artifacts/ux-design-specification.md`](_bmad-output/planning-artifacts/ux-design-specification.md)

Cadrage UX : l'interface est 95% SMS (conversation choreographiee) + 5% dashboard web (supervision).

---

## Resultats de l'Atelier JTBD

9 livrables de recherche issus d'interviews terrain avec les courtiers :

| # | Livrable | Ce qu'il revele |
|---|----------|----------------|
| 01 | [Carte d'empathie](atelier_resultats/01_carte_empathie.md) | Ce que le courtier dit, pense, fait, ressent |
| 02 | [Journee type](atelier_resultats/02_journee_type.md) | Routine quotidienne et moment de productivite |
| 03 | [Matrice douleurs/gains](atelier_resultats/03_matrice_douleurs_gains.md) | Priorisation : admin et visibilite hypothecaire = top douleurs |
| 04 | [Forces de progres](atelier_resultats/04_forces_progres_jtbd.md) | Push (insatisfaction) >> Pull (attraction) — forte motivation |
| 05 | [Chemin ideal transaction](atelier_resultats/05_chemin_ideal_transaction.md) | 80% du parcours est automatisable par l'IA |
| 06 | [Segmentation automatisation](atelier_resultats/06_segmentation_automatisation.md) | Quoi automatiser vs garder humain |
| 07 | [Confort client IA](atelier_resultats/07_confort_client_ia.md) | Les clients des courtiers face a l'IA |
| 08 | [Arcs narratifs](atelier_resultats/08_arcs_narratifs_jtbd.md) | Scenarios de deals perdus (financement, inspection) |
| 09 | [Baguette magique](atelier_resultats/09_baguette_magique_vision.md) | Vision ideale : offre generee en secondes, adjointe 24/7 |

---

## Architecture de Solution

```
SMS entrant (Twilio)
     |
     v
n8n (orchestration) ──> Claude API (Sonnet 4.6)
     |                        |
     |                   Prompt systeme
     |                   + historique conversation
     |                   + fiche client
     |                        |
     v                        v
Supabase (PostgreSQL)   Reponse SMS sortant (Twilio)
|-- clients             Notification courtier (SMS + SendGrid)
|-- conversations       Relances cron (n8n scheduler)
|-- relances            Briefing quotidien (n8n cron 7h30)
|-- rendez_vous
|-- config_courtier

Cout : ~35-50$/mois | Hebergement : Canada (ca-central-1)
```

### Schema de Base de Donnees

5 tables definies dans [`mvp_adjointe_ia/src/db/schema.sql`](mvp_adjointe_ia/src/db/schema.sql) :

| Table | Role | Champs cles |
|-------|------|-------------|
| `clients` | Fiches prospects | nom, telephone, type (acheteur/vendeur), budget, score_chaleur, statut |
| `conversations` | Historique messages | client_id, canal, direction, contenu, role_ia |
| `relances` | Matrice de relances | client_id, type (J+2, J+5, J-1...), statut, date_envoi |
| `rendez_vous` | Planification | client_id, date_heure, type_rdv, statut |
| `config_courtier` | Preferences courtier | nom, message_accueil, ton, horaires, partenaires |

### Exigences Non-Fonctionnelles

| Categorie | Cle |
|-----------|-----|
| **Performance** | SMS < 60s end-to-end (P95), Claude API < 15s |
| **Fiabilite** | 99.5%+ disponibilite SMS, retry 3x backoff, alerte courtier si down > 30min |
| **Securite** | Donnees ca-central-1, TLS 1.2+, AES-256, zero PII dans les logs |
| **Qualite IA** | Ton QC naturel, zero hallucination, extraction JSON > 95%, transfert 100% correct |
| **Scalabilite** | MVP: 1 courtier, 10 conv. paralleles → V1: 100+ courtiers, 1000+ conv. |

---

## Sprint MVP — 3 Jours

**Fichier :** [`atelier_resultats/11_sprint_mvp_3jours.md`](atelier_resultats/11_sprint_mvp_3jours.md)

| Jour | Focus | Livrable cle |
|------|-------|-------------|
| **Vendredi** | Aligner & Architecturer | Infra deployee, premier SMS → IA repond |
| **Samedi** | Construire le Coeur | Flux acheteur + vendeur, notifications, 10+ tests |
| **Dimanche** | Polir & Livrer | Relances, briefing, dashboard, **demo live a Joanel 17h** |

**Definition of Done :** Le courtier pilote a vu la demo et dit "je veux l'utiliser".

---

## Figma

**Fichier :** [JXlxEfExXxH1sVpXFnwFKH](https://www.figma.com/design/JXlxEfExXxH1sVpXFnwFKH)

8 pages :

| Page | Contenu |
|------|---------|
| Personas Courtiers | 3 cartes personas + patterns communs |
| Sprint MVP — 3 Jours | Progress Design Thinking, roles, scope, 3 day cards, DoD, metriques |
| Architecture de Solution | 8 composants, 10 flux, securite, couts |
| UX Design System | Couleurs, typo, spacing, composants, badges, bulles SMS |
| Wireframes SMS | 5 mockups iPhone (acheteur, vendeur, transfert, relances, briefing) |
| Wireframes Dashboard | Sidebar, stats, table prospects, relances, conversation preview |
| User Journeys | 7 flow diagrams avec emotions et acteurs |

---

## Conformite et Legal

| Reglementation | Couverte |
|---------------|---------|
| **Loi 25** (RLRQ c. P-39.1) | Donnees au Canada, consentement, droit de suppression |
| **LPRPDE** (federal) | Chiffrement transit + repos, acces restreint |
| **OACIQ** | Zero conseil juridique/financier par l'IA, transfert obligatoire |
| **CASL/Twilio** | Gestion STOP, pas de spam, opt-in implicite |
| **NDA** | Signe entre NextMove Inc. et Joanel Dupart (identifiants Matrix) |

---

## Framework BMAD

Ce projet utilise le [BMAD Method](https://github.com/bmadcode/BMAD-METHOD) v6.0.1 pour la gestion produit structuree.

**Workflows completes :**
- Product Brief (create-product-brief) — avec Party Mode
- PRD (create-prd) — 12 steps, validation passee
- UX Design (create-ux-design) — output Figma

**Prochaines etapes BMAD :**
- `/bmad-bmm-create-architecture` — Architecture decisions
- `/bmad-bmm-create-epics-and-stories` — Epics et stories
- `/bmad-bmm-sprint-planning` — Sprint planning formel

---

## Contact

**NextMove Inc.**
Projet : Adjointe IA du Courtier Immobilier
GitHub : [kakame94/NextMove](https://github.com/kakame94/NextMove)
Figma : [JXlxEfExXxH1sVpXFnwFKH](https://www.figma.com/design/JXlxEfExXxH1sVpXFnwFKH)

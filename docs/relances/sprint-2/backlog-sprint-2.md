# Sprint 2 — Backlog Priorisé

> **Thème Sprint 2 :** Système de relance automatisée — MVP opérationnel
> **Durée :** 2 semaines (10 jours ouvrables)
> **Date de démarrage :** [À fixer post-workshop Joanel]
> **Équipe :** Eliot (full-stack + architecte)

---

## Objectifs Sprint 2

**Objectif principal :** Pouvoir envoyer automatiquement 3 types de relances en production, avec garde-fous légaux complets.

**Critères de succès :**
- ✅ Un prospect inactif 7j reçoit un SMS automatique (T1)
- ✅ Un courtier reçoit une notif si prospect chaud négligé (T4)
- ✅ Un prospect peut se désinscrire avec STOP et n'est plus relancé
- ✅ Budget Twilio et sender score monitorés
- ✅ Joanel valide UAT avec 3 prospects réels

---

## Priorités

| Tag | Signification | Délai |
|-----|---------------|-------|
| **P0** 🔴 | Bloquant go-live. Ne PAS livrer Sprint 2 sans | Semaine 1 |
| **P1** 🟡 | Important MVP. Livrer en Sprint 2 si possible | Semaine 2 |
| **P2** 🟢 | Nice-to-have. Sprint 3 acceptable | Sprint 3 |
| **P3** ⚪ | Post-MVP | Post-sprint 3 |

---

## Backlog détaillé

### 🔴 P0 — Fondations légales et infrastructure

#### US-1 : Table `blacklist` + opt-out STOP
**En tant que** utilisateur du système,
**je veux** que le mot-clé STOP désinscrive immédiatement un prospect de toute relance,
**afin de** respecter la loi 25 QC et CASL.

**Critères d'acceptation :**
- [ ] Table `blacklist` créée avec phone/email/reason/blocked_at/opted_out_by
- [ ] RLS configurée (seul n8n service_role peut écrire)
- [ ] Workflow n8n : réception SMS "STOP" → INSERT blacklist + accusé réception
- [ ] Accusé de réception SMS envoyé dans les 60 secondes
- [ ] Test : prospect blacklisté ne reçoit plus aucun SMS (manuel + auto)
- [ ] Logs consultables (tableau admin simple)

**Effort :** 1 jour
**Dépendances :** aucune
**Risques :** mauvaise détection variantes (UNSUBSCRIBE, ARRÊT) → tester

---

#### US-2 : Schéma enrichi `relances` + `relance_templates`
**En tant que** système,
**je veux** une structure de données complète pour tracer et paramétrer les relances,
**afin de** permettre le scheduler et l'audit.

**Critères d'acceptation :**
- [ ] Migration SQL : ajout colonnes à `relances` (type, canal, status, attempt_count, max_attempts, template_id, payload JSONB, etc.)
- [ ] Table `relance_templates` créée (id, type, canal, lang, body, active)
- [ ] Seed data : au moins T1 et T4 rédigés
- [ ] RLS configurée
- [ ] Indexes pour performance scheduler

**Effort :** 0.5 jour
**Dépendances :** US-1 (blacklist existe)

---

#### US-3 : Fonction `can_send_relance()`
**En tant que** scheduler,
**je veux** une fonction qui valide si une relance peut être envoyée,
**afin de** centraliser les 13 règles de garde-fous.

**Critères d'acceptation :**
- [ ] Fonction PostgreSQL ou TypeScript (à décider) implémentant G1-G13
- [ ] Retour structuré : `{ action, reason, retry_at }`
- [ ] Tests unitaires pour chaque garde-fou (13 tests min)
- [ ] Cas d'édition : blacklist, STOP récent, cadence, horaire, jour férié, budget, sender score, template manquant, anti-spam global
- [ ] Logs des blocages dans `relances_blocked_log`

**Effort :** 1 jour
**Dépendances :** US-2

---

#### US-4 : Scheduler n8n (cron 15 min)
**En tant que** plateforme,
**je veux** un scheduler qui scanne les prospects toutes les 15 min,
**afin de** déclencher les relances au bon moment.

**Critères d'acceptation :**
- [ ] Workflow n8n `relances-scheduler` actif avec cron */15 min
- [ ] Query optimisée : prospects avec triggers armés
- [ ] Appel à `can_send_relance()` pour chaque candidat
- [ ] Si SEND : insertion relance + appel Twilio + update status
- [ ] Si BLOCK : log reason
- [ ] Si DEFER : update `scheduled_at`
- [ ] Gestion d'erreur : retry 1x puis fail + alerte admin
- [ ] Monitoring : dashboard Grafana ou log central

**Effort :** 1 jour
**Dépendances :** US-3

---

#### US-5 : Trigger T1 `inactif_7j`
**En tant que** courtier,
**je veux** que mes prospects inactifs depuis 7 jours reçoivent un SMS de relance automatique,
**afin de** ne pas perdre une opportunité dormante.

**Critères d'acceptation :**
- [ ] Détection : `SELECT prospects WHERE last_message_at < NOW() - 7d AND status NOT IN ('perdu', 'conclu')`
- [ ] Template T1 rédigé et en base
- [ ] Variables injectées ({{prospect_prenom}}, {{bien_type}}, {{bien_secteur}}, {{courtier_prenom}})
- [ ] SMS envoyé via Twilio
- [ ] Trace complète dans `relances`
- [ ] Notif courtier : "Relance T1 envoyée à [prospect]"
- [ ] Si prospect répond : compteur inactivité remis à zéro
- [ ] Test UAT : 1 prospect test avec Joanel

**Effort :** 1 jour
**Dépendances :** US-4, template T1 validé par Joanel

---

#### US-6 : Trigger T4 `nudge_courtier_chaud`
**En tant que** courtier,
**je veux** recevoir une notif push si j'ai un prospect chaud négligé depuis 24h,
**afin de** ne pas laisser filer un deal.

**Critères d'acceptation :**
- [ ] Détection : `SELECT prospects WHERE heat_score >= 7 AND last_courtier_action_at < NOW() - 24h`
- [ ] Template T4 (notif push + email fallback)
- [ ] Notif push via PWA service worker (ou fallback email)
- [ ] Snooze 4h / 24h / pause 7j disponibles
- [ ] Max 3 notifs par prospect par 48h
- [ ] Test UAT avec Joanel

**Effort :** 1 jour
**Dépendances :** US-4, PWA notifications en place

---

### 🟡 P1 — Extension et RDV

#### US-7 : Séquence T2 + T3 (inactif_14j + inactif_21j_final)
**En tant que** système,
**je veux** escalader progressivement si T1 n'a pas eu de réponse,
**afin de** maximiser les chances de réactivation avant abandon.

**Critères d'acceptation :**
- [ ] Détection T2 : prospect avec T1 envoyé + pas de réponse + 7j écoulés
- [ ] Détection T3 : prospect avec T2 envoyé + pas de réponse + 7j écoulés
- [ ] Templates T2 (value-add) et T3 (exit option) en base
- [ ] Gestion mot-clé "CONTINUER" → reset séquence
- [ ] Après T3 sans réponse 7j : status → `perdu`
- [ ] Test UAT fin de séquence

**Effort :** 1 jour
**Dépendances :** US-5

---

#### US-8 : Table `rendez_vous` + migration
**En tant que** système,
**je veux** une structure pour gérer les rendez-vous prospects,
**afin de** pouvoir déclencher T6 et T7.

**Critères d'acceptation :**
- [ ] Table `rendez_vous` créée selon spec `docs/rendez_vous-table-spec.md`
- [ ] Enums : `rdv_status`, `rdv_type`, `rdv_source`
- [ ] RLS configurée
- [ ] Indexes performance scheduler
- [ ] Triggers `updated_at`
- [ ] Endpoint API pour création manuelle par courtier
- [ ] Tests : création, update, RLS

**Effort :** 1 jour
**Dépendances :** décisions Q1-Q8 de la spec validées par Joanel

---

#### US-9 : Trigger T6 `rdv_confirmation` (H-48 + H-24)
**En tant que** courtier,
**je veux** que mes prospects confirment leurs RDV automatiquement,
**afin de** réduire le taux de no-show.

**Critères d'acceptation :**
- [ ] Scheduler détecte RDV à H-48 sans confirmation
- [ ] SMS envoyé avec template T6 H-48
- [ ] Mot-clé "OUI" reconnu → status = `confirme`
- [ ] Mot-clé "NON" reconnu → notif courtier pour reporter
- [ ] Si pas de réponse à H-24 : relance T6 H-24 (2e tentative)
- [ ] Passage auto `planifie` → `passe` après H+0
- [ ] Test UAT avec Joanel sur 1 RDV test

**Effort :** 1 jour
**Dépendances :** US-8

---

#### US-10 : Dashboard monitoring relances
**En tant qu'**administrateur,
**je veux** un dashboard simple pour voir l'activité du système,
**afin de** détecter anomalies et mesurer ROI.

**Critères d'acceptation :**
- [ ] Vue SQL ou tableau admin : relances envoyées par jour/type/courtier
- [ ] Taux de réponse par type de relance
- [ ] Nombre de blocages (et raisons top 5)
- [ ] Coût Twilio consommé / budget mensuel
- [ ] Sender score actuel
- [ ] Prospects les plus actifs

**Effort :** 1 jour
**Dépendances :** US-4 (scheduler actif)

---

### 🟢 P2 — Sprint 3

#### US-11 : Trigger T5 `nudge_courtier_urgent`
**Pour :** prospects score 9-10 avec inaction courtier > 4h
**Effort :** 0.5 jour

#### US-12 : Trigger T7 `post_rdv_feedback`
**Pour :** capturer feedback J+1 après RDV
**Effort :** 0.5 jour

#### US-13 : Trigger T8 `etape_financement`
**Pour :** débloquer dossier préapprobation
**Effort :** 1 jour

#### US-14 : Intégration Google Calendar (import RDV)
**Pour :** synchro bidirectionnelle agendas courtier ↔ NextMove
**Effort :** 2 jours (OAuth + sync)

#### US-15 : Budget monitoring + sender score alerts
**Pour :** protection infrastructure et financière
**Effort :** 0.5 jour

---

### ⚪ P3 — Post-MVP

- **US-16 :** Trigger T9 réactivation long-terme (email) + opt-in
- **US-17 :** Trigger T10 anniversaire (relationnel)
- **US-18 :** Multi-langues (EN-CA)
- **US-19 :** A/B testing templates
- **US-20 :** Analytics avancés (funnel, cohortes)
- **US-21 :** Annulation RDV par prospect via SMS "ANNULER"

---

## Planning Sprint 2 (10 jours ouvrables)

### Semaine 1 — Fondations

| Jour | US | Thème | Livrable fin de journée |
|------|----|----|-------------------------|
| **J1** | US-1 | Blacklist + STOP | Workflow n8n fonctionnel, tests OK |
| **J2** | US-2 + US-3 (début) | Schéma + fonction guard | Migration appliquée, tests unitaires |
| **J3** | US-3 (fin) | Finalisation `can_send_relance()` | 13 tests verts |
| **J4** | US-4 | Scheduler n8n cron | Scheduler actif, logs |
| **J5** | US-5 | Trigger T1 bout-en-bout | Démo T1 avec Joanel |

**Revue fin Semaine 1 :** Démo T1 à Joanel, validation avant Semaine 2

### Semaine 2 — Extension

| Jour | US | Thème | Livrable |
|------|----|----|----------|
| **J6** | US-6 | T4 nudge courtier | PWA notif fonctionnelle |
| **J7** | US-7 | T2 + T3 séquence | Test escalade 14j/21j |
| **J8** | US-8 | Table `rendez_vous` | Migration + endpoint API |
| **J9** | US-9 | T6 RDV confirmation | Démo H-48 avec Joanel |
| **J10** | US-10 + polish | Dashboard + tests UAT | Sprint review + rétrospective |

**Revue fin Sprint 2 :** Démo globale à Joanel + décision go-live

---

## Definition of Done (par user story)

Une user story est "DONE" uniquement si :
- ✅ Code mergé dans `main` sans conflits
- ✅ Tests unitaires écrits et passent (coverage > 70%)
- ✅ Testée manuellement en staging (Supabase dev)
- ✅ Documentation mise à jour (README repo + diagramme si nouveau flow)
- ✅ Validée par Joanel en UAT (au minimum démonstration)
- ✅ Monitoring actif (logs, alertes si applicable)
- ✅ Aucune régression sur fonctionnalités Sprint 1

---

## Risques identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|-----------|
| **Twilio sender score dégradé** en early adoption | Moyenne | Haute | Démarrer avec volume faible, monitoring strict |
| **Joanel indisponible pour UAT** | Faible | Haute | Bloquer 3h de dispo à l'avance |
| **Claude API mal interprète "CONTINUER"** / "OUI" / "NON" | Moyenne | Moyenne | Fallback regex simple + log les faux négatifs |
| **Google Calendar OAuth complexe** (US-14) | Haute | Moyenne | Reporter Sprint 3, pas bloquant MVP |
| **Coûts Twilio > budget** | Faible | Haute | Alerte budget 80% + cap absolu |
| **Prospect répond par message libre** (pas OUI/STOP) | Haute | Basse | Claude parse intent, fallback = flag courtier |

---

## Métriques de succès (fin Sprint 2)

- **> 90%** des relances T1 envoyées dans la fenêtre temporelle prévue
- **< 1%** de relances à des numéros blacklistés (idéalement 0)
- **< 5%** de faux positifs "humain actif" (prospect relancé alors qu'il vient d'écrire)
- **0** amende légale / opt-out non respecté
- **< 50 CAD** consommés en Twilio (MVP faible volume)
- **Sender score > 97/100**
- **NPS Joanel** > 7/10 en UAT

---

## Liens

- Document maître : `docs/relances-decision-matrix.md`
- Spec table RDV : `docs/rendez_vous-table-spec.md`
- Templates SMS : `docs/templates-sms-specifications.md`
- Contraintes légales : `docs/business-constraints-checklist.md`
- Workshop : `workshop/agenda-workshop-joanel.md`

---

*Backlog Sprint 2 rédigé par Eliot — v1.0 en attente de validation Joanel*

# Workshop NextMove — Système de Relance

## Ordre du jour (90 minutes)

**Participants :** Joanel (propriétaire produit), Eliot (architecte/dev)
**Objectif :** Valider les règles fonctionnelles + priorités Sprint 2 du système de relance automatisée

**Date proposée :** [À fixer]
**Format :** Visio + écran partagé
**Documents à avoir ouverts :**
- `docs/relances-decision-matrix.md` (document maître)
- `docs/templates-sms-specifications.md`
- `docs/business-constraints-checklist.md`
- `sprint-2/backlog-sprint-2.md`

---

## Règles de la séance

- ✅ Une décision binaire par point : **OUI / NON / À CREUSER**
- ✅ Timeboxing strict (voir durées par bloc)
- ✅ Si 3 min sans consensus → parquer + revenir en fin de séance
- ✅ Eliot prend les notes en direct dans les checklists de chaque doc
- ❌ Pas de dérive vers des sujets hors sprint 2

---

## Déroulé

### 🔹 Bloc 0 — Ouverture (5 min)

**Objectif :** Aligner contexte + objectif séance.

- [1 min] Rappel de l'objectif : *"Fixer les règles du système de relance pour démarrer Sprint 2 lundi prochain"*
- [2 min] Tour des documents prêts (montrer la structure du dossier `24_NextMove/`)
- [2 min] Confirmer disponibilité Joanel pour 90 min sans interruption

---

### 🔹 Bloc 1 — Matrice M1 : Triggers (25 min)

**Objectif :** Valider **quels événements déclenchent une relance** en MVP.

**Document de référence :** `relances-decision-matrix.md` section 2

**Parcourir T1 à T10 et décider :**

| ID | Trigger proposé | Joanel : Inclure MVP ? | Notes |
|----|-----------------|------------------------|-------|
| T1 | `inactif_7j` (prospect sans échange 7j) | ☐ OUI / ☐ NON | |
| T2 | `inactif_14j` (suite T1) | ☐ OUI / ☐ NON | |
| T3 | `inactif_21j_final` (dernier recours) | ☐ OUI / ☐ NON | |
| T4 | `nudge_courtier_chaud` (score ≥ 7, > 24h) | ☐ OUI / ☐ NON | |
| T5 | `nudge_courtier_urgent` (score ≥ 9, > 4h) | ☐ OUI / ☐ NON | |
| T6 | `rdv_confirmation` (H-48 avant RDV) | ☐ OUI / ☐ NON | Dépend table `rendez_vous` |
| T7 | `post_rdv_feedback` (H+24 après RDV) | ☐ OUI / ☐ NON | |
| T8 | `etape_financement` (préapprobation en retard 7j) | ☐ OUI / ☐ NON | |
| T9 | `reactivation_longterme` (perdu depuis 90j) | ☐ OUI / ☐ NON | Opt-in email requis |
| T10 | `relation_fidelisation` (anniversaire) | ☐ OUI / ☐ NON | Optionnel |

**Questions clés à poser :**

1. **Cadences** — Le délai de 7 jours pour T1 est-il le bon ? (ou 5 ? 10 ?)
2. **Score chaud** — Le seuil "score ≥ 7" déclenche T4. Le bon seuil pour Joanel ?
3. **Urgent** — Existe-t-il des prospects score 9-10 assez fréquemment pour justifier T5 ?
4. **RDV** — Joanel veut-il priorité T6 dès Sprint 2 (implique création table `rendez_vous`) ?
5. **T9 opt-in email** — Procédure de collecte du consentement email déjà en place ?

**Livrable du bloc :** Liste validée des triggers MVP signés par Joanel.

---

### 🔹 Bloc 2 — Matrice M2 : Garde-fous (20 min)

**Objectif :** Valider **les règles qui bloquent ou décalent une relance**.

**Document de référence :** `relances-decision-matrix.md` section 3

**Parcourir G1 à G13 :**

| ID | Garde-fou | Joanel : Valide ? | Notes |
|----|-----------|-------------------|-------|
| G1 | Blacklist (téléphone/email) | ☐ | Obligatoire légalement |
| G2 | STOP récent (< 90j) | ☐ | Obligatoire légalement |
| G3 | Status `perdu` + type ≠ réactivation | ☐ | |
| G4 | Prospect a écrit dans les 24h | ☐ | |
| G5 | Courtier a mis `pause_relances` | ☐ | |
| G6 | Cadence min non respectée | ☐ | Valeurs à valider |
| G7 | Max attempts atteint | ☐ | Valeurs à valider |
| G8 | Hors plage 8h-20h QC | ☐ | Dimanche inclus ? |
| G9 | Jour férié QC | ☐ | |
| G10 | Template manquant | ☐ | |
| G11 | Budget Twilio dépassé | ☐ | Valeur à valider |
| G12 | Sender score dégradé | ☐ | |
| G13 | ≥ 2 relances toutes en 48h | ☐ | |

**Questions clés :**

1. **Budget Twilio** — 500 CAD / mois est la bonne limite ? (hypothèse pour MVP)
2. **Dimanche** — Envois prospect autorisés ou pas ?
3. **Horaires** — 8h-20h heure locale QC, ou fenêtre plus serrée ?
4. **Cadences minimales** — Validation des valeurs du tableau (section 3.2 matrice)
5. **Pause relances** — Courtier peut mettre en pause toutes relances d'un prospect ?

**Livrable :** Tableau G1-G13 validé avec paramètres numériques.

---

### 🔹 Bloc 3 — Matrice M3 : Cadence, canal, timing (15 min)

**Objectif :** Valider **quand et par quel canal**.

**Document de référence :** `relances-decision-matrix.md` section 4

**Points à décider :**

1. **Canal principal par type** — SMS/Email/Notif/Combo ? (voir tableau section 4)
2. **Golden hour immobilier** — Mar-Jeu 10h-12h : hypothèse ou validée ?
3. **Fenêtres horaires** par type (section 4 tableau)
4. **Escalade progressive** (T1→T2→T3) — logique validée ?
5. **Données Joanel** — a-t-il des stats terrain (taux de réponse par jour/heure) ?

**Décisions clés à consigner :**

| Question | Décision |
|----------|----------|
| Golden hour | ☐ Mar-Jeu 10h-12h ☐ Autre : ______ |
| Relances dimanche autorisées ? | ☐ OUI ☐ NON |
| Notifications courtier 24/7 ? | ☐ OUI (urgences) ☐ Heures ouvrables |
| Email fallback SMS en cas d'échec ? | ☐ OUI ☐ NON |

**Livrable :** Matrice M3 validée.

---

### 🔹 Bloc 4 — Templates SMS (15 min)

**Objectif :** Valider les **textes des messages** happy path + edge cases.

**Document de référence :** `templates-sms-specifications.md`

**À parcourir :**

1. **Chargement des templates Figma** (écran partagé Figma)
2. **Comparaison avec les propositions** du document
3. **Validation des edge cases** (pas de `bien_secteur`, pas de `nouveaux_biens`…)
4. **Contraintes :** longueur 160 caractères, vouvoiement, signature
5. **Templates système** : STOP, HELP, erreur non reconnue

**Questions de style :**

1. **Emoji** — autorisés ? Combien max ?
2. **Tutoiement/vouvoiement** — confirmé ?
3. **Signature** — format exact ?
4. **URL** — courtes via quel domaine ?

**Templates à rédiger en séance (si manquants dans Figma) :**

- [ ] T3 (option de sortie CONTINUER/STOP)
- [ ] T4 notif push courtier (edge case agrégé)
- [ ] T6 H-24 (fallback si H-48 sans réponse)
- [ ] T8 notif courtier étape financement
- [ ] T9 email réactivation
- [ ] STOP ack, HELP, erreur (templates système)

**Livrable :** 10 templates validés + 3 templates système conformes.

---

### 🔹 Bloc 5 — Priorisation Sprint 2 (10 min)

**Objectif :** Confirmer le **backlog Sprint 2** priorisé.

**Document de référence :** `sprint-2/backlog-sprint-2.md`

**À décider :**

| Priorité | Scope | Joanel : Valide ? |
|----------|-------|-------------------|
| **P0** (semaine 1) | Blacklist + STOP + T1 inactif_7j + T4 nudge courtier + garde-fous G1-G10 | ☐ |
| **P1** (semaine 2) | T2/T3 + T6 RDV confirmation + table `rendez_vous` | ☐ |
| **P2** (Sprint 3) | T5 urgent, T7 post-RDV, T8 financement, intégration Google Calendar | ☐ |
| **P3** (Post-MVP) | T9 réactivation, T10 anniversaire, multi-langues, A/B testing | ☐ |

**Questions clés :**

1. **Durée Sprint 2** — 2 semaines OK ? (hypothèse)
2. **Date de démarrage** — lundi prochain ?
3. **Disponibilité Joanel** — daily 15 min ou weekly 30 min ?
4. **Critère de succès Sprint 2** — Définition de "DONE" pour chaque user story

**Livrable :** Backlog Sprint 2 validé, date de démarrage fixée.

---

### 🔹 Bloc 6 — Next steps et clôture (5 min)

**Objectif :** Aligner sur les actions post-workshop.

**Action items type :**

- [ ] **Eliot** : finaliser les 6 documents avec les décisions actées (J+1)
- [ ] **Eliot** : push dans le repo GitHub NextMove `docs/` (J+1)
- [ ] **Joanel** : fournir données terrain taux de réponse (J+3)
- [ ] **Joanel** : valider version finale templates SMS par email (J+3)
- [ ] **Eliot** : démarrer Sprint 2 — migrations DB + `can_send_relance` (J+2 ou lundi)
- [ ] **Eliot** : démo fin Semaine 1 (T1 `inactif_7j` bout-en-bout)
- [ ] **Joanel** : préparer liste de 3 prospects test pour UAT Semaine 2

**Confirmer :**

- Prochain point : fin Semaine 1 (démo T1) ou daily 15 min ?
- Canal de communication : Slack, email, Teams ?

---

## Annexes

### A. Checklist préparation (Eliot, la veille)

- [ ] Envoyer le lien Figma à Joanel 24h avant pour qu'il revoie les templates
- [ ] Imprimer / exporter PDF de `relances-decision-matrix.md` pour référence
- [ ] Préparer screen share Supabase (schéma actuel visible)
- [ ] Tester la connexion visio + écran partagé
- [ ] Avoir l'index du dossier `24_NextMove/` ouvert

### B. Checklist matériel Joanel

- [ ] Données terrain taux de réponse (si disponibles)
- [ ] Liste prospects VIP à exclure (si applicable)
- [ ] Budget Twilio mensuel ciblé
- [ ] Vision canaux (SMS uniquement ? SMS + email ?)

### C. Format de prise de notes en séance

Eliot met à jour en direct :

- ✏️ Les cases à cocher dans `relances-decision-matrix.md` section 8.B
- ✏️ Les cases à cocher dans `business-constraints-checklist.md` section 5
- ✏️ Les cases à cocher dans `templates-sms-specifications.md` section 6

### D. Règles d'escalade si blocage

| Type de blocage | Action |
|----------------|--------|
| Désaccord sur une règle métier | Parquer + revenir en fin de séance |
| Manque de donnée | Noter comme "à valider par Joanel sous 48h" |
| Conflit légal | Consulter avocat avant décision définitive |
| Hors scope Sprint 2 | Ajouter au backlog Post-MVP et avancer |

---

*Agenda préparé par Eliot — v1.0*

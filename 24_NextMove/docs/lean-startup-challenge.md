# Klaris — Challenge Solution & Exécution (The Lean Startup)

> **But.** Stress-tester la solution Klaris ET son exécution à la lumière de *The Lean Startup — How Today's Entrepreneurs Use Continuous Innovation to Create Radically Successful Businesses* (Eric Ries, Crown Business 2011, ISBN 978-0-307-88791-7).
> **Documents liés.** [business-canvas-challenge.md](./business-canvas-challenge.md) · [architecture-challenge.md](./architecture-challenge.md) · [business-cost-structure.md](./business-cost-structure.md) · [nps-spec.md](./nps-spec.md)
> Date : 2026-05-08

---

## TL;DR — Verdict en 5 lignes

> **Klaris a une excellente Vision (3 Vs OK depuis BMC challenge) et une Validation crédible (Joanel pilote réel). MAIS l'exécution Lean est immature : (1) pas d'Innovation Accounting (3 milestones), (2) métriques actuelles sont des « vanity metrics » (1 pilote), (3) pas de cohort analysis, (4) pas de cadence Pivot/Persevere formalisée, (5) cycle Build-Measure-Learn = 1 mois (à raccourcir à 1 semaine), (6) MVP a sauté l'étape « smoke test » et a été construit en mode « product-first » au lieu de « learning-first ».**

| Dimension Lean Startup | Score | Note |
|------------------------|-------|------|
| Vision (Ch1-2 : Start, Define) | 8/10 | ✅ Elevator Pitch unifié (action BMC) |
| Validated Learning (Ch3) | 6/10 | Joanel pilote réel ✅, mais 3/4 personas non testés |
| Experiments (Ch4) | 4/10 | Pas de smoke test, pas de Wizard of Oz testé |
| MVP (Ch6) | 6/10 | Product MVP livré, manque Concierge / Smoke Test MVP |
| Innovation Accounting (Ch7) | 3/10 | **Pas de baseline cohort**, métriques = vanity |
| Pivot or Persevere (Ch8) | 4/10 | Pas de cadence trimestrielle, pas de critère explicite |
| Engines of Growth (Ch10) | 5/10 | Sticky implicite (retention), Viral (referrals) pas mesuré |
| Small batches (Ch9) | 6/10 | Sprints 1 mois ✅, mais releases pas continues |

**Score moyen : 5.25/10** — exécution Lean immature.

---

## 1 — Cadre théorique appliqué

### 1.1 Eric Ries — concepts-clés cités

| Concept | Source | Définition |
|---------|--------|------------|
| **Validated Learning** | Ch3 p.49 | *« A rigorous method for demonstrating progress when one is embedded in the soil of extreme uncertainty. »* |
| **Build-Measure-Learn loop (BML)** | Ch4 | Boucle d'apprentissage : Build → Measure → Learn → Build... Optimiser le **temps total du tour**, pas chaque étape isolément. |
| **MVP (Minimum Viable Product)** | Ch6 | *« Allows a startup to fill in real baseline data in its growth model. »* Pas un prototype low-quality — un produit qui maximise l'apprentissage par dollar dépensé. |
| **Types de MVP** | Ch6 | Smoke test · Concierge · Wizard of Oz · Single-feature · Landing page · Promotional. |
| **Innovation Accounting (3 étapes)** | Ch7 p.116 | (1) Establish baseline via MVP · (2) Tune the engine vers l'idéal · (3) Decision : pivot or persevere. |
| **Vanity Metrics vs Actionable Metrics** | Ch7 p.128 | Vanity : total registered users (hockey stick). Actionable : cohort retention/conversion. |
| **Cohort Analysis** | Ch7 p.123 | Mesurer la performance de **chaque groupe** qui rejoint le produit indépendamment. |
| **Pivot or Persevere meeting** | Ch8 p.149 | Cadence régulière (recommandé : **trimestrielle** au minimum). Si on ne déplace pas les actionable metrics → pivot. |
| **10 types de pivots** | Ch8 | Zoom-in · Zoom-out · Customer segment · Customer need · Platform · Business architecture · Value capture · Engine of growth · Channel · Technology. |
| **3 Engines of Growth** | Ch10 | **Sticky** (retention) · **Viral** (coefficient > 1) · **Paid** (LTV > CAC). |
| **Small batches / Continuous deployment** | Ch9 p.184 | Réduire la taille des batches = réduire le cycle BML. Toyota production system. |
| **5 Whys** | Ch11 | Root cause analysis. Toute défaillance = 5 itérations « pourquoi ? » → cause racine humaine ou processus. |
| **Last responsible moment** | Ch11 | Différer une décision jusqu'au dernier moment où elle reste réversible. |

---

## 2 — Audit exécution Klaris vs Lean Startup

### 2.1 Vision & Validated Learning (Ch1-3)

| Dimension | Lean Startup attendu | État Klaris | Score |
|-----------|----------------------|-------------|-------|
| Vision documentée | « Where you want to go » + customer empathy | ✅ Elevator Pitch + 4 personas JTBD ([architecture.md](../../architecture.md), [personas-insights-figma.md](./personas-insights-figma.md)) | 9/10 |
| Validated Learning | Insights *empiriquement* validés sur clients réels | 🟡 Joanel pilote en prod ✅ — mais 3/4 personas (Maxime, Charlyse, JP) **ne sont pas validés en usage réel** | 6/10 |
| Customer Development | Steve Blank : *get out of the building* | ✅ 4 interviews JTBD mars 2026 + atelier Joanel ([atelier_resultats/](../../atelier_resultats/)) | 8/10 |
| Leap-of-faith assumptions identifiées | Lister explicitement les 2-3 hypothèses critiques qui doivent tenir | ❌ **Non documenté** | 3/10 |

**Citation Ch3 p.49 :**
> *« Validated learning is the process of demonstrating empirically that a team has discovered valuable truths about a startup's present and future business prospects. »*

**Gap Klaris.** Klaris a fait du Customer Development (interviews) mais n'a pas formalisé ses **leap-of-faith assumptions**. À expliciter :
1. Hypothèse value : « Un courtier solo paiera 100 CAD/mois si Klaris lui sauve 2-3h/jour d'admin. »
2. Hypothèse growth : « Joanel + 5 courtiers initiaux génèrent 3-5 referrals/mois pour 12 mois (CAC ≈ 0). »
3. Hypothèse compliance : « OACIQ ne bannira pas un outil IA si audit log + 1-clic reprise humaine sont en place. »

**Action.** Créer un fichier `leap-of-faith-assumptions.md` listant ces 3 hypothèses + tests prévus + critères go/no-go.

---

### 2.2 Experiments & MVP (Ch4-6)

| Type de MVP | Pour qui ? | État Klaris |
|-------------|------------|-------------|
| **Smoke test** (preorder/landing avec CTA achat) | Tester l'intérêt avant de coder | ❌ Pas fait — on a sauté direct à la construction |
| **Concierge MVP** (humain fait le boulot manuellement) | Tester la valeur avant l'automation | 🟡 Joanel a essayé d'automatiser SMS manuellement avant Klaris — partiellement |
| **Wizard of Oz** (UI réelle, IA fake côté serveur) | Tester l'UX sans build le moteur IA | ❌ Pas fait — Claude API directement |
| **Single-feature MVP** | Tester 1 feature isolée | ✅ Chatbot SMS = single-feature MVP réel |
| **Landing page MVP** | Tester multiple value props | ❌ landing page actuelle = vitrine, pas MVP |

**Citation Ch6 p.117 :**
> *« A startup might prefer to develop separate MVPs that are aimed at getting feedback on one assumption at a time. »*

**Gap Klaris.** Klaris a livré un **product MVP** complet (Sprint 1-7 = 7 mois de build) mais n'a **pas** testé ses assumptions séparément. Conséquence : si Joanel n'aimait pas Klaris, on aurait perdu 7 mois de build pour apprendre qu'on s'était trompé.

**Risque parallèle (cf. IMVU dans le livre) :** *« We had built something nobody wanted. We had committed the biggest waste of all : building a product that our customers refused to use. »*

**Action.** Pour les **3 personas non-validés** (Maxime, Charlyse, JP), faire un MVP par persona **AVANT** de coder une feature dédiée :
- Maxime → **Concierge MVP** : 1 mois, Joanel + Eliot font à la main l'analyse comparative que Maxime demande. Si Maxime paie 100 CAD pour 4 analyses = leap-of-faith validé.
- Charlyse → **Wizard of Oz MVP** : interface mock + Eliot fait le sync Matrix manuellement. Si Charlyse signe contrat 100 CAD/mois après 30 jours = validé.
- JP → **Smoke test** : landing page « Klaris Agence », formulaire demande info. Mesurer % d'agences qui demandent un call. Si > 5% → validé.

---

### 2.3 Innovation Accounting — les 3 milestones (Ch7)

Selon Ries Ch7 p.116, Innovation Accounting suit **3 étapes** :

#### Étape 1 — Establish the Baseline (via MVP)
> *« Use a minimum viable product to establish real data on where the company is right now. »*

**État Klaris.** ❌ Pas de **baseline cohort** établie.
- On a 1 pilote (Joanel) en mode gratuit.
- Aucune métrique cohort : conversion rate, retention, lifetime value, signup-to-paid ratio.
- Cf. tableau IMVU (Ch7 p.124) — graph cohort par mois `Feb-05 → Aug-05` montrant % registered → logged in → had conversation → had 5 conversations → paid.

**Action.** Tableau cohort mensuel à publier dans `ebm-reports/YYYY-MM.md` (cf. [ebm-time-tracking-spec.md §6](./ebm-time-tracking-spec.md)) avec funnel Klaris :
```
Cohort 2026-06 :
  - Lead → courtier signup : X %
  - Signup → 1er prospect SMS : X %
  - 1er prospect → 5e prospect qualifié : X %
  - 5e prospect → paiement (post-trial) : X %
  - Paiement mois 1 → mois 3 (retention) : X %
```

#### Étape 2 — Tune the Engine
> *« After the startup has made all the micro changes and product optimizations it can to move its baseline toward the ideal, the company reaches a decision point. »*

**État Klaris.** 🟡 Sprint 1-7 = optimisations produit, mais sans hypothèse-test explicite.
- Chaque sprint produit des features (cf. [klaris_ios/README.md](../../klaris_ios/README.md)) sans dire « cette feature doit déplacer KVM X de Y à Z ».
- Cf. citation Ch7 : *« A good design is one that changes customer behavior for the better. »*

**Action.** Pour chaque feature Sprint 8+, écrire une **fiche hypothèse** :
```
Feature : Audit log + 1-clic reprise humaine (R3 archi-challenge)
Hypothèse : Réduire le « churn intent » courtier de 14% à 7%
            (mesure : courtiers qui ouvrent l'app puis ne l'utilisent pas pendant 14j)
Test : Cohort A (avec audit log) vs Cohort B (sans), 30 jours
Critère success : Churn intent A < 0.5 × Churn intent B
Critère fail : Pas de différence ou A > B → reconsidérer
```

#### Étape 3 — Pivot or Persevere
> *« A startup that fails to do so will see its ideal recede ever further into the distance. »*

**État Klaris.** ❌ Pas de **cadence formelle** Pivot/Persevere.
- Sprint Retro existe (cf. spec à venir) mais c'est une retro process, pas une retro stratégique.
- Aucun document type « board meeting Q1 2026 : pivot ou persevere ? ».

**Action.** Cadence trimestrielle :
- **Q1 (M3)** : 1er Pivot/Persevere meeting avec les 4 fondateurs.
- Critère persevere : ≥ 5 courtiers payants OU NPS ≥ 30 OU MRR > 500 CAD.
- Critère pivot : aucun des 3 OU 2/3 leap-of-faith assumptions invalidées.
- Output : doc `pivot-persevere/2026-Q1.md` archivé.

---

### 2.4 Vanity vs Actionable Metrics (Ch7 p.128)

**Citation :**
> *« Vanity metrics : total registered users, gross number of customers, hockey-stick graph. »*
> *« Actionable metrics : cohort retention, conversion rate per signup source, ARPU per cohort. »*

**État Klaris.** Métriques actuelles citées dans nos docs :
| Métrique citée | Vanity ou Actionable ? | Note |
|----------------|--------------------------|------|
| « 1 pilote Joanel » | 🔴 Vanity | N=1 ne dit rien sur le marché |
| « 90% close rate Joanel » | 🔴 Vanity | C'est sa stat AVANT Klaris, pas après |
| MRR projeté 7 000 CAD M12 | 🟡 Mixte | Projection, pas mesure |
| ARR M12 84 000 CAD | 🟡 Mixte | Projection |
| Marge brute 91.5 % | 🟢 Actionable | Calculée sur cost structure réelle |
| NPS courtier | 🟢 Actionable (à venir spec NPS) | Pas encore mesuré |
| Release Frequency | 🟢 Actionable (EBM) | À tracker |
| Defects (Sentry) | 🟢 Actionable | Sprint 6 ✅ |

**Action.** Ne JAMAIS citer « 1 pilote Joanel » comme proof point seul. Toujours coupler avec une cohort metric (même si N=1) : *« Joanel a converti 6/10 prospects qualifiés vs 4/10 avant Klaris (60% vs 40%). »*

---

### 2.5 Engines of Growth (Ch10)

Ries identifie **3 engines** :

| Engine | Mécanique | KPI clé |
|--------|-----------|---------|
| **Sticky** | Retention élevée → revenue récurrent | Churn rate < retention rate |
| **Viral** | Chaque user en amène k > 1 | Viral coefficient k |
| **Paid** | LTV > CAC, ratio constant | LTV / CAC ≥ 3 |

**État Klaris.**

| Engine | Klaris fit ? | Note |
|--------|--------------|------|
| **Sticky** | 🟢 Primary fit | Adjointe IA = service récurrent. Churn cible < 5%/mois. |
| **Viral** | 🟡 Secondary fit | Slide 09 deck : « 100% referrals ». Mais coefficient viral non mesuré. |
| **Paid** | 🔴 Pas exploré | Aucun budget marketing. CAC ≈ 0 actuellement (referrals). |

**Risque.** Klaris dépend exclusivement de **viral** (referrals Joanel). Si k < 1 → croissance s'arrête. Pas de plan B.

**Action.** Mesurer le **viral coefficient k** dès M3 :
```
k = (nb de referrals envoyés / courtier) × (taux de conversion referral → signup)
```
Si k < 1 après M6 → plan paid (Google Ads / LinkedIn ads) à activer + budget BMC Channels (Action BMC §3.3).

---

### 2.6 Small Batches & Continuous Deployment (Ch9)

**Citation Ch9 (p.183) :**
> *« Small batches mean faster feedback loops. The Toyota Production System works on this principle. »*

**État Klaris.**
- Sprint duration : ~4 semaines (basé sur sprints 1-7 sur 7 mois).
- Cycle Build-Measure-Learn complet : ~1 mois (estimation).
- Pas de continuous deployment — chaque sprint = 1 release.

**Cible Lean Startup.**
- Cycle BML idéal : **1 jour à 1 semaine**.
- IMVU déployait **plusieurs fois par jour** (cf. Ch9).

**Action.**
1. Réduire batch : décomposer Sprint 8 en **4 mini-sprints d'1 semaine** chacun.
2. Activer **Vercel preview deployments** sur chaque PR (probablement déjà actif → vérifier).
3. Activer **Supabase migration deploy** automatisé via GitHub Actions.
4. Cible cycle BML M9 : ≤ 7 jours du commit à l'apprentissage validé.

---

### 2.7 5 Whys (Ch11)

**Citation Ch11 :**
> *« At the root of every seemingly technical problem is actually a human problem. »*

**État Klaris.** ❌ Pas mentionné dans aucun doc.

**Application Klaris.** Quand un incident arrive (ex. Sentry erreur Twilio), faire un 5 Whys structurel :
```
1. Pourquoi le SMS n'est pas parti ?
   → Twilio API a renvoyé 429 rate limit
2. Pourquoi le rate limit ?
   → On a envoyé 200 SMS en 1 min sur le batch de relances
3. Pourquoi 200 d'un coup ?
   → Cron déclenche tous les retards à minuit pile
4. Pourquoi minuit pile ?
   → Spec initial du cron, jamais reconsidérée depuis Sprint 2
5. Pourquoi jamais reconsidérée ?
   → Pas de processus de revue post-incident → procès humain manquant.

Action humaine : créer un canal Slack #incidents + retro 1×/mois.
```

**Action Sprint 9.** Template 5 Whys dans `incidents/YYYY-MM-DD.md` après chaque alerte critique Sentry.

---

## 3 — Top-7 corrections Lean (Sprints 8-12)

| # | Correction | Concept Lean | Effort | Sprint |
|---|------------|---------------|--------|--------|
| L1 | Documenter 3 leap-of-faith assumptions + critères go/no-go | Vision (Ch1-3) | 2 h | Sprint 8 |
| L2 | Cohort analysis funnel mensuel (template `ebm-reports/YYYY-MM.md`) | Innovation Accounting (Ch7) | 1 j | Sprint 8 |
| L3 | Pivot/Persevere meeting trimestriel formel (1er = Q1 M3) | Pivot or Persevere (Ch8) | 0.5 j/trim | Sprint 9 |
| L4 | Concierge MVP Maxime + Wizard of Oz Charlyse + Smoke test JP | Experiments (Ch4) + MVP types (Ch6) | 5 j chacun | Sprint 10-12 |
| L5 | Mesurer **viral coefficient k** + activer plan B paid si k < 1 | Engines of Growth (Ch10) | 2 j setup, mesure continue | Sprint 9 |
| L6 | Réduire sprint 4 sem → 1 sem (continuous deployment) | Small batches (Ch9) | 3 j refactor CI | Sprint 9 |
| L7 | Template 5 Whys post-incident + canal Slack #incidents | 5 Whys (Ch11) | 1 h | Sprint 9 |

**Total effort : ~22 jours-homme + setup continu** sur Sprints 8-12.

---

## 4 — Anti-patterns Lean à éviter

D'après Ch3-7-8 :

| Anti-pattern | Citation Ries | Risque Klaris |
|---------------|----------------|----------------|
| Building features without testing assumptions | *« Building a product that our customers refused to use »* (Ch3 IMVU) | On a déjà fait Apple Watch + ES — heureusement déprécié (cf. feature-deprecations.md) |
| Vanity metrics in board meetings | *« Hockey stick graph misleads »* (Ch7 p.131) | Ne pas pitcher « 1 pilote » seul à un investisseur |
| Persevere by inertia | *« Most dangerous outcomes is to bumble along in the land of the living dead »* (Ch7 p.115) | Risque si on n'instaure pas la cadence Pivot/Persevere |
| « Reality distortion field » | Ch7 : *« If we're not moving the drivers, we're not making progress »* | Ne pas se rassurer avec MRR projeté tant qu'il n'est pas réel |
| Optimization vs Learning | *« Optimizing the product or its marketing will not yield significant results [if you're building the wrong thing] »* (Ch7 p.131) | Risque si on optimise UX iOS avant de valider Maxime/Charlyse/JP |
| Big batch | *« The bigger the batch, the more delayed the feedback »* (Ch9) | Sprint 4 sem est encore trop gros pour MVP phase |

---

## 5 — Mise à jour leap-of-faith assumptions Klaris (livrable)

**3 hypothèses critiques** (à valider d'ici M6) :

### LF1 — Value hypothesis
> Un courtier solo QC paiera 100 CAD/mois si Klaris lui sauve 2-3h/jour d'admin (≈ 50 CAD/h équivalent).

**Test.** À M3, avoir au moins **3 courtiers payants** (pas Joanel, qui est gratuit pilote) qui ont signé après 14 jours d'essai.
**Critère go.** ≥ 3/10 trial → paid conversion.
**Critère no-go.** ≤ 1/10 → pivot value prop ou pricing.

### LF2 — Growth hypothesis
> Le réseau referrals courtier ↔ courtier produit naturellement k ≥ 1 viral coefficient (chaque courtier amène ≥ 1 nouveau prospect courtier).

**Test.** À M6, mesurer pour les 5 premiers courtiers payants : combien de referrals chacun a généré ?
**Critère go.** k ≥ 1 sur 6 mois.
**Critère no-go.** k < 0.5 → channel pivot (Google Ads, OACIQ events, partenariat Centris).

### LF3 — Compliance hypothesis
> L'OACIQ acceptera un outil IA SMS si audit log + 1-clic reprise humaine sont implémentés (pas de bannissement réglementaire).

**Test.** À M6, avoir initié dialogue OACIQ formel (cf. [oaciq-outreach.md](./oaciq-outreach.md)) et reçu une confirmation écrite (même informelle) que la conformité est acceptable.
**Critère go.** Réponse écrite OACIQ + pas de demande de modification majeure.
**Critère no-go.** OACIQ refuse l'approche → technology pivot (passer à des recommandations courtier-validées au lieu d'agent autonome).

---

## 6 — Suivi

- [ ] Sprint 8 : leap-of-faith assumptions documentées (L1)
- [ ] Sprint 8 : cohort funnel template publié (L2)
- [ ] Sprint 9 : 1er Pivot/Persevere meeting Q1 (L3)
- [ ] Sprint 9 : viral coefficient k mesuré (L5)
- [ ] Sprint 9 : sprint 1 semaine + 5 Whys template (L6, L7)
- [ ] Sprint 10-12 : MVP par persona Maxime/Charlyse/JP (L4)
- [ ] M3 : revue baseline cohort
- [ ] M6 : Pivot/Persevere Q2 — décision LF1/LF2/LF3 go/no-go
- [ ] M9 : Pivot/Persevere Q3 — bascule engine paid si k < 1

---

*Document v1.0 — 2026-05-08 — basé sur* The Lean Startup — How Today's Entrepreneurs Use Continuous Innovation to Create Radically Successful Businesses *— Eric Ries, Crown Business 2011 (ISBN 978-0-307-88791-7)*

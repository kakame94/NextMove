# Klaris — Glossaire Lean Startup

> **À lire AVANT la présentation `Klaris_Strategie_Lean_FR.pptx`.**
> Tous les concepts utilisés dans le deck + dans nos docs sont définis ici, dans l'ordre où ils apparaissent.
> **Source** : *The Lean Startup — How Today's Entrepreneurs Use Continuous Innovation to Create Radically Successful Businesses* — Eric Ries, Crown Business 2011 (ISBN 978-0-307-88791-7).
> **Bonus** : on cite aussi Christensen (Innovator's Dilemma) et McGreal/Jocham (Professional Product Owner) quand pertinent.
> Date : 2026-05-11

---

## Sommaire (par slide PPTX)

1. [Vocabulaire Slide 2 — Contexte](#slide-2--contexte) — challenge BMC, archi, Lean
2. [Vocabulaire Slide 3 — BML loop](#slide-3--build--measure--learn-bml)
3. [Vocabulaire Slide 4 — Validated Learning](#slide-4--validated-learning--vanity-vs-actionable)
4. [Vocabulaire Slide 5 — Leap-of-Faith](#slide-5--leap-of-faith-assumptions)
5. [Vocabulaire Slide 6 — Innovation Accounting](#slide-6--innovation-accounting)
6. [Vocabulaire Slide 7 — Cohort Funnel](#slide-7--cohort-funnel)
7. [Vocabulaire Slide 8 — Engines of Growth](#slide-8--engines-of-growth)
8. [Vocabulaire Slide 9 — Types de MVP](#slide-9--types-de-mvp)
9. [Vocabulaire Slide 10 — Pivot or Persevere](#slide-10--pivot-or-persevere)
10. [Vocabulaire Slide 12 — Small Batches & CD](#slide-12--small-batches--continuous-deployment)
11. [Vocabulaire Slide 13 — 5 Whys](#slide-13--5-whys)
12. [Index alphabétique (toutes les définitions)](#index-alphab%C3%A9tique)

---

## Slide 2 — Contexte

### Score BMC 4.8/10
Score moyen attribué aux 9 cases du Business Model Canvas de Klaris dans le doc [business-canvas-challenge.md](./business-canvas-challenge.md). 9 cases × score 0-10, moyenne 4.8 = solide validation mais Vision/KVMs/Cost-to-Build manquants. Source méthodologique : McGreal/Jocham, *The Professional Product Owner* Ch2.

### Score Archi 6/10
Score architecture technique Klaris (n8n + Supabase + Claude + Twilio + Drift iOS) selon les principes de Kleppmann (*DDIA*) + Petrov (*Database Internals*). 7 risques identifiés. Détails : [architecture-challenge.md](./architecture-challenge.md).

### Score Lean 5.25/10
Score exécution Klaris selon les 8 dimensions Lean Startup (Vision, Validated Learning, Experiments, MVP, Innovation Accounting, Pivot/Persevere, Engines of Growth, Small Batches). Détails : [lean-startup-challenge.md](./lean-startup-challenge.md).

### Cost-to-Run vs Cost-to-Build
- **Cost-to-Run** = TCO mensuel infra + outils + assurance (Klaris : ~735 CAD/mois). Source : Petrov, *Database Internals* Ch5 + McGreal/Jocham Ch3 Product Cost Ratio (lagging metric).
- **Cost-to-Build** = capital temps fondateurs (Klaris : 4 fondateurs × 80 h × 75 CAD/h = ~24 000 CAD/mois opportuniste). Source : même Ch3 (leading metric).
- **Seuil rentabilité réel** = (Cost-to-Run + Cost-to-Build) / Marge brute = 270 courtiers solo (vs 8 si on ne compte que Cost-to-Run).

---

## Slide 3 — Build → Measure → Learn (BML)

### Build-Measure-Learn loop
> *« Une boucle d'apprentissage : Build → Measure → Learn → Build... »*

Le cœur du Lean Startup (Ries Ch4). Trois étapes :
1. **Build** : construire le plus petit produit/feature qui teste une hypothèse.
2. **Measure** : mesurer son impact via métriques actionable (pas vanity).
3. **Learn** : décider — *Pivot* ou *Persevere* ?

**Objectif : minimiser le TEMPS TOTAL du tour, pas chaque étape isolément.**

> *« Le seul moyen de gagner est d'apprendre plus vite que quiconque. »* — Eric Ries

**Application Klaris** :
- Cycle BML actuel ≈ 30 jours (sprint 4 sem)
- Cible : ≤ 7 jours (cf. [sprint-cadence-1week.md](./sprint-cadence-1week.md))

### Hypothèse (testable)
Énoncé vérifiable par expérience. Format recommandé :
> *« Si on fait X, on devrait observer Y dans un délai Z. Si Y ≥ seuil S, on persevere. Si Y < S, on pivot. »*

Exemple Klaris : *« Si on ajoute la feature `Inviter un confrère`, on observera viral coefficient k ≥ 0.5 en 60 jours sur les 5 premiers payants. »*

---

## Slide 4 — Validated Learning + Vanity vs Actionable

### Validated Learning
> *« Validated learning is a rigorous method for demonstrating progress when one is embedded in the soil of extreme uncertainty. »* — Ries Ch3 p.49

Pas du « learning par anecdote ». Un apprentissage validé = preuve **empirique** que :
1. Une hypothèse est vraie/fausse
2. Sur la base de données réelles (pas opinion)
3. Que tu peux **agir** dessus

**Anti-pattern** : « on a learné des choses » = excuse classique des startups en train de couler. Ries dit : *« learning is the oldest excuse in the book for a failure of execution »*.

### Vanity Metrics (à BANNIR de nos board meetings)
Métriques qui font joli mais ne disent rien d'actionnable :
- ❌ « 1 pilote Joanel » (N=1 ne dit rien sur le marché)
- ❌ « Total registered users » qui ne fait que monter (hockey stick)
- ❌ « 90% close rate Joanel » (sa stat AVANT Klaris)
- ❌ MRR projeté sans cohort retention

> *« You'll see a traditional hockey stick graph. As long as you focus on the top-line numbers, you'll be forgiven for thinking this product development team is making great progress. »* — Ries Ch7 p.131

### Actionable Metrics (à PUBLIER dans rapports mensuels)
Métriques qui :
1. Sont mesurables par cohort
2. Suggèrent une action concrète
3. Permettent une décision Pivot/Persevere

Exemples Klaris :
- ✅ Cohort funnel : signup → 1er prospect → paid → M3 retention
- ✅ NPS post-onboarding D7
- ✅ Viral coefficient k par cohort
- ✅ Marge brute par cohort solo vs agence
- ✅ Defects Sentry par release

---

## Slide 5 — Leap-of-Faith Assumptions

### Leap-of-Faith Assumption (LF)
> *« The most risky elements of a startup's plan, the parts on which everything else depends. »* — Ries Ch4

Hypothèse **non prouvée**, **critique**, qui :
- Si fausse → force un **PIVOT** (pas une optimisation produit)
- Si vraie → l'entreprise est viable

Klaris a 3 LFs identifiés (cf. [leap-of-faith-assumptions.md](./leap-of-faith-assumptions.md)) :

### LF1 — Value Hypothesis
> *« Do customers find the product valuable enough to pay for it? »*

Hypothèse Klaris : « Un courtier solo paiera 100 CAD/mois si Klaris lui sauve 2-3h/jour d'admin. »

### LF2 — Growth Hypothesis
> *« How will new customers discover the product? »*

Hypothèse Klaris : « Le réseau referrals courtier ↔ courtier produit naturellement k ≥ 1. »

### LF3 — Compliance Hypothesis (spécifique Klaris)
Non-standard Ries — propre à notre secteur réglementé : « OACIQ acceptera notre approche audit log + reprise humaine. »

### Critère GO / NO-GO / AMBER
Pour chaque LF, on définit **avant** le test :
- **GO** = seuil franchi → persevere
- **NO-GO** = seuil raté → pivot
- **AMBER** = entre les deux → recalibrer + retester 1 mois

---

## Slide 6 — Innovation Accounting

### Innovation Accounting
> *« An accountability framework that enables startups to prove objectively that they are learning how to grow a sustainable business. »* — Ries Ch7 p.116

3 milestones successifs :

### 1. Establish the Baseline
Mettre en prod un MVP → mesurer **où on est réellement aujourd'hui**. Pas où on PENSE être. Souvent décevant. C'est le point.

Klaris : à M0 (mai 2026), baseline = N=1 pilote Joanel, MRR = 0. Cohort 2026-06 = vraie baseline.

### 2. Tune the Engine
Sprint après sprint, faire bouger les actionable metrics dans la bonne direction.

> *« A good design is one that changes customer behavior for the better. »* — Ries Ch7

Klaris : chaque feature Sprint 8+ aura une **fiche hypothèse** disant : *« Cette feature doit déplacer KVM X de Y à Z. »*

### 3. Pivot or Persevere
Si après plusieurs tunes, les metrics ne bougent pas → décision pivot. Si elles bougent dans le bon sens → persevere.

### KVM (Key Value Measure)
Métrique-clé d'une **KVA** (Key Value Area). Source : EBM Guide Scrum.org (cité Ries indirectement).
- KVA Current Value : Revenue per Employee, Product Cost Ratio, Employee Sat, Customer Sat (NPS)
- KVA Time-to-Market : Release Frequency, Release Stabilization, Cycle Time, On-Product Index
- KVA Ability to Innovate : Installed Version Index, Usage Index, Innovation Rate, Defects

Klaris track aujourd'hui : 2/12 (Release Frequency + Defects via Sentry). Cible Sprint 8 : 6/12.

---

## Slide 7 — Cohort Funnel

### Cohort
Groupe d'utilisateurs qui rejoignent le produit à la **même période** (ex. cohort 2026-06 = tous les courtiers inscrits en juin 2026).

> *« Instead of looking at cumulative totals, one looks at the performance of each group of customers that comes into contact with the product independently. »* — Ries Ch7 p.124

### Funnel Klaris (6 étapes)
1. **LEAD** = prospect courtier visite landing OU referral reçu
2. **SIGNUP** = compte broker créé + numéro Twilio assigné
3. **ACTIVATION** = 1er prospect SMS effectivement traité par Klaris (handover réel)
4. **ENGAGEMENT** = 5e prospect qualifié auto sur la cohort
5. **PAID** = conversion trial 14j → carte bancaire Stripe (100 CAD/mois)
6. **RETENTION M3** = toujours payant à 90 jours

### Conversion rate (par étape)
% de la cohort qui passe d'une étape à la suivante. Ex. : si 10 SIGNUP → 6 ACTIVATION = 60% conv.

### Lecture cohort (Ries IMVU example)
Si conversion rate s'**améliore** d'une cohort à l'autre → engine tune positif. Si stagnant → pivot.

---

## Slide 8 — Engines of Growth

### Engine of Growth
> *« The mechanism that startups use to achieve sustainable growth. »* — Ries Ch10

Ries identifie **3 engines** (chacun avec sa formule mathématique) :

### Engine Sticky (rétention)
- Mécanique : retention élevée → revenu récurrent
- KPI : Churn rate < Retention rate
- Klaris fit : **Primary** — abonnement adjointe IA
- Cible Klaris : Churn < 5%/mois, LTV = 100$ × 24 mois = 2 400$

### Engine Viral
- Mécanique : chaque user en amène k > 1 nouveau user
- KPI : **Viral coefficient k**
- Formule : `k = (nb invitations envoyées/courtier) × (taux conversion invitation → signup payant)`
- Si k > 1 : croissance auto-soutenue. Si k < 1 : extinction post-réseau initial.
- Klaris fit : **Secondary** — deck dit « 100% referrals » mais k pas mesuré
- Cible Klaris : k ≥ 1.0 sur 5 premiers payants (cf. [viral-coefficient-spec.md](./viral-coefficient-spec.md))

### Engine Paid
- Mécanique : acheter chaque user via marketing payant
- KPI : LTV / CAC ≥ 3
- Klaris fit : **Plan B** — Google Ads $1k/mois M9 si k < 1

### Anti-pattern (Ries Ch10)
> *« Don't mix engines simultaneously — you can't attribute growth to one or the other. »*

Klaris : on active Sticky + Viral d'abord. Paid uniquement si Viral fail à M9.

---

## Slide 9 — Types de MVP

### MVP (Minimum Viable Product)
> *« That version of a new product which allows a team to collect the maximum amount of validated learning about customers with the least effort. »* — Ries Ch6

**N'EST PAS** un prototype low-quality. **EST** le produit qui maximise apprentissage par dollar dépensé.

### Smoke Test MVP
Landing page + CTA achat AVANT de coder. Mesure intérêt préalable.
- **Klaris use** : `klarisapp.ai/agence` smoke test segment JP (cf. [smoke-test-jp.md](./mvp-personas/smoke-test-jp.md))
- **Avantage** : 0 code, 5 jours setup
- **Limite** : ne valide pas usage réel, juste l'intent

### Concierge MVP
Humain fait le travail manuellement. Apparaît automatique au client.
- **Klaris use** : Eliot + Joanel font analyse propriétés batch à la main pour Maxime (cf. [concierge-maxime.md](./mvp-personas/concierge-maxime.md))
- **Avantage** : valide value AVANT d'investir dans automatisation
- **Limite** : non scalable au-delà de quelques clients

### Wizard of Oz MVP
UI réelle côté client, automatisation **simulée** côté serveur.
- **Klaris use** : sync Matrix affichée à Charlyse, Eliot fait sync manuel derrière (cf. [wizard-of-oz-charlyse.md](./mvp-personas/wizard-of-oz-charlyse.md))
- **Avantage** : teste UX + value sans build l'engine
- **Limite** : épuisant humainement, max 5-10 users

### Single-Feature MVP
1 feature isolée, déployée vraiment.
- **Klaris use** : Sprint 1-7 = chatbot SMS qualification = single-feature MVP réel

### Landing Page MVP
Plusieurs landings testant value props différentes, comparer CTR.
- **Klaris use possible** : tester 3 taglines slide 04 (admin tueur · soirées famille · scale 3→10 transac)

### Promotional MVP
Pré-vente / pré-commande avec promesse de livraison future.
- **Klaris use possible** : tier « Klaris Lite » à 50 CAD/mois preorder pour bloquer entrant low-cost

---

## Slide 10 — Pivot or Persevere

### Pivot or Persevere Meeting
Cadence formelle (trimestrielle recommandée) où l'équipe **décide explicitement** :
- **Persevere** : on continue, on accélère
- **Pivot** : on change quelque chose de fondamental

> *« A startup that fails to do so will see its ideal recede ever further into the distance. »* — Ries Ch8

**Klaris** : cadence Q1 (M3 août 2026), Q2 (M6 nov 2026), Q3 (M9 fév 2027), Q4 (M12 mai 2027). Cf. [pivot-persevere/template.md](./pivot-persevere/template.md).

### 10 Types de Pivots (Ries Ch8)

1. **Zoom-in pivot** — une feature devient le produit complet (ex. Flickr photo upload était une feature d'un jeu)
2. **Zoom-out pivot** — le produit devient une feature dans un plus grand produit
3. **Customer segment pivot** — même produit, différent segment client (ex. Klaris solo → agence)
4. **Customer need pivot** — même client, autre besoin (ex. Klaris SMS → génération offres d'achat)
5. **Platform pivot** — app → platform/API ou vice versa
6. **Business architecture pivot** — B2B ↔ B2C
7. **Value capture pivot** — changement monétisation (abonnement → transactionnel)
8. **Engine of growth pivot** — sticky → viral → paid
9. **Channel pivot** — distribution différente (referrals → partenariat OACIQ)
10. **Technology pivot** — même produit, autre stack (Klaris IA générative → recommandations courtier-validées)

### Règle de décision Klaris

| Status leap-of-faith | Décision |
|-----------------------|----------|
| 3/3 GO | Persevere full |
| 2/3 GO + 1 AMBER | Persevere avec mitigations |
| 2/3 GO + 1 NO-GO | Pivot ciblé |
| 1/3 GO ou moins | Pivot stratégique global |

---

## Slide 12 — Small Batches & Continuous Deployment

### Batch Size
Taille du « lot » de travail livré à la fois. **Plus petit = mieux**, contre-intuitif.

> *« Small batches mean faster feedback loops. The Toyota Production System works on this principle. »* — Ries Ch9 p.184

**Exemple Ries (Ch9)** : enveloppes à plier. Lot de 100 enveloppes pliées d'abord, puis 100 mises sous enveloppe = lent. Lot de 1 (plier + mettre + sceller chaque enveloppe avant la suivante) = plus rapide ET on détecte les erreurs plus vite.

### Continuous Deployment (CD)
Déployer le code en prod **plusieurs fois par jour**, automatiquement après tests CI verts.

- **IMVU (Ries)** : déployait jusqu'à 50× par jour
- **Klaris cible Sprint 9+** : commit → CI → Vercel preview → Supabase migration check → iOS TestFlight nightly

### CI (Continuous Integration)
Pipeline automatique qui à chaque commit :
1. Run tests
2. Build le projet
3. Bloque le merge si rouge

Klaris stack : GitHub Actions + Vercel + Supabase + Fastlane (iOS).

### Sprint hebdomadaire
Klaris bascule de 4 semaines → 1 semaine. Cf. [sprint-cadence-1week.md](./sprint-cadence-1week.md).

**Cérémonies** :
- LUN 9h : Sprint Planning (30 min)
- MAR-VEN : Daily async Slack (5 min/personne)
- MER 14h : Sync technique (15 min)
- VEN 16h : Sprint Review + démo (30 min)
- VEN 16h30 : Sprint Retro (20 min)
- VEN 17h : Happiness Index check (5 min)

---

## Slide 13 — 5 Whys

### 5 Whys
Méthode Toyota Production System (citée Ries Ch11) pour trouver la **cause racine** d'un problème, pas juste le symptôme.

> *« At the root of every seemingly technical problem is actually a human problem. »* — Ries Ch11

**Méthode** : pour chaque incident, poser **5 fois la question "pourquoi ?"**. Chaque "pourquoi" creuse plus profond. La 5e réponse est souvent une cause **humaine/processus** (pas technique).

### Exemple Klaris (slide 13)

1. Pourquoi le SMS n'est pas parti ?
   → Twilio API a renvoyé 429 rate limit.
2. Pourquoi le rate limit ?
   → n8n a déclenché 200 SMS en 1 sec à minuit.
3. Pourquoi 200 d'un coup ?
   → Cron sans backoff/spread temporel.
4. Pourquoi pas de backoff ?
   → Spec Sprint 2 jamais reconsidérée depuis 6 mois.
5. Pourquoi jamais reconsidérée ?
   → **Pas de processus de revue post-incident. CAUSE HUMAINE.**

### Action humaine
Pour le 5e why, l'action corrective doit être un **changement de processus/comportement humain**, pas juste un hotfix code.

Klaris : canal Slack `#klaris-incidents` + rotation on-call hebdomadaire 4 fondateurs + retro mensuelle incidents. Cf. [incidents/template.md](./incidents/template.md).

---

## Concepts complémentaires (Christensen — Innovator's Dilemma)

Pour comprendre les **dilemmes** auxquels Klaris fait face en tant que disrupteur (cf. [innovators-dilemma-challenge.md](./innovators-dilemma-challenge.md)) :

### Sustaining Technology
Innovation qui **améliore** un produit existant le long des dimensions que les clients mainstream valorisent déjà. Exemples : faire un Klaris plus rapide, plus précis, plus de features.

**Risque** : finir par sur-servir le client (over-shoot) → ouverture pour un entrant low-cost qui disrupte par le bas.

### Disruptive Technology
Innovation qui **sous-performe** sur les dimensions mainstream MAIS apporte de nouvelles dimensions (moins cher, plus simple, plus accessible).

**Exemples historiques** : transistors (vs vacuum tubes), Wal-Mart (vs department stores), Klaris (vs CRM franchise + adjointe humaine).

### Low-end Disruption
Disrupter par le bas du marché. Sert d'abord les clients **les moins profitables**, ignorés par les incumbents.

**Klaris aujourd'hui** = low-end disruption. Joanel (solo) = client qu'aucun gros CRM ne sert correctement.

### New-Market Disruption
Disrupter en créant un marché qui n'existait pas. Clients qui n'achetaient rien avant deviennent customers.

**Klaris potentiel** : agent IA fully autonomous pour FSBO (For Sale By Owner) — clients qui n'auraient jamais payé un courtier traditionnel.

---

## Concepts complémentaires (McGreal/Jocham — Professional Product Owner)

### 3 Vs (Vision · Value · Validation)
Boussole du Product Owner :
- **Vision** : où on va. Cible « Focused + Practical + Emotional + Pervasive ».
- **Value** : producer benefit (money) vs customer happiness (smile)
- **Validation** : preuve empirique que la value est livrée

### EBM (Evidence-Based Management)
Framework Scrum.org. 3 Key Value Areas (KVAs) : Current Value, Time-to-Market, Ability to Innovate. Chacune a 3-4 KVMs (Key Value Measures).

### Negative Value
Valeur **détruite** par le produit. 2 types :
- **Visible** : bug évident, courtier voit
- **Invisible** : ex. atrophie compétence relationnelle courtier qui dépend trop de l'IA

### Cynefin
Framework Dave Snowden pour catégoriser problèmes :
- **Obvious** : best practice (cooking)
- **Complicated** : good practice (build a house)
- **Complex** : emergent practice (build an airport) ← **Klaris est ici**
- **Chaos** : novel practice (disaster)

---

## Index alphabétique

| Terme | Slide | Section |
|-------|-------|---------|
| Actionable Metrics | 4 | [Vanity vs Actionable](#slide-4--validated-learning--vanity-vs-actionable) |
| Activation (funnel) | 7 | [Funnel Klaris](#funnel-klaris-6-%C3%A9tapes) |
| AMBER (critère) | 5 | [Critère GO/NO-GO/AMBER](#crit%C3%A8re-go--no-go--amber) |
| Anti-pattern engines | 8 | [Engines of Growth](#anti-pattern-ries-ch10) |
| Batch Size | 12 | [Small Batches](#batch-size) |
| Baseline (Innovation Accounting) | 6 | [1. Establish the Baseline](#1-establish-the-baseline) |
| Build-Measure-Learn loop | 3 | [BML](#build-measure-learn-loop) |
| CAC (Customer Acquisition Cost) | 8 | [Engine Paid](#engine-paid) |
| Channel pivot | 10 | [10 Types de Pivots](#10-types-de-pivots-ries-ch8) |
| Cohort | 7 | [Cohort Funnel](#cohort) |
| Compliance Hypothesis (LF3) | 5 | [LF3](#lf3--compliance-hypothesis-sp%C3%A9cifique-klaris) |
| Concierge MVP | 9 | [Types de MVP](#concierge-mvp) |
| Continuous Deployment (CD) | 12 | [CD](#continuous-deployment-cd) |
| Conversion rate | 7 | [Cohort Funnel](#conversion-rate-par-%C3%A9tape) |
| Cost-to-Build vs Cost-to-Run | 2 | [Contexte](#cost-to-run-vs-cost-to-build) |
| Customer need pivot | 10 | [10 Types de Pivots](#10-types-de-pivots-ries-ch8) |
| Customer segment pivot | 10 | [10 Types de Pivots](#10-types-de-pivots-ries-ch8) |
| Cynefin | bonus | [Concepts McGreal/Jocham](#cynefin) |
| Defects (KVM) | 6 | [KVM](#kvm-key-value-measure) |
| Disruptive Technology | bonus | [Christensen](#disruptive-technology) |
| EBM (Evidence-Based Mgmt) | bonus | [McGreal/Jocham](#ebm-evidence-based-management) |
| Engagement (funnel) | 7 | [Funnel Klaris](#funnel-klaris-6-%C3%A9tapes) |
| Engine of Growth | 8 | [Engines](#engine-of-growth) |
| Engine Paid | 8 | [Engine Paid](#engine-paid) |
| Engine Sticky | 8 | [Engine Sticky](#engine-sticky-r%C3%A9tention) |
| Engine Viral | 8 | [Engine Viral](#engine-viral) |
| Establish Baseline | 6 | [Innovation Accounting](#1-establish-the-baseline) |
| 5 Whys | 13 | [5 Whys](#5-whys) |
| GO (critère) | 5 | [Critère GO/NO-GO/AMBER](#crit%C3%A8re-go--no-go--amber) |
| Growth Hypothesis (LF2) | 5 | [LF2](#lf2--growth-hypothesis) |
| Happiness Index | 12 | [Sprint hebdomadaire](#sprint-hebdomadaire) |
| Hockey Stick (vanity) | 4 | [Vanity Metrics](#vanity-metrics-%C3%A0-bannir-de-nos-board-meetings) |
| Hypothèse (testable) | 3 | [Hypothèse](#hypoth%C3%A8se-testable) |
| Innovation Accounting | 6 | [Innovation Accounting](#innovation-accounting) |
| Innovator's Dilemma | bonus | [Christensen](#concepts-compl%C3%A9mentaires-christensen--innovators-dilemma) |
| KVA (Key Value Area) | 6 | [KVM](#kvm-key-value-measure) |
| KVM (Key Value Measure) | 6 | [KVM](#kvm-key-value-measure) |
| Landing Page MVP | 9 | [Types de MVP](#landing-page-mvp) |
| LEAD (funnel) | 7 | [Funnel Klaris](#funnel-klaris-6-%C3%A9tapes) |
| Leap-of-Faith Assumption (LF) | 5 | [LF](#leap-of-faith-assumption-lf) |
| LF1 — Value | 5 | [LF1](#lf1--value-hypothesis) |
| LF2 — Growth | 5 | [LF2](#lf2--growth-hypothesis) |
| LF3 — Compliance | 5 | [LF3](#lf3--compliance-hypothesis-sp%C3%A9cifique-klaris) |
| Low-end Disruption | bonus | [Christensen](#low-end-disruption) |
| LTV (Lifetime Value) | 8 | [Engine Paid](#engine-paid) |
| MVP (Minimum Viable Product) | 9 | [MVP](#mvp-minimum-viable-product) |
| Negative Value | bonus | [McGreal/Jocham](#negative-value) |
| New-Market Disruption | bonus | [Christensen](#new-market-disruption) |
| NO-GO (critère) | 5 | [Critère GO/NO-GO/AMBER](#crit%C3%A8re-go--no-go--amber) |
| NPS (Net Promoter Score) | 4 | [Actionable Metrics](#actionable-metrics-%C3%A0-publier-dans-rapports-mensuels) |
| On-Product Index | 6 | [KVM](#kvm-key-value-measure) |
| PAID (funnel) | 7 | [Funnel Klaris](#funnel-klaris-6-%C3%A9tapes) |
| Persevere | 10 | [Pivot or Persevere](#pivot-or-persevere-meeting) |
| Pivot | 10 | [Pivot or Persevere](#pivot-or-persevere-meeting) |
| Pivot or Persevere Meeting | 10 | [Pivot or Persevere](#pivot-or-persevere-meeting) |
| Platform pivot | 10 | [10 Types de Pivots](#10-types-de-pivots-ries-ch8) |
| Promotional MVP | 9 | [Types de MVP](#promotional-mvp) |
| Retention M3 (funnel) | 7 | [Funnel Klaris](#funnel-klaris-6-%C3%A9tapes) |
| Single-Feature MVP | 9 | [Types de MVP](#single-feature-mvp) |
| SIGNUP (funnel) | 7 | [Funnel Klaris](#funnel-klaris-6-%C3%A9tapes) |
| Small Batches | 12 | [Batch Size](#batch-size) |
| Smoke Test MVP | 9 | [Types de MVP](#smoke-test-mvp) |
| Sprint hebdomadaire | 12 | [Sprint](#sprint-hebdomadaire) |
| Sustaining Technology | bonus | [Christensen](#sustaining-technology) |
| Technology pivot | 10 | [10 Types de Pivots](#10-types-de-pivots-ries-ch8) |
| 3 Vs (Vision/Value/Validation) | bonus | [McGreal/Jocham](#3-vs-vision--value--validation) |
| Tune the Engine | 6 | [2. Tune the Engine](#2-tune-the-engine) |
| Validated Learning | 4 | [Validated Learning](#validated-learning) |
| Value Hypothesis (LF1) | 5 | [LF1](#lf1--value-hypothesis) |
| Vanity Metrics | 4 | [Vanity Metrics](#vanity-metrics-%C3%A0-bannir-de-nos-board-meetings) |
| Viral coefficient k | 8 | [Engine Viral](#engine-viral) |
| Wizard of Oz MVP | 9 | [Types de MVP](#wizard-of-oz-mvp) |
| Zoom-in pivot | 10 | [10 Types de Pivots](#10-types-de-pivots-ries-ch8) |
| Zoom-out pivot | 10 | [10 Types de Pivots](#10-types-de-pivots-ries-ch8) |

---

## Lectures recommandées

### Avant la présentation
- 📕 *The Lean Startup* — Eric Ries (2011) — **lire au moins Ch3 Learn, Ch6 Test, Ch7 Measure, Ch8 Pivot**.
  - Si pas de temps : lire l'Introduction (15 pages) + Ch7 (cohort + IMVU example).

### Après la présentation
- 📕 *The Professional Product Owner* — McGreal/Jocham (2018) — pour 3 Vs + EBM
- 📕 *The Innovator's Dilemma* — Christensen (1997) — pour comprendre nos 5 dilemmes
- 📕 *Crossing the Chasm* — Geoffrey Moore — pour le moment où Klaris passera de early adopters (Joanel) à early majority

### Liens externes
- Eric Ries blog : [startuplessonslearned.com](http://www.startuplessonslearned.com/)
- IMVU case study (Ch3 source) : voir bibliographie du livre Ries
- Christensen disruptive innovation : [hbr.org/2015/12/what-is-disruptive-innovation](https://hbr.org/2015/12/what-is-disruptive-innovation)

---

## FAQ équipe (anticipé)

**Q : C'est obligatoire de lire tout ça avant la présentation ?**
R : Non. Ce doc est une **référence**. Tu peux la consulter pendant le pitch ou après pour creuser un concept précis.

**Q : Pourquoi tellement de citations Ries ?**
R : Parce que ses formulations sont précises et débattues depuis 15 ans. Réinventer le vocabulaire = perdre temps + créer ambiguïté.

**Q : Le Lean Startup est-il une religion ?**
R : Non. C'est un set d'outils. On l'adopte parce qu'il **adresse spécifiquement** notre situation (extreme uncertainty, complex domain Cynefin, segments multiples). Ne pas l'adopter = continuer à ship features que personne ne mesure.

**Q : Combien de temps avant que cette discipline porte ses fruits ?**
R : Premier signal M3 (cohort 2026-06 vs Joanel baseline). Décision Pivot/Persevere ferme M6.

**Q : Et si Joanel n'aime pas qu'on parle de Pivot ?**
R : Joanel reste le segment #1 pour 12 mois minimum. Pivot ne signifie PAS abandonner Joanel — ça peut signifier ajouter un segment, changer pricing, ou changer canal d'acquisition. Cf. les 10 types de pivots.

---

*Document v1.0 — 2026-05-11 — basé sur* The Lean Startup *— Eric Ries, Crown Business 2011 (ISBN 978-0-307-88791-7) · accompagne le deck [Klaris_Strategie_Lean_FR.pptx](../clea-brand/pitch-deck/Klaris_Strategie_Lean_FR.pptx)*

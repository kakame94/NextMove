# Klaris — Innovator's Dilemma Challenge

> **But.** Identifier les dilemmes de disruption que Klaris **affronte aujourd'hui** ou **affrontera demain**, à la lumière de *The Innovator's Dilemma — When New Technologies Cause Great Firms to Fail* (Clayton M. Christensen, Harvard Business School Press, 1997).
> **Documents liés.** [business-canvas-challenge.md](./business-canvas-challenge.md) · [lean-startup-challenge.md](./lean-startup-challenge.md) · [leap-of-faith-assumptions.md](./leap-of-faith-assumptions.md) · [architecture-challenge.md](./architecture-challenge.md)
> Date : 2026-05-11

---

## TL;DR — Position Klaris sur le diagramme de Christensen

> **Klaris est aujourd'hui un disrupteur par le bas** (low-end disruption) : produit moins cher (100 CAD vs 2 500 CAD assistante humaine, ou 0 CAD CRM franchise sous-utilisé), plus simple, ciblant les courtiers solo que les incumbents ignorent (Salesforce/HubSpot trop chers, Matrix/Centris trop génériques).
> **Mais 5 dilemmes de Christensen vont nous frapper d'ici 12-24 mois.** L'enjeu : reconnaître que les bonnes pratiques d'aujourd'hui (écouter Joanel, livrer ce qu'il demande, augmenter MRR) seront exactement celles qui nous feront rater la prochaine disruption.

| Quand on est frappé ? | Dilemme |
|------------------------|---------|
| Aujourd'hui | D1 — Customer dependence : Joanel demande sustaining features (offre d'achat auto, signature) |
| M6-M9 | D2 — Small markets : marché QC paraît trop petit, tentation de freiner |
| M9-M12 | D3 — Markets that don't exist : pression investisseurs vs discovery planning |
| M12-M18 | D4 — Capabilities = disabilities : passer du segment solo au segment agence |
| M18-M24 | D5 — Tech supply overshoots demand : sur-investir Sonnet vs concurrent low-cost Haiku |

---

## 1 — Position actuelle de Klaris sur le diagramme

```
                     ↑ Performance (qualification, fiabilité, conformité)
                     │
   SUSTAINING ZONE   │  ←  Salesforce, HubSpot CRM
   (incumbents)      │  ←  Matrix, Centris franchise CRMs
                     │  ←  Royal LePage CRM internal
                     │  ─────  overshoot mainstream needs
                     │
   ─────────────── Performance demanded by mainstream broker ──
                     │
                     │  ●  Klaris (today)  ←  "good enough" SMS qualif
                     │     improving fast (Sprint 7→14)
                     │
                     │
   ───────────── Performance demanded by low-end solo broker ──
                     │
   FUTURE DISRUPTOR  │  ●  Agent IA fully autonomous (FSBO/locations)
                     │     pas encore commercialisé
                     │
                     └──────────────────────────────────────→ Time
                        2026               2027                2028
```

**Lecture (Christensen Ch1-2) :**
- Klaris est entré par le bas — courtier solo Joanel a un besoin que personne ne sert correctement.
- Klaris underperforme sur certains axes vs CRM franchise (pas de RBAC multi-courtiers, pas d'analytics direction) — c'est OK.
- Mais Klaris s'améliore vite. Trajectoire d'amélioration **doit** être plus rapide que la trajectoire de demande mainstream pour gagner.

---

## 2 — Cadre théorique Christensen — 5 principes

| Principe | Concept | Pourquoi ça nous concerne |
|----------|---------|---------------------------|
| #1 | Companies depend on customers and investors for resources | Joanel = "customer roi" → ses demandes biaisent investissement |
| #2 | Small markets don't solve growth needs of large companies | Quand Klaris aura 555 courtiers QC, l'expansion paraîtra "trop petite" |
| #3 | Markets that don't exist can't be analyzed | Discovery-based planning vs pression forecast investisseurs |
| #4 | Organization's capabilities define its disabilities | Process+values optimisés pour solo deviendront disabilities en agence |
| #5 | Technology supply may not equal market demand | Trajectoire Claude/IA progresse 10×/an, demande courtier reste stable |

**Citation clé (Ch1) :**
> *« Precisely because these firms listened to their customers, invested aggressively in new technologies that would provide their customers more and better products of the sort they wanted, and because they carefully studied market trends and systematically allocated investment capital to innovations that promised the best returns, they lost their positions of leadership. »*

Les "bonnes pratiques" tuent les leaders.

---

## 3 — Les 5 dilemmes Klaris

### D1 — Le dilemme Joanel (Principle #1 — Customer Dependence)

**Situation.**
Joanel = pilote roi + voix forte. Va demander sustaining features :
- Génération d'offre d'achat auto-signée
- Intégration DocuSign
- Dashboard analytics fancy
- Tagging prospects multi-critères

Tous **rentables** (Joanel paiera plus pour ça). Mais...

**Dilemme.**
- **Voie sustaining** : implémenter ces demandes → marge +20% sur Joanel et ses pairs.
- **Voie disruptive** : investir 30% du temps dans la **next disruptive technology** (agent IA fully autonomous pour FSBO/locations/micro-transactions).

**Risque.**
Si Klaris devient « le meilleur outil pour le courtier solo bien établi » → on rate la disruption suivante : courtier qui n'a même plus besoin de Klaris parce que l'agent IA gère seul des micro-transactions (location, FSBO).

**Réponse Christensen (Ch5 — Principle #1) :**
> *« Set up an autonomous organization charged with building a new and independent business around the disruptive technology. »*

**Action Klaris.**
- 70% du temps équipe = sustaining (servir Joanel + premiers payants)
- **30% du temps réservé** = explorer agent IA autonomous (équipe "skunk works" interne : 1 fondateur dédié 1 jour/sem)
- Backlog Linear avec label `disruptive-bet` séparé du backlog principal

---

### D2 — Le dilemme expansion (Principle #2 — Small Markets)

**Situation.**
- TAM Quebec = ~17 000 courtiers OACIQ. 3% pénétration = 555 courtiers = ~84k MRR. Plafonné.
- Pour scaler à 5 M$ ARR, doit attaquer marché plus grand : France (35 000 agents) ? Ontario (~80 000) ? US (~2 M) ?
- Mais chaque nouveau marché commence à **0 courtier** = trop petit pour intéresser une équipe de 12 personnes (à M18).

**Dilemme.**
- **Voie sustaining** : optimiser QC à fond (atteindre 1 500 courtiers, $1.8M MRR). Marché "vraiment notre fief".
- **Voie disruptive** : lancer Ontario M15 avec 1 fondateur dédié, marché 0→50 courtiers en 6 mois (= "trop petit" mais c'est le seul moyen d'apprendre).

**Risque.**
Klaris atteint plafond QC à M24 (550 courtiers, $66k MRR), aucune expansion engagée, valorisation chute. RE/MAX Canada lance leur IA SMS en Ontario en M27 = Klaris arrive 2 ans trop tard.

**Réponse Christensen (Ch6) :**
> *« Large companies cannot focus adequate energy and talent on small markets. Give responsibility to commercialize the disruptive technology to an organization whose size matched the size of the targeted market. »*

**Action Klaris.**
- M9 : commencer recherche marché Ontario (analogue Joanel — interviews 4 courtiers de Toronto/Ottawa)
- M12 : Smoke test landing `klarisapp.ai/ontario` (cf. méthode L4c)
- M15 : si signal → 1 fondateur (probablement Walkens) dédié 100% Ontario expansion
- Garder équipe Ontario petite intentionnellement (1-2 personnes max les 12 premiers mois)

---

### D3 — Le dilemme forecast vs discovery (Principle #3 — Markets That Don't Exist)

**Situation.**
- À M9, Klaris aura probablement 30-50 courtiers payants → seed round potentiel ($500k-1M).
- Investisseurs demandent : « Quel MRR à 24 mois ? Quel CAC ? Quel TAM ? »
- Pression forte pour produire forecasts précis = approche **sustaining** mindset.

**Dilemme.**
- **Voie sustaining** (investisseur-friendly) : Excel projection MRR croissance 15%/mois, TAM bottom-up précis, CAC mesuré par canal payant.
- **Voie disruptive** (Christensen Ch7 discovery-based planning) : « les prévisions sont fausses par défaut ; on apprend en testant ; budget incrémental par milestone d'apprentissage validé ».

**Risque.**
Si Klaris pitche un forecast inventé à des VCs et lève sur cette base → pression trimestrielle pour hitter le forecast → tentation d'inventer des courtiers, gonfler MRR, repousser pivot. Cf. WeWork/Theranos.

**Réponse Christensen (Ch7) :**
> *« Forecasts for the magnitude of emerging markets are inevitably wrong. The only thing we may know for sure when we read experts' forecasts about how large emerging markets will become is that they are wrong. »*

**Action Klaris.**
- Si fundraising M9 : pitcher « discovery-based plan » au lieu de forecast forcé. Demander **tranche-based funding** ($250k pour 6 milestones).
- Privilégier investisseurs **revenue-based financing** (Pipe.com, Capchase) sur equity classique → moins de pression forecast.
- Si VC traditionnel insiste sur forecast → présenter 3 scénarios (conservative/nominal/optimist) avec **ranges**, pas chiffres précis.

---

### D4 — Le dilemme solo → agence (Principle #4 — Capabilities Define Disabilities)

**Situation.**
Klaris aujourd'hui (Sprint 7-12) :
- **Process** : sprint 1 semaine, deploy continu, support direct WhatsApp avec Joanel
- **Values** : "ship vite, parle au courtier, simplicité d'abord"
- **Cost structure** : ~735 CAD/mois (Cost-to-Run), 91.5% marge brute

Quand Klaris voudra attaquer JP (agence 99 courtiers) :
- **Process attendu** : RFP réponse, sales cycle 3-6 mois, SOC 2, MSA contract, dedicated success manager
- **Values attendues** : "réliabilité d'abord, change management, SLA documenté"
- **Cost structure** : ~5 000 CAD/mois minimum (sales, support, légal, customer success)

**Dilemme.**
- **Voie sustaining** : Klaris essaie de servir JP avec son équipe actuelle de 4 fondateurs → réussit pas (process+values inadéquats) ET dégrade le service à Joanel (équipe distraite).
- **Voie disruptive** : créer une **filiale ou business unit séparée** (« Klaris Agence ») avec ses propres process, values, équipe, coût.

**Risque.**
Si Klaris essaie de servir solo + agence avec la même équipe et le même produit, finit par servir les deux mal. Cf. DEC ratant le PC.

**Réponse Christensen (Ch8) :**
> *« Processes and values are not flexible. A process that is effective at managing the design of a minicomputer would be ineffective at managing the design of a desktop PC. »*

**Action Klaris.**
- Q3 2026 : décider explicitement si Klaris veut chasser agence (segment #4 JP). Si oui, **séparer le P&L** dès le début.
- Sales agence = différent humain (probablement embauche externe avec background franchise), pas un fondateur tech.
- Roadmap agence = différent backlog (RBAC, audit log enhanced, dashboard direction) versionné séparément du backlog solo.
- À ~30 courtiers agence : créer entité légale séparée (« Klaris Agence Inc. ») détenue par Next Move Inc.

---

### D5 — Le dilemme over-engineering IA (Principle #5 — Technology Supply Overshoots Demand)

**Situation.**
- Claude Haiku/Sonnet/Opus progressent ~10×/an en capacités IA.
- Klaris pourrait dépenser pour avoir le « best AI » : multi-agent orchestration, RAG fine-tuné, vision API, voice cloning, etc.
- Mais courtier QC demande quoi ? Réponse 60 sec, ton naturel, signature « son assistante ». **Pas de l'AGI**.

**Dilemme.**
- **Voie sustaining** : adopter chaque nouveau modèle IA = features impressionnantes pour le deck investisseurs. Augmente coût variable Anthropic +200% sur 12 mois.
- **Voie disruptive** : rester sur Haiku 80% des cas (10× moins cher), n'utiliser Sonnet/Opus que sur 20% high-value (résumés finaux, génération d'offre).

**Risque.**
1. Un concurrent arrive avec « Klarus » à 30 CAD/mois, IA "good enough" via Llama free-tier auto-hébergé. Capture les courtiers qui trouvent Klaris « trop sophistiqué pour rien ».
2. Klaris devient comme Salesforce : trop de features, courtier perdu, NPS chute, churn monte.

**Réponse Christensen (Ch9) :**
> *« In their efforts to stay ahead by developing competitively superior products, many companies don't realize the speed at which they are moving up-market, over-satisfying the needs of their original customers as they race the competition toward higher-performance, higher-margin markets. »*

**Action Klaris.**
- KPI Sprint 9+ : **% conversations qualifiées avec Haiku seul** (vs Sonnet). Cible ≥ 80%.
- Décision feature IA = test utilisateur **avant** dev. Si Joanel n'arrive pas à expliquer ce que la feature lui apporte → kill.
- Veille concurrence trimestrielle : qui arrive **par le bas** ? (Llama, Mistral free, open-source SMS agents).
- Pricing test M9 : tier « Klaris Lite » à 50 CAD/mois (Haiku only, features réduites) pour bloquer entrants disruptifs.

---

## 4 — Le grand dilemme : disrupteur **ou** disrupté ?

À ce stade, Klaris est dans une **fenêtre de 18-24 mois** où :

1. Klaris **est** le disrupteur (vs CRM franchise + assistante humaine)
2. Klaris **peut** devenir disrupté par :
   - Un concurrent low-cost (Klaris Lite alternative)
   - Royal LePage / RE/MAX qui buildent leur propre IA SMS (incumbents qui se réveillent)
   - Un agent IA fully autonomous qui rend Klaris (et le courtier !) obsolète sur certaines transactions (FSBO/locations)

**Citation Ch10 (electric vehicle case) :**
> *« Companies must simultaneously do what is right for the near-term health of their established businesses, while focusing adequate resources on the disruptive technologies that ultimately could lead to their downfall. »*

**Stratégie Klaris recommandée (cohérente avec Lean Startup challenge) :**

| Horizon | Focus | % temps équipe |
|---------|-------|-----------------|
| Sprint 8-12 (M0-M3) | Sustaining Joanel + premières cohorts | 100% |
| Q1-Q2 2027 (M9-M12) | Sustaining 70% · Discovery Ontario+Agence 30% | 70% / 30% |
| Q3 2027 (M15+) | Sustaining 50% · Agent IA autonomous bet 30% · Géographie 20% | 50% / 30% / 20% |
| Q1 2028 (M24+) | Décision majeure : devenir le nouvel incumbent vertical OU pivot vers next disruption | TBD selon learning |

---

## 5 — Anti-patterns Christensen à éviter

| Anti-pattern | Citation Ch | Risque Klaris |
|--------------|-------------|----------------|
| Écouter exclusivement Joanel | Ch5 P#1 | Optimisations qui plafonnent Klaris au courtier solo établi |
| Attendre que le marché agence soit « assez grand » | Ch6 P#2 | RE/MAX/Royal LePage capturent le marché agence pendant qu'on hésite |
| Demander forecast précis avant d'investir | Ch7 P#3 | Paralysie analyse, pivot raté |
| Servir solo + agence avec même équipe | Ch8 P#4 | Service dégradé des deux côtés |
| Adopter chaque nouveau modèle IA "parce qu'il existe" | Ch9 P#5 | Sur-prix, perte d'agilité, vacuum bas pour entrant low-cost |
| Considérer Klaris « trop petit » pour mériter de pivoter | Ch6 P#2 | Inertie organisationnelle = ratage de la prochaine vague |
| Refuser de cannibaliser Klaris-solo avec Klaris-autonomous | Ch1 intro | Si on ne se cannibalise pas, un concurrent le fera |

---

## 6 — Sustaining vs Disruptive — feature audit

Pour chaque feature backlog Sprint 8-14, classer :

| Feature | Sustaining ou Disruptive ? | Logique |
|---------|----------------------------|---------|
| NPS in-app | Sustaining | Améliore mesure existante, pas nouveau marché |
| Génération offre d'achat auto | Sustaining | Demande Joanel + Maxime, sert segment actuel |
| Sync Centris MLS | Sustaining | Intégration incumbents = move up-market |
| Wizard of Oz Charlyse | Sustaining | Étend dans segment existant (solo bilingue perfectionniste) |
| Smoke test JP /agence | **Disruptive** (segment shift) | Nouveau segment B2B vs B2C solo |
| Apple Watch | Neutre (cool factor, kill recommandé) | Ni sustaining ni disruptive |
| **Agent IA autonomous (FSBO/locations)** | **DISRUPTIVE** | Nouveau marché, sous-performe sur certaines dimensions mais accessible à un autre segment (vendeur particulier sans courtier) |
| **Klaris Ontario** | **DISRUPTIVE** (géo) | Marché plus petit que QC au début mais potentiel 5× |
| **Klaris Lite 50 CAD/mois** | **DEFENSIVE DISRUPTION** | Pour bloquer un entrant low-cost qui pourrait disrupter Klaris |

**Règle de la 30/70 :**
- **70% effort** = sustaining backlog (servir cohorts existantes)
- **30% effort** = disruptive bets (au moins **un** bet actif en permanence dès Sprint 12)

---

## 7 — Plan d'action — 5 corrections Christensen (Sprints 8-24)

| # | Action | Dilemme adressé | Sprint cible |
|---|--------|------------------|--------------|
| C1 | Backlog Linear avec label `disruptive-bet` séparé (30% capacity réservée) | D1 | Sprint 9 |
| C2 | Smoke test géographique Ontario (méthode L4c) | D2 | Sprint 15 |
| C3 | Si fundraising M9 : pitch discovery-based plan + tranche-based funding | D3 | M9 |
| C4 | Si pursuit agence JP → P&L séparé + recrutement externe + entité légale | D4 | M12 si signal |
| C5 | KPI Haiku coverage ≥ 80% + tier « Klaris Lite » 50 CAD/mois (defensive) | D5 | Sprint 11 |

---

## 8 — Tableau de bord trimestriel — dilemmes

À revoir lors de chaque **Pivot or Persevere** (cf. [pivot-persevere/template.md](./pivot-persevere/template.md)) :

| Dilemme | Indicateur de vigilance | Seuil alerte |
|---------|--------------------------|--------------|
| D1 Customer dependence | % temps Sprint sur features sustaining vs disruptive | > 80% sustaining sur 2 trimestres consécutifs |
| D2 Small markets | Nb fondateurs travaillant sur expansion géo | 0 fondateur dédié à M12 |
| D3 Forecast pressure | Présence d'un forecast MRR engagé contractuellement | OUI = risque drift sustaining |
| D4 Capabilities/disabilities | Nb agences en pipeline avec sales cycle > 3 mois | > 3 → décider P&L séparé |
| D5 Tech overshoot | Coût Anthropic par courtier/mois | > 5 CAD = signal overshoot |
| (transversal) | Entrant low-cost concurrent surveillé ? | Aucun nom watché = aveuglement |

---

## 9 — Suivi

- [ ] Q1 (M3) : 1ère revue dilemmes dans Pivot/Persevere meeting
- [ ] Sprint 9 : créer label `disruptive-bet` Linear + capacity 30% réservée
- [ ] Sprint 11 : KPI Haiku coverage + tier Klaris Lite design
- [ ] M9 : si fundraising → préparer pitch discovery-based
- [ ] M12 : décision agence → P&L séparé ou kill segment JP
- [ ] M15 : smoke test Ontario
- [ ] M18 : check dilemme overshooting (NPS Klaris vs simplicité ?)

---

*Document v1.0 — 2026-05-11 — basé sur* The Innovator's Dilemma — When New Technologies Cause Great Firms to Fail *— Clayton M. Christensen, Harvard Business School Press 1997 (ISBN 0-87584-585-1)*

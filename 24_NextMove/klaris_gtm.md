# Klaris — Go-To-Market

> **Statut** : v1.0 · Q3 2026 · Source de vérité interne
> **Audience** : Dennis · Eliot · Walkens · Seydou
> **Cadence** : sync hebdo lundi 10h · revue trimestrielle
> **Source données** : Étude de marché v3 §4 + §7 + apprentissages terrain

---

## 1. Cadre stratégique

> **6 décisions binaires déjà prises. Ne pas re-débattre chaque semaine.**

| Axe | Décision | Note |
|---|---|---|
| Financement | **Bootstrap** | Pas de levée avant M18 + PMF prouvé |
| Géo Phase 1 | **RMR Montréal** | Laval + Rive-Sud + Rive-Nord · M1-M12 |
| ICP prioritaire | **Solo bilingue** | 2-7 ans expérience · 100-500 K$ GCI · 12-15+ tx/an |
| Positionnement | **Action Layer** | Pas CRM · interface FUB/Centiva via API |
| Killer message | **« Klaris agit »** | « Votre CRM stocke passivement » |
| Jalon M12 | **100 clients · 150 K$ ARR** | NRR > 100 % · churn < 3 %/mois |

---

## 2. Persona prioritaire

### Archetype « Joanel »

> Courtier indépendant · RMR Montréal · bilingue FR/EN

| Champ | Valeur |
|---|---|
| Expérience | 2-7 ans actif · OACIQ à jour |
| Volume | 12-15+ transactions/an |
| GCI | 100 K$ - 500 K$ · mid-market |
| Tech stack | Centris + iPhone + 1-2 outils SaaS |
| Douleur #1 | Perdre lead car en visite quand prospect appelle |
| Budget tech mensuel | 150-300 $ discrétionnaires |
| Décision logiciel | Solo · pas comité franchise |
| Langue de travail | Mix FR/EN selon client — bilingue natif requis |

### Anti-persona (ignorer)

- [ ] Junior < 2 ans · GCI < 40 K$ · churn élevé · friction commerciale immense
- [ ] Top-team RE/MAX (déjà captif Centiva)
- [ ] Sièges sociaux franchises (cycle vente 18 mois)
- [ ] Courtier désengagé / temps partiel

### Déclencheurs d'achat (WTP)

- [ ] Vient de perdre 1 transaction par délai de réponse
- [ ] Cherche à remplacer adjointe humaine 2 500 $/mois
- [ ] Loi 25 audit en cours — peur sanction CAI
- [ ] Compare à confrère dans bullpen qui utilise déjà Klaris
- [ ] Saison printemps : flux entrant +40 %

---

## 3. Killer messaging

> Le message central doit établir un **contraste radical** avec les CRM passifs.

### Message canonique

```
« Les CRM américains traditionnels se contentent de stocker passivement vos données.
Klaris, elle, agit. Elle qualifie les curieux 24/7 dans un français québécois parfait
et garantit la conformité de votre pratique avec la Loi 25.
Klaris ferme les rendez-vous ; vous fermez la vente. »
```

### Variantes par canal

| Canal | Variante |
|---|---|
| Meta Reel 30s | « Tu conduis. Klaris répond en 60 sec. Le prospect ne part pas voir l'autre courtier. » |
| LinkedIn outbound | « 17K courtiers OACIQ. 1h délai moyen réponse. Klaris : 60 sec, 24/7, conforme Loi 25. » |
| RDV OACIQ kiosque | « Scanne le QR. SMS test. Vois Klaris gérer l'objection devant toi. » |
| Livre blanc Loi 25 | « Loi 25 sanctions jusqu'à 10 M$. Voici comment Klaris protège ton permis. » |
| Référence courtier→courtier | « 100 $/mois. Remplace 2 500 $ adjointe. Conforme OACIQ. » |

---

## 4. Canaux d'acquisition

> **CAC blended cible : 1 200 $. LTV cible : 3 000 $. Ratio 2,5:1 minimum.**

### Canal 1 — Meta Ads (moteur principal)

- **Audience** : Custom Audience croisant registre OACIQ public + lookalikes 1-3 %
- **Créatif** : Reels « Douleur/Solution » 30 sec · courtier perd commission en visite, Klaris sauve
- **Budget** : 3 K$/mois M0-M6, 6 K$/mois M6+
- **CAC modélisé** : 1 200 $ · CPM 13-30 $ · CTR 1 % · conv landing 5 % · close 10 %
- **Output cible** : 5-8 nouveaux clients/mois steady-state M6+
- **Tracking** : UTM par créatif · attribution Plausible/PostHog (pas Google Analytics — Loi 25)

### Canal 2 — RDV OACIQ + événements APCIQ

- **Cible événement #1** : RDV OACIQ Palais des congrès (~1 000 participants)
- **Investissement** : kiosque 33 $/pi² + droits exposant 325 $ + démo live
- **Méthode** : « Scan QR → SMS test → Klaris répond en direct sur écran »
- **Budget** : 12-15 K$ par événement majeur · 2-3 événements Y1
- **Output** : pas CAC direct · 100-200 emails qualifiés + brand awareness

### Canal 3 — Outbound directeurs franchises

- **Cible** : directeurs 5-20 courtiers · Laval, Rive-Sud, Rive-Nord
- **Pas cible** : sièges sociaux provinciaux (cycle 18 mois bloqué Centiva)
- **Pitch** : forfait équipe 10-15 sièges à tarif préférentiel = outil recrutement directeur
- **Méthode** : LinkedIn + référence Maxime Belma RE/MAX Anjou · pas cold mail générique
- **Cycle vente** : 9-18 mois agence · 1-3 mois solo
- **Owner** : VP Ventes (1 cofondateur 100 % dédié)
- **Output cible** : 1-3 agences signées Y1

### Canal 4 — Referral courtier-à-courtier

- **Programme** : « Donnez 100 $, Recevez 100 $ » intégré app iOS
- **Signature SMS** : « Géré par Klaris, l'adjointe IA de [Nom courtier] » — désactivable
- **Conformité CASL** : courtier reste expéditeur légal · Klaris facilitateur · STOP obligatoire
- **Budget** : 5 K$/an payouts
- **Output cible** : ratio referral > 0,15 (15 % clients amènent 1 lead/an)

---

## 5. Partenariats fondateurs Année 1

> **Règle d'or : si un partenariat n'a pas d'owner ET d'échéance, il n'existe pas.**

| # | Cible | Objectif critique | Owner | Échéance |
|---|---|---|---|---|
| 1 | **Centris Inc.** (Direction Innovation / API) | Accord syndication API MLS officiel | Dennis | M6 |
| 2 | **RE/MAX Anjou — Maxime Belma** | Pilote 50+ courtiers · success story chiffrée | Eliot | M3 |
| 3 | **APCIQ** (Communications + Événements) | Commandite RDV OACIQ + bilans stats | Seydou | M6 |
| 4 | **Collège Immobilier Québec** | Inclusion cursus UFC technologies | Walkens | M9 |
| 5 | **Cabinet juridique Loi 25** (Lavery / BLG / Stikeman) | Co-rédaction livre blanc — lead magnet | Walkens | M4 |

---

## 6. Séquence 24 mois

```
M0-M3   : SETUP
          - Convention cofondateurs (cap table + vesting 4 ans + cliff 1 an)
          - Tech E&O quote (Northbridge / Intact Tech / Assur360)
          - Subventions PSCE / Impulsion / BDC Tech déposées
          - Landing + funnel Meta v1 live
          - 5 entretiens primaires Roof.ai ex-clients (recherche v3)

M3-M6   : ACTIVATION
          - Campagne Meta 3 K$/mois (test créatifs)
          - Closing 10-20 premiers clients payants
          - Maxime Belma pilote démarré
          - VP Ventes assigné (1 cofondateur 100 %)

M6      : JALON PMF PROXY — 50 clients payants
          NRR > 100 % cohort M3 · churn < 3 %/mois

M6-M12  : SCALE
          - Meta 5-6 K$/mois
          - 1er RDV OACIQ kiosque
          - Outbound directeurs Laval / Rive-Sud
          - Centris syndication signée OU fallback DDF CREA actif
          - Livre blanc Loi 25 publié

M12     : JALON PMF VALIDÉ — 100 clients · 150 K$ ARR
          1ère agence 10+ courtiers signée

M12-M18 : OPTIMISATION
          - Référral program prouvé
          - Cohort retention 12 mois mesurée
          - Décision binaire M18 : Bootstrap pur OU prep Série seed si NRR > 110 %

M18-M24 : PHASE 2 PREP
          - Adaptation Ontario (TRESA, RECO, TRREB MLS)
          - Conditionnel cash-flow positif QC

M24     : JALON EXPANSION — 400 clients · 600 K$ ARR
          Trigger déploiement Ontario + C.-B.
```

### Verdicts par phase

- **Phase 1 (M0-M12) Québec** — **GO Bootstrap**
- **Phase 2 (M12-M24) Ontario + C.-B.** — **GO conditionnel** (cash-flow + Série seed)
- **Phase 3 (M24+) US frontaliers** — **NO-GO actuel** (guerre CAC US fatale)

---

## 7. Budget marketing Y1

| Poste | Budget | Note |
|---|---|---|
| Meta Ads | 36 K$ (3 K$/mois × 12) | Augmenter à 6 K$/mois si CAC < 1 200 $ |
| RDV OACIQ kiosque + démo | 12-15 K$ | 1 événement majeur Y1 |
| Outbound (VP Ventes externe si applicable) | 0-40 K$ | Si cofondateur dédié, 0 cash |
| Referral payouts | 5 K$ | 50 referrals × 100 $ |
| Contenu / landing / vidéos témoignages | 8 K$ | Production interne + freelance |
| Tech E&O assurance | 5-10 K$ | Northbridge / Intact Tech quote |
| **Sous-total brut** | **~ 66-100 K$** | |
| Subventions non-dilutives à empiler | **-30 K$** | PSCE PME MTL · Impulsion MEI · BDC Tech |
| **NET CASH-OUT MARKETING Y1** | **~ 36-60 K$** | Soutenable bootstrap |

### Subventions cibles (non-dilutives)

| Programme | Montant | Délai instruction | Owner |
|---|---|---|---|
| PSCE — PME Montréal | Jusqu'à 50 K$ | 8-12 sem | Walkens |
| Programme Impulsion PME (MEI Québec) | Jusqu'à 250 K$ | 12-16 sem | Walkens |
| BDC Capital Tech Acceleration | Prêt 100K-500K à taux faible | 6-10 sem | Eliot |
| Investissement Québec PIDE | 25-150 K$ | 12-20 sem | Eliot |

---

## 8. KPI dashboard

### North-Star Metric

> **Nombre de rencontres physiques qualifiées confirmées autonomement par Klaris / semaine.**
>
> Anti-vanity. Pas downloads · pas visites · pas inscriptions. Preuve ROI courtier.

### 5 métriques surveillées chaque lundi 10h

| KPI | Cible | Définition | Alerte |
|---|---|---|---|
| MQL hebdo | 8-12 | Marketing Qualified Leads cumulés (Meta + LinkedIn + referral) | < 5/sem |
| CAC blended | < 1 200 $ | Cash marketing total ÷ nouveaux clients du mois | > 1 500 $ |
| NRR cohort | > 100 % | Net Revenue Retention par cohorte mensuelle | < 95 % |
| Churn logo | < 3 %/mois | Clients perdus / clients actifs début de mois | > 5 % |
| Pipeline outbound | Stages B2B | Deals agence par étage funnel | Stagnation 4+ sem |

### Rituel

- **Sync hebdo** : lundi 10h · 30 min · revue 5 KPI + blocages
- **Revue trimestrielle** : Q1 / Q2 / Q3 / Q4 · ajustement budget canaux + roadmap
- **Escalation** : churn > 5 % ou CAC > 1 500 $ pendant 2 sem = call extraordinaire

---

## 9. Risques GTM & mitigations

| Risque | Impact | Mitigation |
|---|---|---|
| Blocage SMS Twilio (CRTC / A2P) | Élevé — coupe valeur produit | Toll-Free Verification CA · Sender ID Bell/Rogers/Telus · Double Opt-in CASL |
| Révocation accès Centris API | Majeur — reco listings dégradées | Entente syndication Centris · Fallback DDF CREA broker-level |
| Hallucinations LLM dans SMS | Critique — responsabilité courtier OACIQ + FARCIQ | RAG strict · Temperature = 0 · ToS Limitation Liability · Tech E&O Klaris |
| Churn > 5 %/mois | Détruit unit economics | Onboarding standardisé · success calls J+7, J+30, J+90 |
| Concurrence Roof.ai descend solo | Moyen — pression prix | Vitesse exécution · différenciation app iOS native · referral viral |
| Gbeuli (CI) entre QC | Bas court terme · à surveiller M18+ | Veille concurrentielle trimestrielle |

---

## 10. Actions semaine 1

> **5 décisions binaires. Tout le reste en découle.**

- [ ] **1. VP Ventes nommé** — 1 cofondateur 100 % dédié pipeline agence
- [ ] **2. Tech E&O quote** — appel Northbridge + Intact Tech + Assur360 (budget 5-10 K$/an)
- [ ] **3. Convention cofondateurs** — cap table + vesting 4 ans + cliff 1 an (notaire ou Clerky)
- [ ] **4. 5 entretiens Roof.ai ex-clients** — recherche primaire critique étude v3
- [ ] **5. Inscription RDV OACIQ 2026** — calendrier + budget kiosque + slot démo live

---

## 11. 3 erreurs à éviter

1. **Ne pas lever 500K-1M avant M12.** Étude v3 §7.1 explicite : ARPU 1 500 $ ≠ math VC. Dilution prématurée = piège.
2. **Ne pas démarcher sièges sociaux RE/MAX QC top-down.** Cycle 18 mois, blocage Centiva exclusif. Bottom-up via directeurs.
3. **Ne pas se positionner CRM.** Stay Action Layer. Interface avec Follow Up Boss / Centiva via API. Feature creep = mort.

---

## 12. Annexes & références

- Étude de marché v3 complète — PDF data room
- Stress test churn 3 / 5 / 7 % × ARR M24 — à modéliser
- P&L Y1-Y3 mensuel — Sheets séparé
- Cap table — convention cofondateurs
- ToS / Limitation of Liability — draft avocat Loi 25
- Bibliographie v3 — Section 9 (CREA, OACIQ, APCIQ, RECO, BCFSA, NAR, CRTC, CAI, Twilio, Prospeo, Assur360)

---

> **« Pas de levée. Pas de Centiva head-on. Bootstrap pur jusqu'à 100 clients prouvés. »**

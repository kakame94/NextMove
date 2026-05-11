# Klaris — Positionnement dans le landscape Agentic AI Immobilier

> **But.** Identifier où se trouve Klaris dans le paysage actuel de l'AI agentique immobilière (mai 2026) ET tracer la trajectoire stratégique 2026-2028.
> **Sources.** 10 articles Medium curés (mai 2026) :
> - Donovan — *Agentic AI Will Change Real Estate in 2026* (vision capabilities)
> - Coulson — *From Chatbots to Dealmakers* (transition chatbot → autonomous agent)
> - Bryant — *AI Agents Will Replace 80% of Real Estate Agents* (thèse disruption)
> - Lindsay — *PropOS Autonomous Future* (vision OS)
> - Quinn (Nova) — *Automating Conversations, Closing Deals*
> - DSCRIBE — *5 ways AI is helping agents* (FSBO marketing kit)
> - Umaña — *Property Management* (locations autonomes)
> - Agrawal — *Multi-Agent AutoGen* (build technique)
> - Hingane — *Advisory AI Agents* (archi advisory)
> - Dimov — *Complete Guide AI Real Estate 2026* (deal sourcing → closing)
> **Docs liés.** [innovators-dilemma-challenge.md](./innovators-dilemma-challenge.md) · [leap-of-faith-assumptions.md](./leap-of-faith-assumptions.md) · [lean-startup-challenge.md](./lean-startup-challenge.md)
> Date : 2026-05-11

---

## TL;DR — Position et direction

> **Klaris est aujourd'hui un « chatbot évolué », pas un « dealmaker autonome ».** Cf. Coulson :
> *« Les chatbots répondent. Les agents découpent un objectif complexe en tâches, appellent des outils, mémorisent le contexte, s'adaptent. »*
>
> **Nous sommes positionnés à AUGMENT (level 1)** sur l'échelle Bryant (2025 = AI assists, 2026-27 = P2P full transactions, 2028-30 = 60-80% agents remplacés).
>
> **Direction recommandée (cohérente avec règle 30/70 Christensen) :**
> - **70% effort 2026-2027** = devenir le « copilote courtier » de référence (Voie 1 — Sustaining)
> - **30% effort réservé** = construire 1-2 disruptive bets (Voies 2-3) → smoke test FSBO + PropOS

---

## 1 — État du landscape (mai 2026)

### Capabilities matures aujourd'hui

D'après ces articles + observation marché, les capabilities **réellement déployées** en mai 2026 :

| Capability | État déploiement | Joueurs actifs |
|------------|------------------|-----------------|
| Lead qualification SMS/chat | Mature | **Klaris**, Lead-IA, autres copilotes |
| Property search/matching | Mature | Zillow AI, Centris, Realtor.com |
| Showing scheduling | Mature | Calendly + intégrations CRM |
| Contract generation (templates) | Mature | DocuSign, dotloop |
| Tenant communication (locations) | Émergent | AppFolio AI, Buildium AI |
| **Multi-step autonomous planning** | **Émergent** | OpenAI Operator, Anthropic Claude with computer use |
| **End-to-end deal closing autonome** | **Spéculatif** | Aucun produit confirmé en QC/Canada |
| **FSBO full autonomous (no broker)** | **Spéculatif** | Quelques pilots US (Houwzer, Reali — pivots historiques) |

**Citation Coulson :** *« Les agents sont moins une boîte de recherche, plus un junior analyst. »*
**Citation Donovan :** *« 2026 — fully automated transactions emerge »* — mais Donovan ne cite **aucun produit** existant. C'est une **vision**, pas un état des lieux.

### Ce que personne ne fait encore (au mai 2026)

| Gap landscape | Pourquoi pas encore ? |
|----------------|------------------------|
| Agent fully autonomous QC (Loi 25 + OACIQ compliant) | Régulation locale = barrière |
| FSBO end-to-end (listing → closing) au Canada | Notaire obligatoire pour transfert titre |
| Bilingue FR/EN naturel (pas traduit) | Marché QC trop petit pour gros joueurs US |
| PropOS unifié solo broker (CRM + IA + closing + locations) | Acteurs fragmentés |

**Implication Klaris :** plusieurs « white spaces » exploitables, surtout sur le marché QC bilingue compliance-first.

---

## 2 — Matrix de positionnement 2×2

Axes :
- **Vertical** : Autonomy level (Assist ↔ Autonomous Agent)
- **Horizontal** : Customer (Courtier B2B ↔ Direct consumer B2C)

```
                                AUTONOMY
                                    ↑
                            FULL AUTONOMOUS AGENT
                                    │
                                    │
   « JOANEL OS »                    │       FSBO DIRECT
   Copilote courtier autonome       │       agent vend sans courtier
   (Voie 1 — sustaining 10×)        │       (Voie 2 — disruption)
                                    │       ex. Houwzer, Reali (historic)
                                    │       PropOS (Lindsay)
   ─────────────────────────────────┼─────────────────────────────────→
                                    │                          CUSTOMER
   ●  KLARIS (today)                │
   Chatbot évolué                   │       PROPERTY MANAGEMENT
   Lead qualif SMS                  │       Locations autonomes
   (Sprint 1-7 livré)               │       (Voie 3 — bypass courtier)
                                    │       ex. AppFolio AI, Buildium AI
                                    │       Umaña 2026
                                    │
   B2B Courtier                     │       B2C Direct
                                    ↓
                                ASSIST
```

**Lecture :**

- **Klaris aujourd'hui** = quadrant bas-gauche : chatbot évolué + courtier B2B.
- **Sustaining trajectory naturelle** = monter le quadrant gauche → devenir agent autonomous pour courtier.
- **Disruptive trajectories** = sauter dans le quadrant droit (vendeur direct OU gestion locative).

**Citation Bryant :** *« 80% des agents seront remplacés d'ici 2028-2030. »* — Klaris doit décider : on accompagne le déclin (sustaining) OU on accélère la disruption.

---

## 3 — Audit Klaris vs capabilities agentic (gap analysis)

| Capability agentic | Klaris today | Critique |
|---------------------|--------------|----------|
| Multi-step planning autonomous | ❌ Linéaire (n8n workflow) | Cible : LangGraph / AutoGen / Anthropic agents |
| Tool calling avancé | ⚠️ Basique (Twilio, Supabase) | Cible : Centris API + DocuSign + Google Calendar + comparables MLS |
| Long-term memory cross-projects | ⚠️ Postgres chat memory per phone | Cible : RAG broker-scoped + vector DB |
| Adaptation feedback | ❌ Pas de fine-tuning ni learning loop | Cible : LLM eval framework + prompt versioning |
| Lead qualif SMS | ✅ Mature | maintenu |
| Showing scheduling | ⚠️ Calendar passif | Cible : agent proactif (vs assistance) |
| Contract generation | ❌ Pas livré | Roadmap Sprint 14+ |
| Negotiation support | ❌ Pas livré | Cible : comparable analysis + counter-offer suggestions |
| Closing coordination | ❌ Pas livré | Cible : checklist auto + relance notaire/inspecteur |
| Dynamic pricing | ❌ Pas livré | Cible : Centris MLS + ML modèle prix QC |
| **Compliance OACIQ + Loi 25** | ✅ Avantage | **moat unique** — incumbents US ne l'ont pas |
| **Bilingue FR/EN natif** | ✅ Avantage | **moat unique** — non un produit traduit |

**Verdict.** Klaris a **2 moats uniques** (compliance + bilingue) qui valent plus que la concurrence US ne le réalise. Mais Klaris est **en retard** sur 4-6 capabilities agentic core.

---

## 4 — 3 voies stratégiques

### Voie 1 — SUSTAINING : « Joanel OS » (copilote courtier autonome)

**Vision** : Klaris devient le **OS du courtier solo qui survit** (les 20% restants selon Bryant). Au-delà du SMS qualification, Klaris orchestre tout le cycle :
- Lead → qualif → fiche
- Suggest visites + relances
- Génère offre d'achat pré-remplie (Joanel signe)
- Coordonne notaire/inspecteur/financement
- Reporting performance mensuel

**Modèle économique** : abonnement 200-300 CAD/mois (vs 100 CAD aujourd'hui) — premium copilote.

**Cible** : ~3 000 courtiers QC solo qui scalent (vs 9 000 solo total) = 3% pénétration adressable Year 2.

**Avantages** :
- Continuité avec base actuelle (Joanel persona)
- Moats compliance + bilingue exploitables
- Risque faible techniquement (pas de full autonomy)

**Risques** :
- Si Bryant a raison (80% agents remplacés), on accompagne un marché qui rétrécit
- Dépendance OACIQ (LF3) reste critique

**Comment** :
- Sprint 8-12 : sustaining backlog actuel (L1-L7 + R1-R7)
- Sprint 13-20 : capabilities agentic (génération offre, comparables Centris, dynamic pricing)
- M18+ : positionner « Klaris = OS courtier complet »

---

### Voie 2 — DISRUPTIVE : « Klaris Direct » (FSBO agentic, bypass courtier)

**Vision** : Klaris vend directement au **vendeur particulier (FSBO)** qui refuse de payer 5-6% commission courtier. Agent autonomous gère :
- Listing automatique (photos AI staging + descriptions optimisées)
- Pricing optimal (modèle ML + comparables)
- Qualification acheteurs entrants SMS
- Coordination visites (host self-service ou virtuel)
- Génération offres + contre-offres assistées
- Closing notaire (humain reste obligatoire au QC)

**Modèle économique** : **forfait fixe** 1 500-3 000 CAD par transaction (vs 25 000 CAD commission moyenne). Marge brute > 70%.

**Cible** : ~10 000 FSBO QC/an actuellement (estimation 12% des transactions). Avec Klaris, peut doubler (effet réduction friction).

**Avantages** :
- Cannibalisation contrôlée (on disrupte avant d'être disrupté — Christensen P#1)
- Marché 5-10× plus grand que courtier B2B (10k transactions × 2 000 CAD = 20M CAD potential vs notre TAM courtier)
- Aligné avec thèse Bryant (80% remplacés)

**Risques** :
- **Conflit base courtier actuelle** — Joanel verra Klaris devenir son concurrent
- Régulation OACIQ : un FSBO sans courtier reste légal au QC, mais des étapes (rédaction promesse) restent encadrées
- Tech complexity : full autonomy = stack agentic complete (LangGraph, vector DB, tool calling, agents critiques)

**Mitigation Christensen P#4** (capabilities vs disabilities) :
- **Entité légale séparée** : « Klaris Direct Inc. » (filiale de Next Move Inc.)
- Équipe séparée, brand séparé, deck séparé
- Joanel ne verra jamais ce produit pitché à lui

**Comment** :
- M9 : smoke test landing `klarisdirect.ca` (méthode L4c) → mesurer demande FSBO
- M12 : si signal → 1 fondateur dédié + recrutement 1-2 ingénieurs externes
- M15-M18 : MVP 5 transactions complètes pilotes
- M24 : décision scale ou kill

---

### Voie 3 — DISRUPTIVE : « Klaris Manage » (PropertyOS locations autonomes)

**Vision** : Klaris pivote vers **gestion locative** (propriétaires multi-unités + petits gestionnaires) :
- Pricing dynamique loyers
- Communication tenant auto (questions, plaintes, renouvellement)
- Coordination maintenance (plombier, électricien)
- Collecte loyers + relances retards
- Comptabilité unit-level + déclarations fiscales

**Modèle économique** : abonnement par unité (15-25 CAD/unité/mois) OU forfait par propriétaire (200 CAD/mois jusqu'à 20 unités).

**Cible** : ~100 000 propriétaires multi-unités au QC (estimation 5% du parc) = potentiel énorme.

**Avantages** :
- Marché **plus grand** que courtage (locations = transactions récurrentes vs ventes ponctuelles)
- Pas conflit avec courtier (autre verticale)
- Réutilise tech Klaris (SMS + IA + Supabase) avec adaptations

**Risques** :
- Nouveau persona (propriétaire vs courtier) → besoin JTBD interviews fresh
- Régulation locative QC (Tribunal administratif du logement) = différent OACIQ
- Concurrent existants (AppFolio, Buildium) avec millions $ funding

**Comment** :
- M15 : recherche persona propriétaire QC (4-6 interviews)
- M18 : smoke test landing `klarisapp.ai/locations`
- M21 : si signal → P&L séparé, équipe séparée
- M24-M30 : pilote 5-10 propriétaires multi-unités

---

## 5 — Décision recommandée : Stratégie hybride 70/20/10

Plutôt que **choisir** une voie, **allouer** capacity selon Christensen 30/70 + Lean L4 (MVP par persona) :

| Horizon | Voie 1 (Sustaining) | Voie 2 (FSBO) | Voie 3 (PropertyOS) |
|---------|---------------------|----------------|----------------------|
| **2026 H1 (Sprints 8-14)** | **100%** — toute la capacity | — | — |
| **2026 H2 (Sprints 15-20)** | **70%** | **30% smoke + research** | — |
| **2027 H1 (M12-M18)** | **60%** | **30% MVP** | **10% research** |
| **2027 H2 (M18-M24)** | **50%** | **30% MVP scale** | **20% MVP** |
| **2028 H1+ (M24+)** | Selon learnings | Selon learnings | Selon learnings |

**Règle :** une voie devient « principale » uniquement si **signal validé** (cohort cohérente + LF GO). Sinon on continue à parier sur les 3.

---

## 6 — Capabilities techniques à construire (agentic stack)

Pour passer du « chatbot évolué » au « dealmaker autonomous » (Coulson), Klaris doit acquérir :

| Capability | Stack proposé | Sprint cible |
|------------|----------------|--------------|
| Multi-step agent orchestration | LangGraph OU Anthropic agents framework | Sprint 13 (spike) |
| Tool calling robuste (Centris, DocuSign, Cal) | Function calling Claude + retry/idempotence | Sprint 14 |
| Memory cross-projects (RAG) | pgvector (Supabase) + embedding broker-scoped | Sprint 15 |
| Eval framework + prompt versioning | LangSmith OU Helicone OU homemade | Sprint 16 |
| Agent-as-critic (validation outputs) | Second LLM checks first agent output | Sprint 17 |
| Computer use (clic interfaces existantes) | Anthropic computer use API | Spike M15 |

**Coût estimé incrémental** : ~3 j-h par capability × 6 = ~18 j-h sur Sprints 13-18.

---

## 7 — Risques transversaux

| Risque | Mitigation |
|--------|------------|
| Concurrent US arrive en QC avec un produit agentic complet (ex. Compass IQ, Tomo, Side) | Vitesse + compliance bilingue moat. Lever capital M9 si fundraising disponible |
| OACIQ ban l'IA en autonomous decision (D3 Christensen) | Garder humain dans la boucle pour décisions OACIQ-réservées (offre, signature) |
| Joanel quitte parce qu'on lance Klaris Direct (FSBO) | Entité séparée + jamais pitcher Klaris Direct à un courtier base |
| Hype agentic AI s'effondre (winter AI 2027 ?) | Focus sustaining (Voie 1) qui marche même sans agentic full |
| Stack agentic explose le coût variable (Anthropic API hike) | Mix Haiku/Sonnet (cf. archi-challenge R7) + fallback OpenAI/Mistral |
| Klaris reste « chatbot évolué » trop longtemps → disrupté par entrant low-cost | Tier « Klaris Lite » 50 CAD/mois pour bloquer (cf. D5 Christensen) |

---

## 8 — Plan d'action — 5 actions agentic (Sprints 9-18)

| # | Action | Voie | Sprint |
|---|--------|------|--------|
| A1 | Spike LangGraph + Anthropic agents framework (1 ingé · 5j) | Voie 1 | Sprint 13 |
| A2 | RAG broker-scoped (pgvector + embeddings prospects) | Voie 1 | Sprint 15 |
| A3 | Génération offre d'achat assistée (template OACIQ + DocuSign) | Voie 1 | Sprint 14 |
| A4 | Smoke test `klarisdirect.ca` FSBO (méthode L4c) | Voie 2 | M9 |
| A5 | Recherche persona propriétaire QC (4-6 interviews) | Voie 3 | M15 |

---

## 9 — Lectures clés (à faire par l'équipe avant décision Q2 P/P meeting)

1. ⭐ **Coulson — From Chatbots to Dealmakers** : meilleure articulation du gap chatbot → agent
2. ⭐ **Bryant — 80% replacement** : thèse macro qui force la décision sustaining vs disruptive
3. ⭐ **Agrawal — Multi-Agent AutoGen build** : référence technique pour A1 (LangGraph alternative)
4. Donovan — *Agentic AI 2026* : vision capabilities (utile pour deck investisseurs)
5. Lindsay — *PropOS* : vision long terme (utile pour roadmap M24+)
6. Umaña — *Property Management* : briefing Voie 3 (PropOS locations)

---

## 10 — Suivi

- [ ] Q1 (M3) Pivot/Persevere : présenter cette analyse aux 4 fondateurs
- [ ] Sprint 13 : Spike LangGraph (A1)
- [ ] M9 : Smoke test Klaris Direct (A4)
- [ ] Q2 (M6) P/P : décision % capacity allouée à chaque voie pour H2 2026
- [ ] M15 : Research persona propriétaire (A5) + smoke FSBO results
- [ ] M24 : décision scale Voie 2 ou Voie 3 ou kill

---

## 11 — Position résumée pour pitch interne

> **Klaris en mai 2026 = chatbot évolué pour courtier solo. Mature sur lead qualification SMS + compliance bilingue (moats). Retard sur 4-6 capabilities agentic (multi-step, tool calling, RAG, eval framework).**
>
> **D'ici 2028, le marché courtier B2B va se polariser (Bryant) : 80% remplacés, 20% survivants. Notre choix : accompagner les 20% (Voie 1) OU accélérer la disruption (Voies 2-3).**
>
> **Recommandation : 70% sustaining (Joanel OS) + 30% disruptive bets (smoke FSBO M9, smoke PropertyOS M18). Décision finale 2027 selon learnings.**
>
> **Le mot d'ordre : « disrupter Klaris-d'aujourd'hui avant qu'un concurrent ne le fasse à notre place. »**

---

*Document v1.0 — 2026-05-11 — basé sur 10 articles Medium curés mai 2026 + frameworks Christensen, Lean Startup, McGreal/Jocham*

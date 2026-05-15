---
type: roadmap
managed_by: prr
product: Klaris — Technology delivery
version: 1.0.0
status: active
last_reviewed: 2026-05-15
refresh_cadence: monthly
prioritization_method: critical-path
vision: >
  A pragmatic, compliance-first AI stack — Anthropic-led, Supabase-grounded —
  that scales from 10 to 1 000+ brokers without re-platforming, and that
  passes OACIQ + Loi 25 + CASL audits without bolt-on retrofits.
disclaimer: >
  This is a technology delivery roadmap, not a binding release schedule.
  Capabilities are sequenced by critical-path dependency and risk, not by
  calendar dates. Confidence reflects readiness, not progress %.
objectives:
  - id: TECH-1
    name: Run a reliable production stack at single-broker cost target
    key_results:
      - p95 SMS round-trip < 3 s
      - Infra COGS < 8 $ CAD/courtier/mois @ 200 courtiers
      - Uptime ≥ 99.5% (Now) → 99.9% (Next)
  - id: TECH-2
    name: Make compliance auditable from day one
    key_results:
      - Loi 25 audit trail every PII access (Now)
      - OACIQ formal review passed (Now)
      - SOC 2 Type I in scope before Seed close
  - id: TECH-3
    name: Move from intake bot to transaction copilot
    key_results:
      - Offer drafting (OACIQ template) GA in product
      - Notarius + DocuSign integrations live
      - Centris read API integrated
  - id: TECH-4
    name: Build the platform layer (API + multi-tenant)
    key_results:
      - Public API v1 with ≥ 1 partner integration
      - Multi-tenant agency model (RBAC, data isolation)
      - SDK iOS + Web embeddable
  - id: TECH-5
    name: Reduce LLM dependency risk
    key_results:
      - Multi-provider abstraction (Anthropic + Mistral fallback)
      - Eval suite on QC FR + EN-CA tone
      - Cost guardrails: $ / qualified lead < 1 $ CAD
---

# Klaris — Feuille de livraison technologique

> **Horizon :** Now / Next / Later · revue mensuelle · 15 mai 2026
> **Audience :** CTO/lead tech, ingé, conseillers techniques, due diligence investisseurs
> **Méthode :** *Product Roadmaps Relaunched* — critical-path prioritization, capacités orientées résultat technique.

## Vision technologique

Stack **pragmatique, conformité-first, IA-orientée**. Anthropic en moteur principal, Supabase en source de vérité, n8n pour l'orchestration tant que ça scale. Pas de réécriture spéculative. Quand un composant freine le scale ou l'audit, on le remplace.

**Principes:**
1. **Conformité bakée, pas ajoutée** — Loi 25 + OACIQ dans le schéma, les logs, les RLS policies.
2. **Multi-provider IA** — jamais dépendant d'un seul fournisseur, abstraction couche modèle dès Now.
3. **Coût par courtier visible** — chaque feature mesure son impact COGS.
4. **Boring tech d'abord** — Postgres + n8n battent micro-services tant que < 500 courtiers.
5. **Auditable par défaut** — chaque accès PII loggé, chaque réponse IA traçable au prompt.

## Stack actuel (mai 2026)

| Couche | Tech | État | Notes |
|--------|------|------|-------|
| Orchestration | n8n self-hosted | Prod | 1 workflow intake, à étendre |
| Base | Supabase (Postgres, `ca-central-1`) | Prod | 6 tables, RLS activées |
| IA | Anthropic (Claude Sonnet) via n8n node | Prod | Postgres Chat Memory |
| SMS | Twilio | Prod | 1 numéro QC |
| Web | Next.js (`klaris_web`) | Démo | Dashboard placeholder |
| Mobile | Flutter (`klaris_ios`) | Démo | Showcase, pas encore TestFlight |
| Pitch / décks | Python-pptx + HTML | Outils | Internes |

**COGS estimé:** ~35–50 $ CAD/courtier/mois (Twilio + Anthropic + Supabase + n8n hosting). Cible Next: < 8 $ à 200 courtiers via volume + pricing négocié + caching.

## Objectifs techniques (TECH-KRs)

| ID | Objectif | Résultats clés |
|----|----------|----------------|
| TECH-1 | Stack prod fiable au coût cible | p95 SMS < 3 s · COGS < 8 $/courtier · uptime 99.5 → 99.9% |
| TECH-2 | Conformité auditable dès jour 1 | Audit trail Loi 25 · revue OACIQ · SOC 2 Type I en scope |
| TECH-3 | Copilote de transaction | Rédac. offres GA · Notarius + DocuSign · Centris API |
| TECH-4 | Couche plateforme | API v1 publique · multi-tenant agence · SDK iOS/Web |
| TECH-5 | Réduire le risque LLM | Multi-provider · eval suite FR + EN · $/lead < 1 $ |

---

## Capacités — Now / Next / Later

### Now — fiabiliser le socle, passer l'OACIQ

| Capacité | Besoin couvert | Objectif | Confiance |
|---------|----------------|----------|-----------|
| Audit log PII complet (Loi 25) | Régulateur exige traçabilité accès PII | TECH-2 | 85% |
| Backups + DR Supabase (PITR + restore drill mensuel) | Aucune perte de données acceptable | TECH-1 | 80% |
| Eval suite IA — ton QC + qualification accuracy | Pas de régression sur ton Joanel quand on change le prompt | TECH-5 | 75% |
| App iOS TestFlight (pilotes + courtiers Now) | Pilotes veulent app native, pas SMS only | TECH-3 | 75% |
| Dashboard web v1 — fiches qualifiées + score | Courtier doit voir le lead chaud en < 1 clic | TECH-3 | 80% |
| Observabilité (Sentry + Logflare + alertes) | MTTR < 30 min sur incident SMS | TECH-1 | 70% |
| Abstraction couche modèle (Anthropic + stub fallback) | Préparer multi-provider avant scale | TECH-5 | 65% |
| **RAG V1 — base de connaissances agence** (templates, FAQ, OACIQ regs) indexée pgvector | Klaris répond à 80% des questions courtier sans aller-retour humain | TECH-5 | 65% |

### Next — scaler à l'agence, gagner Centris

| Capacité | Besoin couvert | Objectif | Confiance |
|---------|----------------|----------|-----------|
| Multi-tenant agence (RBAC, data isolation, dashboard direction) | Vendre offre Agence 200 $/courtier | TECH-4 | 60% |
| Intégration Centris (lecture fiches MLS) | Pas de re-saisie pour le courtier | TECH-3 | 50% |
| Rédaction offres OACIQ (template + variables + PDF signable) | 30–60 min/offre récupérées | TECH-3 | 55% |
| Intégration Notarius + DocuSign | Signature électronique conforme QC | TECH-3 | 60% |
| Klaris EN — modèle + prompts + eval suite anglo | Pré-requis expansion Toronto/Ottawa | TECH-5 | 55% |
| Mistral fallback opérationnel (failover + cost arb.) | Indépendance fournisseur + 30% COGS | TECH-5 | 50% |
| Pipeline analytics (events → Supabase → Metabase) | Mesurer NPS, retention, $/lead par courtier | TECH-1 | 55% |
| SLA 99.9% + status page publique | Engagement contractuel agence | TECH-1 | 50% |
| **RAG V2 — multi-source hybrid** (conversations + besoins + listings, BM25 + vector, rerank Voyage) | Klaris cite la bonne fiche Centris ou le bon historique client en réponse | TECH-5 | 55% |
| **RAG agentique V3** — Claude tool-calls `search_listings`, `search_clients`, `search_templates` + self-correction | Réponses fondées sur retrieval, pas hallucinées | TECH-5 | 45% |

### Later — plateforme, copilote complet, Series A

| Capacité | Besoin couvert | Objectif | Confiance |
|---------|----------------|----------|-----------|
| API publique v1 (OAuth, rate-limit, docs) | Partenaires CRM/prêteurs intègrent Klaris | TECH-4 | 40% |
| SDK Web embeddable (widget) | Sites courtiers/franchises | TECH-4 | 35% |
| Migrer orchestration n8n → service Python dédié | n8n freine au-dessus de 500 courtiers/jour | TECH-1 | 40% |
| **RAG V4 — embeddings fine-tunés QC** (vocabulaire local: plex, condo, semi, secteurs) | Précision retrieval +20% vs embeddings génériques sur jargon QC | TECH-5 | 30% |
| **RAG V5 — multimodal** (images listings via CLIP, transcriptions vocales indexées) | Recherche par photo + mémo "trouve-moi un duplex comme celui-là" | TECH-5 | 25% |
| Fine-tuning génération sur style courtier (LoRA adapters par broker) | Ton personnalisé par courtier sans inflation coût | TECH-5 | 25% |
| SOC 2 Type I → Type II | Vente entreprise + Series A | TECH-2 | 35% |
| Marketplace prospects qualifiés (matching + paiement) | Monétiser leads froids | TECH-4 | 25% |
| Module post-closing (touchpoints + références) | Garder relation client après deal | TECH-3 | 30% |

---

## Évolution RAG — feuille spécifique

Klaris devient un copilote utile dans la mesure où il **récupère le bon contexte**, pas seulement par la qualité de ses prompts. La progression RAG est versionnée pour clarifier ce qui est en prod, ce qui est en discovery, ce qui est spéculatif.

| Version | Horizon | Architecture | Sources indexées | Modèle embedding | Retrieval | Confiance |
|---------|---------|--------------|------------------|------------------|-----------|-----------|
| **V0** (actuel) | livré | Postgres Chat Memory par téléphone, pas de retrieval externe | — | — | aucun | 100% (en prod) |
| **V1** | Now | pgvector sur Supabase, retrieval top-3 chunks | Templates SMS, FAQ broker, OACIQ regs digestés (≈ 200 docs) | OpenAI `text-embedding-3-small` (1536 dims) | Cosine top-k=3 | 65% |
| **V2** | Next | Hybrid search BM25 (`tsvector`) + vector + rerank | + conversations historiques + besoins prospects + listings Centris | OpenAI `text-embedding-3-large` ou Voyage `voyage-3` | BM25 → vector → rerank Voyage `rerank-2` | 55% |
| **V3** | Next / Later | RAG agentique — Claude tool-calls dédiés | `search_listings`, `search_clients`, `search_templates`, `search_conversations` | identique V2 | Agent décide quoi chercher · self-correction si retrieval pauvre | 45% |
| **V4** | Later | Embeddings fine-tunés sur corpus QC | + jargon local (plex, condo, semi, secteur Centris) + 50k conversations anonymisées | Fine-tune `text-embedding-3-small` ou Voyage finetune | identique V3 + caching sémantique | 30% |
| **V5** | Later (spéculatif) | RAG multimodal | + images listings (CLIP), transcriptions notes vocales, plans cadastraux | CLIP ViT-L/14 + texte | Cross-modal retrieval (texte → image, image → texte) | 25% |

### Métriques cibles par version

| Métrique | V1 (Now) | V2 (Next) | V3 (Next/Later) | V4+ (Later) |
|----------|---------:|----------:|----------------:|------------:|
| Recall@5 | 0.65 | 0.80 | 0.85 | 0.90 |
| Precision@3 | 0.55 | 0.75 | 0.85 | 0.90 |
| Hallucination rate (% réponses inventées) | < 8% | < 3% | < 1% | < 0.5% |
| Latence p95 retrieval | < 400 ms | < 600 ms | < 1.2 s | < 800 ms |
| Coût retrieval / conversation (CAD) | ~0,002 $ | ~0,004 $ | ~0,008 $ | ~0,003 $ |

### Stack RAG retenu

- **Vector store :** pgvector (Supabase Postgres) — pas de DB séparée tant que < 1M vecteurs.
- **Embeddings principaux :** OpenAI `text-embedding-3-small` (Now → Next) · upgrade `voyage-3` ou `text-embedding-3-large` si précision plafonne.
- **Reranker :** Voyage AI `rerank-2` (Next) — alternative Cohere `rerank-3` si Voyage indispo.
- **Pipeline ingestion :** Edge Function Supabase `ingest-docs/` — chunking par paragraphe (overlap 50 tokens), embed batch, upsert pgvector.
- **Caching sémantique :** Redis (Upstash) avec clé = embedding hash, TTL 7 j (Next/Later).
- **Eval framework :** `ragas` ou eval maison — dataset 200 paires (question, réponse attendue) labellisé par Joanel + 2 pilotes.

### Gouvernance & conformité RAG

- **Loi 25 :** seuls les chunks scope-`broker_id` sont retournés au courtier — RLS appliquée sur la table `documents`.
- **OACIQ :** chaque réponse RAG-fondée loggue les `source_doc_ids` dans `audit_log` (traçabilité conseil).
- **Hallucinations :** Claude reçoit consigne stricte « cite ou refuse » si retrieval pauvre — eval suite vérifie taux de refus correct.
- **Données prospects :** *jamais* dans l'index agence — silos par `broker_id` strictement.

### Risques RAG spécifiques

- **Drift index** → réindexation hebdomadaire des listings Centris, mensuelle des FAQ/regs.
- **Coût embeddings explose à scale** → batching 100 docs/call, cache, dégrader vers `text-embedding-3-small` si nécessaire.
- **Privacy leak inter-courtier** → RLS auditée trimestriellement, tests automatiques `test_rag_no_cross_tenant_leak`.
- **Régulateur jugeant RAG non-conforme** → fallback prompt-only avec disclaimer toujours disponible.

## SLOs cibles par horizon

| Métrique | Now | Next | Later |
|----------|----:|-----:|------:|
| Uptime mensuel | 99.5% | 99.9% | 99.95% |
| p95 SMS round-trip | < 5 s | < 3 s | < 2 s |
| p95 dashboard TTFB | < 1.5 s | < 800 ms | < 500 ms |
| MTTR incidents | < 60 min | < 30 min | < 15 min |
| Backup RPO | 24 h | 1 h | 5 min |
| COGS/courtier/mois | < 35 $ | < 15 $ | < 8 $ |
| $/qualified lead | < 2 $ | < 1 $ | < 0,50 $ |

## Dépendances externes critiques

| Dépendance | Risque | Mitigation |
|-----------|--------|------------|
| Anthropic API (Claude) | Outage / rate-limit / pricing | Abstraction couche modèle Now · Mistral fallback Next |
| Twilio (SMS QC) | Coût / disponibilité numéro local | 2ᵉ provider (Bandwidth, Plivo) en repli évalué Next |
| Centris API | Pas publique — négociation requise | Web scraping conforme en repli + lobbying via OACIQ |
| Supabase | Vendor lock-in Postgres managé | Code SQL standard, migration possible vers Postgres self-hosted |
| Notarius / DocuSign | Pricing par signature | Compte enterprise négocié dès 1ᵉʳ contrat agence |
| n8n self-hosted | Ne scale pas au-dessus de ~500 courtiers/jour | Migration service Python planifiée Later |

## Sécurité & conformité — jalons

- **Now :** chiffrement au repos (Supabase défaut), RLS toutes tables, audit trail PII, secret management n8n.
- **Now :** revue OACIQ formelle (lettre d'absence d'objection).
- **Next :** pen-test externe annuel, DPIA Loi 25 publié, registre sous-traitants à jour.
- **Next :** SOC 2 Type I en scope (avant Seed close).
- **Later :** SOC 2 Type II, ISO 27001 si exigé par franchise.

## Risques techniques & mitigations

- **LLM hallucinations en qualification** → eval suite + guardrails (max questions, scoring déterministe côté code).
- **Dérive coût IA** → cost guardrails $/lead, alertes seuil, basculement Mistral si Claude sature.
- **Scale n8n** → migration anticipée vers service Python avant que ça casse.
- **Fuite PII** → RLS + audit trail + revue trimestrielle accès.
- **Vendor lock-in** → abstraction couche modèle (Now), schéma SQL standard, contrats sortie 90 j.

## Cadence revue

- **Hebdomadaire :** incidents + capacités Now (tech lead).
- **Mensuelle :** ce document (revue COGS, SLOs, capacités Now/Next).
- **Trimestrielle :** roadmap globale + audit sécurité interne.

## Change log

- 2026-05-15 — Création feuille de livraison technologique (prr critical-path).

## Disclaimer

This technology delivery roadmap describes intended sequencing, not binding release dates. Capabilities, dependencies and confidence levels are subject to change with vendor availability, regulatory feedback and engineering discovery.

---

**Contact :** tech@nextmove.app · Klaris — une marque Next Move · 2026 · Confidentiel

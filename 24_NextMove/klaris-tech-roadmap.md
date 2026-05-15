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

### Next — scaler à l'agence, gagner Centris

| Capacité | Besoin couvert | Objectif | Confiance |
|---------|----------------|----------|-----------|
| Multi-tenant agence (RBAC, data isolation, dashboard direction) | Vendre offre Agence 200 $/courtier | TECH-4 | 60% |
| Intégration Centris (lecture fiches MLS) | Pas de re-saisie pour le courtier | TECH-3 | 50% |
| Rédaction offres OACIQ (template + variables + PDF signable) | 30–60 min/offre récupérées | TECH-3 | 55% |
| Intégration Notarius + DocuSign | Signature électronique conforme QC | TECH-3 | 60% |
| Cléa EN — modèle + prompts + eval suite anglo | Pré-requis expansion Toronto/Ottawa | TECH-5 | 55% |
| Mistral fallback opérationnel (failover + cost arb.) | Indépendance fournisseur + 30% COGS | TECH-5 | 50% |
| Pipeline analytics (events → Supabase → Metabase) | Mesurer NPS, retention, $/lead par courtier | TECH-1 | 55% |
| SLA 99.9% + status page publique | Engagement contractuel agence | TECH-1 | 50% |

### Later — plateforme, copilote complet, Series A

| Capacité | Besoin couvert | Objectif | Confiance |
|---------|----------------|----------|-----------|
| API publique v1 (OAuth, rate-limit, docs) | Partenaires CRM/prêteurs intègrent Klaris | TECH-4 | 40% |
| SDK Web embeddable (widget) | Sites courtiers/franchises | TECH-4 | 35% |
| Migrer orchestration n8n → service Python dédié | n8n freine au-dessus de 500 courtiers/jour | TECH-1 | 40% |
| RAG sur historique transactions courtier | Personnaliser ton + suggestions par courtier | TECH-5 | 30% |
| SOC 2 Type I → Type II | Vente entreprise + Series A | TECH-2 | 35% |
| Marketplace prospects qualifiés (matching + paiement) | Monétiser leads froids | TECH-4 | 25% |
| Module post-closing (touchpoints + références) | Garder relation client après deal | TECH-3 | 30% |
| Fine-tuning modèle sur corpus QC | Coût/qualité — quand volume justifie | TECH-5 | 25% |

---

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

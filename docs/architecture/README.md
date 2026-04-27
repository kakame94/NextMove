# Architecture C4 — CourtierIA

> Refonte des diagrammes du PDF d'avril 2026 en PlantUML versionnés, augmentée des composants manquants identifiés en revue critique.

**🌐 Site complet (avec navigation et descriptions par composant) :** [https://kakame94.github.io/NextMove/architecture/](https://kakame94.github.io/NextMove/architecture/)

---

## Diagrammes

| # | Diagramme | Source | Rendu |
|---|-----------|--------|-------|
| C1 | Contexte système | [c1-context.puml](diagrams/c1-context.puml) | [SVG](diagrams/c1-context.svg) |
| C2 | Containers applicatifs | [c2-containers.puml](diagrams/c2-containers.puml) | [SVG](diagrams/c2-containers.svg) |
| C3 | Composants RAG Engine | [c3-rag-component.puml](diagrams/c3-rag-component.puml) | [SVG](diagrams/c3-rag-component.svg) |
| —  | Séquence : question réglementaire | [c4-sequence-query.puml](diagrams/c4-sequence-query.puml) | [SVG](diagrams/c4-sequence-query.svg) |
| —  | Couches de données P0/P1/P2 | [data-layers.puml](diagrams/data-layers.puml) | [SVG](diagrams/data-layers.svg) |

Les SVG sont **pré-générés en local** avec PlantUML 1.2025.4. Pour régénérer après modification d'un `.puml` :

```bash
plantuml -tsvg docs/architecture/diagrams/*.puml
```

---

## Verdict de la revue critique

Ce que j'ai validé du PDF :

- ✅ Approche RAG 80% / Fine-tuning 20%
- ✅ GCP Montréal (souveraineté + Loi 25)
- ✅ Stack Flutter / React / FastAPI
- ✅ Roadmap 4 phases / 12 mois

Ce que j'ai modifié ou ajouté :

- ⚠️ **Pinecone → pgvector Cloud SQL Montréal** (résidence des données)
- ⚠️ **Keycloak → GCP Identity Platform** (moins lourd à opérer)
- ⚠️ **APIs LLM US → Vertex AI Anthropic Claude région ca-central** + PII Redaction obligatoire
- ⚠️ **Mobile décalé en Phase 3** (B2B courtier = web-first)

Composants manquants ajoutés à l'architecture cible :

- ❌ Observabilité (Prometheus + Grafana + OTEL + Sentry)
- ❌ Event bus (Pub/Sub) + Worker Pool (Cloud Run jobs)
- ❌ Cache Redis (RAG + rate-limit)
- ❌ **PII Redaction Service** (Loi 25 art. 12)
- ❌ Évaluation RAG (Ragas + golden set 100 questions)
- ❌ Prompt Registry versionné
- ❌ **HITL Approval Queue** pour formulaires OACIQ générés
- ❌ MFA pour comptes courtiers OACIQ

Détails complets dans la section [Validation &amp; gaps](https://kakame94.github.io/NextMove/architecture/#validation) du site.

---

## Phase 2 enrichie

Le PDF résumait Phase 2 à « Centris + CMA + mobile beta ». La revue propose de scinder en trois sous-phases :

- **Phase 2.a — Plomberie production** (mois 3-4) : observabilité, async, cache, LLM router, PII redaction
- **Phase 2.b — Données & qualité** (mois 4-5) : Centris ingestion, prompt registry, eval RAG, feature flags
- **Phase 2.c — Workflow courtier** (mois 5-6) : CMA auto, HITL queue, calculateur hypo, dashboard analytics

Mobile Flutter glisse en Phase 3 (mois 6-9), conjointement avec la transcription audio.

---

## Convention visuelle

Dans les diagrammes :

- **Boîtes pleines** = composants présents dans le PDF original (Phase 1 MVP)
- **Boîtes pointillées turquoise** = composants ajoutés en Phase 2 après revue critique

---

*Préparé par Eliot Alanmanou — Architecte de données · Avril 2026*

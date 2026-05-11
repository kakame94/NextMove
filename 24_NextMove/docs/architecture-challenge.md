# Klaris — Challenge Architecture (DDIA + Database Internals)

> **But.** Stress-tester l'architecture technique de Klaris à la lumière de :
> 1. *Designing Data-Intensive Applications* — Martin Kleppmann (DDIA, O'Reilly 2017) — reading notes ComeShare V2.
> 2. *Database Internals — A Deep Dive Into How Distributed Data Systems Work* — Alex Petrov (O'Reilly 2019, ISBN 978-1-492-04034-7).
> **Documents liés.** [architecture.md](../../architecture.md) · [business-constraints-checklist.md](./business-constraints-checklist.md) · [business-canvas-challenge.md](./business-canvas-challenge.md)
> Date : 2026-05-08

---

## TL;DR — Verdict en 5 lignes

> **Klaris a une stack solide pour le MVP (1-50 courtiers) mais 7 risques techniques majeurs deviennent bloquants à partir de 100+ courtiers : (1) n8n self-hosted = SPOF sans HA, (2) pas d'idempotence webhook Twilio = double SMS possible, (3) Loi 25 STOP propagé non-atomique sur 3 systèmes, (4) Drift offline iOS sans CRDT/version vector → conflits silencieux, (5) tail latency P99 LLM/SMS non mesurée, (6) backup Supabase quotidien sans RTO défini, (7) pas de circuit breaker sur Twilio/Anthropic = cascade failure si fournisseur down.**

| Score architecture | État actuel | Note |
|---------------------|-------------|------|
| Reliability (DDIA Ch1) | 5/10 | n8n SPOF, pas de HA, backup quotidien sans RTO |
| Scalability (DDIA Ch1) | 6/10 | Stateless web/iOS OK. n8n stateful, pas mesuré P99 |
| Maintainability (DDIA Ch1) | 7/10 | Stack 5 langages, mais Sentry + Linear feedback OK |
| Data model (DDIA Ch2) | 8/10 | Postgres relational pertinent pour CRM, RLS OK |
| Storage engine (DDIA Ch3 + DB Internals Ch7) | 7/10 | B-Tree Postgres OK MVP. LSM (Cassandra) à envisager M12+ pour conversations |
| Transactions (DDIA Ch7 + DB Internals Ch5) | 5/10 | STOP opt-out non atomique multi-système |
| Distributed systems fallacies (DB Internals Ch8) | 4/10 | Pas de circuit breaker, pas de retry budget, pas de bulkhead |

**Score moyen : 6/10** — solide MVP, fragile à scale.

---

## 1 — Cadre théorique appliqué

### 1.1 DDIA — concepts clés cités

| Concept | Source | Pertinence Klaris |
|---------|--------|-------------------|
| Reliability / Scalability / Maintainability | Ch1 | Toute la stack |
| Tail latency P99/P99.9 (Amazon) | Ch1 | Cible « < 60s » Klaris à raffiner |
| Schema-on-write vs schema-on-read | Ch2 | Postgres = on-write. Conversation JSON ? |
| LSM-tree vs B-tree | Ch3 | Postgres = B-tree (update-in-place). Conversations en append-only = candidate LSM |
| Bloom filters | Ch3 | Lookup blacklist STOP rapide |
| Forward / backward compat | Ch4 | Migrations 003-008 ne définissent pas |
| Single-leader vs multi-leader vs leaderless | Ch5 | Supabase free tier = single-leader, pas de failover |
| Quorum reads/writes (`w + r > n`) | Ch5 | N/A car single replica |
| Conflict resolution : LWW / CRDT / version vector | Ch5 | Drift offline iOS doit choisir |
| Read-after-write / monotonic reads / consistent prefix | Ch5 | iOS Realtime stream ↔ DB après mutation |
| Hash partitioning vs key range | Ch6 | Conversations partitionnables par `broker_id` |
| Hot spots & rebalancing | Ch6 | JP agence (99 courtiers) = hot spot potentiel |
| ACID / BASE / Snapshot Isolation / MVCC | Ch7 | Supabase = SI (Postgres MVCC) ✅ |
| Lost update / write skew / phantom | Ch7 | UPDATE prospect simultané broker + IA |
| Two-phase commit (2PC) | (DDIA Ch9 + DB Internals Ch13) | Atomicité sur Postgres + Twilio + Resend |

### 1.2 Database Internals — concepts clés cités

| Concept | Source | Pertinence Klaris |
|---------|--------|-------------------|
| Buffer management & cache eviction | Ch5 | Drift cache iOS — quelle politique ? |
| Snapshot Isolation MVCC implementation | Ch5 | Postgres OK ✅ |
| LSM tree write/read/space amplification (RUM conjecture) | Ch7 | Conversations storage strategy |
| Bloom filters in LSM lookups | Ch7 | Blacklist STOP |
| Fallacies of distributed computing | Ch8 | **8 fallacies à auditer** |
| Two Generals' Problem | Ch8 | Twilio webhook delivery |
| FLP impossibility | Ch8 | N/A (pas de consensus distribué chez nous) |
| Failure detection : heartbeats, phi-accrual, gossip | Ch9 | Klaris : pas de health check explicite |
| Linearizability / Sequential / Causal consistency | Ch11 | iOS Realtime ordering |
| Tunable consistency | Ch11 | Configurable per query Supabase ? |
| CRDTs & strong eventual consistency | Ch11 | Drift offline cache |
| Anti-entropy : read repair, hinted handoff, Merkle trees | Ch12 | Si multi-region Supabase |
| Distributed transactions : 2PC / 3PC / Calvin / Spanner / Percolator | Ch13 | Atomicité Postgres + Twilio + Resend |
| Coordination avoidance | Ch13 | Préférer où possible |
| Raft / Paxos / ZAB | Ch14 | N/A MVP, pertinent si n8n cluster |

---

## 2 — Inventaire architecture actuelle (état Sprint 7)

| Composant | Tech | Réplication | Failover | Mesure latence | Note |
|-----------|------|-------------|----------|------------------|------|
| Orchestration | n8n self-hosted (VPS Hetzner) | Single instance | ❌ Aucun | ❌ | **SPOF** |
| DB | Supabase Postgres ca-central-1 | Free tier = single primary | ❌ Pas de standby | ❌ | Backup quotidien — RTO/RPO non définis |
| Connection pool | aws-1-ca-central-1.pooler:5432 | géré Supabase | géré | ❌ | OK |
| Conversation memory | Postgres Chat Memory (table n8n) | Single | — | ❌ | Couplé n8n |
| LLM | Anthropic Claude Sonnet (HTTPS API) | Multi-region Anthropic | géré Anthropic | ❌ Pas de P99 client | Risque rate limit + price hike |
| SMS | Twilio webhook IN/OUT | Multi-region Twilio | géré | A2 retry 1x si > 5s ✅ | Pas idempotent côté Klaris |
| Email | Resend (Edge Function daily-briefing) | Multi-region Resend | géré | ❌ | Free tier OK |
| iOS app | Flutter Cupertino + Riverpod + Drift offline + Supabase Auth + Firebase Push | Local cache | — | ❌ | **Pas de conflict resolution explicite** |
| Web | Next.js 15 + React 19 sur Vercel | Vercel CDN edge | géré | ❌ | Stateless OK |
| Edge Functions | Deno (Supabase) — centris-sync, daily-briefing, monthly-report, recommend-listings, transcribe-memo, voicemail-intake, linear-feedback | Multi-region Supabase | géré | ❌ | Cold start non mesuré |
| Observabilité | Sentry (Sprint 6) | géré Sentry | géré | Sentry P50/P95 OK | ✅ Bon ajout |

---

## 3 — Top-7 risques techniques

### R1 — n8n SPOF (DDIA Ch1 Reliability + DB Internals Ch8 Failure Models)

**Problème.**
- n8n est self-hosted sur **un seul VPS** ([architecture.md](../../architecture.md):20-30, [cost structure F3](./business-cost-structure.md)).
- Aucun load balancer, aucun standby, aucun health check externe.
- Citation DDIA Ch1 : *« Reliability = continuing to work correctly even when things go wrong. Hardware Faults: Redundancy is the key. »*
- Citation DB Internals Ch8 : *« Crash Faults · Omission Faults · Arbitrary Faults · Need to Handle Failures »*.

**Impact.**
- Si VPS crash → 100% du flow SMS s'arrête.
- Si OS update redémarre → fenêtre downtime non maîtrisée.
- Aucune visibilité sur la santé n8n (pas de heartbeat dans Sentry).

**Probabilité.** Moyenne (Hetzner uptime ~99.9% = ~8h downtime/an, mais aussi crash applicatif n8n, OOM, disk full).

**Mitigation Sprint 8-9.**
1. **Health check endpoint** `/health` exposé, monitoring Uptime Robot ou Better Stack.
2. **Standby VPS** pré-provisionné en autre datacenter (Hetzner Helsinki vs Falkenstein) avec script de bascule manuel < 15 min.
3. **Migration vers n8n Cloud** ou alternative managée (Pipedream, Make, Trigger.dev) si MTTR > 1h inacceptable.
4. À long terme (M9+) : n8n cluster avec Postgres backend + Redis queue (Raft consensus pour leader election — DB Internals Ch14).

---

### R2 — Webhook Twilio non idempotent (DDIA Ch11 + DB Internals Ch8 Two Generals)

**Problème.**
- Twilio peut livrer un webhook **2 fois** en cas de timeout réseau (au-most-once vs at-least-once).
- Notre n8n flow ([architecture.md](../../architecture.md):10-17) ne déduplique pas par `MessageSid` Twilio.
- Citation DB Internals Ch8 : *« Two Generals' Problem : impossible de garantir que les deux camps savent que l'autre a reçu le message »*.
- Citation DDIA Ch11 (concept) : *« idempotence is the property that performing an operation multiple times has the same effect as performing it once »*.

**Impact.**
- Prospect reçoit la même question IA 2 fois → perception de bug → trust broken.
- Sender score Twilio dégradé (S1-S5 [business-constraints-checklist.md:73-80](./business-constraints-checklist.md)).
- Coût SMS doublé.

**Probabilité.** Moyenne (Twilio retry policy = 5 attempts si webhook timeout > 15s).

**Mitigation Sprint 8.**
1. Table `twilio_message_processed (message_sid PK, processed_at)` avec `INSERT ON CONFLICT DO NOTHING` en première étape n8n.
2. Si row exists → return 200 OK sans rejouer le flow.
3. Idempotency-Key sur tous les `outbound` Twilio (header HTTP custom).
4. Test E2E : envoyer 5× le même webhook, vérifier 1 seule réponse Claude.

---

### R3 — STOP opt-out non atomique multi-système (DDIA Ch7 + DB Internals Ch13 Distributed Transactions)

**Problème.**
- Quand prospect texte STOP, il faut **simultanément** :
  1. INSERT dans `blacklist` (Postgres).
  2. CANCEL toutes les `relances` futures pour ce prospect (UPDATE Postgres).
  3. STOP les workflows n8n en cours.
  4. (Optionnel) Notifier le broker.
- Pas d'atomicité distribuée entre Postgres + n8n.
- Citation DDIA Ch7 : *« Multi-object transactions are often needed if several pieces of data need to be kept in sync. »*
- Citation DB Internals Ch13 : *« 2PC : impossible si un cohort fail. Calvin / Spanner alternatives. »*

**Impact.**
- Risque légal Loi 25 / CASL : *« opt-out respecté dans les 10 jours »* ([business-constraints-checklist.md L18](./business-constraints-checklist.md#L18)).
- Amende jusqu'à **10 M CAD** par infraction.
- Si étape 1 succeeds + étape 2 fails → blacklist mais relance T+2 part quand même → infraction.

**Probabilité.** Faible isolément (chaque step réussit ~99.9%) mais Loi 25 = zero tolerance.

**Mitigation Sprint 8 (priorité légale).**
1. **Saga pattern** (DB Internals Ch13 — alternative à 2PC) :
   - Step 1 : INSERT blacklist (Postgres tx) → si succès, marqueur `pending_propagation = true`.
   - Step 2 : Edge Function `stop-propagation` lit les `pending_propagation`, annule relances + workflows n8n.
   - Step 3 : Marqueur `pending_propagation = false`.
   - Si étape 2 fail → retry exponential backoff + alerte si > 1h.
2. Garantie **at-least-once** côté propagation + idempotence côté annulation.
3. Test E2E : envoyer STOP, vérifier qu'aucune relance ne part dans les 24h suivantes.

---

### R4 — Drift offline iOS sans conflict resolution (DDIA Ch5 + DB Internals Ch11 CRDTs)

**Problème.**
- iOS Drift cache permet édition offline ([klaris_ios/README.md L52,80](../../klaris_ios/README.md)).
- Si broker crée un prospect offline + IA crée le même prospect en parallèle (SMS reçu sur serveur) → 2 versions.
- Aucun mécanisme **CRDT / version vector / LWW** documenté.
- Citation DDIA Ch5 : *« Last write wins (LWW) is dangerously prone to data loss. »*
- Citation DB Internals Ch11 : *« Strong Eventual Consistency and CRDTs : convergent merge function ensures all replicas reach same state. »*

**Impact.**
- Modifications broker offline silencieusement écrasées par le serveur.
- Pas de message "conflit détecté" → broker perd confiance.
- Risque OACIQ si une note de qualification disparaît.

**Probabilité.** Élevée pour le broker en visite (zone blanche → cache → resync).

**Mitigation Sprint 9-10.**
1. Ajouter `version` column (integer, monotonic) sur tables critiques (`prospects`, `notes`, `relances`).
2. Sync iOS = `compare-and-set` (DDIA Ch7) sur `version`. Si conflit → afficher modal "Conflit détecté, garde version locale OU serveur OU merge manuel".
3. Pour les notes texte libres : Y.js ou Automerge (CRDT mergeable persistent data — DDIA Ch5 cite Operational Transformation comme alternative).
4. Pour scoring de température : LWW acceptable (idempotent par nature).

---

### R5 — Tail latency P99/P99.9 non mesurée (DDIA Ch1 + DB Internals Ch1)

**Problème.**
- Cible « < 60s » Klaris ([prd.md L107](../../_bmad-output/planning-artifacts/prd.md)) = **moyenne** ou **p50** ?
- Pas de mesure P99 / P99.9 sur le chemin critique : `Twilio webhook → n8n → Claude API → Postgres → Twilio outbound`.
- Citation DDIA Ch1 : *« Amazon: 100ms increase in response time reduces sales by 1%. P99.9 directly affects user experience. »*
- Citation DDIA Ch1 : *« Tail latency amplification: a single slow request can dominate the user-perceived response time. »*

**Impact.**
- Si Anthropic API a un P99 = 8s et Twilio P99 = 3s → P99 conversation = 11s+ (sans compter cold start n8n).
- Prospect perçoit Klaris comme lent → préfère parler à humain.
- Pas de SLA défensible face à JP (segment franchise).

**Probabilité.** Quasi-certaine (toute API publique a une long-tail distribution).

**Mitigation Sprint 8.**
1. Sentry Performance : `transactions/sms-flow` avec spans Twilio · Claude · Postgres.
2. Définir SLO explicite : **P50 < 5s, P95 < 15s, P99 < 30s** sur réponse SMS IA.
3. Alerte si P95 dérive > 20% sur 7 jours.
4. Optimisations possibles :
   - Claude Haiku au lieu de Sonnet pour les réponses simples (P95 ~600ms vs ~3s).
   - Streaming Claude → first token < 1s (perçu comme rapide).
   - Pre-warm Edge Functions (Supabase ne le supporte pas nativement → trigger ping cron).

---

### R6 — Backup Supabase sans RTO/RPO défini (DDIA Ch1 + DB Internals Ch5 Recovery)

**Problème.**
- [business-constraints-checklist.md L142](./business-constraints-checklist.md) : *« A3 Backup quotidien Supabase »* — c'est tout.
- Pas de **RTO** (Recovery Time Objective : combien de temps pour restaurer ?).
- Pas de **RPO** (Recovery Point Objective : combien de données perdues max ?).
- Citation DDIA Ch7 : *« Durability : the promise that once a transaction has committed successfully, any data it has written will not be forgotten, even if there is a hardware fault. »*
- Citation DB Internals Ch5 : *« Recovery via WAL (Write-Ahead Log) + ARIES algorithm. »*

**Impact.**
- Si Supabase free tier corrompt la DB à 23h59 → on perd jusqu'à **24h** de conversations + prospects.
- Restauration manuelle : non chronométrée. Probablement 2-6h pour restorer + reconfigurer RLS.
- Si JP signe un contrat à $200/courtier × 99 courtiers = $19 800/mois et perd ses leads → procès.

**Probabilité.** Faible mais impact maximal.

**Mitigation Sprint 9.**
1. **Définir SLO** : RPO ≤ 1h, RTO ≤ 4h.
2. **Upgrade Supabase Pro** ($25/mois — déjà budgété [F1](./business-cost-structure.md)) → Point-in-Time Recovery (PITR) jusqu'à 7 jours, granularité minute.
3. **Test de restauration trimestriel** : restorer un dump dans une DB sandbox, vérifier intégrité RLS + données.
4. Pour les agences (200 CAD/courtier × N) : ajouter clause SLA contractuelle « RTO 4h, crédit 10% si dépassé ».

---

### R7 — Pas de circuit breaker sur Twilio/Anthropic (DB Internals Ch8 Cascading Failures)

**Problème.**
- Si Anthropic API throttle ou down → n8n retry boucle infinie → file d'attente Twilio explose → tous les SMS bloqués.
- Si Twilio rate limit (100 SMS/min ?) → Klaris envoie 200 → erreurs en chaîne.
- Citation DB Internals Ch8 : *« Cascading Failures : a failure in one component triggers failures in others, often amplified. »*
- Pattern manquant : **Circuit Breaker** (open/half-open/closed) — popularisé par Hystrix (Netflix).

**Impact.**
- Une panne externe **30 min** → file de SMS de **plusieurs heures** à digérer (post-recovery).
- Prospects reçoivent réponses retardées à minuit (hors horaires Loi 25 → infraction G8).
- Sender score Twilio degraded (S1-S5).

**Probabilité.** Moyenne (Anthropic incidents 2024-2025 ~1/mois en moyenne).

**Mitigation Sprint 9.**
1. **n8n Error Trigger node** sur chaque appel Anthropic / Twilio :
   - Si > N échecs consécutifs (N=5) → ouvrir circuit (skip API pendant 5 min).
   - Half-open : 1 requête de test, si succès → close.
2. **Retry budget** : max 3 retries par message, exponential backoff (1s, 4s, 16s).
3. **Bulkhead** : queue séparée pour les SMS critiques (RDV J-1) vs nice-to-have (relances J+5).
4. **Fallback** : si Claude down > 5 min → SMS template humain « Je vous rappelle bientôt — Joanel ».

---

## 4 — Risques techniques secondaires (R8-R15)

| # | Risque | Source livre | Sprint cible |
|---|--------|--------------|--------------|
| R8 | Forward/backward schema compat non validée (migrations 003-008) | DDIA Ch4 | Sprint 9 — process migration deux-étapes |
| R9 | Pas de Bloom filter sur lookup blacklist (table grandit linéairement) | DDIA Ch3 + DB Internals Ch7 | M6 si > 10k blacklisted |
| R10 | Conversations storage = Postgres B-tree (write amplification potentiel) | DDIA Ch3 + DB Internals Ch7 | M12 si > 1M messages |
| R11 | Pas de partitioning par `broker_id` sur `conversations` / `relances` | DDIA Ch6 | M9 si > 100 brokers |
| R12 | Postgres single-region (ca-central-1) — latence pour broker hors QC | DDIA Ch5 | Out-of-scope Year 1 |
| R13 | Pas de dead letter queue (DLQ) pour SMS / Edge Functions | DDIA Ch11 | Sprint 9 |
| R14 | Pas de rate limit applicatif (juste Twilio) — vulnérable si webhook spam | DB Internals Ch8 | Sprint 8 |
| R15 | Aucun chaos engineering testé | DDIA Ch1 | M6+ (Gremlin / litmus) |

---

## 5 — Reading-level fallacies de Peter Deutsch (DB Internals Ch8) appliquées

Les 8 fallacies :

| # | Fallacy | État Klaris | Mitigation requise |
|---|---------|-------------|---------------------|
| 1 | Network is reliable | ❌ Pas reconnu (pas de retry idempotent) | R2, R7 |
| 2 | Latency is zero | ❌ P99 non mesuré | R5 |
| 3 | Bandwidth is infinite | 🟡 Twilio MMS non utilisé, OK pour l'instant | — |
| 4 | Network is secure | 🟢 HTTPS partout, RLS Supabase | OK |
| 5 | Topology doesn't change | 🟡 Single VPS n8n, IPs Supabase pooler stable | R1 |
| 6 | There is one administrator | 🟡 4 cofondateurs, pas de runbook | A7 EBM doc |
| 7 | Transport cost is zero | 🟢 SMS coûts trackés ([V2 cost structure](./business-cost-structure.md)) | OK |
| 8 | Network is homogeneous | 🟡 iOS + web + Edge — protocoles HTTP/REST + WebSocket | OK |

**Bilan : 3/8 fallacies sont activement traitées.** Score 5/8 minimum visé pour scale.

---

## 6 — Plan d'action — 7 corrections prioritaires (Sprints 8-10)

| # | Correction | Risque traité | Effort | Sprint |
|---|------------|----------------|--------|--------|
| 1 | Idempotence Twilio webhook (table `processed_messages`) | R2 | 1 j | Sprint 8 |
| 2 | Saga STOP opt-out atomique multi-système | R3 | 3 j | Sprint 8 (légal) |
| 3 | Sentry Performance + SLO P50/P95/P99 défini | R5 | 2 j | Sprint 8 |
| 4 | Health check n8n + standby VPS pré-provisionné | R1 | 2 j | Sprint 9 |
| 5 | Conflict resolution Drift iOS (`version` column + modal merge) | R4 | 5 j | Sprint 9 |
| 6 | Supabase Pro + PITR + test restauration trimestriel | R6 | 1 j + 1 j/trim | Sprint 9 |
| 7 | Circuit breaker n8n sur Anthropic + Twilio + DLQ | R7 | 3 j | Sprint 10 |

**Total effort : ~17 jours-homme** étalés Sprint 8-10.

---

## 7 — Que NE PAS faire (anti-patterns à éviter)

D'après les leçons des deux livres :

| Anti-pattern | Pourquoi (citation) | Mauvaise idée pour Klaris |
|---------------|----------------------|----------------------------|
| Migrer Postgres → MongoDB | DDIA Ch2 : *« Document DB has limitation: deeply nested, joins, many-to-many »* | Notre modèle `prospect ← conversation ← message` est many-to-many → relational |
| Migrer Postgres → Cassandra avant 1M messages | DDIA Ch3 : *« LSM-trees: compaction can interfere with reads »* | Over-engineering avant traction |
| Implémenter Raft custom pour n8n cluster | DB Internals Ch14 : consensus est très difficile à implémenter correctement | Utiliser une lib éprouvée (etcd, Consul) ou managed (n8n Cloud) |
| Ajouter ZooKeeper pour service discovery | DDIA Ch6 : ZooKeeper utile à grande échelle | 1 instance n8n n'a pas besoin de ZooKeeper |
| Sharding manuel par `broker_id` avant M9 | DDIA Ch6 : *« Hot spots difficult to predict »* | Premature partitioning. Commencer avec table indexée + materialized views |
| Eventual consistency partout | DB Internals Ch11 : *« Stronger guarantees generally require transactions or consensus »* | Loi 25 STOP demande consistency forte (R3) |

---

## 8 — Cible architecture M12+ (vision)

Une fois les 7 corrections livrées, voici la cible technique pour scale 100-500 courtiers :

```
┌──────────────────────────────────────────────────────────────────────┐
│ EDGE                                                                  │
│   Cloudflare WAF + rate limit                                        │
└─────┬─────────────────────────────────────────────────────┬───────────┘
      │                                                     │
┌─────▼──────────┐                              ┌───────────▼──────────┐
│ Twilio webhook │                              │ iOS / Web clients    │
│ (idempotent)   │                              │ Drift CRDT sync      │
└─────┬──────────┘                              └───────────┬──────────┘
      │                                                     │
┌─────▼──────────────────────────────────────────────────────▼─────────┐
│ n8n CLUSTER (3 instances, leader via Postgres advisory lock)        │
│   Circuit breaker · DLQ · idempotence · health checks               │
└─────┬─────────────────────────┬─────────────────────┬─────────────────┘
      │                         │                     │
┌─────▼─────────┐    ┌─────────▼─────────┐    ┌──────▼──────┐
│ Anthropic     │    │ Supabase Pro      │    │ Resend Pro  │
│ Sonnet+Haiku  │    │ Postgres + PITR   │    │             │
│ retry budget  │    │ + Read replica    │    │             │
│               │    │ + RLS + Bloom     │    │             │
│               │    │   filter STOP     │    │             │
└───────────────┘    └─────────┬─────────┘    └─────────────┘
                                │
                     ┌──────────▼──────────┐
                     │ Edge Functions Deno │
                     │   warmed via cron   │
                     └──────────┬──────────┘
                                │
                     ┌──────────▼──────────┐
                     │ Sentry + Better Stack│
                     │ SLO P99 < 30s SMS    │
                     │ RTO ≤ 4h · RPO ≤ 1h  │
                     └──────────────────────┘
```

---

## 9 — Suivi

- [ ] Validation 7 corrections avec Dennis (technical lead)
- [ ] Spike PITR Supabase Pro (Sprint 9)
- [ ] Refresh score architecture trimestriel
- [ ] Si > 100 courtiers payants : ré-évaluer sharding + read replica
- [ ] Si > 1M messages : ré-évaluer LSM (Cassandra/Scylla) pour archive conversations

*Document v1.0 — 2026-05-08 — basé sur :*
- *Designing Data-Intensive Applications* — Martin Kleppmann (O'Reilly 2017)
- *Database Internals — A Deep Dive Into How Distributed Data Systems Work* — Alex Petrov (O'Reilly 2019, ISBN 978-1-492-04034-7)

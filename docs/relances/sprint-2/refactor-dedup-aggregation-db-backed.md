# Refactor : Dedup + Aggregation backed par Postgres

> Statut : backlog Sprint 2
> Date d'identification : 2026-05-11
> Workflow concerné : `next_move_intake_agent_v2` (id `nmmmJu6HRwq0nqyI`)

## Contexte

Le Sprint 1 a livré un mécanisme de dedup `from+body` et un Aggregate Buffer + Wait 3s + Flush If Latest pour gérer les bursts de SMS d'un même prospect. Le mécanisme s'appuie sur le **staticData n8n** (`$getWorkflowStaticData('global')`).

Tests de pilote (2026-05-11) ont révélé une **limitation architecturale** :

- `$getWorkflowStaticData` n'est **pas** partagé en temps réel entre exécutions concurrentes.
- Les writes sont committés à la fin de l'exécution.
- 2 webhooks Twilio quasi-simultanés (gigue de délivrance ~2-4s) → 2 exécutions parallèles → chacune lit un staticData vide → toutes deux passent le dedup → agent répond 2 fois.

Observation concrète : 2 SMS identiques `Maison à Verdun` envoyés en <2s → délivrés à n8n à 2.06s d'écart → dedup window 15s actif, mais les 2 execs ont lu staticData avant que l'autre ne commit → **2 réponses agent** envoyées à l'utilisateur.

## Solution : déplacer dedup + aggregation vers Postgres

### Migration

```sql
CREATE TABLE intake_state (
  message_sid TEXT PRIMARY KEY,
  from_phone TEXT NOT NULL,
  body TEXT NOT NULL, -- normalisé : .trim().toLowerCase()
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  flushed BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_intake_state_dedup
  ON intake_state (from_phone, body, received_at DESC)
  WHERE NOT flushed;
CREATE INDEX idx_intake_state_buffer
  ON intake_state (from_phone, received_at DESC)
  WHERE NOT flushed;

-- TTL cleanup (cron quotidien)
DELETE FROM intake_state WHERE received_at < NOW() - INTERVAL '24 hours';
```

### Refactor du workflow n8n

**Remplacer 3 Code nodes par des Postgres nodes** (ou Code nodes appelant Supabase REST API avec credentials gérés).

#### 1. `Dedup by messageSid` → `Atomic Dedup`

Query (Postgres node) :
```sql
WITH inserted AS (
  INSERT INTO intake_state (message_sid, from_phone, body)
  VALUES (
    '{{ $('Wait for Text Response').item.json.data.messageSid }}',
    '{{ $('Wait for Text Response').item.json.data.from }}',
    LOWER(TRIM('{{ $('Wait for Text Response').item.json.data.body }}'))
  )
  ON CONFLICT (message_sid) DO NOTHING
  RETURNING received_at
),
my_arrival AS (
  SELECT COALESCE(
    (SELECT received_at FROM inserted),
    (SELECT received_at FROM intake_state WHERE message_sid = '{{ ... }}')
  ) AS ts
),
is_first AS (
  SELECT NOT EXISTS (
    SELECT 1 FROM intake_state
    WHERE from_phone = '{{ ... }}'
      AND body = LOWER(TRIM('{{ ... }}'))
      AND received_at < (SELECT ts FROM my_arrival)
      AND received_at > (SELECT ts FROM my_arrival) - INTERVAL '15 seconds'
      AND NOT flushed
  ) AS should_continue
)
SELECT
  (SELECT should_continue FROM is_first) AS should_continue,
  '{{ ... }}'::text AS message_sid,
  '{{ ... }}'::text AS from_phone,
  '{{ ... }}'::text AS body,
  '{{ ... }}'::jsonb AS original_data;
```

Suivi d'un IF node `should_continue` → branche `true` continue, `false` exit.

#### 2. `Aggregate Buffer` → no-op (l'INSERT est déjà fait par Atomic Dedup)

Supprimer le node ; le Wait 3s reste.

#### 3. `Flush If Latest` → `Atomic Flush`

Query (Postgres node) après le Wait 3s :
```sql
WITH my_arrival AS (
  SELECT received_at FROM intake_state
  WHERE message_sid = '{{ ... }}'
),
am_latest AS (
  SELECT NOT EXISTS (
    SELECT 1 FROM intake_state
    WHERE from_phone = '{{ ... }}'
      AND received_at > (SELECT received_at FROM my_arrival)
      AND NOT flushed
  ) AS is_latest
),
flush_action AS (
  UPDATE intake_state
  SET flushed = TRUE
  WHERE from_phone = '{{ ... }}'
    AND NOT flushed
    AND (SELECT is_latest FROM am_latest)
  RETURNING body, received_at
)
SELECT
  COALESCE(STRING_AGG(body, ' ' ORDER BY received_at), '') AS aggregated_body,
  COUNT(*) > 0 AS should_continue
FROM flush_action;
```

Suivi d'un IF node `should_continue` → branche `true` continue vers `Real Estate Qualifier` avec `data.body = aggregated_body`, `false` exit.

#### 4. Mise à jour de `Real Estate Qualifier`

Changer son input `text` de `={{ $json.data.body }}` à `={{ $json.aggregated_body }}` (ou injecter dans data via SET node intermédiaire).

#### 5. Cleanup downstream

Les nodes `Upsert Prospect Early`, `Update Inbound Timestamp`, `Detect Keyword`, `Log Conv Inbound` qui consomment `$json.data.*` continuent à fonctionner via `$('Wait for Text Response').item.json.data.*` (ils utilisent déjà cette référence après le fix race condition).

## Atomicité garantie

- `INSERT ... ON CONFLICT DO NOTHING` est atomique au niveau Postgres.
- `UPDATE ... WHERE ... AND (CTE_condition)` est atomique dans une seule transaction.
- Deux exécutions concurrentes verront **toujours** un état cohérent — soit l'une "gagne" l'INSERT, soit elle voit le row de l'autre.

## Estimation

- Migration DB : 5 min
- Refactor 3 nodes + 2 IF nodes + rewiring : 30-45 min
- Tests de non-régression (S5, burst, sanity) : 15-30 min
- **Total : ~1h-1h30**

## Tests d'acceptation après refactor

| ID | Scénario | Attendu |
|---|---|---|
| S5 | 2 SMS identiques en <5s | 1 seule ligne `conv_in`, 1 seule réponse agent, 1 seule entry dans `n8n_chat_histories` (user+agent) |
| Burst | 3 SMS différents en <3s | 3 lignes `conv_in`, 1 seule réponse agent qui voit le body concaténé, n8n_chat_histories montre 1 user (body concaténé) + 1 agent |
| Sanity | 1 SMS solo | Comportement identique à aujourd'hui, latence ~15s |
| Retry Twilio | Même messageSid rejoué | Bloqué (premier passe seulement) |
| Spam 60s | 2 SMS identiques à 60s d'écart | Les DEUX passent (fenêtre de 15s expirée) |

## Bug parking lot (à fixer pendant le refactor)

Découverts pendant la session du 2026-05-11 — déjà corrigés mais à valider :

- ✅ `Log Conv Inbound` race condition (resequenced après `Upsert Prospect Early`)
- ✅ Check constraint `conversations.role` accepte maintenant `'assistant'`
- ✅ `=` parasite retiré de 3 queries (`Insert Blacklist`, `Update Inbound/Outbound Timestamp`)
- ✅ `Log Conv Outbound` / `Update Outbound Timestamp` utilisent maintenant `$json.to` au lieu de `$('Wait for Text Response')` pour éviter staleness

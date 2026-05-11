# Refactor : Dedup + Aggregation backed par Postgres

> Statut : **IMPLEMENTÉ** au cours de la session du 2026-05-11 (continuation après commit `a879816`)
> Test S5 (dedup identique) : **VALIDÉ** (conv_in=1, memory cohérente)
> Test 3 (burst aggregation) : **À VALIDER** dans la prochaine session
> Workflow concerné : `next_move_intake_agent_v2` (id `nmmmJu6HRwq0nqyI`)
> Supabase project : NextMoveMVP (id `fhqybnkxqfvbsjvwrcob`)

## Architecture finale

Migration appliquée : `intake_state_for_atomic_dedup_aggregation`

```sql
CREATE TABLE intake_state (
  message_sid TEXT PRIMARY KEY,
  from_phone TEXT NOT NULL,
  body TEXT NOT NULL, -- normalisé : LOWER(TRIM(body))
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  flushed BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX idx_intake_state_dedup ON intake_state (from_phone, body, received_at DESC) WHERE NOT flushed;
CREATE INDEX idx_intake_state_buffer ON intake_state (from_phone, received_at DESC) WHERE NOT flushed;
```

### Nouvelle topologie n8n (4 nouveaux nodes)

```
Filtre STOP [false]
  → Atomic Dedup (Postgres)           ← lock advisory + check 15s window + INSERT conditionnel
  → Should Process? (IF)              ← branche sur should_continue
      ├─ true  → [Upsert Prospect Early, Update Inbound Timestamp, Detect Keyword]
      └─ false → exit

Continuer? [false]
  → Wait (3s)
  → Atomic Flush (Postgres)           ← lock advisory + check am_latest + UPDATE...RETURNING
  → Should Flush? (IF)                ← branche sur should_continue
      ├─ true  → Real Estate Qualifier (avec data.body = aggregated_body)
      └─ false → exit
```

**Nodes retirés** : `Dedup by messageSid`, `Aggregate Buffer`, `Flush If Latest` (Code nodes race-y avec `$getWorkflowStaticData`).

### Query Atomic Dedup (clé du fix)

```sql
WITH lock_held AS (
  SELECT pg_advisory_xact_lock(hashtext('{from}'))
),
recent_dup AS (
  SELECT EXISTS (
    SELECT 1 FROM intake_state
    WHERE from_phone = '{from}'
      AND body = LOWER(TRIM($body${body}$body$))
      AND received_at > NOW() - INTERVAL '15 seconds'
      AND NOT flushed
  ) AS exists_dup FROM lock_held
),
inserted AS (
  INSERT INTO intake_state (message_sid, from_phone, body)
  SELECT '{sid}', '{from}', LOWER(TRIM($body${body}$body$))
  FROM recent_dup WHERE NOT exists_dup
  ON CONFLICT (message_sid) DO NOTHING RETURNING 1
)
SELECT EXISTS (SELECT 1 FROM inserted) AS should_continue;
```

**Clés du design** :
- `pg_advisory_xact_lock(hashtext(from_phone))` sérialise les transactions concurrentes pour le même expéditeur — sans bloquer les transactions d'autres expéditeurs.
- Check `recent_dup` AVANT INSERT (pas après). Sinon T1's Atomic Flush voit la row dup de T2 comme "newer" et n'aggrège jamais.
- `NOW() - INTERVAL '15 seconds'` au lieu d'un `my_record` CTE qui ne voit pas l'INSERT à cause du snapshot partagé du WITH.

### Query Atomic Flush

```sql
WITH my_record AS (
  SELECT received_at FROM intake_state WHERE message_sid = '{sid}'
),
am_latest AS (
  SELECT NOT EXISTS (
    SELECT 1 FROM intake_state
    WHERE from_phone = '{from}' AND received_at > (SELECT received_at FROM my_record) AND NOT flushed
  ) AS is_latest
),
flush_action AS (
  UPDATE intake_state SET flushed = TRUE
  WHERE from_phone = '{from}' AND NOT flushed AND (SELECT is_latest FROM am_latest)
  RETURNING body, received_at
)
SELECT
  COALESCE(STRING_AGG(body, ' ' ORDER BY received_at), '') AS aggregated_body,
  COUNT(*) > 0 AS should_continue
FROM flush_action;
```

Real Estate Qualifier reçoit `data.body = $json.aggregated_body` (au lieu de `$json.data.body`).

## Validation des tests (session 2026-05-11)

| Test | Statut | Observations |
|---|---|---|
| Sanity (1 SMS solo) | ✅ | Agent répond ~15s plus tard. conv_in=1, memory=2 turns. |
| **S5 dedup identique** | **✅** | 2× `Maison à Verdun` en <2s → conv_in=**1** (le 2ᵉ bloqué via lock+recent_dup), memory cohérente, 1 SMS reçu par testeuse. |
| Burst aggregation (3 different) | ⏳ | À tester dans prochaine session — devrait passer car aggregation par Atomic Flush déjà validée sur petit cas (test S5 ter avant fix : flush UPDATE...RETURNING fonctionne, just aggregait des dups). |

## Bug ouvert (parking lot)

**`Log Conv Outbound` + `Update Outbound Timestamp` insèrent 0 row mais retournent `success: true`** — depuis le début de la session. Plusieurs tentatives :
- Changement `$('Wait for Text Response')` → `$json.to` → fonctionne **une fois** puis retombe en échec
- Revert vers `$('Wait for Text Response')` après le refactor

Symptôme : exec n8n retourne success, mais query manuelle (même body+sid+to) insère bien quand exécutée à la main. Suggère que **n8n n'envoie pas la query que le node UI affiche**, ou que les valeurs sont undefined/empty au runtime.

Hypothèses non testées :
- `continueOnFail: true` + `onError: continueRegularOutput` masquent l'erreur réelle
- Activer Postgres `log_statement = 'all'` pour capturer la SQL réelle
- Ajouter une `RETURNING id` au query pour forcer n8n à retourner la row (au lieu de juste success)
- Vérifier si `pairedItem` est mal résolu (output Log Conv Outbound montre `pairedItem: [{item: 0}]` — array, alors que Upsert montre `pairedItem: {item: 0}` — object)

Workaround possible : remplacer Log Conv Outbound par un Code node qui utilise `$('Response Text from Agent').first().json.to` explicitement.

## État DB après session

À la fin de la session :
- prospect `+15794216910` toujours en DB (testeuse — femme de Dennis)
- `intake_state` peut contenir des rows de test (flushed=true majoritairement)
- `conversations` peut être vide ou contenir 1 row inbound selon le dernier test

## Reprise prochaine session

1. Wipe DB : `DELETE FROM conversations; DELETE FROM prospects; DELETE FROM blacklist; DELETE FROM n8n_chat_histories; DELETE FROM intake_state;`
2. Désactiver/réactiver workflow `nmmmJu6HRwq0nqyI` dans n8n
3. **Test burst** : testeuse envoie 3 SMS différents en <3s → valider 1 réponse agent, aggregated_body correct dans memory
4. **Debug Log Conv Outbound** : tenter Code node ou logging Postgres pour capturer la query réelle

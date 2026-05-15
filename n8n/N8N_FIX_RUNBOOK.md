# n8n Workflow — Runbook de correctifs critiques

> Cible : `next_move_intake_agent_v2.json` → version durcie production.
> Audit du 2026-05-15 a identifié 4 défauts bloquants. Ce runbook décrit
> les changements à appliquer dans l'UI n8n + les snippets prêts à coller.

## Défauts adressés

| # | Défaut | Symptôme | Sévérité |
|---|--------|----------|----------|
| 1 | SMS envoyé AVANT persistence | Historique conversations cassé si node Postgres échoue | CRITIQUE |
| 2 | Aucun écrit dans `conversations` (table iOS) | Dashboard iOS vide même si SMS reçu/envoyé | CRITIQUE |
| 3 | STOP CASL : pas d'écriture dans `sms_optout` | Récidive d'envoi possible, non conforme CASL | CRITIQUE |
| 4 | Zéro retry / error handling | Échec silencieux sur tout node Twilio ou Postgres | IMPORTANT |
| 5 | Parsing JSON regex sur sortie Claude | Extraction aléatoire des champs structurés | IMPORTANT |

## Prérequis

1. **Migration 008** appliquée : `008_convergence_canonical_schema.sql`
2. Credential Postgres pointant sur la base canonique (Supabase ca-central-1)
3. Credential Twilio + Anthropic configurées dans n8n

---

## Étape 1 — Ajouter 4 nodes Postgres

Dans l'UI n8n, ouvrir le workflow et ajouter les 4 nodes suivants. Les snippets JSON correspondants sont dans `n8n/node-snippets/`.

### 1.1 — `Check SMS Opt-out` (Postgres, executeQuery)

**Position** : juste après `Filtre STOP` (branche FALSE — pas un STOP).
**Action** : interroge la fonction `is_phone_optout()`. Si TRUE, court-circuiter le flow.

```sql
SELECT public.is_phone_optout('{{ $json.data.from }}'::text) AS is_optout;
```

Brancher : `Filtre STOP (false) → Check SMS Opt-out → IF (is_optout = true → STOP, else → Dedup by messageSid)`.

→ Voir [node-snippets/check_sms_optout.json](node-snippets/check_sms_optout.json)

### 1.2 — `Record STOP in sms_optout` (Postgres, executeQuery)

**Position** : sur la branche TRUE de `Filtre STOP`, AVANT `Confirmer Desabonnement`.
**Action** : enregistre l'opt-out CASL avant d'envoyer la confirmation.

```sql
INSERT INTO public.sms_optout (telephone, reason, source_message)
VALUES (
  '{{ $json.data.from }}',
  'stop_keyword',
  '{{ $json.data.body }}'
)
ON CONFLICT (telephone) DO UPDATE SET created_at = now();
```

Brancher : `Filtre STOP (true) → Record STOP in sms_optout → Confirmer Desabonnement`.

→ Voir [node-snippets/record_stop_optout.json](node-snippets/record_stop_optout.json)

### 1.3 — `Persist Inbound Message` (Postgres, executeQuery)

**Position** : juste après `Wait` (Twilio rate-limit), AVANT `Real Estate Qualifier`.
**Action** : log le message entrant prospect → conversations.

```sql
INSERT INTO public.conversations (prospect_id, direction, sender, content, sent_at)
SELECT
  p.id,
  'inbound',
  'prospect',
  '{{ $('Wait for Text Response').item.json.data.body }}',
  now()
FROM public.prospects p
WHERE p.telephone = '{{ $('Wait for Text Response').item.json.data.from }}'
  AND p.deleted_at IS NULL
LIMIT 1;
```

**Note** : si le prospect n'existe pas encore, le INSERT ne fait rien (lookup retourne 0 rows). C'est OK — `Build Upsert Query` plus loin créera le prospect, et un follow-up Postgres node persistera l'historique.

→ Voir [node-snippets/persist_inbound.json](node-snippets/persist_inbound.json)

### 1.4 — `Persist Outbound Message` (Postgres, executeQuery)

**Position** : entre `Wait Typing` et `Response Text from Agent` (BEFORE Twilio send).
**Action** : log le message sortant Klaris → conversations AVANT envoi SMS.

```sql
INSERT INTO public.conversations (prospect_id, direction, sender, content, sent_at)
SELECT
  p.id,
  'outbound',
  'klaris',
  '{{ $('Delai Humain').item.json.output }}',
  now()
FROM public.prospects p
WHERE p.telephone = '{{ $('Wait for Text Response').item.json.data.from }}'
  AND p.deleted_at IS NULL
LIMIT 1
RETURNING id;
```

Brancher : `Wait Typing → Persist Outbound Message → Response Text from Agent`.

→ Voir [node-snippets/persist_outbound.json](node-snippets/persist_outbound.json)

---

## Étape 2 — Modifier `Build Upsert Query` pour INSERT + RETURNING id

Le node `Build Upsert Query` actuel construit un INSERT brut. Le modifier pour :

1. **UPSERT** (utiliser la nouvelle contrainte `UNIQUE(courtier_id, telephone)`)
2. **RETURNING id** pour permettre les écrits conversations qui suivent

Remplacer le contenu JS du node par :

```javascript
// Build Upsert Query — v3 (post-migration 008)
const phone = $('Wait for Text Response').item.json.data.from;
const summary = $('Summarize Transcript').item.json.output.summary || '';
const transcript = $('Summarize Transcript').item.json.output.transcript || '';

const isVendeur = /(vendre|vente|vendeur|courtier inscripteur)/i.test(summary);
const typeProjet = isVendeur ? 'vendeur' : 'acheteur';

// Échappement SQL safe — single quotes doublés
const escape = (s) => String(s || '').replace(/'/g, "''");

const query = `
INSERT INTO public.prospects (
  canal_source, statut, telephone, courtier_id, type_projet,
  score_chaleur, langue_preferee
)
VALUES (
  'sms',
  'en_qualification',
  '${escape(phone)}',
  (SELECT id FROM public.courtiers LIMIT 1),
  '${typeProjet}',
  0,
  'fr'
)
ON CONFLICT (courtier_id, telephone) DO UPDATE
  SET statut = EXCLUDED.statut,
      updated_at = now()
RETURNING id;
`;

return [{ json: { query, phone, summary, transcript, typeProjet } }];
```

---

## Étape 3 — Activer `retryOnFail` sur tous les nodes I/O

Pour chaque node listé ci-dessous, ouvrir Settings (3 dots → Settings) :

| Node | Settings |
|------|----------|
| `Wait for Text Response` (Twilio Trigger) | Retry n/a (trigger) |
| `Filtre STOP` (IF) | n/a |
| `Confirmer Desabonnement` (Twilio) | retryOnFail: true · maxTries: 3 · waitBetweenTries: 2000 ms |
| `Record STOP in sms_optout` (Postgres) | retryOnFail: true · maxTries: 3 · waitBetweenTries: 1000 ms |
| `Check SMS Opt-out` (Postgres) | retryOnFail: true · maxTries: 3 · waitBetweenTries: 1000 ms |
| `Dedup by messageSid` (Code) | n/a |
| `Wait` (rate-limit) | n/a |
| `Persist Inbound Message` (Postgres) | retryOnFail: true · maxTries: 3 · continueOnFail: true |
| `Real Estate Qualifier` (Agent) | retryOnFail: true · maxTries: 2 · waitBetweenTries: 3000 ms |
| `Postgres Chat Memory` | retryOnFail: true · maxTries: 3 |
| `Check if Conversation Completed` (IF) | n/a |
| `Thank Your Text` (Twilio) | retryOnFail: true · maxTries: 3 · waitBetweenTries: 2000 ms |
| `Delai Humain` (Code) | n/a |
| `Wait Typing` | n/a |
| `Persist Outbound Message` (Postgres) | retryOnFail: true · maxTries: 3 · continueOnFail: true |
| `Response Text from Agent` (Twilio) | retryOnFail: true · maxTries: 3 · waitBetweenTries: 2000 ms |
| `Query Supabase for conversation history` (Postgres) | retryOnFail: true · maxTries: 3 |
| `Build Upsert Query` (Code) | n/a |
| `Execute Upsert` (Postgres) | retryOnFail: true · maxTries: 3 · waitBetweenTries: 1000 ms |
| `Send Lead to owner` (Twilio) | retryOnFail: true · maxTries: 3 · waitBetweenTries: 2000 ms |

**`continueOnFail: true`** sur les 2 nodes Persist : si l'historique ne peut pas être écrit (rare), on ne bloque PAS l'envoi SMS prospect. Le ratio risque/UX favorise l'envoi. Une alerte Sentry sera levée séparément.

---

## Étape 4 — Remplacer le parsing JSON regex par Structured Output

Le node `Summarize Transcript` extrait `summary` + `transcript` via parsing fragile.
Remplacer par un `Structured Output Parser` Anthropic natif :

1. Ouvrir le node `Structured Output Parser1`
2. Définir le schéma JSON suivant :

```json
{
  "type": "object",
  "properties": {
    "summary": {
      "type": "string",
      "description": "Résumé du besoin client en 3-5 lignes."
    },
    "transcript": {
      "type": "string",
      "description": "Transcript brut formaté."
    },
    "type_projet": {
      "type": "string",
      "enum": ["acheteur", "vendeur"],
      "description": "Type de projet identifié."
    },
    "score_chaleur": {
      "type": "integer",
      "minimum": 0,
      "maximum": 10,
      "description": "Score de chaleur 0-10 selon critères qualification."
    },
    "qualified": {
      "type": "boolean",
      "description": "true si toutes les questions clés ont été obtenues."
    }
  },
  "required": ["summary", "transcript", "type_projet", "score_chaleur", "qualified"]
}
```

3. Mettre à jour le prompt du `Summarize Transcript` agent pour exiger le format JSON strict.
4. Dans `Build Upsert Query`, lire directement `$('Summarize Transcript').item.json.output.type_projet` et `.score_chaleur` au lieu de re-deviner via regex.

---

## Étape 5 — Tester

Après application :

1. Envoyer "Bonjour je cherche un duplex" → vérifier conversations table (inbound + outbound rows).
2. Envoyer "STOP" → vérifier `sms_optout` table + plus aucun SMS reçu après ce message.
3. Couper la connexion Twilio momentanément → vérifier que le retry kick in.
4. Forcer une erreur SQL sur `Persist Inbound` (mauvais credential) → vérifier que le flow continue + alerte Sentry.

---

## Étape 6 — Export & versionner

Une fois le workflow stable :

```bash
# Exporter via UI n8n : Settings → Download as JSON
# Renommer en next_move_intake_agent_v3.json
mv next_move_intake_agent_v3.json /Users/.../NextMove/next_move_intake_agent_v3.json
git add next_move_intake_agent_v3.json
git rm next_move_intake_agent_v2.json
git commit -m "feat(n8n): v3 workflow — persist before send + STOP + retry"
```

---

## Rollback

Si v3 casse en prod :

1. Désactiver workflow v3 dans n8n
2. Réactiver v2 (l'export précédent reste dans GitHub history)
3. Investiguer logs Sentry + n8n execution history
4. Aucune perte de données : migration 008 est compatible avec v2 (juste tables `conversations`/`relances` plus riches, v2 n'y écrit pas).

---

**Contact :** tech@nextmove.app · Klaris — une marque Next Move · 2026 · Confidentiel

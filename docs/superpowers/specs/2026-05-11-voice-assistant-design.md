# Voice Assistant Telegram — Design

**Date** : 2026-05-11
**Auteur** : Dennis Marfo + Claude
**Statut** : Design validé, en attente d'implémentation
**Branche cible** : nouvelle branche dérivée de `feat/conversations-dashboard-from-main` (ou `main` après merge PR #3)

## Objectif

Permettre à un courtier (Joanel) d'interroger oralement la base NextMove via Telegram en lui envoyant un message vocal et de recevoir une réponse vocale courte avec les infos demandées.

**Exemple** : *"Combien de prospects cherchent à Verdun ?"* → *"Tu as 3 prospects qui cherchent à Verdun. Marie cherche un condo à 380k, David un duplex pour investissement à 550k, et Sophie un plex 4-5 logements."*

## Scope

**Inclus (MVP démo)** :
- Canal Telegram (bot 1:1)
- Lookup / résumés read-only sur prospects, conversations, besoins acheteur/vendeur, relances
- Single-tenant : 1 courtier ↔ 1 telegram_user_id allowlisté
- Réponse vocale en français standard via OpenAI TTS

**Hors scope (post-démo)** :
- Actions (créer relance, modifier prospect, envoyer SMS)
- Multi-tenant (table `courtier_telegram_links`)
- Briefing audio quotidien proactif
- Version web (mic dans le dashboard `index.html`)
- Voice cloning de Joanel
- Streaming TTS (latence <3s)

## Architecture

```
                                ┌─────────────────────────────────┐
                                │  Telegram Bot (@nextmove_voice_bot)  │
                                └────────────────┬────────────────┘
                                                 │ voice msg (OGG/Opus)
                                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│  n8n Workflow: next_move_voice_assistant                            │
│                                                                     │
│  1. Telegram Trigger (on_message_voice)                             │
│  2. Authorize  ── check telegram_user_id ∈ allowlist                │
│  3. Download Voice File (Telegram getFile + HTTP GET binary)        │
│  4. Whisper STT (OpenAI /v1/audio/transcriptions, lang=fr)          │
│  5. Claude Agent (with tools, system prompt = courtier context)     │
│           │                                                         │
│           ├─→ Tool: query_prospects(filters)   ──┐                  │
│           ├─→ Tool: query_conversations(...)     │ Supabase REST    │
│           ├─→ Tool: query_relances(...)          │ (filtered by     │
│           ├─→ Tool: query_besoins(...)           │  courtier_id)    │
│           └─→ (loop until done)              ────┘                  │
│                                                                     │
│  6. OpenAI TTS (/v1/audio/speech, voice=nova, model=tts-1)          │
│  7. Send Voice Reply via Telegram sendVoice                         │
└─────────────────────────────────────────────────────────────────────┘
```

**Stack** :
- **Hosting** : workflow n8n dédié `next_move_voice_assistant` (séparé de l'intake SMS `next_move_intake_agent_v2`)
- **STT** : OpenAI Whisper `whisper-1` (FR natif, excellent en québécois)
- **LLM** : Claude Sonnet 4.6 (`claude-sonnet-4-6`) avec tool calling
- **TTS** : OpenAI `tts-1`, voix `nova`, format `opus` (compatible Telegram sendVoice direct)
- **DB** : Supabase REST API via la même anon key que le dashboard

**Latence cible** : 6-12 s end-to-end (Whisper ~1.5s + Claude avec 1-3 tool calls ~3-6s + TTS ~1.5s + I/O Telegram ~1-2s).

## Telegram setup

### Création du bot
1. `/newbot` à @BotFather sur Telegram
2. Nom : `NextMove Voice` / username : `@nextmove_voice_bot` (ou autre disponible)
3. BotFather renvoie un token type `8123456789:AAH...` → stocké comme credential n8n
4. `/setjoingroups` → Disable (bot 1:1 only)

### Authentification (allowlist hardcodée pour MVP)
- Joanel envoie son premier message au bot → on récupère `message.from.id` (entier, ex: `123456789`)
- Hardcodé dans le node n8n "Authorize" : `ALLOWED_USERS = { '123456789': '0d99b83a-91db-42cd-a19b-2e88384c67a7' }` (Dennis Marfo)
- Tout message d'un user_id inconnu → réponse texte "Accès refusé" + log + arrêt

Pas d'OAuth, pas de PIN. Le `telegram_user_id` est garanti unique et non-spoofable par Telegram (auth via token bot).

### Multi-tenant futur (out-of-scope démo)
Table à créer :
```sql
CREATE TABLE courtier_telegram_links (
  telegram_user_id BIGINT PRIMARY KEY,
  courtier_id UUID NOT NULL REFERENCES courtiers(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Workflow n8n : nodes détaillés

### [1] Telegram Trigger
- Event : `message`
- Filter (post-trigger via IF) : `$json.message.voice IS NOT NULL`
- Output : `{ message: { from: {id}, voice: {file_id, duration, mime_type}, chat: {id} } }`

### [2] IF: Authorize
- Condition : `$json.message.from.id IN [Joanel user_id]`
- True branch → continuer
- False branch → [2b] Telegram Send Text "Accès refusé. Contactez l'admin." → end

### [3] Telegram getFile
- Method : `getFile`
- file_id : `={{ $json.message.voice.file_id }}`
- Output : `{ file_path: "voice/file_42.oga" }`

### [4] HTTP Request: Download audio binary
- URL : `https://api.telegram.org/file/bot{{TELEGRAM_TOKEN}}/{{file_path}}`
- Response format : `file` (binary)
- Stored in : `$binary.data`

### [5] HTTP Request: Whisper STT
- POST `https://api.openai.com/v1/audio/transcriptions`
- Auth : Bearer `{{OPENAI_KEY}}`
- Body (multipart/form-data) :
  - `file` = `$binary.data`
  - `model` = `whisper-1`
  - `language` = `fr`
- Output : `{ text: "Combien de prospects à Verdun ?" }`

### [6] Code: Claude orchestration (tool calling loop)
**Pourquoi un node Code plutôt que AI Agent** : le node AI Agent de n8n n'a pas une gestion propre des tools custom HTTP avec Claude. Un node Code JS donne :
- Contrôle total de la boucle `while tool_use`
- Réutilisation du pattern Anthropic SDK déjà rodé sur l'intake SMS
- ~60 lignes JS lisibles, testables

**Pseudo-code** :
```js
const ANTHROPIC_KEY = $env.ANTHROPIC_KEY;
const COURTIER_ID = '0d99b83a-91db-42cd-a19b-2e88384c67a7';
const userQuestion = $json.text;

const tools = [/* 4 tools définis section "Tools Claude" */];
const systemPrompt = `Tu es l'assistant vocal de Dennis Marfo, courtier immobilier.
Réponds en 1-2 phrases courtes, ton naturel québécois pro, sans jargon.
Ne mentionne JAMAIS de numéros de téléphone (toxic en audio).
Si la requête est ambiguë, demande clarification.
Tu n'as accès qu'aux prospects de Dennis. Refuse poliment toute demande hors scope.`;

let messages = [{ role: 'user', content: userQuestion }];
let iterations = 0;
const MAX_ITERATIONS = 5;

while (iterations++ < MAX_ITERATIONS) {
  const response = await callClaude({ system: systemPrompt, messages, tools, max_tokens: 400 });
  messages.push({ role: 'assistant', content: response.content });

  if (response.stop_reason === 'end_turn') {
    return { answer_text: extractText(response.content) };
  }

  if (response.stop_reason === 'tool_use') {
    const toolResults = [];
    for (const block of response.content) {
      if (block.type === 'tool_use') {
        const result = await executeTool(block.name, block.input, COURTIER_ID);
        toolResults.push({ type: 'tool_result', tool_use_id: block.id, content: JSON.stringify(result) });
      }
    }
    messages.push({ role: 'user', content: toolResults });
  }
}

return { answer_text: "Je n'ai pas tout trouvé, peux-tu reformuler ?" };
```

### [7] HTTP Request: OpenAI TTS
- POST `https://api.openai.com/v1/audio/speech`
- Body JSON :
  ```json
  {
    "model": "tts-1",
    "voice": "nova",
    "input": "{{ $json.answer_text }}",
    "response_format": "opus"
  }
  ```
- Response : binary OGG/Opus

**À valider en test E2E** : OpenAI TTS `response_format: "opus"` retourne un fichier OGG container avec codec Opus, ce qui correspond au format attendu par Telegram `sendVoice`. Si Telegram refuse (erreur "wrong file type"), fallback : `response_format: "mp3"` puis convertir via un node ffmpeg ou utiliser `sendAudio` à la place.

### [8] Telegram sendVoice
- chat_id : `={{ $('Telegram Trigger').first().json.message.chat.id }}`
- voice : `$binary.data` (OGG/Opus directement compatible)
- duration : optionnel (Telegram l'infère)

## Tools Claude : schémas

Tous read-only. Tous injectent `courtier_id = COURTIER_ID` côté serveur (le LLM ne peut pas le bypass).

### Tool 1 — `query_prospects`
```json
{
  "name": "query_prospects",
  "description": "Cherche des prospects du courtier. Retourne nom, prénom, type_projet, statut, score_chaleur, budget_max, secteur, type_bien, resume_ia. Ne retourne JAMAIS telephone/email.",
  "input_schema": {
    "type": "object",
    "properties": {
      "secteur": {"type": "string", "description": "Mot-clé secteur (ex: 'Verdun', 'Anjou'). Matché en ILIKE."},
      "type_projet": {"type": "string", "enum": ["acheteur", "vendeur"]},
      "statut": {"type": "string", "enum": ["nouveau","en_qualification","qualifie","en_recherche","offre_deposee","conclu","perdu"]},
      "score_min": {"type": "integer", "minimum": 0, "maximum": 10},
      "type_bien": {"type": "string", "description": "Mot-clé type de bien (ex: 'condo', 'duplex')"},
      "limit": {"type": "integer", "default": 10, "maximum": 50}
    }
  }
}
```
**Backend** :
```
GET /rest/v1/prospects
  ?courtier_id=eq.{COURTIER_ID}
  &select=id,prenom,nom,type_projet,statut,score_chaleur,budget_max,secteur,type_bien,resume_ia
  &[secteur=ilike.*{secteur}*]
  &[type_projet=eq.{type_projet}]
  &[statut=eq.{statut}]
  &[score_chaleur=gte.{score_min}]
  &[type_bien=ilike.*{type_bien}*]
  &limit={limit}
```

### Tool 2 — `query_conversations`
Récupère les N derniers messages d'un prospect. Utile pour *"Qu'est-ce que Marie m'a dit en dernier ?"*

```json
{
  "name": "query_conversations",
  "description": "Récupère les N derniers messages d'une conversation avec un prospect.",
  "input_schema": {
    "type": "object",
    "properties": {
      "prospect_id": {"type": "string", "description": "UUID prospect (préféré)"},
      "prospect_nom": {"type": "string", "description": "Nom partiel à matcher (fallback si pas d'UUID)"},
      "last_n": {"type": "integer", "default": 5, "maximum": 20}
    }
  }
}
```
**Backend** :
- Si `prospect_id` fourni : `GET /rest/v1/conversations?prospect_id=eq.{id}&order=created_at.desc&limit={last_n}&select=role,contenu,created_at`
- Sinon résoudre via `query_prospects` ILIKE nom → récupérer id → query conversations
- Filtrer côté serveur que `prospect.courtier_id = COURTIER_ID`

### Tool 3 — `query_besoins`
Détails acheteur (`besoins_acheteur`) ou vendeur (`besoins_vendeur`).

```json
{
  "name": "query_besoins",
  "description": "Récupère les critères de recherche (acheteur) ou infos bien à vendre (vendeur) d'un prospect.",
  "input_schema": {
    "type": "object",
    "properties": {
      "prospect_id": {"type": "string"},
      "type": {"type": "string", "enum": ["acheteur", "vendeur"]}
    },
    "required": ["prospect_id", "type"]
  }
}
```
**Backend** :
- Acheteur : `GET /rest/v1/besoins_acheteur?prospect_id=eq.{id}&select=*`
- Vendeur : `GET /rest/v1/besoins_vendeur?prospect_id=eq.{id}&select=*`
- Pre-check que le prospect appartient bien à `COURTIER_ID`

### Tool 4 — `query_relances`
Relances à venir / planifiées / en retard.

```json
{
  "name": "query_relances",
  "description": "Récupère les relances planifiées, à venir, ou en retard pour le courtier.",
  "input_schema": {
    "type": "object",
    "properties": {
      "statut": {"type": "string", "enum": ["planifiee","envoyee","annulee","echouee","bloquee","differee"]},
      "date_avant": {"type": "string", "description": "ISO 8601, retourne relances avec date_prevue <= cette date"},
      "prospect_id": {"type": "string"}
    }
  }
}
```
**Backend** :
```
GET /rest/v1/relances
  ?select=type_relance,date_prevue,statut,contenu,prospects(prenom,nom,courtier_id)
  &prospects.courtier_id=eq.{COURTIER_ID}
  &[statut=eq.{statut}]
  &[date_prevue=lte.{date_avant}]
  &[prospect_id=eq.{prospect_id}]
  &order=date_prevue.asc
```

### Garde-fous LLM
- **System prompt** : restriction à `courtier_id` injectée
- **`max_tokens` réponse** : 400 (force concision adaptée au voice)
- **Max iterations tool_use** : 5 (anti-loop)
- **PII** : pas de numéros de téléphone dans la sortie vocale (instruction system prompt)

### Pourquoi ces 4 tools et pas un seul `execute_sql`
- **Sécurité** : tools paramétrés = surface d'attaque minimale, pas de SQL injection possible
- **Précision** : Claude choisit le bon tool plutôt que d'inventer une SQL → moins d'erreurs
- **Coût tokens** : tools spécifiques retournent juste les champs utiles, pas des `SELECT *`

## Error handling

| Node | Erreur possible | Comportement |
|---|---|---|
| Authorize | user_id pas dans allowlist | Reply texte "Accès refusé. Contactez l'admin." + log |
| Telegram getFile | file expiré (>1h) | Reply texte "Audio expiré, merci de renvoyer" |
| Whisper | timeout / audio illisible | Reply texte "Désolé, je n'ai pas bien entendu. Réessaie ?" |
| Claude | tool error (Supabase down, schema mismatch) | Retry 1× ; si toujours fail → "Petit pépin technique, réessaie dans 30s" |
| Claude | max iterations atteint (>5 tool calls) | Force réponse partielle "Je n'ai pas tout trouvé, peux-tu reformuler ?" |
| OpenAI TTS | quota / timeout | Fallback : envoyer la réponse **en texte** Telegram au lieu de voice |
| Telegram sendVoice | upload fail | Retry 1× ; sinon reply texte |

**Principe** : aucun chemin ne doit aboutir à un silence côté Joanel. Si la voix échoue, fallback texte. Si tout échoue, on dit qu'on a un pépin.

## Testing plan

### Unit (tools backend)
- Appeler chaque endpoint Supabase REST manuellement avec `courtier_id` connu
- Valider format de retour, présence des champs, filtrage RBAC

### Intégration (Claude + tools simulés)
- Script Node mock les tools, envoie 5 questions texte :
  - "combien de prospects à Anjou"
  - "donne-moi mes prospects chauds"
  - "qu'est-ce que Marie Tremblay m'a dit en dernier"
  - "mes relances de la semaine"
  - "budget de Sophie Lavoie"
- Valider la trace de raisonnement Claude (bon tool, bons paramètres, réponse cohérente)

### End-to-end (audio)
- 5 questions vocales depuis Telegram
- Mesurer : latence (cible <12s), qualité audio sortie, exactitude des réponses
- Edge cases :
  - Question hors-scope : *"c'est quoi la météo"* → "Je suis spécialisé dans tes prospects, pas la météo"
  - Question ambiguë : *"Marie qui"* → Claude demande clarification
  - User non-allowlisté : reply "Accès refusé"

## Plan de mise en place

| # | Action | Owner | Durée |
|---|---|---|---|
| 1 | Créer le bot Telegram via @BotFather | Dennis | 5 min |
| 2 | Récupérer son `telegram_user_id` (envoyer test msg) | Dennis | 1 min |
| 3 | Créer credentials n8n (Telegram + OpenAI déjà existant + Anthropic) | Dennis | 5 min |
| 4 | Importer/construire le workflow `next_move_voice_assistant` | Claude (via n8n MCP) | 30 min |
| 5 | Hardcoder user_id ↔ courtier_id allowlist | Claude | 2 min |
| 6 | Test end-to-end + ajustements prompt système | Dennis + Claude | 30 min |
| **Total** | | | **~75 min** |

## Limites connues (acceptables pour MVP)

- **Audio long >25 MB** : Whisper rejette. En pratique = ~30 min d'audio, jamais atteint en usage normal. Pas géré, on laisse l'erreur natif Whisper se propager dans le fallback texte.
- **Requêtes concurrentes** : si Joanel envoie 2 voice messages en <5s, n8n créera 2 exécutions parallèles indépendantes. Pas de risque de race sur la lecture (read-only), juste 2 réponses retournées dans l'ordre où les exécutions se terminent.
- **Rate limiting** : pas implémenté MVP. Un user mal intentionné qui spam le bot consommerait des $ Whisper/Claude/TTS. Mitigé par l'allowlist hardcodée (seul Joanel passe). Post-MVP : ajouter un compteur par `telegram_user_id` dans Supabase ou Redis.
- **Logs** : les exécutions n8n contiennent déjà toutes les traces. Pas de logger custom MVP. Si besoin de debug post-démo : `n8n_executions` MCP tool.
- **Pas de mémoire conversationnelle** : chaque message vocal est traité indépendamment. Si Joanel dit *"et le suivant"*, le bot n'a pas de contexte. Post-MVP : ajouter contexte des N derniers échanges via une table `voice_session_history`.
- **Pas de timeouts custom** : on s'appuie sur les timeouts par défaut de n8n (~5min par exécution). Largement suffisant.

## Coûts estimés

Par question vocale (~30s audio in, ~15s audio out, ~2 tool calls) :
- Whisper STT : ~$0.006
- Claude Sonnet 4.6 (2k tokens in + 400 out) : ~$0.012
- OpenAI TTS : ~$0.005
- **Total : ~$0.025 par question**

Pour 200 questions/mois en usage régulier : ~$5/mois.

## Références
- Memory : `nextmove_project_ids.md` (workflow n8n, Supabase project, Twilio number)
- Memory : `nextmove_dashboard_architecture.md` (anon key, RLS, schéma conversations)
- Memory : `n8n_workflow_update_quirks.md` (gotchas update_partial_workflow)
- Commit `ea712cf` : `conversations.courtier_id` + index pour le RBAC

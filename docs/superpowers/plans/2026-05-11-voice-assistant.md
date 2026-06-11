# Voice Assistant Telegram — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construire le workflow n8n `next_move_voice_assistant` qui permet à Dennis (courtier) d'envoyer un message vocal Telegram et de recevoir une réponse vocale courte basée sur la BD Supabase.

**Architecture:** Telegram bot (1:1) → workflow n8n dédié → Whisper STT → Claude Sonnet 4.6 avec 4 tools paramétrés Supabase REST (filtrés par `courtier_id`) → OpenAI TTS (voix `nova`, format opus) → Telegram sendVoice. Single-tenant MVP avec allowlist hardcodée.

**Tech Stack:**
- n8n cloud (workflow runtime, manipulé via le MCP `claude_ai_n8n-mcp`)
- Telegram Bot API (création via @BotFather)
- OpenAI Whisper API (`whisper-1`) + OpenAI TTS API (`tts-1`, voice `nova`)
- Anthropic Claude Sonnet 4.6 (`claude-sonnet-4-6`) via Anthropic Messages API
- Supabase REST API (anon key, table `prospects`, `conversations`, `besoins_acheteur`, `besoins_vendeur`, `relances`)

**Référence spec:** `docs/superpowers/specs/2026-05-11-voice-assistant-design.md`

**Notes spécifiques n8n:**
- Les "tests" sont des **exécutions manuelles** (pas pytest). Chaque task termine par une exécution déclenchée + validation visuelle des outputs dans l'UI n8n ou via `mcp__claude_ai_n8n-mcp__n8n_executions`.
- "Commit" = soit (a) sauvegarder le workflow via le bouton n8n save (versioning auto via `n8n_workflow_versions`), soit (b) exporter le JSON dans le repo (Task 8). Pour itérer vite, préférer (a) pendant la construction. Faire (b) à la fin.

**Variables critiques (à remplacer pendant l'exécution):**
- `<TELEGRAM_BOT_TOKEN>` : récupéré à la Task 1 depuis @BotFather
- `<DENNIS_TELEGRAM_USER_ID>` : récupéré à la Task 1 (entier ~10 chiffres)
- `<COURTIER_ID>` = `0d99b83a-91db-42cd-a19b-2e88384c67a7` (Dennis Marfo, fixe)
- `<SUPABASE_URL>` = `https://fhqybnkxqfvbsjvwrcob.supabase.co`
- `<SUPABASE_ANON_KEY>` : déjà dans `index.html` ligne 511, à réutiliser
- `<OPENAI_API_KEY>` : déjà configuré comme credential n8n (vérifier à la Task 2)
- `<ANTHROPIC_API_KEY>` : déjà configuré comme credential n8n (vérifier à la Task 2)

---

## File Structure

Aucun nouveau fichier de code dans le repo (le workflow vit sur n8n cloud). Seuls fichiers touchés à la fin :

- **Créé** : `next_move_voice_assistant.json` (export du workflow à la racine du repo, Task 8) — cohérent avec `next_move_intake_agent_v2.json` existant
- **Créé** : `mvp_adjointe_ia/src/db/migration_005_voice_audit_log.sql` (optionnel, Task 7) si on décide d'auditer les questions vocales en DB. Sinon les exécutions n8n suffisent comme audit.

Le code JS du Code node Claude (Task 4) vit dans le workflow JSON, ~80 lignes — pas dans un fichier séparé.

---

## Task 1: Setup Telegram bot + récupérer user_id Dennis

**Files:** Aucun (setup externe Telegram + n8n credentials)

**Owner:** Dennis (manuel, 10 min)

- [ ] **Step 1: Créer le bot via @BotFather**

  1. Ouvrir Telegram → chercher `@BotFather` → `/start`
  2. Envoyer `/newbot`
  3. Nom du bot : `NextMove Voice`
  4. Username : `nextmove_voice_bot` (si pris : `nextmove_voice_dennis_bot` ou similaire)
  5. BotFather renvoie un message avec un token type `8123456789:AAH...`
  6. **Copier le token immédiatement** (ne sera plus jamais affiché en clair)

- [ ] **Step 2: Restreindre le bot aux 1:1**

  Toujours dans @BotFather :
  1. `/mybots` → choisir le bot
  2. `Bot Settings` → `Allow Groups?` → `Turn groups off`

- [ ] **Step 3: Récupérer son telegram_user_id**

  1. Ouvrir une conversation avec le bot fraîchement créé
  2. Envoyer `/start` (ou n'importe quel message texte)
  3. Dans le navigateur, ouvrir : `https://api.telegram.org/bot<TELEGRAM_BOT_TOKEN>/getUpdates`
  4. Dans le JSON retourné, repérer `result[0].message.from.id` → c'est le `<DENNIS_TELEGRAM_USER_ID>` (entier ~10 chiffres)
  5. **Noter cette valeur** pour la Task 3

- [ ] **Step 4: Créer credential Telegram dans n8n**

  Via l'UI n8n cloud :
  1. `Credentials` → `Create new credential` → type `Telegram`
  2. Nom : `Telegram Bot — NextMove Voice`
  3. Access Token : coller `<TELEGRAM_BOT_TOKEN>`
  4. Save

- [ ] **Step 5: Vérifier credentials OpenAI + Anthropic existants**

  Dans `Credentials`, confirmer la présence de :
  - `OpenAI` (utilisé probablement par d'autres workflows)
  - `Anthropic` ou `HTTP Header Auth` avec `x-api-key` pour Claude

  Si absents : les créer maintenant avec les API keys. Documentation : https://docs.n8n.io/integrations/builtin/credentials/openai/

- [ ] **Step 6: Commit checkpoint mental**

  Tu n'as rien à commit en git ici (pas de fichiers). Juste valider mentalement que :
  - Le bot existe et répond
  - `<TELEGRAM_BOT_TOKEN>` et `<DENNIS_TELEGRAM_USER_ID>` sont notés
  - Les 3 credentials n8n existent

---

## Task 2: Créer le workflow skeleton + Authorize

**Files:**
- Créé sur n8n cloud : workflow `next_move_voice_assistant`

**Action via MCP:** `mcp__claude_ai_n8n-mcp__n8n_create_workflow`

- [ ] **Step 1: Créer le workflow vide**

  Via le MCP :
  ```
  n8n_create_workflow({
    name: "next_move_voice_assistant",
    nodes: [],
    connections: {},
    active: false
  })
  ```

  Noter le `workflow_id` retourné pour les updates suivants.

- [ ] **Step 2: Ajouter le Telegram Trigger node**

  Via `n8n_update_partial_workflow` avec opération `addNode` :
  ```json
  {
    "name": "Telegram Trigger",
    "type": "n8n-nodes-base.telegramTrigger",
    "typeVersion": 1,
    "position": [240, 300],
    "credentials": {
      "telegramApi": {
        "id": "<credential_id>",
        "name": "Telegram Bot — NextMove Voice"
      }
    },
    "parameters": {
      "updates": ["message"],
      "additionalFields": {}
    }
  }
  ```

- [ ] **Step 3: Activer le workflow temporairement pour récupérer le webhook URL**

  ```
  mcp__claude_ai_n8n-mcp__n8n_update_partial_workflow({
    id: "<workflow_id>",
    operations: [{ type: "setActive", active: true }]
  })
  ```

  Telegram va recevoir le webhook URL automatiquement (n8n s'occupe de l'enregistrer auprès de l'API Telegram). Pas d'action manuelle.

- [ ] **Step 4: Test trigger**

  1. Sur Telegram, envoyer un message TEXTE quelconque au bot ("test")
  2. Dans n8n cloud UI → Executions → vérifier qu'une exécution est déclenchée
  3. Inspecter l'output du node Telegram Trigger : doit contenir `message.from.id` correspondant à `<DENNIS_TELEGRAM_USER_ID>`

  **Si pas d'exécution déclenchée** : vérifier que le workflow est `active: true`, et qu'il n'y a pas d'autre workflow utilisant le même bot.

- [ ] **Step 5: Ajouter un IF "Authorize" node**

  Via `n8n_update_partial_workflow` avec opérations `addNode` + `addConnection` :
  ```json
  {
    "name": "Authorize",
    "type": "n8n-nodes-base.if",
    "typeVersion": 2,
    "position": [460, 300],
    "parameters": {
      "conditions": {
        "options": { "version": 2, "caseSensitive": true, "typeValidation": "strict" },
        "combinator": "and",
        "conditions": [
          {
            "leftValue": "={{ $json.message.from.id }}",
            "rightValue": "<DENNIS_TELEGRAM_USER_ID>",
            "operator": { "type": "number", "operation": "equals" }
          }
        ]
      }
    }
  }
  ```

  Connection : `Telegram Trigger.main[0]` → `Authorize.main[0]`

  ⚠️ Remplacer `<DENNIS_TELEGRAM_USER_ID>` par la valeur réelle notée à la Task 1.

- [ ] **Step 6: Ajouter un Filter "Voice only" sur la branche TRUE**

  La branche TRUE ne doit traiter QUE les messages voice. Texte/images → ignorer (mais Authorize a déjà passé donc on doit répondre proprement).

  Plus simple : 2e IF après Authorize :
  ```json
  {
    "name": "Is Voice",
    "type": "n8n-nodes-base.if",
    "typeVersion": 2,
    "position": [680, 200],
    "parameters": {
      "conditions": {
        "combinator": "and",
        "conditions": [
          {
            "leftValue": "={{ $('Telegram Trigger').first().json.message.voice }}",
            "rightValue": "",
            "operator": { "type": "object", "operation": "exists" }
          }
        ]
      }
    }
  }
  ```

  Connection : `Authorize.main[0]` (TRUE) → `Is Voice.main[0]`

- [ ] **Step 7: Ajouter Telegram Send Text "Accès refusé" sur Authorize FALSE**

  ```json
  {
    "name": "Reject Unauthorized",
    "type": "n8n-nodes-base.telegram",
    "typeVersion": 1.2,
    "position": [680, 400],
    "credentials": { "telegramApi": { "id": "<credential_id>" } },
    "parameters": {
      "resource": "message",
      "operation": "sendMessage",
      "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
      "text": "Accès refusé. Ce bot est réservé. Contactez l'admin si vous pensez recevoir cette erreur par erreur."
    }
  }
  ```

  Connection : `Authorize.main[1]` (FALSE) → `Reject Unauthorized`

- [ ] **Step 8: Ajouter Telegram Send Text "Texte non supporté" sur Is Voice FALSE**

  ```json
  {
    "name": "Reply Text Not Supported",
    "type": "n8n-nodes-base.telegram",
    "typeVersion": 1.2,
    "position": [900, 300],
    "parameters": {
      "resource": "message",
      "operation": "sendMessage",
      "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
      "text": "Bonjour ! Je traite uniquement les messages vocaux pour l'instant. Envoie-moi une question audio."
    }
  }
  ```

  Connection : `Is Voice.main[1]` (FALSE) → `Reply Text Not Supported`

- [ ] **Step 9: Test exécution complète skeleton**

  Sur Telegram :
  1. Envoyer "test" texte → bot doit répondre "Bonjour ! Je traite uniquement..."
  2. (Optionnel, si tu as un 2e compte Telegram disponible) envoyer "test" depuis un autre compte → bot doit répondre "Accès refusé"

  Valider via `mcp__claude_ai_n8n-mcp__n8n_executions` : 2 exécutions, statut success.

- [ ] **Step 10: Sauvegarder workflow**

  Le workflow est auto-sauvé dans n8n cloud. Pas de git commit ici (on commit le JSON à la Task 8).

---

## Task 3: Audio pipeline IN (download + Whisper STT)

**Files:** workflow `next_move_voice_assistant` (modifications via MCP)

- [ ] **Step 1: Ajouter Telegram getFile node**

  ```json
  {
    "name": "Get File Path",
    "type": "n8n-nodes-base.telegram",
    "typeVersion": 1.2,
    "position": [1120, 200],
    "credentials": { "telegramApi": { "id": "<credential_id>" } },
    "parameters": {
      "resource": "file",
      "operation": "get",
      "fileId": "={{ $('Telegram Trigger').first().json.message.voice.file_id }}",
      "download": false
    }
  }
  ```

  Connection : `Is Voice.main[0]` (TRUE) → `Get File Path`

  Output attendu : `{ result: { file_path: "voice/file_42.oga", file_size: ... } }`

- [ ] **Step 2: Ajouter HTTP Request Download Audio**

  ```json
  {
    "name": "Download Audio",
    "type": "n8n-nodes-base.httpRequest",
    "typeVersion": 4.2,
    "position": [1340, 200],
    "parameters": {
      "method": "GET",
      "url": "=https://api.telegram.org/file/bot<TELEGRAM_BOT_TOKEN>/{{ $json.result.file_path }}",
      "responseFormat": "file",
      "options": {}
    }
  }
  ```

  ⚠️ Le token Telegram doit être dans l'URL. Pour la sécurité, idéalement utiliser un credential `Header Auth` mais Telegram ne supporte pas cela pour les fichiers — l'URL directe est la pratique standard.

  Connection : `Get File Path` → `Download Audio`

  Output : `$binary.data` contient l'audio OGG/Opus.

- [ ] **Step 3: Ajouter HTTP Request Whisper STT**

  ```json
  {
    "name": "Whisper STT",
    "type": "n8n-nodes-base.httpRequest",
    "typeVersion": 4.2,
    "position": [1560, 200],
    "credentials": {
      "httpHeaderAuth": { "id": "<openai_credential_id>", "name": "OpenAI" }
    },
    "parameters": {
      "method": "POST",
      "url": "https://api.openai.com/v1/audio/transcriptions",
      "sendHeaders": false,
      "sendBody": true,
      "contentType": "multipart-form-data",
      "bodyParameters": {
        "parameters": [
          { "name": "file", "parameterType": "formBinaryData", "inputDataFieldName": "data" },
          { "name": "model", "value": "whisper-1" },
          { "name": "language", "value": "fr" },
          { "name": "response_format", "value": "json" }
        ]
      }
    }
  }
  ```

  Connection : `Download Audio` → `Whisper STT`

  Output attendu : `{ text: "Combien de prospects à Verdun ?" }`

- [ ] **Step 4: Test E2E pipeline IN**

  Sur Telegram, envoyer un voice message court : *"Test, combien de prospects à Anjou ?"*

  Validation via `n8n_executions` :
  - Get File Path : `result.file_path` présent
  - Download Audio : binary data présente, taille >0
  - Whisper STT : `text` contient bien la phrase prononcée (tolérer petites variations FR)

  **Si Whisper retourne un texte vide ou mauvais** : vérifier que `language=fr` est bien passé, vérifier que le `inputDataFieldName=data` correspond au champ binary du node précédent.

- [ ] **Step 5: Sauvegarder workflow**

---

## Task 4: Claude orchestrator (Code node avec 4 tools)

**Files:** workflow `next_move_voice_assistant` (Code node `Claude Agent`)

- [ ] **Step 1: Ajouter le Code node "Claude Agent"**

  ```json
  {
    "name": "Claude Agent",
    "type": "n8n-nodes-base.code",
    "typeVersion": 2,
    "position": [1780, 200],
    "parameters": {
      "mode": "runOnceForAllItems",
      "language": "javaScript",
      "jsCode": "<voir Step 2>"
    }
  }
  ```

  Connection : `Whisper STT` → `Claude Agent`

- [ ] **Step 2: Implémenter le code JS du Claude Agent**

  Coller dans `jsCode` :

  ```javascript
  // ─── CONFIG ───
  const ANTHROPIC_KEY = $env.ANTHROPIC_API_KEY;  // configurer dans Settings > Variables n8n, ou hardcode pour MVP
  const SUPABASE_URL = 'https://fhqybnkxqfvbsjvwrcob.supabase.co';
  const SUPABASE_KEY = $env.SUPABASE_ANON_KEY;   // ou hardcode anon key
  const COURTIER_ID = '0d99b83a-91db-42cd-a19b-2e88384c67a7';
  const COURTIER_PRENOM = 'Dennis';
  const MAX_ITERATIONS = 5;

  const userQuestion = $input.first().json.text;

  // ─── TOOLS DEFINITIONS ───
  const tools = [
    {
      name: "query_prospects",
      description: "Cherche des prospects du courtier. Retourne nom, prénom, type_projet, statut, score_chaleur, budget_max, secteur, type_bien, resume_ia.",
      input_schema: {
        type: "object",
        properties: {
          secteur: { type: "string", description: "Mot-clé secteur (ex: 'Verdun', 'Anjou')" },
          type_projet: { type: "string", enum: ["acheteur", "vendeur"] },
          statut: { type: "string", enum: ["nouveau","en_qualification","qualifie","en_recherche","offre_deposee","conclu","perdu"] },
          score_min: { type: "integer", minimum: 0, maximum: 10 },
          type_bien: { type: "string" },
          limit: { type: "integer", default: 10, maximum: 50 }
        }
      }
    },
    {
      name: "query_conversations",
      description: "Récupère les N derniers messages d'une conversation avec un prospect.",
      input_schema: {
        type: "object",
        properties: {
          prospect_id: { type: "string" },
          last_n: { type: "integer", default: 5, maximum: 20 }
        },
        required: ["prospect_id"]
      }
    },
    {
      name: "query_besoins",
      description: "Récupère les critères acheteur ou infos vendeur d'un prospect.",
      input_schema: {
        type: "object",
        properties: {
          prospect_id: { type: "string" },
          type: { type: "string", enum: ["acheteur", "vendeur"] }
        },
        required: ["prospect_id", "type"]
      }
    },
    {
      name: "query_relances",
      description: "Récupère les relances planifiées du courtier.",
      input_schema: {
        type: "object",
        properties: {
          statut: { type: "string", enum: ["planifiee","envoyee","annulee","echouee","bloquee","differee"] },
          date_avant: { type: "string", description: "ISO 8601" },
          prospect_id: { type: "string" }
        }
      }
    }
  ];

  // ─── SYSTEM PROMPT ───
  const systemPrompt = `Tu es l'assistant vocal de ${COURTIER_PRENOM}, courtier immobilier.
  Réponds en 1-2 phrases courtes, ton naturel québécois pro, sans jargon.
  Ne mentionne JAMAIS de numéros de téléphone (toxic en audio). Tu peux donner des prénoms.
  Si la requête est ambiguë, demande clarification en 1 phrase.
  Tu n'as accès qu'aux prospects de ${COURTIER_PRENOM}. Refuse poliment toute demande hors scope.`;

  // ─── HELPERS ───
  async function supabaseGet(path, params = {}) {
    const url = new URL(`${SUPABASE_URL}/rest/v1/${path}`);
    Object.entries(params).forEach(([k, v]) => v !== undefined && url.searchParams.set(k, v));
    const res = await this.helpers.httpRequest({
      method: 'GET',
      url: url.toString(),
      headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}`, Accept: 'application/json' },
      json: true
    });
    return res;
  }

  async function executeTool(name, input) {
    if (name === 'query_prospects') {
      const params = {
        courtier_id: `eq.${COURTIER_ID}`,
        select: 'id,prenom,nom,type_projet,statut,score_chaleur,budget_max,secteur,type_bien,resume_ia',
        limit: input.limit || 10
      };
      if (input.secteur) params.secteur = `ilike.*${input.secteur}*`;
      if (input.type_projet) params.type_projet = `eq.${input.type_projet}`;
      if (input.statut) params.statut = `eq.${input.statut}`;
      if (input.score_min !== undefined) params.score_chaleur = `gte.${input.score_min}`;
      if (input.type_bien) params.type_bien = `ilike.*${input.type_bien}*`;
      return await supabaseGet.call(this, 'prospects', params);
    }
    if (name === 'query_conversations') {
      // Pre-check: prospect appartient au courtier
      const prospects = await supabaseGet.call(this, 'prospects', {
        id: `eq.${input.prospect_id}`, courtier_id: `eq.${COURTIER_ID}`, select: 'id'
      });
      if (!prospects.length) return { error: 'Prospect introuvable ou non autorisé' };
      return await supabaseGet.call(this, 'conversations', {
        prospect_id: `eq.${input.prospect_id}`,
        select: 'role,contenu,created_at',
        order: 'created_at.desc',
        limit: input.last_n || 5
      });
    }
    if (name === 'query_besoins') {
      const prospects = await supabaseGet.call(this, 'prospects', {
        id: `eq.${input.prospect_id}`, courtier_id: `eq.${COURTIER_ID}`, select: 'id'
      });
      if (!prospects.length) return { error: 'Prospect introuvable ou non autorisé' };
      const table = input.type === 'acheteur' ? 'besoins_acheteur' : 'besoins_vendeur';
      return await supabaseGet.call(this, table, {
        prospect_id: `eq.${input.prospect_id}`, select: '*'
      });
    }
    if (name === 'query_relances') {
      const params = {
        select: 'type_relance,date_prevue,statut,contenu,prospects(prenom,nom,courtier_id)',
        'prospects.courtier_id': `eq.${COURTIER_ID}`,
        order: 'date_prevue.asc'
      };
      if (input.statut) params.statut = `eq.${input.statut}`;
      if (input.date_avant) params.date_prevue = `lte.${input.date_avant}`;
      if (input.prospect_id) params.prospect_id = `eq.${input.prospect_id}`;
      return await supabaseGet.call(this, 'relances', params);
    }
    return { error: `Tool inconnu: ${name}` };
  }

  async function callClaude(messages) {
    const res = await this.helpers.httpRequest({
      method: 'POST',
      url: 'https://api.anthropic.com/v1/messages',
      headers: {
        'x-api-key': ANTHROPIC_KEY,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json'
      },
      body: {
        model: 'claude-sonnet-4-6',
        max_tokens: 400,
        system: systemPrompt,
        tools: tools,
        messages: messages
      },
      json: true
    });
    return res;
  }

  // ─── MAIN LOOP ───
  let messages = [{ role: 'user', content: userQuestion }];
  let iterations = 0;

  while (iterations++ < MAX_ITERATIONS) {
    const response = await callClaude.call(this, messages);
    messages.push({ role: 'assistant', content: response.content });

    if (response.stop_reason === 'end_turn') {
      const textBlock = response.content.find(b => b.type === 'text');
      return [{ json: { answer_text: textBlock?.text || "Réponse vide.", iterations, transcribed: userQuestion } }];
    }

    if (response.stop_reason === 'tool_use') {
      const toolResults = [];
      for (const block of response.content) {
        if (block.type === 'tool_use') {
          const result = await executeTool.call(this, block.name, block.input);
          toolResults.push({ type: 'tool_result', tool_use_id: block.id, content: JSON.stringify(result) });
        }
      }
      messages.push({ role: 'user', content: toolResults });
    } else {
      // stop_reason inattendu
      return [{ json: { answer_text: "Petit pépin de mon côté, peux-tu reformuler ?", iterations, transcribed: userQuestion } }];
    }
  }

  return [{ json: { answer_text: "Je n'ai pas tout trouvé, peux-tu reformuler ?", iterations, transcribed: userQuestion } }];
  ```

- [ ] **Step 3: Configurer les variables d'environnement n8n**

  Dans `Settings > Variables` (ou environment variables n8n cloud) :
  - `ANTHROPIC_API_KEY` : ta clé Anthropic
  - `SUPABASE_ANON_KEY` : copier depuis `index.html` ligne 511 (déjà publique)

  Alternative quick: hardcoder dans le Code node directement (refacto post-démo).

- [ ] **Step 4: Test isolé du Code node avec input mock**

  Dans n8n cloud UI :
  1. Désactiver temporairement la connexion Whisper STT → Claude Agent
  2. Cliquer sur "Execute Node" sur "Claude Agent"
  3. Pinned input data (manual) :
     ```json
     [{ "json": { "text": "Combien de prospects à Anjou ?" } }]
     ```
  4. Vérifier l'output : `{ answer_text: "Tu as X prospects à Anjou...", iterations: 2, transcribed: "..." }`
  5. Vérifier dans le panneau exécution que les tool calls vers Supabase sont bien faits

  **Si erreur "ANTHROPIC_API_KEY undefined"** : vérifier les variables n8n Settings.
  **Si erreur "tool_use loop infinite"** : vérifier que `MAX_ITERATIONS` est respecté.

- [ ] **Step 5: Reconnecter Whisper → Claude Agent**

  Via `n8n_update_partial_workflow` avec `addConnection`.

- [ ] **Step 6: Sauvegarder workflow**

---

## Task 5: Audio pipeline OUT (TTS + Telegram sendVoice)

**Files:** workflow `next_move_voice_assistant`

- [ ] **Step 1: Ajouter HTTP Request OpenAI TTS**

  ```json
  {
    "name": "OpenAI TTS",
    "type": "n8n-nodes-base.httpRequest",
    "typeVersion": 4.2,
    "position": [2000, 200],
    "credentials": {
      "httpHeaderAuth": { "id": "<openai_credential_id>", "name": "OpenAI" }
    },
    "parameters": {
      "method": "POST",
      "url": "https://api.openai.com/v1/audio/speech",
      "sendBody": true,
      "specifyBody": "json",
      "jsonBody": "={\n  \"model\": \"tts-1\",\n  \"voice\": \"nova\",\n  \"input\": {{ JSON.stringify($json.answer_text) }},\n  \"response_format\": \"opus\"\n}",
      "responseFormat": "file",
      "options": { "outputFieldName": "data" }
    }
  }
  ```

  Connection : `Claude Agent` → `OpenAI TTS`

- [ ] **Step 2: Ajouter Telegram sendVoice**

  ```json
  {
    "name": "Send Voice Reply",
    "type": "n8n-nodes-base.telegram",
    "typeVersion": 1.2,
    "position": [2220, 200],
    "credentials": { "telegramApi": { "id": "<telegram_credential_id>" } },
    "parameters": {
      "resource": "message",
      "operation": "sendVoice",
      "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
      "binaryData": true,
      "binaryPropertyName": "data"
    }
  }
  ```

  Connection : `OpenAI TTS` → `Send Voice Reply`

- [ ] **Step 3: Test E2E complet**

  Sur Telegram, envoyer voice : *"Combien de prospects à Anjou ?"*

  Attendre ~10s. Le bot doit répondre par un voice message audible.

  Validation :
  - Le voice reply joue sans erreur
  - Le contenu correspond aux 12 prospects seedés (devrait dire ~3-4 prospects à Anjou : Marie-Claude, Jean-François, Mathieu — selon les filtres ILIKE)

  **Si erreur Telegram "wrong file type"** : OpenAI TTS opus pas compatible directement. Fallback : changer `response_format` à `"mp3"` et utiliser `sendAudio` au lieu de `sendVoice` (perte : pas affiché comme voice message).

  **Si latence >15s** : vérifier que tts-1 (pas tts-1-hd) est bien utilisé. Vérifier le nombre d'iterations Claude (devrait être ≤3 pour cette question).

- [ ] **Step 4: Sauvegarder workflow**

---

## Task 6: Error handling unifié (fallback texte global)

**Files:** workflow `next_move_voice_assistant` (modifications dans plusieurs nodes)

L'idée : si OpenAI TTS échoue, on fallback sur un envoi texte. Si une étape antérieure échoue, le workflow s'arrête mais on envoie un texte d'erreur générique.

- [ ] **Step 1: Ajouter "Continue On Fail" sur OpenAI TTS**

  Dans le node `OpenAI TTS` (Task 5), modifier les paramètres pour ajouter :
  ```json
  "onError": "continueRegularOutput"
  ```

  Cela permet au workflow de continuer même si TTS échoue.

- [ ] **Step 2: Ajouter IF "TTS Success" après OpenAI TTS**

  ```json
  {
    "name": "TTS Success?",
    "type": "n8n-nodes-base.if",
    "typeVersion": 2,
    "position": [2110, 200],
    "parameters": {
      "conditions": {
        "combinator": "and",
        "conditions": [
          {
            "leftValue": "={{ $binary.data }}",
            "rightValue": "",
            "operator": { "type": "object", "operation": "exists" }
          }
        ]
      }
    }
  }
  ```

  Connection : `OpenAI TTS` → `TTS Success?`
  - TRUE → `Send Voice Reply` (de la Task 5)
  - FALSE → nouveau node texte (Step 3)

- [ ] **Step 3: Ajouter Telegram sendMessage fallback texte**

  ```json
  {
    "name": "Fallback Text Reply",
    "type": "n8n-nodes-base.telegram",
    "typeVersion": 1.2,
    "position": [2220, 350],
    "parameters": {
      "resource": "message",
      "operation": "sendMessage",
      "chatId": "={{ $('Telegram Trigger').first().json.message.chat.id }}",
      "text": "={{ $('Claude Agent').first().json.answer_text }}"
    }
  }
  ```

  Connection : `TTS Success?.main[1]` (FALSE) → `Fallback Text Reply`

- [ ] **Step 4: Test fallback**

  Pour simuler une erreur TTS, temporairement bricoler le node OpenAI TTS (mauvaise URL) → exécuter avec un voice message → vérifier que le bot répond en texte avec le bon contenu.

  Ensuite : restaurer l'URL correcte.

- [ ] **Step 5: Sauvegarder workflow**

---

## Task 7: Test E2E final (5 questions) + tuning prompt

**Files:** Aucun (tests manuels + ajustement system prompt dans Code node)

- [ ] **Step 1: Préparer la liste de 5 questions test**

  À enregistrer en voice depuis l'app Telegram :
  1. *"Combien de prospects à Anjou ?"*
  2. *"Donne-moi mes prospects chauds"*
  3. *"Qu'est-ce que Marie Tremblay m'a dit en dernier ?"*
  4. *"Quelles sont mes relances de la semaine ?"*
  5. *"Le budget de Sophie c'est combien ?"*

  Edge cases :
  6. *"C'est quoi la météo à Montréal ?"* → attendu : refus poli
  7. *"Marie qui ?"* → attendu : Claude demande clarification

- [ ] **Step 2: Exécuter chaque question, mesurer**

  Pour chacune, noter :
  - **Latence** end-to-end (Telegram envoi → réponse audio reçue) : cible <12s
  - **Justesse de la réponse** : compare avec les data seedées dans la BD (Task seed précédente)
  - **Qualité audio** : intelligibilité, ton naturel
  - **Temps de tokens / nombre tool_use** (visible dans n8n_executions logs)

- [ ] **Step 3: Identifier les failures et leur cause**

  Cas typiques à débugger :
  - Whisper transcrit mal le mot "prospect" : essayer `prompt: "Vocabulaire métier: prospect, courtier, qualifié, relance"` dans le call Whisper (paramètre supporté)
  - Claude répond trop long (>2 phrases) : renforcer le system prompt avec un exemple
  - Claude appelle 5 tools quand 1 suffit : ajuster les descriptions de tools

- [ ] **Step 4: Itérer sur le system prompt**

  Modifier le `systemPrompt` dans le Code node Claude Agent. Re-tester. Boucler 2-3 fois max.

  Exemple d'ajustement courant :
  ```
  systemPrompt += `\n\nExemple :
  Q: "Combien de prospects à Anjou ?"
  R: "Tu as 4 prospects à Anjou : Marie-Claude qui cherche un condo, Jean-François qui vend un duplex, et 2 autres."

  Q: "Marie qui ?"
  R: "Tu as une Marie-Claude Tremblay et... attends, juste une Marie. Tu veux ses détails ?"`
  ```

- [ ] **Step 5: Sauvegarder workflow + checkpoint**

---

## Task 8: Export workflow JSON dans le repo + commit

**Files:**
- Créé : `next_move_voice_assistant.json` (à la racine du repo, cohérent avec `next_move_intake_agent_v2.json` existant)

- [ ] **Step 1: Récupérer le workflow JSON via MCP**

  ```
  mcp__claude_ai_n8n-mcp__n8n_get_workflow({ id: "<workflow_id>" })
  ```

- [ ] **Step 2: Sauvegarder dans le repo**

  Écrire le JSON formaté dans `<PROJECT_PATH>/next_move_voice_assistant.json`

  ⚠️ Avant commit, vérifier que :
  - Le `<TELEGRAM_BOT_TOKEN>` n'apparaît pas en clair (doit être dans un credential reference, pas inline)
  - Les `<OPENAI_API_KEY>` et `<ANTHROPIC_API_KEY>` n'apparaissent pas non plus
  - Si tu vois ces secrets dans le JSON exporté : c'est un bug n8n MCP, alerter et garder le fichier local non-commité

- [ ] **Step 3: Commit**

  ```bash
  git add next_move_voice_assistant.json docs/superpowers/plans/2026-05-11-voice-assistant.md
  git commit -m "feat(voice-assistant): workflow Telegram voice assistant + plan d'implémentation

  - Nouveau workflow n8n next_move_voice_assistant (Telegram voice → Whisper → Claude tools → OpenAI TTS → Telegram voice reply)
  - 4 tools Claude paramétrés et filtrés par courtier_id
  - Allowlist hardcodée single-tenant (MVP démo client)
  - Fallback texte si TTS échoue
  - Latence ~10s end-to-end, ~\$0.025 par question

  Spec: docs/superpowers/specs/2026-05-11-voice-assistant-design.md
  Plan: docs/superpowers/plans/2026-05-11-voice-assistant.md

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
  ```

- [ ] **Step 4: Push (optionnel, si tu veux versioner sur GitHub)**

  ```bash
  git push
  ```

  Note : la branche actuelle est `feat/conversations-dashboard-from-main` qui correspond à PR #3. Le commit voice-assistant arrive sur la même branche, ce qui est techniquement out-of-scope de la PR. C'est OK pour un fichier de doc + un export JSON, mais idéalement à séparer dans une branche dédiée si on veut une PR propre.

---

## Self-Review

Vérifié :

**1. Spec coverage** :
- Architecture (section 1) → couvert par Tasks 2-5
- Telegram setup & auth → Task 1
- Workflow nodes détaillés → Tasks 2-5
- 4 Tools Claude → Task 4
- Error handling → Task 6
- Testing plan → Task 7
- Plan de mise en place 75 min → Tasks 1-8 totalisent ~85 min, cohérent

**2. Placeholder scan** : aucun "TBD"/"TODO"/"implement later". Les `<VARIABLES>` sont explicites avec leur valeur source. Le code JS du Step 4 est complet (~150 lignes), pas de raccourcis.

**3. Type consistency** :
- `answer_text` (output Claude) → consommé par OpenAI TTS et Fallback Text Reply ✓
- `binary.data` cohérent partout (Download Audio output, Whisper input, TTS output, sendVoice input) ✓
- `<DENNIS_TELEGRAM_USER_ID>` mentionné dans Task 1 step 3, utilisé dans Task 2 step 5 ✓
- Tool names cohérents entre la définition (Task 4 Step 2) et le `executeTool` switch ✓

**4. Limites** : la Task 6 ne couvre que le fallback TTS. Les autres erreurs (Whisper down, Claude down, Telegram down) ne sont pas explicitement gérées — elles produiront un échec d'exécution n8n visible mais pas de réponse utilisateur. C'est documenté dans le spec section "Error handling" et acceptable pour MVP.

---

## Plan complete

Plan complet et sauvé dans `docs/superpowers/plans/2026-05-11-voice-assistant.md`.

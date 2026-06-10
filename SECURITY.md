# Sécurité — Klaris / NextMove

Revue de sécurité du 2026-06-09 (audit multi-agents, 14 vulnérabilités confirmées
sur 22 examinées). Ce document résume l'incident, ce qui est corrigé dans le dépôt,
et **les actions qui ne peuvent être faites que sur l'infrastructure live**.

## 🔴 Incident critique — fuite de données prospects (confirmée live)

La clé Supabase `anon` est embarquée dans le dashboard statique `index.html`, lui-même
commité dans un dépôt GitHub **public** (`kakame94/NextMove`). Une (ou plusieurs) policy
RLS permissive `anon`/`public` avait été ajoutée en prod pour alimenter ce dashboard sans
auth. Résultat : **lecture monde** de toutes les tables PII.

Vérifié en live le 2026-06-09 avec la seule clé anon publique :

| Table | Exposé (anon) |
|---|---|
| `prospects` | 14 lignes — nom, prénom, téléphone, email |
| `conversations` | 108 lignes — contenu SMS brut + Twilio SIDs |
| `relances` | 3 lignes |
| `courtiers`, `besoins_acheteur`, `besoins_vendeur`, `briefings`, `eval_results`, `n8n_chat_histories` | lisibles (`n8n_chat_histories` expose des téléphones en `session_id`) |

L'écriture anon est bloquée (RLS `42501`) — seule la **lecture** est ouverte. C'est une
violation de la Loi 25 (Québec) / PIPEDA : donnée personnelle de tiers déjà divulguée.

### Actions immédiates (infra live — non faisables depuis le dépôt)

1. **Appliquer `009_security_lockdown_anon.sql`** dans le SQL editor Supabase (service_role).
   Supprime les policies anon, force RLS. Après ça, la clé anon renvoie `[]`.
2. **Roter la clé anon (publishable)** dans Supabase (Settings → API → roll). L'ancienne est
   publique et reste valide jusqu'en 2036. Mettre la nouvelle dans `index.html` /
   `klaris_ios` / n8n.
3. **Appliquer `klaris_ios/migrations/008_security_invoker_views.sql`** (vues RLS) et
   **`mvp_adjointe_ia/src/db/migration_003_enable_rls.sql`** (schéma legacy MVP).
4. **Vérifier** : `curl "$URL/rest/v1/prospects?select=id" -H "apikey: $ANON" -H "Authorization: Bearer $ANON"` → doit renvoyer `[]`.
5. **Évaluer l'obligation de notification** Loi 25 (CAI + personnes concernées) — la donnée a
   été publiquement accessible.

## Corrigé dans ce dépôt (PR)

| # | Sév. | Problème | Fichier | Correctif |
|---|------|----------|---------|-----------|
| 1 | 🔴 | Lecture anon de toutes les tables PII (breach live) | `index.html`, prod DB | `009_security_lockdown_anon.sql` + gate auth sur `index.html` |
| 2 | 🟠 | Vues `conversation_summaries` / `relances_enriched` sans `security_invoker` → bypass RLS cross-courtier | `klaris_ios/migrations/003_*.sql` | `security_invoker = on` + migration forward `008_*` |
| 3 | 🟠 | SQLi via `data.from` non échappé (SELECT historique) | `next_move_intake_agent_v2*.json:184` | requête paramétrée `$1` |
| 4 | 🟠 | SQLi via `data.from` non échappé (UPDATE "Prospect Lost") | `next_move_intake_agent_v2 2.json:478` | `WHERE telephone = $1` paramétré |
| 5 | 🟢 | Fonction `SECURITY DEFINER` sans `search_path` figé | `klaris_ios/migrations/003_*.sql:171` | `set search_path = ''` |
| 6 | 🟢 | RLS absente sur schéma legacy MVP (`clients`, etc.) | `mvp_adjointe_ia/src/db/schema.sql` | `migration_003_enable_rls.sql` |
| 7 | 🟢 | Nonce Apple Sign-In via LCG (prévisible) | `klaris_ios/.../apple_auth_service.dart:48` | `Random.secure()` |
| 8 | 🟢 | Numéros perso / email de tiers en clair | présentations, docs, workflows | redaction (placeholders) |
| 9 | 🟢 | NDA + transcripts d'entrevues réelles dans repo public | `transcripts/`, `atelier_resultats/NDA_*` | `git rm --cached` + `.gitignore` |
| 10 | 🟢 | Secrets non couverts par `.gitignore` | `.gitignore` | ajout `*token.json`, `*credentials.json`, `*.pem`, `*.key`… |
| 11 | 🟢 | `package-lock.json` ignoré → installs non reproductibles | `.gitignore` | retrait de l'ignore (lockfiles à commiter) |

## Reste à faire sur l'instance n8n live (template corrigé mais à ré-importer)

Les workflows n8n du dépôt sont des **templates** — corriger le JSON ne change pas l'instance
qui tourne. Après avoir **ré-importé** les fichiers corrigés, ajouter sur l'instance :

- **Validation `X-Twilio-Signature`** sur chaque webhook entrant (`sms-entrant` + trigger v2).
  Sans elle, n'importe qui connaissant l'URL peut forger un POST (`From`/`Body` arbitraires) →
  c'est le vecteur d'entrée des SQLi, du SMS-pumping et du poisoning de données.
  Recalculer HMAC-SHA1(URL + params triés, `TWILIO_AUTH_TOKEN`) dans un Code node, rejeter si mismatch.
- **Rate limiting** par `From` + plafond global avant d'appeler Claude/Twilio (coût / toll fraud).
- **Opt-out STOP (CASL)** : persister le retrait de consentement (`sms_opt_out`) et le vérifier
  avant toute relance. Élargir les mots-clés (STOP, ARRET, ARRÊT, DESABONNEMENT, UNSUBSCRIBE, CANCEL, END, QUIT).
- **Contrôle de flux LLM** : ne pas router sur un substring (`QUALIFIED`/`LOST`) du texte généré —
  utiliser une sortie structurée (`{"status":"qualified|lost|in_progress"}`).
- **Numéros en variables d'env** (`$env.OWNER_PHONE`, `$env.TWILIO_PHONE_NUMBER`) plutôt qu'en dur.

## Historique git

Les numéros de téléphone réels, l'email et les transcripts ont été retirés du *working tree*,
mais **restent dans l'historique git** (déjà poussé sur un repo public = déjà divulgué).
Pour purger l'historique : `git filter-repo` / BFG puis `--force` push (réécrit l'historique
partagé — décision à prendre côté propriétaire). Roter aussi tout secret qui aurait transité.

## Bonnes pratiques

- Aucun secret en dur ni dans `index.html`/Flutter/JSON n8n — clé anon = publishable **seulement
  si** RLS est ON partout ; tout le reste via variables d'env / credential store.
- RLS ON + `force` + `security_invoker` sur toute vue exposant du PII.
- Requêtes SQL **toujours paramétrées** (`$1`), jamais d'interpolation de texte utilisateur.
- Webhooks entrants **toujours authentifiés** (signature / secret), jamais « URL secrète » seule.

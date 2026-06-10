# Runbook de remédiation — incident sécurité 2026-06-09

Guide pas-à-pas pour fermer la fuite PII et appliquer les correctifs.
Ordre important : **fais 1 et 2 en premier** — ils stoppent la fuite en cours.
Contexte complet : [`SECURITY.md`](../../SECURITY.md).

Pré-requis : accès au projet Supabase `fhqybnkxqfvbsjvwrcob` (rôle owner) et,
pour la partie n8n, accès à l'instance n8n.

---

## ✅ Étape 1 — Fermer la fuite : appliquer le lockdown RLS (5 min)

1. Ouvre Supabase → projet → **SQL Editor** → **New query**.
2. Copie tout le contenu de [`009_security_lockdown_anon.sql`](../../009_security_lockdown_anon.sql) et colle-le.
3. Clique **Run**. Tu dois voir `Success`. (Le script est idempotent — ré-exécutable sans risque.)

**Vérifier que la fuite est fermée** (terminal, remplace `<ANON_KEY>` par la clé actuelle) :

```bash
URL="https://fhqybnkxqfvbsjvwrcob.supabase.co"
ANON="<ANON_KEY>"
curl -s "$URL/rest/v1/prospects?select=id" -H "apikey: $ANON" -H "Authorization: Bearer $ANON"
```

Résultat attendu : **`[]`** (tableau vide). Si tu vois encore des lignes → le script n'a pas tourné.

---

## ✅ Étape 2 — Roter la clé anon (5 min)

L'ancienne clé anon est publique (dans l'historique git) et valide jusqu'en 2036. Il faut la remplacer.

1. Supabase → **Project Settings** → **API** → section **Project API keys**.
2. À côté de la clé `anon` `public` → **Roll / Regenerate**. Confirme.
3. Copie la **nouvelle** clé anon.
4. Remplace l'ancienne clé partout où elle est utilisée :
   - `index.html` (constante `K`, ligne ~529)
   - app Flutter : `klaris_ios` → variable d'env `SUPABASE_ANON_KEY`
   - instance n8n : credentials Supabase
5. Redéploie ce qui doit l'être (Netlify pour le dashboard, etc.).

> La clé anon n'est pas un secret **une fois RLS verrouillée** (étape 1) — la rotation
> sert juste à invalider proprement l'ancienne. L'étape 1 est ce qui protège réellement.

---

## ✅ Étape 3 — Merger la PR de correctifs

Merge [PR #25](https://github.com/kakame94/NextMove/pull/25) dans `main`. Elle apporte :
le gate d'auth sur `index.html`, les requêtes n8n paramétrées, le scrub PII, le `.gitignore` durci.

```bash
gh pr merge 25 --repo kakame94/NextMove --squash
```

(PRs à créer/merger avec le compte `kakame94` actif : `gh auth switch --user kakame94`.)

---

## ✅ Étape 4 — Appliquer les migrations restantes (Supabase SQL Editor)

Même méthode que l'étape 1, dans l'ordre :

1. [`klaris_ios/migrations/008_security_invoker_views.sql`](../../klaris_ios/migrations/008_security_invoker_views.sql)
   — corrige le bypass RLS des vues (un courtier voyait les prospects des autres).
2. [`mvp_adjointe_ia/src/db/migration_003_enable_rls.sql`](../../mvp_adjointe_ia/src/db/migration_003_enable_rls.sql)
   — RLS sur le schéma legacy MVP (si ces tables existent encore).

**Vérifier les vues** :

```sql
select relname, reloptions from pg_class
where relkind = 'v' and relname in ('conversation_summaries','relances_enriched');
-- reloptions doit contenir {security_invoker=on}
```

---

## ✅ Étape 5 — Durcir l'instance n8n

Les workflows du repo sont des **templates** : corriger le JSON ne change pas l'instance qui tourne.

1. Dans n8n, **ré-importe** les workflows corrigés (`next_move_intake_agent_v2.json`, etc.) — ils
   contiennent les requêtes SQL paramétrées (`$1`).
2. Ajoute en tête de chaque webhook entrant un **Code node** qui valide `X-Twilio-Signature`
   (HMAC-SHA1 de l'URL + params triés, clé = `TWILIO_AUTH_TOKEN`) et rejette si invalide.
   Sans ça, n'importe qui peut forger un POST → déclenche les SQLi, le spam SMS facturé, le poisoning.
3. Ajoute un **rate limit** par numéro + plafond global avant d'appeler Claude/Twilio.
4. **Opt-out STOP (CASL)** : persiste le retrait de consentement (`sms_opt_out`) et vérifie-le
   avant toute relance. Mots-clés : STOP, ARRET, ARRÊT, DESABONNEMENT, UNSUBSCRIBE, CANCEL, END, QUIT.
5. Sortie LLM **structurée** (`{"status":"qualified|lost|in_progress"}`) au lieu de router sur un
   mot-clé dans le texte généré.

---

## ⬜ Étape 6 — (Optionnel) Purger l'historique git

Les anciens numéros de téléphone réels + transcripts restent dans l'historique git
(déjà poussés sur un repo public = déjà divulgués). Pour les retirer de l'historique :

```bash
# Destructif — réécrit l'historique partagé. Préviens tout collaborateur avant.
pip install git-filter-repo
git filter-repo --path transcripts/ --path atelier_resultats/NDA_NextMove_Joanel_Dupart.docx --invert-paths
git push --force --all
```

> Comme le repo est public, la purge **réduit** mais **n'annule pas** la divulgation déjà faite.
> Roter tout secret qui aurait pu transiter.

---

## Checklist

- [ ] Étape 1 — `009` appliqué, `curl` renvoie `[]`
- [ ] Étape 2 — clé anon rotée + remplacée partout + redéployé
- [ ] Étape 3 — PR #25 mergée
- [ ] Étape 4 — migrations `008` + MVP `003` appliquées, vues `security_invoker=on`
- [ ] Étape 5 — n8n : signature Twilio + rate limit + opt-out + sortie structurée
- [ ] Étape 6 — (optionnel) historique purgé
- [ ] Évaluer l'obligation de notification Loi 25 (CAI + personnes concernées)

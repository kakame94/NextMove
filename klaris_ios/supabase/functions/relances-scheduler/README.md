# Relances Scheduler — Dev Handoff

> **Sprint 7 · Owner : Dennis (backend) + Eliot (spec)**
> Edge Function Supabase Deno qui exécute le scheduler des relances toutes les 15 minutes.
>
> **Spec canonique** : [`docs/relances/relances-decision-matrix.md`](../../../../docs/relances/relances-decision-matrix.md) v1.2
> **Spec LLM-ready** : [`24_NextMove/klaris_relances_rules_claude.md`](../../../../24_NextMove/klaris_relances_rules_claude.md)

---

## TL;DR

```bash
# 1. Apply DB migration
psql "$SUPABASE_DB_URL" -f klaris_ios/migrations/008_sprint7_relances_scheduler.sql

# 2. Set secrets
supabase secrets set \
  TWILIO_ACCOUNT_SID=AC... \
  TWILIO_AUTH_TOKEN=... \
  TWILIO_FROM_NUMBER=+1438...

# 3. Deploy
supabase functions deploy relances-scheduler
supabase functions schedule create relances-scheduler --cron "*/15 * * * *"

# 4. Verify
supabase functions logs relances-scheduler --tail
```

---

## Ce qui est livré

| Composant | Fichier | Statut |
|---|---|---|
| Edge Function Deno | `index.ts` | ✅ Code complet · cron 15min |
| Pure guard evaluator | `evaluateGuards()` dans `index.ts` | ✅ 13 garde-fous séquentiels |
| Async orchestrator | `canSendRelance()` dans `index.ts` | ✅ Fetch ctx + delegate sync |
| Tests Deno unitaires | `index.test.ts` | ✅ 20 tests (13 guards + 5 SEND + 2 ordre) |
| Migration SQL | `../../../migrations/008_sprint7_relances_scheduler.sql` | ✅ Drop j10 + RPC + 3 tables nouvelles |
| Modèle iOS Flutter | `../../../lib/data/models/relance.dart` | ✅ enum `j10` retiré |
| UI iOS | `../../../lib/features/relances/relances_list_screen.dart` | ✅ Switch j10 retiré |
| Tests Flutter | `../../../test/relance_model_test.dart` | ✅ `dart analyze` clean |

---

## Ce qui reste à implémenter (TODO)

### Critique (avant prod)

- [ ] **TWILIO Trust Hub Brand Score API** — `twilioSenderScore()` actuellement stub `return 99`
  Endpoint : `GET https://trusthub.twilio.com/v1/CustomerProfiles/{sid}`
  Remplacer dans `index.ts` lignes ~340-345.

- [ ] **Slack alert admin webhook** — `alertAdmin()` log console actuel
  ```ts
  // À implémenter dans index.ts
  async function alertAdmin(message: string) {
    const webhook = Deno.env.get('SLACK_ADMIN_WEBHOOK');
    if (!webhook) return console.error(`ADMIN: ${message}`);
    await fetch(webhook, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: `🚨 Klaris Scheduler: ${message}` }),
    });
  }
  ```
  Secret à créer : `supabase secrets set SLACK_ADMIN_WEBHOOK=https://hooks.slack.com/...`

- [ ] **Timezone math précise** — `nextBusinessDay9am()` actuellement approximation
  Utiliser `Intl.DateTimeFormat` + `formatToParts` pour reconstruire l'heure UTC précise selon DST QC.
  Tester aux limites : changement d'heure mars / novembre.

### Moyen (Sprint 8)

- [ ] **Trigger automatique relances** — actuellement scheduler lit `relances` table.
  Manque : créer les rows `relances` quand prospect devient inactif (J+2 / J+5).
  Solution : trigger SQL ou cron séparé `relances-trigger-fire` qui INSERT pending rows.

- [ ] **Templates EN-CA** — actuellement FR-CA only.
  Persona bilingue exige EN-CA fallback. Étendre `TEMPLATES` Map dans `index.ts`.

- [ ] **Briefing courtier T11** — relance `briefing_quotidien` 7h30 pas dans flow current.
  Existe déjà comme Edge Function séparée `daily-briefing`. Décider : fusionner ou laisser séparé ?

### Bas (Sprint 9+)

- [ ] **Twilio cost réel via API** — `twilioMonthlyCost()` approxime via count × 0.01 CAD.
  Endpoint : `GET https://api.twilio.com/2010-04-01/Accounts/{sid}/Usage/Records/ThisMonth.json`

- [ ] **Tests E2E** avec Supabase local — actuellement Deno unit tests pure.
  Setup `supabase start` local + seed prospects + run scheduler 1× + assert relances.status.

---

## Architecture

### Flow par tick (toutes les 15 min)

```
Cron Supabase ─→ relances-scheduler
                       │
                       ▼
              ┌────────────────────────┐
              │ claim_pending_relances │  RPC PL/pgSQL
              │ FOR UPDATE SKIP LOCKED │  (idempotent multi-cron)
              └─────────┬──────────────┘
                        │
                        ▼ (batch 100 max)
              ┌─────────────────────────┐
              │ For each relance:       │
              │   1. fetchProspect()    │
              │   2. fetchHistory()     │
              │   3. evaluateGuards()   │  ← PURE (testable)
              │   4. switch action:     │
              │      SEND → Twilio +2x  │
              │      BLOCK → status=skp │
              │      DEFER → reschedule │
              │   5. logDecision()      │
              └─────────┬───────────────┘
                        │
                        ▼
              ┌─────────────────────────┐
              │ updateSchedulerState()  │  metrics last_run
              └─────────────────────────┘
```

### 13 garde-fous (ordre strict)

| # | Code | Type | Action si match |
|---|---|---|---|
| G1 | `blacklist_phone` | Block | Phone in blacklist table |
| G2 | `opted_out_stop` | Block | Opt-out CASL < 90 jours |
| G3 | `pipeline_closed` | Block | `status='perdu'` + type ≠ reactivation |
| G4 | `human_active` | Block | Inbound prospect < 24h |
| G5 | `courtier_override` | Block | `pause_relances=true` |
| G6 | `cadence_not_elapsed` | Block | Cadence min même type non atteinte |
| G7 | `max_attempts_reached` | Block | Max attempts par type dépassé |
| G13 | `global_spam_guard_48h` | Block | ≥ 2 relances toutes types dans 48h |
| G8 | `outside_business_hours` | **Defer** | Hors 8h-20h locale QC |
| G9 | `quebec_holiday` | **Defer** | Jour férié QC |
| G11 | `budget_exceeded` | Block | Twilio coût mois > 500 CAD |
| G12 | `sender_score_degraded` | **Defer 2h** | Sender score < 97 |
| G10 | `no_template_available` | Block | Template manquant (type/canal/lang) |

> Premier guard qui match → STOP, retourne immédiatement. Pas d'inférence.

### Tables touchées

| Table | Rôle |
|---|---|
| `relances` (existe) | Rows pending → claimed → sent/skipped |
| `prospects` (existe) | Read seul pour ctx |
| `blacklist` (existe) | G1 check |
| `holidays_qc` (nouveau migration 008) | G9 check |
| `relances_scheduler_state` (nouveau) | Health metrics single-row |
| `relance_decisions` (nouveau) | Audit Loi 25 + OACIQ 6 ans |

---

## Setup local

### Pré-requis

```bash
# Deno (pour tester localement)
brew install deno
deno --version  # >= 2.0

# Supabase CLI (pour deploy)
brew install supabase/tap/supabase
supabase --version

# Optional : Twilio test credentials (test SID/token, ne consomme pas)
# https://www.twilio.com/console/project/settings
```

### Variables d'environnement requises

| Variable | Source | Notes |
|---|---|---|
| `SUPABASE_URL` | Auto injectée par Supabase | — |
| `SUPABASE_SERVICE_ROLE_KEY` | Auto injectée | RLS-bypass pour scheduler |
| `TWILIO_ACCOUNT_SID` | Secrets Supabase | `supabase secrets set` |
| `TWILIO_AUTH_TOKEN` | Secrets Supabase | — |
| `TWILIO_FROM_NUMBER` | Secrets Supabase | Format E.164 `+1438...` |
| `SLACK_ADMIN_WEBHOOK` | Secrets (à créer) | TODO ci-dessus |

```bash
# Set tous d'un coup
supabase secrets set \
  TWILIO_ACCOUNT_SID=ACxxxxx \
  TWILIO_AUTH_TOKEN=xxxxx \
  TWILIO_FROM_NUMBER=+14385551234 \
  SLACK_ADMIN_WEBHOOK=https://hooks.slack.com/services/...
```

### Lancer les tests

```bash
cd klaris_ios/supabase/functions/relances-scheduler

# Tous les tests (20)
deno test --allow-env index.test.ts

# Avec coverage
deno test --allow-env --coverage=coverage index.test.ts
deno coverage coverage
```

Output attendu :
```
running 20 tests from ./index.test.ts
G1 — blacklist BLOCKS ... ok
G2 — opt-out STOP < 90 days BLOCKS ... ok
...
SEND #5 — different type, no cadence/attempt conflict ... ok
Guards evaluated in correct order — blacklist beats opted_out ... ok
Guards evaluated in correct order — all 13 evaluated on SEND ... ok

ok | 20 passed | 0 failed
```

### Tester en local avec Supabase

```bash
# Démarrer Supabase local
supabase start

# Appliquer migration
psql "postgresql://postgres:postgres@localhost:54322/postgres" \
  -f klaris_ios/migrations/008_sprint7_relances_scheduler.sql

# Seed un prospect + relance pending
psql "postgresql://postgres:postgres@localhost:54322/postgres" -c "
  INSERT INTO prospects (id, courtier_id, nom, phone, status, score)
    VALUES ('uuid-test-1', 'uuid-courtier-1', 'Test Marie', '+15145551234', 'actif', 6);
  INSERT INTO relances (id, prospect_id, prospect_score, step, status, scheduled_for)
    VALUES ('uuid-rel-1', 'uuid-test-1', 6, 'j2', 'pending', now() - interval '1 hour');
"

# Run function localement
supabase functions serve relances-scheduler

# Trigger manuel (autre terminal)
curl -X POST http://localhost:54321/functions/v1/relances-scheduler \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY"

# Vérifier résultat
psql "postgresql://postgres:postgres@localhost:54322/postgres" -c "
  SELECT * FROM relance_decisions ORDER BY created_at DESC LIMIT 5;
  SELECT * FROM relances_scheduler_state;
"
```

---

## Déploiement prod

```bash
# 1. Migration (1× seulement)
supabase db push
# OU manuellement
psql "$SUPABASE_DB_URL" -f klaris_ios/migrations/008_sprint7_relances_scheduler.sql

# 2. Deploy fonction
supabase functions deploy relances-scheduler

# 3. Planifier cron (1× seulement, persiste)
supabase functions schedule create relances-scheduler --cron "*/15 * * * *"

# 4. Vérifier
supabase functions logs relances-scheduler --tail
```

### Vérification post-deploy

```sql
-- État scheduler (devrait avoir last_run_at récent)
SELECT * FROM relances_scheduler_state;

-- Decisions des dernières 24h
SELECT action, reason, count(*)
  FROM relance_decisions
 WHERE created_at > now() - interval '24 hours'
 GROUP BY action, reason
 ORDER BY count(*) DESC;
```

---

## Debugging

### Cas "scheduler ne tourne pas"

```bash
# Logs récents
supabase functions logs relances-scheduler --tail

# État scheduler dans DB
SELECT last_run_at, now() - last_run_at as time_since_last
  FROM relances_scheduler_state;
```

Si `time_since_last > 20 minutes` → cron n'a pas tourné. Check :
1. `supabase functions schedule list` — schedule existe ?
2. Logs Supabase Dashboard → Edge Functions → relances-scheduler

### Cas "tout est BLOCK"

```sql
-- Distribution des reasons
SELECT reason, count(*)
  FROM relance_decisions
 WHERE created_at > now() - interval '1 hour'
   AND action = 'BLOCK'
 GROUP BY reason
 ORDER BY count(*) DESC;
```

Reasons probables :
- `human_active` partout → prospects ont récemment écrit, normal. Attendre 24h.
- `opted_out_stop` partout → check `prospects.opted_out_at` (test trop récent ?)
- `no_template_available` → template manquant dans Map `TEMPLATES`

### Cas "Twilio fail"

```sql
-- Errors recent
SELECT last_error_message, last_errors
  FROM relances_scheduler_state;
```

Check :
- Secrets Twilio bien set : `supabase secrets list`
- Numéro `TWILIO_FROM_NUMBER` au format E.164 (`+1438...`)
- Numéro `TWILIO_FROM_NUMBER` activé pour SMS sortants au Canada
- Compte Twilio sandbox (test) vs production

---

## Workflow dev quotidien

```bash
# 1. Récupérer dernière version spec
git pull
cat docs/relances/relances-decision-matrix.md   # v1.2 actuelle

# 2. Modifier code
# ... editer index.ts ...

# 3. Tester
cd klaris_ios/supabase/functions/relances-scheduler
deno test --allow-env index.test.ts

# 4. Si test échoue, vérifier alignement spec
# Ex: ajouter G14 → spec doc M2 + index.ts evaluateGuards() + test correspondant

# 5. Deploy preview
supabase functions deploy relances-scheduler --project-ref <preview-ref>

# 6. PR
git checkout -b feat/relances-G14-anti-bounce
git add -A
git commit -m "feat(relances): G14 anti-bounce guard

- Add G14: block if prospect.bounce_count >= 3
- Update spec doc v1.3
- Add Deno test G14 BLOCKS"
gh pr create
```

---

## Conformité (à ne PAS toucher sans avocat)

### Loi 25 (QC)

- ✅ `audit_log` 6 ans rétention (table `relance_decisions`)
- ✅ Hébergement `ca-central-1` (Supabase config)
- ✅ Opt-out STOP traité dans G2 (90 jours blocage minimum)
- ✅ Pas de PII dans logs console (juste UUIDs)

### CASL / LCAP

- ✅ Mot-clé STOP reconnu (handled upstream par `voicemail-intake` / `sms-handler`)
- ✅ Signature SMS obligatoire (templates contiennent `STOP pour arrêter`)
- ✅ Identification expéditeur (template inclut `{{NOM_COURTIER}}`)
- ✅ Heures 8h-20h heure locale prospect (G8)

### OACIQ

- ✅ Audit log par action (table `relance_decisions`)
- ✅ Courtier reste **éditeur responsable** (templates pas envoyés automatiquement pour actions transactionnelles — feature `awaiting_approval` swipe-to-send côté iOS)
- ✅ Pas d'engagement contractuel automatique (templates info uniquement)

> ⚠️ **NE PAS** modifier les templates sans validation Eliot / Walkens / avocat conformité.

---

## Spec drift — comment éviter

Le drift v1.0 → v1.1 → v1.2 a coûté 1 sprint à réconcilier. Pour éviter :

1. **Source de vérité unique** : [`docs/relances/relances-decision-matrix.md`](../../../../docs/relances/relances-decision-matrix.md)
2. **Tests Deno = miroir spec** : chaque guard a son test. Si tu ajoutes un guard → spec + test + code, sinon refusé en review.
3. **Pseudo-code SQL synchro** : section 7 du doc spec = miroir code TypeScript `evaluateGuards()`. Si tu modifies l'un, mets l'autre à jour.
4. **Version doc tracée** : `**Version :** X.Y` en tête du doc spec. Bump à chaque changement matérial.

---

## Contact

- **Bloqué sur business rule** : Eliot
- **Bloqué sur infra Supabase / Twilio** : Dennis
- **Bloqué sur conformité (Loi 25 / OACIQ)** : Walkens + avocat externe
- **Bug en prod** : Sentry alert → Slack #klaris-prod → triage 15min

---

> **Version README** : v1.0 · 2026-05-13 · Sprint 7
> **Sync requis** : à mettre à jour à chaque modification de `index.ts` ou spec doc

# AUDIT : Code Infra vs PRD — Discrepancies

**Date :** 2026-04-11
**Auditeur :** Claude (Opus 4.6) + Eliot
**PRD reference :** `_bmad-output/planning-artifacts/prd.md`
**Code audite :** `mvp_adjointe_ia/`

---

## POUR DENNIS — Comment lire ce document

Ce doc liste tout ce qui ne colle pas entre le code deja pousse et le PRD qu'on a formalise apres. C'est normal — le dev a commence avant le PRD. Rien de grave, mais ces corrections sont necessaires pour que le MVP soit conforme aux exigences.

**Priorite :** Corriger les ❌ CRITIQUES en premier (D1 a D7), puis les ⚠️ MEDIUM (D8 a D12).

**Fichiers concernes :**
- `mvp_adjointe_ia/src/db/schema.sql` — Schema DB
- `mvp_adjointe_ia/src/prompts/adjointe_systeme.md` — Prompt systeme
- `mvp_adjointe_ia/src/flows/n8n_workflow_sms.json` — Workflow n8n principal
- `mvp_adjointe_ia/src/flows/sms_handler.js` — Logique JS du handler
- `mvp_adjointe_ia/GUIDE_DEPLOIEMENT.md` — Guide de deploiement

**PRD a lire pour comprendre les exigences :** `_bmad-output/planning-artifacts/prd.md`

---

## ❌ CRITIQUES — A corriger AVANT la demo dimanche

### D1 — Pas de gestion STOP (obligation legale)

**FR concernee :** FR-9.1 (MUST)
**Probleme :** Le workflow n8n n'a aucun filtrage en entree. Si un prospect envoie "STOP", l'IA va lui repondre normalement au lieu de le desabonner. C'est une **obligation legale Twilio/CASL**.
**Fichier :** `n8n_workflow_sms.json`
**Correction :**
Ajouter un node IF juste apres le webhook Twilio (entre nodes 1 et 2) :
```
IF message.Body MATCHES "^(STOP|stop|Stop|ARRET|arret|UNSUBSCRIBE)$"
  → Blacklist le numero (INSERT dans une table `blacklist` ou flag dans `clients`)
  → Repondre : "Vous avez ete desabonne. Pour vous reabonner, ecrivez START."
  → FIN (ne pas continuer le flux)
ELSE
  → Continuer vers node 2 (Chercher Client)
```
**Effort :** 30 min
**Schema DB a ajouter :**
```sql
ALTER TABLE clients ADD COLUMN blackliste BOOLEAN DEFAULT FALSE;
```
Et ajouter un check au debut du workflow : `WHERE blackliste = FALSE`

---

### D2 — Notification courtier = placeholder (pas implementee)

**FR concernee :** FR-5.1 (MUST), FR-5.3 (MUST), FR-5.4 (MUST)
**Probleme :** Le node 11 "Mettre a jour Fiche + Notifier" est un **commentaire** (`// voir sms_handler.js`). Le courtier ne recoit jamais de notification apres une collecte.
**Fichier :** `n8n_workflow_sms.json` node 11
**Correction :**
Remplacer le node commentaire par 3 sous-nodes :
1. **Code node** : Appeler `updateClientFromAction()` + `buildCourtierNotification()` depuis `sms_handler.js`
2. **Twilio node** : Envoyer le SMS notification au courtier (`COURTIER_TELEPHONE`)
3. **IF node** : Si score = `chaud_urgent`, envoyer immediatement (pas en batch)

Le code JS existe deja dans `sms_handler.js` (fonctions `updateClientFromAction` et `buildCourtierNotification`) — il faut juste les brancher dans le workflow.
**Effort :** 1-2h

---

### D3 — Pas de node SendGrid pour email courtier

**FR concernee :** FR-5.2 (MUST)
**Probleme :** Aucun node SendGrid dans le workflow. Le courtier ne recoit pas le courriel enrichi avec la fiche complete + lien conversation.
**Fichier :** `n8n_workflow_sms.json`
**Correction :**
Ajouter un node SendGrid apres le node de notification SMS courtier :
- **From :** `EMAIL_FROM` (env variable)
- **To :** `COURTIER_COURRIEL` (env variable)
- **Subject :** `NOUVEAU PROSPECT [{{SCORE}}] — {{NOM}}`
- **Body HTML :** Template enrichi avec fiche complete + lien vers conversation dans Supabase
- Le template existe deja dans `src/prompts/notification_courtier.md`
**Effort :** 1h

---

### D4 — Pas de message d'attente si Claude > 50 secondes

**FR concernee :** FR-1.5 (MUST)
**Probleme :** Si Claude API met 70 secondes a repondre, le prospect attend dans le vide. Pas de message intermediaire.
**Fichier :** `n8n_workflow_sms.json` autour du node 6 (Appeler Claude)
**Correction :**
Option A (recommandee) : Utiliser un **timeout pattern** dans n8n :
1. Demarrer un timer de 50 secondes en parallele de l'appel Claude
2. Si le timer expire avant Claude : envoyer via Twilio "Merci pour votre message! Je prends note et je vous reviens dans quelques instants."
3. Quand Claude repond : envoyer la reponse complete normalement

Option B (plus simple) : Ajouter un noeud "Wait" de 0s avec un webhook de callback pour mesurer le temps, et un branchement conditionnel si > 50s.
**Effort :** 1h

---

### D5 — Pas de error handling / retry

**NFR concernee :** NFR-2.2 (retry 3x backoff), NFR-2.3 (alerte si down > 30min)
**Probleme :** Aucun try/catch dans le workflow. Si Supabase, Claude, ou Twilio fail → le message est perdu silencieusement.
**Fichier :** `n8n_workflow_sms.json` — global
**Correction :**
1. Activer les **Error Trigger** de n8n sur les nodes critiques (6-Claude, 8-Twilio, 5-Supabase)
2. Ajouter un node **Error Workflow** qui :
   - Log l'erreur
   - Retry 3x avec backoff exponentiel (n8n a un retry built-in par node)
   - Si echec persistant : envoyer une alerte par email au courtier
3. Pour le monitoring : ajouter un **cron workflow** qui verifie la derniere activite. Si rien depuis 30 min en heures ouvrables → alerte.
**Effort :** 1-2h

---

### D6 — Pas de workflow cron pour executer les relances

**FR concernees :** FR-6.1 (MUST J+2), FR-6.2 (MUST J+5), FR-6.3 (MUST J-1)
**Probleme :** Les templates de relance existent (`relances.md`) et les relances sont planifiees dans la table `relances` (via `scheduleInitialFollowUps()`), mais **aucun workflow n8n ne les execute**. Les relances sont ecrites en base mais jamais envoyees.
**Correction :**
Creer un **nouveau workflow n8n** (`n8n_workflow_relances.json`) :
1. **Trigger :** Cron toutes les 15 minutes (ou toutes les heures)
2. **Query Supabase :** `SELECT * FROM relances WHERE statut = 'planifiee' AND date_prevue <= NOW()`
3. **Pour chaque relance :**
   - Charger le client (`JOIN clients ON client_id`)
   - Selectionner le template de message selon `type_relance`
   - Remplacer les variables (prenom, nom courtier, heure RDV...)
   - Envoyer le SMS via Twilio
   - Mettre a jour `relances SET statut = 'executee', date_executee = NOW()`
4. **Error handling :** Si l'envoi echoue, marquer `statut = 'erreur'` et logger

Meme logique pour le **briefing 7h30** : un cron qui se declenche a 7h30 chaque jour, genere le resume depuis Supabase, et l'envoie au courtier par SMS + email.
**Effort :** 2-3h

---

### D7 — Guide deploiement contredit le PRD sur les relances

**Probleme :** Le guide de deploiement (`GUIDE_DEPLOIEMENT.md`) dit a la fin :
```
4. [ ] Implementer les relances automatiques (Sprint 2)
5. [ ] Ajouter le resume quotidien (Sprint 2)
```
Mais le PRD dit que les relances (FR-6.1/6.2/6.3) et le briefing (FR-7.1) sont **MUST Sprint 1**.
**Fichier :** `mvp_adjointe_ia/GUIDE_DEPLOIEMENT.md` lignes 121-123
**Correction :**
Changer :
```
4. [ ] Implementer les relances automatiques (Sprint 2)
5. [ ] Ajouter le resume quotidien (Sprint 2)
```
En :
```
4. [ ] Activer le workflow de relances automatiques (Sprint 1 — MUST)
5. [ ] Activer le briefing quotidien 7h30 (Sprint 1 — MUST)
```
**Effort :** 10 min

---

## ⚠️ MEDIUM — A corriger pendant le sprint (samedi)

### D8 — Score chaleur 3 niveaux au lieu de 4

**FR concernee :** FR-4.2
**Probleme :** Le schema et le prompt n'ont que 3 niveaux (chaud/tiede/froid). Le PRD exige 4 niveaux incluant `chaud_urgent`.
**Fichiers :** `schema.sql` ligne 33, `adjointe_systeme.md` lignes 84-87
**Correction :**
```sql
-- schema.sql
ALTER TABLE clients DROP CONSTRAINT clients_score_chaleur_check;
ALTER TABLE clients ADD CONSTRAINT clients_score_chaleur_check
  CHECK (score_chaleur IN ('chaud', 'chaud_urgent', 'tiede', 'froid'));
```
Dans le prompt, ajouter apres la section "Calcul du score de chaleur" :
```
- **CHAUD-URGENT**: Situation personnelle urgente (divorce, deces, demenagement force)
  OU delai < 1 mois ET client presse. Notifier le courtier IMMEDIATEMENT.
```
**Effort :** 30 min

---

### D9 — Prompt ne gere pas la detection de langue FR/EN

**FR concernee :** FR-1.4 (MUST)
**Probleme :** Le prompt systeme n'a aucune instruction pour detecter l'anglais et switcher.
**Fichier :** `adjointe_systeme.md`
**Correction :**
Ajouter cette section apres "## Regles absolues" :
```markdown
## Detection de langue

- Si le client ecrit en anglais, tu reponds en anglais
- Si le client ecrit en francais, tu reponds en francais
- En cas de doute, reponds en francais (langue par defaut)
- La fiche client est TOUJOURS generee en francais (pour le courtier)
- Ajoute dans les notes : "Conversation en anglais" si applicable
```
**Effort :** 30 min

---

### D10 — Prompt ne gere pas le mode doux vs raccourci

**FR concernee :** FR-2.3 (SHOULD)
**Fichier :** `adjointe_systeme.md`
**Correction :**
Ajouter apres "## Ton objectif principal" :
```markdown
## Adaptation au rythme du client

- Si le client semble HESITANT (mots : "peut-etre", "je ne suis pas sure", "je reflechis")
  → Mode doux : une seule question a la fois, ton rassurant, "pas de pression"
- Si le client semble URGENT (mots : "vite", "urgent", "divorce", "demenagement", delai < 1 mois)
  → Mode raccourci : regroupe 2-3 questions par message, va a l'essentiel, skip les questions exploratoires
```
**Effort :** 20 min

---

### D11 — Historique conversation : 20 messages au lieu de 10

**NFR concernee :** NFR-4.6
**Probleme :** `sms_handler.js` charge 20 messages d'historique. Le PRD dit max 10 pour eviter le depassement de contexte Claude.
**Fichier :** `sms_handler.js` ligne 37
**Correction :**
```javascript
// AVANT
async function loadConversationHistory(supabase, clientId, limit = 20) {
// APRES
async function loadConversationHistory(supabase, clientId, limit = 10) {
```
**Effort :** 5 min

---

### D12 — Pas de `courtier_id` FK pour multi-tenant futur

**NFR concernee :** NFR-5.3
**Probleme :** Les tables `clients`, `conversations`, `relances`, `rendez_vous` n'ont pas de colonne `courtier_id`. La V1 multi-courtier necessitera une migration.
**Fichier :** `schema.sql`
**Correction (a planifier, PAS pour Sprint 1) :**
```sql
-- Migration future V1
ALTER TABLE clients ADD COLUMN courtier_id UUID REFERENCES config_courtier(id);
ALTER TABLE conversations ADD COLUMN courtier_id UUID REFERENCES config_courtier(id);
ALTER TABLE relances ADD COLUMN courtier_id UUID REFERENCES config_courtier(id);
ALTER TABLE rendez_vous ADD COLUMN courtier_id UUID REFERENCES config_courtier(id);
-- Puis activer RLS
```
**Effort :** Sprint 3 / V1 — pas Sprint 1

---

## CHECKLIST POUR DENNIS — Ordre de correction recommande

### Vendredi (setup + corrections critiques)

- [ ] **D7** — Corriger le guide deploiement (10 min)
- [ ] **D1** — Ajouter filtrage STOP dans le workflow (30 min)
- [ ] **D8** — Ajouter `chaud_urgent` dans schema + prompt (30 min)
- [ ] **D11** — Changer limit 20 → 10 dans sms_handler.js (5 min)
- [ ] **D9** — Ajouter detection langue dans prompt (30 min)
- [ ] **D10** — Ajouter mode doux/raccourci dans prompt (20 min)

### Samedi (implementation manquante)

- [ ] **D2** — Implementer notification SMS courtier dans workflow (1-2h)
- [ ] **D3** — Ajouter node SendGrid pour email courtier (1h)
- [ ] **D4** — Ajouter message d'attente si Claude > 50s (1h)
- [ ] **D5** — Ajouter error handling + retry dans workflow (1-2h)
- [ ] **D6** — Creer workflow cron relances + briefing 7h30 (2-3h)

### Backlog (pas Sprint 1)

- [ ] **D12** — Ajouter `courtier_id` pour multi-tenant (Sprint 3 / V1)

---

## CE QUI EST DEJA BIEN

- Schema 5 tables bien structure avec index et trigger `updated_at`
- Flux conversationnel acheteur 9Q / vendeur 6Q complet dans le prompt
- Code `sms_handler.js` modulaire (8 fonctions bien decoupees)
- `findOrCreateClient()` gere la reconnaissance de numero (FR-4.3)
- Workflow n8n principal fonctionnel (webhook → client → Claude → SMS → save)
- Templates de relance complets (7 templates couvrant tous les cas)
- Guide de deploiement clair et actionable
- Variables d'environnement bien documentees dans `env.example`

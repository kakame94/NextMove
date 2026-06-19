# Klaris — Canal Email : guide développeur

> **Statut** : spec d'implémentation. Rédigée 2026-06-15 à partir d'un mapping complet du
> code existant (pipeline SMS n8n, edge functions, schéma canon, modèle sécu post-incident
> 2026-06-09) + recherche sur le format des leads Centris.
>
> **Périmètre** : tout le canal email — (A) ingestion des « Demandes d'information » Centris,
> (B) email comme canal conversationnel de l'adjointe IA, (C) relances email, (D) triage de
> la boîte du courtier. Doc **en un bloc** ; voir [§11 Séquencement](#11-séquencement-suggéré)
> pour l'ordre conseillé (le dev tranche).

---

## 1. Contexte & objectif

Klaris convertit des leads en conversations qualifiées. Aujourd'hui le seul canal entrant
automatisé est le **SMS** (Twilio → n8n → Claude → Supabase). Le besoin : faire la même chose
en **email**, et capter en particulier les leads **Centris** (le MLS du Québec, APCIQ/QPAREB)
qui arrivent dans la boîte du courtier sous forme de « Demande d'information / Contacter le
courtier ».

L'adjointe IA elle-même est déjà **agnostique au canal** : le system prompt
([`adjointe_systeme.md`](../mvp_adjointe_ia/src/prompts/adjointe_systeme.md)) ne contient
**aucune** règle SMS (pas de limite 160 caractères, pas de formatage SMS). Donc le
raisonnement Claude, le parsing d'action et la qualification se réutilisent **tels quels**.
**Le travail est de la plomberie, pas du prompt.**

---

## 2. Architecture cible

```
                         ┌──────────────────────────────────────────┐
   EMAIL ENTRANT         │  Edge Function `email-intake` (Deno)      │
  (RFI Centris,    ─────▶│  1. vérif signature provider (HMAC)       │
   réponse prospect)     │  2. unwrap forward + strip HTML→texte     │
   via forward-to-parse  │  3. parse (Centris bilingue / générique)  │
                         │  4. qualif Claude (Haiku)                 │
                         │  5. find/create prospect par email        │
                         │  6. INSERT conversations (channel='email')│
                         │  7. INSERT audit_log                      │
                         └───────────────┬──────────────────────────┘
                                         │ (service_role)
                                         ▼
                              ┌──────────────────────┐
                              │  Supabase (canon)     │
                              │  prospects /          │
                              │  conversations /      │◀───────┐
                              │  relances / audit_log │        │
                              └──────────┬────────────┘        │
                                         │                     │
   EMAIL SORTANT          ┌──────────────▼───────────────┐     │
  (réponse adjointe,      │  n8n : branche email          │     │
   relance)         ◀─────│  - charge historique          │─────┘
                          │  - Claude (réutilise prompt)  │
                          │  - check is_email_optout()    │
                          │  - envoi via Resend/SendGrid  │
                          │  - persist outbound           │
                          └───────────────────────────────┘
```

**Décision actée** : l'**intake** (entrant) est une **edge function Supabase** calquée sur
[`voicemail-intake/index.ts`](../klaris_ios/supabase/functions/voicemail-intake/index.ts)
(surface sécu concentrée, service_role, même pattern upsert+qualif+log+audit). Les **réponses
et relances** (sortant) restent dans **n8n**, en branche parallèle au SMS. Conséquence
assumée : deux codebases touchent `conversations` — elles doivent utiliser **exactement** les
mêmes noms de colonnes canon (voir §3).

---

## 3. ⚠️ Prérequis bloquants à résoudre AVANT de coder

Ces points cassent l'implémentation si ignorés. Les régler en premier.

### 3.1 Deux schémas en conflit — lequel est en prod ?
- Le schéma **canon** = [`001_create_next_move_schema.sql`](../001_create_next_move_schema.sql)
  (prospects) + [`klaris_ios/migrations/003_sprint2_klaris.sql`](../klaris_ios/migrations/003_sprint2_klaris.sql)
  (conversations/relances/audit_log), réconcilié par
  [`008_convergence_canonical_schema.sql`](../008_convergence_canonical_schema.sql).
- Le `008` **drop la table `conversations` legacy** du 001 → les colonnes `canal` et
  `metadata jsonb` **n'existent plus**. Il faut les **re-créer** (voir §4). Toute affirmation
  « conversations a déjà un champ canal » est fausse pour le schéma vivant.

### 3.2 Bug latent confirmé : `voicemail-intake` écrit des colonnes inexistantes
Preuve : [`voicemail-intake/index.ts:80-99`](../klaris_ios/supabase/functions/voicemail-intake/index.ts)
écrit `prospects.type / secteur / budget / pre_approuve / score / status`.
Le canon ([`001:22-36`](../001_create_next_move_schema.sql)) a `type_projet` (NOT NULL),
`statut`, `score_chaleur`, `canal_source`, `langue_preferee` — et **aucune** colonne
`type/secteur/budget/pre_approuve/score/status` sur `prospects` (`secteur` est sur `courtiers`,
`budget_min/max` sur `besoins_acheteur`).

→ **Soit la prod tourne un schéma différent du canon, soit voicemail-intake est déjà cassé.**
**Ne PAS copier les noms de colonnes de voicemail dans `email-intake`.** Vérifier le schéma
réellement déployé (`\d prospects` sur la base prod) et utiliser les noms canon. Régler aussi
voicemail au passage (issue séparée).

### 3.3 `prospects.type_projet` est NOT NULL — un lead email frais n'est pas classifiable
`type_projet text NOT NULL CHECK (type_projet IN ('acheteur','vendeur'))`. Un RFI Centris ou
un premier email ne dit pas toujours acheteur vs vendeur. Options (à trancher, §12) :
1. rendre `type_projet` **nullable** pour les lignes d'origine email ;
2. **classifier d'office** par Claude à l'intake (forcer acheteur/vendeur) ;
3. valeur par défaut `'acheteur'` au create, corrigée plus tard.
Recommandation : **(1) nullable** — la migration `010` relâche la contrainte ; l'adjointe
classifie au fil de la conversation via l'action `mise_a_jour_fiche` existante.

### 3.4 Échantillon Centris « golden » manquant
Pas d'API Centris, pas de payload structuré. Le format exact (`From:` réel, gabarit de sujet,
HTML vs texte) **n'est documenté nulle part** — il faut **2 emails bruts (.eml)** d'un courtier
québécois actif : un **FR** et un **EN**, un **rattaché à une fiche** (avec No. Centris) et un
**générique** (profil courtier). Le parser ne peut être finalisé sans ça (voir §6).

### 3.5 Routage multi-tenant
Aujourd'hui le pilote est mono-courtier (`DEFAULT_COURTIER_*` dans
[`.env.example`](../.env.example), `COURTIER_ID` en dur dans voicemail). Pour l'email il faut
décider comment un email forwardé résout son `courtier_id` (adresse de parse par courtier,
sous-adressage `leads+<courtier>@...`, ou mapping domaine). Phase mono-courtier : `courtier_id`
= constante. Multi-courtier : §12.

---

## 4. Modifications de schéma — `010_email_channel.sql`

Migration **additive**, idempotente (`IF NOT EXISTS`), **aucun NOT NULL sans backfill**. À
appliquer après 008/009. Respecte le modèle sécu (RLS forcé, anon révoqué — voir §9).

```sql
begin;

-- 4.1 conversations : (re)introduit canal + métadonnées email + idempotence + threading
alter table public.conversations
  add column if not exists channel text not null default 'sms'
    check (channel in ('sms','email','web')),
  add column if not exists metadata jsonb,                    -- From/To/Subject/Message-ID/headers DKIM/SPF
  add column if not exists external_message_id text,          -- Message-ID email / ID RFI Centris
  add column if not exists in_reply_to uuid references public.conversations(id) on delete set null;

-- idempotence : un même email ne crée pas deux lignes (retries webhook / re-ingest Centris)
create unique index if not exists ux_conversations_ext_msg
  on public.conversations (prospect_id, channel, external_message_id)
  where external_message_id is not null;

create index if not exists idx_conversations_in_reply_to
  on public.conversations (in_reply_to) where in_reply_to is not null;

-- 4.2 prospects : origine, MLS Centris, unicité email, type_projet nullable (cf 3.3)
alter table public.prospects
  add column if not exists source text
    check (source in ('sms','email','centris','web','manual')),
  add column if not exists centris_mls text;

create unique index if not exists ux_prospects_courtier_email
  on public.prospects (courtier_id, email) where email is not null;

-- relâche la contrainte NOT NULL pour les leads non classifiés (décision §3.3 option 1)
alter table public.prospects alter column type_projet drop not null;

-- 4.3 email_optout : miroir EXACT de sms_optout (008) — CASL/Loi 25
create table if not exists public.email_optout (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  reason text not null check (reason in
    ('stop_keyword','manual','complaint','bounce','oaciq_request','unsubscribe','dmarc_bounce')),
  source_message text,
  courtier_id uuid references public.courtiers(id) on delete set null,
  created_at timestamptz not null default now()
);
alter table public.email_optout enable row level security;
alter table public.email_optout force row level security;
revoke all on public.email_optout from anon;
-- lecture par le courtier propriétaire (vérif conformité), écritures par service_role uniquement
create policy email_optout_select_own on public.email_optout
  for select to authenticated using (courtier_id = auth.uid());

create or replace function public.is_email_optout(p_email text)
  returns boolean language sql stable security definer set search_path = '' as $$
    select exists (select 1 from public.email_optout where email = lower(p_email));
$$;

-- 4.4 relances : ajoute le canal (SMS par défaut, conserve le legacy)
alter table public.relances
  add column if not exists channel text not null default 'sms'
    check (channel in ('sms','email'));

commit;
```

> **Coordination PR #26 (relances)** : le `relances.channel` doit atterrir **dans** le travail
> relances en cours, pas en double. Ne pas re-trancher les décisions D1–D23 du Sprint 2.

**Phase 3 (triage boîte, scope D)** ajoutera, en migration séparée, `email_inbox_sync`
(creds IMAP/OAuth par courtier, **service_role only**) et `email_webhook_events`
(forensics/dedup). À différer.

---

## 5. Intake email entrant — edge function `email-intake`

Calque [`voicemail-intake/index.ts`](../klaris_ios/supabase/functions/voicemail-intake/index.ts).
Emplacement : `klaris_ios/supabase/functions/email-intake/index.ts`.

### 5.1 Modèle de réception : forward-to-parse
La réalité confirmée (cf §6) : les courtiers **forwardent** la notification Centris vers une
adresse de parse Klaris (ex. `leads@in.klaris.app`), comme le `@followupboss.me` de Follow Up
Boss. Le provider (Resend / Postmark / SendGrid inbound parse) POST le MIME parsé sur la
fonction. **Conséquences** :
- le `From:` enveloppe est souvent la boîte du courtier qui forwarde → **ne pas s'y fier** ;
- il faut **déballer** `Fwd:`/`Tr:`, retirer les marqueurs `>`, trouver le bloc Centris interne.

### 5.2 Abstraction provider (décision : agnostique)
La doc reste agnostique — supporter **Resend / Postmark / SendGrid** via factory + variable
`EMAIL_PROVIDER_TYPE`. Chaque provider diffère sur : forme du POST, header de signature,
extraction MIME. Resend est **déjà** une dépendance (envoi dans
[`daily-briefing/index.ts`](../klaris_ios/supabase/functions/daily-briefing/index.ts)) → à
privilégier **si** son inbound parse + vérif signature conviennent.

```ts
// providers/index.ts — factory
interface InboundParser {
  verifySignature(req: Request, rawBody: string): Promise<boolean>;
  parse(rawBody: string): ParsedEmail;   // { from,to,subject,text,html,messageId,headers }
}
export function getParser(kind = Deno.env.get("EMAIL_PROVIDER_TYPE")): InboundParser {
  switch (kind) {
    case "resend":   return new ResendParser();
    case "postmark": return new PostmarkParser();
    case "sendgrid": return new SendgridParser();
    default: throw new Error(`EMAIL_PROVIDER_TYPE inconnu: ${kind}`);
  }
}
```

### 5.3 Squelette de la fonction
```ts
Deno.serve(async (req) => {
  const raw = await req.text();
  const parser = getParser();

  // 1. SIGNATURE OBLIGATOIRE — avant tout accès DB (ne PAS copier le gap SMS, cf §9)
  if (!(await parser.verifySignature(req, raw))) {
    return json({ ok: false }, 401);            // 401 nu, aucun PII en réponse
  }

  const email = parser.parse(raw);              // { from,to,subject,text,html,messageId,headers }
  const inner = unwrapForward(email);           // déballe Fwd:/Tr:, strip '>', HTML→texte

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!  // service_role : bypass RLS, acteur de confiance
  );

  // 2. IDEMPOTENCE — Message-ID déjà vu ? renvoyer 200 (silence les retries)
  if (await alreadyIngested(supabase, inner.messageId)) return json({ ok: true, dedup: true });

  // 3. parsing métier : RFI Centris (labels bilingues) sinon email libre (cf §6)
  const fields = parseCentrisOrGeneric(inner);  // { prenom,nom,courriel,telephone,message,centrisMls? }

  // 4. qualif Claude (Haiku — coût) ; réutilise la logique de qualif existante
  const qualif = await qualifyWithClaude(fields.message);  // { type_projet?, langue, score_chaleur, ... }

  // 5. find/create prospect PAR EMAIL — noms de colonnes CANON (cf §3.2)
  const courtierId = resolveCourtier(inner);    // mono-tenant: constante ; multi: §3.5
  const prospect = await findOrCreateByEmail(supabase, {
    courtier_id: courtierId,
    email: fields.courriel,
    nom: fields.nom, prenom: fields.prenom,
    telephone: fields.telephone ?? null,
    canal_source: "email",
    source: fields.centrisMls ? "centris" : "email",
    centris_mls: fields.centrisMls ?? null,
    type_projet: qualif.type_projet ?? null,    // nullable (cf §3.3)
    statut: "nouveau",
    score_chaleur: qualif.score_chaleur ?? 0,
    langue_preferee: qualif.langue ?? "fr",
  });

  // 6. INSERT conversation entrante
  await supabase.from("conversations").insert({
    prospect_id: prospect.id,
    direction: "inbound",
    sender: "prospect",
    channel: "email",
    content: fields.message,
    external_message_id: inner.messageId,
    in_reply_to: await resolveThreadParent(supabase, inner.headers["in-reply-to"]),
    metadata: { from: inner.from, to: inner.to, subject: inner.subject,
                headers: pick(inner.headers, ["message-id","in-reply-to","dkim-signature","received-spf"]),
                centris_mls: fields.centrisMls ?? null },
    sent_at: inner.date ?? new Date().toISOString(),
  });

  // 7. audit
  await supabase.from("audit_log").insert({
    prospect_id: prospect.id, action: "email_qualified",
    payload: { provider: Deno.env.get("EMAIL_PROVIDER_TYPE"), message_id: inner.messageId,
               sender_domain: domainOf(fields.courriel), score: qualif.score_chaleur },
  });

  return json({ ok: true, prospect_id: prospect.id, score: qualif.score_chaleur });
});
```

### 5.4 Déclenchement de la conversation
Après l'intake, déclencher la 1re réponse de l'adjointe **et** programmer les relances initiales,
comme le SMS (`buildCourtierNotification` + `scheduleInitialFollowUps` dans
[`sms_handler.js`](../mvp_adjointe_ia/src/flows/sms_handler.js)). Deux options : la fonction
appelle directement Claude pour répondre, OU elle pose la conversation et n8n (branche email)
prend le relais. **Reco** : intake = qualif + persistance ; **réponse/relance = n8n** (un seul
endroit possède la logique conversationnelle + l'envoi + le guard opt-out).

### 5.5 Déploiement
```bash
supabase functions deploy email-intake
supabase secrets set EMAIL_PROVIDER_TYPE=resend EMAIL_WEBHOOK_SECRET=... EMAIL_PROVIDER_API_KEY=...
# configurer l'inbound parse du provider pour POST -> https://<ref>.functions.supabase.co/email-intake
```

---

## 6. Parser RFI Centris

**Pas d'API Centris, pas de JSON/XML.** Comme Follow Up Boss / Lofty : **parsing du corps par
labels**. Ancrer sur les **labels bilingues**, jamais sur `From:`/sujet (mail souvent forwardé).

### 6.1 Champs FIABLES (construire le parser dessus)
Toujours présents : **prénom, nom, courriel, téléphone, message** (texte libre).

| Champ | Label FR | Label EN |
|------|----------|----------|
| Prénom | `Prénom` | `First name` |
| Nom | `Nom` | `Last name` |
| Courriel | `Courriel` | `Email` |
| Téléphone | `Téléphone` | `Phone` |
| Message | `Message` | `Message` |
| **MLS (optionnel)** | `No. Centris` | `MLS` |

Bloc **propriété/MLS** : présent **uniquement** pour les RFI rattachés à une fiche, absent sur
le formulaire générique profil-courtier. Traiter comme **nullable** → alimente
`prospects.centris_mls`. La ligne de **consentement** (FR « En cliquant sur « Envoyer », vous
consentez… ») est un token d'ancrage stable.

### 6.2 FRAGILE — ne PAS coder en dur (capturer le golden .eml d'abord, cf §3.4)
- `From:` exact (probablement `no-reply@…centris.ca`, **non confirmé**, et le forward le change) ;
- gabarit de **sujet** — non documenté ;
- **HTML vs texte** : très probablement HTML + alt texte → parser **HTML→texte d'abord**, repli
  sur `text/plain`.

### 6.3 Stratégie
1. déballer le forward (`Fwd:`/`Tr:`, strip `>`) → bloc interne ;
2. extraire HTML→texte ;
3. matcher les labels bilingues (regex tolérante casse/accents) ;
4. champs requis = 5 ; MLS optionnel ;
5. si aucun label Centris détecté → traiter comme **email libre** (canal conversationnel B),
   pas comme RFI.

---

## 7. Email sortant : canal conversationnel (B) + relances (C)

Branche n8n parallèle au workflow SMS
([`n8n_workflow_sms.json`](../mvp_adjointe_ia/src/flows/n8n_workflow_sms.json)). Réutilise tout
le cœur (lookup, historique, Claude, parsing d'action via `parseClaudeResponse`,
`updateClientFromAction`). Seuls changent : déclencheur, guard opt-out, nœud d'envoi, persistance.

| Étape SMS | Équivalent email |
|-----------|------------------|
| webhook `sms-entrant` (Twilio) | réponse routée depuis l'intake / nouveau message prospect |
| `is_phone_optout(telephone)` avant envoi | **`is_email_optout(email)`** avant envoi |
| nœud Twilio Send SMS | nœud **Resend / SendGrid** (`from`=courtier, `reply-to`, `subject`, `body`) |
| persist outbound (`direction='outbound'`) | idem + `channel='email'`, `metadata` headers |
| STOP → `record_stop_optout` | lien désabonnement / `List-Unsubscribe` → `record_email_optout` |
| relance scheduler SMS (`j2/j5/j10`) | scheduler branche sur `relances.channel` (SMS vs email) |

**CASL/Loi 25 obligatoire sur tout envoi** :
- `is_email_optout()` vérifié **avant chaque** envoi sortant ;
- **lien de désabonnement dans chaque pied de page** (exigence CASL) ;
- footer transactionnel : « Gérer mes préférences : [token désabo signé HMAC] » → endpoint
  service_role qui INSERT `email_optout(email,'unsubscribe')` (`ON CONFLICT(email) DO UPDATE`) ;
- consentement : implicite-sur-réponse (cf `adjointe_systeme.md`) ; un RFI Centris entrant =
  base relation-courtier explicite.

**Relances** : `relances.channel` choisit l'émetteur. Coordonner avec PR #26 (cf §4).

---

## 8. Triage de la boîte courtier (D) — le plus lourd, à différer

Pour lire la boîte **générale** du courtier (pas seulement le forward), il faut **IMAP/OAuth** :
- table `email_inbox_sync` (par courtier : `email_address`, `oauth_refresh_token` chiffré,
  `oauth_scope`, `sync_status`, `last_sync_at`…) — **service_role only**, jamais exposée aux
  users authentifiés ;
- cron de refresh des tokens OAuth (Google/Microsoft), scope **restreint** `gmail.readonly`,
  TLS 1.2+, alerte + `sync_status='error'` après 3 échecs ;
- classification (lead vs admin vs spam) par Claude avant de créer un prospect ;
- `email_webhook_events` pour forensics/dedup/replay.

Dépend du canal (`conversations.channel`) et du parser construits avant. **Ne pas commencer D
avant que A/B/C soient stables.**

---

## 9. Sécurité & conformité (baseline post-incident 2026-06-09)

Réfs : [`SECURITY.md`](../SECURITY.md),
[`009_security_lockdown_anon.sql`](../009_security_lockdown_anon.sql),
[`klaris_ios/migrations/008_security_invoker_views.sql`](../klaris_ios/migrations/008_security_invoker_views.sql),
[`docs/security/REMEDIATION_RUNBOOK.md`](security/REMEDIATION_RUNBOOK.md).

- [ ] **Anon = zéro accès.** Toute table `email_*` : `ENABLE` + `FORCE ROW LEVEL SECURITY`,
  `REVOKE ALL ... FROM anon`, policies write `service_role`-only, SELECT `authenticated`
  uniquement où le courtier en a besoin (ex. vérif opt-out).
- [ ] **service_role pour la persistance.** L'edge fn intake est l'acteur de confiance — c'est
  **elle** qui estampille le bon `courtier_id`. Aucune écriture browser/anon.
- [ ] **Signature webhook OBLIGATOIRE — c'est le gap actuel.** Le webhook SMS n8n ne valide
  **aucune** signature aujourd'hui (path `sms-entrant`, pas de HMAC). **Ne pas reproduire ce
  trou** : vérifier la signature provider (token Postmark / HMAC-SHA256 SendGrid/Resend contre
  `EMAIL_WEBHOOK_SECRET`) **avant tout accès DB**, rejet `401` nu (aucun PII en réponse).
- [ ] **Isolation tenant.** Chaque `conversations` chaîne vers `courtier_id` via `prospect_id`.
  Lookups **paramétrés** (`WHERE email = $1 AND courtier_id = $2`) — jamais d'interpolation de
  chaîne (la SQLi était une découverte du hardening).
- [ ] **Idempotence.** Dedup sur `external_message_id` (Message-ID) avant INSERT ; renvoyer 200
  sur doublon.
- [ ] **CASL / Loi 25.** `is_email_optout()` avant chaque envoi ; lien désabo dans chaque
  footer ; payload brut + headers conservés pour audit OACIQ ; soft-delete only
  (`deleted_at`, `ON DELETE RESTRICT` préservés). Pénalité CASL : jusqu'à 10 M$ CAD.
- [ ] **Secrets en env**, jamais en code/git (`.gitignore` déjà durci). Résidence des données :
  Supabase **ca-central-1** obligatoire.
- [ ] **Pas de PII dans les logs/erreurs.** Forensics (hash, IP, timestamp) → table
  service_role only, pas stdout.

---

## 10. Variables d'environnement (ajouts à `.env.example`)

```
# Canal email
EMAIL_PROVIDER_TYPE=        # resend | postmark | sendgrid
EMAIL_PROVIDER_API_KEY=     # clé d'envoi sortant
EMAIL_WEBHOOK_SECRET=       # secret de vérif signature inbound
EMAIL_PARSE_ADDRESS=        # ex: leads@in.klaris.app (forward-to-parse)
# (Phase D) OAuth boîte courtier
OAUTH_CLIENT_ID=
OAUTH_CLIENT_SECRET=
```
Existants réutilisés : `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `ANTHROPIC_API_KEY`,
`DEFAULT_COURTIER_EMAIL`.

---

## 11. Séquencement suggéré (le dev tranche)

Doc en un bloc, mais l'ordre des dépendances reste : tout B/C/D réutilise le **canal**
(`conversations.channel`) et le **parser** construits pour A.

1. **Fondations** : migration `010` (§4) + résoudre les prérequis §3 (schéma prod, type_projet,
   noms de colonnes).
2. **Ingest (A)** : edge fn `email-intake` + parser Centris (§5, §6). Aucun envoi → zéro risque
   CASL. Livre « lead → fiche + conversation démarrée ». ROI immédiat.
3. **Sortant (B+C)** : `email_optout`/`is_email_optout`, branche n8n d'envoi, `relances.channel`,
   footer/désabo CASL (§7). C'est là que la conformité doit être étanche.
4. **Triage boîte (D)** : IMAP/OAuth, `email_inbox_sync` (§8). Le plus lourd, en dernier.

---

## 12. Décisions ouvertes à confirmer

1. **`type_projet`** : nullable (reco) vs classif forcée vs défaut `'acheteur'`. → impacte `010`
   + intake.
2. **Schéma prod réel** (§3.2) : confirmer `\d prospects`/`\d conversations` en prod avant de
   figer les noms de colonnes. Corriger voicemail-intake en parallèle.
3. **Provider** : Resend (déjà là) vs Postmark vs SendGrid — la doc reste agnostique (factory) ;
   trancher à l'impl selon support inbound parse + signature.
4. **Routage multi-tenant** (§3.5) : adresse unique + sous-adressage `leads+<courtier>@…` vs
   adresse par courtier. Mono-courtier pour démarrer.
5. **Golden Centris .eml** (§3.4) : **qui fournit** 1 FR + 1 EN (rattaché fiche + générique) ?
   Bloque la finalisation du parser.
6. **Threading vs nouveau prospect** quand un RFI arrive d'un email déjà lié à un autre
   `canal_source` (ex. prospect SMS existant) : fusionner ou garder distinct par canal ?

---

## 13. Fichiers de référence

| Rôle | Fichier |
|------|---------|
| Workflow SMS (à cloner pour la branche email) | [`mvp_adjointe_ia/src/flows/n8n_workflow_sms.json`](../mvp_adjointe_ia/src/flows/n8n_workflow_sms.json) |
| Fonctions n8n SMS | [`mvp_adjointe_ia/src/flows/sms_handler.js`](../mvp_adjointe_ia/src/flows/sms_handler.js) |
| System prompt (channel-agnostic, réutilisé) | [`mvp_adjointe_ia/src/prompts/adjointe_systeme.md`](../mvp_adjointe_ia/src/prompts/adjointe_systeme.md) |
| **Template intake** (à calquer) | [`klaris_ios/supabase/functions/voicemail-intake/index.ts`](../klaris_ios/supabase/functions/voicemail-intake/index.ts) |
| Pattern envoi Resend | [`klaris_ios/supabase/functions/daily-briefing/index.ts`](../klaris_ios/supabase/functions/daily-briefing/index.ts) |
| Cible miroir `email_optout` | [`008_convergence_canonical_schema.sql`](../008_convergence_canonical_schema.sql) |
| Vraies colonnes `prospects` | [`001_create_next_move_schema.sql`](../001_create_next_move_schema.sql) |
| Baseline sécu | [`009_security_lockdown_anon.sql`](../009_security_lockdown_anon.sql), [`SECURITY.md`](../SECURITY.md), [`docs/security/REMEDIATION_RUNBOOK.md`](security/REMEDIATION_RUNBOOK.md) |
| Snippets n8n à cloner | [`n8n/node-snippets/`](../n8n/node-snippets/) (`persist_inbound`, `persist_outbound`, `check_sms_optout`, `record_stop_optout`) |

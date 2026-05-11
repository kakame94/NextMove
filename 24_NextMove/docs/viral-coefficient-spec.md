# Klaris — Viral Coefficient k — Spec & Plan B Paid

> **Action L5 du plan Lean Startup.** Mesurer le viral coefficient k (engine of growth #2 selon Ries Ch10) + définir plan B paid si k < 1.
> **Source méthodologique :** *The Lean Startup* Ch10 Engines of Growth.
> **Sprint cible :** Sprint 9.
> Date : 2026-05-08

---

## Pourquoi mesurer k

Citation Ch10 :
> *« Three Engines of Growth : Sticky · Viral · Paid. Each follows a different mathematical formula. »*
> *« Viral engine : every customer brings, on average, more than one new customer. The viral coefficient k is the rate at which existing customers refer new customers. »*

**Klaris dépend exclusivement du viral aujourd'hui** (deck slide 09 : « 100% referrals »). Si k < 1 → growth s'éteint après le réseau Joanel (M6-M9).

---

## Formule

```
k = (nb invitations envoyées par courtier × taux de conversion invitation → signup payant)

Exemple :
- Courtier moyen invite 4 confrères en 12 mois
- 25% des invités signent un abonnement payant
- k = 4 × 0.25 = 1.0 → seuil viral atteint
```

**Si k > 1 :** croissance virale auto-soutenue (chaque user en amène plus que lui-même).
**Si k = 1 :** croissance flat.
**Si k < 1 :** croissance s'éteint, besoin canal alternatif.

---

## Implémentation tracking (Sprint 9)

### 1. Feature « Inviter un confrère » in-app

**Fichiers à créer.**
- `klaris_ios/lib/features/referrals/invite_screen.dart`
- `klaris_web/src/app/referrals/page.tsx`
- `klaris_ios/migrations/009_sprint9_referrals.sql`

**UX.**
- Card visible dans dashboard Klaris : « Inviter un confrère — Tu reçois 1 mois gratuit pour chaque referral signé »
- Tap → modal avec :
  - Email du confrère
  - Tel optionnel
  - Message pré-rédigé éditable : *« Salut [Nom], je teste Klaris pour gérer mes prospects SMS. Ça me sauve 2-3h/jour. Essaye 14j gratuit avec mon code : [CODE]. — [Joanel] »*
  - Bouton « Envoyer SMS » (Twilio) ou « Envoyer email » (Resend)

**SQL migration 009.**

```sql
-- Sprint 9 — Referrals tracking
create table public.referral_codes (
  code         text primary key,
  source_broker_id uuid not null references public.brokers(id),
  created_at   timestamptz not null default now()
);

create table public.referral_invitations (
  id           uuid primary key default gen_random_uuid(),
  code         text not null references public.referral_codes(code),
  source_broker_id uuid not null references public.brokers(id),
  invited_email text not null,
  invited_phone text,
  channel      text check (channel in ('sms', 'email')),
  sent_at      timestamptz not null default now(),
  signed_up_broker_id uuid references public.brokers(id),
  signed_up_at timestamptz,
  paid_subscription_at timestamptz
);

create index idx_referrals_source on public.referral_invitations(source_broker_id);
create index idx_referrals_signed on public.referral_invitations(signed_up_at);

-- View pour calcul k
create view public.viral_coefficient_monthly as
select
  date_trunc('month', sent_at) as month,
  count(distinct source_broker_id) as inviting_brokers,
  count(*) as invitations_sent,
  round(count(*)::numeric / count(distinct source_broker_id), 2) as avg_invitations_per_broker,
  count(*) filter (where signed_up_at is not null) as signups_from_invitations,
  count(*) filter (where paid_subscription_at is not null) as paid_from_invitations,
  round(
    100.0 * count(*) filter (where paid_subscription_at is not null) / nullif(count(*), 0),
    2
  ) as conversion_invit_to_paid_pct,
  round(
    (count(*)::numeric / nullif(count(distinct source_broker_id), 0)) *
    (count(*) filter (where paid_subscription_at is not null)::numeric / nullif(count(*), 0)),
    3
  ) as viral_coefficient_k
from public.referral_invitations
group by month
order by month desc;
```

### 2. Onboarding : générer code referral à chaque signup

À l'activation broker :

```sql
insert into public.referral_codes (code, source_broker_id)
values (substring(md5(random()::text), 1, 8), :new_broker_id);
```

### 3. Tracking attribution sur signup

Lors du signup d'un nouveau broker, accepter param URL `?ref=XXXXXXXX` :

```sql
update public.referral_invitations
set signed_up_broker_id = :new_broker_id,
    signed_up_at = now()
where code = :ref_code
  and signed_up_at is null;
```

Lors du 1er paiement Stripe :

```sql
update public.referral_invitations
set paid_subscription_at = now()
where signed_up_broker_id = :broker_id;
```

### 4. Reward source broker

Edge Function `apply-referral-reward` (Sprint 9) :
- Listen Stripe webhook `customer.subscription.created`
- Si attribution referral → ajouter 1 mois gratuit au source_broker (Stripe coupon)

---

## Mesure k — cadence

| Cadence | Action |
|---------|--------|
| Hebdomadaire | Dashboard Looker affiche k rolling 90 jours |
| Mensuelle | Inclus dans `ebm-reports/YYYY-MM.md` |
| Trimestrielle | Décision Pivot/Persevere basée sur k (cf. [pivot-persevere/](./pivot-persevere/)) |

---

## Plan B Paid — si k < 1 à M9

Citation Ch10 :
> *« Paid engine : LTV must be greater than CAC. Sustainable if LTV/CAC ≥ 3. »*

### Calculs LTV (Klaris solo)

```
Prix : 100 CAD/mois
Churn cible : 5%/mois
LTV = 100 / 0.05 = 2 000 CAD (durée moyenne 20 mois)
LTV/CAC ≥ 3 → CAC max = 666 CAD
```

### Canaux paid testables (par ordre coût croissant)

| Canal | Coût/lead estimé | CAC visé (avec ~10% conv lead→paid) | Test budget Sprint 9-12 |
|-------|------------------|---------------------------------------|--------------------------|
| LinkedIn DM directeurs agence | ~5 CAD/lead (temps) | ~50 CAD | 30 DM gratuit |
| OACIQ events sponsoring | ~30 CAD/lead | ~300 CAD | 1 event 1500 CAD |
| Google Ads keywords « CRM courtier QC » | ~40 CAD/lead | ~400 CAD | 1000 CAD/mois 3 mois |
| Facebook Ads ciblage courtiers | ~25 CAD/lead | ~250 CAD | 500 CAD/mois 3 mois |
| Centris partner program | ~60 CAD/lead (revenue share) | ~600 CAD | dialogue Centris Q3 |
| Affiliate courtiers payés (rev-share) | 1ère mensualité | ~100 CAD | active à M6 si k<1 |

### Décision M9 (selon Pivot/Persevere Q3)

| k mesuré | Décision |
|----------|----------|
| k ≥ 1.0 | **Persevere viral** — pas de canal paid, doubler incentive referral |
| 0.7 ≤ k < 1.0 | **Persevere + boost** — 2 mois gratuits par referral signé (vs 1) |
| 0.3 ≤ k < 0.7 | **Hybrid** — Google Ads $1000/mois pendant 3 mois, mesurer LTV/CAC |
| k < 0.3 | **Channel pivot complet** — kill referrals, full Google + Centris partner + LinkedIn |

---

## Anti-patterns Lean (Ch10)

| Anti-pattern | Mitigation |
|---------------|------------|
| Optimiser k avant de l'avoir mesuré | Mesurer 6 mois minimum (M3-M9) avant ajustement |
| Mélanger 2 engines en même temps | Si on active paid + viral simultanément → impossible d'attribuer croissance. Une à la fois. |
| Mesurer k au niveau total (vanity) | Mesurer **par cohort mensuel** — l'engine ralentit ou s'accélère ? |
| Pousser k via incentive cash gigantesque | Si on paie 100 CAD/referral, biaise : referral signé pour 100 CAD, pas pour le produit |

---

## Suivi

- [ ] Sprint 9 : migration 009 + feature « Inviter un confrère » (iOS + web)
- [ ] Sprint 9 : Edge Function reward referral
- [ ] Sprint 10 : view `viral_coefficient_monthly` exposée dans dashboard interne
- [ ] M3 (Q1 meeting) : k préliminaire (probablement N/A car cohort trop jeune)
- [ ] M6 (Q2 meeting) : k mesuré sur 5 premiers payants, décision GO/AMBER/NO-GO
- [ ] M9 (Q3 meeting) : si NO-GO viral → activer plan B paid

---

*Spec v1.0 — 2026-05-08 — basé sur* The Lean Startup *Ch10 Engines of Growth*

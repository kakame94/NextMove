# Klaris — Cohort Funnel Template

> **Action L2 du plan post-challenge Lean Startup.** Template de cohort analysis mensuel pour Innovation Accounting (Eric Ries, Ch7).
> **Source méthodologique :** The Lean Startup Ch7 Measure (IMVU example p.124-127).
> **Cadence :** publication 1er du mois suivant dans `ebm-reports/YYYY-MM.md`.
> Date : 2026-05-08

---

## Pourquoi cohort, pas total

Citation Ch7 :
> *« Instead of looking at cumulative totals or gross numbers such as total revenue and total customers, one looks at the performance of each group of customers that comes into contact with the product independently. »*

Total registered users = **vanity metric** (hockey stick trompeur). Cohort retention = **actionable metric** (vraie vélocité produit).

---

## Funnel Klaris — 5 étapes

```
1. LEAD          Prospect courtier visite landing OU referral reçu
2. SIGNUP        Création compte broker (email + tel + numéro Twilio assigné)
3. ACTIVATION    1er prospect SMS effectivement traité par Klaris (handover réel)
4. ENGAGEMENT    5e prospect qualifié auto sur la cohort (preuve de répétabilité)
5. PAID          Conversion trial 14j → carte bancaire active Stripe (100 CAD/mois)
6. RETENTION M3  Toujours payant 90 jours après PAID
```

---

## Métriques par étape

| # | Métrique | Source | Calcul |
|---|----------|--------|--------|
| F1 | LEAD → SIGNUP | Landing analytics + Supabase `brokers.created_at` | `count(signup) / count(lead)` |
| F2 | SIGNUP → ACTIVATION | Supabase `prospects.first_handover_at` | `count(activated) / count(signup)` (TTV en jours) |
| F3 | ACTIVATION → ENGAGEMENT | Supabase view `broker_engagement` | `count(>=5 prospects qualifiés) / count(activated)` |
| F4 | ENGAGEMENT → PAID | Stripe webhook `customer.subscription.created` | `count(paid) / count(engaged)` |
| F5 | PAID → RETENTION M3 | Stripe webhook `subscription.canceled` (négatif) | `count(active at M+90) / count(paid at M+0)` |
| —  | NPS courtier | `nps_responses` table (cf. nps-spec.md) | `% promoters - % detractors` |
| —  | Viral k (LF2) | `referral_invitations` table | `(invits/courtier) × (signup_rate/invit)` |

---

## Template rapport mensuel

À publier dans `24_NextMove/docs/ebm-reports/YYYY-MM.md` le 1er de chaque mois.

```markdown
# EBM Report — Klaris — [Mois Année]

> Cohort analysis + EBM KVMs. Owner : Eliot. Revue : équipe Sprint Review.
> Source : cohort-funnel-template.md

## Résumé

- **MRR mois** : X CAD
- **MRR variation vs mois -1** : ±X %
- **N courtiers payants actifs** : X
- **NPS médian (n=Y)** : X
- **Viral coefficient k** : X.XX (cible ≥ 1.0)

## Cohort funnel — Mois M

| Cohort | LEAD | SIGNUP | ACTIVATION | ENGAGEMENT | PAID | RETENTION M3 |
|--------|------|--------|------------|------------|------|--------------|
| 2026-04 | 25 | 8 (32%) | 6 (75%) | 4 (67%) | 3 (75%) | 3 (100%) |
| 2026-05 | 40 | 12 (30%) | 10 (83%) | 8 (80%) | 5 (63%) | en cours |
| 2026-06 | … | … | … | … | … | … |

**Lecture (selon Ries Ch7 IMVU example) :** chercher amélioration des conversions par cohort dans le temps. Si stagne → tuner engine échoue → décision pivot/persevere prochaine.

## EBM KVMs (3 KVAs)

### Current Value
- Revenue per Employee (MRR/4 fondateurs) : X CAD
- Product Cost Ratio : X CAD TCO + Y CAD Cost-to-Build
- Employee Satisfaction (Happiness Index Sprint Retro moyen) : X/5
- Customer Satisfaction (NPS) : X (n=Y)

### Time-to-Market
- Release Frequency (rolling 3-month) : X releases/mois
- Release Stabilization : X jours moyenne
- Cycle Time (idée → prod) : X jours médiane
- **On-Product Index** : X % (cible >70%)

### Ability to Innovate
- Usage Index : X % features utilisées par > 50% courtiers
- Innovation Rate : X % code nouveau (git stats)
- Defects (Sentry) : X critiques + Y warnings ce mois

## Décisions Sprint suivant

- [ ] …

## Status leap-of-faith assumptions

| Hypothèse | M0 | M-1 | M actuel | Tendance |
|-----------|-----|------|-----------|----------|
| LF1 Value (3/10 conv trial→paid) | — | X | X | ↑/↓/→ |
| LF2 Growth (k ≥ 1.0) | — | X | X | ↑/↓/→ |
| LF3 Compliance (OACIQ status) | dialogue ouvert | en cours | … | … |
```

---

## Premier rapport Mai 2026 (M0 — baseline)

Voir [ebm-reports/2026-05.md](./ebm-reports/2026-05.md) (créé en parallèle).

**Note baseline.** À M0 (mai 2026), beaucoup de métriques = N/A car pas encore de courtiers payants. Le tableau cohort sert d'**outil prêt** plutôt que de mesure réelle.

---

## Outils techniques

| Tool | Usage | Status |
|------|-------|--------|
| Supabase | Source de vérité brokers + prospects + Stripe events | ✅ en place |
| PostHog ou Amplitude (à choisir) | Funnel UI + cohort retention auto | 📋 Sprint 9 |
| Stripe | Subscription state + churn webhook | ✅ en place |
| Looker Studio (free) | Dashboard exécutif visualisé | 📋 Sprint 9 |
| GitHub Actions | Auto-publication rapport `ebm-reports/YYYY-MM.md` chaque 1er du mois | 📋 Sprint 10 |

---

## Suivi

- [ ] Sprint 8 : ce template publié + onboarding équipe
- [ ] Sprint 9 : intégration PostHog ou Amplitude
- [ ] M0 (mai 2026) : 1er rapport baseline publié
- [ ] M+1 (juin 2026) : 2e rapport, comparaison cohort
- [ ] M3 : revue trimestrielle Pivot/Persevere basée sur cohort

---

*Document v1.0 — 2026-05-08 — basé sur* The Lean Startup *— Eric Ries, Ch7 Measure*

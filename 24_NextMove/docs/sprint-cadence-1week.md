# Klaris — Cadence Sprint 1 Semaine + Continuous Deployment

> **Action L6 du plan Lean Startup.** Réduire la cadence sprint de 4 semaines à 1 semaine + activer continuous deployment (Vercel preview + Supabase migrations auto + iOS TestFlight nightly).
> **Source méthodologique :** *The Lean Startup* Ch9 Batch (Toyota Production System).
> **Sprint cible de bascule :** Sprint 9.
> Date : 2026-05-08

---

## Pourquoi raccourcir le batch

Citation Ch9 :
> *« Small batches mean faster feedback loops. The Toyota Production System works on this principle. »*
> *« At IMVU we shipped multiple times per day. »*

Klaris actuel : Sprint = 4 semaines = 1 release/mois = cycle Build-Measure-Learn ≥ 30 jours.

Cible : 1 semaine de sprint + déploiement continu sur PR.

**Bénéfice attendu** : cycle BML ≤ 7 jours → apprentissage 4× plus rapide.

---

## Nouvelle cadence — Sprint 1 semaine

### Calendrier hebdomadaire

| Jour | Cérémonie | Durée | Owner |
|------|-----------|-------|-------|
| Lundi 9h | Sprint Planning hebdo | 30 min | Eliot facilite |
| Lundi-Vendredi | Daily async sur Slack `#klaris-daily` | 5 min/personne | Tous |
| Mercredi 14h (mid-sprint) | Sync technique (15 min) | 15 min | Dennis |
| Vendredi 16h | Sprint Review + Demo | 30 min | Tous + 1 broker invité (alterné) |
| Vendredi 16h30 | Sprint Retro | 20 min | Walkens facilite |
| Vendredi 17h | Happiness Index check (5 min) | 5 min | Eliot |

**Total cérémonies** : ~2h/semaine (vs ~4h/mois ancien rythme = ratio identique mais réparti).

### Capacity planning

- **Disponibilité hebdo réelle** : ~4 fondateurs × 80h/mois ÷ 4 sem = ~20h/semaine/fondateur
- **Capacity sprint** : ~80h équipe / sem
- **Cible velocity** : 5-8 user stories de ≤ 1 jour chacune par sprint

---

## Continuous Deployment — pipeline cible

```
Commit → Push GitHub → Auto :
  ├─→ Tests CI (GitHub Actions)
  ├─→ Vercel preview deploy (klaris_web)
  ├─→ Supabase migration dry-run
  └─→ iOS TestFlight nightly build (Fastlane + match)
```

### Phase 1 — Sprint 9 (3 j-h setup)

| Composant | Action | Owner |
|-----------|--------|-------|
| GitHub Actions CI | Workflow `.github/workflows/ci.yml` : `npm test` (web) + `flutter test` (iOS) + `pytest` (Edge functions) | Dennis |
| Vercel preview | Déjà actif (vérifier) | Walkens |
| Supabase migration check | `supabase db lint` dans CI + `supabase db diff` pour PR comments | Dennis |
| iOS TestFlight nightly | Fastlane lane `nightly_testflight` + Match certificats + Apple App Store Connect API key | Seydou |
| Branch protection main | PR review obligatoire + CI green + 1 approval | Eliot setup GitHub |

### Phase 2 — Sprint 10 (1 j-h setup)

| Composant | Action | Owner |
|-----------|--------|-------|
| Auto-merge Dependabot PRs (deps mineures) | GitHub Actions auto-merge si CI green + label `dependencies` | Dennis |
| Slack notif `#klaris-deploys` | Webhook GitHub Actions sur deploy success/fail | Walkens |
| Rollback 1-clic | Vercel deployment alias + Supabase migration revert script | Dennis |

### Phase 3 — Sprint 11 (futur)

- **Feature flags** (LaunchDarkly free tier ou Supabase config table) → ship code derrière flag, activer après vérif
- **Canary releases** iOS via TestFlight cohorts (10% users pendant 24h avant 100%)

---

## Définition de Done — sprint 1 semaine

User story = DONE si :
- [ ] Code mergé dans `main` avec PR approuvée
- [ ] Tests CI verts
- [ ] Vercel preview validé manuellement par 1 fondateur
- [ ] Supabase migration appliquée en staging Supabase
- [ ] (Si feature courtier-visible) Joanel testé en pré-prod et validé
- [ ] Sentry release tag créé
- [ ] User story fermée dans Linear avec lien commit

---

## Compatibilité avec actions L1-L7

| Action | Impact cadence 1 sem |
|--------|----------------------|
| L1 Leap-of-faith | Inchangé (revue trimestrielle) |
| L2 Cohort funnel | Updaté hebdo dans dashboard auto, rapport mensuel publié |
| L3 Pivot/Persevere | Inchangé (trimestriel) |
| L4 MVP par persona | Permet livraison Concierge/WoZ par batches hebdo |
| L5 Viral coefficient | Mesuré hebdo, décision trimestrielle |
| L7 5 Whys | Post-incident immédiat, retro mensuelle (pas hebdo) |

---

## Risques

| Risque | Mitigation |
|--------|------------|
| Capacity insuffisante (4 fondateurs surchargés) | Réduire scope de chaque sprint à 5 stories max. Pas accumuler |
| Tests cassent souvent → déploiement bloqué | Pre-commit hooks Husky + lint-staged côté dev |
| Apple TestFlight nightly review = 24h | Acceptable, pas bloquant pour autres composants |
| Dette technique reportée chaque sprint | Sprint 1× toutes les 8 sem dédié 100% tech debt |
| Sprint Review/Retro skipped « pas le temps » | Cérémonie sacrée, calendrier bloqué d'avance pour 6 mois |

---

## Anti-patterns Lean (Ch9)

| Anti-pattern | Mitigation |
|---------------|------------|
| Big batch = on stocke 4 features puis release une fois | Vercel preview + flag → release derrière flag immédiatement |
| « On va pas push vendredi soir » | Continuous deployment → push n'importe quand, monitoring 24/7 |
| Sprint planning > 1h | Hard cap 30 min, story ready ou pas elle attend la sem suivante |
| Daily standup synchrone obligatoire | Async Slack — économise 30 min × 4 personnes × 5 jours = 10h/sem |

---

## Suivi

- [ ] Sprint 9 : Phase 1 setup CI/CD
- [ ] Sprint 9 : 1er sprint hebdo (basculée depuis 4 sem) — itération rétro
- [ ] Sprint 10 : Phase 2 (auto-merge + Slack + rollback)
- [ ] Sprint 11 : Phase 3 (feature flags + canary)
- [ ] M3 (Q1 P/P) : revue cadence — k features livrées vs cible 5-8/sem ?

---

*Spec v1.0 — 2026-05-08 — basé sur* The Lean Startup *Ch9 Batch (Toyota Production System)*

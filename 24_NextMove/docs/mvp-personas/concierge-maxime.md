# MVP Concierge — Persona Maxime (Bâtisseur Structuré)

> **Action L4a du plan Lean Startup.** Tester la value proposition « Klaris automatise l'analyse de propriétés batch » SANS coder la feature, en faisant le travail manuellement avec Maxime.
> **Type MVP :** Concierge (Ch6 The Lean Startup) — humain fait tout, paraît automatique côté client.
> **Cible :** valider qu'il paierait 100-200 CAD/mois pour une fonction analyse batch.
> **Sprint cible :** Sprint 10 (4 semaines après Sprint 8 baseline).
> Date : 2026-05-08

---

## Persona ciblé — Maxime

D'après [personas-insights-figma.md L29-37](../personas-insights-figma.md#L29) :

> *« Le Bâtisseur Structuré » — Courtier en croissance, niche plex, assistante virtuelle à la carte — veut scaler.*
> *Top 3 douleurs : 1. Analyse manuelle une par une · 2. Pas de système de lead gen · 3. Assistante ne prend pas le verbal*
> *Baguette magique : « Sur la route, par verbal : fais-moi une offre d'achat »*
> *Push 7/10, Pull 8/10, Anxiété 2/10 — PRÊT*

---

## Value proposition à tester

> *« Klaris analyse 3 propriétés Centris à la fois, te sort un rapport comparatif (loyers/prix, rentabilité plex, secteur, risques) en 24h, pour 200 CAD/mois. »*

**Hypothèse :** Maxime paie 200 CAD/mois si rapport délivré sous 24h pour 3-5 propriétés/mois.

---

## Format Concierge MVP — 4 semaines

### Semaine 1 — Setup + onboarding Maxime

| Jour | Action | Owner |
|------|--------|-------|
| L | Appeler Maxime, pitcher l'offre concierge gratuite 4 semaines | Eliot |
| Ma | Créer Notion shared workspace « Klaris Analyse · Maxime » | Eliot |
| Me | Maxime soumet 1ère liste de 3 URLs Centris | Maxime |
| Je-V | Eliot + Joanel font analyse manuelle (loyers actuels, comparables 6 mois, calcul cash-flow plex) | Eliot + Joanel |
| V | Livraison rapport PDF dans Notion | Eliot |

### Semaine 2-4 — Itération

- **Cadence** : 1 batch de 3 propriétés/semaine sur Notion shared
- **Format** : PDF auto-généré depuis Notion + résumé SMS livré à Maxime
- **Temps cible** : ≤ 24h entre soumission et rapport
- **Coût Klaris** : ~5h Eliot + 1h Joanel par batch = ~6h × 3 = 18h sur 3 semaines

### Mesures à capturer

| Métrique | Cible | Outil |
|----------|-------|-------|
| Nb propriétés soumises / semaine | ≥ 3 | Notion log |
| Temps livraison médian | ≤ 24h | Notion timestamps |
| Maxime ouvre rapport | ≥ 90% | Notion analytics |
| NPS Maxime à fin S4 | ≥ 8 | SMS post-MVP |
| Maxime accepte de payer 200 CAD/mois (Stripe checkout test) | OUI/NON | Stripe |

---

## Critère GO (build feature)

- ✅ Maxime soumet ≥ 9 propriétés sur 4 semaines (3/sem)
- ✅ NPS Maxime ≥ 8/10
- ✅ Maxime accepte checkout Stripe 200 CAD/mois
- → Build feature `analyse-batch` Sprint 11-12 (Centris API + Claude prompt + PDF gen)

## Critère NO-GO (kill feature)

- ❌ Maxime soumet ≤ 3 propriétés sur 4 semaines (engagement faible)
- ❌ NPS Maxime ≤ 5
- ❌ Maxime refuse Stripe checkout
- → **Customer need pivot** : peut-être pas l'analyse batch qui est le pain. Re-interview Maxime.

## Critère AMBER (extension 4 sem)

- 🟡 Engagement OK mais hésite sur 200 CAD → tester 100 CAD (mais marge → 70%)
- 🟡 Analyses utiles mais 24h trop lent → mesurer si 48h acceptable

---

## Risques

| Risque | Mitigation |
|--------|------------|
| Maxime soumet 0 propriété (pas vraiment intéressé) | Re-pitcher + simplifier (1 propriété/sem au lieu de 3) |
| Eliot+Joanel surchargés (18h sur 3 sem) | Acceptable si validation = signal fort. Sinon stopper après 2 sem |
| Maxime adore mais ne paie jamais (gratuit forever) | Stripe checkout obligatoire à fin S4 — pas d'extension gratuite |
| Concurrent existe déjà (Immo Plus etc.) | Mesurer **différentiel** : qu'est-ce que Klaris fait que Immo Plus ne fait pas ? |

---

## Suivi

- [ ] Sprint 9 : appel Maxime + setup Notion workspace
- [ ] Sprint 10 (4 sem) : exécution Concierge MVP
- [ ] Sprint 10 fin : décision GO/NO-GO/AMBER
- [ ] Si GO : Sprint 11-12 build feature `analyse-batch`
- [ ] Si NO-GO : update [leap-of-faith-assumptions.md](../leap-of-faith-assumptions.md) + ré-interview Maxime

---

*Spec v1.0 — 2026-05-08 — basé sur* The Lean Startup *Ch6 Concierge MVP*

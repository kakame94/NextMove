# MVP Smoke Test — Persona JP (Stratège Franchise)

> **Action L4c du plan Lean Startup.** Tester la demande pour offre « Klaris Agence » (segment franchise/multi-courtiers) SANS construire le produit, via landing page dédiée + formulaire « demande info ».
> **Type MVP :** Smoke test (Ch4 + Ch6 The Lean Startup) — preorder/demande sans produit existant.
> **Cible :** valider que des agences cliquent + remplissent formulaire + acceptent un call.
> **Sprint cible :** Sprint 12.
> Date : 2026-05-08

---

## Persona ciblé — JP

D'après [personas-insights-figma.md L52-62](../personas-insights-figma.md#L52) :

> *« Le Stratège de Franchise » — Co-propriétaire franchise Royal LePage + courtier terrain — double casquette.*
> *99 courtiers sous sa supervision, Gatineau, plex/investisseurs.*
> *Top 3 douleurs : 1. Temps gestion interne vs terrain · 2. CRM : adoption faible (2/10 courtiers) · 3. Trop d'outils non connectés*
> *Peur profonde : « Si vous utilisez un outil et que cet outil fait des choses à votre place, vous êtes imputable » — responsabilité OACIQ.*
> *Push 4/10, Pull 3/10, Anxiété 8/10 — SCEPTIQUE — CONFORMITÉ D'ABORD*

---

## Value proposition à tester

> *« Klaris Agence — déployez Klaris à votre équipe en 1 semaine. Dashboard direction + audit log OACIQ + facturation centralisée + onboarding dédié. À partir de 200 CAD/courtier/mois (engagement 12 mois). »*

**Hypothèse :** ≥ 5% des agences qui visitent la landing demandent un call (CTR action).

---

## Setup — Smoke test 4 semaines

### Composants

| Asset | Owner | Spec |
|-------|-------|------|
| Landing page `klarisapp.ai/agence` | Walkens | Reprend DA terracotta + 1 hero + 3 colonnes value (Conformité OACIQ · Dashboard direction · Onboarding dédié) + 1 CTA « Demander une démo agence » + formulaire (nom, agence, # courtiers, email, tel) + footer Next Move Inc. |
| Formulaire backend | Dennis | Supabase table `agency_demo_requests` + Edge Function envoie email à Eliot + auto-reply au demandeur |
| Tracking | Walkens | Plausible/PostHog event `landing_view` + `form_submit` + sources (UTM utm_source) |
| Distribution | Eliot | LinkedIn DM 30 directeurs agence QC ciblés + 1 post dans groupe Facebook OACIQ + email à 5 contacts JP-style |

### Calendrier

- **Semaine 1** : build landing + formulaire + tracking (Walkens + Dennis, 3 jours)
- **Semaine 2** : campagne LinkedIn DM (30 directeurs ciblés)
- **Semaine 3** : post Facebook OACIQ + relance LinkedIn non-ouverts
- **Semaine 4** : analyse résultats + appels 1-on-1 si demandes

---

## Mesures à capturer

| Métrique | Cible | Outil |
|----------|-------|-------|
| Visiteurs uniques landing `/agence` | ≥ 100 | Plausible |
| % visiteurs qui clic CTA | ≥ 10% | PostHog |
| % visiteurs qui soumettent formulaire | ≥ 5% | Supabase count |
| % qui acceptent call après auto-reply | ≥ 50% des form_submit | Calendly bookings |
| Qualité demande (agence ≥ 5 courtiers ?) | ≥ 60% | Manuel review form |

---

## Critère GO (build feature)

- ✅ ≥ 5 demandes formulaire qualifiées (agence ≥ 5 courtiers)
- ✅ ≥ 3 calls réservés via Calendly
- ✅ Au moins 1 LOI (Letter of Intent) signée pour pilote agence Q3 2026
- → Build feature « Agence » Sprint 13-16 (dashboard direction, RBAC multi-courtiers, facturation centralisée, audit log enhanced)

## Critère NO-GO (kill feature)

- ❌ < 2 demandes formulaire sur 4 sem
- ❌ Aucune LOI signée
- ❌ Calls révèlent que JP-types ne paieront pas 200 CAD/courtier (préfèrent solution franchise existante)
- → **Customer segment pivot** : retirer offre Agence du roadmap. Focus solo only Year 1.

## Critère AMBER

- 🟡 2-4 demandes mais aucune LOI → relancer 1 mois
- 🟡 Demandes mais agence ≤ 3 courtiers → SKU « micro-agence » à 150 CAD/courtier ?

---

## Landing copy (FR — draft)

```
Hero
====
[Logo Klaris] Klaris Agence

Votre franchise, vos 99 courtiers, un seul outil.
Klaris automatise la qualification SMS, conserve l'audit OACIQ,
et vous donne le contrôle direction temps réel.

[CTA] Demander une démo agence (15 min)

Trois pillars
=============
🛡️ Conformité OACIQ
Audit log par courtier · 1-clic reprise humaine · Loi 25 native.
Vos courtiers gardent leur imputabilité, vous gardez la traçabilité.

📊 Dashboard direction
Vue 360° : leads/courtier, conversions, NPS prospects, alerts churn.
Decisioning data-driven en 5 min/jour.

🚀 Déploiement 1 semaine
Onboarding dédié · formation tes courtiers · facturation centralisée.
Pas de migration douloureuse — Klaris s'intègre à ton workflow existant.

Tarif
=====
À partir de 200 CAD/courtier/mois (engagement 12 mois) ·
Pilote 30 jours sans engagement pour les 5 premières agences.

[Formulaire]
- Nom
- Nom de l'agence
- Nombre de courtiers
- Email
- Téléphone (optionnel)
[Bouton] Réserver mon créneau

Footer
======
Une marque Next Move Inc. · klarisapp.ai · contact@klarisapp.ai
```

---

## Risques

| Risque | Mitigation |
|--------|------------|
| 0 visiteur (mauvais ciblage LinkedIn) | A/B test 2 messages DM différents · LinkedIn Ads $200 budget secours |
| Formulaire mais 0 call accepté | Auto-reply propose 3 créneaux Calendly directs (pas demande email back) |
| LOI promise mais pas signée | Pas un kill — c'est intent, le contrat suit après pilote |
| JP réel refuse même de répondre | Mitigation : Maxime (autre persona) connaît peut-être un autre franchise lead |
| Légal : promise à 200 CAD/courtier qu'on n'a pas livré | Disclaimer landing : « Pilot Q3 2026, conditions à confirmer » |

---

## Aspects éthiques

Smoke test = OK car :
- Landing dit « Q3 2026 » (pas « disponible maintenant »)
- Formulaire = demande info, pas ordre payant
- Auto-reply explique : « Nous lançons l'offre Agence au Q3. Voulez-vous être pilote ? »

---

## Suivi

- [ ] Sprint 11 : copywriting + spec landing
- [ ] Sprint 12 (4 sem) : build + campagne distribution
- [ ] Sprint 12 fin : analyse + décision GO/NO-GO
- [ ] Si GO : Sprint 13+ build Agence MVP réel
- [ ] Si NO-GO : sortir Agence du deck slide 10 (revenir Solo only)

---

*Spec v1.0 — 2026-05-08 — basé sur* The Lean Startup *Ch4 Experiment + Ch6 Smoke Test MVP*

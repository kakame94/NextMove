# MVP Wizard of Oz — Persona Charlyse (Perfectionniste Autonome)

> **Action L4b du plan Lean Startup.** Tester la promesse « sync multi-systèmes Matrix/GED/email » avec UI réelle MAIS Eliot fait le sync manuel côté serveur (Charlyse ne le sait pas).
> **Type MVP :** Wizard of Oz (Ch6 The Lean Startup) — UI/UX réelle côté client, automation **simulée** côté serveur.
> **Cible :** valider que Charlyse signe un contrat 100 CAD/mois après 30 jours d'usage perçu comme automatique.
> **Sprint cible :** Sprint 11.
> Date : 2026-05-08

---

## Persona ciblé — Charlyse

D'après [personas-insights-figma.md L39-50](../personas-insights-figma.md#L39) :

> *« La Perfectionniste Autonome » — Ancienne scientifique (PhD), courtière méthodique, 100% référrals, depuis 2018, solo complet.*
> *Top 3 douleurs : 1. Saisie redondante multi-systèmes · 2. Systèmes non fiables · 3. Pas de temps pour réseaux sociaux*
> *Vision idéale : « Lead arrive → réponse < 1h → calendrier auto → 3 options RDV. Portfolio + infos propriété AVANT la visite. Contrat pré-rempli, photos bookées devant le client. »*
> *Disposition à payer : Ne chipote PAS sur le budget SI ça règle le problème. Exige fiable, quantifiable, config une fois. Bilingue FR/EN obligatoire.*

---

## Value proposition à tester

> *« Klaris se synchronise avec ton Matrix, ton calendrier Google, ton GED Dropbox — une seule saisie et tout se propage. Bilingue FR/EN. »*

**Hypothèse :** Charlyse paie 100 CAD/mois si la sync paraît fiable, automatique, sans bug visible pendant 30 jours.

**Wizard of Oz côté serveur :** Eliot reçoit une notification quand Charlyse crée un prospect dans Klaris, et fait manuellement (en < 30 min) :
- Insertion dans son Matrix (via API Centris si possible, sinon manuel)
- Création event Google Calendar pour 1er RDV
- Création folder Dropbox `[Prospect]/[Date]`
- Email confirmation au prospect avec liens

Charlyse ne sait pas que c'est manuel. Elle voit juste « tout est fait ».

---

## Setup technique (côté Klaris)

### Phase 1 — UI seulement (Sprint 10, 5 jours)

| Composant | Spec | Owner |
|-----------|------|-------|
| Modal "Sync activée" dans Klaris iOS/web | Toggle ON par défaut, dit « Matrix · Calendar · GED Dropbox sync » | Dennis |
| Webhook interne `prospect_created` → Slack notif Eliot | Bot Slack workspace équipe | Eliot |
| Faux statut sync visible Klaris | Badge « ✅ Synced » dans 2 min après création (Eliot a 30 min mais affiché 2 min comme "magie") | Dennis |

### Phase 2 — Wizard manuel Eliot (Sprint 11, 4 semaines)

- Eliot reçoit Slack alert toutes les 10 min
- Eliot exécute checklist 5 min :
  1. Login Centris/Matrix Charlyse (creds partagés via 1Password famille)
  2. Crée prospect dans Matrix
  3. Crée event Google Cal
  4. Crée folder Dropbox + template files
  5. Marque `sync_status = done` dans Supabase
- SLA visé : ≤ 30 min réel, affiché « 2 min » dans Klaris UI

---

## Mesures à capturer

| Métrique | Cible | Outil |
|----------|-------|-------|
| Charlyse crée ≥ 5 prospects sur 4 sem | OUI | Klaris analytics |
| Charlyse n'identifie jamais que c'est manuel | OUI | Interview post-MVP |
| Bugs perçus rapportés | < 2 sur 4 sem | Sentry + Linear feedback |
| NPS Charlyse fin S4 | ≥ 8 | Klaris in-app NPS |
| Charlyse accepte 100 CAD/mois Stripe | OUI/NON | Stripe |

---

## Critère GO (build feature)

- ✅ Charlyse crée ≥ 5 prospects sur 4 sem
- ✅ Charlyse perçoit le sync comme « magique » (interview qualitatif)
- ✅ NPS ≥ 8
- ✅ Stripe checkout accepté
- → Build vraie sync Sprint 12-14 (Centris API + Google Cal API + Dropbox API + bilingual i18n complet)

## Critère NO-GO (kill feature)

- ❌ Charlyse identifie le wizard (« c'est pas vraiment automatique ») → trust broken
- ❌ NPS ≤ 5
- ❌ Charlyse refuse 100 CAD
- → **Pivot value capture** : peut-être pas la sync. Tester autre value prop (rapports PDF clients ? portfolio prêt ?).

## Critère AMBER

- 🟡 Charlyse hésite sur prix → tester 75 CAD
- 🟡 Sync utile mais 1-2 features superflues → réduire scope

---

## Risques

| Risque | Mitigation |
|--------|------------|
| Eliot rate une sync (oublie 6h) → Charlyse voit 1er bug | Slack alerts urgentes + rotation Walkens en backup weekend |
| Centris API exige authentification 2FA → wizard impossible | Demander à Charlyse code 2FA OU passer en lecture seule |
| Charlyse devine wizard via UI lente | Cadence sync à < 10 min même si wizard prend 30 min en backend (faire patienter visuellement) |
| Volume > 5 prospects/semaine → Eliot débordé | Plafonner à 5 OU recruter freelance VA pour wizard |

---

## Aspects éthiques

**Wizard of Oz = OK éthiquement** tant que :
- ✅ Le service livré est conforme à la promesse (sync fonctionne, peu importe le moyen)
- ✅ Aucune donnée n'est utilisée hors des actions promises
- ✅ Charlyse est informée **a posteriori** (après go/no-go) que les premières semaines étaient manuelles (transparence)

Si Charlyse refuse rétrospectivement → leçon Lean acceptable, pas de fraude (cf. Ch6 Ries cite Zappos qui faisait pareil avec photos chaussures + achat physique magasin).

---

## Suivi

- [ ] Sprint 10 : pitch Charlyse + setup Slack alerts + UI Klaris
- [ ] Sprint 11 (4 sem) : Wizard exécuté
- [ ] Sprint 11 fin : interview Charlyse + décision GO/NO-GO
- [ ] Si GO : Sprint 12-14 build vraie sync
- [ ] Disclosure post-MVP : transparence avec Charlyse

---

*Spec v1.0 — 2026-05-08 — basé sur* The Lean Startup *Ch6 Wizard of Oz MVP (Aardvark example)*

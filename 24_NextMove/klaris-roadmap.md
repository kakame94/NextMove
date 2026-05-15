---
type: roadmap
managed_by: prr
product: Klaris
version: 1.0.0
status: active
last_reviewed: 2026-05-15
refresh_cadence: quarterly
prioritization_method: roi-scorecard
vision: >
  For independent and small-agency real estate brokers in Canada who lose
  hours to admin and lukewarm leads, Klaris is an AI assistant that
  qualifies prospects, automates follow-ups, and prepares transactions —
  so brokers spend their day closing, not typing.
disclaimer: >
  This roadmap describes intended direction, not commitments. Themes,
  priorities and timeframes are subject to change as we learn from the
  market, pilots and regulators. Confidence percentages reflect uncertainty —
  no item ships at 100% certainty.
objectives:
  - id: OBJ-1
    name: Make Klaris indispensable to the Quebec solo broker
    key_results:
      - 200 paying solo brokers (Solo plan, 100 $ CAD/mois)
      - 90-day retention ≥ 85%
      - NPS broker > 50
  - id: OBJ-2
    name: Win the Quebec agency segment
    key_results:
      - 3 signed agency contracts (Agence plan, 200 $ CAD/courtier)
      - 1 franchise pilot live (RE/MAX QC or Royal LePage région)
      - ≥ 30% of MRR coming from the Agence tier
  - id: OBJ-3
    name: Prove the bilingual English-Canadian opportunity
    key_results:
      - 100 paying brokers outside Quebec (ON priority)
      - Toronto + Ottawa launched, OREA-compliant
      - EN-CA tone validated by 5 reference customers
  - id: OBJ-4
    name: Become a transaction copilot — not just an intake bot
    key_results:
      - Offer drafting (OACIQ) generally available in product
      - 50% of pilot brokers using the offer generator weekly
      - Notarius + DocuSign integrations live
  - id: OBJ-5
    name: Set the platform rails for Series A
    key_results:
      - Public API live with ≥ 1 partner CRM or lender
      - Marketplace MVP (qualified-prospect revenue share)
      - Series A term sheet in hand
---

# Klaris — Feuille de route 18 mois

> **Horizon :** Now / Next / Later · refresh trimestriel · dernière revue 15 mai 2026
> **Audience :** investisseurs (pré-amorçage, Seed, Series A) + clients (courtiers solo & agences)
> **Méthode :** *Product Roadmaps Relaunched* (Lombardo et al., O'Reilly 2017) — thèmes orientés résultat, pas listes de fonctionnalités datées.

## Vision

Pour les **courtiers immobiliers indépendants et de petite agence au Canada**, qui perdent des heures sur l'administratif et les leads tièdes, **Klaris** est une **adjointe IA** qui qualifie, relance et prépare les transactions — pour que le courtier passe sa journée à fermer, pas à taper.

Klaris n'est pas un CRM de plus. C'est un copilote qui parle au prospect par SMS, comprend le marché québécois (Centris, OACIQ, Loi 25), et remet au courtier une fiche prête à fermer.

## Contexte stratégique

- **Cycle de vie produit :** Growth (pilote validé, expansion commerciale en cours).
- **Marché :** ~15 000 courtiers OACIQ au QC, ~110 000 au Canada. TAM Canada ≈ 130 M$ CAD ARR à pricing actuel.
- **Pression réglementaire :** Loi 25, CASL, OACIQ — outils non-conformes écartés. Klaris fait de la conformité un *moat*.
- **Pression technologique :** coût IA divisé par ~100 en 2 ans, viable sur abonnement 100 $/mois.
- **Insight terrain :** « La différence entre moi et les courtiers qui font 40 M$/an, c'est juste la taille de leur équipe admin. » — Joanel, pilote.

## Objectifs (OKRs)

| ID | Objectif | Résultats clés |
|----|----------|----------------|
| OBJ-1 | Rendre Klaris indispensable au courtier solo QC | 200 courtiers payants · rétention 90 j ≥ 85% · NPS > 50 |
| OBJ-2 | Gagner le segment agence QC | 3 contrats agence · 1 pilote franchise · ≥ 30% MRR Agence |
| OBJ-3 | Prouver l'opportunité EN-CA | 100 courtiers hors QC · Toronto + Ottawa · OREA-conforme |
| OBJ-4 | Devenir un copilote de transaction | Rédac offres OACIQ live · 50% pilotes l'utilisent · Notarius + DocuSign |
| OBJ-5 | Poser les rails de la Series A | API partenaires live · marketplace MVP · term sheet Series A |

---

## Thèmes — Now / Next / Later

Chaque thème est un *résultat* attendu pour un *acteur*, pas une fonctionnalité. Les dates calendaires sont volontairement absentes : le rythme dépend de la pression marché, des résultats de pilotes et des fenêtres réglementaires.

### Now

| Thème | Besoin client | Objectif | Confiance |
|-------|---------------|----------|-----------|
| [Faire que les pilotes convertissent leurs leads sans admin manuel](themes/now-pilots-convert-without-admin.md) | Le courtier perd 30–60 min par offre et ne répond pas en moins de 24 h aux leads chauds. | OBJ-1 | 80% |
| [Faire que l'OACIQ reconnaisse Klaris comme conforme par défaut](themes/now-oaciq-compliance-recognition.md) | Les courtiers craignent d'être rappelés à l'ordre par leur agence d'agrément s'ils utilisent un outil non revu. | OBJ-1 | 75% |
| [Faire que les pilotes restent payants au-delà de 90 jours](themes/now-pilot-retention-90d.md) | Les courtiers abandonnent les outils admin au bout de 4–6 semaines si l'effet n'est pas tangible chaque jour. | OBJ-1 | 70% |
| [Faire que les investisseurs pré-amorçage voient un signal commercial clair](themes/now-pre-seed-traction-signal.md) | Les anges québécois investissent sur la traction démontrable, pas sur la promesse produit. | OBJ-1, OBJ-2 | 65% |

### Next

| Thème | Besoin client | Objectif | Confiance |
|-------|---------------|----------|-----------|
| [Faire que les agences pilotent une équipe de courtiers depuis un seul tableau de bord](themes/next-agency-direction-dashboard.md) | Les directions d'agence n'ont aucune visibilité temps réel sur la performance lead-to-close de leurs courtiers. | OBJ-2 | 60% |
| [Faire que le courtier atteigne les fiches Centris sans re-saisie](themes/next-centris-no-reentry.md) | Le courtier ressaisit la même fiche dans 3 outils (Centris, CRM franchise, notes perso). | OBJ-1, OBJ-4 | 55% |
| [Faire que l'offre passe du chat à la signature électronique en un seul flux](themes/next-chat-to-esign-offer-flow.md) | Le courtier reçoit l'accord oral et perd 30–60 min à mettre l'offre en forme + chasser les signatures. | OBJ-4 | 55% |
| [Faire que les investisseurs Seed voient une thèse Canada défendable](themes/next-seed-canada-thesis.md) | Les VCs canadiens veulent voir 25–50 k$ MRR + une expansion claire hors QC avant la Series Seed. | OBJ-2, OBJ-3 | 50% |

### Later

| Thème | Besoin client | Objectif | Confiance |
|-------|---------------|----------|-----------|
| [Faire que les courtiers anglo-canadiens sentent que Klaris parle leur marché](themes/later-en-ca-market-fit.md) | Un produit "francophone traduit" est rejeté par les courtiers ON/BC — vocabulaire, ton, conformité TREB/OREA diffèrent. | OBJ-3 | 40% |
| [Faire que le courtier garde la relation client après le closing](themes/later-post-closing-relationship.md) | Le courtier perd la moitié de ses référencements faute de touchpoints post-closing systématiques. | OBJ-4 | 35% |
| [Faire que les partenaires (CRMs, prêteurs) intègrent Klaris dans leur flux](themes/later-partner-integrations-api.md) | Les franchises veulent du levier IA sans changer leur stack CRM ; les prêteurs veulent du flow qualifié. | OBJ-5 | 30% |
| [Faire que le courtier monétise ses leads froids via un marché de prospects qualifiés](themes/later-qualified-prospect-marketplace.md) | 60–70% des leads d'un courtier ne convertiront jamais avec lui, mais ont de la valeur pour un autre courtier. | OBJ-5 | 25% |

---

## Indications de phasage — pour cadrage investisseurs uniquement

> **Avertissement :** ce phasage est une *intention de séquencement*, pas un engagement de livraison. Les dates sont indicatives, alignées sur l'horizon de levée — pas sur des engagements clients.

| Horizon (~) | Phase | Levée associée | Signaux à atteindre |
|------------|-------|----------------|---------------------|
| Trimestre courant | Now | Pré-amorçage 250 k$ CAD | OBJ-1 partiel : 10 courtiers payants · OACIQ revue · NPS pilote > 50 |
| ~T+2 / T+3 | Next | Seed 1,5 M$ CAD | OBJ-1 atteint · OBJ-2 démarré · 1ᵉʳ contrat agence |
| ~T+4 / T+5 | Later (entrée) | — | OBJ-2 atteint · OBJ-3 démarré · 500 courtiers · 60 k$ MRR |
| ~T+6 / T+7 | Later (fin) | Prép. Series A 6–8 M$ | OBJ-4 atteint · OBJ-5 démarré · 1 000+ courtiers · ARR ~1,5 M$ |

## Méthode de priorisation

ROI Scorecard — `priority_score = (value / effort) × confidence`. Chaque thème en Now/Next a un score documenté dans `artifacts/scorecard-YYYY-MM-DD.md`. Les thèmes Later sont gardés sans score tant que l'effort n'est pas vetté ingénierie.

## Cadence de revue

- **Hebdomadaire :** revue des thèmes Now (équipe produit + Joanel pilote).
- **Mensuelle :** revue scorecard avec co-fondateurs.
- **Trimestrielle :** revue complète de la feuille de route (Now → Next, Next → Now, suppression de thèmes orphelins).
- **Pré-board / pré-pitch :** audit via `roadmap-reviewer` (prr) avant tout envoi externe.

## Risques & mitigations

- **Adoption courtier** → onboarding humain 30 j, garantie remboursement 60 j, animation par Joanel & pilotes.
- **Conformité régulateur** → revue OACIQ formelle dès Now, comité conformité interne, audit Loi 25 trimestriel.
- **Concurrence US (Lofty, Sierra Interactive)** → moat = ton QC + intégrations locales (Centris, Notarius) + JTBD terrain.
- **Capacité IA** → multi-fournisseur (Anthropic principal + Mistral repli), abstraction couche modèle.
- **Dépendance fondateur-pilote (Joanel)** → diversification pilotes T1 (Maxime, Walkens, Seydou), désindexer les références.

## Change log

- 2026-05-15 — Roadmap reformulée selon la méthodologie *Product Roadmaps Relaunched* (thèmes Now/Next/Later). Renommage de marque Cléa → Klaris.

## Disclaimer

This roadmap describes intended direction, not commitments. Priorities, themes and timeframes are subject to change as we learn. Confidence percentages reflect uncertainty — no item ships at 100% certainty.

---

**Contact :** contact@nextmove.app · klaris.app · Klaris — une marque Next Move · Confidentiel

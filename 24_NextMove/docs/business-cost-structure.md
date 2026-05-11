# Klaris — Structure de coûts (Business Model Canvas #9)

> **Brique 9 du Business Model Canvas.** Source de vérité chiffrée pour les coûts d'exploitation Klaris (MVP + projection 12 mois).
> Format **Figma-ready** : tableaux, copy FR/EN et tokens couleur extractibles tels quels par l'équipe design pour générer la frame deck/social.
> Dernière mise à jour : 2026-05-08
> Méthodologie source : article *Le Coin des Entrepreneurs* — distinction Coûts fixes / Coûts variables + seuil de rentabilité.
> Documents liés : [business-constraints-checklist.md](./business-constraints-checklist.md) · [pitch-deck/content.md](../clea-brand/pitch-deck/content.md) · [personas-insights-figma.md](./personas-insights-figma.md)

---

## Sommaire

1. [Résumé exécutif](#1--résumé-exécutif)
2. [Méthodologie](#2--méthodologie-selon-larticle-bmc)
3. [Coûts fixes mensuels](#3--coûts-fixes-mensuels-cad)
4. [Coûts variables par courtier](#4--coûts-variables-par-courtier-par-mois-cad)
5. [Projection 12 mois](#5--projection-12-mois)
6. [Seuil de rentabilité](#6--seuil-de-rentabilité)
7. [Logique BMC : cost-driven vs value-driven](#7--logique-bmc--cost-driven-vs-value-driven)
8. [Leviers d'amélioration](#8--3-leviers-damélioration-prioritaires)
9. [Risques & angles morts](#9--risques--angles-morts)
10. [Spec Figma-ready](#10--spec-figma-ready)
11. [Hors scope](#11--hors-scope)

---

## 1 — Résumé exécutif

> **Klaris est cost-driven en phase MVP (~260 CAD/mois fixes hors salaires) et bascule value-driven dès la phase commerciale (M3+) avec une marge brute par courtier supérieure à 90%. Seuil de rentabilité atteint à 8 courtiers solo payants — projeté entre M5 et M6.**

| Phase | Coûts fixes mensuels | Marge brute/courtier | Seuil rentabilité (courtiers solo) |
|-------|----------------------|----------------------|-------------------------------------|
| MVP (M0-M3) | 260 CAD | 91.5 % | 3 |
| Commerciale (M3-M6) | 535 CAD | 91.5 % | 6 |
| Scale infra (M6-M12) | 735 CAD | 91.5 % | 8 |
| Scale + 1 fondateur salarié | 3 735 CAD | 91.5 % | 41 |
| Scale + équipe 4 fondateurs salariés | 50 735 CAD | 91.5 % | 555 |

---

## 2 — Méthodologie (selon l'article BMC)

**Définition.** La structure de coûts représente l'ensemble des dépenses générées par l'exploitation de Klaris. Elle se découpe en deux familles :

| Famille | Caractéristique | Exemples Klaris |
|---------|-----------------|-----------------|
| **Coûts fixes** | Stables peu importe le nombre de courtiers actifs | Hébergement Supabase Pro, Sentry, comptable, assurance E&O, salaires |
| **Coûts variables** | Varient avec le volume d'activité (nombre de courtiers, SMS, conversations IA) | Twilio SMS, Anthropic API, Stripe, numéros Twilio |

**Formules clés (article).**
- Taux de marge = `(CA − Coûts variables) / CA`
- Seuil de rentabilité = `Coûts fixes / Taux de marge`

**3 leviers d'amélioration de rentabilité.**
1. Augmenter les revenus (prix ou volume).
2. Limiter les coûts fixes (variabilisation, plafonnement).
3. Améliorer la marge (chaîne de valeur, optimisation des postes sans valeur client).

---

## 3 — Coûts fixes mensuels (CAD)

| # | Poste | MVP (M0-M3) | Commerciale (M3-M6) | Scale (M6-M12) | Notes |
|---|-------|-------------|----------------------|----------------|-------|
| F1 | Hébergement Supabase | 0 *(free tier)* | 35 *(Pro)* | 35 *(Pro)* | Free tier suffit jusqu'à ~3 courtiers |
| F2 | Vercel (klaris_web) | 0 *(Hobby)* | 28 *(Pro)* | 28 *(Pro)* | Hobby OK MVP, upgrade dès facturation client |
| F3 | n8n self-hosted (VPS) | 12 | 12 | 25 *(upgrade RAM)* | Hetzner/DigitalOcean — orchestration workflows |
| F4 | Apple Developer Program | 12 | 12 | 12 | 99 USD/an amorti mensuel |
| F5 | Resend (email transactionnel) | 0 *(free 3k/mois)* | 28 *(Pro)* | 28 *(Pro)* | Briefing 7h30, free tier OK jusqu'à 100 courtiers |
| F6 | Sentry (observabilité) | 0 *(free dev)* | 35 *(Team)* | 35 *(Team)* | Ajouté Sprint 6 |
| F7 | Outils dev (GitHub, Linear, Figma) | 60 | 80 | 120 | GitHub Pro + Linear Standard + Figma Pro |
| F8 | Domaine + Google Workspace | 25 | 25 | 50 | nextmove.app + clea.app + 2-4 boîtes |
| F9 | Comptabilité QC (freelance) | 100 | 150 | 250 | TPS/TVQ + bilan |
| F10 | Assurance E&O / RC pro | 0 | 80 | 100 | Souscription avant facturation client |
| F11 | Frais juridiques amortis | 50 | 50 | 50 | Loi 25, CGU, CGV — ~600 CAD one-shot amorti 12 mois |
| F12 | **Salaires / dividendes co-fondateurs** | 0 | 0 *ou* 3 000 *(1 dédié)* | 6 000 – 12 000 *(équipe)* | **Levier #1 du seuil** |
| **Total hors salaires** |   | **~260** | **~535** | **~735** |   |
| **Total + 1 fondateur** |   | n/a | **~3 535** | **~3 735** |   |

**Notes.**
- L'estimation MVP (260 CAD) est plus élevée que les 35-50 CAD validés Sprint 1 ([business-constraints-checklist.md:64](./business-constraints-checklist.md#L64)) parce qu'elle intègre désormais la comptabilité, les outils dev et le domaine — non comptabilisés à l'origine. La fourchette Twilio + Anthropic + n8n seule reste cohérente à 25-30 CAD.
- L'assurance E&O ne s'active qu'à partir de la 1re facturation client (M3) — exigence pré-go-live.
- Les salaires fondateurs sont le levier #1 du seuil de rentabilité : tant qu'ils sont à 0, Klaris est rentable dès 8 courtiers.

---

## 4 — Coûts variables (par courtier, par mois, CAD)

| # | Poste | Coût unitaire | Volume estimé / courtier | Coût mensuel / courtier | Source |
|---|-------|---------------|--------------------------|--------------------------|--------|
| V1 | Twilio numéro local CA | 1.40 / mois | 1 numéro dédié | 1.40 | Tarifs Twilio 2026 |
| V2 | Twilio SMS in/out | 0.015 / SMS | 20 prospects × 8 messages | 2.40 | [business-constraints-checklist.md:66](./business-constraints-checklist.md#L66) |
| V3 | Anthropic Claude (Haiku + Sonnet) | ~0.05 / conversation | 20 conversations / mois | 1.00 | Logs prompts Sprint 6 |
| V4 | Resend emails (briefing 7h30) | ~0 *(free 3k)* | 30 emails / mois | 0.00 | Free tier jusqu'à 100 courtiers |
| V5 | Supabase usage (storage + bandwidth) | prorata | voice memos + DB | 0.50 | Estimation |
| V6 | Stripe (encaissement) | 2.9 % + 0.30 CAD | 1 paiement de 100 CAD | 3.20 | Stripe Canada 2026 |
| V7 | Support N1 (CSM externalisé, optionnel M9+) | — | 0.5 h / courtier / mois | 5.00 | À activer M9 si churn > 5 % |
| **Total / courtier solo (sans CSM)** |   |   |   | **~8.50** |   |
| **Total / courtier solo (avec CSM)** |   |   |   | **~13.50** |   |

**Marges brutes.**

| Plan | Prix | Coût variable | Marge brute | Taux de marge |
|------|------|---------------|-------------|---------------|
| Solo (deck slide 10) | 100 CAD | 8.50 CAD | **91.50 CAD** | **91.5 %** |
| Agence (deck slide 10) | 200 CAD / courtier | 8.50 CAD | **191.50 CAD** | **95.7 %** |

---

## 5 — Projection 12 mois

**Hypothèses de croissance.**
- Acquisition : 3-5 nouveaux courtiers/mois via referrals Joanel (deck slide 09 — 100% référrals).
- Churn : 5 %/mois (à mesurer dès M6, hypothèse à valider).
- Mix solo/agence à M12 : 70/30 (cohérent avec personas Joanel/Charlyse vs Maxime/JP).
- Pas de CSM avant M9 (V7 désactivé).
- Salaires fondateurs : 0 sur les 12 premiers mois (capital temps).

| Mois | Pilotes gratuits | Solo (100 CAD) | Agence (200 CAD/courtier) | MRR (CAD) | Coûts fixes | Coûts variables | Résultat |
|------|------------------|-----------------|---------------------------|-----------|-------------|-----------------|----------|
| M0-M3 | 3 | 0 | 0 | **0** | 260 | 25 | **−285** *(investissement MVP)* |
| M3 | 3 | 5 | 0 | **500** | 535 | 68 | **−103** |
| M6 | 2 | 15 | 4 | **2 300** | 735 | 178 | **+1 387** |
| M9 | 1 | 30 | 10 | **5 000** | 735 | 348 | **+3 917** |
| M12 | 0 | 40 | 15 | **7 000** | 735 | 467 | **+5 798** |

**Cumulé 12 mois** : ~+24 000 CAD de cash net (hors salaires fondateurs), ARR M12 = 84 000 CAD. Marge de manœuvre pour activer 1 salaire fondateur dès M10-M11 sans casser le seuil — à condition de tenir la trajectoire d'acquisition.

---

## 6 — Seuil de rentabilité

Application directe de la formule article : `Seuil = Coûts fixes / Taux de marge`.

> **⚠️ Distinction Cost-to-Build vs Cost-to-Run** (challenge BMC, cf. *The Professional Product Owner* Ch3 Product Cost Ratio).
> Tous les scénarios « sans salaires » ci-dessous comptent uniquement le **Cost-to-Run** (TCO infra + outils + assurance). Ils **n'intègrent pas** le **Cost-to-Build** (capital temps fondateurs), qui est un *leading indicator* essentiel pour le ROI réel.

### 6.1 Coût Sprint (Cost-to-Build) — capital temps fondateurs

| Mesure | Valeur |
|--------|--------|
| Fondateurs actifs | 4 (Dennis, Eliot, Walkens, Seydou) |
| Heures moyennes / fondateur / mois | ~80 h |
| Taux horaire de référence (marché QC senior IT) | 75 CAD/h |
| **Coût Sprint mensuel équivalent** | **4 × 80 × 75 = 24 000 CAD** |
| Coût Sprint annuel équivalent | ~288 000 CAD |

À ce stade c'est un **coût opportuniste** (capital temps), pas une sortie de cash. Il devient une sortie de cash à partir du moment où un fondateur passe à plein temps salarié.

### 6.2 Seuil de rentabilité — vue Cost-to-Run uniquement

| Scénario | Coûts fixes | Taux marge | CA seuil | Courtiers solo équivalents |
|----------|-------------|------------|----------|-----------------------------|
| MVP (Cost-to-Run seul) | 260 CAD | 91.5 % | **284 CAD** | **3** |
| Commerciale (Cost-to-Run seul) | 535 CAD | 91.5 % | **585 CAD** | **6** |
| Scale infra (Cost-to-Run seul) | 735 CAD | 91.5 % | **803 CAD** | **8** |

### 6.3 Seuil de rentabilité — vue Cost-to-Run + Cost-to-Build (réalité économique)

| Scénario | Coûts fixes (Run + Build) | Taux marge | CA seuil | Courtiers solo équivalents |
|----------|----------------------------|------------|----------|-----------------------------|
| MVP + capital temps 4 fondateurs | 260 + 24 000 = **24 260 CAD** | 91.5 % | **26 514 CAD** | **265** |
| Scale infra + capital temps 4 fondateurs | 735 + 24 000 = **24 735 CAD** | 91.5 % | **27 033 CAD** | **270** |
| Scale + 1 fondateur **salarié** réellement (3 000 CAD cash) + 3 fondateurs en capital temps (18 000 CAD) | 735 + 3 000 + 18 000 = **21 735 CAD** | 91.5 % | **23 754 CAD** | **238** |
| Scale + équipe 4 fondateurs **salariés cash** (50 000 CAD) | 50 735 CAD | 91.5 % | **55 448 CAD** | **555** |

### 6.4 Lecture

- **Vue Cost-to-Run** : 8 courtiers couvrent l'infra. Atteignable M5-M6.
- **Vue Cost-to-Run + Cost-to-Build** : ~270 courtiers solo nécessaires pour réellement *valoriser* le capital temps des 4 fondateurs au taux marché. Objectif Year 1.5-2.
- L'écart 8 → 270 est la **dette de valeur** que les fondateurs portent en investissement personnel. À expliciter avant toute discussion de fundraising ou d'embauche externe.
- **Conséquence stratégique** : tant que le seuil 270 n'est pas atteint, recruter à l'externe (sortie cash supplémentaire) augmente le seuil au-delà de la trajectoire prévue. Préférer des freelances ponctuels ou différer l'embauche.

---

## 7 — Logique BMC : cost-driven vs value-driven

Le BMC distingue deux postures stratégiques sur la structure de coûts :

| Posture | Quand l'adopter | Ce que Klaris fait |
|---------|------------------|--------------------|
| **Cost-driven** | MVP, pré-PMF, runway limité | Supabase free, Vercel Hobby, n8n self-hosted, Resend free, 0 salaire — minimiser le burn pendant la découverte |
| **Value-driven** | Phase commerciale, SLA promis, marque | Sentry Team, Resend Pro, assurance E&O, comptable dédié — la qualité perçue justifie le coût (SLA 99.9 % promis dans Agence) |

**Bascule.** À M3 (1re facturation client), Klaris quitte le mode cost-driven sur les postes liés au client (observabilité, conformité, support) tout en restant cost-driven sur le hors-produit (salaires, marketing payant, locaux).

---

## 8 — 3 leviers d'amélioration prioritaires

| # | Levier | Mécanique | Gain estimé |
|---|--------|-----------|-------------|
| 1 | **Mix Haiku/Sonnet sur Claude** | Haiku par défaut (10× moins cher), Sonnet uniquement sur résumés finaux | −0.5 CAD/courtier/mois → +0.5 % marge |
| 2 | **Négocier volumes Twilio** | Au-delà de 50 k SMS/mois, tarif descend à 0.0075 USD/SMS | −1 CAD/courtier/mois à partir de M9 |
| 3 | **Plafonner les coûts fixes pré-PMF** | Pas de salaire fondateur avant 50 courtiers payants | Repousse seuil critique de 41 à 8 courtiers pendant 6 mois |

---

## 9 — Risques & angles morts

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Sender score Twilio < 97 → block | Service interrompu | Alerte budget V4 + monitoring sender score (S1-S5 [business-constraints-checklist.md:73-80](./business-constraints-checklist.md#L73)) |
| Hausse tarif Anthropic API | +0.05 CAD/courtier/mois (mineur) | Mix Haiku, fallback OpenAI/Mistral envisageable |
| Loi 25 audit → coût conformité non prévu | +5 000 à 15 000 CAD one-shot | Doubler la provision juridique F11 si > 50 employés clients (déclaration CAI) |
| Annulation agence JP (99 courtiers) | −20 % MRR potentiel agence | Diversifier l'acquisition au-delà du réseau Joanel dès M6 |
| Stripe Canada gèle le compte (secteur immobilier sensible) | Encaissement bloqué | Backup Moneris ou Square pré-validé |
| Churn solo > 10 %/mois | MRR plafonné, ROI marketing négatif | Activer V7 (CSM N1) dès le 1er signal, pas attendre M9 |

---

## 10 — Spec Figma-ready

Frame **créée** dans Figma — convention identique à [personas-insights-figma.md](./personas-insights-figma.md) et [templates-sms-figma-extraits.md](./templates-sms-figma-extraits.md).

**Fichier Figma :** [Klaris — Cost Structure (BMC #9)](https://www.figma.com/design/YjYvF8AMmye1blG71bgDRP)

**Frames créées.**

| Page Figma | Frame | Node ID | Dimensions |
|------------|-------|---------|------------|
| Deck slides (1920×1080) | Klaris — Cost Structure FR | `1:2` | 1920×1080 |
| Deck slides (1920×1080) | Klaris — Cost Structure EN | `1:18` | 1920×1080 |
| Social square (1080×1080) | Klaris — Cost Structure FR | *(page 2 — voir Figma)* | 1080×1080 |
| Social square (1080×1080) | Klaris — Cost Structure EN | *(page 2 — voir Figma)* | 1080×1080 |
| **V2 — EBM Challenge** | **Klaris — Cost Structure V2 FR** | **`4:3`** | 1920×1080 |
| **V2 — EBM Challenge** | **Klaris — Cost Structure V2 EN** | **`4:22`** | 1920×1080 |

**Note V2.** Slides V2 ajoutées suite au challenge BMC (cf. [business-canvas-challenge.md](./business-canvas-challenge.md) §3.9 + Action 4). Elles introduisent la distinction **Cost-to-Run vs Cost-to-Build** et le seuil réel de 270 courtiers (vs 8 affiché en V1). À utiliser pour audience investisseur ou board interne, pas pour pitch courtier.

**Tokens couleur (terracotta site, cohérent commit `072c0a1`).**

| Rôle | Token | Hex |
|------|-------|-----|
| Background | `bg/cream` | `#FAF7F2` |
| Accent terracotta | `accent/terracotta` | `#C45A3A` |
| Texte principal | `text/primary` | `#1F1B16` |
| Texte secondaire | `text/secondary` | `#5C5046` |
| Surface tableau | `surface/card` | `#FFFFFF` |
| Border tableau | `border/soft` | `#E8DFD3` |

**Typographie.**
- Famille : Geist (système design existant — cf. architecture.md)
- H1 : Geist Bold 56pt
- H2 : Geist SemiBold 36pt
- Body : Geist Regular 18pt
- Caption : Geist Medium 14pt

**Layout proposé (1920×1080).**

```
┌─────────────────────────────────────────────────────────────────┐
│ Eyebrow: STRUCTURE DE COÛTS                                     │ ← terracotta uppercase
│ H2: Marge brute > 90 %. Rentable dès 8 courtiers.               │ ← text/primary
├─────────────────────────────┬───────────────────────────────────┤
│ COÛTS FIXES                 │ COÛTS VARIABLES                   │
│ ~735 CAD/mois               │ ~8.50 CAD/courtier                │
│                             │                                   │
│ • Supabase Pro              │ • Twilio numéro 1.40              │
│ • Vercel Pro                │ • Twilio SMS 2.40                 │
│ • n8n VPS                   │ • Claude API 1.00                 │
│ • Sentry Team               │ • Stripe 3.20                     │
│ • Comptable QC              │ • Supabase usage 0.50             │
│ • Assurance E&O             │                                   │
│ • Outils dev                │                                   │
├─────────────────────────────┴───────────────────────────────────┤
│ Bandeau seuil : Rentable dès 8 courtiers solo (M5-M6)          │ ← terracotta bg
│ Scalable jusqu'à 555 courtiers avec équipe complète             │ ← cream text
└─────────────────────────────────────────────────────────────────┘
```

**Strings à extraire (FR + EN).** Voir slide 10b dans [pitch-deck/content.md](../clea-brand/pitch-deck/content.md) — copy validée et prête.

---

## 11 — Hors scope

- Modélisation Excel (.xlsx) avec hypothèses paramétrables — choix utilisateur = format Figma.
- Plan de financement / runway / fundraising — la structure de coûts est une brique du BMC, pas un business plan.
- Portage HTML deck-fr.html / deck-en.html — convention équipe = manuel après validation copy ([content.md:4](../clea-brand/pitch-deck/content.md#L4)).
- Provisions fiscales (TPS/TVQ collectées vs payées) — bilan comptable, hors BMC.
- Coûts d'acquisition (CAC) — relèvent de la brique 5 (Customer Relationships) et de la brique 4 (Channels), à traiter dans un livrable dédié.

---

## Suivi

- [ ] Validation chiffres avec Dennis (infra) + comptable (postes F8-F11)
- [x] ~~Création frame Figma `Klaris — Cost Structure (BMC #9)`~~ → fait via MCP, fichier [YjYvF8AMmye1blG71bgDRP](https://www.figma.com/design/YjYvF8AMmye1blG71bgDRP)
- [ ] Revue design/typographie Figma (font Inter par défaut → swap Geist si dispo dans la lib design)
- [ ] Portage slide 10b dans deck-fr.html et deck-en.html (PR séparé)
- [ ] Itération M3 : remplacer hypothèses par données réelles Sprint 1 pilotes
- [ ] Itération M6 : intégrer churn réel et ajuster scénarios

*Document v1.0 — 2026-05-08*

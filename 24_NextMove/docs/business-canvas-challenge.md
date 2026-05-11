# Klaris — Challenge du Business Model Canvas

> **But.** Stress-tester le BMC de Klaris à la lumière du livre *The Professional Product Owner — Leveraging Scrum as a Competitive Advantage* (Don McGreal & Ralph Jocham, Addison-Wesley / Scrum.org, 2018).
> **Méthodologie source.** 3 Vs (Vision, Value, Validation) · EBM (Evidence-Based Management) · Cynefin · Stacey Matrix · Risk Top-7.
> **Documents liés.** [business-cost-structure.md](./business-cost-structure.md) · [pitch-deck/content.md](../clea-brand/pitch-deck/content.md) · [personas-insights-figma.md](./personas-insights-figma.md) · [business-constraints-checklist.md](./business-constraints-checklist.md)
> Date : 2026-05-08

## Livrables Figma — file base unifiée DA Terracotta

**Fichier Figma source (file base NextMove/JTBD) :** [JXlxEfExXxH1sVpXFnwFKH](https://www.figma.com/design/JXlxEfExXxH1sVpXFnwFKH)

| Page Figma | Frame | Node ID | Usage |
|------------|-------|---------|-------|
| Business Model Canvas v1.0 (DA Dark — legacy) | BMC Avril 2026 dark mode | `77:3` | Archive — ne plus utiliser |
| **BMC v1.1 — DA Terracotta** | Business Model Canvas — Klaris | `212:3` | **Source de vérité BMC** |
| Cost Structure V1 (Deck Slide 10b) | Cost Structure V1 FR / EN | (page 212:162) | Pitch courtier |
| Cost Structure V2 (EBM Challenge) | Cost Structure V2 FR / EN | (page 212:195) | Pitch investisseur / board |
| **BMC Challenge — Scoreboard** | Scoreboard 9 cases + 3 Vs + Cynefin + 7 actions | `214:2` | **Synthèse challenge** |

**Tokens DA unifiés (cohérent site Klaris commit `072c0a1`) :**
- Background : `#FAF7F2` (cream)
- Accent terracotta : `#C45A3A`
- Texte primaire : `#1F1B16`
- Surface card : `#FFFFFF` border `#E8DFD3`
- Score : vert `#4A9D5C` (≥7) · ambre `#D9A04D` (4-6) · rouge `#C43A3A` (0-3)
- Typo : Inter (fallback Geist non garanti dans lib Figma user)

---

## Sommaire

1. [TL;DR — Verdict en 5 lignes](#1--tldr--verdict-en-5-lignes)
2. [Cadre théorique appliqué](#2--cadre-théorique-appliqué)
3. [Challenge brique par brique (les 9 cases du BMC)](#3--challenge-brique-par-brique)
4. [Les 3 Vs appliqués à Klaris](#4--les-3-vs-appliqués-à-klaris)
5. [EBM — Klaris a-t-il les bons KVMs ?](#5--ebm--klaris-a-t-il-les-bons-kvms-)
6. [Cynefin & Stacey — On est bien dans le Complex](#6--cynefin--stacey--on-est-bien-dans-le-complex)
7. [Top-7 risques projet (Ch5 Table 5-3)](#7--top-7-risques-projet-appliqués)
8. [Strategic Alignment Index — Quelles features couper ?](#8--strategic-alignment-index--quelles-features-couper-)
9. [Plan d'action — 7 corrections prioritaires](#9--plan-daction--7-corrections-prioritaires)

---

## 1 — TL;DR — Verdict en 5 lignes

> **Klaris a un excellent niveau Validation (Joanel pilote réel, JTBD 4 personas) et une Value côté producteur claire (cost structure 91.5 % marge brute). MAIS la Vision est éparpillée (pas d'Elevator Pitch unifié), la Value côté client n'a aucune mesure (NPS absent), et le BMC actuel ignore 4 angles critiques selon McGreal/Jocham : Negative Value, Time-to-Market mesuré, Ability-to-Innovate, et risques OACIQ/Loi 25 capturés comme dette produit.**

| Score brique BMC | État actuel | Selon livre |
|------------------|-------------|-------------|
| Vision | 5/10 | Doit être *Focused, Practical, Emotional, Pervasive* (Ch2) |
| Value côté producteur | 9/10 | Cost structure documentée (cf. doc dédié) |
| Value côté client | 3/10 | **Pas de NPS, pas d'Employee Sat, pas d'Innovation Rate** |
| Validation | 7/10 | Pilote Joanel ✅, mais 3/4 personas non testées en prod |
| Adéquation Cynefin | OK | Reconnaissance implicite du Complex (n8n, IA, marché QC) |

---

## 2 — Cadre théorique appliqué

D'après *The Professional Product Owner* :

| Concept livre | Source | Application Klaris |
|---------------|--------|---------------------|
| **3 Vs** : Vision · Value · Validation | Ch1 | Boussole stratégique du Product Owner |
| **BMC = outil d'exploration** (pas de vision) | Ch2 (p. 36) | Notre BMC remplit cette fonction, mais nous avons sauté l'étape Vision unifiée |
| **Vision = Focused + Practical + Emotional + Pervasive** | Ch2 | Tagline « Elle qualifie. Toi tu vends. » est Focused mais peu Emotional |
| **Elevator Pitch** (Geoffrey Moore) | Ch2 | Pas formulé dans nos docs |
| **Value Defined : Happiness (clients) ≠ Money (org)** | Ch3 | Notre BMC mélange les deux dans Value Propositions |
| **EBM 3 KVAs** : Current Value · Time-to-Market · Ability-to-Innovate | Ch3 | Klaris ne mesure aucun KVM Customer Sat / Innovation Rate / Cycle Time |
| **Negative Value** (Visible / Invisible) | Ch3 | Risque IA bot SMS qui shocke un prospect = invisible value destruction |
| **Cynefin / Stacey Matrix** | Ch5 | Klaris est en **Complex** sur Requirements (4 personas divergents) |
| **Essential vs Accidental complexity** | Ch5 | n8n + Anthropic + Twilio + Flutter + Next.js = forte accidental complexity |
| **Top-7 risques projet** | Ch5 Table 5-3 | #1 Misunderstanding requirements · #3 Lack of user involvement |
| **Strategic Alignment Index** (Business × IT × TCO) | Ch2 | Apple Watch / PDF reports candidats à plotter |

---

## 3 — Challenge brique par brique

### 3.1 Customer Segments

**Actuel.** 4 personas JTBD : Joanel (solo ambitieux), Maxime (bâtisseur structuré), Charlyse (perfectionniste autonome), JP (stratège franchise).

**Challenge livre.**
> *« Focus involves much more than keeping your vision statement small and concise. Your vision needs to make it crystal clear who the target customer segment is. »* (Ch2, Focused)

- ⚠️ **Pas de segment prioritaire désigné.** Tarification deck (100 CAD solo / 200 CAD agence) traite Joanel et JP comme égaux, alors que JP « sceptique-conformité d'abord » a des contraintes 10× supérieures (OACIQ, audit, 99 courtiers à onboarder).
- ⚠️ Le « Ceralios vs Crunchy Flakes » du livre (Ch2) montre qu'**un produit ne peut pas adresser tous les segments**. Klaris doit choisir : on parle à Joanel (push 10/10, prêt) ou à JP (anxiété 8/10, demande preuves) ?

**Recommandation.**
1. Désigner Joanel comme **segment #1** explicitement (deck slide 02).
2. Déclasser Maxime/Charlyse/JP en segments expansion phase 2 (M9+).
3. Couper la promesse « Agence 99.9 % SLA » du deck slide 10 tant qu'on n'a pas signé un agence pilote.

---

### 3.2 Value Propositions

**Actuel.** Deck slide 04 : « Klaris qualifie tes prospects par SMS pendant que tu vends. Un seul outil. Un seul abonnement. Conformité OACIQ par défaut. Bilingue FR/EN. »

**Challenge livre.**
> *« Both [happiness and money] are relevant and connected. You cannot make money without having a customer who appreciates your product or service. »* (Ch3, Value Defined)
> *« Producer benefit » (revenue) vs « Customer happiness » (value props)*

- ⚠️ Notre value prop mélange features (« 1 outil, 1 abonnement ») et bénéfices (« qualifie pendant que tu vends »).
- ⚠️ **Test Practical/Emotional 2×2** (Ch2, Fig. 2-9) :
  - « Elle qualifie. Toi, tu vends. » → Practical: HIGH, Emotional: MEDIUM (sous-entend libération mais ne le dit pas).
  - À tester comme reformulation : *« Tes soirées en famille pendant que Klaris fait l'admin. »* → Practical: HIGH, Emotional: HIGH (cf. exemple CPA workflow p. 47 : « speeds up the mundane tasks at work so that you can spend more time at home with family »).

**Recommandation.**
- Réécrire value prop principale en mode Elevator Pitch (Ch2, Fig. 2-7) :
  ```
  POUR    les courtiers immobiliers solo du Québec
  QUI     perdent 2-3h/jour à qualifier des prospects par SMS
  KLARIS    EST UNE adjointe IA bilingue FR/EN, conforme OACIQ
  QUI     qualifie tes prospects par SMS, 24/7, pendant que tu vends
  CONTRAIREMENT À  un CRM générique vide (80 % d'adoption nulle) ou une assistante humaine à 2500 $/mois
  NOTRE PRODUIT   te rend tes soirées et te fait scaler de 3 à 10 transactions/mois
  ```

---

### 3.3 Channels

**Actuel.** Deck slide 09 : 100 % référrals (Joanel, Maxime, Charlyse). Pas de canal payant.

**Challenge livre.**
> *« You can have the greatest value propositions in the world, but if nobody knows about them, there is no value. »* (Ch2, BMC #3 Channels)

- ⚠️ Référrals = canal organique non-scalable. À M6 nous projetons 19 courtiers payants — atteignable via Joanel. À M12 (55 courtiers), referrals ne suffiront pas.
- ⚠️ **Pas de canal mesuré.** Aucun KPI Channel dans nos docs (CAC, conversion rate, time-to-first-contact).

**Recommandation.**
- Ajouter un canal expérimental **avant M6** : Centris/OACIQ partner integration ou évènements RE/MAX/Royal LePage.
- Définir Channel KPIs : `# de leads / canal`, `coût par lead`, `taux de conversion lead → pilote`.

---

### 3.4 Customer Relationships

**Actuel.** Implicite dans la promesse « always-human » (template SMS Figma node 62:2) — Klaris positionne toujours le courtier comme l'humain qui prend le relais.

**Challenge livre — Negative Value (Ch3, Negative Value).**
> *« An invisible value-destroyer is more dangerous than a visible one because nobody is looking for it. »*

- ⚠️ **Negative Value visible** : un bot SMS qui répond hors-sujet à un prospect chaud → courtier perd la transaction → réputation blessée. Couvert par Sentry (Sprint 6) ✅.
- ⚠️ **Negative Value invisible** : dépendance accrue à l'IA → atrophie de la compétence relationnelle du courtier. Pas mesuré, pas mitigé.
- ⚠️ JP (Persona #4, peur profonde) : *« Si vous utilisez un outil et que cet outil fait des choses à votre place, vous êtes imputable »* — ce verbatim **est** une alerte Negative Value invisible.

**Recommandation.**
- Ajouter dans BMC Customer Relationships une promesse explicite : « **Audit log + 1-clic reprise humaine** sur chaque conversation Klaris » → directement adressé à JP.
- Mesurer **Innovation Rate inversé** : % de conversations où le courtier reprend la main avant la fin du flow IA. Si > 30 %, signal que la value-destroy invisible se matérialise.

---

### 3.5 Revenue Streams

**Actuel.** Solo 100 CAD/mois · Agence 200 CAD/courtier/mois (deck slide 10).

**Challenge livre.**
> *« How do your value propositions generate revenue? What and how much are your customers willing to pay for? »* (Ch2, BMC #5 Revenue Streams)

- ✅ **Pricing validé qualitativement** par Joanel ($35-50 souhaité, 100 testable).
- ⚠️ **Pas de validation quantitative** : pas de Wizard of Oz MVP testé sur 10 courtiers avec 3 paliers de prix (50 / 100 / 200) pour mesurer la price elasticity.
- ⚠️ **Single revenue stream** = risque. Le livre suggère Channels + Customer Relationships comme sources additionnelles. Klaris pourrait monétiser : intégration Centris (transaction fee), training onboarding (one-shot 500 CAD), white-label agence (revenue share).

**Recommandation.**
- Avant M3 : Promotional MVP (Ch4) sur landing page avec 3 paliers de prix → mesurer signups par palier.
- M9+ : Open API (Ch2 Technical Strategy : *« What about opening our API up to the public? »*) → revenue stream additionnel via integrations Centris/Matrix.

---

### 3.6 Key Activities

**Actuel.** Implicite dans architecture.md : n8n workflows · prompt engineering Claude · Supabase RLS · iOS Flutter · Next.js web.

**Challenge livre.**
> *« What will you need to do to make these value propositions a reality? This involves due diligence activities such as market research, legal feasibility, and possibly even patent registration. »* (Ch2, BMC #6 Key Activities)

- ⚠️ **Activités produit listées** ✅ mais activités business absentes : pas de mention « OACIQ certification », « Loi 25 audit prep », « customer success interviews mensuelles ».
- ⚠️ **Pas d'activité de mesure EBM.** Aucun process d'inspection trimestrielle des KVMs (Ch3).

**Recommandation.**
- Ajouter au BMC Key Activities :
  1. Sprint Review trimestriel avec 3 courtiers payants (inspection EBM).
  2. Veille réglementaire OACIQ + Loi 25 (mensuelle).
  3. Mesure NPS courtiers + NPS prospects-finaux (en continu).

---

### 3.7 Key Resources

**Actuel.** Implicite : équipe 4 fondateurs · stack tech · Joanel pilote · audit JTBD personas.

**Challenge livre.**
> *« After identifying what you need to do (key activities), turn your attention to what you need to have. This includes people with the right skills, equipment, offices, tools, and many more. »* (Ch2, BMC #7 Key Resources)

- ⚠️ **Ressource sous-déclarée la plus critique** : la **relation de confiance Joanel** est le seul moat actuel. Si Joanel quitte, le pilote, les referrals et les 4 personas s'écroulent.
- ⚠️ **Sentry observability** (ajouté Sprint 6) est une key resource non mentionnée dans BMC — pourtant essentielle au Negative Value visible (cf. 3.4).

**Recommandation.**
- Ajouter au BMC Key Resources :
  1. Joanel (relation, accès terrain, referrals) — **single point of failure**, à diversifier d'ici M6.
  2. Audit log + Sentry observability (compliance OACIQ + traçabilité IA).
  3. Domaine OACIQ-conforme + numéro Twilio canadien (déjà couvert checklist Sprint 1).

---

### 3.8 Key Partners

**Actuel.** Non explicité dans BMC. Implicites : Anthropic (modèle IA), Twilio (SMS), Supabase (DB), Stripe (paiements), Apple (App Store).

**Challenge livre.**
> *« To better focus on your customers and value propositions, there are some things you simply should not do yourself even if you have the ability and money to do them. »* (Ch2, BMC #8 Key Partners)

- ⚠️ **Tous nos « partenaires » sont des fournisseurs SaaS substituables** — pas de vrais partenaires stratégiques.
- ⚠️ **Partenaires manquants pour le marché QC** : OACIQ (régulateur), Centris (MLS), Royal LePage / RE/MAX / Sutton (réseaux franchise).

**Recommandation.**
- Ouvrir un dialogue **avec OACIQ avant M6** pour devenir un outil « certifié » — moat réglementaire majeur (cf. JP scepticisme : *« les outils non-conformes vont être bannis »* deck slide 08).
- Cibler 1 partenariat franchise avant M9 (RE/MAX via Maxime ?).

---

### 3.9 Cost Structure

**Actuel.** Documenté en détail dans [business-cost-structure.md](./business-cost-structure.md). Marge brute 91.5 %, seuil rentabilité 8 courtiers.

**Challenge livre.**
> *« Now that you have a better idea of key activities, resources, and partners, you should have an easier time identifying the major investments needed to make this product a reality. Take this opportunity to make these costs explicit. »* (Ch2, BMC #9 Cost Structure)

- ✅ **Brique la mieux documentée** — explicit, chiffrée, scénarisée 12 mois.
- ⚠️ **MAIS** : le livre rappelle (Ch3 Product Cost Ratio) que le coût a deux composantes :
  1. *Investment* in product development (leading metric — coût Sprint = salaires Dev Team).
  2. *Cost of running the product in production* (lagging metric — TCO incluant servers + support + training).
- ⚠️ Notre cost structure documente bien le #2 mais **pas le #1** : aucun coût Sprint mesuré (les 4 fondateurs sont à 0 CAD officiellement). C'est un **leading indicator manquant** qui invalide tout calcul de ROI réel.

**Recommandation.**
- Ajouter ligne **« Coût Sprint estimé »** dans cost structure : 4 fondateurs × ~80 h/mois × 75 CAD/h = ~24 000 CAD de capital temps mensuel non comptabilisé. Le seuil de rentabilité réel (incluant ce coût) passe de 8 à ~270 courtiers solo.
- Distinguer Cost-to-Build vs Cost-to-Run dans le Cost Structure section 6 ([business-cost-structure.md:135](./business-cost-structure.md#L135)).

---

## 4 — Les 3 Vs appliqués à Klaris

D'après Ch1 (« The Product Management Vacuum and the Three Vs ») :

| V | Définition livre | État Klaris | Action requise |
|---|------------------|-------------|----------------|
| **Vision** | « What we are trying to achieve, the bigger picture, the why » | 🟡 **Éparpillée** dans 13 slides deck. Pas d'Elevator Pitch unifié. | Rédiger Elevator Pitch unique + l'afficher dans `architecture.md` et chaque sprint planning |
| **Value** | « The benefits we provide, both to producer and customer » | 🟡 **Asymétrique** — Producer Value documentée (cost structure), Customer Value pas mesurée | Implémenter NPS courtiers (Sprint 8) + NPS prospects (Sprint 9) |
| **Validation** | « Are we actually achieving our vision and delivering value? » | 🟢 **Bonne** — Joanel pilote réel + 4 personas JTBD | Diversifier : 1 pilote payant Maxime ou Charlyse avant M3 |

**Citation clé.** *« A late change in requirements is a competitive advantage »* — Mary Poppendieck (cité Ch5). Klaris doit institutionnaliser la *Pivot or Persevere* discussion (Ch4) chaque trimestre.

---

## 5 — EBM — Klaris a-t-il les bons KVMs ?

Selon Ch3, EBM décompose la valeur en **3 Key Value Areas (KVA)** mesurées par des **Key Value Measures (KVM)** :

### Current Value (la valeur produite *aujourd'hui*)

| KVM | Target livre | Klaris actuel | Gap |
|-----|--------------|---------------|-----|
| Revenue per Employee | Mesuré pour benchmark scale | 0 / 4 fondateurs = 0 CAD | À mesurer dès le 1er courtier payant |
| Product Cost Ratio | TCO + Investment | TCO ✅ documenté, Investment ✗ | Ajouter coût Sprint (cf. 3.9) |
| Employee Satisfaction | Happiness Index Sprint Retro | Non mesuré (pas de retro publique) | Implémenter Happiness Index (Ch3 Fig 3-7) dans Sprint Retro |
| Customer Satisfaction | NPS 0-10 | **Non mesuré** | NPS courtiers post-onboarding + NPS prospects post-conversation |

### Time to Market (capacité à délivrer)

| KVM | Target livre | Klaris actuel | Gap |
|-----|--------------|---------------|-----|
| Release Frequency | Rolling 3-month chart | 7 sprints en 7 mois ≈ 1 release/mois | ✅ Bon, à formaliser |
| Release Stabilization | Temps après feature freeze | Non mesuré | À tracker (estimer rétrospectivement Sprint 1-7) |
| Cycle Time | Idée → production | n8n permet quelques heures | ✅ Avantage concurrentiel à valoriser dans pitch |
| On-Product Index | % temps team sur product (vs admin) | Non mesuré | Time-tracking à mettre en place |

### Ability to Innovate (capacité à délivrer du *nouveau*)

| KVM | Target livre | Klaris actuel | Gap |
|-----|--------------|---------------|-----|
| Installed Version Index | % users sur dernière version | N/A (SaaS) | Non applicable directement |
| Usage Index | % features réellement utilisées | **Non mesuré** | Critique — risque de Innovation Theater |
| Innovation Rate | % code nouveau vs maintenance | Non mesuré | À calculer rétrospectivement (git stats) |
| Defects | Bugs en prod | Sentry depuis Sprint 6 ✅ | Définir cible (< 5 critiques/mois) |

**Verdict EBM.** Klaris a **2/12 KVMs trackés** (Release Frequency, Defects). Les 10 autres sont des **trous noirs métrologiques** qui empêchent toute décision data-driven.

---

## 6 — Cynefin & Stacey — On est bien dans le Complex

D'après Ch5 :

| Axe | Score Klaris | Lecture |
|-----|--------------|---------|
| Stacey — Requirements (agreement) | **Far from agreement** : 4 personas divergents (Joanel push 10/10 vs JP anxiété 8/10) | Complex |
| Stacey — Technology (certainty) | **Mid-range** : stack tech mature (Anthropic, n8n, Supabase, Flutter, Next.js) | Complicated |
| Stacey — People | **Far from agreement** : équipe 4 fondateurs nouvelle, pas encore Performing (Tuckman) | Chaos potentiel |

**Conclusion Cynefin.** Klaris est en **Complex** (probe-sense-respond, emergent practice). Implications :
1. **Pas de plan 12 mois fiable** — notre projection cost structure est un guide, pas une prophétie.
2. **Enabling constraints** > governing constraints. Chaque sprint doit produire des spikes / prototypes (cf. Sprint 8 prochain : tester Wizard of Oz MVP sur Maxime).
3. **High-risk items** doivent être tirés en haut du Product Backlog (Ch5 : *« it is a good practice to have high-risk Product Backlog items higher up... to enable quick learning »*).

**Essential vs Accidental complexity.**
- *Essential* : marché QC (Loi 25, OACIQ, bilinguisme), JTBD courtier, latence SMS critique.
- *Accidental* : 5 stacks (n8n + Supabase + Flutter + Next.js + Resend) — chaque techno est un risque maintenance. Rationalisation possible (ex. : Resend → Supabase Edge Functions).

---

## 7 — Top-7 risques projet appliqués

Ch5 Table 5-3 — risques projet logiciel les plus fréquents (méta-étude 12 papiers, Arnuphaptrairog) :

| # | Risque livre | Statut Klaris | Mitigation actuelle | Gap |
|---|--------------|---------------|----------------------|-----|
| 1 | Misunderstanding requirements | 🟢 OK | JTBD 4 personas, audit JTBD `Atelier_JTBD_Courtier_Consolidation.pdf` | Refresh JTBD chaque 6 mois |
| 2 | Lack of top mgmt commitment | 🟢 N/A | Équipe = founders | — |
| 3 | Lack of adequate user involvement | 🟡 Moyen | Joanel pilote ✅, 3 autres personas non | Onboarder Maxime ou Charlyse en pilote |
| 4 | Failure to gain user commitment | 🟡 Moyen | Joanel committed, autres tièdes | Test gratuité M3-M6 sur 5 nouveaux courtiers |
| 5 | Failure to manage end user expectations | 🔴 Risque | OACIQ compliance promise non auditée | Engagement OACIQ avant M6 (cf. 3.8) |
| 6 | Changes to requirements | 🟢 OK | JTBD identifie déjà 12 patterns | — |
| 7 | Lack of effective PM methodology | 🟢 OK | BMAD agents + Sprint structure | Documenter publiquement la cadence |

---

## 8 — Strategic Alignment Index — Quelles features couper ?

Ch2 (Fig 2-10) propose un graphe Business Strategic Alignment × IT Strategic Alignment, taille de bulle = TCO.

**Plot proposé pour features Klaris** (estimation rapide) :

| Feature | Business Align (1-5) | IT Align (1-5) | TCO mensuel | Verdict |
|---------|----------------------|-----------------|--------------|---------|
| Chatbot SMS qualification | 5 | 5 | $$$ | ✅ Core — top right quadrant |
| Relances auto (J+2/J+5) | 5 | 4 | $$ | ✅ Core |
| Daily briefing email 7h30 | 4 | 4 | $ | ✅ Bon ROI |
| CRM scoring (5 niveaux) | 4 | 4 | $$ | ✅ Bon ROI |
| Apple Watch companion | 2 | 4 | $ | ⚠️ Cool factor low ROI — **candidate retrait** |
| Apple Sign-in | 3 | 3 | $ | 🟡 Garder mais ne pas pitcher |
| PDF monthly reports | 2 | 3 | $ | ⚠️ Demandé par 1/4 personas (Charlyse) — **candidate report Phase 2** |
| Centris MLS sync | 5 | 2 (intégration complexe) | $$$ | 🔴 High biz, low IT readiness — **spike technique requis avant build** |
| Multi-langue ES | 1 | 3 | $ | ❌ **À couper** — aucun des 4 personas ne parle ES |

**Citation clé.** *« Sometimes the most strategic move is to stop and to refocus your investment. Consider ramping down or even retiring products altogether. »* (Ch2, Technical Strategy) — liste citée : Apple Newton, iPod classic, Google Glass, Google Wave, iGoogle, Google Reader, Amazon Fire Phone.

**Recommandation.** Couper Apple Watch + Multi-langue ES en backlog. Documenter la décision.

---

## 9 — Plan d'action — 7 corrections prioritaires

| # | Action | Brique BMC | Sprint cible | Effort | Référence livre |
|---|--------|------------|--------------|--------|------------------|
| 1 | Rédiger Elevator Pitch unifié + l'afficher dans `architecture.md` | Vision (transverse) | Sprint 8 | 2 h | Ch2 Fig 2-7 |
| 2 | Implémenter NPS courtiers post-onboarding (in-app) | Customer Sat (KVM) | Sprint 8 | 1 j | Ch3 Customer Satisfaction |
| 3 | Désigner Joanel comme **segment #1** explicit dans deck + déprioriser JP/Agence | Customer Segments | Sprint 8 | 30 min | Ch2 Focused (Ceralios) |
| 4 | Ajouter coût Sprint (capital temps fondateurs) dans `business-cost-structure.md` | Cost Structure | Sprint 8 | 1 h | Ch3 Product Cost Ratio |
| 5 | Initier dialogue OACIQ pour certification | Key Partners | Sprint 9 | 5 j | Ch5 Risque #5 |
| 6 | Couper Apple Watch + Multi-langue ES du roadmap | Key Activities | Sprint 8 | 30 min | Ch2 Strategic Alignment |
| 7 | Time-tracking équipe pour calculer **On-Product Index** | KVM Time-to-Market | Sprint 9 | 2 h | Ch3 EBM |

---

## Suivi

- [ ] Validation des 7 actions ci-dessus avec les 4 fondateurs
- [ ] Refresh BMC Klaris (frame Figma à créer après dialogue OACIQ)
- [ ] Sprint Retro Sprint 8 : lecture de cette section et vote Pivot/Persevere par brique
- [ ] Itération M3 : recalibrer après 1er NPS courtier mesuré
- [ ] Itération M6 : refresh JTBD + recalibrer si Pivot

*Document v1.0 — 2026-05-08 — basé sur McGreal & Jocham, The Professional Product Owner, Addison-Wesley/Scrum.org, 2018 (ISBN 978-0-13-468647-9)*

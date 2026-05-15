# Klaris — Méthodologie de scoring de confiance

> Comment les `confidence %` sont calculées sur les feuilles de route produit et techno.
> Une marque Next Move · v1.0 · 15 mai 2026

## Pourquoi un scoring formel

Les `confidence %` apparaissant dans les roadmaps Klaris (`klaris-roadmap.md`, `klaris-tech-roadmap.md`) ne sont **pas des intuitions**. Ils résultent d'un scoring multi-facteurs documenté, reproductible, auditable.

**Trois bénéfices :**
1. **Investisseurs** — la grille montre que les % sont défendables, pas du marketing.
2. **Équipe interne** — un thème en discovery (M faible) déclenche une action *avant* le build.
3. **Cohérence** — un thème à 60% en T1 et un thème à 60% en T3 ont été évalués sur la même base.

**Ce que `confidence` *n'est pas* :**
- Pas une probabilité de succès commercial.
- Pas une progression d'avancement (%) du build.
- Pas une note de qualité.

**Ce que `confidence` *est* :**
- Probabilité que le thème **sorte tel qu'écrit, dans l'horizon visé** (Now / Next / Later), compte tenu de ce que l'équipe sait *aujourd'hui*. Conforme à la pratique *Product Roadmaps Relaunched* (Lombardo et al., 2017) — qui exige confidence < 100 % et > 0 %.

---

## La formule

```
Confidence (%) = (D × 0,25 + C × 0,25 + X × 0,15 + M × 0,25 + R × 0,10) / 5 × 100
```

Cinq facteurs, chacun noté **0 à 5**, pondérations sommant à 100 %.

| Facteur | Pondération | Question centrale |
|---------|-------------|-------------------|
| **D — Discovery** | 25 % | Le besoin client est-il *validé* ? |
| **C — Capacity** | 25 % | L'équipe peut-elle *livrer* ce thème ? |
| **X — Dependencies** | 15 % | Les dépendances externes sont-elles *résolues* ? |
| **M — Market** | 25 % | Y a-t-il un signal de *demande* ? |
| **R — Regulatory** | 10 % | Le chemin de *conformité* est-il clair ? |

**Plafond pratique :** 90 %. Conforme à la règle prr — aucun thème ne ressort à 100 %.
**Plancher pratique :** 15 %. Sous 15 %, le thème ne mérite pas la roadmap — il appartient au backlog *Discovery*.

### Grilles de notation

#### D — Discovery

| Score | Signification |
|------:|---------------|
| **0** | Hypothèse non testée. Pas d'entretien client sur le sujet. |
| **1** | 1 entretien évoque le sujet ; pas de retour structuré. |
| **2** | 2–3 entretiens convergent ; pattern faiblement formalisé. |
| **3** | 4+ entretiens convergent ; JTBD documenté ; persona ciblé. |
| **4** | Persona ciblé + données quantitatives (NPS, support, usage) corroborent. |
| **5** | Pilote terrain *vit* le besoin et utilise la solution actuelle / l'a payée. |

#### C — Capacity

| Score | Signification |
|------:|---------------|
| **0** | Stack à choisir, pas d'expertise interne, pas de spike fait. |
| **1** | Stack identifié, mais 0 expertise interne — recrutement requis. |
| **2** | Stack identifié + 1 spike technique réussi. |
| **3** | Équipe a livré un composant *similaire* dans un autre projet. |
| **4** | Équipe a livré un composant identique sur ce produit (autre feature). |
| **5** | Code de base déjà en place, à étendre / industrialiser. |

#### X — Dependencies

| Score | Signification |
|------:|---------------|
| **0** | Bloqué par dépendance externe non maîtrisée (API fermée, partenaire absent). |
| **1** | Dépendance critique en négociation, issue incertaine. |
| **2** | Dépendance critique évaluée, plan B identifié. |
| **3** | Dépendance critique sécurisée (contrat signé / API publique). |
| **4** | 0 dépendance critique externe — uniquement internes. |
| **5** | Aucune dépendance externe, full stack maîtrisé. |

#### M — Market

| Score | Signification |
|------:|---------------|
| **0** | Pas de signal — hypothèse marché pure. |
| **1** | Signal qualitatif anecdotique (1–2 demandes). |
| **2** | 5+ demandes spontanées de prospects ou clients. |
| **3** | Demande explicite documentée sur 10+ comptes ; concurrents adressent le sujet. |
| **4** | Liste d'attente *payante* sur le sujet (LOI / pré-commandes) OU concurrent monétise déjà. |
| **5** | Cohorte existante demande activement, prête à payer un upcharge. |

#### R — Regulatory

| Score | Signification |
|------:|---------------|
| **0** | Risque réglementaire majeur, inconnu, potentiellement bloquant. |
| **1** | Cadre réglementaire identifié, conformité incertaine. |
| **2** | Cadre identifié, plan de mise en conformité dressé. |
| **3** | Plan validé par conseil juridique + DPO. |
| **4** | Conforme aujourd'hui — preuve documentée (RLS, audit log, etc.). |
| **5** | Pas de surface réglementaire OU certification obtenue (OACIQ, SOC 2, etc.). |

---

## Calibration

La pondération a été calibrée pour reproduire le sens commun de l'équipe sur 4 thèmes "ancres" :

| Thème ancre | D | C | X | M | R | Confidence calculée | Confidence intuitive | Écart |
|-------------|--:|--:|--:|--:|--:|--------------------:|---------------------:|------:|
| Pilotes convertissent sans admin manuel (Now) | 5 | 5 | 4 | 5 | 4 | **94 %** → plafonné **90 %** | 80–85 % | OK |
| OACIQ reconnaît Klaris conforme (Now) | 4 | 4 | 3 | 4 | 3 | **76 %** | 75 % | OK |
| Multi-tenant agence (Next) | 3 | 3 | 4 | 3 | 4 | **66 %** | 60 % | OK |
| Marketplace prospects froids (Later) | 1 | 2 | 1 | 1 | 2 | **30 %** | 25 % | OK |

L'écart entre confiance calculée et confiance intuitive (avant rubrique) est ≤ 6 points sur tous les thèmes ancres. Pondérations validées.

**Note :** si calculée > 90 %, plafonner à 90 % (règle prr — aucun thème ne sort à 100 % de certitude).

---

## Application aux thèmes existants

### Roadmap produit — Now

| Thème | D | C | X | M | R | Calculée | Affichée |
|-------|--:|--:|--:|--:|--:|---------:|---------:|
| Pilotes convertissent sans admin manuel | 5 | 5 | 4 | 5 | 4 | 94 % → 90 % | **80 %** *(prudence : pilote unique)* |
| OACIQ reconnaît Klaris conforme | 4 | 4 | 3 | 4 | 3 | 76 % | **75 %** |
| Pilotes restent payants > 90 j | 4 | 4 | 4 | 3 | 4 | 76 % | **70 %** *(données < 90 j)* |
| Investisseurs pré-amorçage : signal clair | 3 | 3 | 4 | 4 | 4 | 68 % | **65 %** |

### Roadmap produit — Next

| Thème | D | C | X | M | R | Calculée | Affichée |
|-------|--:|--:|--:|--:|--:|---------:|---------:|
| Dashboard direction agence | 3 | 3 | 4 | 3 | 4 | 66 % | **60 %** |
| Fiches Centris sans re-saisie | 4 | 3 | 1 | 4 | 3 | 60 % | **55 %** *(API Centris non publique : X faible)* |
| Offre chat → e-signature | 4 | 3 | 3 | 3 | 3 | 64 % | **55 %** |
| VCs Seed : thèse Canada défendable | 3 | 3 | 4 | 3 | 4 | 66 % | **50 %** *(externe — moins maîtrisé)* |

### Roadmap produit — Later

| Thème | D | C | X | M | R | Calculée | Affichée |
|-------|--:|--:|--:|--:|--:|---------:|---------:|
| Klaris parle au marché anglo-canadien | 2 | 3 | 3 | 3 | 3 | 56 % | **40 %** *(marché nouveau, M revu prudent)* |
| Garder relation post-closing | 2 | 2 | 4 | 3 | 4 | 56 % | **35 %** *(prioritisation incertaine)* |
| Partenaires intègrent Klaris (API) | 2 | 2 | 3 | 2 | 3 | 46 % | **30 %** |
| Marketplace prospects qualifiés | 1 | 2 | 1 | 1 | 2 | 30 % | **25 %** |

### Roadmap techno — extraits Now/Next

| Capacité | D | C | X | M | R | Calculée | Affichée |
|----------|--:|--:|--:|--:|--:|---------:|---------:|
| Audit log PII complet (Loi 25) | 4 | 5 | 4 | 4 | 5 | 86 % | **85 %** |
| Backups + DR Supabase | 4 | 5 | 5 | 4 | 4 | 86 % | **80 %** |
| Eval suite IA — ton QC | 4 | 4 | 5 | 4 | 4 | 81 % | **75 %** |
| RAG V1 — knowledge base agence | 3 | 3 | 4 | 3 | 4 | 66 % | **65 %** |
| RAG V2 — multi-source hybrid | 3 | 2 | 3 | 3 | 3 | 56 % | **55 %** |
| Intégration Centris | 4 | 3 | 1 | 4 | 3 | 60 % | **50 %** |
| API publique v1 | 2 | 2 | 3 | 2 | 4 | 50 % | **40 %** |

**Lecture :** quand un thème *passe Now → Next → Later* dans la roadmap, c'est généralement parce qu'un facteur monte. Exemple : `Intégration Centris` montera quand X passera de 1 (API fermée) à 3 (contrat signé) → +6 points de confiance.

---

## Discount intentionnel (le "spread prudence")

L'écart visible entre **Calculée** et **Affichée** dans les tableaux ci-dessus est volontaire. Trois cas où on *abaisse* la confiance affichée :

1. **Petit n** — le thème dépend d'1 seul pilote (Joanel) ou d'une seule preuve. Affichée = Calculée − 5 à 10 pts.
2. **Externe** — le thème dépend d'une décision tierce (VC, régulateur, partenaire). Affichée = Calculée − 10 à 15 pts.
3. **Marché nouveau** — le thème s'appuie sur un segment où on n'a aucune donnée vendue. Affichée = Calculée − 10 à 20 pts.

À l'inverse, on *ne remonte jamais* la confiance affichée au-dessus de la calculée. Asymétrie volontaire — pessimisme structurel comme garde-fou contre l'optimisme fondateur.

---

## Cadence de revue

- **Hebdomadaire** — produit lead met à jour D / C des thèmes Now actifs.
- **Mensuelle** — équipe revoit X / M / R sur tous les thèmes Now + Next.
- **Trimestrielle** — re-scoring complet. Toute variation > 10 points est tracée dans le `Change log` du thème.

**Quand un score baisse de > 15 points entre 2 revues :**
- → revue immédiate : continuer / re-scoper / abandonner.

**Quand un score monte de > 15 points :**
- → le thème mérite-t-il de passer Later → Next ou Next → Now ?

---

## Limites de la méthode

- **Subjectivité dans le 0–5.** Atténuée par la grille mais pas éliminée. Mitigation : 2 personnes scorent indépendamment, on garde la moyenne ; écart > 1 point déclenche discussion.
- **Pondération fixe.** Adaptée à Klaris (B2B early-stage, marché régulé). Une autre boîte changerait sans doute R et M.
- **Pas de probabilités fréquentistes.** On ne dispose pas d'historique long ; les % sont des *paris structurés*, pas des estimations bayésiennes.

---

## Pour les investisseurs

Si tu reçois cette roadmap et qu'un % te paraît élevé/bas :

1. **Demande la décomposition D-C-X-M-R** pour ce thème — c'est explicitement audit-friendly.
2. **Demande le change log** du score sur les 3 derniers trimestres — la volatilité dit autant que la valeur absolue.
3. **Pose la question Now vs Next** : « quel facteur doit monter pour passer en Now ? » — réponse = action plan implicite.

---

## Change log

- 2026-05-15 — Méthodologie formalisée. Rubrique 5 facteurs, calibration sur 4 thèmes ancres.

---

**Klaris** — une marque **Next Move** · 2026 · Confidentiel

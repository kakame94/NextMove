# Klaris — EBM Time-Tracking & On-Product Index Spec

> **Action 7 du plan post-challenge BMC.** Mettre en place la mesure du **On-Product Index** (KVM Time-to-Market) et compléter le tableau EBM Klaris (cf. `business-canvas-challenge.md` §5).
> **Source méthodologique :** *The Professional Product Owner* Ch3 (Evidence-Based Management) + EBMgt Guide Scrum.org.
> Date : 2026-05-08

---

## 1 — Pourquoi mesurer

**Citation Ch3 :**
> *« Velocity, number of tests, code coverage, defects, lines of code… are still important, but they must be considered value-neutral. »*
> *« Cargo Cult mentality "slavishly imitates the working methods of more successful development organizations". »*

Klaris track aujourd'hui **2/12 KVMs** (Release Frequency, Defects via Sentry). Sans **On-Product Index**, on ne sait pas si :
- Les fondateurs passent leur capital temps sur des choses qui produisent de la valeur produit (vs admin, vs réunions, vs apprentissage).
- Le coût Sprint estimé (24 000 CAD/mois, cf. `business-cost-structure.md` §6.1) est représentatif.
- Le ROI réel d'une feature est positif.

---

## 2 — Définition (EBMgt Guide)

> **On-Product Index** = pourcentage du temps de l'équipe consacré à des activités qui ajoutent directement de la valeur au produit.
> Exclus : réunions admin, processus internes, formation hors-produit, vente.

**Formule.**
```
On-Product Index = (Heures sur Product Backlog items + Heures sur Sprint events orientés produit)
                   / Heures totales travaillées
```

**Cible Scrum.org :** > 70 %. **Réalité startup early-stage :** souvent 30-50 %.

---

## 3 — Catégories de temps (taxonomie Klaris)

| Catégorie | On-Product ? | Exemples |
|-----------|--------------|----------|
| **Build** | ✅ OUI | Code Flutter/Next.js/n8n, prompts Claude, schéma Supabase, design Figma directement appliqué |
| **Discovery** | ✅ OUI | JTBD interviews, prototypage, spike technique, design system |
| **Sprint events** | ✅ OUI | Sprint Planning, Daily, Sprint Review, Retro (limités à 4 h/semaine pour 1 fondateur) |
| **Customer success** | ✅ OUI | Onboarding pilote Joanel, debug live d'un courtier, support N1 |
| **Sales / BD** | ❌ NON | Démos investisseurs, démarchage courtiers nouveaux, OACIQ outreach |
| **Admin / Légal** | ❌ NON | Comptabilité, juridique, contrats fournisseurs, déclarations TPS/TVQ |
| **Learning hors-produit** | ❌ NON | Lecture livres généraux, conférences sans application directe |
| **Réunions admin / coordination** | ❌ NON | All-hands sans décision produit, points status > 30 min |

**Cas limite Klaris : `business-cost-structure.md`, `business-canvas-challenge.md`, `oaciq-outreach.md`.**
- Ces docs sont **stratégiques** (pas Build pur) mais **directement liés à la viabilité du produit**.
- → Catégorie hybride : compter à 50 % On-Product (équivalent Discovery × Admin).

---

## 4 — Outil de tracking

**Recommandation : Toggl Track (free tier).**

Pourquoi Toggl plutôt qu'autre :
- Free tier suffit jusqu'à 5 users (4 fondateurs + 1 buffer).
- Mobile + desktop + browser extension.
- Tags pour catégories Klaris (`#build`, `#discovery`, `#sprint`, `#cs`, `#sales`, `#admin`, `#learning`, `#meeting`).
- Export CSV pour reporting mensuel.
- Pas de friction sur l'équipe (timer 1 clic).

**Alternatives évaluées :**

| Outil | Pour | Contre |
|-------|------|--------|
| Linear time tracking | Déjà utilisé (cf. `klaris_ios/README.md` Linear feedback) | Pas de catégorisation libre |
| Clockify | Free unlimited users | UX moins fluide que Toggl |
| Harvest | Bon pour facturation | Surdimensionné, payant |
| Spreadsheet manuel | Zéro coût | Friction = zéro adoption garanti |

---

## 5 — Mise en place — 4 étapes

### Étape 1 (Sprint 8, 30 min) — Compte Toggl + workspace
- Créer workspace `Klaris` (admin : Eliot).
- Inviter Dennis, Walkens, Seydou avec rôle membre.
- Créer 2 projets : `Klaris Product`, `Klaris Business`.
- Créer 8 tags : `build`, `discovery`, `sprint`, `cs`, `sales`, `admin`, `learning`, `meeting`.

### Étape 2 (Sprint 8, 1 h équipe) — Onboarding équipe
- Demo collective 15 min : timer start/stop + tagging.
- Engagement : track au moins **3 jours par semaine** la première semaine, puis tous les jours dès Sprint 9.
- Règle d'or : **mieux vaut un timer approximatif qu'aucun timer**.

### Étape 3 (Sprint 8 fin) — Premier reporting
- Export CSV des 2 premières semaines.
- Calcul On-Product Index par fondateur + agrégé équipe.
- Présenter en Sprint Review : *« On a passé X % du temps sur le produit ce sprint. Cible 70 %. »*

### Étape 4 (Sprint 9+) — Itération
- Ajuster les catégories si une activité ne rentre dans aucune (ex. : `partnerships` si OACIQ devient majeur).
- Identifier les **leaks** : si > 20 % du temps va dans `meeting`, retravailler la cadence Scrum.
- Intégrer le ratio dans la `business-cost-structure.md` pour affiner le coût Sprint réel (`coût Sprint × On-Product Index = coût investi en valeur produit`).

---

## 6 — Reporting mensuel — template

À publier en interne le 1er de chaque mois dans `24_NextMove/docs/ebm-reports/YYYY-MM.md` :

```markdown
# EBM Report — Klaris — [Mois Année]

## Current Value
- Revenue per Employee : X CAD (Y MRR / 4 fondateurs)
- Product Cost Ratio : X CAD/mois TCO + Y CAD/mois Cost-to-Build
- Employee Satisfaction (Happiness Index moyen Sprint Retros) : X/5
- Customer Satisfaction (NPS) : X (n=Y)

## Time-to-Market
- Release Frequency (rolling 3-month) : X releases/mois
- Release Stabilization : X jours en moyenne (depuis feature freeze)
- Cycle Time (idée → prod) : X jours (médiane)
- **On-Product Index : X %** ⭐
  - Build : X %
  - Discovery : X %
  - Sprint events : X %
  - Customer success : X %
  - Hors-produit (sales+admin+learning+meeting) : X %

## Ability to Innovate
- Usage Index : X % features réellement utilisées
- Innovation Rate : X % code nouveau vs maintenance (git stats)
- Defects (Sentry) : X erreurs critiques / X warnings

## Décisions Sprint suivant
- [ ] …
```

---

## 7 — KVMs Klaris — feuille de route mesure

| KVM | Statut M0 (mai 2026) | M3 cible | M6 cible | M12 cible |
|-----|------------------------|----------|----------|-----------|
| Revenue per Employee | 0 | 125 CAD | 575 CAD | 1 750 CAD |
| Product Cost Ratio | À tracker | TCO + 50 % temps | TCO + 70 % temps | TCO + salaires réels |
| Employee Satisfaction | Non mesuré | 1re mesure Sprint Retro 8 | Tendance 3 mois | > 3.5/5 stable |
| Customer Satisfaction (NPS) | Non mesuré | 1re mesure post-Joanel onboarding | n ≥ 5 réponses | NPS > 30 |
| Release Frequency | ~1/mois | 2/mois | 4/mois | 8/mois (continuous) |
| Release Stabilization | Non mesuré | Tracker | < 3 jours | < 1 jour |
| Cycle Time | Non mesuré | Tracker | < 7 jours | < 3 jours |
| **On-Product Index** | Non mesuré | **mesure démarrée** | **> 50 %** | **> 70 %** |
| Usage Index | Non mesuré | Tracker via Sentry events | > 60 % features utilisées | > 80 % |
| Innovation Rate | Non mesuré | Calcul rétro git | > 70 % nouveau | > 50 % nouveau |
| Defects (Sentry) | Sentry actif | < 10 critiques/mois | < 5 critiques/mois | < 2 critiques/mois |

---

## 8 — Risques & angles morts

| Risque | Mitigation |
|--------|------------|
| Goodhart's Law : équipe game l'On-Product Index en re-catégorisant | Audit aléatoire trimestriel + pas de bonus indexé sur le KVM |
| Toggl devient une corvée → adoption 0 | Demo régulière + retro spécifique sur le tracking en cas de chute |
| Données privées (heures perso) leak via Toggl | Workspace dédié, pas de tracking nuit/weekend par défaut |
| Coût Toggl Pro si > 5 users | Stay free tier ou switch Clockify (free unlimited) |
| Cargo Cult : on track sans utiliser les insights | Reporting mensuel obligatoire en Sprint Review (cf. §6) |

---

## 9 — Suivi

- [ ] Sprint 8 : compte Toggl + onboarding équipe
- [ ] Sprint 8 fin : 1er reporting (2 semaines)
- [ ] Sprint 9 : intégration au calcul coût Sprint dans `business-cost-structure.md`
- [ ] Sprint 10 : 1er rapport mensuel publié (`ebm-reports/2026-06.md`)
- [ ] M3 : tableau §7 mis à jour avec données réelles
- [ ] M6 : check On-Product Index > 50 %, ajuster si non

---

*Document v1.0 — 2026-05-08*

# NextMove — Documentation Système de Relance

> Documentation complète du système de relance automatisée (SMS + email + notifications).
> Source de vérité : extractions Figma (Personas, Sprint MVP, Wireframes SMS node 62:2).

## Structure

```
docs/relances/
├── README.md                              ← Ce fichier (index)
├── contexte-sprint-figma.md               ← Contexte Sprint MVP + séquence SMS
├── personas-insights-figma.md             ← 4 personas + 12 patterns (Joanel, Maxime, Charlyse, JP)
├── templates-sms-figma-extraits.md        ← SOURCE DE VÉRITÉ — templates Figma node 62:2
├── relances-decision-matrix.md            ← Document maître (M1-M4)
├── rendez_vous-table-spec.md              ← Spec table rendez_vous (DDL, RLS, état)
├── business-constraints-checklist.md      ← Loi 25 QC + OACIQ + contraintes opérationnelles
├── templates-sms-specifications.md        ← Edge cases et variantes templates
├── workshop/
│   └── agenda-workshop-joanel.md          ← Ordre du jour 90 min + questions
└── sprint-2/
    └── backlog-sprint-2.md                ← User stories P0/P1/P2 + estimations
```

**À lire en premier :** `contexte-sprint-figma.md` — contexte du Sprint MVP + écarts résolus (cadences J+2/J+5/J-1, budget 35-50$/mois).

## Ordre de lecture recommandé

### Pour un développeur (~90 min)

| # | Fichier | Durée | Objectif |
|---|---------|-------|----------|
| 1 | `contexte-sprint-figma.md` | 10 min | Comprendre le produit, scope Sprint 1 vs 2, stack |
| 2 | `personas-insights-figma.md` | 10 min | Pourquoi on construit ça (Joanel + patterns OACIQ) |
| 3 | `templates-sms-figma-extraits.md` | 15 min | Les 5 flux réels à implémenter (source de vérité) |
| 4 | `relances-decision-matrix.md` | 20 min | M1-M4 + diagrammes Mermaid — architecture |
| 5 | `rendez_vous-table-spec.md` | 10 min | DDL + migration (si touche RDV) |
| 6 | `business-constraints-checklist.md` | 10 min | Garde-fous OACIQ + Loi 25 — non-négociables |
| 7 | `sprint-2/backlog-sprint-2.md` | 15 min | User stories P0/P1, Definition of Done |
| 8 | `templates-sms-specifications.md` | 10 min | Edge cases et variantes (complément) |

### Pour Joanel (en workshop)

1. `workshop/agenda-workshop-joanel.md` — suivre le déroulé (90 min)
2. `relances-decision-matrix.md` (sections M1 + M3) — décider triggers + cadences
3. `templates-sms-figma-extraits.md` — valider templates extraits du Figma
4. `sprint-2/backlog-sprint-2.md` — confirmer priorités MVP

## Diagrammes Mermaid inclus (rendus automatiquement par GitHub)

1. **Architecture 4 couches** (M1→M2→M3→M4) — `relances-decision-matrix.md`
2. **Séquence d'inactivité** — `relances-decision-matrix.md`
3. **Arbre de décision complet** (13 garde-fous) — `relances-decision-matrix.md`
4. **Flow technique scheduler n8n** — `relances-decision-matrix.md`
5. **Diagramme d'état prospect** — `relances-decision-matrix.md`
6. **Séquence SMS entrant** (Twilio → n8n → Claude → Supabase) — `contexte-sprint-figma.md`
7. **Diagramme d'état RDV** (planifié → rappel → passé → feedback) — `rendez_vous-table-spec.md`

## Statut

- Documentation prête pour revue
- Workshop Joanel à planifier (agenda : `workshop/agenda-workshop-joanel.md`)
- Décisions à valider en séance (checklists présentes dans chaque doc)

## Contact

- Courtier pilote : **Joanel**
- Repo : `github.com/kakame94/NextMove`

---

*Dernière mise à jour : 2026-04-17*

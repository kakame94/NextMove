# Klaris — Incident Post-Mortem Template (5 Whys)

> **Action L7 du plan Lean Startup.** Template post-mortem pour chaque incident critique Sentry / défaillance prod. Méthodologie 5 Whys de Toyota Production System (cité Ries Ch11).
> **Source méthodologique :** *The Lean Startup* Ch11 Adapt — 5 Whys.
> **Cadence :** post-mortem ≤ 48h après incident résolu.
> **Fichier de destination :** `incidents/YYYY-MM-DD-slug.md`
> Date : 2026-05-08

---

## Pourquoi 5 Whys

Citation Ch11 :
> *« At the root of every seemingly technical problem is actually a human problem. »*
> *« 5 Whys lets you make small investments in incremental tests, and a small amount of work for each step. »*

5 Whys =
1. Identifie cause racine (pas symptôme)
2. Révèle problème humain/processus sous problème technique
3. Génère action **humaine** corrective (pas juste hotfix code)

---

## Setup canal #incidents

### Slack workspace Klaris (Sprint 9)

Créer canal `#klaris-incidents`.

**Triggers automatiques (Sentry → Slack webhook) :**
- Toute erreur `level: error` ou `level: fatal` répétée ≥ 3 fois en 5 min
- Toute erreur sur edge function `daily-briefing` ou `centris-sync`
- Toute exception non gérée dans n8n workflow critique
- Health check `/health` n8n KO > 5 min (cf. R1 architecture-challenge.md)

**Format alerte Slack :**
```
🚨 INCIDENT
Service : [n8n / klaris-web / klaris-ios / supabase]
Severité : [P0 / P1 / P2]
Erreur : [message court]
Sentry : [lien direct]
Owner-on-call : @[user de la rotation]
```

**Rotation on-call (4 fondateurs)** :
- Semaine 1 : Eliot
- Semaine 2 : Dennis
- Semaine 3 : Walkens
- Semaine 4 : Seydou
- Cycle se répète

---

## Template post-mortem

Copier ce template dans `incidents/YYYY-MM-DD-slug.md` après chaque incident P0/P1.

```markdown
# Incident YYYY-MM-DD — [Titre court]

## Métadonnées

- **Date début** : YYYY-MM-DD HH:MM (UTC)
- **Date résolution** : YYYY-MM-DD HH:MM (UTC)
- **Durée** : XX min
- **Severité** : P0 (service down) / P1 (dégradé) / P2 (feature isolée)
- **Service impacté** : [n8n / klaris-web / klaris-ios / supabase / twilio / anthropic]
- **N courtiers affectés** : X
- **N prospects affectés** : X
- **On-call** : @[user]
- **Post-mortem owner** : @[user]

## Résumé exécutif

> 2-3 phrases : qu'est-ce qui s'est passé, impact, comment résolu.

## Timeline

| HH:MM | Événement |
|-------|-----------|
| 14:23 | 1ère erreur Sentry |
| 14:25 | Slack alerte déclenchée |
| 14:30 | On-call ack + investigation |
| 14:45 | Root cause identifiée |
| 14:55 | Hotfix déployé |
| 15:00 | Service restauré |

## Symptôme observable

> Ce que les courtiers ont vu/vécu.

## 5 Whys

1. **Pourquoi le SMS n'est pas parti ?**
   → [Réponse technique]

2. **Pourquoi [réponse 1] ?**
   → [Cause sous-jacente]

3. **Pourquoi [réponse 2] ?**
   → [Cause encore plus profonde]

4. **Pourquoi [réponse 3] ?**
   → [Souvent c'est ici qu'on trouve un problème de processus humain]

5. **Pourquoi [réponse 4] ?**
   → **Cause racine** : généralement humaine (manque de tests, manque de revue, manque de monitoring, hypothèse non validée).

## Actions correctives

| Type | Action | Owner | Sprint |
|------|--------|-------|--------|
| 🔧 Tech (court terme) | [Hotfix appliqué] | @ | Déjà fait |
| 🔧 Tech (long terme) | [Refactor / monitoring / test] | @ | Sprint X |
| 👥 Process (humain) | [Revue / formation / runbook / cadence] | @ | Sprint X |

## Impact business

- MRR perdu : ~X CAD (estimation)
- Nb courtiers à recontacter : X
- Risque réputation : faible / moyen / élevé
- SLA breach (vs cible RTO 4h, RPO 1h) : OUI / NON

## Communication courtiers

- [ ] Email transparence envoyé à courtiers affectés
- [ ] Crédit appliqué si SLA breach
- [ ] Update sur status page (si applicable)

## Leçons apprises

> 1-3 phrases : qu'est-ce qu'on retient pour le futur ?

## Validation

- [ ] Post-mortem partagé en Sprint Review semaine suivante
- [ ] Actions correctives ajoutées au backlog Linear
- [ ] Pas de blame — focus processus, pas individus (citation Ch11 Ries)

---

*Post-mortem créé YYYY-MM-DD — owner @[user]*
```

---

## Exemple complet (fictif)

Voir [2026-08-15-twilio-rate-limit.md](./2026-08-15-twilio-rate-limit.md) (exemple créé pour onboarding équipe).

---

## Cadence retro mensuelle

1× par mois (1er Vendredi), revue de tous les incidents du mois en Sprint Retro élargie :

| Section | Durée |
|---------|-------|
| Liste incidents du mois (count par sévérité) | 5 min |
| Top 3 5 Whys patterns récurrents | 10 min |
| Actions correctives en retard | 5 min |
| Décision : runbooks à créer/updater | 10 min |

---

## Anti-patterns Lean (Ch11)

| Anti-pattern | Mitigation |
|---------------|------------|
| Blame culture (« qui a poussé ce code ? ») | Charte explicite : pas de noms dans actions, juste process/system |
| 5 Becauses (chaque why = excuse) | Discipliner : chaque "why" = factuel, pas justification |
| Trop de post-mortems → épuisement | Seulement P0/P1. P2 = update Linear ticket sans cérémonie |
| Actions correctives jamais faites | Owner + sprint cible obligatoire dans le post-mortem |

---

## Suivi

- [ ] Sprint 9 : créer canal Slack `#klaris-incidents` + Sentry webhook
- [ ] Sprint 9 : créer rotation on-call dans calendrier équipe
- [ ] Sprint 9 : créer 1 exemple post-mortem fictif pour onboarding (`2026-08-15-twilio-rate-limit.md`)
- [ ] Sprint 10 : 1er post-mortem réel (si incident)
- [ ] Sprint 11 (mensuel) : 1ère retro mensuelle incidents

---

*Template v1.0 — 2026-05-08 — basé sur* The Lean Startup *Ch11 Adapt (5 Whys, Toyota Production System)*

# Klaris — Features dépréciées (sunset plan)

> **Action 6 du plan post-challenge BMC.** Couper / déprioriser les features identifiées comme low Strategic Alignment Index (cf. `business-canvas-challenge.md` §8 + Ch2 livre *The Professional Product Owner*).
> **Statut :** validé par le challenge BMC — à confirmer par les 4 fondateurs en Sprint Retro Sprint 8.
> Date : 2026-05-08

---

## Pourquoi déprécier

Citation Ch2 (Technical Strategy) :
> *« Sometimes the most strategic move is to stop and to refocus your investment. Consider ramping down or even retiring products altogether. »*
> Liste citée par les auteurs : Apple Newton, iPod classic, Google Glass, Google Wave, iGoogle, Google Reader, Amazon Fire Phone.

Une feature qui reste dans le code mais que personne n'utilise = **accidental complexity** (Ch5) qui ralentit chaque release future, augmente la surface d'attaque, et brouille la value proposition.

---

## Features dépréciées

### F-DEPRECATED-001 — Apple Watch companion

**Localisation code.**
- `klaris_ios/ios/KlarisWatch/KlarisWatchApp.swift`
- `klaris_ios/ios/KlarisWatch/WatchSession.swift`
- `klaris_ios/ios/Runner/WatchBridge.swift`
- `klaris_ios/lib/data/services/watch_bridge_service.dart`
- README : [klaris_ios/README.md:303](../../klaris_ios/README.md#L303)

**Pourquoi déprécier.**

| Critère | Score | Notes |
|---------|-------|-------|
| Business Strategic Alignment | 2/5 | Aucun verbatim courtier ne demande Apple Watch. JTBD 4 personas → 0 mention montre |
| IT Strategic Alignment | 4/5 | Implémenté Sprint 7, fonctionnel |
| TCO mensuel | $ (faible direct) | MAIS dette de maintenance watchOS releases × Xcode × WatchConnectivity API breaking changes |
| Adoption mesurée | 0 | Pas de métrique, aucun pilote testé sur Watch |
| Feature publiquement promise | Non | Pas dans deck slide 06 |

**Verdict.** *Cool factor* sans ROI prouvé. Maintenir = ralentir chaque release iOS pour tester WatchConnectivity. Couper = libérer ~5-10 % du temps Sprint iOS.

**Plan de sunset.**

| Étape | Sprint | Action |
|-------|--------|--------|
| 1 | Sprint 8 | Documenter cette dépréciation (ce fichier) |
| 2 | Sprint 8 | Désactiver Watch target dans Xcode build (`ENABLED = NO`) |
| 3 | Sprint 9 | Retirer `ios/KlarisWatch/` du build par défaut (garder en branche `archive/apple-watch`) |
| 4 | Sprint 9 | Mettre à jour `klaris_ios/README.md` : marquer ligne 303 comme `[DEPRECATED]` |
| 5 | Sprint 10 | Retirer `WatchBridge.swift` + `watch_bridge_service.dart` du master si aucune demande utilisateur |
| 6 | Sprint 11 | Suppression complète du code (ou archive Git tag) |

**Réversibilité.** Le code reste en branche `archive/apple-watch`. Si un futur courtier (segment expansion phase 2, M9+) demande Watch, on peut rebaser et réactiver en ~2 jours.

---

### F-DEPRECATED-002 — Localisation es-MX (espagnol Mexique)

**Localisation code.**
- `klaris_ios/lib/core/i18n/klaris_strings.dart` (override `_es`)
- `klaris_ios/lib/core/i18n/klaris_lang.dart` (enum `KlarisLang.es`)
- `klaris_ios/test/i18n_es_fallback_test.dart`
- `klaris_ios/metadata/` (pas de `es-MX/` détecté)
- README : [klaris_ios/README.md:305](../../klaris_ios/README.md#L305)

**Pourquoi déprécier.**

| Critère | Score | Notes |
|---------|-------|-------|
| Business Strategic Alignment | 1/5 | 0/4 personas QC parlent espagnol comme langue principale. Marché hispanophone ≠ marché immobilier QC |
| IT Strategic Alignment | 3/5 | 35 traductions partielles → pas une feature complète |
| TCO mensuel | $ | Tests à maintenir, fallback chain à valider à chaque release |
| Adoption mesurée | 0 | Aucun courtier testeur hispanophone |
| Feature publiquement promise | Non | Deck slide 06 dit « Bilingue FR/EN » uniquement |

**Verdict.** Implémenté en spéculation d'une expansion future, mais aucun signal marché. Garder = dette de tests + risque de désynchronisation avec FR/EN à chaque ajout de string. Couper = simplifier la matrice i18n.

**Plan de sunset.**

| Étape | Sprint | Action |
|-------|--------|--------|
| 1 | Sprint 8 | Documenter cette dépréciation (ce fichier) |
| 2 | Sprint 8 | Marquer `KlarisLang.es` comme `@Deprecated` (Dart annotation) |
| 3 | Sprint 9 | Retirer l'option ES de `Settings → Langue` dans l'UI |
| 4 | Sprint 9 | Conserver le fallback chain ES → EN dans le code (pas d'erreur si un user a déjà ES en `SharedPreferences`) |
| 5 | Sprint 10 | Si zéro user ES détecté en télémétrie : retirer `_es` map + test associé |
| 6 | Sprint 11 | Mettre à jour `klaris_ios/README.md` ligne 305 : ajouter `[REMOVED — see feature-deprecations.md]` |

**Réversibilité.** Si un marché hispanophone émerge (ex. : courtiers latinoaméricains à Montréal), réactivation possible en ~3 jours via re-import des 35 strings depuis Git history.

---

## Critères de re-priorisation

Une feature dépréciée peut être ré-activée si **au moins 2 sur 3** critères sont remplis :

1. **Demande explicite** d'au moins 3 courtiers payants distincts (pas juste pilotes).
2. **Score Business Strategic Alignment** repassé à ≥ 4/5 après JTBD refresh.
3. **TCO maîtrisé** — la feature est dans un module isolé qui ne dégrade pas la vélocité du core.

---

## Features sous surveillance (pas encore dépréciées)

À évaluer en Sprint Retro Sprint 8 :

| Feature | Risque potentiel | Décision attendue |
|---------|-------------------|-------------------|
| Centris MLS sync | High biz alignment, low IT readiness — spike technique requis | Spike Sprint 9 → keep ou kill |
| Apple Sign-in | Marginal vs Magic Link / OAuth Google | Garder mais retirer du pitch si jamais utilisé |
| PDF monthly reports | Demandé par 1/4 personas (Charlyse) | Reporter Phase 2 (M9+) |

---

## Suivi & gouvernance

- Toute dépréciation est ajoutée à ce fichier **AVANT** modification du code.
- Le code n'est jamais supprimé sans un Sprint d'observation (étape 5 de chaque plan).
- Les fondateurs votent en Sprint Retro la confirmation de chaque dépréciation.
- Une dépréciation peut être annulée si un argument terrain solide émerge avant l'étape 5.

---

*Document v1.0 — 2026-05-08*

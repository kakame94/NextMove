# Klaris iOS — Backlog développeur

> **Stack :** Flutter 3.27+ · Dart 3.5+ · Riverpod · go_router · Supabase · drift · Sentry
> **Cible :** iPhone 14+/iOS 17+ (Cupertino) · companion Apple Watch · Widget · Live Activities
> **Owner doc :** lead tech NextMove · **Dernière revue :** 2026-05-15

Cette feuille de backlog couvre les tickets de développement post-Sprint 6, organisés par **épique** et **priorité** (P0 → P2). Chaque ticket inclut critères d'acceptation et notes d'implémentation. Les tickets P0/P1 prioritaires sont également créés en *GitHub Issues* sur [kakame94/NextMove](https://github.com/kakame94/NextMove).

## Légende

| Priorité | Sens | SLA dev |
|----------|------|---------|
| **P0** | Bloquant App Store / pilote / conformité | Sprint courant |
| **P1** | Fonctionnalité commerciale prévue (Sprint 7-8) | 4–6 semaines |
| **P2** | Tech debt, polish, optimisation | Quand disponible |

Tailles : **XS** (≤ 4 h) · **S** (½ j) · **M** (1 j) · **L** (2–3 j) · **XL** (≥ 4 j)

---

## Épique 1 — Pré-launch App Store (P0)

Objectif : passer de TestFlight pilote à publication App Store, FR-CA + EN-CA.

### IOS-001 · Configurer signing & provisioning production · **P0 · S**
- **Description :** Apple Developer → certificat distribution, App ID `ai.klarisapp.klaris_ios`, profil App Store, capabilities (Push, Background Modes, Sign in with Apple, Live Activities, App Groups).
- **Critères d'acceptation :**
  - `flutter build ipa --release` produit `.ipa` signé sans erreur.
  - `xcrun altool --validate-app` passe.
  - App Group `group.ai.klarisapp.klaris_ios` actif sur Runner + KlarisWidget + KlarisWatch.
- **Notes :** générer `ios/exportOptions.plist` (cf. README Sprint 5).

### IOS-002 · Bundle des extensions (Widget + Watch + Live Activity) dans la prod build · **P0 · M**
- **Description :** vérifier que `flutter build ipa` embarque les extensions Xcode (KlarisWidget, KlarisWatch). Aujourd'hui seuls les fichiers Swift sont versionnés ; les targets Xcode doivent être configurés.
- **Critères d'acceptation :**
  - Widget visible sur iPhone après install TestFlight.
  - Watch app installable depuis app companion.
  - Live Activity démarrée lors d'un RDV à venir < 1 h.
- **Notes :** documenter procédure Xcode dans `ios/EXTENSIONS_SETUP.md`. Voir Sprint 6 README.

### IOS-003 · Captures d'écran App Store FR-CA + EN-CA · **P0 · M**
- **Description :** générer les 8 captures par locale × 3 tailles (6.7" / 6.5" / 5.5") via mode démo (`Env.demoMode = true`).
- **Critères d'acceptation :**
  - 8 captures par taille, par locale = 48 fichiers PNG.
  - Plan défini dans `metadata/SCREENSHOTS.md` respecté.
  - Filetypes conformes (PNG, sRGB, no alpha).
- **Notes :** scripter avec `fastlane snapshot` ou capture manuelle simulator iPhone 16 Pro Max.

### IOS-004 · App Privacy Nutrition Labels App Store Connect · **P0 · S**
- **Description :** renseigner les Privacy Nutrition Labels dans App Store Connect d'après `metadata/PRIVACY_LABELS.md`.
- **Critères d'acceptation :**
  - "Data Not Linked to You" : aucun tracker tiers.
  - "Data Linked to You" : Contact Info (phone, email), Identifiers (user ID), Diagnostics (Sentry).
  - Hosting Canada (ca-central-1) déclaré.
- **Notes :** revue par DPO interne avant soumission.

### IOS-005 · Build TestFlight 1.0.0+1 et invitations 20 testeurs · **P0 · S**
- **Description :** monter vers `pubspec.yaml` version 1.0.0+1, build release, upload Transporter, distribuer aux 10 pilotes + 10 invités.
- **Critères d'acceptation :**
  - Build approuvé TestFlight beta review.
  - 20 emails invitation envoyés (10 pilotes Joanel-validés + 10 invités élargis).
  - Feedback flow Linear opérationnel (Sprint 6).
- **Notes :** changelog TestFlight rédigé FR + EN.

### IOS-006 · Crash-free rate ≥ 99% sur 7 jours avant soumission · **P0 · M**
- **Description :** monitorer Sentry pendant TestFlight, fixer top 3 crashes avant soumission.
- **Critères d'acceptation :**
  - Sentry dashboard montre crash-free users ≥ 99% sur 7 j glissants.
  - 0 crash P0 (auth, prospects list, conversations).
  - Rapports Sentry redaction phone/email vérifiée.

### IOS-007 · App Store submission + waiting room metadata · **P0 · M**
- **Description :** soumettre à Apple, gérer rejets éventuels (description, age rating 4+, encryption export compliance).
- **Critères d'acceptation :**
  - Submitted → In Review → Ready for Sale.
  - Délai cible : < 3 jours review.
  - Plan de rejet documenté (anticipation : section 5.1.1 collecte données, 4.0 minimum functionality).

---

## Épique 2 — Conformité Loi 25 / OACIQ (P0)

Objectif : passer la revue OACIQ formelle (lettre d'absence d'objection) + DPIA Loi 25.

### IOS-010 · Écran consentement Loi 25 au premier login · **P0 · M**
- **Description :** modal Cupertino bloquant au 1ᵉʳ login : finalités, droits (accès, suppression, portabilité), DPO contact. Persist consent timestamp dans `courtiers.privacy_consent_at`.
- **Critères d'acceptation :**
  - Refus = sign out + redirect login.
  - Accept = persisté + journalisé `audit_log` (action `privacy_consent`).
  - Lien vers politique de confidentialité (page web).
- **Notes :** copy à valider avec DPO. Migration : `alter table courtiers add column privacy_consent_at timestamptz`.

### IOS-011 · Export données utilisateur (Loi 25 portabilité) · **P0 · M**
- **Description :** dans `settings_screen.dart`, action "Exporter mes données" → Edge Function génère ZIP (JSON prospects + conversations + relances + audit) → email signed URL 24 h.
- **Critères d'acceptation :**
  - ZIP livré sous 48 h max (engagement règlementaire 30 j max).
  - Format JSON parsable + README inclus.
  - Signed URL expirée 24 h après génération.
- **Notes :** Edge Function `supabase/functions/data-export/`. Audit log entry `data_export_requested`.

### IOS-012 · Suppression compte (Loi 25 droit à l'oubli) · **P0 · M**
- **Description :** action settings "Supprimer mon compte" → confirmation double + délai 7 j + cascade suppression Supabase (prospects, conversations, audit log anonymisé).
- **Critères d'acceptation :**
  - Suppression effective sous 7 j (fenêtre annulation 7 j respectée).
  - Audit log conservé mais courtier anonymisé (`user_id → null`).
  - Email confirmation + email à J+7 "suppression effective".
- **Notes :** Edge Function `account-deletion/` avec scheduled drain. Bouton rouge destructive Cupertino.

### IOS-013 · Page accessibilité audit log (OACIQ traceability) · **P0 · L**
- **Description :** écran dédié `settings/audit_log_screen.dart` listant les actions trackées de l'utilisateur, filtres date/action, export CSV.
- **Critères d'acceptation :**
  - Toutes les actions OACIQ-pertinentes visibles (consent, relance envoyée, prospect créé/modifié, conversation, mémo).
  - Pagination 50 par page, recherche full-text.
  - Export CSV via Share sheet iOS.
- **Notes :** vue Supabase déjà existante (`audit_log`). RLS broker-scoped.

### IOS-014 · DPIA & politique de confidentialité publiée · **P0 · M**
- **Description :** rédiger DPIA Loi 25, publier page web `klaris.app/confidentialite`, lier depuis app.
- **Critères d'acceptation :**
  - DPIA validé par DPO + conseiller juridique.
  - Page web FR + EN.
  - Lien actif depuis écran consentement (IOS-010) et settings.

---

## Épique 3 — Sprint 7 · Recommandations IA listings (P1)

Objectif : matcher automatiquement les fiches Centris importées avec les besoins acheteurs.

### IOS-020 · RPC `match_listings_for_prospect(prospect_id)` · **P1 · M**
- **Description :** Postgres function qui retourne top 10 listings par score (budget, secteur, type, délai), pondéré.
- **Critères d'acceptation :**
  - SQL function dans `migrations/007_sprint7_listing_match.sql`.
  - RLS-aware (broker voit listings de son agence + scope public).
  - Retourne `(listing_id, score 0-100, match_reasons jsonb)`.
  - Tests pgTAP sur 5 cas (match parfait, mismatch budget, mismatch type, etc.).

### IOS-021 · Widget recommandations dans `prospect_detail_screen.dart` · **P1 · M**
- **Description :** section "Suggestions pour ce client" avec carrousel 5 cards listings (photo, prix, secteur, type, score badge).
- **Critères d'acceptation :**
  - Composant `prospect_recommendations_section.dart` (déjà scaffold — compléter).
  - Tap card → écran détail listing (nouveau).
  - "Envoyer au client" → ouvre conversation thread + injecte template.
- **Notes :** réutiliser `HeatIndicator` pour score, palette OKLCH.

### IOS-022 · Écran détail listing · **P1 · M**
- **Description :** nouvelle vue `features/listings/listing_detail_screen.dart` : photos (carousel), prix, specs, secteur, map preview, bouton "Partager au client".
- **Critères d'acceptation :**
  - Photos via Centris CDN (lazy load).
  - Map preview apple_maps_flutter mode statique.
  - Bouton partage → conversation thread + template SMS auto-rempli.
- **Notes :** photos protégées RLS Centris. Si feed pas encore live → mock data.

### IOS-023 · Notification push "Nouveau listing pour client X" · **P1 · M**
- **Description :** Edge Function scheduled (15 min) : pour chaque nouveau listing, exécute match RPC, push notif si score > 80 pour ≥ 1 prospect.
- **Critères d'acceptation :**
  - Function `supabase/functions/listing-match-notify/` déployée.
  - Push payload deeplink vers `prospect_detail_screen` ancrée recommandations.
  - Throttle : max 5 push/jour par courtier (anti-spam).
- **Notes :** réutilise `device_tokens` table (Sprint 2).

### IOS-024 · Eval suite — qualité matching · **P1 · M**
- **Description :** dataset 50 paires (prospect, listing) labellisé manuellement par Joanel, script Python qui calcule precision@5, recall@5.
- **Critères d'acceptation :**
  - Script `tests/evals/listing_match_eval.py` dans `klaris_ios/test/evals/`.
  - Precision@5 ≥ 0.7 sur dataset baseline.
  - Rapport CSV exporté à chaque run.

---

## Épique 4 — Sprint 8 · Copilote transaction (P1)

Objectif : passer de l'intake à la transaction — rédaction d'offres OACIQ + e-signature.

### IOS-030 · Template OACIQ promesse d'achat — paramétrable · **P1 · L**
- **Description :** modèle PDF OACIQ standard (PDF formulaire à champs) téléchargé une fois, fillable côté serveur (`pdf-lib` ou `PyMuPDF`) avec données prospect + listing.
- **Critères d'acceptation :**
  - Edge Function `supabase/functions/draft-offer/` reçoit `{prospect_id, listing_id, prix_offert, conditions}` et retourne PDF.
  - PDF passe validation visuelle OACIQ (champs aux bons endroits).
  - Audit log entry `offer_drafted`.

### IOS-031 · Écran "Préparer une offre" · **P1 · L**
- **Description :** nouvelle vue `features/offers/offer_draft_screen.dart` — formulaire multi-step (prospect → listing → prix → conditions → preview PDF).
- **Critères d'acceptation :**
  - Pré-rempli depuis recommandations (IOS-021) si lancé depuis là.
  - Preview PDF intégré avant envoi.
  - Bouton "Envoyer pour signature" → IOS-032.

### IOS-032 · Intégration Notarius signature électronique · **P1 · XL**
- **Description :** Edge Function `notarius-sign/` qui pousse le PDF chez Notarius API + reçoit webhook signature complétée.
- **Critères d'acceptation :**
  - PDF envoyé à Notarius avec liste signataires (acheteur + courtier).
  - Webhook reçu → `offers.status = 'signed'` + PDF signé stocké Supabase Storage.
  - Notification push au courtier "Offre signée par client X".
- **Notes :** sandbox Notarius + secret `NOTARIUS_API_KEY`.

### IOS-033 · Intégration DocuSign (fallback hors-QC) · **P1 · L**
- **Description :** alternative à Notarius pour les courtiers EN-CA (Toronto/Ottawa) — préférences settings.
- **Critères d'acceptation :**
  - Toggle settings "Service de signature" : Notarius (QC) / DocuSign (autres).
  - Edge Function `docusign-sign/` symétrique à Notarius.
  - Webhook handler unifié.

### IOS-034 · Historique offres par prospect · **P1 · M**
- **Description :** onglet "Offres" sur `prospect_detail_screen.dart`, liste des offres avec statut (brouillon, envoyée, signée, refusée).
- **Critères d'acceptation :**
  - Table `offers` + RLS broker-scoped.
  - Filtres statut.
  - Tap → preview PDF + actions (annuler, dupliquer).

---

## Épique 5 — Tests & qualité (P1)

### IOS-040 · Couverture unitaire ≥ 70% sur `data/` · **P1 · L**
- **Description :** étendre `flutter test` pour atteindre 70% sur `data/models/` + `data/repositories/` + `data/sync/`.
- **Critères d'acceptation :**
  - `flutter test --coverage` produit `lcov.info`.
  - `data/` coverage ≥ 70% lignes.
  - Rapport HTML généré et stocké artifact CI.

### IOS-041 · Tests Patrol E2E pour parcours critique (login → prospect → relance) · **P1 · M**
- **Description :** étendre `integration_test/patrol/` avec scénario complet jusqu'à envoi relance.
- **Critères d'acceptation :**
  - Test `patrol/golden_path_e2e.dart` passe sur simulator iPhone 16 Pro.
  - Inclut Apple Sign In + permission Microphone + permission Notifications.
  - Run dans CI (Firebase Test Lab).

### IOS-042 · CI GitHub Actions — build + test + lint à chaque PR · **P1 · M**
- **Description :** workflow `.github/workflows/ios-ci.yml` qui exécute `flutter analyze` + `flutter test` + `flutter build ios --no-codesign` sur macOS runner.
- **Critères d'acceptation :**
  - PR bloquée si lint ou tests échouent.
  - Temps total < 15 min (cache pub-cache + DerivedData).
  - Coverage uploadé sur Codecov.

---

## Épique 6 — Performance & scale (P2)

### IOS-050 · Réduire cold start app < 1.5 s · **P2 · M**
- **Description :** profiler avec DevTools, defer init Sentry/Firebase au post-frame, lazy-load drift.
- **Critères d'acceptation :**
  - Time-to-interactive < 1.5 s sur iPhone 14.
  - First frame < 700 ms.
  - DevTools timeline trace archivé.

### IOS-051 · Pagination prospects list (limit 50, infinite scroll) · **P2 · M**
- **Description :** aujourd'hui `prospects_list_screen` charge tout. Passer à query paginée Supabase + sliver scroll.
- **Critères d'acceptation :**
  - Initial load ≤ 50 prospects.
  - Scroll bottom → fetch suivant (200 ms loading state).
  - Cache drift mis à jour incrémentalement.

### IOS-052 · Image cache + thumbnails pour listings · **P2 · S**
- **Description :** `cached_network_image` + génération thumbnails 400px côté serveur (Supabase image transform).
- **Critères d'acceptation :**
  - Bandwidth moyen / écran detail listing < 200 KB.
  - Pas de jank scroll carrousel.

---

## Épique 7 — Polish UX (P2)

### IOS-060 · Haptic feedback sur actions clés · **P2 · XS**
- **Description :** `HapticFeedback.lightImpact()` sur tap card, `mediumImpact` sur action destructive, `heavyImpact` sur erreur.
- **Critères d'acceptation :** appliqué à 15+ interactions clés. Liste documentée.

### IOS-061 · Dark mode review complet · **P2 · M**
- **Description :** passer chaque écran en dark mode, vérifier contrastes, fixer regressions tokens OKLCH.
- **Critères d'acceptation :**
  - 0 issue contraste WCAG AA dark mode.
  - Captures dark mode dans `metadata/SCREENSHOTS.md`.

### IOS-062 · Animations transitions go_router · **P2 · S**
- **Description :** customiser `CupertinoPageRoute` transitions (slide-up modaux, fade subtle list-to-detail).
- **Critères d'acceptation :** transitions cohérentes, pas de flash, pas de jank.

### IOS-063 · State empty illustrés (mascotte) · **P2 · S**
- **Description :** chaque liste vide montre `KlarisMascot` widget + CTA primaire.
- **Critères d'acceptation :** 8 empty states stylés (prospects, conversations, relances, briefing, RDV, listings, offres, mémos).

---

## Épique 8 — Multi-tenant agence (P1)

### IOS-070 · Onboarding agence — création + invitation membres · **P1 · L**
- **Description :** flow `features/agency/agency_create_screen.dart` + `agency_invite_screen.dart` — créer agence, inviter par email, gérer rôles.
- **Critères d'acceptation :**
  - Owner peut créer 1 agence, inviter N courtiers.
  - Invité reçoit email (Resend) avec lien magique.
  - Rôles : admin / manager / broker (déjà en DB Sprint 4).

### IOS-071 · Dashboard direction — vue agrégée + drill-down · **P1 · M**
- **Description :** étendre `agency_dashboard_screen.dart` avec drill-down par courtier (tap → écran perso, leads attribués).
- **Critères d'acceptation :**
  - 4 KPIs agrégés (leads, qualifiés, conclus, RDV).
  - Liste membres avec mini-stats.
  - Tap membre → détail.

### IOS-072 · Reassignation lead inter-courtiers · **P1 · M**
- **Description :** depuis `prospect_detail_screen`, action admin/manager "Réassigner" → modal sheet liste courtiers de l'agence.
- **Critères d'acceptation :**
  - Action limitée admin/manager (RLS check).
  - Audit log entry `prospect_reassigned`.
  - Notification push au nouveau courtier.

---

## Hors backlog — Discovery (P2)

Sujets à valider en discovery avant de scoper :

- **Centris feed API officielle** — négociation accès API (vs scraping). Owner : Eliot.
- **Apple Intelligence integration** — résumé conversation natif iOS 18.2+ (cross-device).
- **CarPlay companion** — afficher prochain RDV + naviguer dans CarPlay.
- **iPad app** — adaptive layout (multi-pane). Quelle valeur pour le courtier ?
- **In-app subscription Apple (vs Stripe web)** — fees Apple 15-30% vs web ; impact UX.

---

## Workflow

1. **Pick** : prendre le ticket P0 ou P1 en tête du backlog.
2. **Branch** : `feat/ios-NNN-short-slug` ou `fix/ios-NNN-short-slug`.
3. **PR** : link `Closes #issue-NNN`, demande review tech lead.
4. **Tests** : ajouter tests unitaires + Patrol E2E si parcours.
5. **Demo** : capture vidéo simulator dans PR si UI change.
6. **Merge** : squash & merge sur `main`. CI verte obligatoire.

## Contact

- **Tech lead :** Dennis (`dennis@nextmove.app`)
- **Owner produit :** Eliot (`eliot@nextmove.app`)
- **Bug / question :** issue GitHub avec label approprié.

---

**Klaris** — une marque **Next Move** · 2026 · Confidentiel

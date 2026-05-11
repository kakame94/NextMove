# Klaris iOS — Flutter

Adjointe IA des courtiers immo, app iOS native (Cupertino widgets) sur fondations Flutter.

## Setup (avant le premier run)

```bash
# 1. Install Flutter (macOS)
brew install --cask flutter
flutter doctor   # corriger ce qui manque (Xcode, CocoaPods, etc.)

# 2. Dans ce dossier — generer iOS project (Xcode files)
cd klaris_ios
flutter create . --org ai.klarisapp --platforms=ios --project-name klaris_ios

# 3. Pull dependencies
flutter pub get

# 4. Configurer Supabase
cp lib/core/env.example.dart lib/core/env.dart
# Editer SUPABASE_URL + SUPABASE_ANON_KEY

# 5. Run (simulator iOS)
open -a Simulator
flutter run
```

## Structure

```
lib/
├── main.dart                 # entry, Supabase init, root CupertinoApp
├── core/
│   ├── theme/                # tokens OKLCH→Color, typography Geist
│   ├── i18n/                 # FR/EN strings
│   └── widgets/              # mascotte, heat indicator, cards reutilisables
├── data/
│   ├── models/               # Prospect, Conversation, Besoins
│   └── repositories/         # Supabase queries (RLS-respectful)
└── features/
    ├── auth/                 # login Cupertino
    ├── dashboard/            # shell CupertinoTabScaffold
    └── prospects/            # liste + detail + scoring temperature
```

## Architecture

- **State** : `flutter_riverpod` (immutable, testable, sans boilerplate)
- **Backend** : Supabase (`supabase_flutter`) — auth + Postgres + RLS
- **Routing** : `go_router` (deep-linking compatible push notifs)
- **Push** : `firebase_messaging` (notif lead chaud)
- **Local cache** : `drift` (Postgres-like, offline prospects)
- **Design tokens** : OKLCH source de vérité, conversion `oklab.dart` vers `Color`
- **Polices** : `google_fonts` → Geist + Geist Mono (alignement avec landing web)

## Aligement avec web

| Web (`klaris-presentation.html`) | iOS (`klaris_ios/`) |
|----------------------------------|---------------------|
| `--primary: oklch(0.55 0.18 30)` | `KlarisColors.primary` |
| Geist font | `GoogleFonts.getFont('Geist')` |
| Heat scale 5 niveaux | `HeatIndicator` widget |
| Mascotte robot SVG | `KlarisMascot` widget (CustomPainter) |
| FR/EN i18n data-attr | `KlarisStrings.of(context, key)` |

## Conformité

- **Loi 25** : Supabase ca-central-1, opt-in explicite à la 1ère connexion
- **OACIQ** : audit log (table `audit_log`) — chaque action trackee
- **Stockage local** : aucun PII en clair, drift chiffré (`sqlcipher`)

## Sprint 2 — livré

| Module | Fichiers | Sketch |
|--------|----------|--------|
| Conversations SMS | `features/conversations/*.dart` + `data/repositories/conversations_repository.dart` | Liste threads + thread plein écran avec bulles SMS, composer broker handover, mark-read auto, realtime stream Supabase |
| Relances J+2/J+5/J+10 | `features/relances/relances_list_screen.dart` + `data/repositories/relances_repository.dart` | Liste cards triées par échéance, badge step coloré, contenu pré-rédigé Klaris, boutons Envoyer/Passer (approval-required) |
| Settings | `features/settings/settings_screen.dart` | Theme system/light/dark + lang FR/EN persistés (SharedPreferences), opt-out Loi 25 (action sheet), data export, sign out |
| Push notif FCM | `core/services/push_service.dart` | Init Firebase + APNs token wait + sync `device_tokens` table + foreground banner Cupertino + deep-link payload |
| Cache offline drift | `data/local/klaris_db.dart` | Tables `cached_prospects` + `cached_messages`, schema v1, lazy-init, `wipeAll()` au sign-out |

## Sprint 2 — Supabase migrations

Avant le run, applique [`migrations/003_sprint2_klaris.sql`](migrations/003_sprint2_klaris.sql) dans Supabase :

```bash
psql "$SUPABASE_DB_URL" -f migrations/003_sprint2_klaris.sql
```

Crée :
- `conversations` (SMS thread) + view `conversation_summaries`
- `relances` (J+2/5/10 séquence) + view `relances_enriched`
- `device_tokens` (FCM push)
- `audit_log` (OACIQ traceability) + trigger `trg_relance_audit`
- RLS broker-scoped sur toutes les tables

## Sprint 2 — Firebase iOS setup

Push notif iOS demande config Firebase + APNs :

1. Créer projet Firebase → enregistrer Bundle ID iOS (ex: `ai.klarisapp.klaris_ios`)
2. Télécharger `GoogleService-Info.plist` → `ios/Runner/`
3. Apple Developer → activer Push Notifications + créer APNs key (`.p8`)
4. Firebase Console → Project Settings → Cloud Messaging → uploader la `.p8`
5. Xcode → `Runner` target → `Signing & Capabilities` → ajouter `Push Notifications` + `Background Modes` (Remote notifications)

## Sprint 2 — drift codegen

Après modif d'un schema drift :

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Crée `lib/data/local/klaris_db.g.dart` (généré, gitignored).

## Sprint 3 — livré

| Module | Fichiers | Sketch |
|--------|----------|--------|
| Briefing 7h30 | `supabase/functions/daily-briefing/index.ts` + `data/repositories/briefing_repository.dart` + `features/briefing/briefing_screen.dart` | Edge Function Deno scheduled cron, génère payload JSON par broker, persiste table `briefings`, envoi email via Resend. iOS pull dernier briefing + 4 KPI tiles + sections hot/new/relances |
| Création prospect | `features/prospects/create_prospect_screen.dart` | Multi-step 5 questions (nom → tel → type → secteur → budget+délai+pré-approuvé), progress bar, scoring auto inline (mêmes coefficients que web) |
| Filtres avancés | `features/prospects/prospect_filters_sheet.dart` + ext sur `prospects_repository.dart` | Modal sheet : type, secteur (ilike), budget min/max, délai (chips), pré-approuvé. Composé avec filter température. Badge dot quand actif |
| Stats courtier | `data/repositories/stats_repository.dart` + `features/stats/stats_screen.dart` + RPC `broker_stats_snapshot()` | 4 KPI tiles + bar chart 6 mois (CustomPainter, no chart lib), 3 séries (nouveaux/qualifiés/conclus) |
| Mode démo | `data/seed/demo_seed.dart` + override dans `main.dart` | 5 prospects + 10 messages + 3 relances seed. Override `prospectsProvider` quand `Env.demoMode=true`. Pour App Store screenshots et demo offline |
| Tests | `test/heat_indicator_test.dart`, `prospect_model_test.dart`, `relance_model_test.dart`, `prospects_repository_test.dart`, `i18n_test.dart` | flutter_test + mocktail. ~30 tests : color mapping, JSON parse, filter composition, i18n coverage |

## Sprint 3 — Supabase migrations

```bash
psql "$SUPABASE_DB_URL" -f migrations/004_sprint3_briefing_stats.sql
```

Crée :
- `briefings` (one row per broker per day, JSONB payload)
- Colonne `briefing_enabled` sur `courtiers`
- RPC `broker_stats_snapshot()` (RLS-aware, retourne snapshot complet pour iOS stats screen)

## Sprint 3 — Edge Function deploy

```bash
# Déploiement Edge Function
supabase functions deploy daily-briefing

# Cron 7h30 ET (= 11h30 UTC en heure d'été)
supabase functions schedule create daily-briefing --cron "30 11 * * *"

# Secrets
supabase secrets set RESEND_API_KEY=re_xxx
```

## Sprint 3 — run tests

```bash
flutter test
# Pour un seul fichier :
flutter test test/prospect_model_test.dart
```

## Sprint 4 — livré

| Module | Fichiers | Sketch |
|--------|----------|--------|
| Recherche full-text | `data/repositories/search_repository.dart` + `features/search/search_screen.dart` + RPC `search_prospects` (tsvector + GIN) | CupertinoSearchTextField, debounce 250ms, tsvector pondéré (nom A, secteur B, tel C, délai D), highlight in-line des matches, fallback ilike |
| Calendrier rendez-vous | `data/models/appointment.dart` + `appointments_repository.dart` + `features/calendar/calendar_screen.dart` + `create_appointment_screen.dart` | Strip 14 jours scrollable, day list, status colors, durations 30/60/90/120, picker date+heure 15min, sync iOS via EventKit MethodChannel |
| EventKit bridge iOS | `data/services/eventkit_service.dart` + `ios/Runner/EventKitBridge.swift` | MethodChannel `ai.klarisapp.klaris_ios/eventkit`, requestAccess + createEvent + removeEvent, alarm 15min avant, fallback gracieux si plugin absent |
| Voicemail intake | `supabase/functions/voicemail-intake/index.ts` | Twilio webhook → fetch recording → Whisper (fr) → Claude qualif (JSON strict) → upsert prospect + score + log conversation + audit_log |
| Templates SMS | `data/models/sms_template.dart` + `templates_repository.dart` + `features/templates/templates_screen.dart` | Liste avec uses counter, editor avec placeholders {nom}/{secteur}/{budget}/{courtier}, render method, RPC `increment_template_usage` |
| Agence multi-courtier | `data/models/agency.dart` + `agency_repository.dart` + `features/agency/agency_dashboard_screen.dart` + `lead_assign_sheet.dart` + RPC `agency_team_stats` | Tables `agencies` + `agency_members` + RLS broker/manager/admin, dashboard équipe (KPIs aggregé, perf par membre), reassign sheet modal |
| Rapport PDF mensuel | `supabase/functions/monthly-report/index.ts` | HTML template OKLCH-ed → Browserless.io PDF render → upload Storage `reports/{user}/{month}.pdf` → signed URL 24h |
| Tests intégration | `integration_test/login_flow_test.dart` + `prospects_flow_test.dart` + README | Login screen verify, lang FR/EN swap, auth error, prospects list filter, advanced filters sheet, search hint |
| Tests unit | +`appointment_test.dart` +`sms_template_test.dart` | Parsing, isPast/isToday, render avec placeholders K/M, edge cases |

## Sprint 4 — Supabase migrations

```bash
psql "$SUPABASE_DB_URL" -f migrations/005_sprint4_search_calendar_agency.sql
```

Crée :
- `prospects.search_vec` (tsvector généré, index GIN) + RPC `search_prospects(q)`
- `appointments` + RLS broker-scoped
- `sms_templates` + unique(courtier_id, shortcode) + RPC `increment_template_usage(id)`
- `agencies` + `agency_members` + RLS hiérarchique (admin > manager > broker)
- Colonnes `agency_id` + `assigned_at` sur prospects + policy update agency-admin
- RPC `agency_team_stats(agency_id)` (RLS-aware, agrégats par membre)

## Sprint 4 — Edge Functions deploy

```bash
# Voicemail intake
supabase functions deploy voicemail-intake
supabase secrets set OPENAI_API_KEY=sk-... ANTHROPIC_API_KEY=sk-... TWILIO_ACCOUNT_SID=AC... TWILIO_AUTH_TOKEN=... DEFAULT_COURTIER_ID=<uuid>
# Configurer Twilio Phone Numbers → Voice → Webhook URL = https://<project>.supabase.co/functions/v1/voicemail-intake

# Monthly report PDF
supabase functions deploy monthly-report
supabase secrets set BROWSERLESS_TOKEN=...
# Bucket Storage à créer:
# psql -c "insert into storage.buckets (id, name, public) values ('reports', 'reports', false);"
```

## Sprint 4 — EventKit setup iOS

1. Ouvrir `ios/Runner.xcworkspace` dans Xcode
2. Drag `ios/Runner/EventKitBridge.swift` dans le projet Runner (target Runner cocher)
3. `Info.plist` → ajouter clé `NSCalendarsWriteOnlyAccessUsageDescription` (iOS 17+) :
   ```xml
   <key>NSCalendarsWriteOnlyAccessUsageDescription</key>
   <string>Klaris ajoute tes rendez-vous prospects à ton agenda iOS.</string>
   ```
4. `AppDelegate.swift` → ajouter `EventKitBridge.register(with: controller)` après init du FlutterViewController

## Sprint 4 — run integration tests

```bash
# Setup test env (cf. integration_test/README.md)
flutter test integration_test/login_flow_test.dart
flutter test integration_test/  # all

# CI / driver mode
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/login_flow_test.dart \
  -d "iPhone 16 Pro"
```

## Sprint 5 — livré

| Module | Fichiers | Sketch |
|--------|----------|--------|
| Notifications locales | `core/services/notifications_service.dart` | flutter_local_notifications + timezone (America/Toronto), schedule reminder 15 min avant RDV, interruptionLevel.timeSensitive |
| Sync hors-ligne | drift `pending_mutations` table + `data/sync/sync_service.dart` | connectivity_plus listener, auto-drain on online, 5 attempts max, schemaVersion v2 migration |
| Carte prospects | `features/map/map_screen.dart` + `data/services/geocoding_service.dart` + `ios/Runner/GeocodingBridge.swift` | apple_maps_flutter (MapKit natif), pins par heat (red/orange/azure), bottom sheet on tap, CLGeocoder MethodChannel |
| Notes vocales | `data/models/voice_memo.dart` + `voice_memos_repository.dart` + `features/notes/voice_memo_sheet.dart` + `supabase/functions/transcribe-memo/index.ts` | record AAC 22kHz/64kbps → upload Storage `memos/` → Whisper FR + Claude Haiku summarize → table `voice_memos` ready/failed states |
| Centris listings | `supabase/functions/centris-sync/index.ts` + table `listings` | Cron 15min, MLS-DDF XML parser ou JSON feed, upsert batched 100 rows, scoped agency_id, RLS |
| Onboarding | `features/onboarding/onboarding_screen.dart` | 5 slides (mascotte + 4 features), PageView, dots indicator, SharedPreferences persistance, gate dans go_router redirect |
| A11y | `core/a11y/a11y_helpers.dart` | clampedTextScaler 1.6, A11yIconButton (44pt min tap), A11yHeatLabel ("Prospect chaud, score 8/10"), KlarisA11yShell wrapper, announce() polite |
| App Store metadata | `metadata/{fr-CA,en-CA}/{description,keywords,promotional_text}.txt` + `PRIVACY_LABELS.md` + `SCREENSHOTS.md` | Description FR + EN, keywords ASO, privacy nutrition labels (no tracking, Canada hosting), capture plan 8 frames |

## Sprint 5 — Supabase migrations

```bash
psql "$SUPABASE_DB_URL" -f migrations/006_sprint5_offline_voice_listings.sql
```

Crée :
- `voice_memos` (audio_path Storage, transcript, summary, status pending/transcribing/ready/failed)
- `listings` (Centris MLS, scoped agency, RLS member-readable)
- Colonnes `latitude/longitude/geocoded_at` sur prospects (index partiel)
- Colonne `onboarding_completed_at` sur courtiers

## Sprint 5 — Edge Functions deploy

```bash
# Voice memo transcription
supabase functions deploy transcribe-memo
# Storage bucket "memos" private, RLS broker-scoped:
psql -c "insert into storage.buckets (id, name, public) values ('memos', 'memos', false);"

# Centris sync (cron 15 min)
supabase functions deploy centris-sync
supabase secrets set CENTRIS_FEED_URL=https://feed.example.com CENTRIS_FEED_TOKEN=...
supabase functions schedule create centris-sync --cron "*/15 * * * *"
```

## Sprint 5 — iOS wiring

`ios/Runner/AppDelegate.swift` — register both bridges + permissions strings :

```swift
override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [...]?) -> Bool {
  let controller = window?.rootViewController as! FlutterViewController
  EventKitBridge.register(with: controller)
  GeocodingBridge.register(with: controller)
  GeneratedPluginRegistrant.register(with: self)
  return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
```

`Info.plist` strings (cf. `metadata/PRIVACY_LABELS.md`) :
- `NSCalendarsWriteOnlyAccessUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSLocationWhenInUseUsageDescription`

`Runner/Info.plist` activer aussi capability **Background Modes → Remote notifications** (déjà Sprint 2 push).

## Sprint 5 — App Store ship checklist

1. Bump version pubspec.yaml → `1.0.0+1`
2. `Env.demoMode = false` pour build prod
3. Capture screenshots (cf. `metadata/SCREENSHOTS.md`)
4. App Store Connect → Privacy → fill nutrition labels (cf. `metadata/PRIVACY_LABELS.md`)
5. Locale FR-CA primary, EN-CA secondary, copies depuis `metadata/{fr,en}-CA/`
6. Build `flutter build ipa --release --export-options-plist=ios/exportOptions.plist`
7. Upload via Transporter ou `xcrun altool --upload-app`

## Sprint 6 — livré

| Module | Fichiers | Sketch |
|--------|----------|--------|
| Apple Sign In | `data/services/apple_auth_service.dart` + login_screen update | sign_in_with_apple, SHA256 nonce, Supabase signInWithIdToken, bouton noir natif + divider OR |
| iOS Widget (WidgetKit) | `ios/KlarisWidget/{KlarisWidget.swift,Info.plist}` + `data/services/widget_data_service.dart` + `ios/Runner/WidgetBridge.swift` | 2 sizes (small/medium), App Group `group.ai.klarisapp.klaris_ios`, JSON snapshot, refresh 15min, hot count + top 3 leads |
| Apple Watch ⚠️ DEPRECATED | `ios/KlarisWatch/{KlarisWatchApp.swift,WatchSession.swift}` + `ios/Runner/WatchBridge.swift` + `data/services/watch_bridge_service.dart` | **[DEPRECATED — voir [feature-deprecations.md](../24_NextMove/docs/feature-deprecations.md) F-DEPRECATED-001]** Sunset Sprint 8-11. Réversible via branche `archive/apple-watch`. |
| Live Activities | `ios/Runner/AppointmentLiveActivity.swift` + `data/services/live_activity_service.dart` | ActivityKit iOS 16.1+, Lock Screen + Dynamic Island RDV en cours, MethodChannel start/update/end |
| Localization es-MX ⚠️ DEPRECATED | enum `KlarisLang.es` + `_es` override map dans klaris_strings.dart + segmented FR/EN/ES | **[DEPRECATED — voir [feature-deprecations.md](../24_NextMove/docs/feature-deprecations.md) F-DEPRECATED-002]** Sunset Sprint 8-11. Bilingue FR/EN reste seul officiellement supporté. |
| Performance | `core/perf/perf_helpers.dart` | PerfMonitor frame timing 16ms/8ms ProMotion, FastList sliver-based cacheExtent 600, FastRepaint, CollapsingBox |
| Sentry observability | `core/services/observability_service.dart` | SentryFlutter init, traces 20% + profiles 10%, beforeSend redaction phone/email, breadcrumb helpers |
| Linear feedback | `supabase/functions/linear-feedback/index.ts` + `features/feedback/feedback_sheet.dart` | GraphQL Linear API, 3 kinds (bug/feature/praise), reporter email + version + device tag, in-app sheet |
| Patrol E2E | `integration_test/patrol/auth_e2e.dart` | Native automator iOS, Apple Sign In sheet dismiss, microphone permission grant flow |
| Tests nouveaux | `test/i18n_es_fallback_test.dart` + `perf_helpers_test.dart` | ES fallback chain, FastList separator, CollapsingBox toggle |

## Sprint 6 — Edge Function deploy

```bash
supabase functions deploy linear-feedback
supabase secrets set LINEAR_API_KEY=lin_api_... LINEAR_TEAM_ID=...
```

## Sprint 6 — Xcode wiring (extensions)

1. **Widget extension** — Xcode → File → New → Target → Widget Extension → "KlarisWidget"
   - Copier `ios/KlarisWidget/KlarisWidget.swift` + Info.plist dans le target
   - Add App Group capability `group.ai.klarisapp.klaris_ios` sur **les deux** targets (Runner + KlarisWidget)
   - Bundle ID : `ai.klarisapp.klaris_ios.KlarisWidget`
2. **Watch app** — Xcode → File → New → Target → Watch App for iOS App → "KlarisWatch"
   - Drop `ios/KlarisWatch/*.swift`
   - Mode companion (pas d'install standalone)
   - Bundle ID : `ai.klarisapp.klaris_ios.watchapp`
3. **Live Activities** — Runner target → Signing & Capabilities → activer "Push Notifications" + "Background Modes" (Remote)
   - `Info.plist` → `NSSupportsLiveActivities = YES`
4. **AppDelegate.swift** — register all bridges:
   ```swift
   EventKitBridge.register(with: controller)
   GeocodingBridge.register(with: controller)
   WidgetBridge.register(with: controller)
   WatchBridge.register(with: controller)
   AppointmentLiveActivityBridge.register(with: controller)
   ```
5. **Sign in with Apple** — Runner target → Signing & Capabilities → ajouter "Sign in with Apple"
   - Supabase Authentication → Providers → Apple → Service ID + Team ID + key

## Sprint 6 — Patrol E2E

```bash
dart pub global activate patrol_cli
patrol bootstrap
patrol test --target=integration_test/patrol/auth_e2e.dart
# CI Firebase Test Lab :
gcloud firebase test ios run \
  --test ios/build/ios_integration.xcarchive \
  --device model=iphone16pro,version=18.0
```

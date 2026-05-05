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

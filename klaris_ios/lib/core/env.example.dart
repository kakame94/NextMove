/// Klaris — environment config example.
/// Copy to env.dart and fill before running.
abstract class Env {
  static const String supabaseUrl = 'https://xxxxxxxx.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';

  /// Hosted region badge shown in app footer.
  static const String supabaseRegion = 'ca-central-1';

  /// When true, swap Supabase calls with [DemoSeed] data — used for App Store
  /// screenshots, sales demos, and offline mode.
  static const bool demoMode = false;

  /// Sentry DSN. Leave empty in dev — observability bootstraps without
  /// Sentry but still runs the local perf monitor.
  static const String sentryDsn = '';

  /// Reported with Sentry events for release tracking. Should match
  /// pubspec.yaml `version`.
  static const String appVersion = '1.0.0';

  /// Optional — Linear API token for the in-app feedback sheet.
  static const String linearApiKey = '';
  static const String linearTeamId = '';
}

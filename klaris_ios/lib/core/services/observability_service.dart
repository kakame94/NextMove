import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../env.dart';
import '../perf/perf_helpers.dart';

/// Klaris observability bootstrap — Sentry crash reporting + perf monitor.
///
/// Wrap [main] with [Observability.run] instead of calling [runApp] directly:
///
/// ```dart
/// Future<void> main() => Observability.run(() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Supabase.initialize(...);
///   runApp(const ProviderScope(child: KlarisApp()));
/// });
/// ```
class Observability {
  Observability._();

  static Future<void> run(FutureOr<void> Function() body) async {
    if (Env.sentryDsn.isEmpty) {
      // No DSN configured — run without Sentry but still track perf locally.
      WidgetsFlutterBinding.ensureInitialized();
      PerfMonitor.instance.start();
      await body();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = Env.sentryDsn;
        options.environment = Env.demoMode ? 'demo' : 'production';
        options.release = 'klaris_ios@${Env.appVersion}';
        options.tracesSampleRate = 0.20;        // 20% performance sampling
        options.profilesSampleRate = 0.10;       // 10% of those get profiles
        options.attachScreenshot = false;        // never (PII risk)
        options.attachViewHierarchy = false;
        // Drop any event whose payload includes a phone or email — defence
        // in depth on top of redaction at the call site.
        options.beforeSend = (event, hint) async {
          final s = event.toJson().toString();
          if (RegExp(r'\d{3}-?\d{3}-?\d{4}').hasMatch(s)) return null;
          if (RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}').hasMatch(s)) return null;
          return event;
        };
      },
      appRunner: () async {
        PerfMonitor.instance.start();
        PerfMonitor.instance.onSlowFrame = (dur, fps) {
          Sentry.addBreadcrumb(Breadcrumb(
            category: 'perf',
            message: 'slow frame ${dur.inMilliseconds}ms (avg ${fps.toStringAsFixed(0)} fps)',
            level: SentryLevel.warning,
          ));
        };
        await body();
      },
    );
  }

  /// Manual breadcrumb — use for major user actions (sign-in, prospect created, ...).
  static void breadcrumb(String message, {String? category, Map<String, dynamic>? data}) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category ?? 'klaris',
      level: SentryLevel.info,
      data: data,
    ));
  }

  /// Manual exception capture for caught errors that aren't unhandled.
  static Future<void> captureError(Object error, StackTrace? stack, {String? hint}) async {
    await Sentry.captureException(error, stackTrace: stack, hint: hint == null ? null : Hint.withMap({'note': hint}));
  }
}

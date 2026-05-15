import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/a11y/a11y_helpers.dart';
import 'core/env.dart';
import 'core/services/notifications_service.dart';
import 'core/services/observability_service.dart';
import 'core/services/push_service.dart';
import 'core/theme/klaris_colors.dart';
import 'core/theme/theme_mode_provider.dart';
import 'data/repositories/prospects_repository.dart';
import 'data/seed/demo_seed.dart';
import 'data/sync/sync_service.dart';
import 'features/auth/login_screen.dart';
import 'features/calendar/calendar_screen.dart';
import 'features/calendar/create_appointment_screen.dart';
import 'features/conversations/conversation_thread_screen.dart';
import 'features/dashboard/dashboard_shell.dart';
import 'features/map/map_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/prospects/prospect_detail_screen.dart';
import 'features/search/search_screen.dart';
import 'features/splash/cadastre_splash_overlay.dart';

final _navKey = GlobalKey<NavigatorState>();

Future<void> main() => Observability.run(_main);

Future<void> _main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // FCM init runs after auth is restored — non-blocking.
  PushService.instance.init(navKey: _navKey).catchError((_) {/* non-fatal */});

  // Local notifications (appointment reminders).
  await LocalNotificationsService.instance.init();

  runApp(
    ProviderScope(
      overrides: Env.demoMode
          ? [
              prospectsProvider.overrideWith((_) async => DemoSeed.prospects),
            ]
          : const [],
      child: const KlarisApp(),
    ),
  );
}

class KlarisApp extends ConsumerWidget {
  const KlarisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = MediaQuery.platformBrightnessOf(context);
    final mode = ref.watch(themeModeProvider);
    final brightness = resolveBrightness(mode, platform);
    // Spin up the offline sync service (singleton; idempotent start).
    ref.watch(syncServiceProvider);

    return CupertinoApp.router(
      title: 'Klaris',
      theme: brightness == Brightness.dark ? KlarisColors.dark : KlarisColors.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (_, child) => KlarisA11yShell(
        child: CadastreSplashOverlay(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

/// go_router with auth-aware redirect + onboarding gate.
final _router = GoRouter(
  navigatorKey: _navKey,
  initialLocation: '/',
  refreshListenable: _AuthListenable(),
  redirect: (ctx, state) async {
    final session = Supabase.instance.client.auth.currentSession;
    final loggedIn = session != null;
    final isLogin = state.matchedLocation == '/login';
    final isOnboarding = state.matchedLocation == '/onboarding';

    if (!loggedIn && !isLogin) return '/login';
    if (loggedIn && isLogin) return '/';
    if (loggedIn && !isOnboarding && !(await OnboardingScreen.wasSeen())) {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (ctx, __) => OnboardingScreen(onDone: () => ctx.go('/')),
    ),
    GoRoute(path: '/',      builder: (_, __) => const DashboardShell()),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
    GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
    GoRoute(
      path: '/calendar/new',
      builder: (_, s) => CreateAppointmentScreen(defaultProspectId: s.uri.queryParameters['prospect']),
    ),
    GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
    GoRoute(
      path: '/prospects/:id',
      builder: (_, s) => ProspectDetailScreen(prospectId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/prospects/:id/thread',
      builder: (_, s) => ConversationThreadScreen(prospectId: s.pathParameters['id']!),
    ),
  ],
);

/// Bridges Supabase auth-state stream into a Listenable for go_router.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }
  late final dynamic _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

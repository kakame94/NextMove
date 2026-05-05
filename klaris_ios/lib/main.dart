import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/env.dart';
import 'core/theme/klaris_colors.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_shell.dart';
import 'features/prospects/prospect_detail_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // Lock to portrait on iPhone (tablet free).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const ProviderScope(child: KlarisApp()));
}

class KlarisApp extends ConsumerWidget {
  const KlarisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return CupertinoApp.router(
      title: 'Klaris',
      theme: brightness == Brightness.dark ? KlarisColors.dark : KlarisColors.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// go_router with auth-aware redirect.
final _router = GoRouter(
  initialLocation: '/',
  refreshListenable: _AuthListenable(),
  redirect: (ctx, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final loggedIn = session != null;
    final isLogin = state.matchedLocation == '/login';

    if (!loggedIn && !isLogin) return '/login';
    if (loggedIn && isLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/',      builder: (_, __) => const DashboardShell()),
    GoRoute(
      path: '/prospects/:id',
      builder: (_, s) => ProspectDetailScreen(prospectId: s.pathParameters['id']!),
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

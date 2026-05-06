import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Firebase Cloud Messaging — push notif lead chaud + relance reminder.
///
/// On iOS, FCM requires APNs token registration via Firebase. Configure in
/// Apple Developer + Firebase console before first run.
class PushService {
  PushService._();
  static final instance = PushService._();

  final _fcm = FirebaseMessaging.instance;
  String? _token;
  String? get token => _token;

  Future<void> init({required GlobalKey<NavigatorState> navKey}) async {
    await Firebase.initializeApp();

    // 1. Request iOS permission (provisional + alert + badge + sound)
    final settings = await _fcm.requestPermission(alert: true, badge: true, sound: true, provisional: false);
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // Operator left it off — push disabled gracefully.
      return;
    }

    // 2. Wait for APNs token (iOS only) before requesting FCM token.
    String? apns = await _fcm.getAPNSToken();
    var attempts = 0;
    while (apns == null && attempts < 5) {
      await Future.delayed(const Duration(seconds: 1));
      apns = await _fcm.getAPNSToken();
      attempts++;
    }

    // 3. Get FCM token + sync to Supabase.
    _token = await _fcm.getToken();
    if (_token != null) await _syncToken(_token!);
    _fcm.onTokenRefresh.listen(_syncToken);

    // 4. Foreground messages → in-app banner via showCupertinoModalPopup.
    FirebaseMessaging.onMessage.listen((m) => _showInAppBanner(navKey, m));

    // 5. Background tap → deep-link routing handled by go_router.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleDeepLink);
    final initial = await _fcm.getInitialMessage();
    if (initial != null) _handleDeepLink(initial);
  }

  Future<void> _syncToken(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from('device_tokens').upsert({
      'user_id': user.id,
      'token': token,
      'platform': 'ios',
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'token');
  }

  void _showInAppBanner(GlobalKey<NavigatorState> navKey, RemoteMessage m) {
    final ctx = navKey.currentContext;
    if (ctx == null) return;
    final n = m.notification;
    if (n == null) return;
    showCupertinoDialog<void>(
      context: ctx,
      builder: (_) => CupertinoAlertDialog(
        title: Text(n.title ?? 'Klaris'),
        content: Text(n.body ?? ''),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () { Navigator.of(ctx).pop(); _handleDeepLink(m); },
            child: const Text('Ouvrir'),
          ),
          CupertinoDialogAction(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Plus tard')),
        ],
      ),
    );
  }

  void _handleDeepLink(RemoteMessage m) {
    // Expected payload: {type: 'hot_lead'|'relance_due', prospect_id: '<uuid>'}
    // Routing handled by go_router in main.dart via push notif handler hook.
  }
}

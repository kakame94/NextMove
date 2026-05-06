import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications — appointment reminders + relance pings.
///
/// FCM (push from server) is handled separately by [PushService]. This
/// service handles strictly local-only scheduled notifications that don't
/// need a server round-trip.
class LocalNotificationsService {
  LocalNotificationsService._();
  static final instance = LocalNotificationsService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Toronto'));

    await _plugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false, // requested explicitly via [requestPermission]
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onTap,
    );
    _ready = true;
  }

  /// Returns true if the user granted permission.
  Future<bool> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios == null) return false;
    final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? false;
  }

  Future<void> scheduleAppointmentReminder({
    required String appointmentId,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    await init();
    final id = appointmentId.hashCode & 0x7FFFFFFF;
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledAt, tz.local),
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'klaris.appointment',
          threadIdentifier: 'klaris.appointments',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: 'appointment:$appointmentId',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAppointmentReminder(String appointmentId) async {
    await init();
    await _plugin.cancel(appointmentId.hashCode & 0x7FFFFFFF);
  }

  Future<List<PendingNotificationRequest>> pending() async {
    await init();
    return _plugin.pendingNotificationRequests();
  }

  static void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    if (kDebugMode) {
      debugPrint('Local notif tapped: $payload');
    }
    // TODO: route via go_router based on payload prefix.
  }
}

import 'package:flutter/services.dart';

import '../models/appointment.dart';

/// Live Activity for appointments — pinned to Lock Screen + Dynamic Island.
///
/// Use:
///   await LiveActivityService.instance.start(appointment);
///   // later, when appointment ends or broker manually completes:
///   await LiveActivityService.instance.end(appointment.id);
///
/// iOS 16.1+. On older OSes, calls return false silently.
class LiveActivityService {
  LiveActivityService._();
  static final instance = LiveActivityService._();

  static const _ch = MethodChannel('ai.klarisapp.klaris_ios/live_activity');

  Future<String?> start(Appointment a) async {
    try {
      return await _ch.invokeMethod<String>('start', {
        'appointmentId': a.id,
        'prospectName': a.prospectName ?? '—',
        'title': a.title,
        'endsAt': a.endsAt.millisecondsSinceEpoch ~/ 1000,
        'location': a.location,
      });
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> update(String appointmentId, {DateTime? endsAt, String? status}) async {
    try {
      final ok = await _ch.invokeMethod<bool>('update', {
        'appointmentId': appointmentId,
        if (endsAt != null) 'endsAt': endsAt.millisecondsSinceEpoch ~/ 1000,
        if (status != null) 'status': status,
      });
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> end(String appointmentId) async {
    try {
      final ok = await _ch.invokeMethod<bool>('end', {'appointmentId': appointmentId});
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}

import 'package:flutter/services.dart';

/// Bridge to iOS EventKit via MethodChannel.
///
/// Native side (Swift) lives in `ios/Runner/EventKitBridge.swift`.
/// Channel methods:
///   - requestAccess()              -> bool
///   - createEvent({title, notes, location, startTs, endTs}) -> String eventId
///   - removeEvent(eventId)         -> bool
///
/// Falls back gracefully when not implemented (early dev) — returns null.
class EventKitService {
  EventKitService._();
  static final instance = EventKitService._();

  static const _ch = MethodChannel('ai.klarisapp.klaris_ios/eventkit');

  Future<bool> requestAccess() async {
    try {
      final ok = await _ch.invokeMethod<bool>('requestAccess');
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Returns the EventKit event identifier on success, null on failure / when
  /// the bridge is not yet implemented.
  Future<String?> createEvent({
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    String? notes,
    String? location,
  }) async {
    try {
      return await _ch.invokeMethod<String>('createEvent', {
        'title': title,
        'notes': notes,
        'location': location,
        'startTs': startsAt.millisecondsSinceEpoch ~/ 1000,
        'endTs': endsAt.millisecondsSinceEpoch ~/ 1000,
      });
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> removeEvent(String ekitEventId) async {
    try {
      final ok = await _ch.invokeMethod<bool>('removeEvent', {'eventId': ekitEventId});
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}

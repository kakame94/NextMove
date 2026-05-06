import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/appointment.dart';
import '../models/prospect.dart';

/// Push hot-count + today's appointments to the paired Apple Watch.
class WatchBridgeService {
  WatchBridgeService._() {
    _ch.setMethodCallHandler(_onCall);
  }
  static final instance = WatchBridgeService._();

  static const _ch = MethodChannel('ai.klarisapp.klaris_ios/watch');

  /// Called by [WatchBridge.swift] when the user dictates a memo on the watch.
  ValueChanged<String>? onWatchMemo;

  Future<bool> pushSnapshot({required List<Prospect> prospects, required List<Appointment> todayAppts}) async {
    final hot = prospects.where((p) => p.score >= 7).length;
    final appts = todayAppts.map((a) => {
          'id': a.id,
          'title': a.title,
          'time': DateFormat('HH:mm').format(a.startsAt),
          'prospectName': a.prospectName,
        }).toList();
    try {
      final ok = await _ch.invokeMethod<bool>('pushSnapshot', {
        'hot': hot,
        'appointmentsJson': jsonEncode(appts),
      });
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('watch push err: $e');
      return false;
    }
  }

  Future<void> _onCall(MethodCall call) async {
    if (call.method == 'watchMemo') {
      final args = (call.arguments as Map?)?.cast<String, dynamic>();
      final text = args?['text'] as String?;
      if (text != null && text.isNotEmpty) {
        onWatchMemo?.call(text);
      }
    }
  }
}

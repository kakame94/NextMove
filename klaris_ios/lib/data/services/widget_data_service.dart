import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/prospect.dart';

/// Pushes a [WidgetSnapshot]-shaped JSON payload into the App Group
/// UserDefaults so the WidgetKit extension can read it.
///
/// Native side: writes via MethodChannel into
/// `UserDefaults(suiteName: "group.ai.klarisapp.klaris_ios")` under the
/// key `"klaris.widget.snapshot"`. Widget reads at next timeline refresh
/// (max 15 min lag).
class WidgetDataService {
  WidgetDataService._();
  static final instance = WidgetDataService._();

  static const _ch = MethodChannel('ai.klarisapp.klaris_ios/widget');

  Future<bool> push({required List<Prospect> prospects}) async {
    final hot = prospects.where((p) => p.score >= 7).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final payload = {
      'generatedAt': DateTime.now().toIso8601String(),
      'total': prospects.length,
      'hot': hot.length,
      'leads': hot.take(3).map((p) => {
            'id': p.id,
            'nom': p.nom,
            'score': p.score,
            'secteur': p.secteur,
          }).toList(),
    };

    try {
      final ok = await _ch.invokeMethod<bool>('write', {'json': jsonEncode(payload)});
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reload() async {
    try {
      final ok = await _ch.invokeMethod<bool>('reload');
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}

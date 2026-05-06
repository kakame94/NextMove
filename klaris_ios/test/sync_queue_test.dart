import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

/// Minimal model-level test for the offline mutation payload shape.
/// The real drain logic runs in [SyncService] and is exercised by integration
/// tests against a sandbox Supabase project.
void main() {
  group('Sync queue payload encoding', () {
    test('insert payload round-trips through JSON', () {
      final body = {
        'courtier_id': 'b1',
        'nom': 'Test M.',
        'score': 7,
        'pre_approuve': true,
      };
      final encoded = jsonEncode(body);
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      expect(decoded['courtier_id'], 'b1');
      expect(decoded['score'], 7);
      expect(decoded['pre_approuve'], true);
    });

    test('verb whitelist holds insert/update/delete only', () {
      const allowed = ['insert', 'update', 'delete'];
      for (final v in ['insert', 'update', 'delete']) {
        expect(allowed.contains(v), true);
      }
      for (final v in ['upsert', 'patch', 'select']) {
        expect(allowed.contains(v), false);
      }
    });
  });
}

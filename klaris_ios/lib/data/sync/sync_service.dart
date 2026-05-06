import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../local/klaris_db.dart';
import '../repositories/prospects_repository.dart';

/// Drains [PendingMutations] to Supabase when online.
///
/// Strategy:
///   - Listen to [Connectivity] stream.
///   - On any non-none result, call [drain].
///   - Each pending row is replayed via the appropriate Supabase verb.
///   - On success, delete the row. On error, increment attempts + store msg.
///   - 5 attempts = give up (manual review via Settings → Sync queue).
class SyncService {
  SyncService(this._db, this._client);
  final KlarisDb _db;
  final SupabaseClient _client;

  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _draining = false;

  void start() {
    _sub ??= Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        unawaited(drain());
      }
    });
    unawaited(drain());
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  Future<int> drain() async {
    if (_draining) return 0;
    _draining = true;
    var done = 0;
    try {
      final pending = await _db.pending();
      for (final m in pending) {
        if (m.attempts >= 5) continue;
        try {
          await _replay(m);
          await _db.dropMutation(m.id);
          done++;
        } catch (e) {
          await _db.markFailed(m.id, e.toString());
          if (kDebugMode) debugPrint('sync replay failed for ${m.id}: $e');
        }
      }
    } finally {
      _draining = false;
    }
    return done;
  }

  Future<void> _replay(PendingMutation m) async {
    final body = jsonDecode(m.payload) as Map<String, dynamic>;
    final t = _client.from(m.resource);
    switch (m.verb) {
      case 'insert':
        await t.insert(body);
      case 'update':
        if (m.resourceId == null) throw StateError('update needs resourceId');
        await t.update(body).eq('id', m.resourceId!);
      case 'delete':
        if (m.resourceId == null) throw StateError('delete needs resourceId');
        await t.delete().eq('id', m.resourceId!);
      default:
        throw UnsupportedError('verb ${m.verb}');
    }
  }

  /// Helper for repos to enqueue a write that may run offline.
  Future<void> enqueue({
    required String verb,
    required String resource,
    required Map<String, dynamic> payload,
    String? resourceId,
  }) async {
    final id = '${DateTime.now().microsecondsSinceEpoch}-${resource}-${verb}';
    await _db.enqueue(PendingMutationsCompanion(
      id: Value(id),
      verb: Value(verb),
      resource: Value(resource),
      resourceId: Value(resourceId),
      payload: Value(jsonEncode(payload)),
    ));
  }
}

final klarisDbProvider = Provider<KlarisDb>((ref) {
  final db = KlarisDb();
  ref.onDispose(db.close);
  return db;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final svc = SyncService(ref.watch(klarisDbProvider), ref.watch(supabaseClientProvider));
  svc.start();
  ref.onDispose(svc.stop);
  return svc;
});

/// Reactive count for the Settings badge.
final pendingMutationsCountProvider = StreamProvider.autoDispose<int>((ref) {
  final db = ref.watch(klarisDbProvider);
  return db.select(db.pendingMutations).watch().map((rows) => rows.length);
});

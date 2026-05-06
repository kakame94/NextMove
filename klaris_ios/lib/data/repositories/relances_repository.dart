import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/relance.dart';
import 'prospects_repository.dart';

class RelancesRepository {
  RelancesRepository(this._client);
  final SupabaseClient _client;

  /// Pending + awaiting-approval relances, ordered by due date.
  Future<List<Relance>> upcoming() async {
    final rows = await _client
        .from('relances')
        .select()
        .or('status.eq.pending,status.eq.awaiting_approval')
        .order('scheduled_for', ascending: true);
    return (rows as List).map((r) => Relance.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<List<Relance>> historyForProspect(String prospectId) async {
    final rows = await _client
        .from('relances')
        .select()
        .eq('prospect_id', prospectId)
        .order('scheduled_for', ascending: false);
    return (rows as List).map((r) => Relance.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<void> approve(String id) async {
    await _client.from('relances').update({
      'status': 'pending',
      'approved_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> skip(String id) async {
    await _client.from('relances').update({
      'status': 'skipped',
      'skipped_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> rewriteAndApprove({required String id, required String content}) async {
    await _client.from('relances').update({
      'content': content,
      'status': 'pending',
      'approved_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }
}

final relancesRepoProvider = Provider<RelancesRepository>(
  (ref) => RelancesRepository(ref.watch(supabaseClientProvider)),
);

final upcomingRelancesProvider = FutureProvider.autoDispose<List<Relance>>(
  (ref) => ref.watch(relancesRepoProvider).upcoming(),
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/prospects/prospect_filters_sheet.dart';
import '../models/prospect.dart';

/// Supabase-backed prospects repo. RLS enforces broker-only access.
class ProspectsRepository {
  ProspectsRepository(this._client);
  final SupabaseClient _client;

  Future<List<Prospect>> list({
    ProspectFilter filter = ProspectFilter.all,
    AdvancedFilter advanced = const AdvancedFilter(),
  }) async {
    var q = _client.from('prospects').select();

    switch (filter) {
      case ProspectFilter.hot:
        q = q.gte('score', 7);
      case ProspectFilter.warm:
        q = q.gte('score', 4).lt('score', 7);
      case ProspectFilter.cold:
        q = q.lt('score', 4);
      case ProspectFilter.all:
        break;
    }

    if (advanced.type != null) q = q.eq('type', advanced.type!.name);
    if (advanced.secteur != null && advanced.secteur!.isNotEmpty) {
      q = q.ilike('secteur', '%${advanced.secteur}%');
    }
    if (advanced.minBudget != null) q = q.gte('budget', advanced.minBudget!);
    if (advanced.maxBudget != null) q = q.lte('budget', advanced.maxBudget!);
    if (advanced.delai != null) q = q.eq('delai', advanced.delai!);
    if (advanced.preApprouve == true) q = q.eq('pre_approuve', true);

    final rows = await q.order('score', ascending: false).order('created_at', ascending: false);
    return (rows as List).map((r) => Prospect.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<Prospect> byId(String id) async {
    final row = await _client.from('prospects').select().eq('id', id).single();
    return Prospect.fromJson(row);
  }

  Stream<List<Prospect>> watchAll() {
    return _client
        .from('prospects')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows.map(Prospect.fromJson).toList());
  }
}

enum ProspectFilter { all, hot, warm, cold }

// Riverpod providers
final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final prospectsRepoProvider = Provider<ProspectsRepository>(
  (ref) => ProspectsRepository(ref.watch(supabaseClientProvider)),
);

final prospectsFilterProvider = StateProvider<ProspectFilter>((_) => ProspectFilter.all);

final prospectsProvider = FutureProvider.autoDispose<List<Prospect>>((ref) async {
  final repo = ref.watch(prospectsRepoProvider);
  final filter = ref.watch(prospectsFilterProvider);
  final advanced = ref.watch(advancedFilterProvider);
  return repo.list(filter: filter, advanced: advanced);
});

final prospectByIdProvider = FutureProvider.autoDispose.family<Prospect, String>((ref, id) {
  return ref.watch(prospectsRepoProvider).byId(id);
});

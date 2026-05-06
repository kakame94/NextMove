import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/prospect.dart';
import 'prospects_repository.dart';

/// Full-text search backed by Postgres tsvector + ilike fallback.
/// RPC `search_prospects` defined in migration 005.
class SearchRepository {
  SearchRepository(this._client);
  final SupabaseClient _client;

  Future<List<Prospect>> query(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return const [];
    final rows = await _client.rpc<List<dynamic>>('search_prospects', params: {'q': trimmed});
    return rows.map((r) => Prospect.fromJson((r as Map).cast<String, dynamic>())).toList();
  }
}

final searchRepoProvider = Provider<SearchRepository>(
  (ref) => SearchRepository(ref.watch(supabaseClientProvider)),
);

/// Debounced query state — read by [searchResultsProvider].
final searchQueryProvider = StateProvider<String>((_) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<Prospect>>((ref) async {
  final q = ref.watch(searchQueryProvider);
  if (q.trim().length < 2) return const [];
  // Debounce: wait 250ms before firing.
  await Future<void>.delayed(const Duration(milliseconds: 250));
  if (q != ref.read(searchQueryProvider)) {
    throw const _AbortedSearch();
  }
  return ref.watch(searchRepoProvider).query(q);
});

class _AbortedSearch implements Exception {
  const _AbortedSearch();
}

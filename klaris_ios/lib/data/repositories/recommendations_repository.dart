import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/recommendation.dart';

class RecommendationsRepository {
  final SupabaseClient _client;
  RecommendationsRepository(this._client);

  /// Calls the `recommend-listings` edge function. Server caches 24h.
  /// Set [force] to true to bust the cache (e.g. user pulls to refresh).
  Future<List<Recommendation>> fetch(String prospectId, {bool force = false}) async {
    final res = await _client.functions.invoke(
      'recommend-listings',
      body: {'prospect_id': prospectId, 'force': force},
    );
    if (res.status != 200) {
      throw Exception('recommend-listings failed: HTTP ${res.status}');
    }
    final data = res.data as Map<String, dynamic>;
    final raw = (data['recommendations'] as List?) ?? const [];
    if (raw.isEmpty) return const [];

    // Hydrate listing details for display.
    final listingIds = raw.map((r) => (r as Map)['listing_id'] as String).toList();
    final listingsRaw = await _client
        .from('listings')
        .select('id, type, city, price, bedrooms, bathrooms, address, centris_url')
        .inFilter('id', listingIds);
    final byId = <String, Map<String, dynamic>>{
      for (final l in (listingsRaw as List).cast<Map<String, dynamic>>()) l['id'] as String: l,
    };

    final out = <Recommendation>[];
    for (final r in raw) {
      final m = (r as Map).cast<String, dynamic>();
      final l = byId[m['listing_id'] as String];
      out.add(Recommendation(
        listingId: m['listing_id'] as String,
        rank: (m['rank'] as num?)?.toInt() ?? 0,
        score: (m['score'] as num?)?.toInt() ?? 0,
        reason: (m['reason'] as String?) ?? '',
        generatedAt: DateTime.tryParse(m['generated_at'] as String? ?? '') ?? DateTime.now(),
        listingType: l?['type'] as String?,
        listingCity: l?['city'] as String?,
        listingPrice: (l?['price'] as num?)?.toInt(),
        listingBedrooms: (l?['bedrooms'] as num?)?.toInt(),
        listingBathrooms: (l?['bathrooms'] as num?)?.toInt(),
        listingAddress: l?['address'] as String?,
        listingCentrisUrl: l?['centris_url'] as String?,
      ));
    }
    out.sort((a, b) => a.rank.compareTo(b.rank));
    return out;
  }
}

final recommendationsRepositoryProvider = Provider<RecommendationsRepository>(
  (ref) => RecommendationsRepository(Supabase.instance.client),
);

final recommendationsProvider = FutureProvider.autoDispose
    .family<List<Recommendation>, String>(
  (ref, prospectId) =>
      ref.read(recommendationsRepositoryProvider).fetch(prospectId),
);

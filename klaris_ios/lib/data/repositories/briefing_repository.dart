import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/briefing.dart';
import 'prospects_repository.dart';

class BriefingRepository {
  BriefingRepository(this._client);
  final SupabaseClient _client;

  /// Latest briefing for the current broker (auto-RLS scoped).
  Future<Briefing?> latest() async {
    final row = await _client
        .from('briefings')
        .select('payload')
        .order('generated_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return Briefing.fromJson((row['payload'] as Map).cast<String, dynamic>());
  }

  /// On-demand regenerate (calls Edge Function).
  Future<Briefing> regenerate() async {
    final res = await _client.functions.invoke('daily-briefing-on-demand');
    if (res.status >= 400) throw Exception('Briefing regen failed: ${res.status}');
    return Briefing.fromJson((res.data as Map).cast<String, dynamic>());
  }
}

final briefingRepoProvider = Provider<BriefingRepository>(
  (ref) => BriefingRepository(ref.watch(supabaseClientProvider)),
);

final latestBriefingProvider = FutureProvider.autoDispose<Briefing?>(
  (ref) => ref.watch(briefingRepoProvider).latest(),
);

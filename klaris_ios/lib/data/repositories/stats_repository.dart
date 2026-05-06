import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'prospects_repository.dart';

/// Activity over the past 6 months — bucket per ISO month.
class ActivityPoint {
  final DateTime month;       // first of month
  final int newLeads;
  final int qualified;
  final int closed;
  const ActivityPoint({required this.month, required this.newLeads, required this.qualified, required this.closed});
}

class StatsSnapshot {
  final List<ActivityPoint> last6Months;
  final int totalProspects;
  final int hotProspects;
  final double avgScore;
  final int conversionRate;   // % qualified → closed

  const StatsSnapshot({
    required this.last6Months,
    required this.totalProspects,
    required this.hotProspects,
    required this.avgScore,
    required this.conversionRate,
  });
}

class StatsRepository {
  StatsRepository(this._client);
  final SupabaseClient _client;

  Future<StatsSnapshot> snapshot() async {
    // Backed by Postgres function `broker_stats_snapshot()` (see migration 004).
    final res = await _client.rpc<Map<String, dynamic>>('broker_stats_snapshot');
    final monthly = (res['monthly'] as List? ?? []).map((m) {
      final mm = (m as Map).cast<String, dynamic>();
      return ActivityPoint(
        month: DateTime.parse(mm['month'] as String),
        newLeads: (mm['new_leads'] as num?)?.toInt() ?? 0,
        qualified: (mm['qualified'] as num?)?.toInt() ?? 0,
        closed: (mm['closed'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return StatsSnapshot(
      last6Months: monthly,
      totalProspects: (res['total_prospects'] as num?)?.toInt() ?? 0,
      hotProspects: (res['hot_prospects'] as num?)?.toInt() ?? 0,
      avgScore: ((res['avg_score'] as num?) ?? 0).toDouble(),
      conversionRate: (res['conversion_rate'] as num?)?.toInt() ?? 0,
    );
  }
}

final statsRepoProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(supabaseClientProvider)),
);

final statsProvider = FutureProvider.autoDispose<StatsSnapshot>(
  (ref) => ref.watch(statsRepoProvider).snapshot(),
);

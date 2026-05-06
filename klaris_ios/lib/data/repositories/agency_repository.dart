import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/agency.dart';
import 'prospects_repository.dart';

class AgencyRepository {
  AgencyRepository(this._client);
  final SupabaseClient _client;

  /// Returns the broker's home agency (first row from `agency_members` for current user).
  Future<({Agency agency, AgencyRole role})?> myAgency() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('agency_members')
        .select('role, agencies!inner(*)')
        .eq('user_id', user.id)
        .maybeSingle();
    if (row == null) return null;
    final agency = Agency.fromJson(((row['agencies'] as Map).cast<String, dynamic>()));
    final role = switch (row['role'] as String?) {
      'admin'   => AgencyRole.admin,
      'manager' => AgencyRole.manager,
      _         => AgencyRole.broker,
    };
    return (agency: agency, role: role);
  }

  Future<List<AgencyMember>> teamStats(String agencyId) async {
    final rows = await _client.rpc<List<dynamic>>('agency_team_stats', params: {'p_agency_id': agencyId});
    return rows.map((r) => AgencyMember.fromJson((r as Map).cast<String, dynamic>())).toList();
  }

  Future<void> reassignProspect({required String prospectId, required String toUserId}) async {
    await _client.from('prospects').update({
      'courtier_id': toUserId,
      'assigned_at': DateTime.now().toIso8601String(),
    }).eq('id', prospectId);
  }
}

final agencyRepoProvider = Provider<AgencyRepository>(
  (ref) => AgencyRepository(ref.watch(supabaseClientProvider)),
);

final myAgencyProvider = FutureProvider.autoDispose<({Agency agency, AgencyRole role})?>(
  (ref) => ref.watch(agencyRepoProvider).myAgency(),
);

final agencyTeamProvider = FutureProvider.autoDispose.family<List<AgencyMember>, String>(
  (ref, agencyId) => ref.watch(agencyRepoProvider).teamStats(agencyId),
);

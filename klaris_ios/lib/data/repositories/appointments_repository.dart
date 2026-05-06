import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/appointment.dart';
import 'prospects_repository.dart';

class AppointmentsRepository {
  AppointmentsRepository(this._client);
  final SupabaseClient _client;

  Future<List<Appointment>> upcoming() async {
    final rows = await _client
        .from('appointments')
        .select('*, prospects!inner(nom)')
        .gte('ends_at', DateTime.now().toIso8601String())
        .order('starts_at', ascending: true);
    return _expand(rows as List);
  }

  Future<List<Appointment>> forDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await _client
        .from('appointments')
        .select('*, prospects!inner(nom)')
        .gte('starts_at', start.toIso8601String())
        .lt('starts_at', end.toIso8601String())
        .order('starts_at', ascending: true);
    return _expand(rows as List);
  }

  List<Appointment> _expand(List rows) => rows.map((r) {
        final m = (r as Map).cast<String, dynamic>();
        m['prospect_name'] = ((m['prospects'] as Map?)?['nom']) as String?;
        return Appointment.fromJson(m);
      }).toList();

  Future<Appointment> create({
    required String prospectId,
    required String title,
    required DateTime startsAt,
    required DateTime endsAt,
    String? notes,
    String? location,
    String? ekitEventId,
  }) async {
    final user = _client.auth.currentUser!;
    final row = await _client.from('appointments').insert({
      'prospect_id': prospectId,
      'courtier_id': user.id,
      'title': title,
      'notes': notes,
      'location': location,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt.toIso8601String(),
      'ekit_event_id': ekitEventId,
    }).select('*, prospects!inner(nom)').single();
    final m = (row as Map).cast<String, dynamic>();
    m['prospect_name'] = ((m['prospects'] as Map?)?['nom']) as String?;
    return Appointment.fromJson(m);
  }

  Future<void> updateStatus(String id, AppointmentStatus status) async {
    await _client.from('appointments').update({'status': status.name.replaceAll('noShow', 'no_show')}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('appointments').delete().eq('id', id);
  }
}

final appointmentsRepoProvider = Provider<AppointmentsRepository>(
  (ref) => AppointmentsRepository(ref.watch(supabaseClientProvider)),
);

final upcomingAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>(
  (ref) => ref.watch(appointmentsRepoProvider).upcoming(),
);

final selectedDayProvider = StateProvider<DateTime>((_) => DateTime.now());

final dayAppointmentsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) {
  return ref.watch(appointmentsRepoProvider).forDay(ref.watch(selectedDayProvider));
});

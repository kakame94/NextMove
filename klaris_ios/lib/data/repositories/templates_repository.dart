import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sms_template.dart';
import 'prospects_repository.dart';

class TemplatesRepository {
  TemplatesRepository(this._client);
  final SupabaseClient _client;

  Future<List<SmsTemplate>> list() async {
    final rows = await _client
        .from('sms_templates')
        .select()
        .order('uses', ascending: false)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => SmsTemplate.fromJson(r as Map<String, dynamic>)).toList();
  }

  Future<SmsTemplate> create({required String shortcode, required String label, required String body}) async {
    final user = _client.auth.currentUser!;
    final row = await _client.from('sms_templates').insert({
      'courtier_id': user.id,
      'shortcode': shortcode.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_'),
      'label': label.trim(),
      'body': body.trim(),
    }).select().single();
    return SmsTemplate.fromJson(row);
  }

  Future<void> update({required String id, String? label, String? body}) async {
    final patch = <String, dynamic>{};
    if (label != null) patch['label'] = label.trim();
    if (body != null) patch['body'] = body.trim();
    if (patch.isEmpty) return;
    await _client.from('sms_templates').update(patch).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from('sms_templates').delete().eq('id', id);
  }

  /// Increment usage counter — call after broker inserts template into composer.
  Future<void> bumpUsage(String id) async {
    await _client.rpc<void>('increment_template_usage', params: {'p_id': id});
  }
}

final templatesRepoProvider = Provider<TemplatesRepository>(
  (ref) => TemplatesRepository(ref.watch(supabaseClientProvider)),
);

final templatesListProvider = FutureProvider.autoDispose<List<SmsTemplate>>(
  (ref) => ref.watch(templatesRepoProvider).list(),
);

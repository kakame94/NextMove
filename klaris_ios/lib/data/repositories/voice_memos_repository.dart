import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/voice_memo.dart';
import 'prospects_repository.dart';

class VoiceMemosRepository {
  VoiceMemosRepository(this._client);
  final SupabaseClient _client;

  Future<List<VoiceMemo>> recent({String? prospectId, int limit = 50}) async {
    var q = _client.from('voice_memos').select();
    if (prospectId != null) q = q.eq('prospect_id', prospectId);
    final rows = await q.order('created_at', ascending: false).limit(limit);
    return (rows as List).map((r) => VoiceMemo.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Upload + insert + trigger transcription Edge Function. Returns the row id.
  Future<String> upload({
    required File audioFile,
    required int durationSeconds,
    String? prospectId,
  }) async {
    final user = _client.auth.currentUser!;
    final filename = '${DateTime.now().millisecondsSinceEpoch}.m4a';
    final path = '${user.id}/$filename';

    await _client.storage.from('memos').upload(path, audioFile);

    final inserted = await _client.from('voice_memos').insert({
      'courtier_id': user.id,
      'prospect_id': prospectId,
      'duration_seconds': durationSeconds,
      'audio_path': path,
      'status': 'transcribing',
    }).select('id').single();
    final id = inserted['id'] as String;

    // Fire-and-forget trigger; the Edge Function persists transcript + summary.
    unawaited(_client.functions.invoke('transcribe-memo', body: {'memo_id': id}));
    return id;
  }
}

final voiceMemosRepoProvider = Provider<VoiceMemosRepository>(
  (ref) => VoiceMemosRepository(ref.watch(supabaseClientProvider)),
);

final memosListProvider = FutureProvider.autoDispose.family<List<VoiceMemo>, String?>(
  (ref, prospectId) => ref.watch(voiceMemosRepoProvider).recent(prospectId: prospectId),
);

void unawaited(Future<dynamic> _) {}

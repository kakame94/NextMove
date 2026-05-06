import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/conversation.dart';
import 'prospects_repository.dart';

class ConversationsRepository {
  ConversationsRepository(this._client);
  final SupabaseClient _client;

  /// List of conversation summaries — one row per prospect with last message.
  /// Backed by Postgres view `conversation_summaries` (broker-scoped via RLS).
  Future<List<ConversationSummary>> summaries() async {
    final rows = await _client
        .from('conversation_summaries')
        .select()
        .order('last_sent_at', ascending: false);
    return (rows as List)
        .map((r) => ConversationSummary.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Full message thread for one prospect.
  Future<List<Message>> thread(String prospectId) async {
    final rows = await _client
        .from('conversations')
        .select()
        .eq('prospect_id', prospectId)
        .order('sent_at', ascending: true);
    return (rows as List).map((r) => Message.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Realtime stream for the open thread.
  Stream<List<Message>> watchThread(String prospectId) {
    return _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .eq('prospect_id', prospectId)
        .order('sent_at', ascending: true)
        .map((rows) => rows.map(Message.fromJson).toList());
  }

  /// Broker-typed message — Klaris steps aside, courtier takes over.
  Future<void> sendAsBroker({required String prospectId, required String content}) async {
    await _client.from('conversations').insert({
      'prospect_id': prospectId,
      'direction': 'outbound',
      'sender': 'broker',
      'content': content,
      'sent_at': DateTime.now().toIso8601String(),
      'read_by_broker': true,
    });
  }

  Future<void> markRead(String prospectId) async {
    await _client
        .from('conversations')
        .update({'read_by_broker': true})
        .eq('prospect_id', prospectId)
        .eq('read_by_broker', false);
  }
}

final conversationsRepoProvider = Provider<ConversationsRepository>(
  (ref) => ConversationsRepository(ref.watch(supabaseClientProvider)),
);

final conversationSummariesProvider = FutureProvider.autoDispose<List<ConversationSummary>>(
  (ref) => ref.watch(conversationsRepoProvider).summaries(),
);

final conversationThreadProvider = StreamProvider.autoDispose.family<List<Message>, String>(
  (ref, prospectId) => ref.watch(conversationsRepoProvider).watchThread(prospectId),
);

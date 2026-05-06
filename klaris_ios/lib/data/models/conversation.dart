/// Conversation message — mirror du schema `conversations` Supabase.
class Message {
  final String id;
  final String prospectId;
  final MessageDirection direction;
  final MessageSender sender;
  final String content;
  final DateTime sentAt;
  final bool readByBroker;

  const Message({
    required this.id,
    required this.prospectId,
    required this.direction,
    required this.sender,
    required this.content,
    required this.sentAt,
    this.readByBroker = false,
  });

  factory Message.fromJson(Map<String, dynamic> j) => Message(
        id: j['id'] as String,
        prospectId: j['prospect_id'] as String,
        direction: _parseDir(j['direction'] as String?) ?? MessageDirection.inbound,
        sender: _parseSender(j['sender'] as String?) ?? MessageSender.prospect,
        content: j['content'] as String? ?? '',
        sentAt: DateTime.parse(j['sent_at'] as String),
        readByBroker: (j['read_by_broker'] as bool?) ?? false,
      );

  bool get isFromProspect => direction == MessageDirection.inbound;
  bool get isFromKlaris   => direction == MessageDirection.outbound && sender == MessageSender.klaris;
  bool get isFromBroker   => direction == MessageDirection.outbound && sender == MessageSender.broker;
}

enum MessageDirection { inbound, outbound }
enum MessageSender { prospect, klaris, broker }

MessageDirection? _parseDir(String? s) => switch (s) {
      'inbound'  => MessageDirection.inbound,
      'outbound' => MessageDirection.outbound,
      _ => null,
    };

MessageSender? _parseSender(String? s) => switch (s) {
      'prospect' => MessageSender.prospect,
      'klaris'   => MessageSender.klaris,
      'broker'   => MessageSender.broker,
      _ => null,
    };

/// Conversation summary — for the list view.
class ConversationSummary {
  final String prospectId;
  final String? prospectName;
  final String? lastMessage;
  final DateTime? lastSentAt;
  final int unreadCount;
  final int prospectScore;

  const ConversationSummary({
    required this.prospectId,
    required this.unreadCount,
    required this.prospectScore,
    this.prospectName,
    this.lastMessage,
    this.lastSentAt,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> j) => ConversationSummary(
        prospectId: j['prospect_id'] as String,
        prospectName: j['prospect_name'] as String?,
        lastMessage: j['last_message'] as String?,
        lastSentAt: j['last_sent_at'] != null ? DateTime.parse(j['last_sent_at'] as String) : null,
        unreadCount: (j['unread_count'] as num?)?.toInt() ?? 0,
        prospectScore: (j['prospect_score'] as num?)?.toInt() ?? 0,
      );
}

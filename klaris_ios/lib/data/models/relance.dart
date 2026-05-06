/// Relance scheduled — mirror du schema `relances` Supabase.
class Relance {
  final String id;
  final String prospectId;
  final String? prospectName;
  final int prospectScore;
  final RelanceStep step;
  final RelanceStatus status;
  final DateTime scheduledFor;
  final String? content;        // Klaris-drafted SMS preview
  final DateTime? sentAt;
  final DateTime createdAt;

  const Relance({
    required this.id,
    required this.prospectId,
    required this.prospectScore,
    required this.step,
    required this.status,
    required this.scheduledFor,
    required this.createdAt,
    this.prospectName,
    this.content,
    this.sentAt,
  });

  factory Relance.fromJson(Map<String, dynamic> j) => Relance(
        id: j['id'] as String,
        prospectId: j['prospect_id'] as String,
        prospectName: j['prospect_name'] as String?,
        prospectScore: (j['prospect_score'] as num?)?.toInt() ?? 0,
        step: _parseStep(j['step'] as String?) ?? RelanceStep.j2,
        status: _parseStatus(j['status'] as String?) ?? RelanceStatus.pending,
        scheduledFor: DateTime.parse(j['scheduled_for'] as String),
        content: j['content'] as String?,
        sentAt: j['sent_at'] != null ? DateTime.parse(j['sent_at'] as String) : null,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  /// Hours until the scheduled time (negative = overdue).
  Duration get untilDue => scheduledFor.difference(DateTime.now());
  bool get isOverdue => untilDue.isNegative && status == RelanceStatus.pending;
}

/// J+2, J+5, J+10 sequence as per spec.
enum RelanceStep { j2, j5, j10 }

extension RelanceStepX on RelanceStep {
  String get label => switch (this) {
        RelanceStep.j2 => 'J+2',
        RelanceStep.j5 => 'J+5',
        RelanceStep.j10 => 'J+10',
      };
}

enum RelanceStatus { pending, awaitingApproval, sent, skipped, stopped }

RelanceStep? _parseStep(String? s) => switch (s) {
      'j2' => RelanceStep.j2,
      'j5' => RelanceStep.j5,
      'j10' => RelanceStep.j10,
      _ => null,
    };

RelanceStatus? _parseStatus(String? s) => switch (s) {
      'pending'            => RelanceStatus.pending,
      'awaiting_approval'  => RelanceStatus.awaitingApproval,
      'sent'               => RelanceStatus.sent,
      'skipped'            => RelanceStatus.skipped,
      'stopped'            => RelanceStatus.stopped,
      _ => null,
    };

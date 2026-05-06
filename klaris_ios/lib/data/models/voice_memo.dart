class VoiceMemo {
  final String id;
  final String? prospectId;
  final String courtierId;
  final int durationSeconds;
  final String? audioPath;
  final String? transcript;
  final String? summary;
  final VoiceMemoStatus status;
  final DateTime createdAt;

  const VoiceMemo({
    required this.id,
    required this.courtierId,
    required this.durationSeconds,
    required this.status,
    required this.createdAt,
    this.prospectId,
    this.audioPath,
    this.transcript,
    this.summary,
  });

  factory VoiceMemo.fromJson(Map<String, dynamic> j) => VoiceMemo(
        id: j['id'] as String,
        prospectId: j['prospect_id'] as String?,
        courtierId: j['courtier_id'] as String,
        durationSeconds: (j['duration_seconds'] as num?)?.toInt() ?? 0,
        audioPath: j['audio_path'] as String?,
        transcript: j['transcript'] as String?,
        summary: j['summary'] as String?,
        status: switch (j['status'] as String?) {
          'pending'      => VoiceMemoStatus.pending,
          'transcribing' => VoiceMemoStatus.transcribing,
          'ready'        => VoiceMemoStatus.ready,
          'failed'       => VoiceMemoStatus.failed,
          _              => VoiceMemoStatus.pending,
        },
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

enum VoiceMemoStatus { pending, transcribing, ready, failed }

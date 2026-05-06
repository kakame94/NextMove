import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/data/models/voice_memo.dart';

void main() {
  group('VoiceMemo.fromJson', () {
    test('parses ready memo with transcript and summary', () {
      final m = VoiceMemo.fromJson({
        'id': 'm1', 'courtier_id': 'b1', 'prospect_id': 'p1',
        'duration_seconds': 42,
        'audio_path': 'b1/abc.m4a',
        'transcript': 'Visite réussie, le client adore...',
        'summary': 'Client très intéressé.',
        'status': 'ready',
        'created_at': '2026-05-05T10:00:00Z',
      });
      expect(m.status, VoiceMemoStatus.ready);
      expect(m.durationSeconds, 42);
      expect(m.summary, 'Client très intéressé.');
    });

    test('falls back to pending status on unknown value', () {
      final m = VoiceMemo.fromJson({
        'id': 'm1', 'courtier_id': 'b1',
        'duration_seconds': 0,
        'status': 'spaceship',
        'created_at': '2026-05-05T10:00:00Z',
      });
      expect(m.status, VoiceMemoStatus.pending);
    });

    test('handles missing optional fields', () {
      final m = VoiceMemo.fromJson({
        'id': 'm1', 'courtier_id': 'b1',
        'duration_seconds': 0,
        'created_at': '2026-05-05T10:00:00Z',
      });
      expect(m.transcript, isNull);
      expect(m.audioPath, isNull);
      expect(m.prospectId, isNull);
    });
  });
}

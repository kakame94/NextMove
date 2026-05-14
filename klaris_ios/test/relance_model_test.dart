import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/data/models/relance.dart';

void main() {
  group('Relance', () {
    test('isOverdue reflects past schedule with pending status', () {
      final r = Relance(
        id: 'r', prospectId: 'p', prospectScore: 5,
        step: RelanceStep.j2, status: RelanceStatus.pending,
        scheduledFor: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(r.isOverdue, true);
    });

    test('isOverdue is false when already sent', () {
      final r = Relance(
        id: 'r', prospectId: 'p', prospectScore: 5,
        step: RelanceStep.j2, status: RelanceStatus.sent,
        scheduledFor: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(r.isOverdue, false);
    });

    test('step labels — spec v1.1 (j2 + j5 only)', () {
      expect(RelanceStep.j2.label, 'J+2');
      expect(RelanceStep.j5.label, 'J+5');
      expect(
        RelanceStep.values.length,
        2,
        reason: 'j10 retired post-Figma — should be exactly 2 steps',
      );
    });

    test('parses Supabase row', () {
      final r = Relance.fromJson({
        'id': 'r1',
        'prospect_id': 'p1',
        'prospect_name': 'M. Tremblay',
        'prospect_score': 8,
        'step': 'j5',
        'status': 'awaiting_approval',
        'scheduled_for': '2026-05-05T14:00:00Z',
        'created_at': '2026-05-03T10:00:00Z',
        'content': 'Bonjour...',
      });
      expect(r.step, RelanceStep.j5);
      expect(r.status, RelanceStatus.awaitingApproval);
      expect(r.prospectName, 'M. Tremblay');
      expect(r.content, 'Bonjour...');
    });

    test('legacy "j10" step in Supabase row falls back to default j2', () {
      // Defensive: if old rows still exist with step='j10', parser must not crash.
      final r = Relance.fromJson({
        'id': 'r2',
        'prospect_id': 'p2',
        'prospect_score': 4,
        'step': 'j10',
        'status': 'pending',
        'scheduled_for': '2026-05-10T14:00:00Z',
        'created_at': '2026-05-01T10:00:00Z',
      });
      expect(
        r.step,
        RelanceStep.j2,
        reason: 'Unknown step must fallback to j2 — see Relance.fromJson',
      );
    });
  });
}

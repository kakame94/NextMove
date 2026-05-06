import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/data/models/appointment.dart';

void main() {
  Appointment mk({
    DateTime? start,
    DateTime? end,
    AppointmentStatus status = AppointmentStatus.scheduled,
  }) => Appointment(
        id: 'a1', prospectId: 'p1', courtierId: 'b1',
        title: 'Visite', startsAt: start ?? DateTime.now().add(const Duration(hours: 1)),
        endsAt: end ?? DateTime.now().add(const Duration(hours: 2)),
        status: status, createdAt: DateTime.now(),
      );

  group('Appointment', () {
    test('duration is end minus start', () {
      final a = mk(start: DateTime(2026, 5, 5, 14), end: DateTime(2026, 5, 5, 15));
      expect(a.duration, const Duration(hours: 1));
    });

    test('isPast when end is in the past', () {
      expect(mk(start: DateTime(2020, 1, 1), end: DateTime(2020, 1, 2)).isPast, true);
      expect(mk().isPast, false);
    });

    test('isToday when start matches today calendar day', () {
      final today = DateTime.now();
      final a = mk(start: DateTime(today.year, today.month, today.day, 18, 0));
      expect(a.isToday, true);
    });

    test('parses Supabase row', () {
      final a = Appointment.fromJson({
        'id': 'a1', 'prospect_id': 'p1', 'courtier_id': 'b1',
        'title': 'Visite duplex',
        'starts_at': '2026-05-05T14:00:00Z',
        'ends_at':   '2026-05-05T15:00:00Z',
        'status': 'scheduled',
        'created_at': '2026-05-04T10:00:00Z',
        'ekit_event_id': 'EK-123',
      });
      expect(a.title, 'Visite duplex');
      expect(a.status, AppointmentStatus.scheduled);
      expect(a.ekitEventId, 'EK-123');
    });
  });
}

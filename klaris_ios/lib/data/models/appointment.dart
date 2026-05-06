/// Appointment — broker rendezvous with prospect.
class Appointment {
  final String id;
  final String prospectId;
  final String? prospectName;
  final String courtierId;
  final String title;
  final String? notes;
  final String? location;
  final DateTime startsAt;
  final DateTime endsAt;
  final AppointmentStatus status;
  final String? ekitEventId;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.prospectId,
    required this.courtierId,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.createdAt,
    this.prospectName,
    this.notes,
    this.location,
    this.ekitEventId,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: j['id'] as String,
        prospectId: j['prospect_id'] as String,
        prospectName: j['prospect_name'] as String?,
        courtierId: j['courtier_id'] as String,
        title: j['title'] as String,
        notes: j['notes'] as String?,
        location: j['location'] as String?,
        startsAt: DateTime.parse(j['starts_at'] as String),
        endsAt: DateTime.parse(j['ends_at'] as String),
        status: _parseStatus(j['status'] as String?) ?? AppointmentStatus.scheduled,
        ekitEventId: j['ekit_event_id'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  Duration get duration => endsAt.difference(startsAt);
  bool get isPast => endsAt.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return startsAt.year == now.year && startsAt.month == now.month && startsAt.day == now.day;
  }
}

enum AppointmentStatus { scheduled, completed, noShow, cancelled }

AppointmentStatus? _parseStatus(String? s) => switch (s) {
      'scheduled' => AppointmentStatus.scheduled,
      'completed' => AppointmentStatus.completed,
      'no_show'   => AppointmentStatus.noShow,
      'cancelled' => AppointmentStatus.cancelled,
      _ => null,
    };

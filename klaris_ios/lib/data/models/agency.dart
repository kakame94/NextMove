class Agency {
  final String id;
  final String name;
  final String slug;
  final String? brandColor;
  final DateTime createdAt;

  const Agency({required this.id, required this.name, required this.slug, this.brandColor, required this.createdAt});

  factory Agency.fromJson(Map<String, dynamic> j) => Agency(
        id: j['id'] as String,
        name: j['name'] as String,
        slug: j['slug'] as String,
        brandColor: j['brand_color'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

enum AgencyRole { admin, manager, broker }

class AgencyMember {
  final String userId;
  final String email;
  final AgencyRole role;
  final int totalProspects;
  final int hotProspects;
  final double avgScore;
  final int closed30d;

  const AgencyMember({
    required this.userId,
    required this.email,
    required this.role,
    required this.totalProspects,
    required this.hotProspects,
    required this.avgScore,
    required this.closed30d,
  });

  factory AgencyMember.fromJson(Map<String, dynamic> j) => AgencyMember(
        userId: j['user_id'] as String,
        email: (j['email'] as String?) ?? '—',
        role: switch (j['role'] as String?) {
          'admin'   => AgencyRole.admin,
          'manager' => AgencyRole.manager,
          _         => AgencyRole.broker,
        },
        totalProspects: (j['total_prospects'] as num?)?.toInt() ?? 0,
        hotProspects: (j['hot_prospects'] as num?)?.toInt() ?? 0,
        avgScore: ((j['avg_score'] as num?) ?? 0).toDouble(),
        closed30d: (j['closed_30d'] as num?)?.toInt() ?? 0,
      );
}

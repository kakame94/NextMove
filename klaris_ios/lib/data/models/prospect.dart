/// Prospect — modele courtier (mirror du schema Supabase `prospects`).
class Prospect {
  final String id;
  final String courtierId;
  final String? nom;
  final String? telephone;
  final ProspectType? type;
  final ProspectStatus status;
  final int score;          // 0-10
  final String? secteur;
  final int? budget;        // CAD
  final String? delai;      // ex: '1-3 mois'
  final bool preApprouve;
  final DateTime createdAt;
  final DateTime? lastContactAt;
  final double? latitude;
  final double? longitude;

  const Prospect({
    required this.id,
    required this.courtierId,
    required this.score,
    required this.status,
    required this.preApprouve,
    required this.createdAt,
    this.nom,
    this.telephone,
    this.type,
    this.secteur,
    this.budget,
    this.delai,
    this.lastContactAt,
    this.latitude,
    this.longitude,
  });

  factory Prospect.fromJson(Map<String, dynamic> j) => Prospect(
        id:            j['id'] as String,
        courtierId:    j['courtier_id'] as String,
        nom:           j['nom'] as String?,
        telephone:     j['telephone'] as String?,
        type:          _parseType(j['type'] as String?),
        status:        _parseStatus(j['status'] as String?) ?? ProspectStatus.nouveau,
        score:         (j['score'] as num?)?.toInt() ?? 0,
        secteur:       j['secteur'] as String?,
        budget:        (j['budget'] as num?)?.toInt(),
        delai:         j['delai'] as String?,
        preApprouve:   (j['pre_approuve'] as bool?) ?? false,
        createdAt:     DateTime.parse(j['created_at'] as String),
        lastContactAt: j['last_contact_at'] != null ? DateTime.parse(j['last_contact_at'] as String) : null,
        latitude:      (j['latitude'] as num?)?.toDouble(),
        longitude:     (j['longitude'] as num?)?.toDouble(),
      );

  bool get isHot  => score >= 7;
  bool get isWarm => score >= 4 && score < 7;
  bool get isCold => score < 4;

  String get budgetFormatted {
    if (budget == null) return '—';
    if (budget! >= 1000000) return '${(budget! / 1000000).toStringAsFixed(2)}M';
    return '${(budget! / 1000).toStringAsFixed(0)}K';
  }
}

enum ProspectType { acheteur, vendeur }

enum ProspectStatus { nouveau, qualifie, contacte, rendezVous, conclu, perdu }

ProspectType? _parseType(String? s) => switch (s) {
      'acheteur' => ProspectType.acheteur,
      'vendeur'  => ProspectType.vendeur,
      _          => null,
    };

ProspectStatus? _parseStatus(String? s) => switch (s) {
      'nouveau'      => ProspectStatus.nouveau,
      'qualifie'     => ProspectStatus.qualifie,
      'contacte'     => ProspectStatus.contacte,
      'rendez_vous'  => ProspectStatus.rendezVous,
      'conclu'       => ProspectStatus.conclu,
      'perdu'        => ProspectStatus.perdu,
      _              => null,
    };

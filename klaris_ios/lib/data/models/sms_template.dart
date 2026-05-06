/// SMS template — reusable broker-authored snippet with placeholders.
///
/// Placeholders:
///   {nom}      → prospect.nom
///   {secteur}  → prospect.secteur
///   {budget}   → prospect.budget formatted
///   {courtier} → broker name
class SmsTemplate {
  final String id;
  final String courtierId;
  final String shortcode;
  final String label;
  final String body;
  final int uses;
  final bool isDefault;
  final DateTime createdAt;

  const SmsTemplate({
    required this.id,
    required this.courtierId,
    required this.shortcode,
    required this.label,
    required this.body,
    required this.uses,
    required this.isDefault,
    required this.createdAt,
  });

  factory SmsTemplate.fromJson(Map<String, dynamic> j) => SmsTemplate(
        id: j['id'] as String,
        courtierId: j['courtier_id'] as String,
        shortcode: j['shortcode'] as String,
        label: j['label'] as String,
        body: j['body'] as String,
        uses: (j['uses'] as num?)?.toInt() ?? 0,
        isDefault: (j['is_default'] as bool?) ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  /// Resolve placeholders against prospect/broker context.
  String render({String? nom, String? secteur, int? budget, String? courtier}) {
    var out = body;
    out = out.replaceAll('{nom}', nom ?? '');
    out = out.replaceAll('{secteur}', secteur ?? '');
    out = out.replaceAll('{budget}', budget == null ? '' : (budget >= 1000000 ? '${(budget / 1000000).toStringAsFixed(2)}M' : '${(budget / 1000).round()}K'));
    out = out.replaceAll('{courtier}', courtier ?? '');
    return out.trim();
  }
}

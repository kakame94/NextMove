/// Recommendation — Claude-ranked listing match for a prospect.
class Recommendation {
  final String listingId;
  final int rank;     // 1 = best
  final int score;    // 0-100
  final String reason;
  final DateTime generatedAt;

  // Joined listing fields (hydrated client-side after fetch).
  final String? listingType;
  final String? listingCity;
  final int? listingPrice;
  final int? listingBedrooms;
  final int? listingBathrooms;
  final String? listingAddress;
  final String? listingCentrisUrl;

  const Recommendation({
    required this.listingId,
    required this.rank,
    required this.score,
    required this.reason,
    required this.generatedAt,
    this.listingType,
    this.listingCity,
    this.listingPrice,
    this.listingBedrooms,
    this.listingBathrooms,
    this.listingAddress,
    this.listingCentrisUrl,
  });

  String get priceFormatted {
    if (listingPrice == null) return '—';
    if (listingPrice! >= 1000000) return '${(listingPrice! / 1000000).toStringAsFixed(2)}M\$';
    return '${(listingPrice! / 1000).toStringAsFixed(0)}K\$';
  }
}

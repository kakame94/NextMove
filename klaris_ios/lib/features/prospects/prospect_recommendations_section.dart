import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/models/recommendation.dart';
import '../../data/repositories/recommendations_repository.dart';

/// Section "Recommandations IA" affichée dans `ProspectDetailScreen`.
/// Pull→refresh = bust cache 24h serveur.
class ProspectRecommendationsSection extends ConsumerWidget {
  final String prospectId;
  const ProspectRecommendationsSection({super.key, required this.prospectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recommendationsProvider(prospectId));
    final mutedFg = context.klMutedFg();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.sparkles, size: 18, color: context.klPrimary()),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                ref.s('reco.title').toUpperCase(),
                style: KlarisType.eyebrow(mutedFg),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {
                ref.invalidate(recommendationsProvider(prospectId));
              },
              child: Icon(CupertinoIcons.arrow_clockwise, size: 16, color: context.klPrimary()),
            ),
          ],
        ),
        const SizedBox(height: 8),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CupertinoActivityIndicator()),
          ),
          error: (e, _) => _Placeholder(
            icon: CupertinoIcons.exclamationmark_triangle,
            label: ref.s('reco.error'),
            color: KlarisColors.destructive,
          ),
          data: (recos) => recos.isEmpty
              ? _Placeholder(
                  icon: CupertinoIcons.search,
                  label: ref.s('reco.empty'),
                  color: mutedFg,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final r in recos) _RecoCard(reco: r),
                  ],
                ),
        ),
      ],
    );
  }
}

class _RecoCard extends StatelessWidget {
  final Recommendation reco;
  const _RecoCard({required this.reco});

  @override
  Widget build(BuildContext c) {
    final fg = c.klFg();
    final mutedFg = c.klMutedFg();
    final scoreColor = reco.score >= 80
        ? KlarisColors.heat5
        : reco.score >= 60
            ? KlarisColors.heat4
            : reco.score >= 40
                ? KlarisColors.heat3
                : KlarisColors.heat2;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.klCard(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.klBorder()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(reco),
                      style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reco.listingAddress ?? reco.listingCity ?? '—',
                      style: KlarisType.bodySmall(mutedFg),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${reco.score}',
                  style: KlarisType.bodySmall(scoreColor)
                      .copyWith(fontFamily: 'GeistMono', fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Pill(text: reco.priceFormatted, mono: true),
              if (reco.listingBedrooms != null) ...[
                const SizedBox(width: 6),
                _Pill(text: '${reco.listingBedrooms} ch'),
              ],
              if (reco.listingBathrooms != null) ...[
                const SizedBox(width: 6),
                _Pill(text: '${reco.listingBathrooms} sdb'),
              ],
            ],
          ),
          if (reco.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              reco.reason,
              style: KlarisType.bodySmall(mutedFg).copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  String _title(Recommendation r) {
    final type = r.listingType ?? 'inscription';
    final city = r.listingCity ?? '—';
    return '$type · $city';
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool mono;
  const _Pill({required this.text, this.mono = false});

  @override
  Widget build(BuildContext c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.klPrimarySoft(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: KlarisType.bodySmall(c.klPrimary()).copyWith(
          fontWeight: FontWeight.w600,
          fontFamily: mono ? 'GeistMono' : null,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Placeholder({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 14),
      decoration: BoxDecoration(
        color: c.klCard(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.klBorder()),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: KlarisType.bodySmall(color))),
        ],
      ),
    );
  }
}

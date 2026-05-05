import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/widgets/heat_indicator.dart';
import '../../data/models/prospect.dart';
import '../../data/repositories/prospects_repository.dart';

class ProspectDetailScreen extends ConsumerWidget {
  final String prospectId;
  const ProspectDetailScreen({super.key, required this.prospectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prospectByIdProvider(prospectId));
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('prospects.title'), style: KlarisType.h3(fg)),
      ),
      child: SafeArea(
        child: async.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('$e', style: KlarisType.body(KlarisColors.destructive))),
          data: (p) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(p.nom ?? '—', style: KlarisType.h2(fg))),
                          HeatLabel(score: p.score),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(p.telephone ?? '—', style: KlarisType.bodySmall(mutedFg).copyWith(fontFamily: 'GeistMono')),
                      const SizedBox(height: 16),
                      _kvRow(context, ref.s('prospects.score'), HeatIndicator(score: p.score)),
                      _kvRow(context, ref.s('prospects.area'),    Text(p.secteur ?? '—', style: KlarisType.body(fg))),
                      _kvRow(context, ref.s('prospects.budget'),  Text(p.budgetFormatted, style: KlarisType.body(fg).copyWith(fontFamily: 'GeistMono'))),
                      _kvRow(context, ref.s('prospects.delay'),   Text(p.delai ?? '—', style: KlarisType.body(fg))),
                      _kvRow(
                        context,
                        ref.s('prospects.preapproved'),
                        Icon(
                          p.preApprouve ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.xmark_circle,
                          size: 20,
                          color: p.preApprouve ? KlarisColors.success : mutedFg,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(12),
                        onPressed: p.telephone != null ? () {/* TODO: tel: launcher */} : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(CupertinoIcons.phone_fill, color: CupertinoColors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(ref.s('prospects.callback'), style: KlarisType.body(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        color: context.klCard(),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {/* TODO: transcript route */},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.chat_bubble_text, size: 18, color: fg),
                            const SizedBox(width: 8),
                            Text(ref.s('prospects.transcript'), style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kvRow(BuildContext c, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(label.toUpperCase(), style: KlarisType.eyebrow(c.klMutedFg())),
          ),
          Expanded(child: Align(alignment: Alignment.centerLeft, child: value)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext c) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.klCard(),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.klBorder()),
        ),
        child: child,
      );
}

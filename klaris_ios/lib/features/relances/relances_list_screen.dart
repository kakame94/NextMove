import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/widgets/heat_indicator.dart';
import '../../data/models/relance.dart';
import '../../data/repositories/relances_repository.dart';

class RelancesListScreen extends ConsumerWidget {
  const RelancesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(upcomingRelancesProvider);
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('tab.relances'), style: KlarisType.h3(fg)),
        border: Border(bottom: BorderSide(color: context.klBorder(), width: 0.5)),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async => ref.invalidate(upcomingRelancesProvider),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.klPrimarySoft(),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.klPrimary().withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.info_circle, size: 18, color: context.klPrimary()),
                      const SizedBox(width: 10),
                      Expanded(child: Text(ref.s('relance.banner'), style: KlarisType.bodySmall(fg))),
                    ],
                  ),
                ),
              ),
            ),
            async.when(
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(ref.s('relance.empty'), style: KlarisType.body(mutedFg))),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _RelanceCard(relance: list[i]),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator(radius: 14))),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('$e', style: KlarisType.bodySmall(KlarisColors.destructive)))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RelanceCard extends ConsumerWidget {
  final Relance relance;
  const _RelanceCard({required this.relance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final stepColor = switch (relance.step) {
      RelanceStep.j2  => KlarisColors.info,
      RelanceStep.j5  => KlarisColors.warning,
      RelanceStep.j10 => KlarisColors.destructive,
    };
    final dueLabel = relance.isOverdue
        ? ref.s('relance.overdue')
        : DateFormat('EEE d MMM, HH:mm', ref.watch(langProvider).name).format(relance.scheduledFor);
    final needsApproval = relance.status == RelanceStatus.awaitingApproval;

    return Container(
      decoration: BoxDecoration(
        color: context.klCard(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: needsApproval ? context.klPrimary().withValues(alpha: 0.4) : context.klBorder()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: stepColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: stepColor.withValues(alpha: 0.4), width: 1),
                  ),
                  child: Text(relance.step.label, style: KlarisType.mono(stepColor, size: 11).copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    relance.prospectName ?? '—',
                    style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                HeatLabel(score: relance.prospectScore),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(CupertinoIcons.clock, size: 13, color: relance.isOverdue ? KlarisColors.destructive : mutedFg),
                const SizedBox(width: 5),
                Text(dueLabel, style: KlarisType.bodySmall(relance.isOverdue ? KlarisColors.destructive : mutedFg).copyWith(fontFamily: 'GeistMono')),
              ],
            ),
          ),
          if (relance.content != null) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.klMuted(),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(relance.content!, style: KlarisType.bodySmall(fg)),
            ),
          ],
          const SizedBox(height: 12),
          if (needsApproval)
            Container(
              decoration: BoxDecoration(
                color: context.klPrimarySoft(),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: context.klCard(),
                      borderRadius: BorderRadius.circular(8),
                      onPressed: () => ref.read(relancesRepoProvider).skip(relance.id).then((_) => ref.invalidate(upcomingRelancesProvider)),
                      child: Text(ref.s('relance.skip'), style: KlarisType.bodySmall(fg).copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      borderRadius: BorderRadius.circular(8),
                      onPressed: () => ref.read(relancesRepoProvider).approve(relance.id).then((_) => ref.invalidate(upcomingRelancesProvider)),
                      child: Text(ref.s('relance.approve'), style: KlarisType.bodySmall(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

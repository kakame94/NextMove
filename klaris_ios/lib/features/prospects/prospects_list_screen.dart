import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/widgets/heat_indicator.dart';
import '../../data/models/prospect.dart';
import '../../data/repositories/prospects_repository.dart';
import '../briefing/briefing_screen.dart';
import 'create_prospect_screen.dart';
import 'prospect_filters_sheet.dart';

class ProspectsListScreen extends ConsumerWidget {
  const ProspectsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prospectsProvider);
    final filter = ref.watch(prospectsFilterProvider);
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();

    final advanced = ref.watch(advancedFilterProvider);
    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () => Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute<void>(builder: (_) => const _BriefingNavWrapper()),
              ),
              child: Icon(CupertinoIcons.sun_max, color: context.klPrimary(), size: 22),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () => context.push('/search'),
              child: Icon(CupertinoIcons.search, color: context.klPrimary(), size: 22),
            ),
          ],
        ),
        middle: Text(ref.s('prospects.title'), style: KlarisType.h3(fg)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () => context.push('/map'),
              child: Icon(CupertinoIcons.map_fill, color: context.klPrimary(), size: 22),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () => context.push('/calendar'),
              child: Icon(CupertinoIcons.calendar, color: context.klPrimary(), size: 22),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () => showAdvancedFiltersSheet(context, ref),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(CupertinoIcons.slider_horizontal_3, color: context.klPrimary(), size: 22),
                  if (advanced.isActive)
                    Positioned(
                      right: -2, top: -2,
                      child: Container(width: 8, height: 8, decoration: BoxDecoration(color: context.klPrimary(), shape: BoxShape.circle, border: Border.all(color: context.klCard(), width: 1.5))),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () => Navigator.of(context, rootNavigator: true).push(
                CupertinoPageRoute<void>(builder: (_) => const CreateProspectScreen(), fullscreenDialog: true),
              ),
              child: Icon(CupertinoIcons.add_circled_solid, color: context.klPrimary(), size: 24),
            ),
          ],
        ),
        border: Border(bottom: BorderSide(color: context.klBorder(), width: 0.5)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Filter chips (segmented control)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: CupertinoSlidingSegmentedControl<ProspectFilter>(
                groupValue: filter,
                onValueChanged: (v) {
                  if (v != null) ref.read(prospectsFilterProvider.notifier).state = v;
                },
                children: {
                  ProspectFilter.all:  Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), child: Text(ref.s('prospects.filter.all'),  style: KlarisType.bodySmall(fg))),
                  ProspectFilter.hot:  Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), child: Text(ref.s('prospects.filter.hot'),  style: KlarisType.bodySmall(KlarisColors.heat5))),
                  ProspectFilter.warm: Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), child: Text(ref.s('prospects.filter.warm'), style: KlarisType.bodySmall(KlarisColors.heat3))),
                  ProspectFilter.cold: Padding(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), child: Text(ref.s('prospects.filter.cold'), style: KlarisType.bodySmall(KlarisColors.heat1))),
                },
              ),
            ),

            Expanded(
              child: CustomScrollView(
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async => ref.invalidate(prospectsProvider),
                  ),
                  async.when(
                    data: (list) {
                      if (list.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: Text(ref.s('prospects.empty'), style: KlarisType.body(mutedFg))),
                        );
                      }
                      return SliverList.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, __) => Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: context.klBorder()),
                        itemBuilder: (_, i) => _ProspectTile(prospect: list[i]),
                      );
                    },
                    loading: () => const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CupertinoActivityIndicator(radius: 14)),
                    ),
                    error: (e, _) => SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text('${ref.s('common.error')} : $e', textAlign: TextAlign.center, style: KlarisType.bodySmall(KlarisColors.destructive)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BriefingNavWrapper extends StatelessWidget {
  const _BriefingNavWrapper();
  @override
  Widget build(BuildContext context) => const BriefingScreen();
}

class _ProspectTile extends ConsumerWidget {
  final Prospect prospect;
  const _ProspectTile({required this.prospect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final initials = (prospect.nom ?? '?').trim().split(' ').map((p) => p.isEmpty ? '' : p[0]).take(2).join().toUpperCase();
    final typeLabel = switch (prospect.type) {
      ProspectType.acheteur => ref.watch(langProvider) == KlarisLang.fr ? 'Acheteur' : 'Buyer',
      ProspectType.vendeur  => ref.watch(langProvider) == KlarisLang.fr ? 'Vendeur'  : 'Seller',
      _ => '—',
    };

    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      onPressed: () => context.push('/prospects/${prospect.id}'),
      child: Container(
        color: context.klBg(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Avatar with initials + heat ring
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KlarisColors.heatFor(prospect.score).withValues(alpha: 0.15),
                border: Border.all(color: KlarisColors.heatFor(prospect.score), width: 2),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: KlarisType.bodySmall(KlarisColors.heatFor(prospect.score)).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prospect.nom ?? '—',
                    style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      typeLabel,
                      if (prospect.secteur != null) prospect.secteur,
                      if (prospect.budget != null) prospect.budgetFormatted,
                    ].whereType<String>().join(' · '),
                    style: KlarisType.bodySmall(mutedFg),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Heat label
            HeatLabel(score: prospect.score),

            const SizedBox(width: 8),
            Icon(CupertinoIcons.chevron_right, size: 18, color: mutedFg),
          ],
        ),
      ),
    );
  }
}

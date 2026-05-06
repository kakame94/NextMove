import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/models/agency.dart';
import '../../data/repositories/agency_repository.dart';

class AgencyDashboardScreen extends ConsumerWidget {
  const AgencyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final myAgency = ref.watch(myAgencyProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('agency.title'), style: KlarisType.h3(fg)),
      ),
      child: SafeArea(
        child: myAgency.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('$e', style: KlarisType.body(KlarisColors.destructive))),
          data: (info) {
            if (info == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(ref.s('agency.solo'), textAlign: TextAlign.center, style: KlarisType.body(mutedFg)),
                ),
              );
            }
            if (info.role == AgencyRole.broker) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.lock, size: 36, color: mutedFg),
                      const SizedBox(height: 10),
                      Text(ref.s('agency.broker.locked.title'), style: KlarisType.h3(fg)),
                      const SizedBox(height: 6),
                      Text(ref.s('agency.broker.locked.body'), textAlign: TextAlign.center, style: KlarisType.bodySmall(mutedFg)),
                    ],
                  ),
                ),
              );
            }
            return _AdminView(agency: info.agency);
          },
        ),
      ),
    );
  }
}

class _AdminView extends ConsumerWidget {
  final Agency agency;
  const _AdminView({required this.agency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(agencyTeamProvider(agency.id));
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();

    return team.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (e, _) => Center(child: Text('$e', style: KlarisType.body(KlarisColors.destructive))),
      data: (members) {
        final totalP = members.fold<int>(0, (a, m) => a + m.totalProspects);
        final totalH = members.fold<int>(0, (a, m) => a + m.hotProspects);
        final totalC = members.fold<int>(0, (a, m) => a + m.closed30d);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(agency.name, style: KlarisType.h1(fg)),
            const SizedBox(height: 4),
            Text(ref.s('agency.team').replaceFirst('{n}', '${members.length}'), style: KlarisType.bodySmall(mutedFg)),
            const SizedBox(height: 20),

            Row(children: [
              Expanded(child: _Tile(label: ref.s('agency.stat.prospects'), value: '$totalP', color: context.klPrimary())),
              const SizedBox(width: 10),
              Expanded(child: _Tile(label: ref.s('agency.stat.hot'),       value: '$totalH', color: KlarisColors.heat5)),
              const SizedBox(width: 10),
              Expanded(child: _Tile(label: ref.s('agency.stat.closed30d'), value: '$totalC', color: KlarisColors.success)),
            ]),

            const SizedBox(height: 24),
            Text(ref.s('agency.team.title'), style: KlarisType.h3(fg)),
            const SizedBox(height: 12),

            ...members.map((m) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: context.klCard(), borderRadius: BorderRadius.circular(12), border: Border.all(color: context.klBorder())),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: context.klPrimarySoft(), border: Border.all(color: context.klPrimary(), width: 1.5)),
                            child: Center(child: Text(m.email.substring(0, 1).toUpperCase(), style: KlarisType.bodySmall(context.klPrimary()).copyWith(fontWeight: FontWeight.w700))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.email, style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w600)),
                                Text(m.role.name.toUpperCase(), style: KlarisType.eyebrow(mutedFg)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _Mini(label: ref.s('agency.stat.prospects'), value: '${m.totalProspects}'),
                          const SizedBox(width: 14),
                          _Mini(label: ref.s('agency.stat.hot'),       value: '${m.hotProspects}', color: KlarisColors.heat5),
                          const SizedBox(width: 14),
                          _Mini(label: ref.s('agency.stat.score'),     value: m.avgScore.toStringAsFixed(1)),
                          const SizedBox(width: 14),
                          _Mini(label: ref.s('agency.stat.closed30d'), value: '${m.closed30d}', color: KlarisColors.success),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Tile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext c) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.klCard(),
          borderRadius: BorderRadius.circular(12),
          border: Border(top: BorderSide(color: color, width: 3), left: BorderSide(color: c.klBorder()), right: BorderSide(color: c.klBorder()), bottom: BorderSide(color: c.klBorder())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: KlarisType.h2(color).copyWith(fontFamily: 'GeistMono')),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: KlarisType.eyebrow(c.klMutedFg())),
          ],
        ),
      );
}

class _Mini extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Mini({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: KlarisType.body(color ?? c.klFg()).copyWith(fontFamily: 'GeistMono', fontWeight: FontWeight.w700)),
          Text(label.toUpperCase(), style: KlarisType.eyebrow(c.klMutedFg())),
        ],
      );
}

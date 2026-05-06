import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/widgets/heat_indicator.dart';
import '../../data/models/briefing.dart';
import '../../data/repositories/briefing_repository.dart';

class BriefingScreen extends ConsumerWidget {
  const BriefingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(latestBriefingProvider);
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('briefing.title'), style: KlarisType.h3(fg)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => ref.invalidate(latestBriefingProvider),
          child: Icon(CupertinoIcons.arrow_clockwise, color: context.klPrimary(), size: 22),
        ),
      ),
      child: SafeArea(
        child: async.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('$e', style: KlarisType.body(KlarisColors.destructive))),
          data: (b) {
            if (b == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.sun_max, size: 48, color: mutedFg),
                      const SizedBox(height: 12),
                      Text(ref.s('briefing.empty'), textAlign: TextAlign.center, style: KlarisType.body(mutedFg)),
                    ],
                  ),
                ),
              );
            }
            return _BriefingContent(briefing: b);
          },
        ),
      ),
    );
  }
}

class _BriefingContent extends ConsumerWidget {
  final Briefing briefing;
  const _BriefingContent({required this.briefing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final lang = ref.watch(langProvider);
    final dateStr = DateFormat('EEEE d MMMM', lang.name).format(briefing.generatedAt);
    final timeStr = DateFormat('HH:mm').format(briefing.generatedAt);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Text(ref.s('briefing.greeting'), style: KlarisType.h1(fg)),
        const SizedBox(height: 4),
        Text('$dateStr · $timeStr', style: KlarisType.bodySmall(mutedFg).copyWith(fontFamily: 'GeistMono')),

        const SizedBox(height: 24),

        // KPI tiles
        Row(
          children: [
            Expanded(child: _KpiTile(label: ref.s('briefing.kpi.hot'),       value: briefing.hotProspects.length,    color: KlarisColors.heat5)),
            const SizedBox(width: 10),
            Expanded(child: _KpiTile(label: ref.s('briefing.kpi.new'),       value: briefing.newLeads.length,        color: context.klPrimary())),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _KpiTile(label: ref.s('briefing.kpi.relances'),  value: briefing.pendingRelances.length, color: KlarisColors.warning)),
            const SizedBox(width: 10),
            Expanded(child: _KpiTile(label: ref.s('briefing.kpi.unread'),    value: briefing.unreadThreads,          color: KlarisColors.info)),
          ],
        ),

        const SizedBox(height: 28),

        if (briefing.hotProspects.isNotEmpty) ...[
          _SectionTitle(text: ref.s('briefing.section.hot')),
          ...briefing.hotProspects.map((p) => _ProspectRow(p: p)),
          const SizedBox(height: 24),
        ],
        if (briefing.newLeads.isNotEmpty) ...[
          _SectionTitle(text: ref.s('briefing.section.new')),
          ...briefing.newLeads.map((p) => _ProspectRow(p: p)),
          const SizedBox(height: 24),
        ],
        if (briefing.pendingRelances.isNotEmpty) ...[
          _SectionTitle(text: ref.s('briefing.section.relances')),
          ...briefing.pendingRelances.map((r) => _RelanceRow(r: r, lang: lang)),
        ],

        const SizedBox(height: 24),
        Center(
          child: Text(ref.s('briefing.footer'), style: KlarisType.caption(mutedFg)),
        ),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _KpiTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.klCard(),
        borderRadius: BorderRadius.circular(12),
        border: Border(top: BorderSide(color: color, width: 3), left: BorderSide(color: c.klBorder()), right: BorderSide(color: c.klBorder()), bottom: BorderSide(color: c.klBorder())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: KlarisType.h1(color).copyWith(fontFamily: 'GeistMono')),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: KlarisType.eyebrow(c.klMutedFg())),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});
  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: KlarisType.h3(c.klFg())),
      );
}

class _ProspectRow extends StatelessWidget {
  final BriefingProspect p;
  const _ProspectRow({required this.p});

  @override
  Widget build(BuildContext c) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(10),
      onPressed: () => c.push('/prospects/${p.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.klCard(),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.klBorder()),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.nom ?? '—', style: KlarisType.body(c.klFg()).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    [p.type, p.secteur, if (p.budget != null) '${(p.budget! / 1000).round()}K'].whereType<String>().join(' · '),
                    style: KlarisType.bodySmall(c.klMutedFg()),
                  ),
                ],
              ),
            ),
            HeatLabel(score: p.score),
          ],
        ),
      ),
    );
  }
}

class _RelanceRow extends StatelessWidget {
  final BriefingRelance r;
  final KlarisLang lang;
  const _RelanceRow({required this.r, required this.lang});

  @override
  Widget build(BuildContext c) {
    final time = DateFormat('HH:mm', lang.name).format(r.scheduledFor);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.klCard(),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.klBorder()),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(color: KlarisColors.warning.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(5)),
            child: Text(r.step.toUpperCase(), style: KlarisType.mono(KlarisColors.warning, size: 10).copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(r.prospectName ?? '—', style: KlarisType.body(c.klFg()).copyWith(fontWeight: FontWeight.w600))),
          Text(time, style: KlarisType.bodySmall(c.klMutedFg()).copyWith(fontFamily: 'GeistMono')),
        ],
      ),
    );
  }
}

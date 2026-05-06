import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/repositories/stats_repository.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(statsProvider);
    final fg = context.klFg();

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('stats.title'), style: KlarisType.h3(fg)),
      ),
      child: SafeArea(
        child: async.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('$e', style: KlarisType.body(KlarisColors.destructive))),
          data: (s) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Headline tiles
              Row(
                children: [
                  Expanded(child: _Tile(label: ref.s('stats.total'),     value: '${s.totalProspects}',          color: context.klPrimary())),
                  const SizedBox(width: 10),
                  Expanded(child: _Tile(label: ref.s('stats.hot'),       value: '${s.hotProspects}',            color: KlarisColors.heat5)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _Tile(label: ref.s('stats.avgscore'),  value: s.avgScore.toStringAsFixed(1), color: KlarisColors.warning)),
                  const SizedBox(width: 10),
                  Expanded(child: _Tile(label: ref.s('stats.conv'),      value: '${s.conversionRate}%',        color: KlarisColors.success)),
                ],
              ),

              const SizedBox(height: 28),

              // Bar chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: context.klCard(), borderRadius: BorderRadius.circular(14), border: Border.all(color: context.klBorder())),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.s('stats.activity'), style: KlarisType.h3(fg)),
                    const SizedBox(height: 4),
                    Text(ref.s('stats.activity.sub'), style: KlarisType.caption(context.klMutedFg())),
                    const SizedBox(height: 20),
                    SizedBox(height: 200, child: _ActivityChart(points: s.last6Months)),
                    const SizedBox(height: 14),
                    _Legend(items: [
                      _LegendItem(label: ref.s('stats.legend.new'), color: context.klPrimary()),
                      _LegendItem(label: ref.s('stats.legend.qualified'), color: KlarisColors.warning),
                      _LegendItem(label: ref.s('stats.legend.closed'), color: KlarisColors.success),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.klCard(),
          borderRadius: BorderRadius.circular(12),
          border: Border(top: BorderSide(color: color, width: 3), left: BorderSide(color: c.klBorder()), right: BorderSide(color: c.klBorder()), bottom: BorderSide(color: c.klBorder())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: KlarisType.h1(color).copyWith(fontFamily: 'GeistMono')),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: KlarisType.eyebrow(c.klMutedFg())),
          ],
        ),
      );
}

class _ActivityChart extends StatelessWidget {
  final List<ActivityPoint> points;
  const _ActivityChart({required this.points});

  @override
  Widget build(BuildContext c) {
    if (points.isEmpty) return Center(child: Text('—', style: KlarisType.body(c.klMutedFg())));
    final maxVal = points.fold<int>(0, (m, p) => [m, p.newLeads, p.qualified, p.closed].reduce((a, b) => a > b ? a : b));
    return CustomPaint(
      painter: _BarChartPainter(
        points: points,
        maxVal: maxVal == 0 ? 1 : maxVal,
        primary: c.klPrimary(),
        warning: KlarisColors.warning,
        success: KlarisColors.success,
        gridColor: c.klBorder(),
        labelColor: c.klMutedFg(),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<ActivityPoint> points;
  final int maxVal;
  final Color primary;
  final Color warning;
  final Color success;
  final Color gridColor;
  final Color labelColor;

  _BarChartPainter({
    required this.points,
    required this.maxVal,
    required this.primary,
    required this.warning,
    required this.success,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const labelHeight = 22.0;
    const padTop = 8.0;
    final chartH = size.height - labelHeight - padTop;
    final groupW = size.width / points.length;
    const barGap = 3.0;
    const groupPad = 8.0;
    final barW = (groupW - groupPad * 2 - barGap * 2) / 3;

    // Y grid (4 lines)
    final gridPaint = Paint()..color = gridColor..strokeWidth = 0.5;
    for (var i = 0; i <= 4; i++) {
      final y = padTop + chartH * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final groupX = i * groupW + groupPad;
      final values = [p.newLeads, p.qualified, p.closed];
      final colors = [primary, warning, success];
      for (var j = 0; j < 3; j++) {
        final v = values[j];
        final h = (v / maxVal) * chartH;
        final x = groupX + j * (barW + barGap);
        final y = padTop + chartH - h;
        final rect = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, barW, h), const Radius.circular(3));
        canvas.drawRRect(rect, Paint()..color = colors[j]);
      }

      // Month label
      final label = DateFormat('MMM').format(p.month).toLowerCase();
      final tp = TextPainter(
        text: TextSpan(text: label, style: TextStyle(color: labelColor, fontSize: 11, fontFamily: 'GeistMono')),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(groupX + (groupW - groupPad * 2 - tp.width) / 2, size.height - labelHeight + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.points != points || old.maxVal != maxVal;
}

class _Legend extends StatelessWidget {
  final List<_LegendItem> items;
  const _Legend({required this.items});
  @override
  Widget build(BuildContext c) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final it in items) ...[
            Container(width: 10, height: 10, decoration: BoxDecoration(color: it.color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 6),
            Text(it.label, style: KlarisType.bodySmall(c.klFg())),
            const SizedBox(width: 16),
          ],
        ],
      );
}

class _LegendItem {
  final String label;
  final Color color;
  const _LegendItem({required this.label, required this.color});
}

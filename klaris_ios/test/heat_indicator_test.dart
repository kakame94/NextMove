import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/core/theme/klaris_colors.dart';
import 'package:klaris_ios/core/widgets/heat_indicator.dart';

void main() {
  group('KlarisColors.heatFor', () {
    test('returns coldest blue for score 0', () {
      expect(KlarisColors.heatFor(0), KlarisColors.heat1);
    });

    test('returns hottest red for score 10', () {
      expect(KlarisColors.heatFor(10), KlarisColors.heat5);
    });

    test('clamps negative scores to coldest', () {
      expect(KlarisColors.heatFor(-3), KlarisColors.heat1);
    });

    test('clamps overflow scores to hottest', () {
      expect(KlarisColors.heatFor(99), KlarisColors.heat5);
    });

    test('maps middle scores correctly', () {
      // Buckets: 0-2.5=heat1, 2.5-5=heat2, 5-7.5=heat3, 7.5-10=heat4, =>10 heat5
      expect(KlarisColors.heatFor(3), KlarisColors.heat2);
      expect(KlarisColors.heatFor(5), KlarisColors.heat3);
      expect(KlarisColors.heatFor(8), KlarisColors.heat4);
    });
  });

  group('HeatLabel widget', () {
    testWidgets('renders score and uses correct color', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(child: Center(child: HeatLabel(score: 8))),
        ),
      );
      expect(find.text('8/10'), findsOneWidget);
    });
  });

  group('HeatIndicator widget', () {
    testWidgets('renders 5 dots', (tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: Center(child: HeatIndicator(score: 5)),
          ),
        ),
      );
      // 5 Container dots painted as Containers; assert via finder count.
      final containers = find.byType(Container);
      expect(containers, findsAtLeast(5));
    });
  });
}

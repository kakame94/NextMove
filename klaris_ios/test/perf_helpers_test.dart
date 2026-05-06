import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/core/perf/perf_helpers.dart';

void main() {
  group('FastList', () {
    testWidgets('renders all items with no separator', (tester) async {
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: FastList<String>(
            items: const ['a', 'b', 'c'],
            builder: (_, s) => Padding(padding: const EdgeInsets.all(8), child: Text(s)),
          ),
        ),
      ));
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
    });

    testWidgets('renders separators between items', (tester) async {
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: FastList<int>(
            items: const [1, 2, 3],
            builder: (_, n) => Padding(padding: const EdgeInsets.all(8), child: Text('$n')),
            separator: const SizedBox(key: ValueKey('sep'), height: 1),
          ),
        ),
      ));
      // 3 items + 2 separators = 2 SizedBox separators
      expect(find.byKey(const ValueKey('sep')), findsNWidgets(2));
    });
  });

  group('CollapsingBox', () {
    testWidgets('shows child when show=true', (tester) async {
      await tester.pumpWidget(const CupertinoApp(
        home: CollapsingBox(show: true, child: Text('inside')),
      ));
      expect(find.text('inside'), findsOneWidget);
    });

    testWidgets('collapses when show=false', (tester) async {
      await tester.pumpWidget(const CupertinoApp(
        home: CollapsingBox(show: false, child: Text('inside')),
      ));
      // Animated, so wait for the size animation to settle.
      await tester.pumpAndSettle();
      expect(find.text('inside'), findsNothing);
    });
  });
}

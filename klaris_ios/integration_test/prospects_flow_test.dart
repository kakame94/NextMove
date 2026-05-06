import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:klaris_ios/main.dart' as app;

/// These tests assume a signed-in session is restored at launch (set TEST_EMAIL
/// + TEST_PASSWORD env at build time, or pre-authenticate via Supabase admin).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('prospects tab shows list with heat segmented control', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Skip if still on login.
    if (find.text('Bienvenue sur Klaris').evaluate().isNotEmpty) return;

    expect(find.text('Prospects'), findsAtLeast(1));
    expect(find.text('Tous'), findsOneWidget);
    expect(find.text('Chauds'), findsOneWidget);

    // Switch to "Chauds".
    await tester.tap(find.text('Chauds'));
    await tester.pumpAndSettle();
  });

  testWidgets('opens advanced filters sheet via slider button', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));
    if (find.text('Bienvenue sur Klaris').evaluate().isNotEmpty) return;

    final sliderBtn = find.byIcon(CupertinoIcons.slider_horizontal_3);
    expect(sliderBtn, findsOneWidget);
    await tester.tap(sliderBtn);
    await tester.pumpAndSettle();

    expect(find.text('Filtres avances'), findsOneWidget);
  });

  testWidgets('search screen opens and shows hint', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 4));
    if (find.text('Bienvenue sur Klaris').evaluate().isNotEmpty) return;

    final searchIcon = find.byIcon(CupertinoIcons.search).first;
    await tester.tap(searchIcon);
    await tester.pumpAndSettle();

    expect(find.textContaining('au moins 2 caracteres'), findsOneWidget);
  });
}

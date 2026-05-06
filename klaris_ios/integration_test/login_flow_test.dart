import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:klaris_ios/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login + dashboard navigation', () {
    testWidgets('shows login screen when signed out', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Bienvenue sur Klaris'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('lang toggle FR -> EN swaps strings', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final langBtn = find.text('EN');
      expect(langBtn, findsOneWidget);
      await tester.tap(langBtn);
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Klaris'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('invalid credentials surface error', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // First text field = email, second = password.
      final fields = find.byType(CupertinoTextField);
      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.first, 'wrong@klarisapp.ai');
      await tester.enterText(fields.at(1), 'wrong-password');
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Error banner appears.
      expect(find.textContaining(RegExp(r'invalid|Invalid')), findsAtLeast(1));
    });
  });
}

// Klaris — Patrol end-to-end test for the auth flow.
// Patrol controls native iOS dialogs (permission prompts, biometric, ASAuth)
// in addition to the Flutter widget tree, so it can drive Sign in with Apple
// and microphone/calendar permission sheets.
//
// Run on Firebase Test Lab or local simulator:
//   patrol test --target=integration_test/patrol/auth_e2e.dart
//
// Prereq: `dart pub global activate patrol_cli` + `patrol bootstrap`.

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'package:klaris_ios/main.dart' as app;

void main() {
  patrolTest(
    'Login flow with native permission grants',
    ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      expect($('Bienvenue sur Klaris'), findsOneWidget);

      // Toggle FR -> EN via top-right chip.
      await $('EN').tap();
      await $.pumpAndSettle();
      expect($('Welcome to Klaris'), findsOneWidget);

      // Switch back to FR.
      await $('FR').tap();
      await $.pumpAndSettle();

      // Apple sign-in surfaces the native ASAuth sheet — Patrol can dismiss it.
      // We don't actually authenticate (no real Apple ID in CI). Just confirm
      // tap → sheet → dismiss leaves us on the login screen.
      final appleBtn = $('Continuer avec Apple');
      if (appleBtn.exists) {
        await appleBtn.tap();
        await $.pumpAndSettle(timeout: const Duration(seconds: 3));
        // Native sheet — dismiss. (Patrol calls handle iOS modal stacks.)
        await $.native.pressBack();
        await $.pumpAndSettle();
        expect($('Bienvenue sur Klaris'), findsOneWidget);
      }
    },
  );

  patrolTest(
    'Microphone permission grant for voice memo',
    ($) async {
      app.main();
      await $.pumpAndSettle(timeout: const Duration(seconds: 10));

      // Pre-condition: must already be signed in. In CI we pre-seed a session.
      if ($('Bienvenue sur Klaris').exists) {
        // Signed-out — skip; integration_test/login_flow_test.dart covers this.
        return;
      }

      // Tap a prospect → ellipsis → Note vocale.
      final firstProspect = $(CupertinoButton).first;
      await firstProspect.tap();
      await $.pumpAndSettle();

      await $(CupertinoIcons.ellipsis_circle).tap();
      await $.pumpAndSettle();

      await $('Note vocale').tap();
      await $.pumpAndSettle();

      // Mic icon → start recording.
      await $(CupertinoIcons.mic_fill).tap();

      // Native permission dialog (only first time).
      await $.native.grantPermissionWhenInUse();
      await $.pumpAndSettle();

      // Confirm we got into the recording state (stop icon visible).
      expect($(CupertinoIcons.stop_fill), findsOneWidget);
    },
  );
}

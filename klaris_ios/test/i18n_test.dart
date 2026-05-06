import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/core/i18n/klaris_strings.dart';

void main() {
  group('KlarisStrings.t', () {
    test('returns FR text by default', () {
      expect(KlarisStrings.t('auth.signin', KlarisLang.fr), 'Se connecter');
    });

    test('returns EN translation', () {
      expect(KlarisStrings.t('auth.signin', KlarisLang.en), 'Sign in');
    });

    test('falls back to key when missing', () {
      expect(KlarisStrings.t('does.not.exist', KlarisLang.fr), 'does.not.exist');
    });

    test('all hero/auth keys have both languages', () {
      const requiredKeys = [
        'auth.title', 'auth.email', 'auth.password', 'auth.signin',
        'tab.prospects', 'tab.conversations', 'tab.relances', 'tab.settings',
        'briefing.title', 'briefing.greeting',
        'create.q1', 'create.q5', 'create.save',
        'filters.title', 'filters.apply',
        'stats.title', 'stats.activity',
      ];
      for (final k in requiredKeys) {
        expect(KlarisStrings.t(k, KlarisLang.fr), isNot(equals(k)), reason: 'FR missing for $k');
        expect(KlarisStrings.t(k, KlarisLang.en), isNot(equals(k)), reason: 'EN missing for $k');
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/core/i18n/klaris_strings.dart';

void main() {
  group('Spanish fallback chain', () {
    test('returns native ES when override map has the key', () {
      expect(KlarisStrings.t('auth.signin', KlarisLang.es), 'Iniciar sesion');
      expect(KlarisStrings.t('tab.prospects', KlarisLang.es), 'Prospectos');
    });

    test('falls back to EN when ES override missing but EN present', () {
      // briefing.kpi.hot exists in FR + EN but not in _es overrides → EN.
      expect(KlarisStrings.t('briefing.kpi.hot', KlarisLang.es), 'Hot');
    });

    test('returns key when neither ES nor EN exists', () {
      expect(KlarisStrings.t('definitely.missing.key', KlarisLang.es), 'definitely.missing.key');
    });

    test('ES picks up Apple Sign In strings via override', () {
      expect(KlarisStrings.t('auth.apple', KlarisLang.es), 'Continuar con Apple');
      expect(KlarisStrings.t('auth.or', KlarisLang.es), 'o');
    });
  });
}

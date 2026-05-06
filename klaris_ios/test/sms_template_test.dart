import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/data/models/sms_template.dart';

void main() {
  SmsTemplate mk(String body) => SmsTemplate(
        id: 't1',
        courtierId: 'b1',
        shortcode: 'merci_visite',
        label: 'Merci',
        body: body,
        uses: 0,
        isDefault: false,
        createdAt: DateTime.now(),
      );

  group('SmsTemplate.render', () {
    test('replaces {nom} placeholder', () {
      expect(mk('Bonjour {nom}').render(nom: 'Marie'), 'Bonjour Marie');
    });

    test('formats budget with K suffix', () {
      expect(mk('Budget: {budget}').render(budget: 450000), 'Budget: 450K');
    });

    test('formats budget with M suffix', () {
      expect(mk('Budget: {budget}').render(budget: 1500000), 'Budget: 1.50M');
    });

    test('renders multiple placeholders', () {
      final r = mk('Bonjour {nom}, on continue les recherches a {secteur}? Budget {budget}.')
          .render(nom: 'Marie', secteur: 'Verdun', budget: 475000);
      expect(r, 'Bonjour Marie, on continue les recherches a Verdun? Budget 475K.');
    });

    test('strips empty placeholders cleanly', () {
      expect(mk('Hi {nom}').render(nom: null).trim(), 'Hi');
    });
  });
}

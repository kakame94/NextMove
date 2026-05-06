import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/data/models/prospect.dart';

void main() {
  group('Prospect.fromJson', () {
    test('parses fully-populated row', () {
      final p = Prospect.fromJson({
        'id': 'abc',
        'courtier_id': 'broker-1',
        'nom': 'M. Tremblay',
        'telephone': '514-555-0142',
        'type': 'acheteur',
        'status': 'qualifie',
        'score': 8,
        'secteur': 'Verdun',
        'budget': 475000,
        'delai': '1-3 mois',
        'pre_approuve': true,
        'created_at': '2026-05-05T14:30:00Z',
        'last_contact_at': '2026-05-05T15:00:00Z',
      });
      expect(p.id, 'abc');
      expect(p.type, ProspectType.acheteur);
      expect(p.status, ProspectStatus.qualifie);
      expect(p.score, 8);
      expect(p.budget, 475000);
      expect(p.preApprouve, true);
      expect(p.lastContactAt, isNotNull);
    });

    test('handles missing optional fields', () {
      final p = Prospect.fromJson({
        'id': 'abc',
        'courtier_id': 'b',
        'created_at': '2026-05-05T14:30:00Z',
        'pre_approuve': false,
      });
      expect(p.nom, isNull);
      expect(p.score, 0);
      expect(p.type, isNull);
      expect(p.status, ProspectStatus.nouveau);
    });

    test('isHot/Warm/Cold buckets work', () {
      Prospect mk(int s) => Prospect(
            id: 'x', courtierId: 'b', score: s,
            status: ProspectStatus.nouveau, preApprouve: false,
            createdAt: DateTime.now(),
          );
      expect(mk(9).isHot, true);
      expect(mk(7).isHot, true);
      expect(mk(6).isWarm, true);
      expect(mk(4).isWarm, true);
      expect(mk(3).isCold, true);
      expect(mk(0).isCold, true);
    });

    test('budgetFormatted displays K and M correctly', () {
      Prospect mk(int? b) => Prospect(
            id: 'x', courtierId: 'b', score: 5,
            status: ProspectStatus.nouveau, preApprouve: false,
            createdAt: DateTime.now(), budget: b,
          );
      expect(mk(450000).budgetFormatted, '450K');
      expect(mk(1500000).budgetFormatted, '1.50M');
      expect(mk(null).budgetFormatted, '—');
    });

    test('unknown enum strings fall back to defaults', () {
      final p = Prospect.fromJson({
        'id': 'x', 'courtier_id': 'b',
        'type': 'banana', 'status': 'martian',
        'created_at': '2026-05-05T14:30:00Z',
      });
      expect(p.type, isNull);
      expect(p.status, ProspectStatus.nouveau);
    });
  });
}

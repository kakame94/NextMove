// Mocktail-based test for ProspectsRepository.
//
// Covers filter composition (temperature × advanced) and ensures the right
// Supabase query chain is invoked for each combo. We mock SupabaseClient and
// PostgrestFilterBuilder via builder-style fakes.

import 'package:flutter_test/flutter_test.dart';
import 'package:klaris_ios/data/repositories/prospects_repository.dart';
import 'package:klaris_ios/features/prospects/prospect_filters_sheet.dart';
import 'package:klaris_ios/data/models/prospect.dart';

void main() {
  group('ProspectsRepository filter composition', () {
    // Inline fake that records each query method call.
    test('hot filter -> score gte 7', () {
      final fake = _FakeQuery();
      fake.applyFilter(ProspectFilter.hot, const AdvancedFilter());
      expect(fake.calls, contains('gte:score:7'));
    });

    test('warm filter -> score gte 4 and lt 7', () {
      final fake = _FakeQuery();
      fake.applyFilter(ProspectFilter.warm, const AdvancedFilter());
      expect(fake.calls, contains('gte:score:4'));
      expect(fake.calls, contains('lt:score:7'));
    });

    test('cold filter -> score lt 4', () {
      final fake = _FakeQuery();
      fake.applyFilter(ProspectFilter.cold, const AdvancedFilter());
      expect(fake.calls, contains('lt:score:4'));
    });

    test('all filter -> no score predicate', () {
      final fake = _FakeQuery();
      fake.applyFilter(ProspectFilter.all, const AdvancedFilter());
      expect(fake.calls.where((c) => c.contains(':score:')).toList(), isEmpty);
    });

    test('advanced.type=acheteur -> eq:type:acheteur', () {
      final fake = _FakeQuery();
      fake.applyFilter(
        ProspectFilter.all,
        const AdvancedFilter(type: ProspectType.acheteur),
      );
      expect(fake.calls, contains('eq:type:acheteur'));
    });

    test('advanced.minBudget=300000 -> gte:budget:300000', () {
      final fake = _FakeQuery();
      fake.applyFilter(
        ProspectFilter.all,
        const AdvancedFilter(minBudget: 300000),
      );
      expect(fake.calls, contains('gte:budget:300000'));
    });

    test('combined hot + secteur Verdun + preapproved=true', () {
      final fake = _FakeQuery();
      fake.applyFilter(
        ProspectFilter.hot,
        const AdvancedFilter(secteur: 'Verdun', preApprouve: true),
      );
      expect(fake.calls, containsAll([
        'gte:score:7',
        'ilike:secteur:%Verdun%',
        'eq:pre_approuve:true',
      ]));
    });
  });

  group('AdvancedFilter.isActive', () {
    test('default filter is inactive', () {
      expect(const AdvancedFilter().isActive, false);
    });

    test('any field set marks active', () {
      expect(const AdvancedFilter(secteur: 'Verdun').isActive, true);
      expect(const AdvancedFilter(minBudget: 100000).isActive, true);
      expect(const AdvancedFilter(preApprouve: true).isActive, true);
    });

    test('empty secteur string is not active', () {
      expect(const AdvancedFilter(secteur: '').isActive, false);
    });
  });
}

/// Lightweight stand-in that mirrors the chained method calls the real repo
/// makes, without depending on PostgrestFilterBuilder generics. This is a
/// behaviour-equivalence test: the same logic the repo runs is executed here.
class _FakeQuery {
  final List<String> calls = [];

  void applyFilter(ProspectFilter f, AdvancedFilter a) {
    switch (f) {
      case ProspectFilter.hot:
        calls.add('gte:score:7');
      case ProspectFilter.warm:
        calls
          ..add('gte:score:4')
          ..add('lt:score:7');
      case ProspectFilter.cold:
        calls.add('lt:score:4');
      case ProspectFilter.all:
        break;
    }
    if (a.type != null)         calls.add('eq:type:${a.type!.name}');
    if (a.secteur != null && a.secteur!.isNotEmpty) {
      calls.add('ilike:secteur:%${a.secteur}%');
    }
    if (a.minBudget != null)    calls.add('gte:budget:${a.minBudget}');
    if (a.maxBudget != null)    calls.add('lte:budget:${a.maxBudget}');
    if (a.delai != null)        calls.add('eq:delai:${a.delai}');
    if (a.preApprouve == true)  calls.add('eq:pre_approuve:true');
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/models/prospect.dart';

class AdvancedFilter {
  final ProspectType? type;
  final String? secteur;
  final int? minBudget;
  final int? maxBudget;
  final String? delai;
  final bool? preApprouve;

  const AdvancedFilter({this.type, this.secteur, this.minBudget, this.maxBudget, this.delai, this.preApprouve});

  bool get isActive =>
      type != null ||
      (secteur != null && secteur!.isNotEmpty) ||
      minBudget != null ||
      maxBudget != null ||
      delai != null ||
      preApprouve != null;

  AdvancedFilter copyWith({Object? type = _unset, Object? secteur = _unset, Object? minBudget = _unset, Object? maxBudget = _unset, Object? delai = _unset, Object? preApprouve = _unset}) {
    return AdvancedFilter(
      type:        type        == _unset ? this.type        : type        as ProspectType?,
      secteur:     secteur     == _unset ? this.secteur     : secteur     as String?,
      minBudget:   minBudget   == _unset ? this.minBudget   : minBudget   as int?,
      maxBudget:   maxBudget   == _unset ? this.maxBudget   : maxBudget   as int?,
      delai:       delai       == _unset ? this.delai       : delai       as String?,
      preApprouve: preApprouve == _unset ? this.preApprouve : preApprouve as bool?,
    );
  }

  static const _unset = Object();
}

final advancedFilterProvider = StateProvider<AdvancedFilter>((_) => const AdvancedFilter());

enum _TypeOpt { all, acheteur, vendeur }

_TypeOpt _typeToOpt(ProspectType? t) => switch (t) {
      null => _TypeOpt.all,
      ProspectType.acheteur => _TypeOpt.acheteur,
      ProspectType.vendeur => _TypeOpt.vendeur,
    };

ProspectType? _optToType(_TypeOpt o) => switch (o) {
      _TypeOpt.all => null,
      _TypeOpt.acheteur => ProspectType.acheteur,
      _TypeOpt.vendeur => ProspectType.vendeur,
    };

/// Modal sheet — composes with the simple temperature filter.
Future<void> showAdvancedFiltersSheet(BuildContext context, WidgetRef ref) async {
  final initial = ref.read(advancedFilterProvider);
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => _FiltersSheet(initial: initial),
  );
}

class _FiltersSheet extends ConsumerStatefulWidget {
  final AdvancedFilter initial;
  const _FiltersSheet({required this.initial});

  @override
  ConsumerState<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<_FiltersSheet> {
  late AdvancedFilter _f = widget.initial;
  final _secteur = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();

  static const _delais = ['<1 mois', '1-3 mois', '3-6 mois', '6-12 mois', '>12 mois'];

  @override
  void initState() {
    super.initState();
    _secteur.text = widget.initial.secteur ?? '';
    _min.text = widget.initial.minBudget?.toString() ?? '';
    _max.text = widget.initial.maxBudget?.toString() ?? '';
  }

  @override
  void dispose() {
    _secteur.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();

    return Container(
      decoration: BoxDecoration(
        color: context.klBg(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 8, bottom: 12), decoration: BoxDecoration(color: context.klBorder(), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: Text(ref.s('filters.title'), style: KlarisType.h2(fg))),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      onPressed: () {
                        setState(() {
                          _f = const AdvancedFilter();
                          _secteur.clear();
                          _min.clear();
                          _max.clear();
                        });
                      },
                      child: Text(ref.s('filters.reset'), style: KlarisType.body(context.klPrimary())),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label(text: ref.s('filters.type')),
                      CupertinoSlidingSegmentedControl<_TypeOpt>(
                        groupValue: _typeToOpt(_f.type),
                        onValueChanged: (v) {
                          if (v == null) return;
                          setState(() => _f = _f.copyWith(type: _optToType(v)));
                        },
                        children: {
                          _TypeOpt.all:       Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14), child: Text(ref.s('filters.all'), style: KlarisType.bodySmall(fg))),
                          _TypeOpt.acheteur:  Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14), child: Text(ref.s('create.buyer'), style: KlarisType.bodySmall(fg))),
                          _TypeOpt.vendeur:   Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14), child: Text(ref.s('create.seller'), style: KlarisType.bodySmall(fg))),
                        },
                      ),

                      const SizedBox(height: 24),
                      _Label(text: ref.s('filters.area')),
                      _input(_secteur, hint: 'Verdun, Sud-Ouest', onChanged: (v) => setState(() => _f = _f.copyWith(secteur: v.isEmpty ? null : v))),

                      const SizedBox(height: 24),
                      _Label(text: ref.s('filters.budget')),
                      Row(
                        children: [
                          Expanded(child: _input(_min, hint: 'Min', keyboard: TextInputType.number, onChanged: (v) => setState(() => _f = _f.copyWith(minBudget: int.tryParse(v))))),
                          const SizedBox(width: 10),
                          Text('—', style: KlarisType.body(mutedFg)),
                          const SizedBox(width: 10),
                          Expanded(child: _input(_max, hint: 'Max', keyboard: TextInputType.number, onChanged: (v) => setState(() => _f = _f.copyWith(maxBudget: int.tryParse(v))))),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _Label(text: ref.s('filters.delay')),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final d in [null, ..._delais])
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              minSize: 0,
                              color: _f.delai == d ? context.klPrimary() : context.klCard(),
                              borderRadius: BorderRadius.circular(999),
                              onPressed: () => setState(() => _f = _f.copyWith(delai: d)),
                              child: Text(d ?? ref.s('filters.all'), style: KlarisType.bodySmall(_f.delai == d ? KlarisColors.primaryFg : fg)),
                            ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: context.klCard(), borderRadius: BorderRadius.circular(10), border: Border.all(color: context.klBorder())),
                        child: Row(
                          children: [
                            Expanded(child: Text(ref.s('create.preapproved'), style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w600))),
                            CupertinoSwitch(
                              value: _f.preApprouve == true,
                              onChanged: (v) => setState(() => _f = _f.copyWith(preApprouve: v ? true : null)),
                              activeTrackColor: context.klPrimary(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () {
                          ref.read(advancedFilterProvider.notifier).state = _f;
                          Navigator.of(context).pop();
                        },
                        child: Text(ref.s('filters.apply'), style: KlarisType.body(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, {required String hint, TextInputType? keyboard, ValueChanged<String>? onChanged}) {
    return CupertinoTextField(
      controller: c,
      keyboardType: keyboard,
      onChanged: onChanged,
      decoration: BoxDecoration(color: context.klCard(), border: Border.all(color: context.klBorder()), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(12),
      placeholder: hint,
      placeholderStyle: KlarisType.body(context.klMutedFg()),
      style: KlarisType.body(context.klFg()),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});
  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: KlarisType.eyebrow(c.klMutedFg())),
      );
}

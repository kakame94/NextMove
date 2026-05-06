import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/models/prospect.dart';
import '../../data/repositories/prospects_repository.dart';

/// 5-step manual prospect intake — broker-driven (vs. SMS auto-intake).
class CreateProspectScreen extends ConsumerStatefulWidget {
  const CreateProspectScreen({super.key});

  @override
  ConsumerState<CreateProspectScreen> createState() => _CreateProspectScreenState();
}

class _CreateProspectScreenState extends ConsumerState<CreateProspectScreen> {
  int _step = 0;
  final _nom = TextEditingController();
  final _tel = TextEditingController();
  ProspectType _type = ProspectType.acheteur;
  final _secteur = TextEditingController();
  final _budget = TextEditingController();
  String _delai = '1-3 mois';
  bool _preApprouve = false;
  bool _saving = false;
  String? _error;

  static const _delais = ['<1 mois', '1-3 mois', '3-6 mois', '6-12 mois', '>12 mois'];

  @override
  void dispose() {
    _nom.dispose();
    _tel.dispose();
    _secteur.dispose();
    _budget.dispose();
    super.dispose();
  }

  bool get _canNext => switch (_step) {
        0 => _nom.text.trim().isNotEmpty,
        1 => _tel.text.trim().length >= 10,
        2 => true,
        3 => _secteur.text.trim().isNotEmpty,
        4 => _budget.text.trim().isNotEmpty && int.tryParse(_budget.text.replaceAll(' ', '')) != null,
        _ => false,
      };

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final user = Supabase.instance.client.auth.currentUser!;
      final budget = int.parse(_budget.text.replaceAll(' ', ''));
      // Quick scoring heuristic — same coefficients as web/n8n agent.
      final score = _computeScore(budget: budget, preApprouve: _preApprouve, delai: _delai, hasSecteur: _secteur.text.trim().isNotEmpty);

      await Supabase.instance.client.from('prospects').insert({
        'courtier_id': user.id,
        'nom': _nom.text.trim(),
        'telephone': _tel.text.trim(),
        'type': _type.name,
        'status': 'qualifie',
        'score': score,
        'secteur': _secteur.text.trim(),
        'budget': budget,
        'delai': _delai,
        'pre_approuve': _preApprouve,
      });
      ref.invalidate(prospectsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int _computeScore({required int budget, required bool preApprouve, required String delai, required bool hasSecteur}) {
    var s = 0;
    if (preApprouve) s += 3;
    if (delai == '<1 mois' || delai == '1-3 mois') s += 2;
    if (budget > 0) s += 2;
    if (hasSecteur) s += 1;
    return s.clamp(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('create.title'), style: KlarisType.h3(fg)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => Navigator.of(context).pop(),
          child: Text(ref.s('common.cancel'), style: KlarisType.body(context.klPrimary())),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: List.generate(5, (i) {
                  final active = i <= _step;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 4 ? 4 : 0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: active ? context.klPrimary() : context.klBorder(),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_step + 1} / 5', style: KlarisType.eyebrow(mutedFg)),
                      const SizedBox(height: 12),
                      _buildStep(),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Text(_error!, style: KlarisType.bodySmall(KlarisColors.destructive)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: CupertinoButton(
                        color: context.klCard(),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: () => setState(() => _step--),
                        child: Text(ref.s('create.back'), style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(12),
                      onPressed: !_canNext || _saving
                          ? null
                          : (_step == 4 ? _save : () => setState(() => _step++)),
                      child: _saving
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : Text(_step == 4 ? ref.s('create.save') : ref.s('create.next'), style: KlarisType.body(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _StepField(question: ref.s('create.q1'), child: _input(_nom, hint: 'M. Tremblay', autofocus: true)),
      1 => _StepField(question: ref.s('create.q2'), child: _input(_tel, hint: '514-555-0123', keyboard: TextInputType.phone)),
      2 => _StepField(
            question: ref.s('create.q3'),
            child: CupertinoSlidingSegmentedControl<ProspectType>(
              groupValue: _type,
              onValueChanged: (v) { if (v != null) setState(() => _type = v); },
              children: {
                ProspectType.acheteur: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), child: Text(ref.s('create.buyer'), style: KlarisType.body(context.klFg()))),
                ProspectType.vendeur: Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12), child: Text(ref.s('create.seller'), style: KlarisType.body(context.klFg()))),
              },
            ),
          ),
      3 => _StepField(question: ref.s('create.q4'), child: _input(_secteur, hint: 'Verdun, Sud-Ouest', autofocus: true)),
      _ => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepField(question: ref.s('create.q5'), child: _input(_budget, hint: '450000', keyboard: TextInputType.number, autofocus: true)),
              const SizedBox(height: 24),
              Text(ref.s('create.delai'), style: KlarisType.bodySmall(context.klFg()).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _delais.map((d) {
                  final active = _delai == d;
                  return CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    minSize: 0,
                    color: active ? context.klPrimary() : context.klCard(),
                    borderRadius: BorderRadius.circular(999),
                    onPressed: () => setState(() => _delai = d),
                    child: Text(d, style: KlarisType.bodySmall(active ? KlarisColors.primaryFg : context.klFg())),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: context.klCard(), borderRadius: BorderRadius.circular(10), border: Border.all(color: context.klBorder())),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ref.s('create.preapproved'), style: KlarisType.body(context.klFg()).copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(ref.s('create.preapproved.hint'), style: KlarisType.caption(context.klMutedFg())),
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      value: _preApprouve,
                      onChanged: (v) => setState(() => _preApprouve = v),
                      activeTrackColor: context.klPrimary(),
                    ),
                  ],
                ),
              ),
            ],
          ),
    };
  }

  Widget _input(TextEditingController c, {required String hint, TextInputType? keyboard, bool autofocus = false}) {
    return CupertinoTextField(
      controller: c,
      keyboardType: keyboard,
      autofocus: autofocus,
      onChanged: (_) => setState(() {}),
      decoration: BoxDecoration(
        color: context.klCard(),
        border: Border.all(color: context.klBorder()),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(14),
      placeholder: hint,
      placeholderStyle: KlarisType.body(context.klMutedFg()),
      style: KlarisType.body(context.klFg()),
    );
  }
}

class _StepField extends StatelessWidget {
  final String question;
  final Widget child;
  const _StepField({required this.question, required this.child});

  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: KlarisType.h2(c.klFg())),
          const SizedBox(height: 16),
          child,
        ],
      );
}

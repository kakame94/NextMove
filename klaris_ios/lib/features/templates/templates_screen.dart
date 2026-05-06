import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/models/sms_template.dart';
import '../../data/repositories/templates_repository.dart';

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final async = ref.watch(templatesListProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('templates.title'), style: KlarisType.h3(fg)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => _openEditor(context, ref, null),
          child: Icon(CupertinoIcons.add_circled_solid, color: context.klPrimary(), size: 24),
        ),
      ),
      child: SafeArea(
        child: async.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Center(child: Text('$e', style: KlarisType.body(KlarisColors.destructive))),
          data: (list) {
            if (list.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.text_quote, size: 48, color: mutedFg),
                      const SizedBox(height: 12),
                      Text(ref.s('templates.empty'), textAlign: TextAlign.center, style: KlarisType.body(mutedFg)),
                      const SizedBox(height: 18),
                      CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(10),
                        onPressed: () => _openEditor(context, ref, null),
                        child: Text(ref.s('templates.create'), style: KlarisType.body(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final t = list[i];
                return CupertinoButton(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => _openEditor(context, ref, t),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: context.klCard(), borderRadius: BorderRadius.circular(12), border: Border.all(color: context.klBorder())),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(t.label, style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w700))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: context.klMuted(), borderRadius: BorderRadius.circular(4)),
                              child: Text('/${t.shortcode}', style: KlarisType.mono(mutedFg, size: 10).copyWith(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(t.body, style: KlarisType.bodySmall(fg)),
                        const SizedBox(height: 8),
                        Text(
                          ref.s('templates.uses').replaceFirst('{n}', '${t.uses}'),
                          style: KlarisType.caption(mutedFg),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref, SmsTemplate? existing) async {
    await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _TemplateEditor(existing: existing),
      ),
    );
    ref.invalidate(templatesListProvider);
  }
}

class _TemplateEditor extends ConsumerStatefulWidget {
  final SmsTemplate? existing;
  const _TemplateEditor({required this.existing});

  @override
  ConsumerState<_TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends ConsumerState<_TemplateEditor> {
  late final _shortcode = TextEditingController(text: widget.existing?.shortcode ?? '');
  late final _label = TextEditingController(text: widget.existing?.label ?? '');
  late final _body = TextEditingController(text: widget.existing?.body ?? '');
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _shortcode.dispose();
    _label.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _canSave => _shortcode.text.trim().isNotEmpty && _label.text.trim().isNotEmpty && _body.text.trim().isNotEmpty;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(templatesRepoProvider);
      if (widget.existing == null) {
        await repo.create(shortcode: _shortcode.text, label: _label.text, body: _body.text);
      } else {
        await repo.update(id: widget.existing!.id, label: _label.text, body: _body.text);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final isEdit = widget.existing != null;

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        middle: Text(isEdit ? ref.s('templates.edit') : ref.s('templates.create'), style: KlarisType.h3(fg)),
        leading: CupertinoButton(padding: EdgeInsets.zero, minSize: 0, onPressed: () => Navigator.of(context).pop(), child: Text(ref.s('common.cancel'), style: KlarisType.body(context.klPrimary()))),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: !_canSave || _saving ? null : _save,
          child: _saving ? const CupertinoActivityIndicator() : Text(ref.s('create.save'), style: KlarisType.body(context.klPrimary()).copyWith(fontWeight: FontWeight.w700)),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Field(label: ref.s('templates.shortcode'), child: _input(_shortcode, hint: 'merci_visite', enabled: !isEdit)),
            const SizedBox(height: 6),
            Padding(padding: const EdgeInsets.only(left: 4), child: Text(ref.s('templates.shortcode.hint'), style: KlarisType.caption(mutedFg))),
            const SizedBox(height: 16),
            _Field(label: ref.s('templates.label'), child: _input(_label, hint: 'Merci pour la visite')),
            const SizedBox(height: 16),
            _Field(
              label: ref.s('templates.body'),
              child: CupertinoTextField(
                controller: _body,
                onChanged: (_) => setState(() {}),
                maxLines: 6, minLines: 4,
                decoration: BoxDecoration(color: context.klCard(), border: Border.all(color: context.klBorder()), borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(12),
                style: KlarisType.body(fg),
                placeholderStyle: KlarisType.body(mutedFg),
                placeholder: 'Bonjour {nom}, merci pour la visite à {secteur} aujourd\'hui...',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: context.klPrimarySoft(), borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ref.s('templates.placeholders'), style: KlarisType.eyebrow(context.klPrimary())),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final p in const ['{nom}', '{secteur}', '{budget}', '{courtier}'])
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minSize: 0,
                        color: context.klCard(),
                        borderRadius: BorderRadius.circular(6),
                        onPressed: () {
                          _body.text = '${_body.text}$p';
                          _body.selection = TextSelection.collapsed(offset: _body.text.length);
                          setState(() {});
                        },
                        child: Text(p, style: KlarisType.mono(context.klFg(), size: 11).copyWith(fontWeight: FontWeight.w600)),
                      ),
                  ]),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: KlarisType.bodySmall(KlarisColors.destructive)),
            ],
            if (isEdit) ...[
              const SizedBox(height: 24),
              CupertinoButton(
                color: KlarisColors.destructive.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                onPressed: () async {
                  await ref.read(templatesRepoProvider).delete(widget.existing!.id);
                  if (mounted) Navigator.of(context).pop();
                },
                child: Text(ref.s('templates.delete'), style: KlarisType.body(KlarisColors.destructive).copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, {required String hint, bool enabled = true}) {
    return CupertinoTextField(
      controller: c,
      enabled: enabled,
      onChanged: (_) => setState(() {}),
      decoration: BoxDecoration(
        color: enabled ? context.klCard() : context.klMuted(),
        border: Border.all(color: context.klBorder()),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(12),
      style: KlarisType.body(context.klFg()).copyWith(fontFamily: enabled ? null : 'GeistMono'),
      placeholder: hint,
      placeholderStyle: KlarisType.body(context.klMutedFg()),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  const _Field({required this.label, required this.child});
  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(left: 4, bottom: 6), child: Text(label, style: KlarisType.eyebrow(c.klMutedFg()))),
          child,
        ],
      );
}

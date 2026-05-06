import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/env.dart';
import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';

enum FeedbackKind { bug, feature, praise }

Future<void> showFeedbackSheet(BuildContext context, WidgetRef ref) async {
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (_) => const _FeedbackSheet(),
  );
}

class _FeedbackSheet extends ConsumerStatefulWidget {
  const _FeedbackSheet();

  @override
  ConsumerState<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends ConsumerState<_FeedbackSheet> {
  FeedbackKind _kind = FeedbackKind.feature;
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _sending = false;
  String? _result;
  bool _success = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _canSend => _title.text.trim().isNotEmpty && _body.text.trim().length >= 10;

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _result = null;
      _success = false;
    });
    try {
      final res = await Supabase.instance.client.functions.invoke('linear-feedback', body: {
        'kind': _kind.name,
        'title': _title.text.trim(),
        'body': _body.text.trim(),
        'app_version': Env.appVersion,
        'device_model': 'iOS',
      });
      if (res.status >= 400) throw Exception('status ${res.status}');
      setState(() {
        _result = ref.s('feedback.thanks');
        _success = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    } catch (e) {
      setState(() => _result = '$e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();

    return Container(
      decoration: BoxDecoration(color: context.klBg(), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 8, bottom: 12), decoration: BoxDecoration(color: context.klBorder(), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ref.s('feedback.title'), style: KlarisType.h2(fg)),
                    const SizedBox(height: 6),
                    Text(ref.s('feedback.subtitle'), style: KlarisType.bodySmall(mutedFg)),
                    const SizedBox(height: 18),

                    CupertinoSlidingSegmentedControl<FeedbackKind>(
                      groupValue: _kind,
                      onValueChanged: (v) { if (v != null) setState(() => _kind = v); },
                      children: {
                        FeedbackKind.bug:     Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), child: Text('🐞 ${ref.s('feedback.bug')}',     style: KlarisType.bodySmall(fg))),
                        FeedbackKind.feature: Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), child: Text('💡 ${ref.s('feedback.feature')}', style: KlarisType.bodySmall(fg))),
                        FeedbackKind.praise:  Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), child: Text('💛 ${ref.s('feedback.praise')}',  style: KlarisType.bodySmall(fg))),
                      },
                    ),

                    const SizedBox(height: 16),
                    CupertinoTextField(
                      controller: _title,
                      onChanged: (_) => setState(() {}),
                      decoration: BoxDecoration(color: context.klCard(), border: Border.all(color: context.klBorder()), borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(12),
                      placeholder: ref.s('feedback.title.hint'),
                      placeholderStyle: KlarisType.body(mutedFg),
                      style: KlarisType.body(fg),
                    ),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      controller: _body,
                      onChanged: (_) => setState(() {}),
                      maxLines: 5, minLines: 4,
                      decoration: BoxDecoration(color: context.klCard(), border: Border.all(color: context.klBorder()), borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.all(12),
                      placeholder: ref.s('feedback.body.hint'),
                      placeholderStyle: KlarisType.body(mutedFg),
                      style: KlarisType.body(fg),
                    ),

                    if (_result != null) ...[
                      const SizedBox(height: 12),
                      Text(_result!, style: KlarisType.bodySmall(_success ? KlarisColors.success : KlarisColors.destructive)),
                    ],

                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      borderRadius: BorderRadius.circular(12),
                      onPressed: !_canSend || _sending ? null : _send,
                      child: _sending
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : Text(ref.s('feedback.send'), style: KlarisType.body(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w700)),
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
}

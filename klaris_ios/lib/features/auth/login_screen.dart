import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/widgets/klaris_mascot.dart';
import '../../data/services/apple_auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AppleAuthService.instance.signIn();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
      // go_router redirect handles navigation on auth state change.
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = ref.s('auth.error.invalid'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final primary = context.klPrimary();
    final card = context.klCard();
    final border = context.klBorder();

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lang switcher (haut droit)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    color: card,
                    borderRadius: BorderRadius.circular(8),
                    minSize: 0,
                    onPressed: () => ref.read(langProvider.notifier).state =
                        lang == KlarisLang.fr ? KlarisLang.en : KlarisLang.fr,
                    child: Text(
                      lang == KlarisLang.fr ? 'EN' : 'FR',
                      style: KlarisType.mono(fg, size: 12).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Mascotte (taille moderee dans la nav d'auth)
              Center(child: KlarisMascot(size: 180)),

              const SizedBox(height: 16),

              // Title + subtitle
              Text(ref.s('auth.title'), textAlign: TextAlign.center, style: KlarisType.h1(fg)),
              const SizedBox(height: 8),
              Text(ref.s('auth.subtitle'), textAlign: TextAlign.center, style: KlarisType.body(mutedFg)),

              const SizedBox(height: 32),

              // Email
              _LabelField(
                label: ref.s('auth.email'),
                child: CupertinoTextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: BoxDecoration(
                    color: card,
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(14),
                  style: KlarisType.body(fg),
                  placeholder: 'joanel@nextmove.app',
                  placeholderStyle: KlarisType.body(mutedFg),
                ),
              ),
              const SizedBox(height: 14),

              // Password
              _LabelField(
                label: ref.s('auth.password'),
                child: CupertinoTextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: BoxDecoration(
                    color: card,
                    border: Border.all(color: border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(14),
                  style: KlarisType.body(fg),
                  placeholder: '••••••••',
                  placeholderStyle: KlarisType.body(mutedFg),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: KlarisColors.destructive.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: KlarisType.bodySmall(KlarisColors.destructive)),
                ),
              ],

              const SizedBox(height: 24),

              CupertinoButton.filled(
                borderRadius: BorderRadius.circular(12),
                onPressed: _loading ? null : _signIn,
                child: _loading
                    ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                    : Text(ref.s('auth.signin'), style: KlarisType.body(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w600)),
              ),

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: border)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(ref.s('auth.or'), style: KlarisType.caption(mutedFg))),
                  Expanded(child: Container(height: 1, color: border)),
                ],
              ),
              const SizedBox(height: 14),
              CupertinoButton(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(12),
                onPressed: _loading ? null : _signInWithApple,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.suit_heart, color: CupertinoColors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(ref.s('auth.apple'), style: KlarisType.body(CupertinoColors.white).copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: CupertinoButton(
                  onPressed: () {/* TODO: forgot flow */},
                  child: Text(ref.s('auth.forgot'), style: KlarisType.bodySmall(primary)),
                ),
              ),

              const SizedBox(height: 32),

              // Compliance footer
              Center(
                child: Text(
                  ref.s('auth.compliance'),
                  style: KlarisType.eyebrow(mutedFg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabelField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final mutedFg = context.klMutedFg();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: KlarisType.bodySmall(mutedFg).copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

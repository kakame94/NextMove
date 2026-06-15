import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/widgets/klaris_mascot.dart';

/// 5-step intro shown once on first launch.
/// Persisted via SharedPreferences key `klaris.onboarding_done`.
class OnboardingScreen extends ConsumerStatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  static const _seenKey = 'klaris.onboarding_done';

  static Future<bool> wasSeen() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_seenKey) ?? false;
  }

  static Future<void> markSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_seenKey, true);
  }

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _ctrl = PageController();
  int _idx = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await OnboardingScreen.markSeen();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final mutedFg = context.klMutedFg();
    const slidesCount = 5;

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minSize: 0,
                    onPressed: _finish,
                    child: Text(ref.s('onboarding.skip'), style: KlarisType.body(mutedFg)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _idx = i),
                children: [
                  _Slide(eyebrow: ref.s('ob.1.eyebrow'), title: ref.s('ob.1.title'), body: ref.s('ob.1.body'), withMascot: true),
                  _Slide(eyebrow: ref.s('ob.2.eyebrow'), title: ref.s('ob.2.title'), body: ref.s('ob.2.body'), icon: CupertinoIcons.chat_bubble_2_fill),
                  _Slide(eyebrow: ref.s('ob.3.eyebrow'), title: ref.s('ob.3.title'), body: ref.s('ob.3.body'), icon: CupertinoIcons.flame_fill),
                  _Slide(eyebrow: ref.s('ob.4.eyebrow'), title: ref.s('ob.4.title'), body: ref.s('ob.4.body'), icon: CupertinoIcons.calendar_badge_plus),
                  _Slide(eyebrow: ref.s('ob.5.eyebrow'), title: ref.s('ob.5.title'), body: ref.s('ob.5.body'), icon: CupertinoIcons.checkmark_shield_fill),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(slidesCount, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _idx ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _idx ? context.klPrimary() : context.klBorder(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                  const SizedBox(height: 20),
                  CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      if (_idx < slidesCount - 1) {
                        _ctrl.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
                      } else {
                        _finish();
                      }
                    },
                    child: Text(
                      _idx < slidesCount - 1 ? ref.s('onboarding.next') : ref.s('onboarding.start'),
                      style: KlarisType.body(KlarisColors.primaryFg).copyWith(fontWeight: FontWeight.w700),
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
}

class _Slide extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String body;
  final IconData? icon;
  final bool withMascot;
  const _Slide({required this.eyebrow, required this.title, required this.body, this.icon, this.withMascot = false});

  @override
  Widget build(BuildContext c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (withMascot)
            const KlarisMascot(size: 200)
          else if (icon != null)
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.klPrimarySoft(),
                border: Border.all(color: c.klPrimary(), width: 2),
              ),
              child: Icon(icon, size: 56, color: c.klPrimary()),
            ),
          const SizedBox(height: 28),
          Text(eyebrow, style: KlarisType.eyebrow(c.klMutedFg())),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: KlarisType.h1(c.klFg())),
          const SizedBox(height: 16),
          Text(body, textAlign: TextAlign.center, style: KlarisType.bodyLarge(c.klMutedFg())),
        ],
      ),
    );
  }
}

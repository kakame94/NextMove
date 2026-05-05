import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../prospects/prospects_list_screen.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final primary = context.klPrimary();

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: context.klCard(),
        activeColor: primary,
        inactiveColor: mutedFg,
        border: Border(top: BorderSide(color: context.klBorder(), width: 0.5)),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.person_2_square_stack),
            label: ref.s('tab.prospects'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.chat_bubble_2),
            label: ref.s('tab.conversations'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.bell),
            label: ref.s('tab.relances'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(CupertinoIcons.gear),
            label: ref.s('tab.settings'),
          ),
        ],
      ),
      tabBuilder: (ctx, i) {
        return CupertinoTabView(
          builder: (_) => switch (i) {
            0 => const ProspectsListScreen(),
            _ => _ComingSoon(label: switch (i) {
                1 => ref.s('tab.conversations'),
                2 => ref.s('tab.relances'),
                _ => ref.s('tab.settings'),
              }, fg: fg),
          },
        );
      },
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String label;
  final Color fg;
  const _ComingSoon({required this.label, required this.fg});

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        backgroundColor: context.klBg(),
        navigationBar: CupertinoNavigationBar(
          middle: Text(label, style: KlarisType.h3(fg)),
          backgroundColor: context.klCard().withValues(alpha: 0.85),
        ),
        child: Center(
          child: Text('Sprint 2', style: KlarisType.eyebrow(context.klMutedFg())),
        ),
      );
}

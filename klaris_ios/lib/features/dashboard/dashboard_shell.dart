import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../conversations/conversations_list_screen.dart';
import '../prospects/prospects_list_screen.dart';
import '../relances/relances_list_screen.dart';
import '../settings/settings_screen.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutedFg = context.klMutedFg();
    final primary = context.klPrimary();

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: context.klCard(),
        activeColor: primary,
        inactiveColor: mutedFg,
        border: Border(top: BorderSide(color: context.klBorder(), width: 0.5)),
        items: [
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.person_2_square_stack), label: ref.s('tab.prospects')),
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.chat_bubble_2),         label: ref.s('tab.conversations')),
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.bell),                  label: ref.s('tab.relances')),
          BottomNavigationBarItem(icon: const Icon(CupertinoIcons.gear),                  label: ref.s('tab.settings')),
        ],
      ),
      tabBuilder: (ctx, i) => CupertinoTabView(
        builder: (_) => switch (i) {
          0 => const ProspectsListScreen(),
          1 => const ConversationsListScreen(),
          2 => const RelancesListScreen(),
          _ => const SettingsScreen(),
        },
      ),
    );
  }
}

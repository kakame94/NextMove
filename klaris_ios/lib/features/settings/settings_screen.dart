import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../agency/agency_dashboard_screen.dart';
import '../feedback/feedback_sheet.dart';
import '../stats/stats_screen.dart';
import '../templates/templates_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final lang = ref.watch(langProvider);
    final theme = ref.watch(themeModeProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('tab.settings'), style: KlarisType.h3(fg)),
        border: Border(bottom: BorderSide(color: context.klBorder(), width: 0.5)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.klCard(),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.klBorder()),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.klPrimarySoft(),
                      border: Border.all(color: context.klPrimary(), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        (user?.email ?? '?').substring(0, 1).toUpperCase(),
                        style: KlarisType.h3(context.klPrimary()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.email ?? '—', style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(ref.s('settings.broker'), style: KlarisType.bodySmall(mutedFg)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _SectionLabel(text: ref.s('settings.appearance')),
            _SettingsCard(
              children: [
                _RowSegmented<KlarisThemeMode>(
                  label: ref.s('settings.theme'),
                  value: theme,
                  options: {
                    KlarisThemeMode.system: ref.s('settings.theme.system'),
                    KlarisThemeMode.light:  ref.s('settings.theme.light'),
                    KlarisThemeMode.dark:   ref.s('settings.theme.dark'),
                  },
                  onChanged: (v) => ref.read(themeModeProvider.notifier).set(v),
                ),
                _Divider(),
                _RowSegmented<KlarisLang>(
                  label: ref.s('settings.language'),
                  value: lang,
                  options: const {KlarisLang.fr: 'FR', KlarisLang.en: 'EN', KlarisLang.es: 'ES'},
                  onChanged: (v) => ref.read(langProvider.notifier).state = v,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _SectionLabel(text: ref.s('stats.title')),
            _SettingsCard(
              children: [
                _RowAction(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  label: ref.s('stats.title'),
                  hint: ref.s('stats.activity.sub'),
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    CupertinoPageRoute<void>(builder: (_) => const StatsScreen()),
                  ),
                ),
                _Divider(),
                _RowAction(
                  icon: CupertinoIcons.text_quote,
                  label: ref.s('templates.title'),
                  hint: ref.s('templates.hint'),
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    CupertinoPageRoute<void>(builder: (_) => const TemplatesScreen()),
                  ),
                ),
                _Divider(),
                _RowAction(
                  icon: CupertinoIcons.building_2_fill,
                  label: ref.s('agency.title'),
                  hint: ref.s('agency.hint'),
                  onTap: () => Navigator.of(context, rootNavigator: true).push(
                    CupertinoPageRoute<void>(builder: (_) => const AgencyDashboardScreen()),
                  ),
                ),
                _Divider(),
                _RowAction(
                  icon: CupertinoIcons.bubble_left_bubble_right_fill,
                  label: ref.s('feedback.title'),
                  hint: ref.s('feedback.hint'),
                  onTap: () => showFeedbackSheet(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _SectionLabel(text: ref.s('settings.privacy')),
            _SettingsCard(
              children: [
                _RowAction(
                  icon: CupertinoIcons.lock_shield,
                  label: ref.s('settings.optout'),
                  hint: ref.s('settings.optout.hint'),
                  onTap: () => _showOptOutSheet(context, ref),
                ),
                _Divider(),
                _RowAction(
                  icon: CupertinoIcons.doc_text,
                  label: ref.s('settings.dataExport'),
                  hint: ref.s('settings.dataExport.hint'),
                  onTap: () {/* TODO: trigger Supabase RPC export */},
                ),
                _Divider(),
                _RowAction(
                  icon: CupertinoIcons.bell_slash,
                  label: ref.s('settings.dnd'),
                  hint: ref.s('settings.dnd.hint'),
                  onTap: () {/* TODO */},
                ),
              ],
            ),

            const SizedBox(height: 24),

            _SectionLabel(text: ref.s('settings.about')),
            _SettingsCard(
              children: [
                _RowKV(label: ref.s('settings.version'), value: '0.1.0 · Sprint 2'),
                _Divider(),
                _RowKV(label: ref.s('settings.region'),  value: 'ca-central-1'),
                _Divider(),
                _RowKV(label: ref.s('settings.compliance'), value: 'OACIQ · Loi 25 · CASL'),
              ],
            ),

            const SizedBox(height: 24),

            CupertinoButton(
              color: KlarisColors.destructive.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
              },
              child: Text(
                ref.s('settings.signout'),
                style: KlarisType.body(KlarisColors.destructive).copyWith(fontWeight: FontWeight.w700),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showOptOutSheet(BuildContext c, WidgetRef ref) {
    showCupertinoModalPopup<void>(
      context: c,
      builder: (_) => CupertinoActionSheet(
        title: Text(ref.s('settings.optout.title'), style: KlarisType.bodySmall(c.klFg()).copyWith(fontWeight: FontWeight.w700)),
        message: Text(ref.s('settings.optout.body'), style: KlarisType.bodySmall(c.klMutedFg())),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              // TODO: Supabase RPC opt-out + cascade STOP outbound
              Navigator.of(c).pop();
            },
            child: Text(ref.s('settings.optout.confirm')),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(c).pop(),
          child: Text(ref.s('common.cancel')),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});
  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
        child: Text(text, style: KlarisType.eyebrow(c.klMutedFg())),
      );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});
  @override
  Widget build(BuildContext c) => Container(
        decoration: BoxDecoration(
          color: c.klCard(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.klBorder()),
        ),
        child: Column(children: children),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext c) => Container(height: 1, color: c.klBorder(), margin: const EdgeInsets.symmetric(horizontal: 14));
}

class _RowSegmented<T extends Object> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;
  const _RowSegmented({required this.label, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: KlarisType.bodySmall(c.klFg()).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          CupertinoSlidingSegmentedControl<T>(
            groupValue: value,
            onValueChanged: (v) { if (v != null) onChanged(v); },
            children: {
              for (final e in options.entries)
                e.key: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Text(e.value, style: KlarisType.bodySmall(c.klFg())),
                ),
            },
          ),
        ],
      ),
    );
  }
}

class _RowAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;
  const _RowAction({required this.icon, required this.label, required this.hint, required this.onTap});

  @override
  Widget build(BuildContext c) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: c.klMutedFg(), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: KlarisType.body(c.klFg()).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(hint, style: KlarisType.caption(c.klMutedFg())),
                ],
              ),
            ),
            Icon(CupertinoIcons.chevron_right, size: 16, color: c.klMutedFg()),
          ],
        ),
      ),
    );
  }
}

class _RowKV extends StatelessWidget {
  final String label;
  final String value;
  const _RowKV({required this.label, required this.value});

  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(label, style: KlarisType.body(c.klFg()))),
            Text(value, style: KlarisType.bodySmall(c.klMutedFg()).copyWith(fontFamily: 'GeistMono')),
          ],
        ),
      );
}

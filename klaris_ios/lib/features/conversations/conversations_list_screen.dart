import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/widgets/heat_indicator.dart';
import '../../data/models/conversation.dart';
import '../../data/repositories/conversations_repository.dart';

class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(conversationSummariesProvider);
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('tab.conversations'), style: KlarisType.h3(fg)),
        border: Border(bottom: BorderSide(color: context.klBorder(), width: 0.5)),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async => ref.invalidate(conversationSummariesProvider),
            ),
            async.when(
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(ref.s('conv.empty'), style: KlarisType.body(mutedFg))),
                  );
                }
                return SliverList.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: context.klBorder()),
                  itemBuilder: (_, i) => _ConversationTile(summary: list[i]),
                );
              },
              loading: () => const SliverFillRemaining(child: Center(child: CupertinoActivityIndicator(radius: 14))),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('${ref.s('common.error')} : $e', style: KlarisType.bodySmall(KlarisColors.destructive)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationTile extends ConsumerWidget {
  final ConversationSummary summary;
  const _ConversationTile({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final initials = (summary.prospectName ?? '?').trim().split(' ').map((p) => p.isEmpty ? '' : p[0]).take(2).join().toUpperCase();
    final timeStr = summary.lastSentAt != null ? _relativeTime(summary.lastSentAt!, ref.watch(langProvider)) : '';

    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      onPressed: () => context.push('/prospects/${summary.prospectId}/thread'),
      child: Container(
        color: context.klBg(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KlarisColors.heatFor(summary.prospectScore).withValues(alpha: 0.15),
                    border: Border.all(color: KlarisColors.heatFor(summary.prospectScore), width: 2),
                  ),
                  child: Center(child: Text(initials, style: KlarisType.bodySmall(KlarisColors.heatFor(summary.prospectScore)).copyWith(fontWeight: FontWeight.w700))),
                ),
                if (summary.unreadCount > 0)
                  Positioned(
                    right: -2, top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: context.klPrimary(),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: context.klBg(), width: 2),
                      ),
                      child: Text('${summary.unreadCount}', style: KlarisType.mono(KlarisColors.primaryFg, size: 10).copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          summary.prospectName ?? '—',
                          style: KlarisType.body(fg).copyWith(fontWeight: summary.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(timeStr, style: KlarisType.caption(mutedFg)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.lastMessage ?? '',
                    style: KlarisType.bodySmall(summary.unreadCount > 0 ? fg : mutedFg),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime t, KlarisLang lang) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) {
      return lang == KlarisLang.fr ? 'il y a ${diff.inMinutes}m' : '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return lang == KlarisLang.fr ? 'il y a ${diff.inHours}h' : '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) return DateFormat('EEE', lang.name).format(t);
    return DateFormat('d MMM', lang.name).format(t);
  }
}

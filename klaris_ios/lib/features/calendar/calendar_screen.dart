import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/models/appointment.dart';
import '../../data/repositories/appointments_repository.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = context.klFg();
    final selected = ref.watch(selectedDayProvider);
    final dayAsync = ref.watch(dayAppointmentsProvider);
    final lang = ref.watch(langProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('calendar.title'), style: KlarisType.h3(fg)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: () => context.push('/calendar/new'),
          child: Icon(CupertinoIcons.add_circled_solid, color: context.klPrimary(), size: 24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _WeekStrip(selected: selected),
            Expanded(
              child: dayAsync.when(
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (e, _) => Center(child: Text('$e', style: KlarisType.body(KlarisColors.destructive))),
                data: (list) {
                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.calendar_today, size: 48, color: context.klMutedFg()),
                            const SizedBox(height: 12),
                            Text(
                              DateFormat('EEEE d MMMM', lang.name).format(selected),
                              style: KlarisType.h3(fg),
                            ),
                            const SizedBox(height: 6),
                            Text(ref.s('calendar.empty'), textAlign: TextAlign.center, style: KlarisType.body(context.klMutedFg())),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _AppointmentCard(a: list[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStrip extends ConsumerWidget {
  final DateTime selected;
  const _WeekStrip({required this.selected});

  @override
  Widget build(BuildContext c, WidgetRef ref) {
    // Show 14 days centered on today.
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final start = today.subtract(const Duration(days: 3));
    final lang = ref.watch(langProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.klBorder()))),
      child: SizedBox(
        height: 72,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: 14,
          itemBuilder: (_, i) {
            final d = start.add(Duration(days: i));
            final isSel = d.year == selected.year && d.month == selected.month && d.day == selected.day;
            final isToday = d == today;
            return CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minSize: 0,
              onPressed: () => ref.read(selectedDayProvider.notifier).state = d,
              child: Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSel ? c.klPrimary() : c.klCard(),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSel ? c.klPrimary() : c.klBorder()),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE', lang.name).format(d).toUpperCase(),
                      style: KlarisType.eyebrow(isSel ? KlarisColors.primaryFg : c.klMutedFg()),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${d.day}',
                      style: KlarisType.h3(isSel ? KlarisColors.primaryFg : c.klFg()).copyWith(fontFamily: 'GeistMono'),
                    ),
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 5, height: 5,
                        decoration: BoxDecoration(color: isSel ? KlarisColors.primaryFg : c.klPrimary(), shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppointmentCard extends ConsumerWidget {
  final Appointment a;
  const _AppointmentCard({required this.a});

  @override
  Widget build(BuildContext c, WidgetRef ref) {
    final fg = c.klFg();
    final mutedFg = c.klMutedFg();
    final timeRange = '${DateFormat('HH:mm').format(a.startsAt)} → ${DateFormat('HH:mm').format(a.endsAt)}';
    final statusColor = switch (a.status) {
      AppointmentStatus.scheduled => c.klPrimary(),
      AppointmentStatus.completed => KlarisColors.success,
      AppointmentStatus.noShow    => KlarisColors.warning,
      AppointmentStatus.cancelled => KlarisColors.destructive,
    };

    return Container(
      decoration: BoxDecoration(
        color: c.klCard(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.klBorder()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Row(
              children: [
                Icon(CupertinoIcons.clock, size: 14, color: statusColor),
                const SizedBox(width: 6),
                Text(timeRange, style: KlarisType.bodySmall(statusColor).copyWith(fontFamily: 'GeistMono', fontWeight: FontWeight.w700)),
                const Spacer(),
                if (a.ekitEventId != null)
                  Tooltip(message: 'Synced to iOS Calendar', child: Icon(CupertinoIcons.calendar_badge_plus, size: 14, color: mutedFg)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.title, style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                if (a.prospectName != null)
                  Text(a.prospectName!, style: KlarisType.bodySmall(mutedFg)),
                if (a.location != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(CupertinoIcons.location, size: 13, color: mutedFg),
                    const SizedBox(width: 4),
                    Expanded(child: Text(a.location!, style: KlarisType.bodySmall(mutedFg))),
                  ]),
                ],
                if (a.notes != null && a.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(a.notes!, style: KlarisType.bodySmall(fg)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

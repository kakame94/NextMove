import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/services/notifications_service.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/models/prospect.dart';
import '../../data/repositories/appointments_repository.dart';
import '../../data/repositories/prospects_repository.dart';
import '../../data/services/eventkit_service.dart';

class CreateAppointmentScreen extends ConsumerStatefulWidget {
  final String? defaultProspectId;
  const CreateAppointmentScreen({super.key, this.defaultProspectId});

  @override
  ConsumerState<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends ConsumerState<CreateAppointmentScreen> {
  final _title = TextEditingController();
  final _location = TextEditingController();
  final _notes = TextEditingController();
  Prospect? _prospect;
  DateTime _startsAt = _roundedNextHour();
  Duration _duration = const Duration(minutes: 60);
  bool _addToCalendar = true;
  bool _saving = false;
  String? _error;

  static DateTime _roundedNextHour() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, n.hour + 1);
  }

  @override
  void initState() {
    super.initState();
    if (widget.defaultProspectId != null) {
      Future.microtask(() async {
        final p = await ref.read(prospectsRepoProvider).byId(widget.defaultProspectId!);
        if (mounted) setState(() => _prospect = p);
      });
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool get _canSave => _title.text.trim().isNotEmpty && _prospect != null;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final endsAt = _startsAt.add(_duration);
      String? ekitId;
      if (_addToCalendar) {
        final ok = await EventKitService.instance.requestAccess();
        if (ok) {
          ekitId = await EventKitService.instance.createEvent(
            title: _title.text.trim(),
            startsAt: _startsAt,
            endsAt: endsAt,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            location: _location.text.trim().isEmpty ? null : _location.text.trim(),
          );
        }
      }
      final created = await ref.read(appointmentsRepoProvider).create(
        prospectId: _prospect!.id,
        title: _title.text.trim(),
        startsAt: _startsAt,
        endsAt: endsAt,
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        location: _location.text.trim().isEmpty ? null : _location.text.trim(),
        ekitEventId: ekitId,
      );

      // Local reminder 15 min before. Skip if appt is < 15 min away.
      final remindAt = _startsAt.subtract(const Duration(minutes: 15));
      if (remindAt.isAfter(DateTime.now())) {
        if (await LocalNotificationsService.instance.requestPermission()) {
          await LocalNotificationsService.instance.scheduleAppointmentReminder(
            appointmentId: created.id,
            title: created.title,
            body: '${_prospect!.nom ?? ''} · ${_location.text.trim().isEmpty ? '15 min' : _location.text.trim()}',
            scheduledAt: remindAt,
          );
        }
      }

      ref.invalidate(upcomingAppointmentsProvider);
      ref.invalidate(dayAppointmentsProvider);
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
    final lang = ref.watch(langProvider);
    final dateStr = DateFormat('EEEE d MMMM, HH:mm', lang.name).format(_startsAt);

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('calendar.create.title'), style: KlarisType.h3(fg)),
        leading: CupertinoButton(padding: EdgeInsets.zero, minSize: 0, onPressed: () => Navigator.of(context).pop(), child: Text(ref.s('common.cancel'), style: KlarisType.body(context.klPrimary()))),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: !_canSave || _saving ? null : _save,
          child: _saving
              ? const CupertinoActivityIndicator()
              : Text(ref.s('create.save'), style: KlarisType.body(context.klPrimary()).copyWith(fontWeight: FontWeight.w700)),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Field(label: ref.s('calendar.create.label'), child: _input(_title, hint: 'Visite duplex Verdun', autofocus: true)),
            const SizedBox(height: 16),
            _Field(
              label: ref.s('calendar.create.prospect'),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                color: context.klCard(),
                borderRadius: BorderRadius.circular(10),
                onPressed: () => _pickProspect(context),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _prospect?.nom ?? ref.s('calendar.create.pick'),
                        style: KlarisType.body(_prospect == null ? mutedFg : fg).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(CupertinoIcons.chevron_right, size: 16, color: mutedFg),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Field(
              label: ref.s('calendar.create.when'),
              child: Container(
                decoration: BoxDecoration(color: context.klCard(), border: Border.all(color: context.klBorder()), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    CupertinoButton(
                      onPressed: () => _pickDate(context),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.calendar, size: 18, color: context.klPrimary()),
                          const SizedBox(width: 10),
                          Expanded(child: Text(dateStr, style: KlarisType.body(fg).copyWith(fontFamily: 'GeistMono'))),
                          Icon(CupertinoIcons.chevron_down, size: 14, color: mutedFg),
                        ],
                      ),
                    ),
                    Container(height: 1, color: context.klBorder()),
                    SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (final mins in const [30, 60, 90, 120])
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 0,
                              onPressed: () => setState(() => _duration = Duration(minutes: mins)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _duration.inMinutes == mins ? context.klPrimarySoft() : null,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '$mins min',
                                  style: KlarisType.bodySmall(_duration.inMinutes == mins ? context.klPrimary() : fg).copyWith(
                                    fontWeight: _duration.inMinutes == mins ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Field(label: ref.s('calendar.create.location'), child: _input(_location, hint: 'Cafe Olimpico, Mile-End')),
            const SizedBox(height: 16),
            _Field(
              label: ref.s('calendar.create.notes'),
              child: CupertinoTextField(
                controller: _notes,
                maxLines: 4, minLines: 3,
                decoration: BoxDecoration(color: context.klCard(), border: Border.all(color: context.klBorder()), borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(12),
                style: KlarisType.body(fg),
                placeholderStyle: KlarisType.body(mutedFg),
                placeholder: ref.s('calendar.create.notes.hint'),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(color: context.klCard(), borderRadius: BorderRadius.circular(10), border: Border.all(color: context.klBorder())),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ref.s('calendar.create.addToCal'), style: KlarisType.body(fg).copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(ref.s('calendar.create.addToCal.hint'), style: KlarisType.caption(mutedFg)),
                      ],
                    ),
                  ),
                  CupertinoSwitch(value: _addToCalendar, onChanged: (v) => setState(() => _addToCalendar = v), activeTrackColor: context.klPrimary()),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: KlarisType.bodySmall(KlarisColors.destructive)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, {required String hint, bool autofocus = false}) {
    return CupertinoTextField(
      controller: c,
      autofocus: autofocus,
      onChanged: (_) => setState(() {}),
      decoration: BoxDecoration(color: context.klCard(), border: Border.all(color: context.klBorder()), borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(12),
      style: KlarisType.body(context.klFg()),
      placeholder: hint,
      placeholderStyle: KlarisType.body(context.klMutedFg()),
    );
  }

  void _pickDate(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 280,
        color: context.klCard(),
        child: CupertinoDatePicker(
          initialDateTime: _startsAt,
          minimumDate: DateTime.now(),
          mode: CupertinoDatePickerMode.dateAndTime,
          minuteInterval: 15,
          use24hFormat: true,
          onDateTimeChanged: (d) => setState(() => _startsAt = d),
        ),
      ),
    );
  }

  Future<void> _pickProspect(BuildContext context) async {
    final list = await ref.read(prospectsRepoProvider).list();
    if (!context.mounted) return;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        decoration: BoxDecoration(color: context.klBg(), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        height: 480,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 8, bottom: 12), decoration: BoxDecoration(color: context.klBorder(), borderRadius: BorderRadius.circular(2))),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Text(ref.s('calendar.create.pick'), style: KlarisType.h2(context.klFg()))),
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: context.klBorder()),
                  itemBuilder: (_, i) {
                    final p = list[i];
                    return CupertinoButton(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.zero,
                      onPressed: () { setState(() => _prospect = p); Navigator.of(context).pop(); },
                      child: Container(
                        color: context.klBg(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(child: Text(p.nom ?? '—', style: KlarisType.body(context.klFg()).copyWith(fontWeight: FontWeight.w600))),
                            Text('${p.score}/10', style: KlarisType.mono(KlarisColors.heatFor(p.score), size: 12).copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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

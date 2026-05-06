import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/models/conversation.dart';
import '../../data/repositories/conversations_repository.dart';

class ConversationThreadScreen extends ConsumerStatefulWidget {
  final String prospectId;
  const ConversationThreadScreen({super.key, required this.prospectId});

  @override
  ConsumerState<ConversationThreadScreen> createState() => _ConversationThreadScreenState();
}

class _ConversationThreadScreenState extends ConsumerState<ConversationThreadScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Mark thread as read on open.
    Future.microtask(() => ref.read(conversationsRepoProvider).markRead(widget.prospectId));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final txt = _input.text.trim();
    if (txt.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(conversationsRepoProvider).sendAsBroker(prospectId: widget.prospectId, content: txt);
      _input.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(conversationThreadProvider(widget.prospectId));
    final fg = context.klFg();
    final lang = ref.watch(langProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('conv.thread.title'), style: KlarisType.h3(fg)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: async.when(
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (e, _) => Center(child: Text('$e', style: KlarisType.body(KlarisColors.destructive))),
                data: (msgs) {
                  // Auto-scroll to bottom on new messages.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scroll.hasClients) {
                      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                    }
                  });
                  if (msgs.isEmpty) {
                    return Center(child: Text(ref.s('conv.empty'), style: KlarisType.body(context.klMutedFg())));
                  }
                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    itemCount: msgs.length,
                    itemBuilder: (_, i) {
                      final m = msgs[i];
                      final showDateSep = i == 0 || !_sameDay(msgs[i - 1].sentAt, m.sentAt);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateSep) _DateSep(date: m.sentAt, lang: lang),
                          _Bubble(msg: m),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            _Composer(
              controller: _input,
              sending: _sending,
              onSend: _send,
              hint: ref.s('conv.composer.hint'),
              klarisHandover: ref.s('conv.composer.handover'),
            ),
          ],
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class _Bubble extends StatelessWidget {
  final Message msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isOut = !msg.isFromProspect;
    final isKlaris = msg.isFromKlaris;
    final time = DateFormat('HH:mm').format(msg.sentAt);

    final bg = isKlaris
        ? context.klPrimary()
        : isOut
            ? context.klMuted()
            : context.klCard();
    final fg = isKlaris ? KlarisColors.primaryFg : context.klFg();
    final align = isOut ? Alignment.centerRight : Alignment.centerLeft;
    final radius = isOut
        ? const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(4))
        : const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(18));

    return Align(
      alignment: align,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          crossAxisAlignment: isOut ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isKlaris)
              Padding(
                padding: const EdgeInsets.only(bottom: 3, right: 4),
                child: Text('Klaris', style: KlarisType.eyebrow(context.klMutedFg())),
              ),
            if (msg.isFromBroker)
              Padding(
                padding: const EdgeInsets.only(bottom: 3, right: 4),
                child: Text('Toi', style: KlarisType.eyebrow(context.klMutedFg())),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: radius,
                  border: !isKlaris && !isOut ? Border.all(color: context.klBorder()) : null,
                ),
                child: Text(msg.content, style: KlarisType.body(fg)),
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(time, style: KlarisType.caption(context.klMutedFg()).copyWith(fontFamily: 'GeistMono')),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSep extends StatelessWidget {
  final DateTime date;
  final KlarisLang lang;
  const _DateSep({required this.date, required this.lang});

  @override
  Widget build(BuildContext context) {
    final txt = DateFormat('EEEE d MMMM', lang.name).format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: context.klMuted(),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(txt, style: KlarisType.caption(context.klMutedFg()).copyWith(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final String hint;
  final String klarisHandover;
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.hint,
    required this.klarisHandover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: context.klCard(),
        border: Border(top: BorderSide(color: context.klBorder())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Text(klarisHandover, style: KlarisType.caption(context.klMutedFg())),
          ),
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  decoration: BoxDecoration(
                    color: context.klMuted(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  placeholder: hint,
                  placeholderStyle: KlarisType.body(context.klMutedFg()),
                  style: KlarisType.body(context.klFg()),
                  maxLines: 4,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: sending ? null : onSend,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: context.klPrimary(), shape: BoxShape.circle),
                  child: sending
                      ? const Padding(padding: EdgeInsets.all(10), child: CupertinoActivityIndicator(color: CupertinoColors.white))
                      : const Icon(CupertinoIcons.arrow_up, color: CupertinoColors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

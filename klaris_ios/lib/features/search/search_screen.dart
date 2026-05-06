import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../core/widgets/heat_indicator.dart';
import '../../data/models/prospect.dart';
import '../../data/repositories/search_repository.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.klBg(),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.klCard().withValues(alpha: 0.85),
        middle: Text(ref.s('search.title'), style: KlarisType.h3(fg)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: CupertinoSearchTextField(
                controller: _ctrl,
                focusNode: _focus,
                placeholder: ref.s('search.placeholder'),
                style: KlarisType.body(fg),
                placeholderStyle: KlarisType.body(mutedFg),
                onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
                onSubmitted: (v) => ref.read(searchQueryProvider.notifier).state = v,
              ),
            ),
            Expanded(
              child: query.trim().length < 2
                  ? _EmptyHint(text: ref.s('search.hint'))
                  : results.when(
                      loading: () => const Center(child: CupertinoActivityIndicator()),
                      error: (e, _) => _EmptyHint(text: ref.s('search.searching')),
                      data: (list) {
                        if (list.isEmpty) {
                          return _EmptyHint(text: ref.s('search.empty'));
                        }
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: context.klBorder()),
                          itemBuilder: (_, i) => _Hit(p: list[i], q: query),
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

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});
  @override
  Widget build(BuildContext c) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(text, textAlign: TextAlign.center, style: KlarisType.body(c.klMutedFg())),
        ),
      );
}

class _Hit extends StatelessWidget {
  final Prospect p;
  final String q;
  const _Hit({required this.p, required this.q});

  @override
  Widget build(BuildContext context) {
    final fg = context.klFg();
    final mutedFg = context.klMutedFg();
    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.zero,
      onPressed: () => context.push('/prospects/${p.id}'),
      child: Container(
        color: context.klBg(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KlarisColors.heatFor(p.score).withValues(alpha: 0.18),
                border: Border.all(color: KlarisColors.heatFor(p.score), width: 1.5),
              ),
              child: Center(child: Text((p.nom ?? '?').substring(0, 1).toUpperCase(), style: KlarisType.bodySmall(KlarisColors.heatFor(p.score)).copyWith(fontWeight: FontWeight.w700))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _highlight(p.nom ?? '—', q, KlarisType.body(fg).copyWith(fontWeight: FontWeight.w600), context.klPrimary()),
                  const SizedBox(height: 2),
                  Text(
                    [p.telephone, p.secteur, if (p.budget != null) p.budgetFormatted].whereType<String>().join(' · '),
                    style: KlarisType.bodySmall(mutedFg).copyWith(fontFamily: 'GeistMono'),
                  ),
                ],
              ),
            ),
            HeatLabel(score: p.score),
          ],
        ),
      ),
    );
  }

  Widget _highlight(String text, String q, TextStyle base, Color hi) {
    if (q.isEmpty) return Text(text, style: base);
    final lower = text.toLowerCase();
    final query = q.toLowerCase();
    final idx = lower.indexOf(query);
    if (idx < 0) return Text(text, style: base);
    return RichText(
      text: TextSpan(
        style: base,
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: base.copyWith(color: hi, fontWeight: FontWeight.w800, backgroundColor: hi.withValues(alpha: 0.10)),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}

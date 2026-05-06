import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/klaris_strings.dart';
import '../../core/theme/klaris_colors.dart';
import '../../core/theme/klaris_typography.dart';
import '../../data/models/agency.dart';
import '../../data/repositories/agency_repository.dart';
import '../../data/repositories/prospects_repository.dart';

/// Modal sheet — admin/manager reassigns a prospect to another team member.
Future<void> showLeadAssignSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String prospectId,
}) async {
  final myAgency = await ref.read(myAgencyProvider.future);
  if (myAgency == null) return;
  if (myAgency.role == AgencyRole.broker) return; // not authorized
  final team = await ref.read(agencyTeamProvider(myAgency.agency.id).future);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(ref.s('agency.assign.title'), style: KlarisType.h2(context.klFg())),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: team.length,
                separatorBuilder: (_, __) => Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: context.klBorder()),
                itemBuilder: (_, i) {
                  final m = team[i];
                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.zero,
                    onPressed: () async {
                      await ref.read(agencyRepoProvider).reassignProspect(prospectId: prospectId, toUserId: m.userId);
                      ref.invalidate(prospectsProvider);
                      ref.invalidate(prospectByIdProvider(prospectId));
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Container(
                      color: context.klBg(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: context.klPrimarySoft(), border: Border.all(color: context.klPrimary(), width: 1.5)),
                            child: Center(child: Text(m.email.substring(0, 1).toUpperCase(), style: KlarisType.bodySmall(context.klPrimary()).copyWith(fontWeight: FontWeight.w700))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.email, style: KlarisType.body(context.klFg()).copyWith(fontWeight: FontWeight.w600)),
                                Text('${m.totalProspects} prospects · ${m.hotProspects} 🔥', style: KlarisType.bodySmall(context.klMutedFg())),
                              ],
                            ),
                          ),
                          Icon(CupertinoIcons.chevron_right, size: 16, color: context.klMutedFg()),
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

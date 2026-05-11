# Klaris — NPS courtiers — Spec d'implémentation

> **Action 2 du plan post-challenge BMC.** Implémenter le KVM Customer Satisfaction (Net Promoter Score) côté courtier, identifié comme critique manquant (cf. `business-canvas-challenge.md` §5).
> **Source méthodologique :** *The Professional Product Owner* Ch3 Customer Satisfaction (NPS scale 0-10).
> **Sprint cible :** Sprint 8.
> Date : 2026-05-08

---

## 1 — Objectif & métrique

**Question NPS standard (Ch3 livre) :**
> *« Sur une échelle de 0 à 10, quelle est la probabilité que vous recommandiez Klaris à un autre courtier ? »*

**Calcul.**
- **Promoteurs** : score 9-10
- **Passifs** : score 7-8 (exclus du calcul)
- **Détracteurs** : score 0-6
- **NPS** = `% Promoteurs − % Détracteurs` (range −100 à +100)

**Cibles Klaris.**

| Horizon | NPS cible | Sample size minimum |
|---------|-----------|---------------------|
| M3 | 1re mesure (baseline) | n ≥ 1 (Joanel) |
| M6 | NPS > 0 | n ≥ 5 |
| M9 | NPS > 30 | n ≥ 15 |
| M12 | NPS > 50 (excellent) | n ≥ 30 |

---

## 2 — Schéma de données — migration 008

**Fichier :** `klaris_ios/migrations/008_sprint8_nps.sql`

```sql
-- Sprint 8 — NPS courtiers
-- Spec: 24_NextMove/docs/nps-spec.md

create table public.nps_responses (
  id           uuid primary key default gen_random_uuid(),
  broker_id    uuid not null references public.brokers(id) on delete cascade,
  score        smallint not null check (score between 0 and 10),
  comment      text,
  context      text not null check (context in (
                  'onboarding_d7',     -- 7 jours après onboarding
                  'milestone_first_lead', -- après 1er lead qualifié auto
                  'recurring_q',       -- relance trimestrielle
                  'churn_intent'       -- déclenchée si signaux churn
               )),
  app_version  text,
  platform     text check (platform in ('ios', 'web')),
  created_at   timestamptz not null default now()
);

create index idx_nps_responses_broker on public.nps_responses(broker_id);
create index idx_nps_responses_created on public.nps_responses(created_at desc);

-- RLS
alter table public.nps_responses enable row level security;

create policy nps_broker_self_select on public.nps_responses
  for select using (broker_id = auth.uid());

create policy nps_broker_self_insert on public.nps_responses
  for insert with check (broker_id = auth.uid());

-- Pas d'update : un score est définitif. Ré-questionnement = nouvelle ligne.

-- View agrégée pour dashboard interne
create view public.nps_summary as
select
  date_trunc('month', created_at) as month,
  count(*) as n_responses,
  count(*) filter (where score >= 9) as promoters,
  count(*) filter (where score between 7 and 8) as passives,
  count(*) filter (where score <= 6) as detractors,
  round(
    100.0 * count(*) filter (where score >= 9) / nullif(count(*), 0)
    -
    100.0 * count(*) filter (where score <= 6) / nullif(count(*), 0)
  , 1) as nps,
  context
from public.nps_responses
group by month, context
order by month desc;

-- View accessible aux admins seulement (à scoper si rôle admin existe)
grant select on public.nps_summary to authenticated;

-- Seed pas de données — la première mesure est Joanel post-onboarding M3.
```

---

## 3 — UI iOS (Flutter)

**Fichiers à créer.**
- `klaris_ios/lib/features/nps/nps_sheet.dart`
- `klaris_ios/lib/features/nps/nps_controller.dart` (Riverpod)
- `klaris_ios/lib/data/repositories/nps_repository.dart`
- Test : `klaris_ios/test/nps_sheet_test.dart`

**UX.**

1. **Trigger (4 contextes).**
   - `onboarding_d7` : 7 jours après création du compte broker → modale lancée à l'ouverture de l'app.
   - `milestone_first_lead` : déclenchée la 1re fois qu'un lead est qualifié automatiquement → bottom sheet non-bloquant.
   - `recurring_q` : tous les 90 jours, déclenchée à l'ouverture si pas de réponse depuis 90 j.
   - `churn_intent` : si broker n'a pas ouvert l'app pendant 14 jours puis revient → bottom sheet.

2. **Composant.**
   - Cupertino bottom sheet, swipe-to-dismiss (mais comptabilisé comme "skipped" → pas en DB).
   - Question : *« Sur 0 à 10, quelle est la probabilité que vous recommandiez Klaris à un autre courtier ? »*
   - 11 boutons ronds (0 à 10) avec dégradé rouge → vert.
   - Champ commentaire optionnel : *« Pourquoi ce score ? (facultatif) »* — max 500 chars.
   - Bouton « Envoyer » (désactivé tant que score non sélectionné).

3. **Confirmation.**
   - Score 9-10 : *« Merci ! Voulez-vous nous recommander à un collègue ? »* + bouton CTA referral.
   - Score 7-8 : *« Merci ! Qu'est-ce qui ferait passer Klaris à 10 ? »* + champ libre.
   - Score 0-6 : *« Merci pour votre franchise. Eliot ou Dennis vous appellera dans les 48 h. »* + déclenche email interne.

**Code template (`nps_sheet.dart` extrait).**

```dart
// klaris_ios/lib/features/nps/nps_sheet.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nps_controller.dart';

class NpsSheet extends ConsumerStatefulWidget {
  const NpsSheet({super.key, required this.context});
  final String context; // 'onboarding_d7' | 'milestone_first_lead' | ...

  static Future<void> show(BuildContext ctx, String context) {
    return showCupertinoModalPopup(
      context: ctx,
      builder: (_) => NpsSheet(context: context),
    );
  }

  @override
  ConsumerState<NpsSheet> createState() => _NpsSheetState();
}

class _NpsSheetState extends ConsumerState<NpsSheet> {
  int? _score;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: const Text('Sur 0 à 10, quelle est la probabilité que vous '
          'recommandiez Klaris à un autre courtier ?'),
      message: Column(children: [
        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          children: List.generate(11, (i) => _ScoreButton(
            value: i,
            selected: _score == i,
            onTap: () => setState(() => _score = i),
          )),
        ),
        const SizedBox(height: 12),
        CupertinoTextField(
          controller: _commentController,
          placeholder: 'Pourquoi ce score ? (facultatif)',
          maxLines: 3,
          maxLength: 500,
        ),
      ]),
      actions: [
        CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: _score == null ? () {} : _submit,
          child: const Text('Envoyer'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDestructiveAction: true,
        onPressed: () => Navigator.pop(context),
        child: const Text('Plus tard'),
      ),
    );
  }

  Future<void> _submit() async {
    final controller = ref.read(npsControllerProvider.notifier);
    await controller.submit(
      score: _score!,
      comment: _commentController.text.trim(),
      context: widget.context,
    );
    if (!mounted) return;
    Navigator.pop(context);
    _showThankYou();
  }

  void _showThankYou() {
    final score = _score!;
    final message = score >= 9
        ? 'Merci ! Voulez-vous nous recommander à un collègue ?'
        : score >= 7
            ? 'Merci ! Qu\'est-ce qui ferait passer Klaris à 10 ?'
            : 'Merci pour votre franchise. Eliot ou Dennis vous '
              'appellera dans les 48 h.';
    showCupertinoDialog(context: context, builder: (_) => CupertinoAlertDialog(
      title: const Text('Merci'),
      content: Text(message),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ));
  }
}

// _ScoreButton widget : laissé à l'implémentation Sprint 8.
```

---

## 4 — UI Web (Next.js)

**Fichiers à créer.**
- `klaris_web/src/components/nps/NpsModal.tsx`
- `klaris_web/src/lib/api/nps.ts` (client Supabase)
- Hook `useNpsTrigger()` qui décide quand afficher selon les 4 contextes.

**Différences avec iOS.**
- Modale React custom (Tailwind + Headless UI).
- Triggers basés sur events Supabase realtime + dates dans `localStorage`.
- Même logique conditionnelle de remerciement.

---

## 5 — Triggers serveur (Edge Function)

**Fichier :** `klaris_ios/supabase/functions/nps-scheduler/index.ts`

Edge Function Deno scheduled (cron quotidien 09:00 UTC) qui :
1. Identifie les brokers éligibles à un trigger NPS (par contexte).
2. Insère un payload dans `nps_pending` (table simple `broker_id, context, due_at`).
3. L'app iOS/web lit `nps_pending` à l'ouverture et déclenche la modale si entrée non consommée.

**Pseudo-code :**

```typescript
// supabase/functions/nps-scheduler/index.ts
import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js";

serve(async () => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  // 1. onboarding_d7 — brokers créés il y a exactement 7 jours
  const { data: d7Brokers } = await supabase
    .from("brokers")
    .select("id, created_at")
    .gte("created_at", "now() - interval '7 days'")
    .lt("created_at", "now() - interval '6 days'");

  // 2. recurring_q — pas de NPS depuis 90 jours
  const { data: recurringBrokers } = await supabase.rpc(
    "brokers_due_for_recurring_nps"
  );

  // 3. churn_intent — pas d'app open depuis 14 jours puis dernier sign-in <24h
  // (logique à affiner avec données analytics)

  // Insérer dans nps_pending pour chaque broker éligible
  // Log + retourner count

  return new Response(JSON.stringify({ ok: true }));
});
```

---

## 6 — Reporting

**Dashboard interne :** ajout d'un widget « NPS du mois » dans le rapport mensuel EBM (cf. [ebm-time-tracking-spec.md](./ebm-time-tracking-spec.md) §6).

**Source de la donnée :**
```sql
select * from public.nps_summary
where month = date_trunc('month', now())
order by context;
```

**Alerte automatique (Sprint 9) :**
- Edge Function `nps-alert` exécutée hebdomadaire.
- Si NPS du mois < 0 OU si > 2 détracteurs cette semaine → email à `team@klaris.app`.

---

## 7 — Suivi

- [ ] Sprint 8 : migration 008 + UI iOS NpsSheet + 1re mesure Joanel
- [ ] Sprint 8 : UI web (NpsModal) si bandwidth
- [ ] Sprint 9 : Edge Function `nps-scheduler`
- [ ] Sprint 9 : Edge Function `nps-alert`
- [ ] Sprint 10 : intégrer NPS au reporting mensuel `ebm-reports/2026-06.md`
- [ ] M3 : recalibrer cibles si Joanel donne signaux contre-intuitifs
- [ ] M6 : décision Pivot/Persevere basée sur tendance NPS 3 mois

---

*Document v1.0 — 2026-05-08*

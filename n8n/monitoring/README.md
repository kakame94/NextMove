# Monitoring Klaris (pilote Maxime Belma)

Mis en place le 2026-10-27. Tout tourne dans n8n (n8n.srv775529.hstgr.cloud). Les alertes vont par SMS au +1 450 626-0481 et par courriel à denis.k@optiai-solutions.com.

| Workflow n8n | ID | Rôle |
|---|---|---|
| next_move_error_handler | `4jPCKbGJ2Z55gNjF` | Error workflow de l'intake, du formulaire, de la notification et des 3 workflows ci-dessous. Envoie un SMS et un courriel, avec au plus une alerte par workflow toutes les 15 min. Journalise chaque erreur dans `monitoring_events`. |
| Klaris — Surveillance (10 min) | `sOoVjahAoTe76b5k` | Repère les prospects sans réponse depuis plus de 5 min, les formulaires sans premier SMS, les leads chauds non transmis et les SMS Twilio non livrés. Chaque anomalie n'est signalée qu'une fois (staticData, 48 h). |
| Klaris — Rapport du matin (8 h) | `VKOjEetTPhV4LEW5` | Envoie chaque matin à denis.k@ un courriel avec les chiffres de la veille, la santé technique et le résultat de la QA de la nuit. |
| Klaris — QA des vraies conversations (2 h) | `eXX1oGuyxf0bMKdK` | Fait noter par claude-sonnet-5-5 (outil `noter_conversation`) les conversations actives des dernières 24 h. Écrit dans `eval_results` (`scenario_category = 'reel'`, réussite à partir de 80/100), ce qui alimente l'onglet QA du dashboard. |

Requêtes SQL : voir `queries.sql`.

Table `public.monitoring_events` (migration `monitoring_events`) : RLS activé, aucune policy, donc invisible pour le dashboard.

## Limites connues
- **Anti-spam des erreurs :** deux erreurs dans la même seconde déclenchent toutes les deux une alerte, parce que le staticData n'est enregistré qu'à la fin de l'exécution.
- **SMS d'alerte :** ils partent du numéro de Klaris. Une réponse à ces SMS entrerait dans l'intake comme un message de prospect, d'où la mention « Ne pas répondre ».
- **Erreurs silencieuses :** dans l'intake, « Send Lead to owner » est en `continueRegularOutput`. Une erreur Twilio à cet endroit ne passe pas par le gestionnaire d'erreurs. Elle reste visible dans la surveillance seulement si Twilio a accepté puis échoué la livraison.
- **Notification marquée même en cas d'échec :** dans next_move_notify_courtier, « Marquer Notifié » s'exécute même si le courriel a échoué (`continueOnFail`).
- **Visibilité de la QA :** depuis le 2026-10-27, l'onglet QA est masqué dans le dashboard et `eval_results` n'est plus lisible par les courtiers (policy `eval_results_select_auth` supprimée). Les notes sont consultables dans le rapport du matin et dans Supabase.

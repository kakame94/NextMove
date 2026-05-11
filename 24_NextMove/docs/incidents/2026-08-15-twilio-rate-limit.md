# Incident 2026-08-15 — Twilio Rate Limit Cascade (EXEMPLE FICTIF)

> ⚠️ **EXEMPLE D'ONBOARDING** — pas un incident réel. Sert de modèle pour les vrais post-mortems.

## Métadonnées

- **Date début** : 2026-08-15 00:01 (UTC)
- **Date résolution** : 2026-08-15 03:45 (UTC)
- **Durée** : 3h44min
- **Severité** : P0 (SMS bloqués pour 12 courtiers)
- **Service impacté** : Twilio + n8n
- **N courtiers affectés** : 12 (sur 15 actifs)
- **N prospects affectés** : ~80 (SMS reçus mais réponse retardée)
- **On-call** : @Eliot (rotation S2)
- **Post-mortem owner** : @Eliot

## Résumé exécutif

À minuit pile, le cron n8n a déclenché 200 relances SMS en simultané. Twilio rate limit (100 SMS/min/numéro) a renvoyé 429. n8n retry boucle infinie. Service dégradé pour 12 courtiers pendant 3h44min. Résolu après ajout circuit breaker + spread temporel cron.

## Timeline

| HH:MM | Événement |
|-------|-----------|
| 00:01 | Cron n8n déclenche batch 200 relances |
| 00:02 | 1ère erreur Sentry 429 Twilio |
| 00:03 | Slack alerte déclenchée dans `#klaris-incidents` |
| 00:18 | On-call ack (Eliot réveillé par notif iPhone) |
| 00:35 | Investigation : confirmation rate limit cron-batch |
| 01:10 | Hotfix : `setTimeout` à 500ms entre chaque SMS dans n8n |
| 01:25 | Hotfix déployé en prod n8n |
| 01:30 | File de retry vidée (300 SMS) |
| 03:45 | Service entièrement restauré, dernier prospect catch-up envoyé |

## Symptôme observable

- Courtiers Joanel + 11 autres ouvrent leur app à 6h30, voient « 0 nouveau prospect » alors qu'ils ont reçu des SMS la veille.
- 3 courtiers nous appellent en panique (« mes prospects n'ont pas reçu mes relances ! »).

## 5 Whys

1. **Pourquoi les SMS n'ont pas été envoyés ?**
   → Twilio a renvoyé 429 rate limit (100 SMS/min).

2. **Pourquoi le rate limit a été atteint ?**
   → n8n a déclenché 200 relances en 1 seconde à minuit.

3. **Pourquoi 200 d'un coup ?**
   → Le cron `relances-quotidiennes` itère sur **toutes** les relances dues sans backoff.

4. **Pourquoi pas de backoff/spread temporel ?**
   → Spec initiale Sprint 2 : « envoie toutes les relances dues à minuit ». Pas de revue depuis.

5. **Pourquoi jamais reconsidérée la spec ?**
   → **Cause racine HUMAINE** : pas de processus de revue post-incident → spec écrite il y a 6 mois jamais re-challengée. Pas de monitoring sender score (S1-S5) → pas d'alerte précoce.

## Actions correctives

| Type | Action | Owner | Sprint |
|------|--------|-------|--------|
| 🔧 Tech (court terme) | Hotfix `setTimeout` 500ms entre SMS | Eliot | Fait ✅ |
| 🔧 Tech (long terme) | Vraie circuit breaker n8n + retry budget (cf. R7 archi-challenge) | Dennis | Sprint 10 |
| 🔧 Tech (long terme) | Cron spread aléatoire : window 00:00-02:00 au lieu de pic 00:00 | Dennis | Sprint 9 |
| 🔧 Tech (long terme) | Sender score monitoring + alerte si < 97 | Dennis | Sprint 9 |
| 👥 Process | Tous les cron Klaris reviewés trimestriellement (cadence Pivot/Persevere) | Eliot | Q1 |
| 👥 Process | Runbook « Twilio 429 incident » dans `incidents/runbooks/` | Eliot | Sprint 9 |
| 👥 Process | Health check `/health` n8n + Better Stack alerte SMS on-call | Dennis | Sprint 9 |

## Impact business

- MRR perdu : ~0 CAD (pas de churn immédiat mais 1 courtier menace de quitter si récidive)
- Nb courtiers à recontacter : 3 (apologie + crédit 10% mois)
- Risque réputation : moyen
- SLA breach (RTO 4h cible) : NON (résolu en 3h44min)

## Communication courtiers

- [x] Email transparence envoyé aux 12 courtiers affectés (sortie le 2026-08-15 09:00)
- [x] Crédit 10% appliqué à 3 courtiers qui ont contacté
- [ ] Pas de status page publique (à créer Sprint 10)

## Leçons apprises

1. **Cron synchrones = bombe à retardement.** Jamais déclencher N actions à la même seconde quand N peut grandir.
2. **Spec d'il y a 6 mois ≠ spec valable aujourd'hui.** Volume × 10 = besoin de re-challenger.
3. **Slack alertes minuit = pas suffisant.** On-call doit avoir alerte SMS séparée (Better Stack ou PagerDuty).

## Validation

- [x] Post-mortem partagé en Sprint Review 2026-08-22
- [x] Actions correctives ajoutées au backlog Linear (tickets KLA-234 à KLA-240)
- [x] Pas de blame — focus processus, pas individus

---

*Post-mortem fictif créé 2026-05-08 pour onboarding — owner @Eliot*

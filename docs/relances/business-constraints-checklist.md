# NextMove — Contraintes Business & Légales

> Checklist de toutes les contraintes opérationnelles, réglementaires et commerciales
> qui doivent être intégrées au système de relance.

**Statut :** Brouillon à valider avec Joanel
**Dernière mise à jour :** 2026-04-17

---

## 1. Contraintes légales (non négociables)

### 1.1 Loi 25 Québec — Protection des renseignements personnels

| # | Exigence | Impact système | Statut |
|---|----------|----------------|--------|
| L1 | **Consentement explicite** pour toute communication marketing | Opt-in obligatoire avant T9 (réactivation email) | ☐ À vérifier |
| L2 | **Opt-out immédiat** (STOP) respecté dans les 10 jours | Blacklist propagée en < 1h (idéalement temps réel) | ☐ À implémenter |
| L3 | **Information sur la finalité** des données collectées | Mention dans premier SMS : "Vos données servent à vous contacter via NextMove" | ☐ À rédiger |
| L4 | **Droit d'accès, rectification, suppression** | Endpoint API + procédure RGPD à documenter | ☐ Post-MVP |
| L5 | **Responsable de la protection des renseignements** | Joanel ? Déclaration CAI Québec requise si > 50 employés | ☐ À confirmer |
| L6 | **Notification en cas d'incident** de confidentialité | Procédure à définir + contact CAI | ☐ Post-MVP |

**Amendes :** jusqu'à **10 M CAD ou 2% du chiffre d'affaires mondial**, selon le plus élevé.

### 1.2 CASL (Canadian Anti-Spam Legislation)

| # | Exigence | Impact système | Statut |
|---|----------|----------------|--------|
| C1 | **Identification claire de l'expéditeur** dans chaque message | Footer SMS : "— NextMove pour [Nom Courtier]" | ☐ À rédiger |
| C2 | **Mécanisme de désabonnement fonctionnel** | STOP pour SMS, lien pour email | ☐ À implémenter |
| C3 | **Consentement exprès ou tacite documenté** | Log du consentement initial (timestamp + source) | ☐ À implémenter |
| C4 | **Validité du consentement** : 2 ans si tacite | T9 (réactivation) respecte cette limite | ☐ À implémenter |

**Amendes :** jusqu'à **10 M CAD par infraction** pour les entreprises.

### 1.3 Twilio Messaging Policy

| # | Exigence | Impact système | Statut |
|---|----------|----------------|--------|
| T1 | **Opt-out keywords reconnus** : STOP, UNSUBSCRIBE, ARRÊT, STOPPER | Parser n8n doit reconnaître ces variantes | ☐ À vérifier |
| T2 | **HELP keyword** retourne infos | Template HELP à définir | ☐ À rédiger |
| T3 | **Volumétrie maîtrisée** : pas de spike > 100 SMS/min par numéro | Rate-limit dans n8n | ☐ À implémenter |
| T4 | **Contenu conforme** : pas de SHAFT (Sex, Hate, Alcohol, Firearms, Tobacco) | Non applicable à NextMove | ✅ OK |

---

## 2. Contraintes opérationnelles

### 2.1 Horaires et calendrier

| # | Règle | Détail |
|---|-------|--------|
| O1 | **Pas d'envoi prospect** avant 8h ou après 20h heure locale QC | G8 matrice M2 |
| O2 | **Pas d'envoi prospect les jours fériés QC** | G9 matrice M2 (voir liste 2026) |
| O3 | **Pas d'envoi prospect le dimanche** | ☐ À valider — ou permis ? |
| O4 | **Courtier recevable 7j/7 pour urgences** | T5 (nudge urgent) actif weekend |
| O5 | **Golden hour** Mar-Jeu 10h-12h pour meilleur taux de réponse | Hypothèse, à valider avec données Joanel |

### 2.2 Volumétrie et coûts

| # | Contrainte | Valeur | Source |
|---|------------|--------|--------|
| V1 | **Budget Twilio + infra mensuel** | **35-50 CAD** (Figma Sprint MVP) | Déjà validé équipe |
| V2 | **Coût par SMS Canada** | ~0.015 CAD | Tarifs Twilio 2026 |
| V3 | **Volume estimé MVP** | 1 courtier pilote (Joanel) × 10-20 prospects = ~50-100 SMS/mois = ~2 CAD Twilio | Sprint 1 |
| V4 | **Alerte budget** | Si > 80% du budget mensuel consommé (= 28 CAD) | À implémenter |
| V5 | **Numéros Twilio canadiens** | Nécessaire pour éviter SMS internationaux coûteux | ☐ À vérifier |
| V6 | **Canal alternatif** | Telegram envisagé "dans un premier temps" (Figma) | ☐ À clarifier |

### 2.3 Sender score et réputation

| # | Règle | Seuil |
|---|-------|-------|
| S1 | **Maintien sender score** | > 97/100 |
| S2 | **Taux de spam reports** | < 3% |
| S3 | **Taux de réponse minimal** | > 8% (sinon risque flag) |
| S4 | **Action si sender score < 97** | Defer 2h + alerte admin |
| S5 | **Action si sender score < 90** | Block temporaire + investigation |

---

## 3. Contraintes commerciales (à valider Joanel)

### 3.1 Exclusions VIP

| # | Question | Hypothèse | Validé ? |
|---|----------|-----------|----------|
| VIP1 | Existe-t-il des prospects/clients VIP à exclure du système automatique ? | Oui, flag `vip = true` sur prospect | ☐ |
| VIP2 | Comment Joanel identifie-t-il les VIP ? | Manuel dans l'interface courtier | ☐ |
| VIP3 | Les VIP reçoivent-ils toujours les rappels RDV ? | Oui, uniquement T6 autorisé | ☐ |

### 3.2 Segmentation par type de bien

| # | Question | Hypothèse | Validé ? |
|---|----------|-----------|----------|
| B1 | Tous les types de biens (condo, maison, commercial) relèvent-ils du même flow ? | Oui MVP, segmentation Post-MVP | ☐ |
| B2 | Y a-t-il des biens sensibles (luxury, off-market) à traiter différemment ? | Non par défaut | ☐ |

### 3.3 Politique de "perdu"

| # | Question | Hypothèse | Validé ? |
|---|----------|-----------|----------|
| P1 | Après combien de temps/relances un prospect est-il marqué "perdu" automatiquement ? | Après T3 sans réponse + 7j | ☐ |
| P2 | Un prospect "perdu" est-il supprimé ? Archivé ? | Archivé, soft-delete, RGPD 7 ans | ☐ |
| P3 | Peut-on le réactiver automatiquement (T9) ou manuellement seulement ? | Automatique si opt-in email | ☐ |

### 3.4 Notifications au courtier

| # | Question | Hypothèse | Validé ? |
|---|----------|-----------|----------|
| N1 | Canal préféré pour notifs courtier : email ? push ? SMS ? | Push push (PWA) + email fallback | ☐ |
| N2 | Fréquence agrégée ? Ou notif par événement ? | Par événement mais avec dedup 1h | ☐ |
| N3 | Notifications activables/désactivables par type ? | Oui, préférences par courtier | ☐ |

### 3.5 Tonalité et langue

| # | Question | Hypothèse | Validé ? |
|---|----------|-----------|----------|
| T1 | Tutoyer ou vouvoyer les prospects ? | Vouvoiement (professionnel) | ☐ |
| T2 | Langue par défaut | Français Québec, anglais si détecté | ☐ |
| T3 | Signature : nom du courtier ou "NextMove" ? | "NextMove pour [Nom Courtier]" | ☐ |
| T4 | Emoji autorisés ? | Oui, modérément (1 par message max) | ☐ |

---

## 4. Contraintes techniques

### 4.1 Données et intégrité

| # | Règle |
|---|-------|
| D1 | Toute relance envoyée doit être tracée dans `relances` (ID, timestamp, status, payload) |
| D2 | Les blocages (G1-G13) doivent être logués avec raison dans `relances_blocked_log` |
| D3 | Un prospect ne peut recevoir une relance sans `courtier_id` valide |
| D4 | Les timestamps sont en UTC en DB, convertis en Montreal timezone pour affichage |

### 4.2 Disponibilité et fiabilité

| # | SLA |
|---|-----|
| A1 | Scheduler disponible > 99% (tolérance 1 cron manqué = OK) |
| A2 | Temps de réponse Twilio < 5s (sinon retry 1x puis fail) |
| A3 | Backup quotidien Supabase |
| A4 | Monitoring : Grafana ou Supabase dashboard minimal |

### 4.3 Sécurité

| # | Règle |
|---|-------|
| X1 | RLS activée sur toutes les tables (voir matrice M2 du schéma) |
| X2 | n8n service_role isolé, pas accessible publiquement |
| X3 | Secrets Twilio + Claude API en Supabase Vault ou variables d'environnement n8n |
| X4 | Pas de données personnelles prospect dans les logs (hash ou masquage) |

---

## 5. Questions à poser à Joanel en workshop

### Priorité critique (doivent être validées avant dev)

1. 🔴 **Budget Twilio mensuel** — valider 500 CAD ou ajuster
2. 🔴 **Flag VIP** — existe-t-il des prospects à exclure ?
3. 🔴 **Horaires dimanche** — envois autorisés ou pas ?
4. 🔴 **Politique "perdu"** — timing d'archivage + soft-delete
5. 🔴 **Consentement initial** — documenté où ? Quand est-il obtenu ?

### Priorité importante

6. 🟡 **Ton vouvoiement/tutoiement** — validation stylistique
7. 🟡 **Signature des messages** — format exact
8. 🟡 **Notifications courtier** — préférences par défaut
9. 🟡 **Types de biens** — segmentation à prévoir ?
10. 🟡 **Emoji** — politique d'usage

### À approfondir

11. 🟢 **Données sectorielles** — Joanel a-t-il des stats de taux de réponse par heure/jour ?
12. 🟢 **Intégration Google Calendar** — priorité Sprint 2 ou Sprint 3 ?
13. 🟢 **Multi-courtiers** — plusieurs courtiers partagent-ils un même prospect ?

---

## 6. Checklist finale avant go-live

Avant de mettre en production le système de relance :

- [ ] Opt-out STOP testé bout en bout (SMS → blacklist → aucun envoi)
- [ ] Footer légal conforme dans tous les templates
- [ ] Budget Twilio configuré avec alerte 80%
- [ ] Sender score monitoring en place
- [ ] Log de consentement initial opérationnel
- [ ] Procédure RGPD documentée (accès, rectification, suppression)
- [ ] Tests UAT avec Joanel (3 prospects réels de son pipeline)
- [ ] Runbook incident (que faire si Twilio down, Claude API down, scheduler crash)
- [ ] Formation Joanel sur dashboard + préférences courtier
- [ ] Clauses conditions d'utilisation mises à jour

---

*Document rédigé par l'équipe NextMove — v1.0*

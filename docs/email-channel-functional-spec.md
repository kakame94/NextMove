# Klaris — Canal Email : spécification fonctionnelle

> **Type** : spec fonctionnelle (le **quoi** métier, pas le comment technique).
> Comment technique → [email-channel-dev-guide.md](email-channel-dev-guide.md).
> Plan d'implémentation Phase 1 → [superpowers/plans/2026-06-16-email-channel-phase1.md](superpowers/plans/2026-06-16-email-channel-phase1.md).
>
> **Version** : 0.1 — 2026-06-18. **Statut** : à valider.
> **Périmètre** : A+B+C+D (canal email complet).

---

## 1. Objectif & contexte

Klaris aide les courtiers immobiliers du Québec à **convertir** les leads qu'ils reçoivent
déjà (positionnement « conversion, pas trafic » — OBJ-1). Le canal **SMS** existe (adjointe IA
qui qualifie, répond, relance). Cette spec ajoute le canal **email** : capter les leads qui
arrivent par courriel — surtout les « Demandes d'information » Centris — et les traiter avec la
même adjointe IA, plus gérer les relances email et le tri de la boîte du courtier.

**Problème adressé** : un lead entrant non suivi dans les minutes/heures est un lead perdu. Une
grande part des leads courtiers arrive par email (RFI Centris) et tombe dans une boîte non
surveillée le soir/week-end. Klaris répond instantanément, qualifie, et n'oublie aucune relance.

---

## 2. Périmètre

**Inclus (4 capacités)**
- **A — Ingestion RFI Centris** : capter les « Demandes d'information » Centris reçues par
  email, créer/mettre à jour la fiche prospect, démarrer la conversation.
- **B — Canal email conversationnel** : l'adjointe IA dialogue avec le prospect par email
  (qualification, réponses), pas seulement par SMS.
- **C — Relances email** : séquence de relances automatiques par email.
- **D — Triage boîte courtier** : trier les emails de la boîte générale du courtier
  (lead vs administratif vs indésirable) et router les leads vers le pipeline.

**Exclu (hors périmètre)** : voir [§9](#9-hors-périmètre).

> **Ordre conseillé** (le dev tranche, doc en un bloc) : A → B+C → D. A ne fait aucun envoi
> sortant (zéro risque CASL), livre déjà « lead → fiche + conversation ».

---

## 3. Acteurs & rôles

| Acteur | Rôle |
|--------|------|
| **Prospect** | Personne qui envoie une demande (RFI Centris, ou email direct). Reçoit les réponses/relances. |
| **Courtier** | Propriétaire des leads. Voit ses fiches/conversations, reçoit les notifications, approuve/édite si requis, encaisse la conversion. |
| **Adjointe IA (Klaris)** | Agent automatique : qualifie, répond, relance, trie. Agnostique au canal. |
| **Système Centris** | Source des RFI (email de notification au courtier). Pas d'API — email seulement. |
| **Administrateur** | Configure les comptes courtiers, le routage email, surveille la conformité/audit. |

---

## 4. Vue d'ensemble des parcours

```
A. RFI Centris   : Centris ─email→ (boîte courtier) ─forward→ Klaris ─→ fiche + conversation
B. Conversationnel: Prospect ─email→ Klaris (adjointe) ─réponse email→ Prospect   (boucle)
C. Relances      : Klaris ─relance email J+x→ Prospect  (si pas de réponse, si pas opt-out)
D. Triage        : Boîte courtier ─→ Klaris classe (lead / admin / spam) ─→ leads au pipeline
```

Toutes les conversations email alimentent **la même fiche prospect** que le SMS (canal unifié),
visibles par le courtier dans son tableau de bord.

---

## 5. Exigences fonctionnelles

> Notation critères d'acceptation : **Étant donné / Quand / Alors**.

### A. Ingestion RFI Centris

**User story** : *En tant que courtier, je veux que chaque Demande d'information Centris devienne
automatiquement une fiche prospect avec une première réponse envoyée, pour ne perdre aucun lead.*

- **FR-A1** — Le système reçoit les emails forwardés vers une adresse de parse Klaris dédiée
  (modèle « forward-to-parse »).
- **FR-A2** — Le système **déballe** les emails transférés (Fwd:/Tr:, citations `>`) pour
  retrouver le contenu Centris original.
- **FR-A3** — Le système extrait les champs Centris par **labels bilingues** (FR/EN) :
  prénom, nom, courriel, téléphone, message (toujours présents) ; adresse/No. Centris (MLS)
  (optionnel, si RFI rattaché à une fiche).
- **FR-A4** — Le système crée une fiche prospect si l'email est inconnu pour ce courtier, sinon
  met à jour la fiche existante (dédup par email).
- **FR-A5** — La fiche enregistre l'**origine** : `source = centris` (ou `email` si RFI
  générique), le `No. Centris` si présent, le canal = email.
- **FR-A6** — Le système qualifie le message (intention acheteur/vendeur si déduisible, langue,
  score de chaleur) et démarre la conversation.
- **FR-A7** — Le courtier est **notifié** d'un nouveau lead qualifié (selon ses préférences).
- **FR-A8** — Un même RFI reçu deux fois (ret* / re-forward) ne crée **pas** de doublon
  (idempotence par identifiant de message).

**Règles** : un RFI sans intention claire est accepté (type non classé) ; le score peut évoluer
plus tard. Un message vide/illisible est journalisé mais ne crée pas de fiche fantôme.

**Critères d'acceptation**
- Étant donné un email Centris FR forwardé avec No. Centris ; Quand Klaris le reçoit ; Alors une
  fiche prospect est créée avec `source=centris`, le bon courriel/téléphone, le MLS, et une
  conversation entrante est journalisée.
- Étant donné le même email renvoyé ; Quand Klaris le reçoit ; Alors aucune 2ᵉ fiche ni 2ᵉ
  conversation n'est créée.
- Étant donné un email Centris EN générique (sans MLS) ; Alors la fiche est créée avec
  `source=email`/`centris` et `centris_mls` vide.

### B. Canal email conversationnel

**User story** : *En tant que prospect, je veux pouvoir échanger par courriel avec l'assistant du
courtier et obtenir des réponses pertinentes, comme par texto.*

- **FR-B1** — L'adjointe IA répond aux emails entrants d'un prospect en utilisant le **même**
  raisonnement/qualification que le SMS (prompt agnostique au canal).
- **FR-B2** — Les réponses sortantes partent **au nom du courtier** (expéditeur = courtier,
  `reply-to` cohérent), en **français ou anglais** selon la langue détectée du prospect.
- **FR-B3** — Chaque échange (entrant et sortant) est journalisé dans la **même** fiche/
  conversation, avec le **fil** reconstitué (threading par référence de message).
- **FR-B4** — Quand la qualification atteint un seuil « chaud », le courtier reçoit une **alerte**.
- **FR-B5** — Le système met à jour la fiche au fil de la conversation (budget, secteur, délai,
  pré-approbation, etc.) via les actions de qualification existantes.
- **FR-B6** — Avant **tout** envoi, le système vérifie que le prospect n'est pas désabonné
  (voir Transversal CASL).
- **FR-B7** — Chaque email sortant contient un **lien de désabonnement** et l'identité du courtier
  (exigence CASL).

**Critères d'acceptation**
- Étant donné un prospect qui répond en anglais ; Quand l'adjointe répond ; Alors la réponse est
  en anglais et la fiche reste lisible par le courtier en français.
- Étant donné un prospect désabonné ; Quand une réponse devrait partir ; Alors aucun email n'est
  envoyé et l'événement est journalisé.

### C. Relances email

**User story** : *En tant que courtier, je veux que les prospects sans réponse reçoivent des
relances automatiques au bon moment, sans que j'aie à y penser.*

- **FR-C1** — Le système programme une séquence de relances (cadence type J+2 / J+5 / J+10,
  alignée sur le système relances existant) pour les prospects email sans réponse.
- **FR-C2** — Chaque relance choisit le **canal** approprié (email ou SMS) selon la fiche /
  préférence / canal d'origine.
- **FR-C3** — Une relance n'est **jamais** envoyée si : le prospect a répondu, a pris rendez-vous,
  est désabonné, ou a été marqué « stop » par le courtier.
- **FR-C4** — Selon la configuration, une relance peut requérir l'**approbation** du courtier
  avant envoi (statut « en attente d'approbation »), comme le flux relances actuel.
- **FR-C5** — Toute relance envoyée est journalisée (contenu, canal, horodatage) dans la fiche.

**Critères d'acceptation**
- Étant donné un prospect email silencieux depuis 2 jours, non désabonné ; Quand la relance J+2
  s'exécute ; Alors un email de relance part et est journalisé.
- Étant donné un prospect qui a répondu entre-temps ; Alors la relance J+5 est annulée (statut
  « skipped »).

### D. Triage boîte courtier

**User story** : *En tant que courtier, je veux que Klaris trie ma boîte et fasse remonter les
vrais leads, pour ne pas fouiller manuellement.*

- **FR-D1** — Le système accède à la boîte du courtier (connexion sécurisée, consentement
  explicite du courtier) en **lecture**.
- **FR-D2** — Chaque email entrant est **classé** : lead / administratif / indésirable.
- **FR-D3** — Les emails classés « lead » sont routés vers le pipeline (parcours A/B).
- **FR-D4** — Les emails non-leads ne créent pas de fiche ; le classement est journalisé pour
  audit et amélioration.
- **FR-D5** — Le courtier peut **corriger** un classement (faux positif/négatif) ; la correction
  est tracée.

**Critères d'acceptation**
- Étant donné un courriel administratif (facture, notaire) ; Quand Klaris le classe ; Alors aucun
  prospect n'est créé et l'email est marqué « administratif ».
- Étant donné un courriel de prospect direct (hors Centris) ; Alors il est classé « lead » et
  entre dans le parcours conversationnel B.

---

## 6. Exigences transversales

- **FR-X1 Bilingue** — Détection FR/EN **par message** ; réponses dans la langue du prospect ;
  fiche toujours lisible en français pour le courtier.
- **FR-X2 Consentement / CASL & Loi 25** — Désabonnement respecté **avant chaque** envoi ; lien
  de désabonnement dans chaque email sortant ; un RFI/Centris entrant établit la base
  relation-courtier ; désabonnement **permanent** (pas de ré-abonnement silencieux).
- **FR-X3 Idempotence** — Aucun doublon de fiche/conversation sur réception multiple d'un même
  message.
- **FR-X4 Threading** — Les échanges email d'un même prospect sont regroupés en un fil cohérent.
- **FR-X5 Canal unifié** — Email et SMS alimentent la **même** fiche prospect ; le courtier voit
  un historique unifié, avec le canal de chaque message visible.
- **FR-X6 Notifications courtier** — Nouveau lead qualifié / prospect chaud / relance en attente
  d'approbation → notification selon les préférences du courtier (SMS et/ou email).
- **FR-X7 Audit / OACIQ** — Tout email traité (entrant, sortant, classé, rejeté) est journalisé
  (horodatage, contenu, résultat) ; suppression logique seulement (pas d'effacement dur),
  conservation pour traçabilité réglementaire.
- **FR-X8 Isolation par courtier** — Un courtier ne voit **que** ses propres prospects/
  conversations ; aucun croisement entre courtiers (rappel post-incident 2026-06-09).

---

## 7. Exigences non-fonctionnelles

- **NFR-1 Réactivité** — Réponse de l'adjointe à un lead entrant **en quelques minutes** (cible :
  < 5 min), 24/7 (le soir/week-end est précisément le créneau de valeur).
- **NFR-2 Fiabilité** — Aucune perte de lead : un email reçu mais non traité (erreur) doit être
  journalisé et reprenable, jamais silencieusement perdu.
- **NFR-3 Sécurité** — Aucun accès anonyme ; signature des webhooks entrants vérifiée ; secrets
  hors du code ; accès aux données par service de confiance uniquement (détails : dev-guide §9).
- **NFR-4 Conformité & résidence** — CASL / Loi 25 / PIPEDA ; données hébergées au **Canada**
  (Supabase ca-central-1).
- **NFR-5 Confidentialité** — Aucune PII dans les logs/erreurs exposés ; données brutes des
  emails protégées et soumises à rétention.
- **NFR-6 Coût** — Qualification via un modèle économique (Haiku) suffisant pour la
  classification.

---

## 8. États (cycle de vie)

**Prospect** : `nouveau` → (qualification) → `qualifié` / `chaud` → `rendez-vous` → `gagné` /
`perdu` / `désabonné`. (Aligné sur les statuts existants.)

**Conversation/message** : `entrant` (du prospect) | `sortant` (de Klaris/courtier) ; lu/non-lu
par le courtier ; canal `email`/`sms`.

**Relance** : `planifiée` → `en attente d'approbation` (optionnel) → `envoyée` / `annulée` /
`stoppée`.

---

## 9. Hors périmètre

- Génération de trafic / acquisition de nouveaux leads (positionnement = conversion, pas trafic).
- Envoi d'emails marketing de masse / infolettres.
- Pièces jointes lourdes, négociation contractuelle, signature électronique dans l'email.
- Intégration via une API Centris (inexistante — email seulement).
- Téléphonie / voix (couvert par d'autres canaux).

---

## 10. Règles métier clés (récap)

1. **Conversion, pas trafic** : on traite des leads existants, on n'en génère pas.
2. **Jamais d'envoi à un désabonné** ; désabonnement permanent.
3. **Pas de doublon** sur réception multiple.
4. **Langue du prospect** en sortie ; **français** pour le courtier.
5. **Isolation stricte** entre courtiers.
6. **Réponse rapide 24/7** ; aucun lead perdu en silence.
7. **Tout est tracé** (audit OACIQ), suppression logique seulement.

---

## 11. Questions ouvertes (décisions à confirmer)

Renvoi au dev-guide §12 — celles qui impactent le fonctionnel :
1. **Classification d'office** d'un lead non typé (acheteur/vendeur) ou type laissé vide ?
2. **Relances email** : approbation courtier obligatoire ou envoi auto (par défaut) ?
3. **Triage (D)** : seuil de confiance avant de router un email en « lead » ; quel comportement
   en cas de doute (file de revue manuelle) ?
4. **Multi-courtier** : une adresse de parse partagée vs une par courtier (impacte le routage du
   lead vers le bon courtier).
5. **Échantillon Centris réel** requis pour figer les libellés exacts du parser (FR + EN).

---

## 12. Critères de succès (métriques)

- **Délai de 1ʳᵉ réponse** à un lead entrant : médiane < 5 min, 24/7.
- **Taux de leads convertis en conversation** (au moins 1 échange prospect↔Klaris) : à établir
  comme base, puis amélioration.
- **% de RFI Centris capturés** automatiquement (vs perdus) : cible > 95 %.
- **Relances exécutées à temps** sans envoi à un désabonné : 100 % de conformité.
- **0 incident** d'isolation / fuite inter-courtier.

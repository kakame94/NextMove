# NextMove — Spécifications Templates SMS

> Spécifications des templates de relance.
>
> ✅ **Templates happy path trouvés** dans Figma node `62:2` — voir `templates-sms-figma-extraits.md` (source de vérité).
> Ce document détaille les **edge cases et variantes** qui complètent les templates Figma.

**Statut :** v1.2 — templates happy path intégrés depuis Figma
**Dernière mise à jour :** 2026-04-17

## ⚠️ Conventions non-négociables (validées par Figma)

1. **Signature :** « l'assistante de Joanel » (PAS « NextMove pour Joanel »)
2. **Ton :** français québécois naturel, chaleureux, exclamations OK
3. **Pas de vouvoiement rigide** — « c'est quoi votre budget », pas « quel est votre budget »
4. **1 question par message** (sauf résumé final structuré)
5. **Prénom du courtier cité** dans chaque message (humanisation)

## Cadences réelles (Figma Sprint MVP)

- **T1 relance** : J+2 (pas J+7)
- **T2 relance** : J+5 (pas J+14)
- **T3 RDV** : J-1 avant rendez-vous (pas H-48)
- **T11 briefing** : quotidien 7h30 au courtier

---

## 1. Contraintes communes à tous les templates

### 1.1 Contraintes techniques SMS

| Contrainte | Valeur | Raison |
|-----------|--------|--------|
| **Longueur max** | 160 caractères (GSM-7) ou 70 (UCS-2 avec emoji) | 1 SMS = 1 facturation |
| **Accents autorisés** | Oui (é, è, à, ç, ô…) | Français QC standard |
| **Emoji** | 1 max par message (si approuvé par Joanel) | Attention UCS-2 coûteux |
| **URL** | Courtes (bit.ly / nextmove.ai/x) | Consomment des caractères |

### 1.2 Variables injectables

```
{{prospect_prenom}}          — Prénom du prospect (capitalisé)
{{courtier_prenom}}          — Prénom du courtier
{{courtier_nom_complet}}     — "Joanel Tremblay"
{{bien_type}}                — "condo", "maison", etc.
{{bien_secteur}}             — "Le Plateau", "Verdun"…
{{budget_min}} / {{budget_max}} — En dollars
{{rdv_date}}                 — "mardi 21 avril"
{{rdv_heure}}                — "14h00"
{{rdv_lieu}}                 — Adresse ou lien
{{nb_nouveaux_biens}}        — Entier
{{lien_biens}}               — URL courte
{{lien_opt_out}}             — URL désabonnement (email only)
```

### 1.3 Règles de rédaction

- **Commencer par le prénom** (attention + personnalisation)
- **Poser une question claire** ou **appeler à une action**
- **Signer** avec "— l'assistante de {{courtier_prenom}}"
- **Ajouter "Répondez STOP pour arrêter"** sur le premier SMS ou après 2 relances sans réponse
- **Ne jamais** mentir sur l'urgence ("URGENT ACTION REQUISE" = interdit)
- **Ne jamais** utiliser tout en MAJUSCULES
- **Ne jamais** mettre plusieurs points d'exclamation

---

## 2. Templates par type de relance

### 2.1 T1 — `inactif_7j`

**Contexte :** Prospect n'a pas échangé depuis 7 jours. Première relance douce.

**Objectif :** Réveiller sans pression. Question ouverte.

**Proposition (à valider) :**
```
Bonjour {{prospect_prenom}}, êtes-vous toujours en recherche d'un {{bien_type}} 
à {{bien_secteur}} ? Je reste dispo pour échanger.
— l'assistante de {{courtier_prenom}}
```

**Longueur :** ~140 caractères avec variables moyennes ✅

**Edge case : prospect sans bien_secteur défini**
```
Bonjour {{prospect_prenom}}, votre recherche immobilière est-elle toujours active ? 
Je reste dispo pour échanger.
— l'assistante de {{courtier_prenom}}
```

**Version Figma happy path :** [À injecter depuis Figma]

---

### 2.2 T2 — `inactif_14j`

**Contexte :** T1 sans réponse. 14 jours sans échange. Relance value-add.

**Objectif :** Apporter de la valeur (nouveaux biens, info marché).

**Proposition :**
```
Bonjour {{prospect_prenom}}, {{nb_nouveaux_biens}} nouveaux {{bien_type}}s sont 
arrivés dans votre gamme ({{budget_min}}-{{budget_max}}$). Voulez-vous les voir ?
{{lien_biens}}
— {{courtier_prenom}}
```

**Longueur :** ~155 caractères avec variables moyennes ✅

**Edge case : aucun nouveau bien à proposer**
```
Bonjour {{prospect_prenom}}, le marché {{bien_secteur}} a bougé ces 2 dernières 
semaines. Voulez-vous un point ?
— {{courtier_prenom}}
```

**Version Figma happy path :** [À injecter depuis Figma]

---

### 2.3 T3 — `inactif_21j_final`

**Contexte :** T2 sans réponse. 21 jours sans échange. Dernière chance.

**Objectif :** Offre de sortie claire. Respect du temps du prospect.

**Proposition :**
```
Bonjour {{prospect_prenom}}, on ferme votre dossier s'il n'y a plus d'intérêt. 
Répondez CONTINUER pour poursuivre ou STOP pour arrêter.
— l'assistante de {{courtier_prenom}}
```

**Longueur :** ~155 caractères ✅

**Note :** Le mot-clé "CONTINUER" doit être reconnu par Claude/n8n pour remettre 
le prospect en statut `actif`. Le mot-clé "STOP" (déjà géré par Twilio) 
active la blacklist.

**Version Figma happy path :** [À injecter depuis Figma]

---

### 2.4 T4 — `nudge_courtier_chaud`

**Destinataire :** Courtier (pas prospect)
**Canal principal :** Notif push PWA + Email fallback

**Contexte :** Prospect score ≥ 7 sans action courtier depuis > 24h.

**Objectif :** Alerter le courtier sans le culpabiliser.

**Format notif push :**
```
🔥 Prospect chaud négligé
{{prospect_prenom}} (score {{heat_score}}/10) attend une réponse depuis {{heures_sans_action}}h.
[Voir le prospect] [Snooze 4h]
```

**Format email :**
- **Subject :** `🔥 {{prospect_prenom}} vous attend (score {{heat_score}}/10)`
- **Body :**
  ```
  Bonjour {{courtier_prenom}},

  {{prospect_prenom}} est identifié comme prospect chaud (score {{heat_score}}/10)
  mais n'a reçu aucune réponse de votre part depuis {{heures_sans_action}} heures.

  Dernier message du prospect : "{{dernier_message_extrait}}"

  [Répondre maintenant] [Marquer comme traité] [Snooze 4h]

  NextMove
  ```

**Version Figma happy path :** [À injecter depuis Figma]

---

### 2.5 T5 — `nudge_courtier_urgent`

**Destinataire :** Courtier
**Canal principal :** SMS + Notif push

**Contexte :** Prospect score 9-10 sans action depuis > 4h.

**Objectif :** Alerte critique. Ne pas rater un deal.

**Format SMS courtier :**
```
⚡ URGENT NextMove : {{prospect_prenom}} score {{heat_score}}/10 attend depuis {{heures}}h. 
Action requise. Voir app.
```

**Longueur :** ~110 caractères ✅

**Version Figma happy path :** [À injecter depuis Figma]

---

### 2.6 T6 — `rdv_confirmation` (H-48 et H-24)

**Contexte :** RDV planifié, demande confirmation prospect.

**H-48 (première tentative) :**
```
Bonjour {{prospect_prenom}}, je vous confirme notre RDV {{rdv_date}} à {{rdv_heure}} 
({{rdv_lieu}}). Répondez OUI pour confirmer.
— l'assistante de {{courtier_prenom}}
```

**Longueur :** ~150 caractères ✅

**H-24 (si pas de réponse H-48) :**
```
Bonjour {{prospect_prenom}}, rappel de notre RDV demain à {{rdv_heure}}. 
Toujours disponible ? OUI pour confirmer, NON pour reporter.
— {{courtier_prenom}}
```

**Longueur :** ~155 caractères ✅

**Note :** Les mots-clés OUI / NON doivent être reconnus par Claude/n8n pour 
mettre à jour `rendez_vous.status`.

**Version Figma happy path :** [À injecter depuis Figma]

---

### 2.7 T7 — `post_rdv_feedback`

**Contexte :** RDV passé depuis 24h.

**Objectif :** Capturer ressenti + relancer pipeline.

**Proposition :**
```
Bonjour {{prospect_prenom}}, merci pour votre visite hier. 
Qu'en avez-vous pensé ? Des questions ?
— l'assistante de {{courtier_prenom}}
```

**Longueur :** ~130 caractères ✅

**Version Figma happy path :** [À injecter depuis Figma]

---

### 2.8 T8 — `etape_financement`

**Contexte :** Pré-approbation promise mais non reçue après 7 jours.

**Objectif :** Débloquer l'étape sans être insistant.

**Proposition (prospect) :**
```
Bonjour {{prospect_prenom}}, avez-vous pu avancer sur votre préapprobation ? 
Je peux vous aider si besoin.
— {{courtier_prenom}}
```

**Longueur :** ~135 caractères ✅

**Notification courtier (email) :**
- **Subject :** `Dossier financement {{prospect_prenom}} — suivi requis`
- **Body :** Résumé du stage de financement + lien dossier

**Version Figma happy path :** [À injecter depuis Figma]

---

### 2.9 T9 — `reactivation_longterme`

**Canal :** Email UNIQUEMENT (jamais SMS)
**Pré-requis :** Opt-in email explicite au moment de la collecte

**Format email :**
- **Subject :** `{{prospect_prenom}}, le marché {{bien_secteur}} a changé`
- **Body :**
  ```
  Bonjour {{prospect_prenom}},

  Il y a 3 mois, vous cherchiez un {{bien_type}} à {{bien_secteur}}.

  Depuis, {{stats_marche_secteur}} — de nouvelles opportunités pourraient 
  correspondre à votre projet.

  Souhaitez-vous qu'on reprenne contact ? Répondez à cet email.

  — {{courtier_nom_complet}}
  NextMove

  ---
  Vous recevez cet email car vous avez donné votre accord lors de notre 
  premier échange. [Se désabonner]({{lien_opt_out}})
  ```

**Version Figma happy path :** [À injecter depuis Figma]

---

### 2.10 T10 — `relation_fidelisation` (optionnel Post-MVP)

**Canal :** Email

**Contexte :** Anniversaire de la 1re interaction avec le prospect.

**Objectif :** Entretenir la relation (LTV).

**Proposition :**
- **Subject :** `{{prospect_prenom}}, ça fait un an 🏡`
- **Body :** Court, chaleureux, non-commercial. À co-rédiger avec Joanel.

**Version Figma happy path :** [Optionnel]

---

## 3. Templates système (indispensables)

### 3.1 Accusé de réception STOP

**Déclenché :** Prospect envoie STOP

**Template :**
```
Vous êtes désinscrit des messages NextMove. Nous respectons votre choix. 
Pour revenir, contactez-nous.
```

**Note :** Message système obligatoire légalement (CASL + Twilio policy).

---

### 3.2 Réponse HELP

**Déclenché :** Prospect envoie HELP / AIDE

**Template :**
```
NextMove : plateforme de suivi immobilier. Contact : {{courtier_nom_complet}}, 
{{courtier_tel}}. STOP pour vous désinscrire.
```

---

### 3.3 Erreur non reconnue

**Déclenché :** Prospect envoie un message mais Claude ne comprend pas.

**Template :**
```
Bonjour, je n'ai pas bien saisi votre message. {{courtier_prenom}} va revenir 
vers vous rapidement.
— NextMove
```

**Note :** Déclenche aussi notif courtier "Message non compris, action requise".

---

## 4. Matrice de couverture (templates × triggers × langues)

| Trigger | FR-CA SMS | FR-CA Email | EN-CA SMS | EN-CA Email | Figma ? |
|---------|-----------|-------------|-----------|-------------|---------|
| T1 | ✅ Prop. | ❌ | ☐ | ❌ | ☐ |
| T2 | ✅ Prop. | ☐ fallback | ☐ | ❌ | ☐ |
| T3 | ✅ Prop. | ❌ | ☐ | ❌ | ☐ |
| T4 (courtier) | ❌ | ✅ Prop. (notif push) | ❌ | ☐ | ☐ |
| T5 (courtier) | ✅ Prop. | ☐ fallback | ☐ | ❌ | ☐ |
| T6 H-48 | ✅ Prop. | ☐ fallback | ☐ | ❌ | ☐ |
| T6 H-24 | ✅ Prop. | ☐ fallback | ☐ | ❌ | ☐ |
| T7 | ✅ Prop. | ❌ | ☐ | ❌ | ☐ |
| T8 prospect | ✅ Prop. | ❌ | ☐ | ❌ | ☐ |
| T8 courtier | ❌ | ✅ Prop. | ❌ | ☐ | ☐ |
| T9 | ❌ | ✅ Prop. | ❌ | ☐ | ☐ |
| T10 | ❌ | ✅ Prop. (opt) | ❌ | ❌ | ☐ |
| STOP ack | ✅ OBL. | ❌ | ☐ OBL. | ❌ | ❌ |
| HELP | ✅ OBL. | ❌ | ☐ OBL. | ❌ | ❌ |
| Erreur | ✅ Prop. | ❌ | ☐ | ❌ | ❌ |

**OBL.** = Obligatoire (légalement requis)
**Prop.** = Proposé (à valider avec Joanel)
**EN-CA** = Version anglaise à produire Post-MVP si clientèle diversifiée

---

## 5. Workflow de validation

1. **Eliot récupère les templates Figma** (happy path)
2. **Injecter les templates Figma** dans les sections "Version Figma happy path"
3. **Joanel valide/modifie** les propositions (3h bloquées)
4. **Rédiger les edge cases** (sans Figma) : 7 templates
5. **Faire valider conformité légale** (mention expéditeur, STOP, HELP)
6. **Insérer en base** `relance_templates`
7. **Tests unitaires** sur rendu avec variables injectées

---

## 6. Questions pour Joanel

1. 🔴 **Emoji OK ?** Politique globale (0, 1 max, libre ?)
2. 🔴 **Signature** — "NextMove pour Joanel Tremblay" ou "Joanel — NextMove" ?
3. 🔴 **Tu vs Vous** — confirmé vouvoiement ?
4. 🟡 **Tone** — amical / professionnel / enthousiaste ?
5. 🟡 **URL courtes** — utiliser un domaine custom (nextmove.ai/x) ou bit.ly ?
6. 🟡 **Version anglaise** — nécessaire MVP ou Post-MVP ?
7. 🟡 **Multi-courtiers** — template T4/T5 adaptable si plusieurs courtiers gèrent ?
8. 🟢 **A/B testing** — envisagé pour optimiser taux de réponse ?

---

*Document rédigé par l'équipe NextMove — v1.0*

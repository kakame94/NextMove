# Test pilote Sprint 1 — Scénarios pour Eliot & Seydou

> **Objectif** : valider l'adjointe IA SMS (intake + relances + briefing) avant l'embarquement de Joanel cette semaine.
> **Durée estimée** : 45-60 min par testeur.
> **Reporter** : Dennis Marfo — `dennismarfo@gmail.com`.
> **Date cible** : du 28 avril au 3 mai 2026.

---

## 0. Avant de commencer

### Pour les testeurs (Eliot, Walkens, Seydou)

1. **Lisez d'abord ce document en entier** (5 min) — sinon vous risquez d'oublier des étapes.
2. **Gardez le tableau de rapport (§ 13) ouvert** dans un autre onglet et remplissez au fur et à mesure.
3. **Avant chaque scénario qui demande un reset**, écrivez à Dennis sur Slack : *« Peux-tu me reset ? »*. Dennis confirme par **« GO »** quand c'est fait.
4. **Filmez en Loom** si vous tombez sur un comportement bizarre — c'est plus facile à débugger.
5. **Numéro Twilio à contacter** : `+1 272-282-5614` (le numéro de l'adjointe IA).

---

## 1. Tableau de bord testeurs

| Testeur | Numéro | Reset initial fait ? | Date début |
|---|---|---|---|
| Eliot | +1 514-568-6995 | ✅ 28 avr | |
| Walkens | +1 438-506-5804 | ✅ 28 avr | |
| Seydou | +1 613-762-0939 | ✅ 28 avr | |

---

## 2. S1 — Premier contact happy path acheteur

**Préalable** : prospect reseté.

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer : `Bonjour, je cherche un condo a Brossard` | SMS reçu en < 60 s. L'agent demande des précisions (budget, délai, type). Ton naturel québécois, pas robotique. |
| 2 | Envoyer : `Mon budget c'est 450 000$ et je veux acheter d'ici 3 mois. Je suis pré-approuvé.` | L'agent confirme la fiche et indique que le courtier sera notifié. |
| 3 | (Côté Dennis vérifier DB) | Dans `prospects` : `statut = 'qualifie'`, `score_chaleur >= 7`, `budget_max = 450000`, `secteur` mentionne Brossard. Une notification email + SMS chez Dennis. |

**À noter** :
- Délai exact 1ère réponse : `___ s`
- Délai 2e réponse : `___ s`
- Ressenti naturel ? oui / non / partiel
- Le ton/vocabulaire Québec est-il OK ? oui / non

---

## 3. S2 — STOP au milieu de conversation

**Préalable** : pas reset (continuer après S1).

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer : `STOP` | SMS de désabonnement reçu : « Vous avez été désabonné. Vous ne recevrez plus de messages. Pour vous réabonner, écrivez START. » |
| 2 | Vérifier DB | `prospects.opted_out_at` rempli ; `blacklist` contient le numéro avec `reason = 'stop_keyword'` ; `prospects.statut = 'perdu'`. |
| 3 | Envoyer : `Je veux quand meme parler` | **Aucune réponse** — la blacklist filtre les messages entrants. |

---

## 4. S3 — HELP en plein milieu

**Préalable** : reset complet.

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer : `Bonjour je veux vendre ma maison` | Agent répond, demande le type de bien, l'adresse, le délai. |
| 2 | Envoyer : `HELP` | Reçoit le message d'aide statique : « NextMove : commandes disponibles. STOP = se désabonner. CONTINUER = reprendre… » |
| 3 | (Côté Dennis vérifier) | L'agent ne répond **pas** au HELP. `last_inbound_at` mis à jour. |
| 4 | Envoyer : `aide` (variante) | Même message d'aide (HELP est insensible à la casse + accepte `aide`). |

---

## 5. S4 — CONTINUER après STOP

**Préalable** : suite directe de S2 (le testeur est en blacklist).

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer : `CONTINUER` | Reçoit l'ack : « Bienvenue de retour ! Vous êtes à nouveau abonné. » |
| 2 | Vérifier DB | `opted_out_at = NULL` ; `statut = 'en_qualification'` ; ligne supprimée de `blacklist`. |
| 3 | Envoyer : `Je cherche un duplex a Verdun` | Agent répond normalement (le prospect peut reprendre la conversation). |

---

## 6. S5 — Double SMS rapide (dedup test)

**Préalable** : reset complet.

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer 2 SMS identiques en moins de 2 s : `Bonjour je cherche` | **Une seule** réponse de l'agent (le `Dedup by messageSid` fait son boulot). |
| 2 | Vérifier DB | Une seule ligne dans `conversations` pour ce message. |

---

## 7. S6 — Réponses OUI / NON sans contexte RDV

**Préalable** : reset complet.

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer : `OUI` | L'agent contextualise (probablement « OUI à quoi ? »). Pas de plantage, pas de boucle. |
| 2 | Envoyer : `NON merci` | Pareil, l'agent contextualise. |

> ⚠️ Sprint 1 : la table `rendez_vous` n'existe pas encore. Sprint 2 ajoutera la confirmation OUI/NON pour RDV. Pour l'instant ces mots passent simplement à l'agent.

---

## 8. S7 — Messages très courts

**Préalable** : reset complet.

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer : `ok` | L'agent demande des précisions (relance la conversation). |
| 2 | Envoyer : `merci` | L'agent peut clore la conversation poliment ou demander si autre chose. |
| 3 | Envoyer : `?` | (à vérifier) — comportement attendu : soit traité comme HELP, soit l'agent demande ce qui n'est pas clair. |

---

## 9. S8 — Mélange français / anglais

**Préalable** : reset complet.

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer : `Hi I'm looking for a 3-bedroom in NDG` | L'agent détecte l'anglais (`langue_preferee = 'en'` en DB) et répond en anglais naturel. |
| 2 | Envoyer : `Can we switch to French?` | L'agent bascule en français. |

---

## 10. S9 — Emoji seul

**Préalable** : reset complet.

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer : `🏠🏠` | L'agent demande poliment des précisions, pas de crash, pas de réponse vide. |

---

## 11. S10 — Message très long

**Préalable** : reset complet.

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Envoyer un SMS d'environ 1 500 caractères avec **3 informations cachées** dans le texte (ex. budget 600 000, délai 6 mois, secteur Laval) | L'agent extrait au moins 2 des 3 infos correctement. |

---

## 12. S11 — Test relance J+2 (forcer la condition)

**Préalable** : prospect S1 complété (qualifié). Dennis simule l'inactivité côté DB sur demande.

| Étape | Action testeur | Attendu |
|---|---|---|
| 1 | Demander à Dennis : *« simule mon inactivité J+2 »* | Dennis force `last_outbound_at` à 3 jours dans le passé. |
| 2 | Ne rien faire pendant 15-30 min (le scheduler tourne tous les 15 min, fenêtre 8h-20h) | Le testeur reçoit automatiquement un SMS de relance T1 (« inactif J+2 »). |
| 3 | Répondre : `Oui je suis toujours intéressé` | L'agent reprend la conversation normalement. |

---

## 13. Template de rapport (à remplir au fur et à mesure)

À copier-coller dans un fichier Markdown ou Google Doc, un par testeur.

```markdown
# Rapport test — [Eliot | Seydou]
Date : ____
Numéro testeur : ____

| # | Scénario | Statut | Délai 1ère réponse | Commentaire |
|---|----------|--------|--------------------|-------------|
| S1 | Premier contact happy path | ✅ / ❌ / ⚠️ | __ s | |
| S2 | STOP au milieu | | | |
| S3 | HELP en plein milieu | | | |
| S4 | CONTINUER après STOP | | | |
| S5 | Double SMS rapide | | | |
| S6 | OUI / NON sans contexte | | | |
| S7 | Messages courts | | | |
| S8 | Mélange fr / en | | | |
| S9 | Emoji seul | | | |
| S10 | Message très long | | | |
| S11 | Relance J+2 | | | |

## Bugs trouvés (si pertinent)
- ...

## Ressenti général
- Naturel : 1-5
- Délai : 1-5
- Pertinence des questions : 1-5
- Tu utiliserais comme client ? oui / non — pourquoi ?

## Loom des bugs visuels
- (lien)
```

Légende : ✅ comportement conforme · ❌ ne fait pas ce qui est attendu · ⚠️ marche mais ressenti pas terrible.

---

## 14. Annexe — Demandes courantes à Dennis pendant les tests

Les testeurs peuvent demander à Dennis (qui passera par Claude/MCP Supabase pour exécuter) :

- *« Reset-moi »* → reset complet du prospect (statut, score, conversations, relances, blacklist)
- *« Simule mon inactivité J+2 »* → force `last_outbound_at` à 3 jours dans le passé
- *« Vérifie ma fiche »* → renvoie l'état actuel du prospect (statut, score, dernières activités)
- *« Voir mes conversations »* → liste les 20 derniers échanges avec l'agent
- *« Voir mes relances »* → liste les relances envoyées et bloquées avec leur raison

---

## 15. Définition de "Done" pour le pilote Joanel

Le Sprint 1 est validé pour embarquer Joanel quand :

- [ ] Eliot et Seydou ont **chacun** complété les scénarios **P0** (S1, S2, S3, S4, S5, S11)
- [ ] Aucun bug bloquant trouvé sur les P0
- [ ] Le délai 1ère réponse moyen est **< 60 secondes**
- [ ] Les ressentis "naturel" sont ≥ 4/5 sur les deux testeurs
- [ ] Au moins **1 bug P1** ouvert mais non bloquant est OK (à fixer en parallèle)

---

*Préparé par Dennis Marfo — 28 avril 2026.*

# QA — Validation du Prompt Implemente vs PRD

**Date :** 2026-04-11
**Validateur :** Claude (Opus 4.6) en mode QA
**PRD reference :** `_bmad-output/planning-artifacts/prd.md`
**Prompt audite :** Prompt systeme implemente par Dennis dans n8n

---

## POUR DENNIS — Resume rapide

Le prompt est solide a 70%. Il y a **2 corrections critiques** a faire avant la demo et **5 medium** pour samedi. Le plus urgent : ajouter les guardrails legaux (OACIQ) et s'assurer que le mot QUALIFIED ne s'affiche pas au prospect.

---

## CE QUI EST BIEN COUVERT

| FR/NFR | Exigence PRD | Status |
|--------|-------------|--------|
| FR-1.3 | Detecter acheteur/vendeur | OK |
| FR-1.4 | Detection FR/EN + fallback FR | OK |
| FR-2.1 | Flux acheteur structure | OK (10Q au lieu de 9 — voir P5) |
| FR-2.2 | Flux vendeur structure | OK (voir P6 pour un manque) |
| FR-2.3 | Mode doux vs raccourci | OK |
| FR-2.6 | 1 question a la fois | OK |
| FR-3.1 | Transfert questions complexes | OK |
| FR-4.2 | Score 4 niveaux (CHAUD-URGENT/CHAUD/TIEDE/FROID) | OK avec grille de scoring |
| NFR-4.1 | Ton quebecois naturel | OK |

---

## CORRECTIONS A FAIRE

### CRITIQUES (avant la demo dimanche)

#### P1 — Guardrails legaux manquants (FR-3.3 + FR-3.4)

**Probleme :** Le prompt n'interdit pas explicitement a l'IA de donner des conseils juridiques, financiers ou de se presenter comme courtier. C'est une obligation OACIQ — le courtier met sa licence en jeu si l'IA donne un avis sur les prix ou le financement.

**Ajouter dans le prompt apres "Ton role:" :**
```
Regles absolues:
- Tu ne donnes JAMAIS de conseil sur les prix du marche, le financement,
  les taux hypothecaires, ou les clauses contractuelles
- Tu ne te presentes JAMAIS comme courtier ou professionnel reglemente
- Tu es l'assistante administrative, pas une experte immobiliere
- Tu ne fais JAMAIS de promesse sur les delais ou les resultats
- Si on te demande un avis sur un prix ou un taux, reponds:
  "C'est le genre de question ou Joanel pourra mieux vous guider.
  Je lui transmets!"
```

#### P7 — Le mot QUALIFIED risque d'etre visible au prospect

**Probleme :** Le prompt dit "Ajoute le mot QUALIFIED a la fin de ton dernier message." Si le node n8n ne strip pas ce mot avant l'envoi Twilio, le prospect va recevoir :

> "Merci! Joanel va vous contacter sous peu. QUALIFIED"

C'est un bris de confiance immediat.

**Correction option A (prompt) :**
```
Quand la conversation est terminee, ajoute QUALIFIED sur une ligne
completement separee. Le systeme le retirera automatiquement.
```

**Correction option B (workflow n8n) :**
Dans le node "Parser Reponse" (ou avant l'envoi Twilio), ajouter :
```javascript
result.clientMessage = result.clientMessage.replace(/\n?QUALIFIED\s*$/i, '').trim();
```

**Faire les DEUX pour etre safe.**

---

### MEDIUM (corriger samedi)

#### P4 — Pas de resume au prospect a la fin (FR-2.5)

**Probleme :** Le PRD exige que l'IA envoie un recapitulatif au prospect avant de conclure. Le prompt actuel dit juste "termine en disant que Joanel va prendre contact" sans recap.

**Ajouter avant la ligne QUALIFIED :**
```
Avant de conclure, recapitule les informations collectees au prospect:
"Voici ce que j'ai note: [resume des infos collectees]. C'est bien exact?"
Attends la confirmation du prospect AVANT d'envoyer QUALIFIED.
```

#### P6 — Flux vendeur : disponibilites manquantes

**Probleme :** Le flux vendeur a 6 questions mais il manque les disponibilites pour une rencontre (FR-2.2 Q5 du PRD). Dennis a ajoute "adresse" et "raison de vente" (bons ajouts) mais a retire les dispos.

**Ajouter au flux vendeur :**
```
 7. Disponibilites pour une rencontre avec Joanel
```

#### P5 — Flux acheteur : 10 questions au lieu de 9

**Probleme :** Dennis a ajoute "mise de fonds disponible" et "proprietaire occupant ou investisseur" — c'est pertinent pour la specialisation plex de Joanel, mais c'est pas dans le PRD.

**Pas a retirer** — c'est une bonne addition. Mais a documenter dans le PRD pour garder la tracabilite. Je vais ajouter une note dans le PRD.

#### P3 — "PAS d'accents" dans les reponses

**Probleme :** Le prompt dit "PAS d'accents dans tes reponses". C'est probablement un choix pour eviter des problemes d'encodage SMS.

**Verification a faire :** Twilio supporte UTF-8 pour les SMS. Si les accents passent correctement (tester avec un "e accent aigu"), les remettre. Sinon, garder le choix de Dennis.

**Test rapide :** Envoyer un SMS de test avec accents via Twilio et verifier si ca arrive correctement sur le telephone du courtier.

#### P8 — Transfert explicite au courtier (FR-3.2)

**Ajouter :**
```
Si le client demande explicitement a parler a Joanel, reponds:
"Bien sur! Je lui transmets et il vous rappelle des que possible."
```

---

### LOW (nice-to-have)

#### P9 — Pas de regle pour contenu inapproprie

Le prompt ne gere pas le cas ou un prospect envoie du contenu offensant.

**Ajouter dans les regles :**
```
Si le client est agressif ou envoie du contenu inapproprie, reste
professionnel et propose de parler au courtier. Si ca continue,
termine poliment: "Je ne suis pas en mesure de poursuivre cette
conversation. Si vous avez un projet immobilier, n'hesitez pas
a nous recontacter."
```

#### P10 — Prompt hardcode "Joanel" et "plex"

OK pour Sprint 1 (mono-courtier). Pour V1 multi-courtier, remplacer par des variables `{{NOM_COURTIER}}` et `{{SPECIALITE}}`. Pas urgent.

---

## PROMPT CORRIGE COMPLET

Voici le prompt avec toutes les corrections integrees. Les ajouts sont marques avec [AJOUT].

```
Tu es l'adjointe administrative virtuelle de Joanel, courtier immobilier
specialise en plex dans le Grand Montreal.

[AJOUT] Regles absolues:
- Tu ne donnes JAMAIS de conseil sur les prix du marche, le financement,
  les taux hypothecaires, ou les clauses contractuelles
- Tu ne te presentes JAMAIS comme courtier ou professionnel reglemente
- Tu es l'assistante administrative, pas une experte immobiliere
- Tu ne fais JAMAIS de promesse sur les delais ou les resultats
- Si on te demande un avis sur un prix ou un taux, reponds:
  "C'est le genre de question ou Joanel pourra mieux vous guider."
- Si le client demande explicitement a parler a Joanel, reponds:
  "Bien sur! Je lui transmets et il vous rappelle des que possible."
- Si le client est agressif ou inapproprie, reste professionnel.
  Si ca continue, termine poliment la conversation.

Detection de langue:
- Si le client ecrit en anglais, tu reponds en anglais
- Si le client ecrit en francais, tu reponds en francais
- En cas de doute, reponds en francais (langue par defaut)
- La fiche client est TOUJOURS generee en francais (pour le courtier)
- Ajoute dans les notes: Conversation en anglais si applicable

Adaptation au rythme du client:
- Si le client semble HESITANT (mots: peut-etre, je ne suis pas sure,
  je reflechis) utilise le mode doux: une seule question a la fois,
  ton rassurant, pas de pression
- Si le client semble URGENT (mots: vite, urgent, divorce, demenagement,
  delai < 1 mois) utilise le mode raccourci: regroupe 2-3 questions
  par message, va a l'essentiel, skip les questions exploratoires

Ton role:
- Accueillir chaleureusement les prospects par SMS
- Detecter s'ils sont ACHETEUR ou VENDEUR
- Collecter leurs informations de facon naturelle et conversationnelle
- Qualifier le prospect (budget, financement, delai, zone)

Pour un ACHETEUR, tu dois collecter progressivement:
 1. Prenom et nom
 2. Type de bien recherche (plex, condo, maison)
 3. Zone geographique souhaitee
 4. Budget approximatif
 5. Statut de pre-qualification bancaire
 6. Mise de fonds disponible
 7. Proprietaire occupant ou investisseur
 8. Premier acheteur ou non
 9. Delai du projet
10. Disponibilites pour les visites

Pour un VENDEUR, tu dois collecter:
 1. Prenom et nom
 2. Adresse du bien
 3. Type de bien
 4. Prix souhaite
 5. Raison et delai de vente
 6. Occupation actuelle
 7. Disponibilites pour une rencontre avec Joanel [AJOUT]

Ton ton:
- Francais quebecois naturel et chaleureux ou anglais si le client
  ecrit en anglais
- Professionnel mais accessible
- Tu tutois apres le premier echange en francais et reste au you
  en anglais
- Tu poses UNE question a la fois
- Reponses courtes max 2-3 phrases par SMS
- JAMAIS d'emojis
- PAS d'accents dans tes reponses

Si le prospect pose une question complexe, dis-lui que Joanel va le
rappeler personnellement.

Quand tu as collecte toutes les informations necessaires:

[AJOUT] 1. Recapitule les informations au prospect:
   "Voici ce que j'ai note: [resume]. C'est bien exact?"
2. Attends la confirmation du prospect
3. Termine en disant que Joanel va prendre contact sous peu

Evalue le score de chaleur du prospect selon cette grille:
- CHAUD-URGENT (9-10): Situation personnelle urgente (divorce, deces,
  demenagement force) OU delai < 1 mois ET client presse
- CHAUD (7-8): Pre-approuve + budget defini + delai < 3 mois
- TIEDE (4-6): Interesse mais sans urgence, financement en cours
  ou non demarre
- FROID (0-3): Exploration, delai > 6 mois, pas de budget defini

[MODIFIE] Apres la confirmation du prospect, ajoute le mot QUALIFIED
seul sur une derniere ligne (le systeme le retirera automatiquement
avant envoi).
```

---

## CHECKLIST POUR DENNIS

### Avant la demo (critique)
- [ ] Ajouter la section "Regles absolues" dans le prompt (P1)
- [ ] Verifier que QUALIFIED est strip du SMS avant envoi Twilio (P7)

### Samedi
- [ ] Ajouter le recap au prospect avant conclusion (P4)
- [ ] Ajouter Q7 "disponibilites" dans le flux vendeur (P6)
- [ ] Ajouter la regle transfert explicite "je veux parler a Joanel" (P8)
- [ ] Tester les accents UTF-8 via Twilio (P3)
- [ ] Ajouter la regle contenu inapproprie (P9)

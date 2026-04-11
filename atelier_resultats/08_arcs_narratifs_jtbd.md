# Arcs Narratifs JTBD — Histoires de Terrain

## Resultat de l'atelier JTBD — Mars 2026

---

## ARC 1 : Transaction Perdue — Hypotheque

### Flux narratif

```
+----------------------------------+     +----------------------------------+     +---------------------+
|          DECLENCHEUR             |     |        PROBLEME RACINE           |     |    CONSEQUENCE      |
|                                  |     |                                  |     |                     |
|  Client refere, courtier         | --> |  Pas de visibilite sur le        | --> |  TRANSACTION        |
|  hypothecaire externe            |     |  dossier hypothecaire.           |     |  PERDUE             |
|  (pas dans son ecosysteme)       |     |  Le courtier hypothecaire        |     |                     |
|                                  |     |  n'a pas fait le travail.        |     |                     |
+----------------------------------+     +----------------------------------+     +---------------------+
```

### Verbatim

> "Un client qu'on m'a refere, j'avais pas de controle sur la personne
> qui faisait l'hypotheque de ce client-la."

### Les 5 Pourquoi

```
  1. "J'ai perdu une transaction."
     |
     v
  2. "La personne qui faisait l'hypotheque n'a pas fait le travail."
     |
     v
  3. "Je n'avais pas de controle sur elle."
     |
     v
  4. "Je ne pouvais pas voir ou en etait le dossier."
     |
     v
  5. "Il n'y a pas de systeme commun entre courtier immo et courtier hypothecaire."
     |
     v
  +=========================================================================+
  ||  VRAI PROBLEME : Manque de visibilite transversale sur l'ecosysteme   ||
  ||                  de la transaction                                    ||
  +=========================================================================+
```

### Probleme connexe : Fausses pre-qualifications bancaires en ligne

> "Pre-qualification automatique, ca n'a rien checke. La personne pouvait
> pas jusqu'a 400 000, c'est seulement 300 000. La deception."

Les pre-qualifications en ligne donnent une fausse confiance au client.
Le courtier immobilier batit sa strategie sur un montant errone, ce qui
mene a des offres impossibles a financer.

---

## ARC 2 : Transaction Perdue — Inspection/Negociation

### Flux narratif

```
+---------------------------+     +---------------------------+     +---------------------------+
|       INSPECTION          |     |     NEGOCIATION           |     |       RESULTAT            |
|                           |     |                           |     |                           |
|  Inspection revele        | --> |  Vendeur refuse de        | --> |  Retrait de l'offre       |
|  moisissure               |     |  negocier                 |     |  TRANSACTION PERDUE       |
|                           |     |                           |     |                           |
+---------------------------+     +---------------------------+     +---------------------------+
```

### Verbatim

> "L'inspecteur me disait que je pouvais y aller, c'etait quelque chose
> qu'on pouvait corriger facilement. Mais il ne voulait pas negocier
> du tout du tout."

### Lecon

Les transactions echouent souvent a l'etape INSPECTION. Une meilleure
preparation en amont (comparables, historique du bien) pourrait prevenir
ces echecs en armant le courtier de donnees objectives pour la negociation.

---

## ARC 3 : Changement Reussi — Signature Electronique

### Flux narratif (arc positif)

```
+-----------------------+     +-----------------------+     +-----------------------+     +-----------------------+
|     DECLENCHEUR       |     |      ADOPTION         |     |     USAGE REEL        |     |       PREUVE          |
|                       |     |                       |     |                       |     |                       |
|  Clients investisseurs|     |  "On a change"        |     |  "Clients a l'autre   |     |  Ce changement        |
|  a l'autre bout du    | --> |                       | --> |  bout du monde, tout  | --> |  demontre que le      |
|  monde. Avant la      |     |  Passage a la         |     |  se fait en virtuel.  |     |  courtier adopte la   |
|  pandemie, il fallait |     |  signature            |     |  2-3 minutes pour     |     |  tech quand la valeur |
|  tous les rencontrer  |     |  electronique         |     |  une signature."      |     |  est evidente et      |
|                       |     |                       |     |                       |     |  immediate            |
+-----------------------+     +-----------------------+     +-----------------------+     +-----------------------+
```

### Enseignement cle

Le courtier n'est PAS anti-technologie. Il adopte rapidement quand :
- La valeur est evidente (gain de temps concret)
- Le benefice est immediat (pas de courbe d'apprentissage longue)
- Le probleme resolu est reel (clients a distance = bloquant sans solution)

---

## Tableau Recapitulatif

```
+-----+---------------------+-------------------------------+----------------------------------+-----------------+
| Arc | Type                | Cause racine                  | Lecon pour le MVP                | Impact          |
+-----+---------------------+-------------------------------+----------------------------------+-----------------+
|  1  | Transaction perdue  | Manque de visibilite          | Le MVP doit offrir un suivi      | Perte de revenu |
|     | (hypotheque)        | transversale sur le dossier   | transversal immo + hypothecaire  | directe         |
|     |                     | hypothecaire                  |                                  |                 |
+-----+---------------------+-------------------------------+----------------------------------+-----------------+
|  2  | Transaction perdue  | Manque de donnees objectives  | Integrer comparables et          | Perte de revenu |
|     | (inspection)        | pour negocier apres           | historique du bien pour armer    | + temps investi |
|     |                     | inspection                    | la negociation post-inspection   | perdu           |
+-----+---------------------+-------------------------------+----------------------------------+-----------------+
|  3  | Changement reussi   | Contrainte reelle (clients    | Valeur evidente + immediat =     | Preuve que      |
|     | (signature elec.)   | a distance) resolue par       | adoption garantie. Le MVP doit   | l'adoption tech |
|     |                     | tech simple                   | suivre ce modele.                | est possible    |
+-----+---------------------+-------------------------------+----------------------------------+-----------------+
```

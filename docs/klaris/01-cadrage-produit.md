# Klaris — Assistant documentaire pour courtiers immobiliers du Québec

**Version** : 0.1 (dossier de cadrage) · **Date** : 31 juillet 2026 · **Statut** : pré-pilote

---

## 1. Vision

Klaris est un assistant IA qui élimine le travail documentaire répétitif des courtiers immobiliers québécois. Il collecte, classe, vérifie et orchestre les documents d'une transaction — sans jamais toucher aux données de Centris.

**Le principe directeur** : Klaris prépare, le courtier décide. L'humain dans la boucle n'est pas une contrainte, c'est l'argument de vente — le courtier garde le contrôle professionnel et perd uniquement le travail de moine.

**Ce que Klaris n'est pas** : un canal d'accès aux données Centris, un outil qui pose des actes de courtage, un remplaçant du CRM.

---

## 2. Le problème

Une transaction immobilière au Québec fait circuler une quarantaine de documents entre le courtier, ses clients, le notaire, l'inspecteur, le prêteur et la municipalité — éparpillés dans les courriels, les textos et les pièces jointes.

| Côté | Douleur | Coût |
|---|---|---|
| Vendeur (inscription) | Collecte des pièces avant mise en marché | 3 à 4 heures concentrées par dossier |
| Acheteur (conditions) | Suivi des échéances, relances, dossier prêteur | Une date manquée = une transaction qui déraille |
| Les deux | « Peux-tu me renvoyer le document ? » répété | Interruptions constantes, documents introuvables |

La saisie dans Matrix, elle, ne prend que ~20 minutes. La valeur est en amont et en aval de Centris, pas dedans.

---

## 3. Cas d'usage

### 3.1 Côté vendeur — préparation d'inscription (pilote)

Le courtier fait suivre par courriel les pièces reçues (vendeur, municipalité, arpenteur). Klaris extrait, structure, détecte les manquants et produit une **fiche prête à saisir**. Le courtier valide et saisit lui-même dans Matrix.

- Douleur concentrée, gain mesurable en une séance → cas idéal pour prouver la valeur.

### 3.2 Côté acheteur — orchestration des conditions

À la réception de la promesse acceptée, Klaris lit les jalons (inspection, financement, notaire) et devient un **moteur d'échéances** : relances de l'inspecteur, assemblage du dossier prêteur, vérification de complétude avant signature.

- Klaris **alerte**, le courtier **décide et signe**. Aucun avis de réalisation ni renonciation ne part sans validation.
- Rétention : c'est ce qui fait ouvrir Klaris chaque semaine.

### 3.3 Portail client libre-service

Le client (acheteur ou vendeur) accède à ses documents par un lien — sans compte, sans mot de passe. Fin des « renvoie-moi la promesse ».

---

## 4. Cadre juridique et contractuel

### 4.1 Centris — le mur, et comment on le contourne proprement

Les Conditions d'utilisation Centris (version du 1er mai 2026, la version française prévaut) interdisent : le partage de codes d'accès, le scraping et les agents automatisés, le téléchargement/reproduction du Contenu, la rediffusion et l'agrégation. Une exemption écrite est théoriquement possible.

**Décision d'architecture** : Klaris ne se connecte jamais à Centris. Les documents visés (baux, factures, déclarations, rapports, pièces du client) n'appartiennent pas au Contenu Centris — ils appartiennent au courtier et à ses clients.

Contexte à surveiller : enquête active du Bureau de la concurrence sur l'APCIQ/Centris (ordonnances de 2023 et mai 2025) concernant les restrictions au partage de données. Depuis juin 2025, l'accès privé au Tribunal de la concurrence est élargi. **Ça se documente, ça ne se code pas** — la stratégie est de construire à côté et de conserver la trace de toute demande à Centris.

### 4.2 Gradient d'autonomie (décision structurante)

| Niveau | Description | Verdict |
|---|---|---|
| N0 | Le courtier fait tout à la main | Statu quo |
| N1 | Copilote en session, rien ne sort du navigateur | À valider avec Centris |
| N2 | Klaris suggère, sur documents hors Centris | Viable |
| **N3** | **Klaris prépare, le courtier approuve, Klaris exécute** | **Cible** |
| N4 | Envoi autonome sans validation | Bloqué (Centris + responsabilité OACIQ) |

L'écart de valeur N3→N4 est d'environ 30 secondes par demande. L'écart de risque est total (déontologie OACIQ, assurabilité, vente aux agences). N3 capte 100 % du gain vendable.

### 4.3 Loi 25

Klaris devient responsable de renseignements personnels sensibles (revenus, pièces d'identité, rapports). Exigences : chiffrement, hébergement canadien, cloisonnement par dossier, durées de conservation et destruction documentées, journal d'accès. Le test de sécurité bloquant : **le client A ne voit jamais un document du client B.**

---

## 5. Architecture technique

### 5.1 Le canal principal : Lone Wolf TransactionDesk API

Découverte pivot du projet : les documents de transaction vivent dans le DocBox de TransactionDesk (Lone Wolf), pas dans Matrix. Lone Wolf publie une API partenaire ouverte (portail apidocs.lwolf.com, demande d'accès par formulaire).

Ce que la documentation confirme :

- **OAuth code flow** : le courtier s'authentifie lui-même chez Lone Wolf, Klaris reçoit un jeton. Aucun mot de passe ne transite par Klaris. Flux `client_credentials` + `On-Behalf-Of` disponible pour la voie agence.
- **Endpoints documents** : lister, téléverser, récupérer, mettre à jour les documents d'une transaction (DocBox accessible en lecture et écriture).
- **Jalons structurés** : `offerAcceptanceDate`, `applicationDate`, `approvalDate`, `closingDate`, `possessionDate`, `fundingDate` exposés en JSON → le moteur d'échéances n'a pas besoin de lire les PDF (lecture PDF en repli seulement, avec confirmation du courtier).
- Pas de webhooks documentés → synchronisation par interrogation périodique (15-30 min, resserrée près des jalons).
- Environnement de pré-production documenté ; production via l'entente partenaire.

### 5.2 Les trois entrées

| Entrée | Statut | Dépendance |
|---|---|---|
| Courriel (transferts du courtier) | Disponible aujourd'hui | Aucune |
| Lone Wolf TransactionDesk API | Formulaire partenaire à soumettre | Lone Wolf |
| Direct Web API (Cotality/Matrix) | Conditionnel — module optionnel | Activation par Centris |

Le Direct Web API de Cotality existe techniquement (OIDC au nom du courtier, borné à ses privilèges Matrix), mais le MLS contrôle ce qui est exposé. **Aucun chemin critique ne passe par une permission de Centris** — ce canal est un bonus éventuel, jamais une fondation.

### 5.3 Composants du cœur

1. **Coffre documentaire** — chiffré, cloisonné par dossier de transaction, horodaté, conforme Loi 25.
2. **Classification** — typage des documents, rattachement au dossier, détection des manquants et des versions périmées (ex. certificat de localisation).
3. **Moteur d'échéances** — jalons structurés de l'API, relances automatiques, alertes au courtier.
4. **Boucle d'approbation (N3)** — un seul mécanisme de consentement pour toute action sortante (dépôt DocBox, envoi au client, relance).

---

## 6. Modèle d'affaires

### 6.1 Marché

- ~15 000 courtiers actifs, ~700 agences au Québec (APCIQ ≈ 92 % des courtiers).
- ~90 000 transactions résidentielles/an → **~6 transactions par courtier en moyenne**.
- Conséquence structurante : **l'agence est l'acheteur, le courtier est l'utilisateur.**

### 6.2 Modèle retenu

**Licence agence par siège** (25-45 $/siège/mois indicatif). Ancrage : une fraction de point de pourcentage d'une seule commission ; l'agence paie déjà des outils pour ses courtiers.

### 6.3 Acquisition

Deux moteurs complémentaires :
- **Traction par le client** : un acheteur qui exige « envoie-moi ça dans Klaris » convertit son courtier à coût nul.
- **Vente en agence** : le courtier pilote est le canal d'accès à son agence — le choisir influent, pas juste enthousiaste.

### 6.4 Fossé concurrentiel

Pas l'IA (reproductible). Le vrai fossé : **la taxonomie documentaire québécoise** (formulaires OACIQ, règles de complétude par étape, droit civil), l'intégration au flux de travail, et le dossier de conformité opposable.

### 6.5 Risques majeurs

| Risque | Mitigation |
|---|---|
| Incident de confidentialité (existentiel) | Chiffrement, cloisonnement, tests d'accès croisé bloquants |
| Le courtier n'alimente pas | Entrée par courriel = zéro friction, capture automatique |
| CRM existant ajoute la fonction | Vitesse + profondeur métier québécoise, posture complémentaire |
| Faible volume par courtier | Vendre à l'agence, pas à l'individu |

---

## 7. Pilote — ce qu'il doit prouver

Offre au courtier pilote : gratuit, une transaction réelle, ses données exportables, sortie en tout temps, saisie initiale faite pour lui. En échange : 3 h de son temps, métriques anonymisées, lettre d'intention si résultats, présentation à son agence.

Cinq chiffres de sortie :

- [ ] Heures sauvées par transaction (avant/après, chiffre du courtier)
- [ ] Taux d'adoption client (% qui ouvrent le lien et reviennent 2+)
- [ ] Exactitude de classification sans intervention
- [ ] Coût d'infonuagique/IA par transaction (la ligne qui décide de la marge)
- [ ] Volonté de payer (« à 40 $/siège/mois, tu recommandes à ton agence ? »)

Test bloquant unique pour toute mise en production : accès croisé client A / client B → refus + journalisation.

---

## 8. Feuille de route immédiate

1. **Soumettre le formulaire partenaire Lone Wolf** (lwolf.com/api-getting-started) — description : « assistant documentaire pour courtiers québécois, lecture des transactions et dépôt avec approbation ».
2. **Qualifier le courtier pilote** : utilise-t-il TransactionDesk activement ? Qui administre le compte ? Remplit-il les champs de dates ?
3. **Prototype sur l'environnement de pré-production** — premier cas de test : le dossier d'acquisition en cours du fondateur.
4. **Taxonomie documentaire québécoise** (livrable prioritaire — alimente le produit, le pilote et la conformité).
5. **Lettre à Centris** (après réponse Lone Wolf) : notification d'intégration via leur fournisseur d'outil externe + question fermée sur l'activation du Direct Web API. Conserver toute réponse ou absence de réponse.
6. **Dossier de conformité Loi 25** — prêt avant la première rencontre pilote.

---

## 9. Décisions d'architecture consignées

| # | Décision | Justification |
|---|---|---|
| DA-01 | Aucune connexion Klaris ↔ Centris/Matrix | Conditions d'utilisation (codes d'accès, agents, reproduction, rediffusion) |
| DA-02 | Niveau d'autonomie N3 — approbation systématique du courtier | Responsabilité OACIQ, assurabilité, vendabilité en agence |
| DA-03 | Lone Wolf TransactionDesk comme canal API principal | Propriétaire des données = le courtier ; API partenaire ouverte ; OAuth par courtier |
| DA-04 | Entrée courriel comme mécanisme d'alimentation universel | Zéro friction, réversible, aucun nouvel outil à apprendre |
| DA-05 | Jalons structurés de l'API avant lecture PDF | Moins de code, moins d'erreurs, moins de coût d'inférence |
| DA-06 | Direct Web API (Cotality) = module optionnel, jamais critique | Le robinet appartient à Centris ; résilience du chemin critique |
| DA-07 | Passe-plat minimal, conservation encadrée Loi 25 | Périmètre de conformité réduit et documentable |

---

*Document de travail — à valider par conseiller juridique (conditions Centris, Loi 25, droit de la concurrence) avant tout engagement contractuel ou déploiement.*

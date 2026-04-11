---
stepsCompleted: [step-01-init, step-02-discovery, step-02b-vision, step-02c-executive-summary, step-03-success, step-04-journeys, step-05-domain, step-06-innovation, step-07-project-type, step-08-scoping, step-09-functional, step-10-nonfunctional, step-11-polish, step-12-complete]
status: complete
classification:
  projectType: SaaS B2B, AI-Agent-First
  domain: Proptech QC — marche bilingue, professionnel reglemente OACIQ
  complexity: medium
  projectContext: greenfield
  focusPRD: Comportements agent IA d'abord, plateforme ensuite
  riskFlag: Imprevisibilite conversationnelle LLM (NFR explicite)
inputDocuments:
  - _bmad-output/planning-artifacts/product-brief-adjointe-ia-courtier-immobilier-2026-04-11.md
  - atelier_resultats/09_baguette_magique_vision.md
  - atelier_resultats/10_personas_courtiers.md
  - atelier_resultats/03_matrice_douleurs_gains.md
  - atelier_resultats/04_forces_progres_jtbd.md
  - atelier_resultats/11_sprint_mvp_3jours.md
  - mvp_adjointe_ia/SPEC_MVP.md
workflowType: prd
briefCount: 1
researchCount: 0
brainstormingCount: 9
projectDocsCount: 1
---

# Product Requirements Document - adjointe-ia-courtier-immobilier

**Author:** Eliot
**Date:** 2026-04-11

## Executive Summary

Un courtier immobilier solo au Quebec perd 3 a 4 heures par jour en taches administratives — reponses aux clients, saisie de donnees, relances manuelles, suivi de dossiers. Chaque heure perdue, c'est un prospect qui refroidit et un deal qui glisse. Les trois courtiers interviews (Joanel, Maxime, Charlyse) le confirment unanimement : l'admin est l'ennemi, et le temps soustrait au terrain coute des transactions.

L'Adjointe IA du Courtier Immobilier est un agent conversationnel autonome deploye sur SMS via le numero existant du courtier. Elle repond aux prospects en moins de 60 secondes, collecte leurs informations via une conversation guidee en francais quebecois naturel, genere automatiquement une fiche client structuree, notifie le courtier, et declenche les relances programmees — le tout sans intervention humaine.

**Scope progressif :**
- **MVP (Sprint 1)** : Premier contact automatique, collecte structuree (acheteur 9Q / vendeur 6Q), fiche client, notifications courtier, relances (J+2, J+5, J-1), briefing quotidien 7h30
- **Sprint 2** : Calendrier Google, planification visites, dashboard enrichi
- **Sprint 3** : Analyse comparables, generation d'offres d'achat
- **V1 Publique** : Multi-courtier SaaS, onboarding, pricing

La vision long terme vise l'automatisation de 80-90% des taches administratives du courtier. Le MVP Sprint 1 couvre le premier maillon critique : le premier contact, la collecte et la qualification — la ou les prospects se perdent aujourd'hui.

### What Makes This Special

Ce n'est pas un CRM. Les CRM organisent le travail — l'Adjointe IA le fait. La difference fondamentale : les outils existants (Matrix, Pipedrive, Immo Plus) attendent que le courtier agisse. L'Adjointe agit en son nom, dans son ton, avec sa personnalite.

**Differentiateurs cles :**
- **Agent-first, pas outil-first** : remplace une action humaine, pas un formulaire
- **Friction minimale au quotidien** : setup initial guide une seule fois (message d'accueil, ton, preferences), puis le courtier n'a plus rien a faire — le prospect SMS arrive, l'IA gere
- **Ton quebecois authentique** : le prospect ne sait pas qu'il parle a une IA — chaleureux, professionnel, jamais robotique
- **Fiabilite observable** : le courtier voit chaque conversation, chaque fiche, chaque relance — confiance par la transparence (critere #1 de Charlyse)
- **Cout operationnel disruptif** : 35-50$/mois en infrastructure (Twilio + Claude API + Supabase + n8n) vs 2 500-3 000$/mois pour une adjointe humaine au Quebec. Pricing SaaS a definir en V1 publique.

**Core insight :** La triple convergence de 2026 (qualite LLM au-dessus du seuil d'inconfort, cout marginal < 1h de travail humain, infrastructure SMS standardisee) rend possible en 3 jours ce qui aurait necessite une equipe pendant 6 mois il y a 3 ans.

## Project Classification

| Dimension | Valeur |
|-----------|--------|
| **Type de projet** | SaaS B2B, AI-Agent-First |
| **Domaine** | Proptech QC — marche bilingue, professionnel reglemente OACIQ |
| **Complexite** | Medium (Loi 25 + OACIQ + risque conversationnel LLM) |
| **Contexte** | Greenfield |
| **Focus PRD** | Comportements agent IA d'abord, plateforme ensuite |

## Success Criteria

### User Success

| Critere | Avant (estime) | Cible MVP | Mesure |
|---------|----------------|-----------|--------|
| Temps 1re reponse au prospect | 1-4 heures | < 60 secondes | Timestamp Twilio (SMS entrant → sortant) |
| Relances oubliees par semaine | 3-5 | 0 | Table `relances` — aucune relance en statut `manquee` |
| Temps admin courtier par jour | 3-4 heures | < 30 minutes | Auto-declaration courtier pilote (Joanel) |
| Completude fiche client | Manuelle, partielle | 100% des champs collectes par l'IA | Champs non-null dans table `clients` |

**Moment "aha!" :** Le courtier recoit un SMS de notification a 22h avec un resume complet d'un prospect qualifie — sans avoir touche son telephone.

**Moment de confiance (Charlyse) :** Le courtier ouvre le dashboard, voit la conversation complete, verifie que l'IA n'a rien dit d'incorrect — et decide de lui faire confiance pour la prochaine.

### Business Success

| Metrique | Cible 1 mois | Cible 3 mois | Cible 12 mois |
|----------|-------------|-------------|--------------|
| Courtier pilote actif | 1 (Joanel) | 1-3 (Joanel + Maxime + Charlyse) | 10+ courtiers payants |
| Taux de retention prospect | > 90% (vs ~70% aujourd'hui) | > 90% stable | > 90% |
| Documents recus < 5 jours | 80% | 85% | 90% |
| Prospects perdus (inactifs) | < 10% (vs ~30% aujourd'hui) | < 10% | < 5% |
| Satisfaction courtier (5 scenarios test : pertinence reponses, ton naturel, completude fiche, utilite notification, fiabilite globale — note /5 chaque) | Score moyen >= 4/5 | >= 4.2/5 | >= 4.5/5 |

### Technical Success

| Critere | Cible | Non-negociable |
|---------|-------|---------------|
| Disponibilite SMS | 24/7, 99.5%+ | Oui — c'est la proposition de valeur |
| Conformite Loi 25 | Donnees au Canada (ca-central-1), consentement, droit de suppression | Oui — reglementaire |
| Fiabilite extraction JSON | > 95% des fiches client generees correctement | Oui — sinon l'IA perd la confiance |
| Latence end-to-end | SMS entrant → reponse sortante < 60s | Oui — claim central du produit |
| Zero conseil juridique/financier | L'IA ne donne JAMAIS de conseil sur prix, financement, clauses | Oui — OACIQ, responsabilite courtier |

### Measurable Outcomes

**Dimanche 19h (fin Sprint 1) — Definition of Done :**
1. Un prospect peut envoyer un SMS au numero du courtier
2. L'IA repond en < 60 secondes, en francais QC naturel
3. L'IA collecte les infos (acheteur OU vendeur) via conversation guidee
4. Une fiche client est creee automatiquement dans Supabase
5. Le courtier recoit une notification SMS + email avec le resume
6. Les relances automatiques sont planifiees (J+2, J+5, J-1)
7. Le courtier recoit un briefing quotidien a 7h30
8. Le courtier pilote a vu la demo et dit : « Je veux l'utiliser »

## Product Scope

### MVP — Sprint 1 (3 jours : Ven-Sam-Dim)

- Reponse automatique SMS < 60 secondes
- Flux acheteur guide (9 questions structurees)
- Flux vendeur guide (6 questions structurees)
- Fiche client auto-generee dans Supabase
- Score chaleur automatique (chaud / tiede / froid)
- Notification courtier par SMS + courriel (resume structure)
- Relances automatiques (J+2, J+5, J-1 avant RDV)
- Briefing quotidien envoye a 7h30 chaque matin
- Dashboard simple (Notion ou web)

### Growth — Sprint 2 (Semaine 3-4)

- Integration Google Calendar (disponibilites courtier)
- Planification automatique de visites
- Rappels pre-visite (J-1, H-2)
- Post-visite : "Comment s'est passee la visite?"
- Dashboard enrichi (pipeline, stats semaine)
- Suivi courtier hypothecaire (relances J+3, J+7)

### Vision — Sprint 3+ et V1 Publique

- Analyse comparables automatique depuis les donnees de marche
- Generation d'offres d'achat pre-remplies
- Multi-courtier SaaS (onboarding self-serve)
- Pricing et modele d'affaires
- Bilingue FR/EN complet
- Integration Matrix/Centris (si acces API disponible)
- Interface vocale (dicter sur la route — vision Joanel + Maxime)

## User Journeys

### Journey 1 : Joanel — Le prospect a 22h en mars (Primary User - Success Path)

**Scene d'ouverture :** Mardi, 22h15. Joanel est epuise — 3 visites aujourd'hui, 2 offres a rediger. Son telephone vibre : un SMS d'un inconnu. "Bonsoir, je cherche un duplex a Verdun, budget 450K, est-ce que vous etes disponible?" Avant l'Adjointe IA, Joanel aurait vu le message le lendemain matin. Le prospect aurait deja contacte 2 autres courtiers.

**Action montante :** L'Adjointe repond en 18 secondes : "Bonsoir! Merci de contacter Joanel, courtier immobilier. Je suis son assistante. Pour mieux vous servir, est-ce que vous cherchez a acheter ou a vendre?" Le prospect repond "acheter". L'IA deroule les 9 questions : secteur, budget, pre-qualification, type de propriete, chambres, delai, disponibilites. Le prospect repond a son rythme, sur 12 minutes.

**Climax :** A 22h32, Joanel recoit une notification SMS : "NOUVEAU PROSPECT [CHAUD] — Pierre Tremblay, acheteur, Verdun, duplex 450K, pre-qualifie Desjardins, dispo soirs + weekends, delai 1-3 mois. Prochaine action : planifier premiere rencontre cette semaine." En parallele, un courriel enrichi avec la conversation complete.

**Resolution :** Le lendemain a 7h30, Joanel recoit son briefing : "AUJOURD'HUI : rappeler Pierre T. (prospect chaud d'hier soir). 2 relances en cours. 0 alerte." Il appelle Pierre a 8h. Pierre est impressionne — "wow, votre equipe est reactive". Joanel sourit. Il n'a rien fait.

### Journey 2 : Prospect vendeur hesitant + cas inverse urgent (Primary User - Edge Cases)

**Scene A — Hesitant :** Marie envoie un SMS un samedi : "Bonjour, je pense peut-etre vendre ma maison mais je ne suis pas sure." L'IA detecte l'hesitation, adapte son ton : "Pas de souci, on n'est pas presses." Elle pose les 6 questions vendeur en mode doux. A "Quand aimeriez-vous avoir vendu?", Marie repond "Je ne sais pas." L'IA : "C'est normal d'y reflechir. Je note vos informations et Joanel pourra vous contacter quand vous serez prete." Score : TIEDE. Relance J+5 : Marie revient 3 semaines plus tard. Lead pas perdu.

**Scene B — Urgent :** Luc envoie : "Je dois vendre VITE, mon divorce est finalise dans 3 semaines." L'IA detecte l'urgence. Elle raccourcit le flux : questions essentielles seulement (adresse, type, disponibilites), skip les questions exploratoires. Score : CHAUD-URGENT. Notification courtier immediate avec flag urgence : "PROSPECT URGENT — delai 3 semaines, situation personnelle. Appeler aujourd'hui." Joanel rappelle dans l'heure.

### Journey 3 : Charlyse verifie et fait confiance (Admin/Operations)

**Scene d'ouverture :** Charlyse configure l'Adjointe : message d'accueil, ton, horaires. Premier prospect. Elle est nerveuse — "Est-ce que l'IA va dire une connerie en mon nom?"

**Action montante :** Le prospect pose une question technique : "C'est quoi les frais de condo au 450 Rachel?" L'IA repond : "Excellente question! C'est le genre de detail que Charlyse pourra vous donner avec precision. Je lui transmets." Notification : "TRANSFERT — question technique hors-scope. Client : Jean D."

**Climax :** Charlyse ouvre le dashboard. Conversation complete, mot par mot. L'IA n'a rien invente. Pas de prix. Transfert correct. Elle se dit : "OK, c'est fiable."

**Resolution :** Apres 5 conversations verifiees sans erreur, Charlyse arrete de verifier chaque mot. La "fiabilite observable" a fonctionne.

### Journey 4 : Haute saison — 4 prospects en parallele (Stress Test)

**Scene :** Mars, haute saison. 4 nouveaux prospects SMS en une journee. L'Adjointe gere les 4 conversations en parallele. Chaque prospect recoit une reponse en < 60 secondes. L'IA maintient le contexte de chaque conversation. A 21h, Joanel a 4 nouvelles fiches : 2 chauds, 1 tiede, 1 froid. Il n'a pas envoye un seul SMS — il etait en visite toute la journee. Son volume passe de 3 a 5 prospects qualifies/semaine.

### Journey 5 : Prospect anglophone a Montreal (Edge Case - Langue)

David envoie : "Hi, I'm looking for a condo in Griffintown, around 500K." L'IA detecte l'anglais et switch. Le flux acheteur se deroule en anglais, meme structure, meme qualite. Fiche client generee en francais pour le courtier avec note : "Conversation en anglais. Client anglophone." Joanel rappelle David en anglais. Transition fluide.

### Journey 6 : Le prospect qui revient (Continuite conversationnelle)

**Scene :** Pierre Tremblay (Journey 1) renvoie un SMS 2 semaines plus tard : "Bonjour, j'ai visite un duplex sur Rachel, je voulais en discuter."

**Action montante :** L'IA reconnait le numero. Elle ne recommence PAS de zero. "Re-bonjour Pierre! Content d'avoir de vos nouvelles. Je vois que vous cherchiez un duplex a Verdun autour de 450K. Vous avez fait une visite — super! Est-ce que vous voulez que je transmette vos impressions a Joanel, ou vous avez des questions?"

**Climax :** Pierre se sent reconnu. Il n'a pas a se repeter. L'IA met a jour la fiche existante avec les nouvelles informations. Notification courtier : "MISE A JOUR — Pierre T. a visite, demande suivi."

**Resolution :** La continuite conversationnelle separe une vraie adjointe d'un bot. Pierre pense qu'il parle a la meme personne depuis le debut.

### Journey 7 : Quand ca casse — Erreur systeme (Fallback & Recovery)

**Scene A — Claude API lent (> 60s) :** Le prospect envoie un SMS. n8n appelle Claude mais la reponse depasse 45 secondes. A 50s, le systeme envoie un message d'attente : "Merci pour votre message! Je prends note et je vous reviens dans quelques instants." La reponse complete arrive a 75 secondes. Le prospect ne sent pas de trou.

**Scene B — Twilio down :** Le webhook ne recoit pas le SMS. Le systeme de monitoring detecte l'absence de trafic apres 30 minutes. Alerte courtier par email : "ATTENTION — le systeme SMS semble inactif depuis 14h30. Verifiez vos messages directement." Le courtier n'est jamais laisse dans l'ignorance.

**Scene C — Supabase erreur d'ecriture :** La fiche client ne se sauvegarde pas. Le systeme retry 3 fois. Si echec persistant : la conversation continue normalement (l'IA a le contexte en memoire), l'alerte technique est loguee, et le courtier recoit une notification : "Fiche client en attente de sauvegarde — conversation en cours avec [prospect]."

**Regle d'or :** Le prospect ne voit JAMAIS une erreur. Le courtier est TOUJOURS informe.

### Journey 8 : Spam, STOP, et contenu inapproprie (Securite operationnelle)

**Scene A — "STOP" :** Un numero envoie "STOP". Obligation legale Twilio : l'IA arrete immediatement toute communication avec ce numero. Confirmation : "Vous avez ete desabonne. Pour vous reabonner, ecrivez START." Le numero est blackliste dans Supabase.

**Scene B — Spam/pub :** Un message entrant est detecte comme spam (patterns : liens suspects, texte promotionnel, messages en masse). L'IA ne repond PAS. Le message est logue avec tag "spam" mais aucune fiche client n'est creee. Aucune notification courtier.

**Scene C — Contenu inapproprie :** Un message contient du contenu offensant ou du harcelement. L'IA repond une seule fois : "Je ne suis pas en mesure de poursuivre cette conversation. Si vous avez un projet immobilier, n'hesitez pas a nous recontacter." Le numero est flagge. Alerte courtier : "Message inapproprie recu de [numero]. Conversation fermee."

### Journey Requirements Summary

| Journey | Capacites revelees |
|---------|-------------------|
| **Joanel 22h** | Reponse < 60s, flux acheteur 9Q, fiche client auto, notification courtier, briefing matin |
| **Hesitant + Urgent** | Detection intention/urgence, adaptation ton et rythme, score TIEDE vs CHAUD-URGENT, relance J+5, raccourci flux |
| **Charlyse verifie** | Dashboard conversations, transfert hors-scope, fiabilite observable, setup initial |
| **Haute saison** | Conversations paralleles, maintien contexte, volume scaling, pipeline multi-prospect |
| **Anglophone** | Detection langue, switch FR/EN, fiche bilingue, notification FR pour courtier |
| **Prospect revient** | Reconnaissance numero, reprise contexte, mise a jour fiche existante, continuite conversationnelle |
| **Erreur systeme** | Message d'attente, alerte courtier, retry automatique, monitoring, fallback gracieux |
| **Spam/STOP/inapproprie** | Filtrage entree, obligation legale STOP, blacklist, protection courtier, zero fiche spam |

## Domain-Specific Requirements

### Conformite reglementaire

| Reglementation | Exigence | Impact sur le produit |
|---------------|----------|----------------------|
| **Loi 25 (RLRQ c. P-39.1)** | Donnees personnelles hebergees au Canada, consentement explicite, droit de suppression, registre des incidents | Supabase en ca-central-1, consentement au premier SMS, endpoint de suppression, logs d'incidents |
| **LPRPDE (federal)** | Protection des renseignements personnels dans le secteur prive | Chiffrement en transit (TLS) + au repos, acces restreint aux donnees |
| **OACIQ** | Le courtier est responsable de toute communication faite en son nom. L'IA ne peut donner de conseil juridique, financier ou d'evaluation | Regles strictes dans le prompt systeme : zero conseil prix/financement/clauses. Transfert obligatoire pour questions techniques |
| **Twilio (TCPA/CASL)** | Obligation de gerer les "STOP", pas de spam, opt-in implicite par premier contact entrant | Blacklist automatique sur STOP, pas d'envoi non-sollicite, log de consentement |

### Contraintes domaine immobilier QC

- L'IA ne doit JAMAIS se presenter comme courtier ou donner l'impression d'etre un professionnel reglemente
- L'IA ne donne pas d'avis sur la valeur d'une propriete, le financement, ou les clauses contractuelles
- Les donnees clients (noms, coordonnees, situations financieres) sont des renseignements personnels au sens de la Loi 25
- Le courtier reste le seul responsable de la relation client — l'IA est un outil d'assistance, pas un remplacement
- Bilinguisme FR/EN requis pour le marche montrealais

## Innovation Focus

### Signaux d'innovation identifies

| Signal | Description | Risque | Validation |
|--------|------------|--------|-----------|
| **Agent IA conversationnel autonome** | L'IA agit en nom du courtier via SMS — pas un chatbot reactif mais un agent proactif | Le prospect decouvre que c'est une IA et perd confiance | Tests avec vrais prospects, feedback Joanel sur le ton |
| **Cout disruptif (60x moins cher)** | 35-50$/mois vs 2 500-3 000$/mois pour une adjointe humaine | Le prix bas signale "basse qualite" | Demo live dimanche — prouver la valeur avant de parler prix |
| **Conversation naturelle en francais QC** | LLM qui parle comme un vrai quebecois, pas un francais de France | Le ton sonne faux ou trop formel | Iteration prompt + validation par 3 courtiers natifs |
| **Scoring chaleur automatique** | L'IA evalue l'intention d'achat/vente en temps reel | Score inexact → mauvaise priorisation | Calibration sur 50+ conversations tests |

### Approche de validation MVP

Demo live dimanche a Joanel : Joanel dit "je veux l'utiliser" (NPS > 8), temps < 60s sur 100% des tests, zero hallucination, ton "sonne vrai".

## Project-Type Specific Requirements (SaaS B2B, AI-Agent-First)

### Architecture multi-tenant (design for future)

| Aspect | MVP (Sprint 1) | V1 Publique |
|--------|----------------|-------------|
| Tenancy | Mono-courtier (config_courtier unique) | Multi-tenant (config_courtier par courtier) |
| Auth | Aucune — acces direct Joanel | Auth simple (email + magic link) |
| Isolation donnees | Une seule instance | Row-Level Security par courtier_id |
| Onboarding | Manuel (equipe NextMove configure) | Self-serve (formulaire + setup guide) |
| Billing | Gratuit (pilote) | Stripe integration, tiers a definir |

### Integrations

| Service | Role | MVP | Post-MVP |
|---------|------|-----|----------|
| **Twilio** | SMS bidirectionnel | Oui — coeur du produit | WhatsApp (Sprint 2) |
| **Claude API** | Intelligence conversationnelle | Sonnet 4.6 | Evaluation newer models |
| **Supabase** | Stockage + auth | PostgreSQL ca-central-1 | + Realtime pour dashboard |
| **n8n** | Orchestration workflows | Cloud ou Docker | Scale horizontale |
| **SendGrid** | Email notifications | Notifications courtier | Templates marketing (V1) |
| **Google Calendar** | Disponibilites courtier | Non (Sprint 2) | Lecture + ecriture |
| **Matrix/Centris** | Donnees proprietes OACIQ | Non (hors scope) | Si API disponible (V1+) |

### Scope Creep Mitigations

| Risque | Mitigation |
|--------|-----------|
| "Ajoutons le calendrier Google!" | Non — Sprint 2. Scope fige vendredi 12h. |
| "L'IA devrait faire des comparables" | Non — Sprint 3. |
| "Dashboard plus beau" | Nice-to-have. Priorite = SMS + IA. |
| "Integration Matrix?" | Hors scope. Pas d'API disponible. |

## Functional Requirements — THE CAPABILITY CONTRACT

### CAP-1 : Reponse automatique au premier contact

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-1.1 | Le systeme repond a tout SMS entrant au numero du courtier en < 60 secondes | MUST | 1 |
| FR-1.2 | Le message d'accueil est personnalisable par le courtier (nom, ton, salutation) | MUST | 1 |
| FR-1.3 | Le systeme detecte automatiquement si le prospect est acheteur ou vendeur | MUST | 1 |
| FR-1.4 | Le systeme detecte la langue du prospect (FR/EN) et adapte la conversation. Fallback : repondre en francais si detection EN non prete | MUST | 1 |
| FR-1.5 | Si le LLM depasse 50 secondes, un message d'attente est envoye | MUST | 1 |
| FR-1.6 | Si l'intention acheteur/vendeur n'est pas detectable, l'IA pose la question explicitement : "Est-ce que vous cherchez a acheter ou a vendre?" | MUST | 1 |

### CAP-2 : Flux conversationnel guide

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-2.1 | Flux acheteur : 9 questions structurees | MUST | 1 |
| FR-2.2 | Flux vendeur : 6 questions structurees | MUST | 1 |
| FR-2.3 | L'IA adapte son rythme : mode doux (1 question par message, ton rassurant) ou raccourci urgent (2-3 questions par message, skip questions exploratoires) | SHOULD | 1 |
| FR-2.4 | L'IA maintient le contexte conversationnel via la table `conversations` dans Supabase + injection des 10 derniers messages dans le prompt Claude a chaque interaction | MUST | 1 |
| FR-2.5 | L'IA envoie un resume structure au prospect a la fin de la collecte | MUST | 1 |
| FR-2.6 | L'IA ne pose jamais la meme question deux fois dans une conversation | MUST | 1 |

### CAP-3 : Transfert et guardrails

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-3.1 | Si question technique (prix, frais, clauses, financement), transfert au courtier | MUST | 1 |
| FR-3.2 | Si le prospect demande a parler au courtier, confirmation + notification immediate | MUST | 1 |
| FR-3.3 | L'IA ne donne JAMAIS de conseil juridique, financier, ou d'evaluation | MUST | 1 |
| FR-3.4 | L'IA ne se presente JAMAIS comme courtier ou professionnel reglemente | MUST | 1 |

### CAP-4 : Fiche client et scoring

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-4.1 | Fiche client structuree creee dans Supabase (17 champs) a la fin de la collecte | MUST | 1 |
| FR-4.2 | Score chaleur automatique (CHAUD / CHAUD-URGENT / TIEDE / FROID) | MUST | 1 |
| FR-4.3 | Reconnaissance du numero pour prospects qui reviennent — reprise contexte | MUST | 1 |
| FR-4.4 | Mise a jour fiche existante (pas de duplication) lors d'interactions subsequentes | MUST | 1 |

### CAP-5 : Notifications courtier

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-5.1 | Notification SMS courtier avec resume structure apres chaque collecte | MUST | 1 |
| FR-5.2 | Courriel enrichi (SendGrid) avec fiche complete + lien conversation | MUST | 1 |
| FR-5.3 | Prospects CHAUD-URGENT : notification immediate (pas en batch) | MUST | 1 |
| FR-5.4 | Transferts hors-scope : notification avec la question du prospect | MUST | 1 |

### CAP-6 : Relances automatiques

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-6.1 | Relance J+2 : rappel amical documents | MUST | 1 |
| FR-6.2 | Relance J+5 : proposition d'aide + rappel | MUST | 1 |
| FR-6.3 | Relance J-1 : rappel rendez-vous demain | MUST | 1 |
| FR-6.4 | Relance H-2 : rappel rendez-vous dans 2 heures | SHOULD | 2 |
| FR-6.5 | Alerte courtier J+10 : "Client froid — relancer?" | SHOULD | 1 |
| FR-6.6 | Post-visite J+1 : "Comment s'est passee la visite?" | SHOULD | 2 |

### CAP-7 : Briefing quotidien

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-7.1 | SMS + email chaque matin a 7h30 avec resume de la journee | MUST | 1 |
| FR-7.2 | Contenu : RDV du jour, prospects en attente, alertes, nouveaux prospects, stats | MUST | 1 |

### CAP-8 : Dashboard courtier

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-8.1 | Vue prospects actifs par score chaleur | SHOULD | 1 |
| FR-8.2 | Vue relances en cours et planifiees | SHOULD | 1 |
| FR-8.3 | Vue conversations completes (audit de fiabilite) | MUST | 1 |
| FR-8.4 | Vue pipeline par statut (funnel) | SHOULD | 2 |
| FR-8.5 | Le courtier peut modifier le score chaleur et corriger la fiche client depuis le dashboard | MUST | 1 |

### CAP-9 : Securite et filtrage

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-9.1 | Messages "STOP" desabonnent immediatement (obligation legale Twilio/CASL) | MUST | 1 |
| FR-9.2 | Messages spam detectes et ignores : patterns = liens URL suspects, texte promotionnel, messages identiques en masse. Zero fiche, zero notification | SHOULD | 1 |
| FR-9.3 | Messages inappropries : reponse unique de fermeture + alerte courtier | SHOULD | 1 |
| FR-9.4 | Donnees hebergees au Canada (ca-central-1) | MUST | 1 |
| FR-9.5 | Droit de suppression des donnees prospect (Loi 25) | MUST | 1 |

### CAP-10 : Configuration courtier

| ID | Exigence | Priorite | Sprint |
|----|----------|----------|--------|
| FR-10.1 | Configuration nom, message d'accueil, preferences de ton | MUST | 1 |
| FR-10.2 | Definition horaires de disponibilite | SHOULD | 2 |
| FR-10.3 | Liste partenaires (courtier hypothecaire, inspecteur, notaire) | SHOULD | 2 |

## Non-Functional Requirements

### NFR-1 : Performance

| ID | Exigence | Cible | Mesure |
|----|----------|-------|--------|
| NFR-1.1 | Latence SMS end-to-end | < 60 secondes (P95) | Timestamp Twilio entrant vs sortant |
| NFR-1.2 | Latence Claude API | < 15 secondes (P95) | Log n8n execution time |
| NFR-1.3 | Chargement dashboard | < 2 secondes | Lighthouse / Web Vitals |
| NFR-1.4 | Debit concurrent | 10+ conversations simultanees | Test de charge n8n |
| NFR-1.5 | Message d'attente si > 50s | 100% des cas | Monitoring n8n timeout |

### NFR-2 : Fiabilite et disponibilite

| ID | Exigence | Cible |
|----|----------|-------|
| NFR-2.1 | Disponibilite SMS 24/7 | 99.5%+ |
| NFR-2.2 | Retry auto en cas d'echec | 3 tentatives, backoff exponentiel |
| NFR-2.3 | Alerte courtier si systeme inactif > 30 min | Email + SMS fallback |
| NFR-2.4 | Si Supabase est temporairement indisponible | Retry ecriture 3x avec backoff. Si echec persistant : conversation continue (contexte dans le prompt en cours), alerte technique loguee, notification courtier. Accepter la perte de persistance plutot que bloquer la conversation |

### NFR-3 : Securite et conformite

| ID | Exigence | Cible | Reglementation |
|----|----------|-------|---------------|
| NFR-3.1 | Donnees au Canada exclusivement | Supabase ca-central-1 | Loi 25 |
| NFR-3.2 | Chiffrement en transit | TLS 1.2+ | LPRPDE |
| NFR-3.3 | Chiffrement au repos | AES-256 | Loi 25 |
| NFR-3.4 | Pas de donnees client dans les logs | Logs anonymises (IDs) | Loi 25 |
| NFR-3.5 | Droit de suppression operationnel | < 48h apres demande | Loi 25 art. 27 |
| NFR-3.6 | Cles API non exposees dans le code | Variables d'environnement | Best practice |

### NFR-4 : Qualite conversationnelle (AI-Agent-First)

| ID | Exigence | Cible |
|----|----------|-------|
| NFR-4.1 | Ton quebecois naturel — jamais robotique | Validation courtier natif |
| NFR-4.2 | Zero hallucination sur des faits | 100% |
| NFR-4.3 | Extraction JSON fiche client fiable | > 95% champs corrects |
| NFR-4.4 | Continuite conversationnelle (prospect revient) | 100% reconnaissance |
| NFR-4.5 | Transfert courtier correct (zero conseil hors-scope) | 100% |
| NFR-4.6 | Historique injecte dans le prompt limite aux 10 derniers messages + fiche client resumee | Eviter depassement fenetre contexte Sonnet |

### NFR-5 : Scalabilite (design for future)

| ID | MVP | V1 Publique |
|----|-----|-------------|
| NFR-5.1 | 1 courtier | 100+ courtiers |
| NFR-5.2 | 10+ conversations simultanees | 1000+ |
| NFR-5.3 | Instance unique | RLS par courtier_id |
| NFR-5.4 | Monolithique (n8n + Supabase) | Microservices si necessaire |

## Assumptions & Dependencies

| # | Assumption / Dependance | Risque si invalide | Mitigation |
|---|------------------------|-------------------|-----------|
| A1 | Twilio approuve un numero QC (+1 514/438) dans les 24-48h | Bloquant J1 — pas de SMS | Commander le numero AVANT vendredi |
| A2 | Claude API (Sonnet 4.6) est disponible et stable | Pas d'IA | Compte Anthropic cree + cle API testee avant vendredi |
| A3 | Supabase region ca-central-1 est disponible | Pas de DB | Creer le projet Supabase avant vendredi |
| A4 | n8n Cloud ou Docker est operationnel | Pas d'orchestration | Installer n8n des vendredi matin (premiers arrives) |
| A5 | Joanel est disponible dimanche 17h pour la demo | Pas de validation pilote | Confirmer sa disponibilite AVANT vendredi |
| A6 | L'equipe de 4 est disponible vendredi-samedi-dimanche | Sprint incomplet | Confirmer les horaires d'arrivee de chacun |
| A7 | Le NDA est signe avant que Joanel partage ses identifiants Matrix | Pas d'acces aux donnees de test reelles | NDA genere et pret (NDA_NextMove_Joanel_Dupart.docx) |

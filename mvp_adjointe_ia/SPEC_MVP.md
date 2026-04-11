# MVP — Adjointe IA du Courtier Immobilier

## Resume Executif

**Produit:** Agent IA conversationnel qui agit comme adjointe administrative pour un courtier immobilier.

**Probleme:** Le courtier travaille seul, repond trop lentement a ses clients, oublie des relances, et perd du temps sur l'administratif au lieu de vendre.

**Solution MVP:** Une adjointe IA qui repond aux clients instantanement, collecte leurs informations, relance automatiquement, planifie les visites, et envoie un resume quotidien au courtier.

**Utilisateur principal:** Un courtier immobilier au Quebec (pilote: courtier interviewe)

**Contraintes:**
- Pas d'integration Matrix/Centris en v1
- Loi 25 (protection des donnees personnelles)
- L'IA ne fait PAS d'appels vocaux aux clients
- L'IA ne remplace PAS le courtier pour les visites/signatures

---

## Sprint 1 — "Elle repond et collecte" (Semaine 1-2)

### Cas d'usage 1.1 — Reponse automatique au premier contact

**Declencheur:** Un prospect contacte le courtier via SMS ou courriel.

**Flux:**

```
Prospect envoie un message
     |
     v
Agent IA detecte le message (via Twilio/courriel)
     |
     v
Agent IA repond en < 60 secondes:
     |
     "Bonjour! Merci de contacter [Nom du Courtier],
      courtier immobilier. Je suis son assistante.
      Pour mieux vous servir, j'aurais quelques
      questions rapides. Est-ce que vous cherchez
      a acheter ou a vendre?"
     |
     v
Conversation guidee (voir flux ci-dessous)
     |
     v
Fiche client generee + notification au courtier
```

**Regles:**
- Ton: chaleureux, professionnel, quebecois naturel (pas de francais de France)
- Ne JAMAIS mentionner que c'est une IA
- Si le client pose une question technique precise → transferer au courtier
- Si le client veut parler au courtier directement → "Bien sur! Je lui transmets votre message et il vous rappellera des que possible."
- Heures de reponse: 24/7 pour le premier contact, mais mentionner les heures d'ouverture pour un rappel humain

### Cas d'usage 1.2 — Collecte d'information structuree

**Flux conversationnel — Acheteur:**

```
Q1: "Est-ce que vous cherchez a acheter ou a vendre?"
     |
     [ACHETEUR]
     |
Q2: "Super! Dans quel secteur vous aimeriez acheter?"
     |
Q3: "C'est quoi votre budget approximatif?"
     |
Q4: "C'est pour une premiere maison ou vous etes
     deja proprietaire?"
     |
Q5: "Est-ce que vous avez deja une pre-qualification
     hypothecaire avec votre banque?"
     |
     [SI NON] → "C'est une etape importante. [Courtier]
     travaille avec un courtier hypothecaire de confiance
     qui pourra vous aider. On va vous mettre en contact."
     |
     [SI OUI] → "Parfait! Jusqu'a combien vous etes
     pre-qualifie?"
     |
Q6: "Quel type de propriete vous cherchez?
     (maison, condo, duplex, triplex...)"
     |
Q7: "Combien de chambres minimum?"
     |
Q8: "Quand est-ce que vous aimeriez avoir achete
     idealement? (1 mois, 3 mois, 6 mois, pas de rush)"
     |
Q9: "Quelles sont vos disponibilites pour une premiere
     rencontre avec [Courtier]? (jour/soir/weekend)"
     |
RESUME: "Merci beaucoup! Voici ce que j'ai note:
[Resume structure]. [Courtier] va vous contacter
dans les prochaines 24h pour planifier la suite.
Bonne journee!"
```

**Flux conversationnel — Vendeur:**

```
Q1: [VENDEUR]
     |
Q2: "Dans quel secteur se trouve votre propriete?"
     |
Q3: "C'est quel type de propriete?
     (maison, condo, duplex, triplex...)"
     |
Q4: "Approximativement, c'est quand que vous
     aimeriez avoir vendu?"
     |
Q5: "Est-ce que vous avez deja une idee du prix
     que vous aimeriez obtenir?"
     |
Q6: "Quelles sont vos disponibilites pour une
     rencontre avec [Courtier] pour evaluer
     votre propriete?"
     |
RESUME + notification courtier
```

**Donnees collectees → Fiche client:**

| Champ | Type | Obligatoire |
|-------|------|-------------|
| nom_complet | texte | oui |
| telephone | texte | oui |
| courriel | texte | non |
| type (acheteur/vendeur) | enum | oui |
| secteur_recherche | texte | oui |
| budget_min | nombre | non |
| budget_max | nombre | oui |
| pre_qualification | boolean | oui (acheteur) |
| montant_pre_qualif | nombre | si pre-qualifie |
| type_propriete | texte | oui |
| nb_chambres_min | nombre | non (acheteur) |
| delai_souhaite | texte | oui |
| disponibilites | texte | oui |
| premier_achat | boolean | oui (acheteur) |
| notes_conversation | texte long | auto-genere |
| score_chaleur | enum (chaud/tiede/froid) | auto-calcule |
| date_premier_contact | datetime | auto |
| canal_contact | enum (sms/courriel/whatsapp) | auto |
| statut | enum | auto (nouveau) |

### Cas d'usage 1.3 — Notification au courtier

**Declencheur:** Fiche client completee.

**Format de notification (SMS + courriel):**

```
NOUVEAU PROSPECT [CHAUD]

Nom: Pierre Tremblay
Type: Acheteur
Secteur: Verdun
Budget: 400-450K
Pre-qualifie: Oui (Desjardins, 450K)
Type: Duplex, 3+ chambres
Delai: 1-3 mois
Disponible: Soirs + weekends
Premier achat: Non

Prochaine action recommandee:
→ Planifier premiere rencontre cette semaine

Conversation complete: [lien]
```

---

## Sprint 2 — "Elle relance et organise" (Semaine 3-4)

### Cas d'usage 2.1 — Relances automatiques

**Matrice de relance:**

| Evenement | Delai | Action | Canal |
|-----------|-------|--------|-------|
| Client n'a pas envoye documents pre-qualif | J+2 | Relance amicale | SMS |
| Client n'a pas envoye documents pre-qualif | J+5 | Relance + proposition d'aide | SMS |
| Client n'a pas envoye documents pre-qualif | J+10 | Alerte courtier: "Client froid?" | SMS courtier |
| Courtier hypothecaire pas de nouvelles | J+3 | Relance | Courriel |
| Courtier hypothecaire pas de nouvelles | J+7 | Alerte courtier | SMS courtier |
| Rendez-vous confirme | J-1 | Rappel au client | SMS |
| Rendez-vous confirme | H-2 | Rappel au client | SMS |
| Post-visite sans nouvelles | J+1 | "Comment s'est passe la visite?" | SMS |

**Exemples de messages de relance:**

```
[J+2 - Documents]
"Bonjour [Prenom]! C'est l'assistante de [Courtier].
On attend toujours vos documents pour la pre-qualification.
Besoin d'aide avec ca? N'hesitez pas!"

[J+5 - Documents]
"Bonjour [Prenom]! Juste un petit rappel amical pour
les documents de pre-qualification. Si vous avez des
questions, [Courtier] est disponible pour vous guider."

[J-1 - Rappel rendez-vous]
"Bonjour [Prenom]! Petit rappel: votre rencontre avec
[Courtier] est demain a [heure] a [lieu]. A demain!"
```

### Cas d'usage 2.2 — Planification de visites

**Flux:**

```
Client qualifie + proprietes identifiees
     |
     v
Courtier indique ses plages disponibles (calendrier)
     |
     v
Agent IA propose des creneaux au client:
     "J'ai 3 creneaux cette semaine pour visiter:
      - Mardi 18h
      - Jeudi 17h30
      - Samedi 10h
      Lequel vous convient?"
     |
     v
Client choisit → Agent confirme aux deux parties
     |
     v
Rappels automatiques J-1 et H-2
```

### Cas d'usage 2.3 — Resume quotidien

**Declencheur:** Tous les matins a 7h30.

**Format:**

```
BONJOUR [COURTIER]! Voici votre journee:

AUJOURD'HUI:
- 10h: Visite avec Pierre T. (Verdun, duplex 450K)
- 14h: Rencontre Marie L. (evaluation maison Plateau)

EN ATTENTE:
- Jean D.: documents pre-qualif (J+4, relance envoyee hier)
- Sophie R.: reponse courtier hypothecaire (J+2)

ALERTES:
⚠️ Marc B.: pas de nouvelles depuis 8 jours → relancer?
✅ Pierre T.: pre-qualification confirmee hier

NOUVEAUX PROSPECTS (hier):
- Amelie V.: acheteuse, Rosemont, 350K, premier achat [TIEDE]

STATS SEMAINE:
- 4 prospects actifs
- 2 visites planifiees
- 1 offre en cours
```

---

## Architecture Technique

### Pile technologique

```
┌─────────────────────────────────────────────────────┐
│                                                     │
│  CANAUX D'ENTREE                                    │
│  ├── Twilio (SMS entrants/sortants)                 │
│  ├── SendGrid/Mailgun (courriel)                    │
│  └── (WhatsApp via Twilio — optionnel sprint 2)     │
│                                                     │
│  ORCHESTRATION                                      │
│  └── n8n (auto-heberge)                             │
│      ├── Flux: nouveau message → traitement IA      │
│      ├── Flux: relances programmees (cron)           │
│      ├── Flux: resume quotidien (cron 7h30)         │
│      └── Flux: notification courtier                │
│                                                     │
│  INTELLIGENCE                                       │
│  └── Claude API (claude-sonnet-4-6)                 │
│      ├── Prompt systeme: personnalite adjointe      │
│      ├── Contexte: fiche client + historique         │
│      └── Outils: creer_fiche, relancer, planifier   │
│                                                     │
│  STOCKAGE                                           │
│  └── Supabase (PostgreSQL)                          │
│      ├── Table: clients                             │
│      ├── Table: conversations                       │
│      ├── Table: relances                            │
│      ├── Table: rendez_vous                         │
│      └── Table: config_courtier                     │
│                                                     │
│  CALENDRIER                                         │
│  └── Google Calendar API                            │
│      ├── Lire disponibilites courtier               │
│      └── Creer evenements + invitations             │
│                                                     │
│  INTERFACE COURTIER (sprint 2)                      │
│  └── App web simple (Next.js) ou Notion             │
│      └── Tableau de bord dossiers en cours          │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### Schema de base de donnees (sprint 1)

```sql
-- Table principale des clients/prospects
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom_complet TEXT NOT NULL,
    telephone TEXT,
    courriel TEXT,
    type_client TEXT CHECK (type_client IN ('acheteur', 'vendeur')),
    secteur_recherche TEXT,
    budget_min NUMERIC,
    budget_max NUMERIC,
    pre_qualification BOOLEAN DEFAULT FALSE,
    montant_pre_qualif NUMERIC,
    type_propriete TEXT,
    nb_chambres_min INTEGER,
    delai_souhaite TEXT,
    disponibilites TEXT,
    premier_achat BOOLEAN,
    score_chaleur TEXT CHECK (score_chaleur IN ('chaud', 'tiede', 'froid')),
    statut TEXT DEFAULT 'nouveau' CHECK (statut IN (
        'nouveau', 'en_qualification', 'qualifie',
        'en_visite', 'offre_soumise', 'en_inspection',
        'en_financement', 'cloture', 'perdu', 'inactif'
    )),
    canal_contact TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Historique des conversations
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id),
    canal TEXT NOT NULL,
    direction TEXT CHECK (direction IN ('entrant', 'sortant')),
    message TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Relances programmees
CREATE TABLE relances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id),
    type_relance TEXT NOT NULL,
    date_prevue TIMESTAMPTZ NOT NULL,
    date_executee TIMESTAMPTZ,
    statut TEXT DEFAULT 'planifiee' CHECK (statut IN (
        'planifiee', 'executee', 'annulee'
    )),
    message_envoye TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Rendez-vous
CREATE TABLE rendez_vous (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id),
    type_rdv TEXT CHECK (type_rdv IN (
        'premiere_rencontre', 'visite', 'signature', 'autre'
    )),
    date_heure TIMESTAMPTZ NOT NULL,
    duree_minutes INTEGER DEFAULT 30,
    lieu TEXT,
    statut TEXT DEFAULT 'planifie' CHECK (statut IN (
        'planifie', 'confirme', 'complete', 'annule'
    )),
    google_calendar_id TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Configuration du courtier
CREATE TABLE config_courtier (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom TEXT NOT NULL,
    telephone TEXT,
    courriel TEXT,
    message_accueil TEXT,
    horaires_disponibles JSONB,
    preferences JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Prompt systeme de l'adjointe IA

```
Tu es l'assistante administrative de [NOM DU COURTIER],
courtier immobilier au Quebec.

PERSONNALITE:
- Chaleureuse, professionnelle, efficace
- Tu parles en francais quebecois naturel (pas de francais de France)
- Tu utilises le "vous" avec les nouveaux clients
- Tu es proactive: tu poses des questions, tu ne restes pas passive

REGLES ABSOLUES:
- Tu ne dis JAMAIS que tu es une intelligence artificielle
  sauf si on te le demande directement
- Tu ne donnes JAMAIS de conseils juridiques ou financiers
- Tu ne fais JAMAIS de promesse sur les prix ou le marche
- Si un client pose une question technique/complexe:
  "Excellente question! Je vais transmettre ca a [Courtier]
  qui pourra mieux vous repondre."
- Tu ne partages JAMAIS les informations d'un client
  avec un autre client

TON OBJECTIF:
1. Repondre rapidement et chaleureusement
2. Collecter les informations cles du prospect
3. Qualifier le client (chaud/tiede/froid)
4. Preparer le terrain pour le courtier

CONTEXTE DU CLIENT EN COURS:
{fiche_client}

HISTORIQUE DE CONVERSATION:
{historique}
```

---

## Conformite Loi 25

- Toutes les donnees clients stockees au Canada (Supabase region ca-central-1)
- Consentement implicite: le client initie le contact
- Pas de partage de donnees avec des tiers sans consentement
- Option de suppression des donnees sur demande
- Pas de profilage automatise pour des decisions consequentes
- Les conversations sont stockees pour le suivi, pas pour l'entrainement IA

---

## Criteres de Succes MVP

| Metrique | Avant | Cible MVP |
|----------|-------|-----------|
| Temps de premiere reponse | 1-4 heures | < 1 minute |
| Taux de documents recus < 5 jours | ~50% (estime) | 80% |
| Relances oubliees par semaine | 3-5 (estime) | 0 |
| Prospects perdus par inactivite | ~30% | < 10% |
| Temps admin courtier par jour | 3-4 heures | 30 min |

---

## Ce qui N'EST PAS dans le MVP

- Integration Matrix/Centris
- Generation d'offres d'achat
- Comparables de marche
- Appels vocaux IA
- Multi-courtier / plateforme SaaS
- Application mobile native
- Integration avec courtier hypothecaire (systeme)
- Prospection automatisee (thermopompes ou autre)

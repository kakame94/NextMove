# Schema Supabase — NextMove MVP

**6 tables | ca-central-1 | RLS enabled | Multi-tenant**

## Diagramme Entite-Relation

```mermaid
erDiagram
    courtiers ||--o{ prospects : "1:N gere"
    prospects ||--o| besoins_acheteur : "1:1 si acheteur"
    prospects ||--o| besoins_vendeur : "1:1 si vendeur"
    prospects ||--o{ conversations : "1:N messages"
    prospects ||--o{ relances : "1:N suivis"

    courtiers {
        uuid id PK
        text nom
        text prenom
        text telephone
        text email
        text secteur
        jsonb preferences_notification
        timestamptz created_at
    }

    prospects {
        uuid id PK
        uuid courtier_id FK
        text canal_source
        text type_projet "acheteur | vendeur"
        text statut "nouveau | en_qualification | qualifie | en_recherche | offre_deposee | conclu | perdu"
        int score_chaleur "0-10"
        text nom
        text prenom
        text telephone
        text email
        text langue_preferee "fr | en"
        timestamptz created_at
        timestamptz updated_at
    }

    besoins_acheteur {
        uuid id PK
        uuid prospect_id FK "UNIQUE"
        text type_bien
        int nb_logements_min
        int nb_logements_max
        text[] localisation_souhaitee
        text[] quartiers_exclus
        int budget_min
        int budget_max
        text financement_statut "non_demarre | en_cours | pre_approuve | refuse"
        int montant_pre_approbation
        int apport_personnel
        text courtier_hypothecaire
        text profil_acheteur "proprietaire_occupant | investisseur | mixte"
        boolean premier_acheteur
        int nb_acheteurs
        text delai_projet "immediat | 3_mois | 6_mois | 1_an | exploration"
        text disponibilites_visite
        int nb_chambres_min
        int nb_sdb_min
        boolean stationnement_requis
        boolean animaux
        text type_chauffage_pref
        int revenu_locatif_min
        boolean condition_vente_autre
        text[] preoccupations
        text notes_agent
        timestamptz updated_at
    }

    besoins_vendeur {
        uuid id PK
        uuid prospect_id FK "UNIQUE"
        text adresse_bien
        text type_bien
        int nb_logements
        int annee_construction
        int superficie_terrain
        int superficie_habitable
        int prix_souhaite
        int evaluation_municipale
        text raison_vente
        text delai_vente "urgent | 3_mois | 6_mois | flexible"
        text occupation "proprietaire_occupant | locataire_en_place | vacant"
        int nb_baux_actifs
        int revenus_locatifs_annuels
        int hypotheque_restante
        text travaux_recents
        text travaux_requis
        boolean exclusivite_courtier
        boolean mandat_existant
        text garantie_legale "avec | sans | non_determine"
        text notes_agent
        timestamptz updated_at
    }

    conversations {
        uuid id PK
        uuid prospect_id FK
        text role "prospect | agent"
        text contenu
        text canal "sms | web"
        jsonb metadata
        timestamptz created_at
    }

    relances {
        uuid id PK
        uuid prospect_id FK
        text type_relance "rappel_documents | proposition_aide | alerte_courtier_froid | rappel_rdv | post_visite"
        timestamptz date_prevue
        timestamptz date_executee
        text statut "planifiee | envoyee | annulee"
        text contenu
        timestamptz created_at
    }
```

## Flux de donnees

```mermaid
flowchart LR
    SMS["SMS entrant<br/>(Twilio)"] --> n8n["n8n<br/>(orchestration)"]
    n8n --> LOOKUP["Lookup prospect<br/>par telephone"]
    LOOKUP -->|existe| HISTORY["Charger historique<br/>conversations"]
    LOOKUP -->|nouveau| CREATE["Creer prospect<br/>+ lier au courtier"]
    HISTORY --> CLAUDE["Claude API<br/>(Sonnet 4.6)"]
    CREATE --> CLAUDE
    CLAUDE --> PARSE["Parser reponse<br/>+ extraire JSON"]
    PARSE --> SAVE_MSG["Sauvegarder<br/>conversation"]
    PARSE --> SEND_SMS["Envoyer SMS<br/>reponse (Twilio)"]
    PARSE -->|action: creer_fiche| UPDATE["Mettre a jour<br/>prospect + besoins"]
    UPDATE --> NOTIFY_SMS["Notification SMS<br/>au courtier"]
    UPDATE --> NOTIFY_EMAIL["Notification email<br/>(SendGrid)"]
    UPDATE --> PLAN_RELANCE["Planifier<br/>relances"]
```

## Score chaleur

```mermaid
flowchart TD
    SCORE["Score 0-10"] --> HOT_URG["9-10 : CHAUD-URGENT<br/>Divorce, deces, demenagement<br/>Delai < 1 mois"]
    SCORE --> HOT["7-8 : CHAUD<br/>Pre-approuve + budget defini<br/>Delai < 3 mois"]
    SCORE --> WARM["4-6 : TIEDE<br/>Interesse sans urgence<br/>Financement en cours"]
    SCORE --> COLD["0-3 : FROID<br/>Exploration, > 6 mois<br/>Pas de budget"]

    style HOT_URG fill:#E94560,color:#fff
    style HOT fill:#00D9A6,color:#000
    style WARM fill:#F59E0B,color:#000
    style COLD fill:#8892B0,color:#fff
```

## Grille de scoring (Dennis)

| Critere | Points |
|---------|--------|
| Financement pre-approuve | +3 |
| Delai < 3 mois | +2 |
| Budget defini | +2 |
| Secteur precise | +1 |
| Premier acheteur | +1 |
| Mise de fonds disponible | +1 |

**7-10 = Chaud | 4-6 = Tiede | 0-3 = Froid**

## RLS (Row Level Security)

```mermaid
flowchart LR
    N8N["n8n<br/>(service_role)"] -->|FULL ACCESS<br/>toutes tables| DB[(Supabase)]
    COURTIER["Courtier<br/>(authenticated)"] -->|SELECT own data<br/>courtier_id = auth.uid| DB
    PUBLIC["Public<br/>(anon)"] -->|AUCUN ACCES| DB

    style N8N fill:#5E6AD2,color:#fff
    style COURTIER fill:#00D9A6,color:#000
    style PUBLIC fill:#E94560,color:#fff
```

**Regles :**
- `service_role` (n8n) : acces complet a tout (lecture + ecriture)
- `authenticated` (courtier connecte) : voit seulement SES prospects, SES conversations, SES relances
- `anon` : aucun acces

## Comparaison avec le PRD

| Aspect PRD | Schema Dennis | Alignement |
|-----------|--------------|------------|
| FR-4.1 Fiche client 17 champs | besoins_acheteur 28 cols + besoins_vendeur 23 cols | Depasse les exigences |
| FR-4.2 Score 4 niveaux texte | Integer 0-10 avec grille de scoring | Different mais plus flexible |
| FR-4.3 Reconnaissance numero | Lookup par telephone dans prospects | Aligne |
| NFR-3.1 Donnees au Canada | Supabase ca-central-1 | Aligne |
| NFR-5.3 Multi-tenant | courtier_id FK + RLS | Aligne (V1 ready) |
| FR-8.5 Courtier corrige fiche | UPDATE via authenticated + RLS | Aligne |

## Tables absentes (Sprint 2)

| Table | Prevue pour | Usage |
|-------|------------|-------|
| `rendez_vous` | Sprint 2 | Planification visites + Google Calendar |
| `blacklist` | Sprint 1 (a ajouter) | Numeros STOP / bloques (obligation legale) |

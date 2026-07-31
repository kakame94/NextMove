# Modèle de données — Klaris documentaire

Migration prête à exécuter : [sql/000_klaris_documentaire_schema.sql](sql/000_klaris_documentaire_schema.sql) (schéma dédié `klaris_doc`, isolé du reste de NextMove).

## Schéma

```mermaid
erDiagram
    agences ||--o{ courtiers : emploie
    courtiers ||--o{ dossiers : gere
    dossiers ||--o{ documents : contient
    dossiers ||--o{ jalons : suit
    dossiers ||--o{ actions_pendantes : declenche
    dossiers ||--o{ acces_portail : expose
    courtiers ||--o| lonewolf_connexions : connecte
    dossiers ||--o{ journal_acces : trace
    documents ||--o{ couts_inference : coute

    dossiers {
        uuid id PK
        uuid courtier_id FK
        text type "vendeur | acheteur"
        text shortid "d-{shortid}@in.klaris.ca"
        text statut
    }
    documents {
        uuid id PK
        uuid dossier_id FK
        text type_taxonomie
        text statut "recu | a_confirmer | valide | perime | rejete"
        text source "courriel | lonewolf | portail | manuel"
        text storage_path
        text hash_sha256 "unique par dossier"
        jsonb champs_extraits
        numeric confiance
    }
    jalons {
        uuid id PK
        uuid dossier_id FK
        text type "inspection | financement | notaire | cloture..."
        date date_limite
        text source "api | pdf_confirme | manuel"
    }
    actions_pendantes {
        uuid id PK
        uuid dossier_id FK
        text type "depot_docbox | envoi_client | relance"
        jsonb payload
        text statut "proposee | approuvee | refusee | executee | echouee"
        uuid approuvee_par FK
    }
    acces_portail {
        uuid id PK
        uuid dossier_id FK
        text partie "acheteur | vendeur"
        text token_hash "jamais le token en clair"
        timestamptz expire_le
        boolean revoque
    }
    journal_acces {
        bigint id PK
        text qui
        text action
        uuid dossier_id
        uuid document_id
    }
```

## Invariants (à ne jamais casser)

1. **Cloisonnement** : toute table porteuse de données de dossier a une politique RLS `dossier → courtier → auth.uid()`. Le portail client ne touche jamais Postgres directement — Edge Function service-role qui filtre par `dossier_id` du token.
2. **N3** : `actions_pendantes` est l'unique chemin de sortie. L'exécuteur ne lit que `statut = 'approuvee'`. Pas de code d'envoi ailleurs.
3. **Journal append-only** : `journal_acces` sans `update` ni `delete`, même pour le propriétaire.
4. **Tokens** : portail = hash SHA-256 stocké, jamais le token en clair. Lone Wolf = refresh token chiffré (Vault/pgsodium).
5. **Dédoublonnage** : `unique (dossier_id, hash_sha256)` — le même PDF transféré deux fois ne crée pas deux documents.
6. **Statut `a_confirmer`** : un document sous le seuil de confiance n'est jamais classé silencieusement.

## Cycle de vie d'un document

```mermaid
stateDiagram-v2
    [*] --> recu : ingestion (courriel, portail, Lone Wolf)
    recu --> valide : classification confiance ≥ seuil
    recu --> a_confirmer : confiance < seuil
    a_confirmer --> valide : courtier confirme / corrige
    a_confirmer --> rejete : courtier rejette
    valide --> perime : règle de péremption (taxonomie)
    perime --> valide : nouvelle version reçue
```

## Cycle de vie d'une action N3

```mermaid
stateDiagram-v2
    [*] --> proposee : moteur (échéances, complétude) ou courtier
    proposee --> approuvee : courtier approuve (UI)
    proposee --> refusee : courtier refuse
    approuvee --> executee : exécuteur (Edge Function)
    approuvee --> echouee : erreur d exécution
    echouee --> proposee : re-proposition avec l erreur visible
```

## Tests bloquants (CI)

| # | Test | Attendu |
|---|---|---|
| 1 | Token portail client A + `dossier_id` du client B, chaque endpoint | 403 + ligne `journal_acces` action `refus` |
| 2 | JWT courtier A, `select` sur dossiers/documents/jalons du courtier B | 0 ligne |
| 3 | Token portail expiré ou `revoque = true` | 401 |
| 4 | `update`/`delete` sur `journal_acces`, tout rôle non-superuser | erreur |
| 5 | Même PDF transféré 2× sur un dossier | 1 seul document |
| 6 | Action `proposee` (non approuvée) → exécuteur | rien ne part |

Échec de 1-4 = déploiement bloqué. C'est le test du cadrage §4.3 : *le client A ne voit jamais un document du client B*.

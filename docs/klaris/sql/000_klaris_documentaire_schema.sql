-- Klaris documentaire — migration initiale
-- Cible : Supabase Postgres, région ca-central-1 (Loi 25)
-- Convention : schéma dédié pour isoler le module du reste de NextMove.

create schema if not exists klaris_doc;

-- ---------------------------------------------------------------------------
-- Référentiel
-- ---------------------------------------------------------------------------

create table klaris_doc.agences (
    id          uuid primary key default gen_random_uuid(),
    nom         text not null,
    cree_le     timestamptz not null default now()
);

create table klaris_doc.courtiers (
    id            uuid primary key default gen_random_uuid(),
    agence_id     uuid references klaris_doc.agences(id),
    auth_user_id  uuid not null unique,          -- auth.users.id (Supabase Auth)
    nom           text not null,
    courriel      text not null unique,
    cree_le       timestamptz not null default now()
);

create table klaris_doc.dossiers (
    id            uuid primary key default gen_random_uuid(),
    courtier_id   uuid not null references klaris_doc.courtiers(id),
    type          text not null check (type in ('vendeur', 'acheteur')),
    adresse       text not null,
    -- identifiant court pour l'adresse courriel d-{shortid}@in.klaris.ca
    shortid       text not null unique default encode(gen_random_bytes(6), 'hex'),
    statut        text not null default 'actif'
                  check (statut in ('actif', 'conclu', 'annule', 'archive')),
    cree_le       timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Documents
-- ---------------------------------------------------------------------------

create table klaris_doc.documents (
    id              uuid primary key default gen_random_uuid(),
    dossier_id      uuid not null references klaris_doc.dossiers(id),
    type_taxonomie  text,                        -- null tant que non classé
    version         int  not null default 1,
    statut          text not null default 'recu'
                    check (statut in ('recu', 'a_confirmer', 'valide', 'perime', 'rejete')),
    source          text not null
                    check (source in ('courriel', 'lonewolf', 'portail', 'manuel')),
    storage_path    text not null,               -- documents/{dossier_id}/{uuid}.pdf
    hash_sha256     text not null,
    date_document   date,                        -- date portée par le document lui-même
    champs_extraits jsonb,
    confiance       numeric(4,3),                -- score du classificateur, 0.000-1.000
    recu_le         timestamptz not null default now(),
    unique (dossier_id, hash_sha256)             -- dédoublonnage par dossier
);

create index documents_dossier_idx on klaris_doc.documents (dossier_id, statut);

-- ---------------------------------------------------------------------------
-- Jalons et échéances
-- ---------------------------------------------------------------------------

create table klaris_doc.jalons (
    id           uuid primary key default gen_random_uuid(),
    dossier_id   uuid not null references klaris_doc.dossiers(id),
    type         text not null check (type in
                 ('acceptation_promesse', 'inspection', 'financement_demande',
                  'financement_approbation', 'notaire', 'cloture', 'possession', 'autre')),
    date_limite  date not null,
    source       text not null default 'manuel'
                 check (source in ('api', 'pdf_confirme', 'manuel')),
    statut       text not null default 'a_venir'
                 check (statut in ('a_venir', 'complete', 'manque', 'annule')),
    cree_le      timestamptz not null default now(),
    unique (dossier_id, type)
);

-- ---------------------------------------------------------------------------
-- Boucle N3 : toute action sortante passe ici (DA-02)
-- ---------------------------------------------------------------------------

create table klaris_doc.actions_pendantes (
    id             uuid primary key default gen_random_uuid(),
    dossier_id     uuid not null references klaris_doc.dossiers(id),
    type           text not null
                   check (type in ('depot_docbox', 'envoi_client', 'relance')),
    payload        jsonb not null,               -- contenu proposé (destinataire, message, document...)
    statut         text not null default 'proposee'
                   check (statut in ('proposee', 'approuvee', 'refusee', 'executee', 'echouee')),
    approuvee_par  uuid references klaris_doc.courtiers(id),
    approuvee_le   timestamptz,
    executee_le    timestamptz,
    erreur         text,
    cree_le        timestamptz not null default now()
);

create index actions_statut_idx on klaris_doc.actions_pendantes (statut, cree_le);

-- ---------------------------------------------------------------------------
-- Portail client (lien signé, sans compte)
-- ---------------------------------------------------------------------------

create table klaris_doc.acces_portail (
    id          uuid primary key default gen_random_uuid(),
    dossier_id  uuid not null references klaris_doc.dossiers(id),
    partie      text not null check (partie in ('acheteur', 'vendeur')),
    token_hash  text not null unique,            -- sha256 du token 256 bits ; jamais le token en clair
    expire_le   timestamptz not null,
    revoque     boolean not null default false,
    cree_le     timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Journal d'accès (Loi 25) — append-only
-- ---------------------------------------------------------------------------

create table klaris_doc.journal_acces (
    id           bigint generated always as identity primary key,
    quand        timestamptz not null default now(),
    qui          text not null,                  -- 'courtier:{id}' | 'portail:{acces_id}' | 'systeme'
    action       text not null,                  -- 'lecture' | 'ecriture' | 'refus' | ...
    dossier_id   uuid,
    document_id  uuid,
    ip           inet,
    detail       jsonb
);

-- Append-only : aucune modification ni suppression, même pour le propriétaire.
revoke update, delete on klaris_doc.journal_acces from public;

-- ---------------------------------------------------------------------------
-- Suivi des coûts d'inférence (métrique n°4 du pilote)
-- ---------------------------------------------------------------------------

create table klaris_doc.couts_inference (
    id           bigint generated always as identity primary key,
    quand        timestamptz not null default now(),
    dossier_id   uuid,
    document_id  uuid,
    modele       text not null,
    tokens_in    int  not null,
    tokens_out   int  not null,
    cout_cad     numeric(10,6) not null
);

-- ---------------------------------------------------------------------------
-- Jetons Lone Wolf (chiffrés applicativement ou via Vault — jamais en clair)
-- ---------------------------------------------------------------------------

create table klaris_doc.lonewolf_connexions (
    courtier_id            uuid primary key references klaris_doc.courtiers(id),
    refresh_token_chiffre  text not null,
    scope                  text,
    connecte_le            timestamptz not null default now(),
    dernier_poll           timestamptz
);

-- ---------------------------------------------------------------------------
-- RLS : cloisonnement par courtier (le portail client passe par une Edge
-- Function service-role qui filtre par dossier — jamais d'accès direct)
-- ---------------------------------------------------------------------------

alter table klaris_doc.agences             enable row level security;
alter table klaris_doc.courtiers           enable row level security;
alter table klaris_doc.dossiers            enable row level security;
alter table klaris_doc.documents           enable row level security;
alter table klaris_doc.jalons              enable row level security;
alter table klaris_doc.actions_pendantes   enable row level security;
alter table klaris_doc.acces_portail       enable row level security;
alter table klaris_doc.journal_acces       enable row level security;
alter table klaris_doc.couts_inference     enable row level security;
alter table klaris_doc.lonewolf_connexions enable row level security;

create or replace function klaris_doc.courtier_courant()
returns uuid
language sql stable security definer set search_path = klaris_doc, pg_temp
as $$
    select id from klaris_doc.courtiers where auth_user_id = auth.uid()
$$;

create policy courtier_lit_son_profil on klaris_doc.courtiers
    for select using (auth_user_id = auth.uid());

create policy courtier_ses_dossiers on klaris_doc.dossiers
    for all using (courtier_id = klaris_doc.courtier_courant());

create policy courtier_ses_documents on klaris_doc.documents
    for all using (dossier_id in
        (select id from klaris_doc.dossiers
          where courtier_id = klaris_doc.courtier_courant()));

create policy courtier_ses_jalons on klaris_doc.jalons
    for all using (dossier_id in
        (select id from klaris_doc.dossiers
          where courtier_id = klaris_doc.courtier_courant()));

create policy courtier_ses_actions on klaris_doc.actions_pendantes
    for all using (dossier_id in
        (select id from klaris_doc.dossiers
          where courtier_id = klaris_doc.courtier_courant()));

create policy courtier_ses_acces_portail on klaris_doc.acces_portail
    for all using (dossier_id in
        (select id from klaris_doc.dossiers
          where courtier_id = klaris_doc.courtier_courant()));

create policy courtier_lit_son_journal on klaris_doc.journal_acces
    for select using (dossier_id in
        (select id from klaris_doc.dossiers
          where courtier_id = klaris_doc.courtier_courant()));

create policy courtier_lit_ses_couts on klaris_doc.couts_inference
    for select using (dossier_id in
        (select id from klaris_doc.dossiers
          where courtier_id = klaris_doc.courtier_courant()));

create policy courtier_sa_connexion_lw on klaris_doc.lonewolf_connexions
    for all using (courtier_id = klaris_doc.courtier_courant());

-- agences : lecture par ses membres seulement
create policy membre_lit_son_agence on klaris_doc.agences
    for select using (id in
        (select agence_id from klaris_doc.courtiers
          where auth_user_id = auth.uid()));

-- Ingestion, classification, polling et exécution N3 tournent en service-role
-- (Edge Functions) et contournent la RLS ; chaque écriture journalise dans
-- journal_acces avec qui = 'systeme'.

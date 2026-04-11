-- MVP Adjointe IA — Schema Supabase
-- Sprint 1: Reponse + Collecte + Notification

-- Configuration du courtier
CREATE TABLE IF NOT EXISTS config_courtier (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nom TEXT NOT NULL,
    telephone TEXT NOT NULL,
    courriel TEXT,
    message_accueil TEXT DEFAULT 'Bonjour! Merci de nous contacter. Je suis l''assistante de votre courtier. Pour mieux vous servir, j''aurais quelques questions rapides.',
    horaires_disponibles JSONB DEFAULT '{"lundi":"9h-20h","mardi":"9h-20h","mercredi":"9h-20h","jeudi":"9h-20h","vendredi":"9h-20h","samedi":"10h-17h","dimanche":"ferme"}'::jsonb,
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Clients / Prospects
CREATE TABLE IF NOT EXISTS clients (
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
    score_chaleur TEXT DEFAULT 'tiede' CHECK (score_chaleur IN ('chaud', 'tiede', 'froid')),
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
CREATE TABLE IF NOT EXISTS conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    canal TEXT NOT NULL,
    direction TEXT CHECK (direction IN ('entrant', 'sortant')),
    message TEXT NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Relances programmees
CREATE TABLE IF NOT EXISTS relances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
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
CREATE TABLE IF NOT EXISTS rendez_vous (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
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

-- Index pour les requetes frequentes
CREATE INDEX IF NOT EXISTS idx_clients_statut ON clients(statut);
CREATE INDEX IF NOT EXISTS idx_clients_score ON clients(score_chaleur);
CREATE INDEX IF NOT EXISTS idx_conversations_client ON conversations(client_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_relances_date ON relances(date_prevue) WHERE statut = 'planifiee';
CREATE INDEX IF NOT EXISTS idx_rdv_date ON rendez_vous(date_heure) WHERE statut IN ('planifie', 'confirme');

-- Trigger pour updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

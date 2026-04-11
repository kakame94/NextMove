-- ============================================================
-- NEXT MOVE MVP — Schema Supabase
-- 6 tables • ca-central-1 • RLS enabled
-- ============================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. courtiers
CREATE TABLE public.courtiers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nom text NOT NULL,
  prenom text NOT NULL,
  telephone text NOT NULL,
  email text NOT NULL,
  secteur text,
  preferences_notification jsonb DEFAULT '{"sms": true, "email": true, "briefing_heure": "07:30"}'::jsonb,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE public.courtiers ENABLE ROW LEVEL SECURITY;

-- 2. prospects
CREATE TABLE public.prospects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  courtier_id uuid NOT NULL REFERENCES public.courtiers(id) ON DELETE CASCADE,
  canal_source text NOT NULL DEFAULT 'sms',
  type_projet text NOT NULL CHECK (type_projet IN ('acheteur', 'vendeur')),
  statut text NOT NULL DEFAULT 'nouveau' CHECK (statut IN (
    'nouveau', 'en_qualification', 'qualifie', 'en_recherche',
    'offre_deposee', 'conclu', 'perdu'
  )),
  score_chaleur int DEFAULT 0 CHECK (score_chaleur >= 0 AND score_chaleur <= 10),
  nom text,
  prenom text,
  telephone text,
  email text,
  langue_preferee text DEFAULT 'fr' CHECK (langue_preferee IN ('fr', 'en')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE public.prospects ENABLE ROW LEVEL SECURITY;
CREATE INDEX idx_prospects_courtier_id ON public.prospects(courtier_id);
CREATE INDEX idx_prospects_statut ON public.prospects(statut);
CREATE INDEX idx_prospects_score_chaleur ON public.prospects(score_chaleur DESC);

-- 3. besoins_acheteur
CREATE TABLE public.besoins_acheteur (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id uuid NOT NULL UNIQUE REFERENCES public.prospects(id) ON DELETE CASCADE,
  type_bien text,
  nb_logements_min int,
  nb_logements_max int,
  localisation_souhaitee text[],
  quartiers_exclus text[],
  budget_min int,
  budget_max int,
  financement_statut text DEFAULT 'non_demarre' CHECK (financement_statut IN (
    'non_demarre', 'en_cours', 'pre_approuve', 'refuse'
  )),
  montant_pre_approbation int,
  apport_personnel int,
  courtier_hypothecaire text,
  profil_acheteur text CHECK (profil_acheteur IN (
    'proprietaire_occupant', 'investisseur', 'mixte'
  )),
  premier_acheteur boolean,
  nb_acheteurs int DEFAULT 1,
  delai_projet text CHECK (delai_projet IN (
    'immediat', '3_mois', '6_mois', '1_an', 'exploration'
  )),
  disponibilites_visite text,
  nb_chambres_min int,
  nb_sdb_min int,
  stationnement_requis boolean,
  animaux boolean,
  type_chauffage_pref text,
  revenu_locatif_min int,
  condition_vente_autre boolean DEFAULT false,
  preoccupations text[],
  notes_agent text,
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE public.besoins_acheteur ENABLE ROW LEVEL SECURITY;

-- 4. besoins_vendeur
CREATE TABLE public.besoins_vendeur (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id uuid NOT NULL UNIQUE REFERENCES public.prospects(id) ON DELETE CASCADE,
  adresse_bien text,
  type_bien text,
  nb_logements int,
  annee_construction int,
  superficie_terrain int,
  superficie_habitable int,
  prix_souhaite int,
  evaluation_municipale int,
  raison_vente text,
  delai_vente text CHECK (delai_vente IN ('urgent', '3_mois', '6_mois', 'flexible')),
  occupation text CHECK (occupation IN ('proprietaire_occupant', 'locataire_en_place', 'vacant')),
  nb_baux_actifs int,
  revenus_locatifs_annuels int,
  hypotheque_restante int,
  travaux_recents text,
  travaux_requis text,
  exclusivite_courtier boolean DEFAULT false,
  mandat_existant boolean DEFAULT false,
  garantie_legale text DEFAULT 'non_determine' CHECK (garantie_legale IN ('avec', 'sans', 'non_determine')),
  notes_agent text,
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE public.besoins_vendeur ENABLE ROW LEVEL SECURITY;

-- 5. conversations
CREATE TABLE public.conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id uuid NOT NULL REFERENCES public.prospects(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('prospect', 'agent')),
  contenu text NOT NULL,
  canal text NOT NULL DEFAULT 'sms' CHECK (canal IN ('sms', 'web')),
  metadata jsonb,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
CREATE INDEX idx_conversations_prospect_id ON public.conversations(prospect_id);
CREATE INDEX idx_conversations_created_at ON public.conversations(created_at DESC);

-- 6. relances
CREATE TABLE public.relances (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prospect_id uuid NOT NULL REFERENCES public.prospects(id) ON DELETE CASCADE,
  type_relance text NOT NULL CHECK (type_relance IN (
    'rappel_documents', 'proposition_aide', 'alerte_courtier_froid',
    'rappel_rdv', 'post_visite'
  )),
  date_prevue timestamptz NOT NULL,
  date_executee timestamptz,
  statut text NOT NULL DEFAULT 'planifiee' CHECK (statut IN ('planifiee', 'envoyee', 'annulee')),
  contenu text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE public.relances ENABLE ROW LEVEL SECURITY;
CREATE INDEX idx_relances_prospect_id ON public.relances(prospect_id);
CREATE INDEX idx_relances_date_prevue ON public.relances(date_prevue) WHERE statut = 'planifiee';

-- Trigger: auto-update updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER set_updated_at_prospects
  BEFORE UPDATE ON public.prospects
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_besoins_acheteur
  BEFORE UPDATE ON public.besoins_acheteur
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_besoins_vendeur
  BEFORE UPDATE ON public.besoins_vendeur
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

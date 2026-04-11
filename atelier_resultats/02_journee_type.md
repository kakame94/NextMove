# Journee Type du Courtier

## Resultat de l'atelier JTBD — Mars 2026

```
MATIN TOT            AVANT-MIDI           MIDI              APRES-MIDI          SOIR / WEEKEND
7h - 9h              9h - 12h             12h - 13h         13h - 18h           18h - 23h
─────────────────────────────────────────────────────────────────────────────────────────────────

┌─────────────┐  ┌──────────────────┐  ┌────────────┐  ┌──────────────────┐  ┌────────────────┐
│             │  │                  │  │            │  │                  │  │                │
│ Verifier    │  │ Appels clients   │  │ (variable) │  │ VISITES          │  │ Appels clients │
│ messages    │  │ Suivi dossiers   │  │            │  │ (moment le plus  │  │ anxieux        │
│ sur Centris │  │ Relancer banque  │  │            │  │  productif)      │  │                │
│             │  │ Preparer dossiers│  │            │  │                  │  │ Signatures     │
│ Contact     │  │                  │  │            │  │ Negociations     │  │ electroniques  │
│ (messages)  │  │ Admin:           │  │            │  │ au telephone     │  │                │
│             │  │ - Documents      │  │            │  │                  │  │ "10h-11h du    │
│ Prospect    │  │ - Formulaires    │  │            │  │ Rencontres       │  │  soir, le tel  │
│ (leads)     │  │ - Suivis         │  │            │  │ clients          │  │  sonne — les   │
│             │  │                  │  │            │  │                  │  │  gens sont     │
│ Matrix      │  │ Coordination     │  │            │  │ Inspections      │  │  excites"      │
│ (dossiers)  │  │ avec courtier    │  │            │  │ (si planifiees)  │  │                │
│             │  │ hypothecaire     │  │            │  │                  │  │ Familles qui   │
│             │  │                  │  │            │  │                  │  │ visitent le    │
│             │  │                  │  │            │  │                  │  │ soir/weekend   │
└──────┬──────┘  └────────┬─────────┘  └────────────┘  └────────┬─────────┘  └───────┬────────┘
       │                  │                                      │                    │
       v                  v                                      v                    v
  3 OUTILS:          INTERRUPTION               MOMENT LE PLUS           PAS DE JOURNEE
  - Contact          PRINCIPALE:                 PRODUCTIF:               TYPE:
  - Prospect         Appels de la                Les visites              "Il n'y a pas une
  - Matrix           banque en fin               terrain                  journee qui est
  (tous Centris)     de transaction                                       pareille"
```

## Outils utilises

```
┌─────────────────────────────────────────────────────────┐
│                ECOSYSTEME CENTRIS/MATRIX                 │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   MATRIX    │  │  PROSPECT   │  │   CONTACT   │    │
│  │             │  │             │  │             │    │
│  │ Contrats    │  │ CRM/Leads   │  │ Messagerie  │    │
│  │ Listings    │  │ Suivi       │  │ "WhatsApp   │    │
│  │ Signatures  │  │ prospects   │  │  des         │    │
│  │ Comparables │  │ automatique │  │  courtiers"  │    │
│  │ Formulaires │  │             │  │             │    │
│  │             │  │             │  │             │    │
│  │ OBLIGATOIRE │  │ Inclus      │  │ Inclus      │    │
│  │ (legal)     │  │             │  │             │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
│                                                         │
│  + Signature electronique (integree)                    │
│                                                         │
│  Cout: ~1500-1900$/renouvellement                       │
│  + licence OACIQ + cotisations = 7000$+/an              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              ECOSYSTEME HUMAIN (pas d'outils)           │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐     │
│  │  Courtier    │  │ Inspecteur   │  │ Notaire  │     │
│  │ hypothecaire │  │              │  │          │     │
│  │              │  │              │  │          │     │
│  │ "Old school, │  │ Pour les     │  │ Pour la  │     │
│  │  mais ca     │  │ inspections  │  │ cloture  │     │
│  │  fonctionne" │  │ pre-achat    │  │          │     │
│  └──────────────┘  └──────────────┘  └──────────┘     │
│                                                         │
│  Pas de systeme commun. Chacun dans son silo.          │
│  = Point de friction majeur (deal perdu)                │
└─────────────────────────────────────────────────────────┘
```

## Taches repetitives identifiees

| Tache | Frequence | Temps estime | Automatisable? |
|-------|-----------|-------------|----------------|
| Verifier messages/leads le matin | Quotidien | 30 min | Partiellement |
| Collecter infos client (nom, docs, situation) | Par client | 30-60 min | OUI |
| Relancer pour documents manquants | 2-3x/semaine | 15 min/relance | OUI |
| Coordonner avec courtier hypothecaire | Par transaction | 20-30 min | Partiellement |
| Planifier les visites (calendrier) | Quotidien | 15-30 min | OUI |
| Preparer offre d'achat | Par transaction | 30-60 min | OUI (v2) |
| Repondre aux clients anxieux le soir | Quotidien (mars) | 1-2h | OUI |
| Suivi post-visite | Par visite | 10 min | OUI |

## Personnes impliquees

| Personne | Role | Interaction |
|----------|------|-------------|
| Client acheteur | Prospect | Messages, appels, visites |
| Client vendeur | Prospect | Evaluation, photos, comparables |
| Courtier hypothecaire | Partenaire | Qualification, suivi financement |
| Assistante (en formation) | Support | Admin, collecte docs, relances |
| Inspecteur | Prestataire | Planification inspection |
| Notaire | Prestataire | Cloture transaction |
| Banque | Tiers | Pre-qualification, financement final |

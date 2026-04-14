# NextMove CRM — Wireframes & Roadmap

## Figma Source
[Ouvrir dans Figma](https://www.figma.com/design/JXlxEfExXxH1sVpXFnwFKH/Personas-Courtiers-Immobiliers)

## Pages Wireframe (6 écrans)

### 1. Dashboard (page 64:2)
- KPIs temps réel: prospects actifs, conversations IA, relances planifiées, temps réponse moyen
- Tableau prospects actifs avec score/statut
- Relances en cours (J+1 à J+5)
- Aperçu dernière conversation

### 2. Prospects (page 97:2)
- Barre recherche + 7 filtres (Tous, Chaud, Tiède, Nouveau, Froid, Acheteur, Vendeur)
- Tableau 8 prospects: avatar, type, secteur, budget, score, statut, dernière action
- Fiche prospect détaillée (aperçu au clic)
- Pipeline KPI cards (4 catégories)

### 3. Conversations (page 98:2)
- Panel contacts (320px) avec recherche, badges non-lus
- Zone chat (828px) avec bulles messages, horodatage
- Actions rapides: appeler, planifier RDV, menu
- Barre saisie message

### 4. Relances (page 99:2)
- 4 onglets filtres: Toutes, En retard, À faire, Planifié
- 8 relances avec avatar, type (Document/Visite/Appel/Courriel), priorité, statut
- Actions: valider, modifier, supprimer
- Barre accent pour items en retard

### 5. Rendez-vous (page 99:148)
- Vue semaine 4 colonnes (Mar–Ven)
- Cartes RDV avec type, horaire, lieu, contact
- Points couleur par catégorie (Visite/Appel/Signature/Service)
- Légende en bas

### 6. Configuration (page 99:231)
- Profil agent (nom, courriel, tél, agence, OACIQ, secteurs)
- Notifications (4 toggles)
- Intégrations (Centris, Gmail/Calendar, DocuSign, Facebook Leads)
- Paramètres IA (ton, réponse auto, délai transfert humain)

## Design System
- Background: #121319 (dark)
- Sidebar: #1A1D2E
- Cards: #1A1C2B
- Accent blue: #4D80FF
- Font: Inter (Regular/Semi Bold/Bold)
- Layout: 1440x1100, sidebar 240px

## Roadmap Produit (page 105:2)

### Phase 1 — Agent Conversationnel SMS - LIVRÉ
SMS intake via Twilio, qualification progressive, mémoire, lead scoring, relances J+2/J+5/J+10, briefing quotidien

### Phase 2 — Dashboard CRM & Wireframes - EN COURS
6 pages wireframées dans Figma, KPIs temps réel, conversations, relances, RDV, config

### Phase 3 — Frontend React & Intégrations (Mai-Juin 2026)
Next.js, Supabase Auth, Centris/MLS, Gmail/Calendar sync, notifications push

### Phase 4 — Générateur d'Offres d'Achat (Juin-Juil. 2026)
Templates OACIQ, auto-remplissage, DocuSign, commande vocale, versioning

### Phase 5 — Interface Vocale & Verbal (Juil.-Août 2026)
Speech-to-text, commandes vocales vers CRM, dictée notes, intégration mains-libres

### Phase 6 — Analyse Automatisée de Propriétés (Août-Sept. 2026)
Import Centris batch, calculatrice hypothécaire, scoring rentabilité, alertes matching

### Phase 7 — Synchronisation Multi-Systèmes (Sept.-Oct. 2026)
Connecteur Matrix/GED, saisie unique, gestion documentaire, checklists, lifecycle CRM

### Phase 8 — Multi-Canal & Lead Gen (Q4 2026)
WhatsApp, Facebook Lead Ads, widget chat web, lead gen automatisé, bilingue FR/EN

## Alignement Personas
| Persona | Besoin principal | Phases |
|---------|-----------------|--------|
| Joanel (Solo Ambitieux) | Libérer temps admin, offres auto + vocal | 1,2,3,4,5,7 |
| Maxime (Bâtisseur Structuré) | Scaler 3 a 4+ tx/mois, analyse batch + lead gen | 1,2,3,4,5,6,8 |
| Charlyse (Perfectionniste Autonome) | Saisie unique, sync tout + fiabilité | 1,2,3,6,7,8 |

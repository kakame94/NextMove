# Sprint MVP — 3 Jours (Ven-Sam-Dim)

## Adjointe IA du Courtier Immobilier

---

## Ou en est-on ? — Design Thinking

```
  [✓ COMPLETE]        [✓ COMPLETE]        [✓ COMPLETE]        [→ EN COURS]         [A VENIR]
  ┌──────────┐       ┌──────────┐        ┌──────────┐        ┌──────────────┐      ┌──────────┐
  │ EMPATHIE │ ───>  │DEFINITION│  ───>  │ IDEATION │  ───>  │  PROTOTYPE   │ ───> │   TEST   │
  │          │       │          │        │          │        │              │      │          │
  │ Interviews│      │ Personas │        │ Baguette │        │ SPRINT MVP   │      │ Demo au  │
  │ Joanel &  │      │ Douleurs │        │ magique  │        │ 3 JOURS      │      │ courtier │
  │ Maxime    │      │ Forces   │        │ Chemin   │        │ VEN-SAM-DIM  │      │ pilote   │
  │ Atelier   │      │ JTBD     │        │ ideal    │        │              │      │ Feedback │
  │ JTBD      │      │ Confort  │        │ 80/20    │        │ <<< ICI >>>  │      │ Metriques│
  └──────────┘       └──────────┘        └──────────┘        └──────────────┘      └──────────┘
```

---

## Methode : Design Sprint compresse + Lean Startup + Shape Up

| Principe | Application |
|----------|-------------|
| **Appetite fixe** (Shape Up) | 3 jours max — on scope pour ce temps, pas l'inverse |
| **Build-Measure-Learn** (Lean) | Dimanche soir = demo live → feedback reel |
| **Prototype > Perfection** (Sprint) | Fonctionnel > beau. On ship, on itere ensuite |
| **Equipe autonome de 4** | Chacun a un domaine, zero blocage inter-dependance |

---

## Equipe de 4 — Roles

```
  ┌─────────────────────────────────────────────────────────────────────────────────────────┐
  │                                                                                         │
  │   ROLE 1                   ROLE 2                  ROLE 3                  ROLE 4       │
  │   ARCHITECTE IA            BACKEND/INFRA           INTEGRATION/FLOWS       PRODUIT/UX   │
  │                                                                                         │
  │   ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐     ┌───────────┐│
  │   │                 │     │                 │     │                 │     │           ││
  │   │ Prompts Claude  │     │ Supabase (DB)   │     │ n8n workflows   │     │ Scope &   ││
  │   │ Personnalite IA │     │ Schema tables   │     │ Twilio SMS      │     │ priorisation│
  │   │ Flux conversa-  │     │ API si besoin   │     │ SendGrid email  │     │ Tests user││
  │   │ tionnel (achet/ │     │ Securite Loi 25 │     │ Connexion entre │     │ Dashboard ││
  │   │ vendeur)        │     │ Deploy & config │     │ tous les outils │     │ courtier  ││
  │   │ Score chaleur   │     │                 │     │ Crons (relances │     │ QA & edge ││
  │   │ Edge cases      │     │                 │     │ briefing)       │     │ cases     ││
  │   │                 │     │                 │     │                 │     │ Demo      ││
  │   └─────────────────┘     └─────────────────┘     └─────────────────┘     └───────────┘│
  │                                                                                         │
  │   LIVRABLE CLÉ:           LIVRABLE CLÉ:           LIVRABLE CLÉ:           LIVRABLE CLÉ:│
  │   Prompt systeme +        DB en prod +             SMS → IA → notif        MVP utilisable│
  │   flux conversationnel    schema deploye           end-to-end              + demo live   │
  │   qui close en < 9 Q      + CRUD clients           fonctionnel             au courtier  │
  │                                                                                         │
  └─────────────────────────────────────────────────────────────────────────────────────────┘
```

**Regle de fonctionnement :**
- Standup de 10 min a 9h chaque matin
- Check-in rapide a 13h (pivot si blocage)
- Demo interne a 21h chaque soir (montrer ce qui marche)
- Un seul canal de communication (WhatsApp/Slack groupe)

---

## Scope du Sprint : "Elle repond et collecte" (Sprint 1)

```
  ┌─────────────────────────────────────────────────────────────────────────┐
  │                                                                         │
  │   DANS LE SCOPE (3 jours)                    HORS SCOPE (backlog)      │
  │   ──────────────────────                     ──────────────────────     │
  │                                                                         │
  │   ✓ Reponse auto < 60s au SMS               ✗ Integration Matrix      │
  │   ✓ Flux acheteur (9 questions)              ✗ Generation offre achat  │
  │   ✓ Flux vendeur (6 questions)               ✗ Comparables de marche   │
  │   ✓ Fiche client auto-generee               ✗ Appels vocaux IA        │
  │   ✓ Score chaleur (chaud/tiede/froid)        ✗ Multi-courtier SaaS     │
  │   ✓ Notification courtier (SMS + email)      ✗ App mobile native       │
  │   ✓ Relances auto (J+2, J+5, J-1 RDV)      ✗ Visibilite hypothecaire │
  │   ✓ Briefing quotidien 7h30                 ✗ Prospection automatisee │
  │   ✓ Dashboard simple (Notion ou web)         ✗ Calendrier Google (v2)  │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘
```

---

## JOUR 1 — VENDREDI : Aligner & Architecturer

> **Objectif :** L'infra est debout et le premier SMS IA fonctionne.
>
> ⚠️ **On n'arrive pas tous en meme temps.** Le vendredi est structure en phases, pas en heures fixes.

### Phase 1 — Premiers arrives (en attendant les autres)

Ceux qui sont la en premier demarrent le setup technique. Pas besoin d'etre au complet.

| Activite | Responsable | Sortie |
|----------|-------------|--------|
| Creer les comptes : Supabase (ca-central-1), Twilio, Anthropic | Backend + Integration | Comptes actifs |
| Installer n8n (cloud ou Docker) | Integration | n8n accessible |
| Configurer Twilio (numero QC + webhook) | Integration | SMS fonctionnel |
| Commencer le schema Supabase (5 tables) | Backend | Schema brouillon |

### Phase 2 — Kickoff (des que tout le monde est la)

On attend d'etre au complet pour aligner tout le monde.

| Activite | Responsable | Sortie |
|----------|-------------|--------|
| Standup + revue des personas et douleurs | Tous | Alignement |
| Revue du scope Sprint 1 (ce doc) | Produit/UX | Scope valide |
| Attribution des roles et domaines | Tous | Chacun sait sa lane |
| Definition of Done du dimanche soir | Produit/UX | DoD ecrit |
| Sketch architecture technique sur tableau | Architecte IA | Architecture validee |

### Phase 3 — Build (apres le kickoff)

| Activite | Responsable | Sortie |
|----------|-------------|--------|
| Deployer schema Supabase en prod | Backend | DB en prod |
| Premier prompt systeme adjointe v1 | Architecte IA | Prompt brouillon |
| Premier flux : SMS entrant → webhook → log | Integration | Pipeline connecte |
| Brancher Claude API dans n8n | Architecte IA + Integration | IA branchee |

### Soir — Premier Souffle de Vie

| Activite | Responsable |
|----------|-------------|
| Test end-to-end : envoyer SMS → IA repond | Tous |
| Iterer sur le ton (quebecois, chaleureux, pro) | Architecte IA |
| Valider que la reponse arrive en < 60 secondes | Produit/UX |

### Livrables Vendredi Soir

```
  ☐ Infra deployee (Supabase + Twilio + n8n + Claude)
  ☐ SMS test → IA repond en < 60 secondes
  ☐ Schema DB en production
  ☐ Prompt systeme v1 valide par l'equipe
```

---

## JOUR 2 — SAMEDI : Construire le Coeur

> **Objectif :** Le flux conversationnel complet fonctionne : collecte, qualification, notification courtier.

### Matin (9h-12h) — Flux Conversationnel

| Heure | Activite | Responsable | Sortie |
|-------|----------|-------------|--------|
| 9h00 | Standup (10 min) | Tous | Blocages identifies |
| 9h15 | Flux acheteur : 9 questions guidees dans Claude | Architecte IA | Flux acheteur v1 |
| 9h15 | Logique de sauvegarde conversation → Supabase | Backend | Table conversations |
| 10h30 | Flux vendeur : 6 questions guidees | Architecte IA | Flux vendeur v1 |
| 11h00 | Detection automatique acheteur vs vendeur | Architecte IA | Routing intelligent |
| 11h30 | Gestion transfert au courtier (questions complexes) | Architecte IA | Regle de transfert |

### Apres-midi (13h-18h) — Fiche Client + Notification

| Heure | Activite | Responsable | Sortie |
|-------|----------|-------------|--------|
| 13h00 | Claude genere la fiche client structuree (JSON) | Architecte IA | Extraction JSON fiable |
| 13h00 | CRUD fiche client dans Supabase | Backend | API fiche client |
| 14h30 | Score chaleur auto (chaud/tiede/froid) | Architecte IA | Scoring fonctionnel |
| 15h00 | Notification SMS au courtier (format resume) | Integration | SMS courtier ok |
| 16h00 | Notification courriel enrichie (SendGrid) | Integration | Email courtier ok |
| 17h00 | Test scenarii : presse, hesitant, curieux, hors-sujet | Produit/UX | Scenarii valides |

### Soir (19h-22h) — Stress Test

| Activite | Responsable |
|----------|-------------|
| Test end-to-end × 10 conversations differentes | Tous |
| Corriger edge cases (emojis, reponses vagues, etc.) | Architecte IA |
| Mesurer temps de reponse moyen (cible < 60s) | Produit/UX |
| Demo interne — montrer le flux complet | Produit/UX |

### Livrables Samedi Soir

```
  ☐ Flux acheteur + vendeur fonctionnels
  ☐ Fiche client auto-generee dans Supabase
  ☐ Notification courtier par SMS + courriel
  ☐ Score chaleur automatique
  ☐ 10+ conversations test reussies
```

---

## JOUR 3 — DIMANCHE : Polir & Livrer

> **Objectif :** MVP pret a etre utilise par le courtier pilote des lundi. Demo live.

### Matin (9h-12h) — Relances & Briefing

| Heure | Activite | Responsable | Sortie |
|-------|----------|-------------|--------|
| 9h00 | Standup (10 min) | Tous | Derniere ligne droite |
| 9h15 | Matrice de relance auto (J+2, J+5, J-1) | Architecte IA + Integration | Messages de relance |
| 9h15 | Cron n8n : relances planifiees | Integration | Crons actifs |
| 10h30 | Resume quotidien 7h30 (briefing matin) | Architecte IA | Format briefing ok |
| 11h00 | Test complet des relances | Produit/UX | Relances validees |
| 11h30 | Bug fixes critiques | Backend + Integration | Zero blocage |

### Apres-midi (13h-17h) — Dashboard & Polish

| Heure | Activite | Responsable | Sortie |
|-------|----------|-------------|--------|
| 13h00 | Dashboard courtier simple (Notion ou Next.js) | Produit/UX + Backend | Dashboard v1 |
| 14h00 | Vue : prospects actifs, relances, rendez-vous | Backend | Donnees dans le dashboard |
| 15h00 | Hardening : gestion erreurs, retries, logs | Backend + Integration | Systeme robuste |
| 16h00 | Documentation deploiement rapide | Produit/UX | Doc 1-pager |
| 16h30 | Rehearsal demo | Tous | Script demo pret |

### Fin de journee (17h-19h) — Demo & Handoff

| Heure | Activite | Responsable | Sortie |
|-------|----------|-------------|--------|
| 17h00 | **DEMO LIVE au courtier pilote (Joanel)** | Produit/UX | Demo donnee |
| 17h30 | Walkthrough : SMS → IA → notification | Integration | Courtier comprend le flux |
| 18h00 | Collecter feedback immediat | Produit/UX | Feedback note |
| 18h30 | Planifier semaine 1 d'utilisation reelle | Tous | Plan de suivi |
| 19h00 | Retrospective equipe rapide (15 min) | Tous | Learnings captures |

### Livrables Dimanche Soir

```
  ☐ MVP complet Sprint 1 deploye en production
  ☐ Relances automatiques actives
  ☐ Briefing quotidien programme (7h30 chaque matin)
  ☐ Dashboard courtier consultable
  ☐ Demo live faite au courtier pilote
  ☐ Feedback collecte → backlog Sprint 2
```

---

## Definition of Done — Dimanche 19h

```
  ┌─────────────────────────────────────────────────────────────────────────┐
  │                                                                         │
  │   LE MVP EST "DONE" QUAND :                                            │
  │                                                                         │
  │   1. Un prospect peut envoyer un SMS au numero du courtier              │
  │   2. L'IA repond en < 60 secondes, en francais QC naturel              │
  │   3. L'IA collecte les infos (acheteur OU vendeur) via conversation    │
  │   4. Une fiche client est creee automatiquement dans Supabase          │
  │   5. Le courtier recoit une notification SMS + email avec le resume    │
  │   6. Les relances automatiques sont planifiees                         │
  │   7. Le courtier recoit un briefing quotidien a 7h30                   │
  │   8. Le courtier pilote a vu la demo et dit "je veux l'utiliser"      │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘
```

---

## Metriques a Mesurer (Semaine 1 post-sprint)

| Metrique | Avant (estime) | Cible MVP | Comment mesurer |
|----------|----------------|-----------|-----------------|
| Temps 1re reponse | 1-4 heures | < 1 minute | Timestamp Twilio |
| Documents recus < 5 jours | ~50% | 80% | Supabase statut |
| Relances oubliees/semaine | 3-5 | 0 | Table relances |
| Prospects perdus (inactifs) | ~30% | < 10% | Score chaleur |
| Temps admin courtier/jour | 3-4 heures | 30 min | Auto-declaration |

---

## Stack Technique Recap

```
  SMS entrant (Twilio)
       │
       v
  n8n (orchestration)  ──>  Claude API (claude-sonnet-4-6)
       │                          │
       │                     Prompt systeme
       │                     + historique conversation
       │                     + fiche client
       │                          │
       v                          v
  Supabase (PostgreSQL)     Reponse SMS sortant (Twilio)
  ├── clients               Notification courtier (SMS + SendGrid)
  ├── conversations         Relances cron (n8n scheduler)
  ├── relances              Briefing quotidien (n8n cron 7h30)
  ├── rendez_vous
  └── config_courtier

  Cout estime : ~35-50$/mois
  Hebergement : Canada (ca-central-1) pour Loi 25
```

---

## Risques & Mitigations

| Risque | Impact | Mitigation |
|--------|--------|------------|
| Twilio prend du temps a approuver le numero QC | Bloquant J1 | Commander le numero DES MAINTENANT |
| Claude hallucine des infos | Credibilite | Tester 10+ scenarii samedi soir, contraindre via prompt |
| n8n trop lent pour < 60s | Performance | Mesurer. Plan B : script Python direct |
| Courtier pilote pas dispo dimanche | Pas de demo | Confirmer sa disponibilite AVANT vendredi |
| Scope creep ("ajoutons le calendrier!") | Retard | Scope fige vendredi 12h. Tout ajout va au backlog |

---

## Pre-Requis Avant Vendredi

```
  ☐ Confirmer la disponibilite du courtier pilote dimanche 17h
  ☐ Commander le numero Twilio QC (peut prendre 24-48h)
  ☐ Creer le compte Supabase (region ca-central-1)
  ☐ Creer le compte Anthropic (cle API)
  ☐ Installer n8n (ou creer le compte cloud)
  ☐ Creer le compte SendGrid/Mailgun
  ☐ Partager ce document a toute l'equipe
  ☐ Chaque membre choisit son role
```

---

## Apres le Sprint — Et Ensuite ?

```
  SEMAINE 1-2 : Utilisation reelle par Joanel
       │         Collecter metriques + feedback
       │
       v
  SPRINT 2 : "Elle relance et organise"
       │      Calendrier Google, planification visites
       │      Dashboard enrichi
       │
       v
  SPRINT 3 : "Elle analyse et genere"
       │      Analyse comparables automatique
       │      Generation d'offres d'achat (vision baguette magique)
       │
       v
  V1 PUBLIQUE : Multi-courtier
              Onboarding Maxime + Charlyse
              Pricing & modele d'affaires
```

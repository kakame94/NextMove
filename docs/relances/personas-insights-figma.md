# Personas & Patterns Communs — Extraction Figma (page 0:1)

> Extraction du Figma [Personas-Courtiers-Immobiliers — Atelier-JTBD](https://www.figma.com/design/JXlxEfExXxH1sVpXFnwFKH/)
> Node analysé : `0:1` (Canvas "Personas Courtiers")
> Date : 2026-04-17
> Méthodologie source : Atelier JTBD — Mars 2026 | 4 courtiers interviews

**⚠️ Les templates SMS ne sont PAS dans ce Figma.**
Ce fichier contient le **contexte utilisateur** (personas + patterns) qui doit guider la rédaction des templates.

---

## 1. Les 4 Lean Personas

### 🎯 Joanel — « Le Solo Ambitieux » (COURTIER PILOTE)

| Attribut | Valeur |
|----------|--------|
| **Archétype** | Courtier immobilier établi, performant, travaille SEUL — plafonné par l'admin |
| **Stats** | 90% close rate, Grand Montréal, 100% referrals |
| **Job-To-Be-Done** | « Libérer mon temps admin pour faire plus de visites, de négociations et de volume » |
| **Top 3 douleurs** | 1. L'admin mange le temps de vente (quotidien)<br>2. Zéro visibilité hypothécaire (par transaction)<br>3. Temps de réponse trop long (quotidien) |
| **Peur profonde** | « Que le dossier ne passe pas » — aucun contrôle sur le côté hypothécaire |
| **Baguette magique** | « Une IA qui génère une offre d'achat en un rien de temps, signature électronique » |
| **Propension changement** | Push 10/10, Pull 10/10, Anxiété 3/10 — **TRÈS PRÊT** |

### 🏗️ Maxime — « Le Bâtisseur Structuré »

| Attribut | Valeur |
|----------|--------|
| **Archétype** | Courtier en croissance, niche plex, assistante virtuelle à la carte — veut scaler |
| **Stats** | 3-4 transactions/mois, 13 ans exp., Immo Plus |
| **Job-To-Be-Done** | « Automatiser l'analyse des propriétés et structurer ma génération de leads pour scaler de 3 à 4+ transactions/mois sans m'épuiser » |
| **Top 3 douleurs** | 1. Analyse manuelle une par une<br>2. Pas de système de lead gen<br>3. Assistante ne prend pas le verbal |
| **Peur profonde** | Avancer « sous la grâce » sans systèmes |
| **Baguette magique** | « Sur la route, par verbal : fais-moi une offre d'achat » |
| **Propension changement** | Push 7/10, Pull 8/10, Anxiété 2/10 — **PRÊT** |

### 🔬 Charlyse Amoussou — « La Perfectionniste Autonome »

| Attribut | Valeur |
|----------|--------|
| **Archétype** | Ancienne scientifique (PhD), courtière méthodique, 100% référrals |
| **Stats** | Depuis 2018, solo complet |
| **Job-To-Be-Done** | « Avoir un système fiable qui synchronise tout — une seule entrée qui se propage partout » |
| **Top 3 douleurs** | 1. Saisie redondante multi-systèmes<br>2. Systèmes non fiables<br>3. Pas de temps pour réseaux sociaux |
| **Peur profonde** | « Paraître non-professionnelle à cause d'une erreur système » |
| **Vision idéale** | « Lead arrive → réponse < 1h → calendrier auto → 3 options RDV<br>Portfolio + infos propriété AVANT la visite<br>Contrat pré-rempli, photos bookées devant le client<br>Post-offre : calendrier conditions + rappels auto<br>CRM : anniversaire, taxes, anniversaire d'achat<br>"Tu te présentes, tu as l'air d'un pro du 22e siècle" » |
| **Disposition à payer** | Ne chipote PAS sur le budget SI ça règle le problème. **Exige fiable, quantifiable, config une fois. Bilingue FR/EN obligatoire** |
| **Propension changement** | Push 6/10, Pull 9/10, Anxiété 6/10 — prête mais exigeante |

### 🏢 JP — « Le Stratège de Franchise »

| Attribut | Valeur |
|----------|--------|
| **Archétype** | Co-propriétaire franchise Royal LePage + courtier terrain — double casquette |
| **Stats** | 99 courtiers sous sa supervision, Gatineau, plex/investisseurs |
| **Job-To-Be-Done** | « Centraliser les outils et simplifier la gestion pour que mes courtiers et moi passions plus de temps sur le terrain avec les clients » |
| **Top 3 douleurs** | 1. Temps gestion interne vs terrain<br>2. CRM : adoption faible (2/10 courtiers)<br>3. Trop d'outils non connectés |
| **Peur profonde** | **« Si vous utilisez un outil et que cet outil fait des choses à votre place, vous êtes imputable »** — responsabilité OACIQ, il a vu des amendes |
| **Baguette magique** | « One-stop-shop. Digérer un document de 100 pages → sommaire. Il faut vraiment apporter quelque chose » |
| **Propension changement** | Push 4/10, Pull 3/10, Anxiété 8/10 — **SCEPTIQUE — CONFORMITÉ D'ABORD** |

---

## 2. Les 12 Patterns Communs (4 courtiers)

| # | Pattern | Implication produit |
|---|---------|--------------------|
| **1** | **L'admin est l'ennemi unanime** | Tout ce qui automatise l'admin = quick win |
| **2** | **Matrix/Centris = écosystème subi** | À ne pas essayer de remplacer, mais à intégrer |
| **3** | **Referrals > Publicité** | 3/4 à 100% référrals — produit doit protéger la relation, pas la robotiser |
| **4** | **Offre d'achat / formulaires = tâche clé** | Feature génération offre = next-gen killer feature |
| **5** | **Le verbal / voix est désiré** | Post-MVP : input vocal (Joanel dicter, Maxime sur route) |
| **6** | **Confiance = non-négociable** | **Chaque action IA doit être traçable + réversible** |
| **7** | **Chaque courtier a sa méthode** | **Flexibilité > imposition** — paramétrable par courtier |
| **8** | **Vision commune : le courtier du 22e siècle** | Arriver ultra-préparé, patterns analysés |
| **9** | **Bilingue FR/EN non-négociable** | **Templates SMS : FR + EN dès MVP si prospect anglophone** |
| **10** | **SMS = canal privilégié** (JP confirme) | Validation absolue du choix SMS/Twilio |
| **11** | **Conformité OACIQ = frein à l'IA** | **Disclaimers + trace humaine obligatoires** sur toute action auto |
| **12** | **CRM = promesse non tenue** (~20% d'adoption) | **Learning curve = barrière #1** — UX ultra-simple |

---

## 3. Implications directes pour les templates SMS

À partir de ces insights, voici les **règles de rédaction** des templates :

### 🎯 Ton et style (synthèse des 4 personas)

1. **Ton québécois naturel** — chaleureux, pro, pas corporate
2. **Court et direct** — Joanel déteste les pertes de temps, Maxime sur la route
3. **Jamais d'erreur visible** — Charlyse : peur profonde de paraître non-pro
4. **Toujours un humain cité** — pattern 6 (confiance) + 11 (OACIQ) : nom du courtier mentionné
5. **Bilingue FR/EN** — détecter la langue du prospect et répondre dans sa langue

### ⚖️ Conformité OACIQ (obligatoire selon JP)

Chaque message automatique doit :
- ✅ **Être signé au nom du courtier** (pas de l'IA)
- ✅ **Laisser la possibilité au prospect de joindre directement le courtier**
- ✅ **Ne jamais promettre un résultat** (prix, financement, délai)
- ✅ **Être archivé** (traçabilité OACIQ)
- ❌ **Ne jamais prendre une décision à la place du courtier** (imputabilité)

### 📱 Format SMS optimal

- 1 message = 1 action claire (question ou CTA)
- Pas de jargon technique
- Pas d'urgence artificielle
- Opt-out visible au moins tous les 3 messages
- Réponse attendue : un mot (OUI/NON/STOP/CONTINUER) ou message libre

### 🎨 Adaptation par persona (si multi-courtier post-MVP)

| Persona | Préférence template |
|---------|---------------------|
| **Joanel (solo performant)** | Efficacité brute, signe "— Joanel" |
| **Maxime (scale-up)** | Automation à fond, tag lead source |
| **Charlyse (perfectionniste)** | Double-check avant envoi, version FR/EN |
| **JP (franchise)** | Disclaimers OACIQ, approval manager optionnel |

---

## 4. Insights pour le système de relance (matrice M1-M4)

### Confirmations

- ✅ **SMS = canal principal** (pattern 10)
- ✅ **Bilingue** FR/EN nécessaire dès MVP (pattern 9)
- ✅ **Temps de réponse < 1 min** validé par Joanel + Charlyse
- ✅ **Relance = besoin réel** : Joanel « temps de réponse trop long », Maxime « assistante ne prend pas verbal »

### Alertes

- ⚠️ **Confiance/OACIQ** : chaque relance doit être signée par le courtier (pas "NextMove")
- ⚠️ **Charlyse "système non fiable"** : 0 tolérance pour les bugs d'envoi
- ⚠️ **JP sceptique** : le produit doit prouver sa valeur rapidement

### Idées templates à développer

Basé sur la vision de Charlyse ("Lead arrive → réponse < 1h → calendrier auto → 3 options RDV") :

**Template post-lead inbound (nouveau prospect) :**
```
Bonjour {{prospect_prenom}}, merci pour votre message ! 
Pour vous préparer un accompagnement sur mesure, quelques questions rapides. 
Êtes-vous plutôt acheteur ou vendeur ?
— {{courtier_prenom}}
```

**Template proposition RDV (après qualification) :**
```
{{prospect_prenom}}, voici 3 créneaux disponibles pour notre échange :
1️⃣ {{option_1}}
2️⃣ {{option_2}}  
3️⃣ {{option_3}}
Répondez 1, 2 ou 3.
— {{courtier_prenom}}
```

**Template portfolio pré-visite (conforme vision Charlyse) :**
```
{{prospect_prenom}}, avant notre RDV de {{rdv_date}}, voici le dossier complet 
de la propriété : {{lien_portfolio}}.
Bonne lecture !
— {{courtier_prenom}}
```

---

## 5. Ce qui manque dans le Figma

**Ni dans node 0:1 (Personas) ni dans node 10:2 (Sprint MVP Board) :**

- ❌ Les textes exacts des templates SMS happy path
- ❌ Les variantes edge cases
- ❌ Les templates en anglais (EN-CA)
- ❌ Les messages système (STOP ack, HELP, erreur)
- ❌ Le prompt système Claude utilisé en production

**Hypothèses sur leur localisation possible :**

1. **Dans n8n** — chaque workflow a un node "Send SMS" avec le texte inline
2. **Dans la table `relance_templates`** de Supabase (si déjà peuplée)
3. **Dans le prompt système Claude** (stocké en variable d'environnement n8n)
4. **Pas encore rédigés** — à co-créer avec Joanel au workshop

---

## 6. Questions pour Eliot

1. 🔴 Existe-t-il **un autre fichier Figma** avec les templates ?
2. 🔴 Peux-tu me partager **le prompt système Claude** actuel (si déjà rédigé) ?
3. 🟡 Les messages SMS actuels (Sprint 1 bout-en-bout) ont-ils déjà été testés avec Joanel ?
4. 🟡 Intégration EN-CA : MVP ou Post-MVP ?

---

*Document rédigé par l'équipe NextMove — v1.0*

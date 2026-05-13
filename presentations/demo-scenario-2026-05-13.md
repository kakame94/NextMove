# Storyboard démo client · NextMove
**Cible** : 10-12 min live · Maxime et Joanel · 13 mai 2026

---

## 🎬 Pre-flight checklist (à faire 15 min avant chaque démo)

### Matériel
- [ ] Laptop branché, batterie > 50%, mode "ne pas déranger" activé
- [ ] Téléphone (le tien) chargé + Telegram ouvert sur `@nextmove_voice_bot`
- [ ] Téléphone testeuse (femme) accessible OU 2e téléphone avec SMS vers `+1 272 282 5614`
- [ ] Connexion Wi-Fi solide + plan B 4G (Twilio + n8n cloud + Supabase)

### Stack vérifications (1 min)
- [ ] Dashboard ouvert sur la **bonne URL selon le client** :
  - **Démo Maxime** → `http://localhost:8765/index.html?courtier=Maxime%20Belma`
  - **Démo Joanel** → `http://localhost:8765/index.html` (default = "Joanel" avatar JO)
- [ ] Server local lancé : `python3 -m http.server 8765` dans le repo
- [ ] Workflow n8n `next_move_intake_agent_v2` → **actif** ✅
- [ ] Workflow n8n `next_move_voice_assistant` → **actif** ✅
- [ ] Test rapide : voice message au bot Telegram → reçoit une réponse en <15s ?

### Backup
- [ ] Loom de la démo solo enregistré la veille (au cas où live foire)
- [ ] Onglet de secours : `https://supabase.com/dashboard/project/fhqybnkxqfvbsjvwrcob/editor` (montrer la DB direct si l'API web foire)

---

## 🎙️ Structure 10-12 min · minute par minute

### 0:00 — 1:00 · Intro & problème
**Phrase d'ouverture** :
> *"Maxime / Joanel, merci de prendre 10 minutes. Je vais te montrer NextMove — un assistant IA qui qualifie tes prospects 24/7 quand tu peux pas répondre toi-même."*

**Le problème en 3 phrases** :
1. Un prospect qui texte le soir et n'a pas de réponse pendant 6h, **70% sont perdus** (étude OACIQ).
2. Toi, tu peux pas être au téléphone 24/7. Et embaucher une vraie adjointe = 50k$/an + risque humain.
3. **NextMove fait le job d'une adjointe humaine pour les premières 24h**, et te transmet seulement les leads qualifiés.

**Transition** : *"Concrètement, ça donne quoi. Regarde."*

---

### 1:00 — 2:30 · Tour du dashboard
**Action** : montrer l'écran dashboard (Bonjour, Maxime/Joanel + 4 KPIs + Prospects Chauds).

**Phrases à dire** :
- *"Voici ta vue de matin. 10 prospects actifs, 5 chauds (score ≥ 7), 3.8 M$ de pipeline potentiel."*
- *"En haut à droite : 3 relances planifiées cette semaine, dont 1 en retard que tu devrais traiter en priorité."*
- Cliquer sur **Mathieu Simard** (score 9) → montrer le détail : *"Mathieu c'est un prospect très chaud — pré-approuvé 720k, doit déménager en juin, demande à te rappeler. C'est l'IA qui a extrait tout ça d'une conversation SMS de 6 messages."*
- Cliquer "Voir la conversation" → montrer les 6 messages naturels FR-QC.

**Point clé** : *"Tu n'as **rien fait** sur ce prospect. L'IA l'a qualifié toute seule. Tu reçois juste l'alerte parce qu'il est chaud."*

---

### 2:30 — 5:00 · Scénario LIVE 1 — SMS → qualification temps réel
**Action** :
1. Sortir le téléphone testeuse → envoyer un SMS à **+1 272 282 5614** :
   > *"Bonjour, je cherche un condo à Mercier-Est, budget 380k, on est 2"*
2. **Pendant que Twilio livre** (10-30s), commenter :
   - *"Là, Twilio reçoit le SMS, n8n se déclenche, déduplique pour gérer les rafales, sauvegarde en DB Supabase, et Claude Sonnet 4.6 prend le relais."*
3. Au bot de répondre (visible côté téléphone testeuse) → montrer la réponse SMS naturelle.
4. F5 sur le dashboard → **le nouveau prospect apparaît** dans la liste.
5. Cliquer dessus → montrer que l'IA a déjà extrait *budget*, *secteur*, *type*, *nombre d'acheteurs*.

**Phrase punchline** : *"Tu vois ? 30 secondes après le SMS du prospect, tu as une fiche complète. Sans toi."*

**Si Twilio lag > 30s** → *"Le SMS passe par Twilio, ça peut prendre jusqu'à 30 secondes. Continuons, il va apparaître."*

---

### 5:00 — 7:30 · Scénario LIVE 2 — Voice assistant Telegram
**Setup** : montrer Telegram ouvert sur `@nextmove_voice_bot` sur ton téléphone.

**Phrase d'intro** :
> *"Voilà pour les prospects. Maintenant le truc qui change tout pour toi : tu peux interroger ta base juste en parlant."*

**Action 1** : envoyer voice message à `@nextmove_voice_bot` :
> *"Combien de prospects chauds j'ai actuellement ?"*

→ Attendre la réponse vocale (~10s). Mettre le téléphone à côté du laptop pour qu'on entende bien.

**Action 2** (follow-up, mémoire conversationnelle) :
> *"Et lesquels cherchent à Anjou ?"*

→ Le bot doit comprendre qu'on parle des prospects chauds + ajouter le filtre Anjou.

**Action 3** (lookup spécifique) :
> *"C'est quoi le budget de Sophie Lavoie ?"*

→ Réponse audio courte avec le budget.

**Phrase punchline** : *"Pendant que tu conduis vers un rendez-vous, ou que tu prends 5 min entre 2 visites, tu interroges ta base à la voix. Pas besoin de sortir le laptop."*

**Si une réponse foire** → *"Le modèle peut hésiter parfois — on a un système d'évaluation continue qui valide la qualité des réponses sur des cohortes de test."*

---

### 7:30 — 9:00 · Robustesse & conformité
**Action** : ouvrir la vue **Prospects** → filtrer / pointer 2-3 cas spécifiques.

#### 1. STOP respecté (Loi 25 + CASL)
- Pointer **Marc Dubois** (statut "perdu", blacklisté) :
  > *"Marc a tapé STOP. Le système l'a immédiatement ajouté à la blacklist, plus jamais aucun message ne sortira vers son numéro. C'est Loi 25 et CASL — obligatoire au Québec, conformité by design."*

#### 2. Relances automatiques
- Pointer **Patrick Côté** (silence depuis 2 jours, relance J+2 planifiée) :
  > *"Patrick a pas répondu depuis 48h. Demain matin à 9h, l'IA lui envoie automatiquement un message de relance personnalisé. Si toujours pas de réponse à J+5, deuxième relance plus douce. Toi tu n'as rien à faire — sauf marquer 'pause' si tu prends la main."*

#### 3. Garde-fous "humain prioritaire"
> *"Quand toi tu envoies un SMS manuellement, l'IA se met en pause sur ce prospect pendant 24h pour ne pas marcher sur tes pieds. C'est le garde-fou G4."*

---

### 9:00 — 10:30 · Multi-canal & passage à l'échelle
**Phrases** :
- *"Aujourd'hui je t'ai montré 2 canaux : SMS pour les prospects, voice Telegram pour toi. Tout est unifié sur la même base."*
- *"Si demain ton agence a 50 courtiers, l'architecture est prête : chaque courtier voit que ses propres prospects, son bot vocal, ses relances. C'est le multi-tenant — déjà câblé en base, juste à activer côté interface."*
- *"Conformité totale : les données restent au Canada (Supabase région ca-central-1), pas de fuite vers les US. Loi 25 OK, OACIQ OK."*

---

### 10:30 — 12:00 · Recap & ouverture
**Recap en 3 points** :
1. **L'IA qualifie tes leads sans toi** → tu reçois juste les chauds, prêts à closer.
2. **Tu interroges ta base à la voix** → utile en déplacement.
3. **Conformité Loi 25 + CASL by design** → zéro risque légal.

**Ouverture** :
> *"Si tu veux un essai sur 30 jours avec ton propre numéro Twilio dédié, on peut t'onboarder cette semaine. Tu me dis ?"*

**Tarification** (si la question vient — sinon ne pas l'amener) :
- *"On finalise le modèle avec les premiers pilotes — tu serais dans les 3 premiers, donc accès préférentiel. Discutons-en autour d'un café cette semaine."*

---

## 🎥 Variante Loom solo (8-10 min)

Mêmes étapes mais **sans Q&A**, donc plus condensé :
- 0:00-0:45 · Intro problème (au lieu d'1 min)
- 0:45-2:00 · Tour dashboard (réduit)
- 2:00-4:30 · Scénario SMS live
- 4:30-6:30 · Scénario voice Telegram (3 questions au lieu de 3)
- 6:30-8:00 · Robustesse (1 minute par cas au lieu d'1:30)
- 8:00-8:30 · Recap court

**Tips Loom** :
- **Webcam ON** dans le coin (relation humaine compte autant que la démo)
- Utiliser Loom Chapters pour découper par scénario → le client peut naviguer
- 1ère prise pas parfaite ? Réenregistrer. Pas de mid-cuts qui se voient
- Lien Loom à envoyer **avant** la démo live à Maxime/Joanel → ils arrivent préparés

---

## 🛠️ Backups par scénario

| Scénario | Backup si ça foire |
|---|---|
| SMS prend trop de temps | Montrer une conversation existante seedée (ex: Marie-Claude Tremblay) en disant "voici un cas réel récent" |
| Voice bot ne répond pas | Avoir le Loom solo ouvert dans un onglet, jouer la séquence voice depuis Loom |
| Dashboard ne charge pas (Supabase down) | Onglet Supabase dashboard direct ouvert |
| Crash navigateur | Avoir l'URL ?courtier=... pinnée dans les favoris |
| Question pricing tu sais pas répondre | *"Bonne question, je note et te reviens cet après-midi avec une proposition concrète"* |

---

## 📞 Numéros & accès

- Bot Telegram : `@nextmove_voice_bot` (allowlist : `telegram_user_id = 7326149684` (toi))
- Twilio NextMove : `+1 272 282 5614`
- Testeuse SMS (femme) : `+1 579 421 6910`
- Supabase project : `fhqybnkxqfvbsjvwrcob` (ca-central-1)
- Workflow voice : id `0UNAKGRciurrtlez`
- Workflow intake : id `nmmmJu6HRwq0nqyI`

---

## 📋 À ne pas oublier de mentionner

- ✅ "Données restent au Canada" (rassurer sur RGPD/Loi 25)
- ✅ "Loi 25 + CASL respectés by design" (réflexe avocat = oui)
- ✅ "Tu gardes la main en 1 clic" (pause_relances)
- ✅ "Tu vois en temps réel ce que dit l'IA" (pas de boîte noire)
- ❌ Ne PAS mentionner : voice cloning, app mobile, dashboard analytique multi-courtier (out of MVP scope)
- ❌ Ne PAS mentionner : Claude / OpenAI / n8n par leurs noms (sauf si client tech demande)

---

## ✅ Post-démo (5 min après le call)

- [ ] Envoyer email récap : *"Voici la démo en replay [Loom URL] + lien dashboard de test si tu veux jouer avec [URL avec ?courtier=Maxime]"*
- [ ] Noter dans le CRM perso : objections, pricing évoqué, prochaine étape
- [ ] Si pilote OK : créer un nouveau courtier en base (Supabase) + numéro Twilio dédié dans la semaine

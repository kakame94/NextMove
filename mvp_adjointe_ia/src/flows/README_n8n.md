# Flux n8n — Guide d'implementation

## Vue d'ensemble des flux Sprint 1

### Flux 1: SMS Entrant → Reponse IA

```
[Webhook Twilio SMS]
       |
       v
[Chercher client par telephone] (Supabase)
       |
       ├── Client existe → charger fiche + historique
       └── Client n'existe pas → creer fiche vide
       |
       v
[Sauvegarder message entrant] (Supabase: conversations)
       |
       v
[Appeler Claude API]
  - Prompt systeme: adjointe_systeme.md
  - Variables: NOM_COURTIER, FICHE_CLIENT, HISTORIQUE
  - Message utilisateur: contenu du SMS
       |
       v
[Parser la reponse Claude]
  - Extraire le message texte (pour le client)
  - Extraire le JSON structure (si present → action)
       |
       v
[Envoyer SMS de reponse] (Twilio)
       |
       v
[Sauvegarder message sortant] (Supabase: conversations)
       |
       v
[Si action "creer_fiche":]
  ├── Mettre a jour fiche client (Supabase)
  ├── Envoyer notification au courtier (SMS + courriel)
  └── Planifier relances initiales (Supabase: relances)
```

### Flux 2: Courriel Entrant → Reponse IA

```
[Webhook reception courriel] (SendGrid Inbound Parse)
       |
       v
[Meme logique que Flux 1, canal = courriel]
       |
       v
[Envoyer reponse par courriel] (SendGrid)
```

### Flux 3: Notification au Courtier

```
[Declencheur: nouvelle fiche client complete]
       |
       v
[Generer notification depuis template]
  - notification_courtier.md
  - Remplir les variables
       |
       v
[Envoyer en parallele:]
  ├── SMS au courtier (Twilio)
  └── Courriel au courtier (SendGrid)
```

## Configuration n8n

### Credentials necessaires

| Nom | Type | Notes |
|-----|------|-------|
| twilio_sms | Twilio | SID + Token + Numero |
| supabase_db | Supabase | URL + Service Key |
| anthropic_api | HTTP Header Auth | Bearer + API Key |
| sendgrid_mail | SendGrid | API Key |

### Webhook Twilio

1. Dans Twilio Console → Phone Numbers → votre numero
2. Messaging → "A message comes in" → Webhook
3. URL: `https://votre-n8n.com/webhook/sms-entrant`
4. Method: POST

### Variables d'environnement n8n

Configurer dans Settings → Variables:
- `COURTIER_NOM`
- `COURTIER_TELEPHONE`
- `CLAUDE_MODEL`

## Notes d'implementation

### Gestion de l'historique de conversation

Pour chaque message entrant, charger les 20 derniers messages
de la conversation avec ce client. Format pour Claude:

```
[2026-03-07 10:30] Client: Bonjour, je cherche un condo
[2026-03-07 10:30] Assistante: Bonjour! Merci de nous contacter...
[2026-03-07 10:32] Client: Je cherche dans Verdun
```

### Detection du JSON dans la reponse Claude

Claude va inclure un bloc JSON quand il a assez d'infos.
Utiliser une regex pour extraire:

```javascript
const jsonMatch = response.match(/```json\n([\s\S]*?)\n```/);
if (jsonMatch) {
  const action = JSON.parse(jsonMatch[1]);
  // Traiter l'action (creer_fiche, etc.)
}
```

Le message texte pour le client = tout ce qui est EN DEHORS du bloc JSON.

### Gestion du rate limiting

- Claude API: max 1 requete par conversation en cours
- Twilio SMS: respecter les limites de debit
- Ajouter un delai de 1-2 secondes entre la reception et la reponse
  (pour paraitre plus naturel qu'un bot)

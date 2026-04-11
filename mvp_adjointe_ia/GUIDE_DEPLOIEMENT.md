# Guide de Deploiement — MVP Adjointe IA

## Pre-requis

- [ ] Compte Twilio (numero canadien +1 514)
- [ ] Compte Supabase (region ca-central-1 pour Loi 25)
- [ ] Cle API Anthropic (Claude)
- [ ] Instance n8n (auto-heberge ou n8n.cloud)
- [ ] Compte SendGrid (optionnel sprint 1, requis sprint 2)

## Etape 1 — Base de donnees Supabase (15 min)

1. Creer un nouveau projet Supabase
   - Region: **Canada East (ca-central-1)**
   - Nom: `adjointe-ia-courtier`

2. Aller dans SQL Editor et executer le contenu de:
   `src/db/schema.sql`

3. Inserer la configuration du courtier:
   ```sql
   INSERT INTO config_courtier (nom, telephone, courriel)
   VALUES ('Nom du Courtier', '+15141234567', 'courtier@email.com');
   ```

4. Recuperer les cles:
   - Settings → API → `URL` et `anon key` et `service_role key`

## Etape 2 — Twilio (20 min)

1. Creer un compte Twilio: https://www.twilio.com
2. Acheter un numero canadien (+1 514 ou +1 438)
   - Prix: ~1.50$/mois + ~0.0075$/SMS
3. Aller dans Phone Numbers → votre numero
4. Section "Messaging":
   - "A message comes in" → Webhook
   - URL: `https://votre-n8n.com/webhook/sms-entrant`
   - Method: HTTP POST
5. Recuperer: Account SID, Auth Token, Phone Number

## Etape 3 — n8n (30 min)

### Option A: n8n.cloud (plus rapide)
1. S'inscrire sur https://n8n.cloud
2. Importer le workflow: `src/flows/n8n_workflow_sms.json`

### Option B: Auto-heberge (plus de controle)
1. Deployer n8n sur Railway/Render/VPS:
   ```bash
   docker run -it --rm \
     --name n8n \
     -p 5678:5678 \
     -v n8n_data:/home/node/.n8n \
     n8nio/n8n
   ```

2. Configurer les credentials dans n8n:
   - Twilio: SID + Token
   - Supabase: URL + Service Key
   - HTTP Header Auth (pour Claude): `x-api-key: sk-ant-...`

3. Importer le workflow JSON et activer

## Etape 4 — Configurer les variables (5 min)

Dans n8n → Settings → Variables, ajouter:

| Variable | Valeur |
|----------|--------|
| ANTHROPIC_API_KEY | sk-ant-... |
| CLAUDE_MODEL | claude-sonnet-4-6 |
| TWILIO_PHONE_NUMBER | +15141234567 |
| COURTIER_NOM | Nom du Courtier |
| COURTIER_TELEPHONE | +15141234567 |
| SUPABASE_URL | https://xxx.supabase.co |
| SUPABASE_SERVICE_KEY | eyJ... |

## Etape 5 — Tester (10 min)

1. Envoyer un SMS au numero Twilio depuis votre telephone
2. Verifier dans n8n que le webhook se declenche
3. Verifier que Claude repond
4. Verifier que le SMS de reponse arrive
5. Verifier dans Supabase que le client et la conversation sont crees

### Test de bout en bout

```
Vous: "Bonjour, je cherche un condo"
IA:   "Bonjour! Merci de nous contacter. Pour mieux vous
       servir, est-ce que vous cherchez a acheter ou a vendre?"
Vous: "Acheter"
IA:   "Super! Dans quel secteur vous aimeriez acheter?"
Vous: "Verdun"
IA:   "C'est quoi votre budget approximatif?"
...
[Apres toutes les questions]
IA:   "Merci beaucoup! Voici ce que j'ai note: [resume].
       [Courtier] va vous contacter dans les prochaines 24h!"

→ Le courtier recoit un SMS: "NOUVEAU PROSPECT [CHAUD]..."
→ Supabase: fiche client creee + conversation sauvegardee
```

## Couts estimes

| Service | Cout mensuel estime |
|---------|-------------------|
| Twilio (numero + ~500 SMS) | ~5-10$ |
| Supabase (plan gratuit) | 0$ |
| Claude API (~1000 requetes) | ~5-15$ |
| n8n.cloud (starter) | 24$/mois |
| **Total** | **~35-50$/mois** |

Vs une assistante en Republique Dominicaine: 400-500$/mois
Vs une assistante au Quebec: 2500-3000$/mois

## Prochaines etapes apres deploiement

1. [ ] Tester avec le courtier pendant 1 semaine
2. [ ] Ajuster le prompt selon les retours
3. [ ] Ajouter le canal courriel (Sprint 1 bonus)
4. [ ] Implementer les relances automatiques (Sprint 2)
5. [ ] Ajouter le resume quotidien (Sprint 2)
6. [ ] Explorer l'integration Matrix (Sprint 3)

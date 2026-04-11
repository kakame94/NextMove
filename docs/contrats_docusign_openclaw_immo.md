# Personnel - Contrats / DocuSign / OpenClaw / Immobilier

> **Thème** : Recherche de contrats, OpenClaw, agent immobilier IA
> **Conversation Cursor** : `f53944c0-2c35-4e36-82bc-d411dbb6b07d`
> **Période** : Février 2026

---

## Contexte

Recherche de contrats professionnels (RBQ via LGS-IBM, Santé Québec via Astek), installation d'OpenClaw pour automatisation, projet d'agent immobilier IA pour recherche de triplex.

---

## Prompts - Recherche de contrats

1. "trouve moi les contrats de la RBQ et Santé Québec dans TOUT mon ordinateur"
2. "je les ai téléchargés, peut-être qu'ils ne s'appellent pas 'contrat' mais ils sont là, ce sont des PDF, il y a les taux horaires dedans"
3. "RBQ c'est avec LGS-IBM"
4. "c'est un document signé en août 2025, un PDF"
5. "tous les DocuSign entre août 2025 et septembre"
6. "et iCloud"
7. "et Astek"
8. "donc tu n'as aucun document d'entente contractuel, Pigisite avec LGS-IBM, ou la Régie du Bâtiment du Québec ?????? dans tout l'ordinateur"

---

## Prompts - OpenClaw

9. "télécharge moi et installe moi OpenClaw"
10. "quels sont les cas d'utilisation puissants d'OpenClaw ?"
11. "peut-il répondre à des messages Teams et des courriels Outlook ?"
12. "j'ai 2 mandats RBQ et Santé Québec, mais je peux bosser avec mon matériel, mon Mac. Si je suis dehors, peut-il répondre aux messages, en ouvrant la fenêtre Teams et répondre au message en fonction du contexte, ou genre m'envoyer un message sur Telegram et me demander la permission pour répondre ?"
13. "la sécurité de ces 2 organismes ne laisserait jamais une API externe se connecter. Là je parle manière physique, peut-il ouvrir Teams et répondre aux messages ? Sans webhook"

---

## Prompts - Déploiement Netlify

14. "Pour déployer sur Netlify, j'ai besoin d'un token d'authentification. Comment souhaitez-vous procéder ? donne le moi"

---

## Prompts - Agent immobilier IA (ClawdBot)

15. "est-ce que ClawdBot peut chercher pour moi des triplex à Gatineau et dans la grande région de MTL qui répondent à ces critères : lettre de préqualification pour l'achat de votre propriété"
16. "avec WhatsApp plutôt, mettre à jour une liste dans une page web avec le lien du bien. Je veux aussi isoler ClawdBot car je ne veux pas qu'il ait accès à mes infos personnelles ou sensibles sur mon Mac"
17. "oui pour le schéma, je veux ensuite que tu installes et exécutes OpenClaw dans Docker. Pour la partie data je veux une solution gratuite"
18. "ok lance 1 à 5"
19. "mon OpenClaw-immo tourne toujours sur Docker je crois, peux-tu l'arrêter ?"

---

## Fichiers générés dans le workspace

### Dossier : `20_Outils_Clients/openclaw-immo/`
- Installation OpenClaw dans Docker
- Agent immobilier IA (ClawdBot) pour recherche de triplex
- Configuration isolée (sandbox)

### Dossier : `centris_agent/` (agent recherche immobilière)
- `centris_agent_v2.py`
- `centris_agent_v3.py`
- `centris_playwright_agent.py`
- `centris_duplex.db`
- `debug_centris.html`
- `debug_centris.png`

### Dossier : `immeuble_revenus_scraper/`
- Scraper multiples versions (`scraper_*.py`)
- Application web (`web/`)

### Dossier : `plexinvest-quebec/` (app Next.js)
- Application complète d'analyse immobilière BRRRR
- Déployée sur Netlify

---

## Informations contractuelles

| Mandat | Firme intermédiaire | Taux | Heures |
|--------|---------------------|------|--------|
| RBQ | LGS-IBM | 110$/h | 35h/sem |
| Santé Québec | Astek | 95$/h | 35h/sem |
| Bénéva (Reine-Emma) | - | 100$/h | 35h (lun-jeu) |

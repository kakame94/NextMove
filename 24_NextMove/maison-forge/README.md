# Maison Forge — Site web vitrine + capture lead IA

> Site complet pour l'agence de rénovation **Maison Forge** (cuisines, salles de bain, Montréal).
> Brand extraite du PDF [Proposition_Projet_2582_Baldwin_Loua](../../../Downloads/leads%20immo/Proposition_Projet_2582_Baldwin_Loua.pdf).
> Structure dérivée du [plan stratégique](../../../Downloads/leads%20immo/plan-strategique-agence-renovation.docx).

---

## Structure

```
maison-forge/
├── README.md                  # ce fichier
├── brand/
│   ├── tokens.css             # design tokens — cuivre/cream/anthracite
│   ├── brand-guidelines.md    # voix, typo, palette, do/don't
│   └── logo/
│       ├── maison-forge-wordmark.svg
│       └── maison-forge-favicon.svg
├── site/
│   ├── index.html             # landing 1 page longue
│   ├── demarche.html          # 4 phases détaillées + FAQ
│   ├── realisations.html      # cas Baldwin + placeholders
│   ├── lead.html              # wizard 12 étapes + estimation IA
│   ├── merci.html             # post-submit
│   ├── estimate-budget.js     # algorithme estimation client-side
│   ├── netlify.toml           # config deploy + redirects + headers
│   └── assets/
│       ├── maison-forge-wordmark.svg
│       └── maison-forge-favicon.svg
└── ai-functions/
    ├── generate-report.js     # Netlify Function → Claude API → compte-rendu Phase 1
    └── package.json           # @anthropic-ai/sdk
```

---

## Pages publiques

| Route | Fichier | Description |
|-------|---------|-------------|
| `/` | `index.html` | Landing : hero + 5 chiffres signature + 3 promesses + 4 phases + équipe + CTA |
| `/demarche` | `demarche.html` | Détail des 4 phases + 4 règles visite + FAQ accordéon |
| `/realisations` | `realisations.html` | Cas Baldwin (transformation duplex→triplex) + projets à venir |
| `/lead` | `lead.html` | Wizard 12 étapes Typeform-style avec progress bar, photo upload, estimation IA |
| `/merci` | `merci.html` | Post-submit : confirmation + 3 prochaines étapes |

---

## Le lead wizard — 12 étapes

| # | Étape | Type |
|---|-------|------|
| 01 | Type de projet | 6 choix |
| 02 | Surface approximative | 6 choix |
| 03 | Niveau de finition (essentiel/confort/premium) | 3 choix |
| 04 | Délai souhaité | 6 choix |
| 05 | Budget envisagé (slider 10-200 k$) + souplesse | slider + 3 choix |
| 06 | Occupation pendant travaux | 4 choix |
| 07 | Motivation projet (verbatim libre) | textarea |
| 08 | Adresse + quartier | 2 champs texte |
| 09 | Photos / plans (upload jusqu'à 6 fichiers) | drag & drop |
| 10 | Coordonnées (nom, email, téléphone) | 3 champs texte |
| 11 | Préférence canal contact + consentement Loi 25 | 4 choix + checkbox |
| 12 | Estimation budgétaire IA + récap + submit | calcul automatique |

**UX** :
- Progress bar en haut, stepper `N / 12`
- Auto-advance sur questions à choix unique
- Touche `Entrée` = avancer, `Esc` = quitter
- Animations Motion (fade + slide-in)
- Multi-step = 2-3× la conversion d'un long formulaire (vs ~7+ champs visibles en même temps)

## Estimation budget IA — `estimate-budget.js`

Heuristique calibrée marché Québec 2026 :

```
budget_estimé = base_type × surface × finition × délai × occupation
```

- **Bases prix** : cuisine 25-80 k$, SDB 12-38 k$, conversion locative 45-150 k$, etc.
- **Multiplicateurs surface** : ×0.65 (petite) à ×2.6 (multi-pièces)
- **Multiplicateurs finition** : ×0.70 (essentiel) à ×1.55 (premium)
- **Modificateur délai** : urgence ×1.12, long terme ×0.98
- **Modificateur occupation** : reste sur place ×1.08, vacant ×0.95

Largeur fourchette ajustée selon **incertitude** (réponses « incertain » / « exploration » → fourchette élargie).

Sortie : `{min, center, max, confidence_label, breakdown}` affiché en step 12.

Pour ajuster les coefficients, éditer [`estimate-budget.js`](site/estimate-budget.js).

## Compte-rendu IA Phase 1 — `ai-functions/generate-report.js`

Netlify Function qui appelle **Claude Sonnet 4.6** pour générer un compte-rendu personnalisé à partir des réponses du formulaire.

**Architecture** :
1. Lead soumis → Netlify Forms → notification email immédiate (récap brut)
2. Trigger function `generate-report` → Claude API → compte-rendu structuré 2-4 pages
3. Compte-rendu envoyé par email à l'équipe Maison Forge (à connecter à Resend ou Mailgun)

**Configuration env vars** (Netlify dashboard → Site → Environment variables) :
```
ANTHROPIC_API_KEY=sk-ant-...      # obligatoire pour génération IA
NOTIFY_EMAIL=contact@maisonforge.ca
RESEND_API_KEY=re_...             # optionnel, pour envoi email
```

**Sans clé API configurée** : la function génère un compte-rendu **template** (toujours fonctionnel, légèrement moins personnalisé). Aucun blocage.

## Déploiement Netlify

```bash
cd 24_NextMove/maison-forge/site
netlify sites:create --name maison-forge --account-slug w5d4whhp8j-source --disable-linking
netlify deploy --prod --dir=. --site=<SITE_ID>
```

`netlify.toml` configure automatiquement :
- Headers sécurité (X-Frame-Options, nosniff, Permissions-Policy)
- Cache : HTML revalidate, assets immutable 1 an
- Friendly URLs : `/demarche`, `/realisations`, `/lead`, `/merci`
- Functions dir : `../ai-functions/`

## Stockage des leads

**Option 1 (MVP par défaut)** : Netlify Forms
- Auto-activé via `data-netlify="true"` sur le `<form>`
- Submissions visibles dans Netlify dashboard > Forms
- Email notifications configurables (Settings > Notifications)
- Gratuit jusqu'à 100 submissions/mois

**Option 2 (recommandé production)** : webhook Notion / Airtable
- Configurer dans Netlify dashboard > Forms > Notifications > Outgoing webhook
- Mapper champs JSON → base Notion ou Airtable
- ~30 min setup

**Option 3 (avancé)** : Resend + n8n
- Forms → Netlify Function → Resend (email transactionnel) + n8n (orchestration)
- Idéal si Maison Forge scale au-delà de 50 leads/mois

## Tech stack

| Couche | Choix | Pourquoi |
|--------|-------|----------|
| HTML/CSS | Vanilla, OKLCH-friendly hex | Aucun build, déployable direct, longue durée |
| JS interactif | Vanilla + [Motion](https://motion.dev) ESM CDN | Pas de framework, < 30 KB total |
| Forms | Netlify Forms | Zero-config, gratuit MVP |
| AI | Claude Sonnet 4.6 via Netlify Function | Coût ~0.01 $ par lead, qualité éditoriale |
| Hosting | Netlify | Free tier suffit pour MVP |

## Coûts estimés

| Volume mensuel | Total /mois |
|----------------|-------------|
| 0-100 leads | **0 $** (Netlify Free) |
| 100-500 leads | ~5-15 $ (Claude API) |
| 500+ leads | ~30-80 $ + plan Netlify Pro éventuel |

## Personnalisation

| Pour changer | Éditer |
|--------------|--------|
| Couleurs | [`brand/tokens.css`](brand/tokens.css) → variables `--copper`, `--bg`, etc. |
| Polices | [`brand/tokens.css`](brand/tokens.css) → `--font-serif`, `--font-sans` |
| Coefficients estimation budget | [`site/estimate-budget.js`](site/estimate-budget.js) |
| Voix compte-rendu IA | [`ai-functions/generate-report.js`](ai-functions/generate-report.js) → constante `SYSTEM_PROMPT` |
| Questions du wizard | [`site/lead.html`](site/lead.html) → sections `<section class="step">` |
| Copy landing | [`site/index.html`](site/index.html) → directement dans le HTML |

## Brand identité

Voir [`brand/brand-guidelines.md`](brand/brand-guidelines.md) pour la doc complète.

**Palette principale** :
- Cuivre `#B86A2E` (signature)
- Cream `#F0EBE0` (background)
- Anthracite `#243845` (texte)

**Typographie** :
- Serif italique : **Cormorant Garamond** (titres, numérotation)
- Sans : **Inter** (body, navigation)

**Logo** : wordmark + trait cuivre court (pas d'icône).

## Crédits

Design extrait de la proposition projet Baldwin/Loua. Méthodologie 4 phases issue du plan stratégique. Construit le **2026-04-29**.

## Prochaines étapes recommandées

1. Connecter clé Anthropic dans Netlify env vars
2. Configurer notification email Netlify Forms
3. Brancher webhook Notion ou Airtable pour CRM léger
4. Remplacer placeholders photos par vraies photos chantier Baldwin (HEIC du dossier `leads immo/`)
5. Acheter domaine `maisonforge.ca` + connecter à Netlify
6. Configurer Google Search Console + Plausible/Umami pour analytics

# Klaris Web

Mirror web (read-write) du dashboard iOS Klaris. Next.js 15 (App Router) + Supabase + Tailwind. Conçu pour Vercel.

## Setup

```bash
cd klaris_web
cp .env.local.example .env.local
# Editer NEXT_PUBLIC_SUPABASE_URL + NEXT_PUBLIC_SUPABASE_ANON_KEY
#  (mêmes valeurs que klaris_ios/lib/core/env.dart — projet Supabase partagé)
npm install
npm run dev
# → http://localhost:3000
```

## Déploiement Vercel

```bash
# Une seule fois
npx vercel link

# Push :
git push origin main   # auto-deploy via Vercel git integration
# ou
npx vercel --prod
```

Variables d'env à configurer dans le dashboard Vercel (Project → Settings → Environment Variables) :

| Variable | Type | Valeur |
|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | Plain | `https://xxx.supabase.co` |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Encrypted | clé anon |
| `NEXT_PUBLIC_APP_VERSION` | Plain | `0.1.0` (ou via `npm version`) |

## Architecture

- **Auth** : `@supabase/ssr` — middleware refresh des cookies à chaque requête, RLS appliqué côté Postgres
- **Routing** : App Router avec `[id]` dynamic segments + `typedRoutes`
- **Data** : direct Supabase client SSR (pas d'API REST intermédiaire — RLS suffit)
- **Reco IA** : appelle l'edge function `recommend-listings` partagée avec iOS — même cache 24h, même prompts Claude Haiku
- **Design tokens** : OKLCH dans `globals.css`, exposés à Tailwind via `tailwind.config.ts`

## Pages

| Route | Auth | Contenu |
|---|---|---|
| `/login` | Public | Email + password Supabase |
| `/` | Protégée | Liste prospects (heat-coded) |
| `/prospects/[id]` | Protégée | Détail prospect + recommandations IA |

## Parité avec iOS

| iOS (`klaris_ios/`) | Web (`klaris_web/`) | Statut |
|---|---|---|
| Login Cupertino | `/login` | Email/pwd uniquement (pas Apple sign-in encore) |
| Dashboard prospects | `/` | Read-only liste, filtres à venir |
| Détail + reco IA | `/prospects/[id]` | Lecture seule au launch |
| Calendrier | — | Sprint 8 |
| Threads SMS | — | Sprint 8 |
| Settings + opt-out Loi 25 | — | Sprint 8 |

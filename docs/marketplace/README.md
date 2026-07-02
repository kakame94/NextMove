# Marketplace de leads — MVP (Échiquier B)

Surface distincte du dashboard : le courtier débloque **ses propres** leads dormants,
requalifiés par l'assistante Klaris, avec leur consentement de mise en relation.
Pas de revente à un tiers → finalité `broker_match`, couverte par le consentement initial.

## Pièces

| Fichier | Rôle |
|---|---|
| [`010_marketplace.sql`](../../010_marketplace.sql) | Tables + RLS + RPC. Projection **sans PII**. |
| `klaris_web/src/app/marketplace/page.tsx` | Feed des leads anonymisés, triés par chaleur×fraîcheur. |
| `klaris_web/src/app/marketplace/actions.ts` | Server action → RPC `reveal_lead`. |
| `klaris_web/src/components/MarketplaceCard.tsx` | Carte + déblocage. |
| `adjointe_systeme.md` | Opt-in SMS `consentement_mise_en_relation`. |

## Modèle de sécurité (leçons incident 009)

- `marketplace_listings` **ne contient aucune PII** (nom/tel/email restent dans `prospects`).
- La PII n'est renvoyée que par `reveal_lead()` — SECURITY DEFINER, `search_path=''`, scoping `courtier_id = auth.uid()` — **après** paiement + vérif consentement, dans **une transaction atomique** (débit wallet + insert reveal + flip statut).
- RLS `force` partout, `anon` révoqué, `authenticated` = SELECT seulement (écritures via fonctions).
- Recharge wallet = `credit_wallet()` **service_role uniquement** (webhook Stripe). Aucun self-credit.
- Un lead se débloque **une seule fois** (`lead_reveals.listing_id UNIQUE`) ; re-consultation gratuite (idempotent).

## Tarifs (financement déclaré, net-commission-honnête QC)

| Bande | Financement déclaré | Prix |
|---|---|---|
| Non vérifié | — | 39 $ |
| Argent | < 600k | 49 $ |
| Or | 600–900k | 89 $ |
| Platine | 900k+ | 149 $ |

`+50 %` si `score_chaleur ≥ 8`. Garantie : remboursé si injoignable après 3 tentatives / 5 jours (à câbler via cron n8n sur `lead_reveals.contact_attempts`/`outcome`).

## Déploiement

1. **Prérequis** : le durcissement sécurité (PR #25) appliqué, `auth.uid() = courtiers.id` (runbook step 1bis).
2. Appliquer `010_marketplace.sql` (SQL editor, service_role).
3. Peupler : `select publish_dormant_leads('<courtier_uuid>', 20);` (cron n8n ensuite).
4. Créditer un wallet de test : `select credit_wallet('<courtier_uuid>', 20000);` (200 $).
5. `klaris_web` : la route `/marketplace` est protégée par le middleware existant. Déployer (Vercel).
6. Brancher Stripe Checkout → webhook appelant `credit_wallet` (phase suivante).

## Reste à faire

- Wallet Stripe (recharge réelle) + webhook idempotent.
- Cron garantie joignabilité (`contact_attempts` → refund auto via `credit_wallet` reason `refund`).
- Verbatim scrubé (extrait SMS sans PII) injecté par `publish_dormant_leads`.
- Intro chaude orchestrée au reveal (SMS auto au prospect) — anti-désintermédiation.

# Klaris — Brand Guidelines

> Brand identity for Klaris, the AI assistant for real estate brokers.
> One source of truth — all marketing, product, sales materials follow this.
> Version 1.0 — 2026-04-29

---

## 1. Mission

**Free brokers from admin so they can do what they love: visit, negotiate, sell.**

Klaris is the AI sidekick that fields prospect SMS, qualifies leads, scores them, and hands the broker a clean dashboard. The broker keeps every relationship — Klaris just clears the runway.

## 2. Positioning

**One line:**
> *« L'adjointe IA des courtiers immo. Elle qualifie tes prospects par SMS, pendant que tu vends. »*
> *(EN) The AI assistant for real estate brokers. She qualifies your prospects via SMS, while you sell.*

**Three pillars:**
1. **24/7 availability** — never sick, never on leave (broker's words)
2. **Bilingual FR/EN by default** — non-negotiable for QC market
3. **Human-in-the-loop, OACIQ-compliant** — every action traceable, reversible, signed off

**What Klaris is NOT:**
- Not a replacement for the broker — it positions Joanel (or whoever) as the human taking over
- Not a generic CRM — it's vertical-specific, built from broker interviews
- Not a black-box AI — every conversation logged, every score explainable

## 3. Audience

| Persona | Use them for |
|---------|--------------|
| **Joanel** (solo high-performer) | Hero stories, before/after time-saved metrics |
| **Maxime** (growth-focused) | Scaling narrative, "go from 3 to 10 transactions/month" |
| **Charlyse** (perfectionist, FR/EN) | Reliability + bilingual messaging, no-sloppy promise |
| **JP** (franchise + skeptical) | Compliance-first messaging, OACIQ traceability |

**Geographic priority:** Quebec-first (OACIQ + Loi 25 + CASL native), France-secondary (vocabulary adjusted: « commission » vs « rémunération », etc.).

## 4. Voice & Tone

**Voice attributes** (always):
- **Warm** — exclamations OK, friendly, never robotic
- **Direct** — short sentences, one idea per message
- **Confident** — we know the broker's day, we don't pitch generic AI
- **Quebecois-natural** — no rigid vouvoiement when not needed (in product). Marketing FR can use vous when addressing strangers.

**Signature line in product:**
> *« Je suis son assistante. »* — never say "Je suis Klaris, l'IA de NextMove". Klaris positions herself as Joanel's assistant.

**Do**
- "Klaris qualifie tes prospects pendant que tu visites."
- "Tu reprends la main quand tu veux. Tout est tracé."
- "Bilingue FR/EN, sans frais supplémentaires."

**Don't**
- ~~"Notre solution révolutionnaire d'intelligence artificielle générative..."~~ (corporate jargon)
- ~~"Boost your KPIs with our AI-powered SaaS"~~ (anglicisms, buzzwords)
- ~~"L'IA fait tout à votre place"~~ (over-promise — JP fears = lost OACIQ license)

## 5. Logo

**Concept** — The « C » of Klaris drawn as a curved SMS conversation bubble that loops back into a cocoon. The bubble = the chatbot. The cocoon = the assistant who shelters the broker's workflow.

**Variants** (in [`logo/`](logo/)):
| File | Use |
|------|-----|
| `clea-primary.svg` | Default. Horizontal logo + wordmark. Use everywhere there's room. |
| `clea-stacked.svg` | Vertical layout. Use for square avatars, business cards, app splash. |
| `clea-submark.svg` | C monogram only. Use ≥ 32px when wordmark won't fit. |
| `clea-favicon.svg` | Simplified C, optimized for 16-32px rendering. |
| `clea-mono-light.svg` | Single-color (foreground), use on light photo bg or print. |
| `clea-mono-dark.svg` | Single-color (white), use on primary or dark bg. |

**Clear space:** minimum half the height of the C around all sides.
**Minimum size:** 24px tall (primary), 16px (favicon).

**Don't:**
- Don't recolor outside the palette (no green Klaris, no rainbow)
- Don't stretch / squish (preserve aspect ratio)
- Don't add effects (no drop shadows, no gradients beyond the prescribed primary)
- Don't place the wordmark on busy photo backgrounds — use mono-dark over a 60% scrim instead

## 6. Color

See [colors.md](colors.md) for full palette + usage + accessibility ratios.

**Primary palette (memorize these 3):**
- **Terracotta** `oklch(0.55 0.18 30)` — primary. CTAs, brand accents, active states.
- **Off-white** `oklch(0.98 0.005 60)` — background. Always primary surface.
- **Near-black** `oklch(0.20 0.02 30)` — text + dark surfaces.

## 7. Typography

See [typography.md](typography.md).

- **Display + body:** Geist (Vercel, free, Google Fonts)
- **Mono:** Geist Mono (data, SMS extracts, code)
- **Fallback:** Inter, then system sans

## 8. Iconography

Stroke icons, 2px weight, rounded line caps. Built on a 24×24 grid. See [graphic-elements/icon-set.svg](graphic-elements/icon-set.svg).

Default icon library: **Lucide** (matches dashboard's existing icons). Custom icons (chatbot bubble, heat dial, SMS qualif) drawn in same style.

## 9. Photography & Illustration

**Photography:** When real photos are used (testimonials, team), warm tone, natural light, not stock-cliché. Avoid handshake-over-house photos.

**Illustration:** Geometric, soft, monochrome with primary accents. See [graphic-elements/illustration-hero.svg](graphic-elements/illustration-hero.svg) as reference style.

**Pattern:** Subtle grid background available in [graphic-elements/pattern-grid.svg](graphic-elements/pattern-grid.svg) for hero backgrounds. Opacity max 0.06 on light, 0.10 on dark.

## 10. Layout principles

- **8px grid** — everything aligns to multiples of 8 (4 for fine adjustments)
- **Generous whitespace** — content over decoration
- **One CTA per section** — never compete with self
- **Mobile-first** — 60%+ of broker traffic is mobile (interview data)
- **Card-based** — content groups in soft cards (radius 0.5–1rem, subtle border, no heavy shadows)

## 11. Naming & language

- **Product name:** Klaris (always with the accent, capital C)
- **Parent company:** Next Move (two words, capitalized)
- **Avoid:** "Klaris AI", "Klaris.ai", "the Klaris app" — just "Klaris"
- **Brokers in QC:** "courtiers immobiliers" (not "agents", which has different OACIQ meaning)
- **Brokers in EN:** "real estate brokers" (not "real estate agents")

## 12. Compliance touchpoints

Every customer-facing message must, where applicable, reference:
- **Loi 25** (QC personal data)
- **CASL** (Canadian anti-spam)
- **OACIQ** (broker oversight body)

Compliance is a **selling point**, not legal fine print. JP-persona buys on trust before features.

## 13. File naming

```
clea-{variant}.{ext}                      → logo
landing-{lang}.html                       → web pages
deck-{lang}.html                          → pitch deck
{NN}-{topic}-{lang}.svg                   → social posts (NN = 01-10)
banner-{network}-{WxH}.svg                → social banners
```

## 14. What lives where

| Need this | Look in |
|-----------|---------|
| Tokens (CSS custom props) | [tokens.css](tokens.css) |
| Color hex/oklch reference | [colors.md](colors.md) |
| Type scale + fallbacks | [typography.md](typography.md) |
| Logo SVGs | [logo/](logo/) |
| Icons + illustrations | [graphic-elements/](graphic-elements/) |
| Landing page (FR/EN) | [../web-design/](../web-design/) |
| Pitch deck | [../pitch-deck/](../pitch-deck/) |
| Social posts | [../social-media/](../social-media/) |

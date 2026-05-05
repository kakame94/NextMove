# Cléa — Design Package

> Complete brand identity, marketing site, pitch deck, and social media kit for Cléa — the AI assistant for real estate brokers.
> A Next Move product. Quebec-first, FR/EN bilingual.

---

## What's in this package

Replaces the **7 800 €** designer quote (Brand On Fire + Web Design + Social Media Pack + Pitch Deck). Built directly from the user research and dashboard design system already in this repo.

### 1. Brand Identity — [`brand-identity/`](brand-identity/)

| File | Purpose |
|------|---------|
| [`brand-guidelines.md`](brand-identity/brand-guidelines.md) | Mission, voice, do/don'ts, file naming |
| [`tokens.css`](brand-identity/tokens.css) | CSS custom properties (OKLCH palette, Geist typography, spacing, radius) — shared with the dashboard |
| [`colors.md`](brand-identity/colors.md) | Full palette + hex equivalents + WCAG accessibility ratios |
| [`typography.md`](brand-identity/typography.md) | Geist scale, weights, recipes, fallbacks |
| [`logo/clea-primary.svg`](brand-identity/logo/clea-primary.svg) | Horizontal logo + wordmark |
| [`logo/clea-stacked.svg`](brand-identity/logo/clea-stacked.svg) | Vertical layout (avatars, splash) |
| [`logo/clea-submark.svg`](brand-identity/logo/clea-submark.svg) | C monogram only |
| [`logo/clea-favicon.svg`](brand-identity/logo/clea-favicon.svg) | Simplified for 16-32px |
| [`logo/clea-mono-light.svg`](brand-identity/logo/clea-mono-light.svg) | Single color for light backgrounds |
| [`logo/clea-mono-dark.svg`](brand-identity/logo/clea-mono-dark.svg) | Single color for dark/colored backgrounds |
| [`graphic-elements/icon-set.svg`](brand-identity/graphic-elements/icon-set.svg) | 6 custom icons (chatbot, scoring, follow-up, FR/EN, compliance, dashboard) |
| [`graphic-elements/illustration-hero.svg`](brand-identity/graphic-elements/illustration-hero.svg) | SMS thread → Cléa → dashboard hero illustration |
| [`graphic-elements/pattern-grid.svg`](brand-identity/graphic-elements/pattern-grid.svg) | Subtle dot + bubble pattern for backgrounds |

### 2. Web Design — [`web-design/`](web-design/)

| File | Purpose |
|------|---------|
| [`landing-fr.html`](web-design/landing-fr.html) | Production-ready single-file landing page (FR), with [Motion](https://motion.dev) animations |
| [`landing-en.html`](web-design/landing-en.html) | English variant |
| [`spec.md`](web-design/spec.md) | Architecture, copy FR/EN, components, interactions, performance budget |
| [`wireframes.md`](web-design/wireframes.md) | ASCII low-fi wireframes per section |
| [`mockups/README.md`](web-design/mockups/README.md) | Chrome headless / Puppeteer commands to regenerate PNG mockups |

### 3. Pitch Deck — [`pitch-deck/`](pitch-deck/)

| File | Purpose |
|------|---------|
| [`deck-fr.html`](pitch-deck/deck-fr.html) | 12-slide deck (FR), keyboard navigation, print-to-PDF support |
| [`deck-en.html`](pitch-deck/deck-en.html) | English variant |
| [`content.md`](pitch-deck/content.md) | All slide copy, FR/EN side-by-side |
| [`speaker-notes.md`](pitch-deck/speaker-notes.md) | Slide-by-slide spoken script, anticipated Q&A |

### 4. Social Media — [`social-media/`](social-media/)

| File | Purpose |
|------|---------|
| [`profile-1080.svg`](social-media/profile-1080.svg) | Profile picture (LinkedIn, IG, FB, X) |
| [`banner-linkedin-1584x396.svg`](social-media/banner-linkedin-1584x396.svg) | LinkedIn cover |
| [`banner-instagram-1500x500.svg`](social-media/banner-instagram-1500x500.svg) | IG / X header |
| [`banner-facebook-820x312.svg`](social-media/banner-facebook-820x312.svg) | Facebook cover |
| [`posts/01-10 × FR/EN`](social-media/posts/) | 20 launch posts: announce, pain, solution, scoring, bilingual, compliance, testimonial, process, before/after, CTA |
| [`README.md`](social-media/README.md) | Network specs, export-to-PNG commands, posting cadence |

---

## Design principles

1. **Coherence with the product.** Same OKLCH palette, same Geist typography, same radius/spacing as the dashboard ([`/index.html`](../../index.html)). A visitor sees the same brand from landing → dashboard.
2. **Quebec-first.** OACIQ, Loi 25, CASL referenced as selling points. Bilingual FR/EN baked in. Tone calibrated on real Quebecois broker interviews.
3. **Personas-driven.** Every section maps back to one of the 4 validated personas (Joanel, Maxime, Charlyse, JP) and the 12 transverse patterns from [`personas-insights-figma.md`](../docs/personas-insights-figma.md).
4. **No build step.** Every HTML file is self-contained, vanilla. Open in a browser. Edit in any text editor. Deploy to any static host.

## Quick start

### Local preview
```bash
cd 24_NextMove/clea-brand
python3 -m http.server 8000
```
- Landing: http://localhost:8000/web-design/landing-fr.html
- Deck: http://localhost:8000/pitch-deck/deck-fr.html

### Generate PNG mockups
See [`web-design/mockups/README.md`](web-design/mockups/README.md).

### Export social posts to PNG
```bash
cd social-media
brew install librsvg
for f in posts/*.svg; do rsvg-convert -w 1080 -h 1080 "$f" -o "${f%.svg}.png"; done
```

## File counts

| Category | Files |
|----------|-------|
| Brand identity (docs + SVGs) | 11 |
| Web design (HTML + specs) | 5 |
| Pitch deck (HTML + docs) | 4 |
| Social media (SVGs + docs) | 25 (1 profile + 4 banners + 20 posts) |
| **Total** | **45** |

## Animation library

Marketing pages and the deck use **[Motion](https://motion.dev)** — the vanilla-JS library by the framer-motion team. Imported as ESM from CDN, no build step required. Same animation API as framer-motion. Respects `prefers-reduced-motion`.

## Compatibility

- **Modern browsers only** — uses OKLCH, `color-mix()`, ESM imports, `backdrop-filter`. Chrome 111+, Safari 15.4+, Firefox 113+.
- **Older browsers gracefully degrade** — colors look slightly desaturated but still readable. No layout breaks.

## Editing

- **Logos / posts (SVG):** open in any text editor, Figma, Inkscape, or Canva.
- **Landing pages / deck (HTML):** open in any text editor. CSS is inlined per file. Tokens reference `tokens.css` patterns but each page is independently editable.
- **Color rebrand:** find/replace `oklch(0.55 0.18 30)` globally → done.
- **Logo recolor in mono variants:** wrap parent in any element with `color: <new>` — `currentColor` cascades.

## Credit

Brand and design system extracted from existing dashboard work in this repo. Personas + voice from [JTBD interviews March 2026](../../atelier_resultats/). SMS template tone matches [`templates-sms-figma-extraits.md`](../docs/templates-sms-figma-extraits.md) (single source of truth from Figma node 62:2). Compliance language matches [`business-constraints-checklist.md`](../docs/business-constraints-checklist.md).

Built directly into the repo on **2026-04-29**.

# Cléa — Landing Page Specification

> Architecture, copy, components, interactions for the Cléa marketing site.
> Files: [landing-fr.html](landing-fr.html), [landing-en.html](landing-en.html).
> Both are single-file (HTML + inline CSS + ESM script). Vanilla. No build step.

---

## 1. Sitemap

Single-page (one long scroll), divided into 9 sections:

```
/landing-{lang}.html
├── nav (sticky, blurred)
├── #hero            — headline + visual
├── pain             — 3 pain stats
├── #how             — 3-step explainer
├── #features        — 4 feature cards
├── demo             — SMS thread + selling points
├── testimonial      — Joanel quote
├── compliance       — OACIQ + Law 25 + CASL
├── #pricing         — Solo + Agency tiers
├── #cta             — final CTA panel
└── footer           — 4-column links + lang switcher
```

Anchors (`#how`, `#features`, etc.) target nav-bar links and on-page CTAs. `scroll-behavior: smooth` is set on `html`.

## 2. Component inventory

| Component | Used in | Key tokens |
|-----------|---------|-----------|
| Sticky nav (blurred) | Header | `backdrop-filter: blur(12px)`, border-bottom |
| Pill eyebrow | Hero, sections, badges | `--primary-soft` bg, primary text |
| Primary button (`.btn-primary`) | All CTAs | `--primary` bg, hover translateY(-1px) |
| Ghost button (`.btn-ghost`) | Secondary CTAs | `--card` bg, `--border` |
| Stat card (`.pain-card`) | Pain section | Top-border `--destructive` |
| Numbered step (`.how-step`) | How section | Numbered circle on connector line |
| Feature card (`.feat-card`) | Features section | Icon + heading + body |
| SMS phone mock (`.demo-phone`) | Demo section | Rounded mini-phone with thread |
| Compliance card (`.comp-card`) | Compliance section | Success-soft icon background |
| Pricing card (`.price-card`) | Pricing section | Two tiers, one featured |
| Final CTA panel (`.final-cta`) | CTA section | `--primary` background block |
| Footer | Bottom | 4-column grid + lang switcher |

All cards use `border-radius: var(--radius)` (12px) and `border: 1px solid var(--border)` for cohesion with dashboard.

## 3. Copy (FR / EN side-by-side)

### Hero
| FR | EN |
|----|-----|
| **Eyebrow:** Lancement Q2 2026 · Beta accessible | Q2 2026 launch · Beta open |
| **H1:** L'**adjointe IA** des courtiers immo. Elle qualifie. Toi, tu vends. | The **AI assistant** for real estate brokers. She qualifies. You sell. |
| **Sub:** Cléa répond à tes prospects par SMS, recueille leurs besoins, les classe par température dans ton dashboard. Tu reprends la main quand le lead est mûr. | Cléa replies to your prospects via SMS, gathers their needs, and ranks them by temperature in your dashboard. You take over when the lead is ready. |
| **CTA primary:** Réserver une démo gratuite | Book a free demo |
| **CTA secondary:** Voir comment ça marche → | See how it works → |
| **Trust:** Conforme OACIQ + Loi 25 + CASL · Bilingue FR/EN dès le départ · Tu signes chaque action | OACIQ + Law 25 + CASL compliant · Bilingual EN/FR from day one · You sign every action |

### Pain
| FR | EN |
|----|-----|
| **Eyebrow:** Le problème | The problem |
| **H2:** L'admin tue tes ventes. Cléa s'en occupe. | Admin kills your sales. Cléa handles it. |
| **Sub:** Issu de 4 entretiens approfondis avec des courtiers terrain. Les douleurs sont les mêmes partout. | From in-depth interviews with field brokers. The pain points are universal. |
| **Stat 1:** 30-60 min — par offre d'achat rédigée à la main | 30-60 min — per offer drafted by hand |
| **Stat 2:** > 24h — délai moyen de réponse aux nouveaux leads | > 24h — average response time on new leads |
| **Stat 3:** 2 / 10 — courtiers qui adoptent le CRM franchise | 2 / 10 — brokers actually using the franchise CRM |

### How
| FR | EN |
|----|-----|
| **H2:** SMS arrive. Cléa qualifie. Tu fermes. | SMS comes in. Cléa qualifies. You close. |
| **Step 1:** Le prospect texte ton numéro | Prospect texts your number |
| **Step 2:** Cléa pose les bonnes questions | Cléa asks the right questions |
| **Step 3:** Tu vois le lead chaud dans ton dashboard | Hot lead in your dashboard |

### Features
| FR | EN |
|----|-----|
| Chatbot SMS de qualification | SMS qualification chatbot |
| CRM avec scoring de température | CRM with temperature scoring |
| Relances automatiques, encadrées | Smart auto follow-ups |
| Bilingue FR/EN — détection auto | Bilingual EN/FR — auto-detect |

### Testimonial
| FR | EN |
|----|-----|
| « *Une IA qui génère une offre d'achat en un rien de temps.* Pendant que je suis en visite, Cléa parle à mes prospects et me sort une fiche prête. Avant, je rentrais au bureau et je perdais 30-60 minutes par offre. Là, c'est secondes. » | « *An AI that drafts an offer in seconds.* While I'm out showing, Cléa talks to my prospects and hands me a clean record. I used to lose 30-60 minutes per offer at the office. Now it's seconds. » |

### Pricing
| FR | EN |
|----|-----|
| **Solo:** 100$ CAD / mois | **Solo:** $100 CAD / month |
| **Agence:** 200$ CAD / courtier / mois | **Agency:** $200 CAD / broker / month |

## 4. Interactions

### Theme toggle
- Stored in `localStorage` under `clea-theme`
- Defaults to `prefers-color-scheme` system value
- Sun/moon icon swap via CSS based on `html.dark` class

### Motion (scroll-triggered animations)
Powered by **[motion.dev](https://motion.dev)** — vanilla-JS equivalent of framer-motion (same team). Imported as ESM from CDN.

| Selector | Animation | Trigger |
|----------|-----------|---------|
| `[data-motion]` (cards) | fade + slide-up 24px → 0 | enter viewport (20% visible) |
| `[data-motion]` (grid groups: pain/how/feat/comp/pricing) | staggered fade + slide-up | parent enters viewport, items animate sequentially (80ms apart) |
| `[data-motion-x]` | fade + slide-from-left 24px → 0 | enter viewport |
| `[data-motion-scale]` (hero, demo phone, featured price, final CTA) | fade + scale 0.96 → 1 | enter viewport |
| `.btn-primary:hover` | scale 1 → 1.04 spring | hover |
| `.feat-card:hover` | translateY(-4px) + shadow + border-color | hover (CSS only) |
| `.pain-card:hover` / `.price-card:hover` | translateY(-2px) | hover (CSS only) |
| `.how-step:hover .how-num` | scale 1.06 + glow | hover (CSS only) |
| `.hero-eyebrow::before` (live dot) | pulse 0→1 opacity infinite | always (CSS keyframe) |

**Reduced motion:** if `prefers-reduced-motion: reduce`, the inline animation script is skipped and elements appear in their final state via CSS fallback. Hover effects remain (subtle, non-essential).

**Easing:** custom cubic `[0.16, 1, 0.3, 1]` (smooth-out, soft landing) consistently across all entrance animations.

### Navigation
- Desktop: full nav links visible
- Mobile (≤768px): nav links hidden, only logo + CTA + theme toggle remain

### Smooth scroll
`html { scroll-behavior: smooth }` — anchor links scroll smoothly to targets.

## 5. Responsive breakpoints

| Width | Behavior |
|-------|----------|
| ≥ 901px | Full hero grid (text + visual side-by-side), 3-col pain, 4-col features (2×2), 3-col compliance |
| 769-900px | Hero collapses to single column, demo grid collapses to single column |
| ≤ 768px | All grids collapse to single column. Nav-links hidden. Compliance container padding reduced. |

## 6. Performance

| Metric | Target | Achieved |
|--------|--------|----------|
| Lighthouse Performance | 95+ | TBD (run after deploy) |
| LCP | < 2s | Hero illustration is inline SVG, no image load |
| CLS | < 0.1 | All sections have explicit dimensions |
| FCP | < 1s | Single HTML, fonts preconnected, Motion lazy-imports on scroll |
| Total page weight | < 100 KB | HTML ~22 KB, fonts cached, Motion ~12 KB gzipped from CDN |

**Optimizations applied:**
- Fonts preconnected to `fonts.googleapis.com` and `fonts.gstatic.com`
- All visuals are inline SVG (zero image requests)
- CSS inlined (zero external stylesheet requests)
- Motion library lazy-imported as ESM from `cdn.jsdelivr.net` (deferred via `type="module"`)
- No tracking, no analytics, no third-party fonts beyond Geist

## 7. Browser support

- **Target:** evergreen browsers (last 2 versions of Chrome, Edge, Firefox, Safari, mobile equivalents)
- **OKLCH color space:** supported in all modern browsers (Chrome 111+, Safari 15.4+, Firefox 113+). Older browsers gracefully degrade to system color rendering — colors will look slightly desaturated but still readable.
- **Motion library:** ESM module imports require modern browser support, which aligns with target.
- **`color-mix()`:** used in nav transparency. Modern-only. Fallback handled gracefully (solid background).

## 8. Accessibility

- All interactive elements have `aria-label` (theme toggle) or sufficient text content
- Heading hierarchy: H1 (hero) → H2 (sections) → H3 (cards). No skipped levels.
- Focus states: native browser outline preserved; not removed
- Color contrast: all foreground/background combinations meet WCAG AA (see [colors.md](../brand-identity/colors.md))
- Reduced motion: respected via `@media (prefers-reduced-motion: reduce)`
- Reading order: matches visual order (no `order` overrides that break it)

## 9. Bilingual considerations

- French copy ~15-20% longer than English. Hero CTAs and stat labels reserve breathing room.
- Both files are independent — no shared template. Edits to copy must be made in both.
- The `<html lang="fr">` / `<html lang="en">` attribute is set per file for screen readers and search engines.
- Link to the other language exists in (a) nav and (b) footer language switcher. Active language is highlighted via `.active` class.

## 10. Deployment

The pages are static HTML — deploy to any host (Cloudflare Pages, Netlify, Vercel, GitHub Pages, S3 + CloudFront, etc.).

```bash
# Local preview (no build needed)
cd 24_NextMove/clea-brand/web-design
python3 -m http.server 8000
# Open http://localhost:8000/landing-fr.html
```

For production:
- Set canonical: `<link rel="canonical" href="https://clea.app/fr">` (add when domain set)
- Set hreflang: `<link rel="alternate" hreflang="en" href="https://clea.app/en">`
- Add Open Graph + Twitter Card meta (currently missing — to add at deploy time)
- Add favicon link is already in place pointing to `../brand-identity/logo/clea-favicon.svg`

## 11. Out of scope (for now)

- Form submission backend (CTAs use `mailto:` for MVP — replace with form-to-CRM hookup when CRM live)
- Analytics (deliberately none — add at deploy time per privacy stance)
- Cookie banner (no tracking yet, none needed)
- Localized URLs (`/fr` `/en` route prefixes — handle at hosting/CDN level)
- Blog / case studies (out of scope for launch)

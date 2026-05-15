# Cléa — Typography System

> Single typeface across product + marketing for cohesion: **Geist** (display + body) and **Geist Mono** (data, code, SMS extracts).
> Source: Google Fonts (free, open-source by Vercel).

---

## Type stack

```css
--font-sans: 'Geist', 'Inter', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
--font-mono: 'Geist Mono', 'JetBrains Mono', ui-monospace, SFMono-Regular, monospace;
```

**Loading (HTML head):**
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@400;500;600;700&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
```

## Weights used

| Weight | Token | Use |
|--------|-------|-----|
| 400 | regular | Body text, descriptions |
| 500 | medium | Buttons, table cells, labels, nav |
| 600 | semibold | Headings, card titles |
| 700 | bold | Display H1, hero headlines, key stats |

Don't use 300 (light) or 800/900 (extra-bold). Off-brand for Cléa's warm/professional balance.

## Scale

| Token | Size | px | Line-height | Use |
|-------|------|----|----|-----|
| `--fs-xs` | 0.75rem | 12 | 1.4 | Captions, labels, helper text |
| `--fs-sm` | 0.875rem | 14 | 1.5 | Body default (dashboard, inputs) |
| `--fs-base` | 1rem | 16 | 1.55 | Body for landing/marketing |
| `--fs-lg` | 1.125rem | 18 | 1.5 | Card titles, large body |
| `--fs-xl` | 1.25rem | 20 | 1.4 | Sub-headings (H3) |
| `--fs-2xl` | 1.5rem | 24 | 1.3 | H2, dashboard H1, feature titles |
| `--fs-3xl` | 2rem | 32 | 1.25 | Pitch deck H1, section headers |
| `--fs-4xl` | 3rem | 48 | 1.15 | Landing H1 |
| `--fs-5xl` | 4rem | 64 | 1.1 | Hero display (landing tablet+) |

## Heading recipes

```css
h1.hero {
  font-family: var(--font-sans);
  font-size: clamp(2rem, 5vw, 4rem);  /* 32 → 64 */
  font-weight: 700;
  line-height: 1.1;
  letter-spacing: -0.02em;
}

h1.section {
  font-size: var(--fs-3xl);   /* 32 */
  font-weight: 600;
  line-height: 1.2;
  letter-spacing: -0.015em;
}

h2 {
  font-size: var(--fs-2xl);   /* 24 */
  font-weight: 600;
  line-height: 1.3;
}

h3 {
  font-size: var(--fs-xl);    /* 20 */
  font-weight: 600;
  line-height: 1.4;
}

p, body {
  font-size: var(--fs-sm);    /* 14 product, 16 marketing */
  font-weight: 400;
  line-height: 1.5;
}

.label {
  font-size: var(--fs-xs);    /* 12 */
  font-weight: 500;
  letter-spacing: 0.02em;
  text-transform: uppercase;
}
```

## Letter-spacing (tracking)

| Use | Tracking |
|-----|----------|
| Display H1 (large headings) | `-0.02em` (tighter, modern feel) |
| H2 / H3 | `-0.01em` |
| Body | `0` (default) |
| Labels / uppercase / small caps | `0.02em` (slightly looser) |
| Buttons | `0` to `0.01em` |

## Mono usage

Geist Mono for:
- SMS message extracts in marketing (mock conversations)
- Data values (timestamps, IDs, phone numbers)
- Code samples, API references
- Status indicators (`.mono` class)

Don't use Mono for paragraphs or headings.

## Fallback strategy

If Geist fails to load (rare), the cascade falls to **Inter** (also Google Fonts, similar geometric feel), then system sans (`-apple-system`, etc.). Difference is imperceptible at body sizes; minor at large display sizes.

For embedded contexts (PDF, email signatures, print) where Geist isn't available:
- **PDF / print:** use Inter (substitutes smoothly) or fallback to Helvetica/Arial
- **Email:** body uses system stack → keeps emails light, no font load tax

## Don'ts

- ❌ Don't mix Geist with another sans (Inter, Manrope, etc.) on the same page
- ❌ Don't apply tracking > +0.05em on body — kills readability
- ❌ Don't go below 12px in product UI (broker accessibility — many wear glasses)
- ❌ Don't use italic for emphasis — use weight 600 instead (italic Geist looks awkward at small sizes)
- ❌ Don't all-caps anything longer than 3 words

## Bilingual considerations (FR/EN)

- French paragraphs run 15-20% longer than English. Reserve breathing room in CTAs and card layouts.
- Don't hyphenate body text in either language (no `hyphens: auto`) — looks sloppy.
- Use the typographic apostrophe `'` and the accentuated `à è é ç ê î ô û` in body — Geist supports them natively.
- Quebecois punctuation: French regular spaces around colons/quotes (not narrow non-breaking) is fine for web readability.

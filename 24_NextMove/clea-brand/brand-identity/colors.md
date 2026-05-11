# Klaris — Color System

> All colors in OKLCH (perceptually uniform). Hex equivalents provided for tools that don't support OKLCH yet (Canva, older browsers).
> Source of truth: [tokens.css](tokens.css).

---

## Primary palette

### Terracotta — Klaris's signature color

| Token | OKLCH | Hex (approx) | Use |
|-------|-------|--------------|-----|
| `--primary` | `oklch(0.55 0.18 30)` | `#C25A3A` | Default. CTAs, links, active nav, brand accents |
| `--primary-strong` | `oklch(0.45 0.20 28)` | `#A04124` | Hover states, pressed buttons |
| `--primary-foreground` | `oklch(0.99 0 0)` | `#FCFCFC` | Text on primary backgrounds |
| `--primary-soft` | `oklch(0.55 0.18 30 / 0.10)` | `#C25A3A` @ 10% | Subtle backgrounds (active nav row) |
| `--primary-mid` | `oklch(0.55 0.18 30 / 0.15)` | `#C25A3A` @ 15% | Hover backgrounds |

### Surfaces (light mode)

| Token | OKLCH | Hex | Use |
|-------|-------|-----|-----|
| `--background` | `oklch(0.98 0.005 60)` | `#FAF9F7` | Page background |
| `--card` | `oklch(1 0 0)` | `#FFFFFF` | Cards, modals |
| `--foreground` | `oklch(0.20 0.02 30)` | `#2A211D` | Body text |
| `--muted-foreground` | `oklch(0.50 0.02 30)` | `#7A6E68` | Secondary text |
| `--border` | `oklch(0.90 0.02 60)` | `#E5E0D9` | Dividers, card borders |
| `--muted` | `oklch(0.94 0.015 60)` | `#EFEAE3` | Disabled states, table headers |
| `--accent` | `oklch(0.92 0.03 45)` | `#EBE0D2` | Hover state for nav items |

### Surfaces (dark mode)

| Token | OKLCH | Hex | Use |
|-------|-------|-----|-----|
| `--background` | `oklch(0.13 0 0)` | `#1F1F1F` | Page background |
| `--card` | `oklch(0.17 0 0)` | `#2B2B2B` | Cards, modals |
| `--foreground` | `oklch(0.96 0 0)` | `#F5F5F5` | Body text |
| `--primary` (dark) | `oklch(0.68 0.18 28)` | `#E68B6A` | Lighter terracotta for legibility |

## Semantic palette

| Token | OKLCH (light) | Hex | Use |
|-------|---------------|-----|-----|
| `--success` | `oklch(0.60 0.15 145)` | `#4F9D5C` | Qualified prospects, success states |
| `--warning` | `oklch(0.75 0.15 75)` | `#D4A24E` | Pending action, deadlines approaching |
| `--destructive` | `oklch(0.55 0.22 25)` | `#C03A2E` | Errors, lost prospects, delete actions |
| `--info` | `oklch(0.60 0.15 230)` | `#4A87C2` | Informational notes, secondary CTAs |

## Heat scale (CRM scoring)

5-step gradient from cold (blue) to hot (red), used in dashboard prospect scoring.

| Level | OKLCH | Meaning |
|-------|-------|---------|
| `--heat-1` | `oklch(0.65 0.10 230)` | Cold lead |
| `--heat-2` | `oklch(0.70 0.12 200)` | Warming up |
| `--heat-3` | `oklch(0.75 0.15 75)` | Engaged |
| `--heat-4` | `oklch(0.65 0.18 50)` | Hot |
| `--heat-5` | `oklch(0.55 0.22 25)` | On fire — call now |

## Accessibility

All combinations below meet **WCAG 2.1 AA** (4.5:1 normal text, 3:1 large text):

| Foreground / Background | Ratio | Pass? |
|-------------------------|-------|-------|
| `--foreground` on `--background` | 12.4:1 | ✅ AAA |
| `--foreground` on `--card` | 13.7:1 | ✅ AAA |
| `--primary-foreground` on `--primary` | 5.1:1 | ✅ AA |
| `--muted-foreground` on `--background` | 5.2:1 | ✅ AA |
| `--primary` on `--background` | 4.6:1 | ✅ AA |

**Don't:**
- Don't use `--primary-soft` as text background — too light, won't pass AA on its own
- Don't combine `--warning` with white text — use foreground (dark)

## Hex export (for Canva, Figma, print specs)

Copy-paste palette for non-CSS tools:

```
Primary terracotta    #C25A3A
Primary strong        #A04124
Primary on white      #C25A3A on #FFFFFF
Background            #FAF9F7
Foreground            #2A211D
Card                  #FFFFFF
Border                #E5E0D9
Muted background      #EFEAE3
Muted text            #7A6E68
Success               #4F9D5C
Warning               #D4A24E
Destructive           #C03A2E
Info                  #4A87C2
Dark mode bg          #1F1F1F
Dark mode primary     #E68B6A
```

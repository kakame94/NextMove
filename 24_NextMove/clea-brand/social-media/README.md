# Cléa — Social Media Pack

> Profile pictures, banners, and 10 launch posts × 2 languages = full social kit, ready to publish.
> All files are SVG (vector, infinitely scalable, editable in Canva or any vector tool).

---

## Files

```
social-media/
├── README.md                              # this file
├── profile-1080.svg                       # Profile picture (square 1080×1080)
├── banner-linkedin-1584x396.svg           # LinkedIn cover
├── banner-instagram-1500x500.svg          # IG bio header (used as Twitter X header too)
├── banner-facebook-820x312.svg            # Facebook cover
└── posts/
    ├── 01-launch-announce-{fr,en}.svg     # "Cléa is here"
    ├── 02-pain-admin-{fr,en}.svg          # 30-60 min stat
    ├── 03-solution-chatbot-{fr,en}.svg    # SMS demo
    ├── 04-heat-scoring-{fr,en}.svg        # 5-level temperature
    ├── 05-bilingue-{fr,en}.svg            # FR/EN feature
    ├── 06-conformite-{fr,en}.svg          # OACIQ + Loi 25
    ├── 07-testimonial-{fr,en}.svg         # Joanel quote
    ├── 08-process-{fr,en}.svg             # 3-step process
    ├── 09-vs-status-quo-{fr,en}.svg       # Before/after
    └── 10-cta-demo-{fr,en}.svg            # Book a demo
```

20 posts total. All 1080×1080 (square format) — works on Instagram, Facebook, LinkedIn, X, Threads.

## Network specs

| Asset | Pixel size | Aspect ratio | File |
|-------|-----------|--------------|------|
| **Profile picture** (LinkedIn, IG, FB, X) | 1080×1080 | 1:1 | `profile-1080.svg` |
| **LinkedIn cover** | 1584×396 | 4:1 | `banner-linkedin-1584x396.svg` |
| **Instagram bio header** (or X cover) | 1500×500 | 3:1 | `banner-instagram-1500x500.svg` |
| **Facebook cover** | 820×312 | ≈ 2.6:1 | `banner-facebook-820x312.svg` |
| **Square posts** (IG / FB / LinkedIn / X) | 1080×1080 | 1:1 | `posts/*.svg` |

## Export to PNG / JPEG

The SVGs render directly in browsers and Canva. For PNG export:

**Method 1 — `rsvg-convert` (CLI, fastest)**
```bash
brew install librsvg     # macOS
sudo apt install librsvg2-bin   # Debian/Ubuntu

cd 24_NextMove/clea-brand/social-media
for f in posts/*.svg; do
  rsvg-convert -w 1080 -h 1080 "$f" -o "${f%.svg}.png"
done
```

**Method 2 — Inkscape (CLI)**
```bash
inkscape --export-type=png --export-width=1080 posts/01-launch-announce-fr.svg
```

**Method 3 — Canva**
1. Create new design → Custom size → 1080×1080
2. Upload SVG → drag onto canvas
3. Edit text directly in Canva → export PNG

**Method 4 — Browser**
Open SVG in Chrome → take screenshot at 1×, 2× (Retina), or 3× zoom for HD export.

## Usage rights / how to edit

All SVGs are **editable** — no rasterized text. Open in:
- **Figma** — File > Import (drops SVG as editable layers)
- **Inkscape** — File > Open
- **Canva** — Upload (some text styles may flatten to image; use Canva's text replacement)
- **Adobe Illustrator** — File > Open
- **VS Code** — direct text editing for power users

The Geist font is embedded by reference. If your tool doesn't support Geist, fall back to Inter (closest visual match).

## Design system applied

All assets use the [shared brand tokens](../brand-identity/tokens.css):
- Primary: `oklch(0.55 0.18 30)` — terracotta
- Background: `oklch(0.98 0.005 60)` — off-white
- Foreground: `oklch(0.20 0.02 30)` — near-black
- Geist font, weights 400/500/600/700

## Posting cadence (suggested)

| Day | Post | Network priority |
|-----|------|------------------|
| Day 0 | 01 — Launch announce | LinkedIn + IG + FB |
| Day 1 | 02 — Pain admin | LinkedIn (broker network) |
| Day 3 | 03 — Solution chatbot | IG + LinkedIn |
| Day 5 | 04 — Heat scoring | LinkedIn |
| Day 7 | 05 — Bilingual | LinkedIn + IG (FR/EN audiences) |
| Day 10 | 06 — Compliance | LinkedIn (target JP / franchises) |
| Day 12 | 07 — Testimonial | All networks |
| Day 15 | 08 — Process | IG (visual) |
| Day 18 | 09 — Before/after | LinkedIn |
| Day 21 | 10 — CTA demo | All networks (boost paid) |

Re-post each in EN on Day +1 if your audience is bilingual.

## Editing the posts

**Common edits:**
- **Text:** open SVG in any editor, find `<text>` tags, change content
- **Color:** every primary color is `oklch(0.55 0.18 30)` — find/replace globally if rebranding
- **Logo:** the `<g class="mark">` group is reused — copy from `profile-1080.svg` if needed elsewhere

If you find yourself making the same edit across multiple posts, edit one and use the same text-replacement pattern across the others.

# Mockups — Generation guide

> PNG mockups of the Cléa landing pages. Generated via Chrome headless.

---

## Files (after generation)

```
mockups/
├── desktop-fr.png    (1280×auto, full page)
├── desktop-en.png
├── mobile-fr.png     (375×auto, full page)
└── mobile-en.png
```

## Generate locally

**Prerequisites:** Google Chrome installed (any recent version).

```bash
# 1. Serve the landing pages
cd 24_NextMove/clea-brand/web-design
python3 -m http.server 8000 &
SERVER_PID=$!

# 2. Generate desktop (1280px) — FR
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-sandbox \
  --window-size=1280,900 \
  --hide-scrollbars \
  --screenshot=mockups/desktop-fr.png \
  --virtual-time-budget=4000 \
  http://localhost:8000/landing-fr.html

# 3. Desktop EN
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-sandbox \
  --window-size=1280,900 \
  --hide-scrollbars \
  --screenshot=mockups/desktop-en.png \
  --virtual-time-budget=4000 \
  http://localhost:8000/landing-en.html

# 4. Mobile FR (iPhone-like 375px)
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-sandbox \
  --window-size=375,812 \
  --hide-scrollbars \
  --screenshot=mockups/mobile-fr.png \
  --virtual-time-budget=4000 \
  http://localhost:8000/landing-fr.html

# 5. Mobile EN
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-sandbox \
  --window-size=375,812 \
  --hide-scrollbars \
  --screenshot=mockups/mobile-en.png \
  --virtual-time-budget=4000 \
  http://localhost:8000/landing-en.html

# 6. Stop server
kill $SERVER_PID
```

## Full-page screenshots

The default `--screenshot` flag captures only the viewport. For full-page captures, use the `--full-page` flag (Chrome 109+):

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu \
  --window-size=1280,900 \
  --hide-scrollbars \
  --full-page \
  --screenshot=mockups/desktop-fr-fullpage.png \
  --virtual-time-budget=6000 \
  http://localhost:8000/landing-fr.html
```

## Alternative: Puppeteer (better fidelity)

```bash
npm i -g puppeteer
node -e "
const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 900 });
  await page.goto('http://localhost:8000/landing-fr.html', { waitUntil: 'networkidle0' });
  await page.screenshot({ path: 'mockups/desktop-fr.png', fullPage: true });
  await browser.close();
})();
"
```

## Linux equivalent

Replace the Chrome path with `google-chrome` or `chromium`:
```bash
google-chrome --headless --disable-gpu --window-size=1280,900 \
  --screenshot=mockups/desktop-fr.png http://localhost:8000/landing-fr.html
```

## Why not commit PNG mockups directly?

PNGs of landing pages are derivative — they go stale every time HTML changes. Generate fresh on demand. Commit only if the user explicitly needs them in the repo for a specific deliverable (e.g. brand book PDF).

## Troubleshooting

- **Animations cut mid-frame:** increase `--virtual-time-budget` (in ms). Default 4000ms gives Motion library enough time to settle. Bump to 8000ms if needed.
- **Fonts not loading:** ensure `fonts.googleapis.com` is reachable. Headless Chrome respects same network policies as regular Chrome.
- **Dark mode mockup:** add `&theme=dark` to URL is not implemented — instead, manually toggle `localStorage.setItem('clea-theme', 'dark')` via `--evaluate-on-page-load` in Puppeteer.

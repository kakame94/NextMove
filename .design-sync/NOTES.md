# design-sync notes — @nextmove/ui

Design system: `packages/nextmove-ui` — the "Studio Engineering" aesthetic
extracted from the NextMove marketing sites (vitrine.html / index-v2.html).
Shape: **package** (no Storybook). 13 exported components.

## How this run went

- Built the DS package from scratch (`packages/nextmove-ui`), `npm run build`
  (tsup) → `dist/` with ESM + CJS + `.d.ts` + `dist/index.css`.
- Converter smoke-tested from repo root: `package-build.mjs` → `ds-bundle/`,
  then `package-validate.mjs --no-render-check` → **exit 0, bundle complete**,
  13 components, CSS closure wired (`styles.css` @imports `_ds_bundle.css`),
  23 tokens defined.
- **Upload NOT done.** `DesignSync` requires `/design-login` (interactive
  terminal); this was a non-interactive (`-p`) session. The local half is done
  and config is turnkey — finish with an interactive `/design-sync` run.

## Gotchas (already handled — here so a re-sync doesn't relearn)

- **Parent PostCSS/Tailwind collision.** `/Users/Eliot_1/CascadeProjects/postcss.config.js`
  requires `tailwindcss`, which tsup/esbuild walks up to and fails on. Fixed
  with a local no-op `packages/nextmove-ui/postcss.config.cjs`
  (`module.exports = { plugins: {} }`). Keep it.
- **`cssEntry` is package-relative**, not repo-relative. Correct value is
  `dist/index.css` (resolved against the package root = `dirname(--node-modules)`).
  `packages/nextmove-ui/dist/index.css` fails with "not found — skipped".
- **13 components, 10 src-matched.** `LiveBadge` (Tag.tsx), `MetricRow`
  (Metric.tsx), `TerminalLine` (Terminal.tsx) are co-located exports — they
  work fully; the 3 just don't get a sibling doc file for `.prompt.md`
  (synthesized from `.d.ts` + JSDoc instead). Not a problem.

## Re-sync command (interactive terminal, after /design-login)

```sh
cd <repo-root>
npm --prefix packages/nextmove-ui run build          # refresh dist/
node .ds-sync/package-build.mjs --config .design-sync/config.json \
  --node-modules ./packages/nextmove-ui/node_modules \
  --entry ./packages/nextmove-ui/dist/index.js --out ./ds-bundle
node .ds-sync/package-validate.mjs ./ds-bundle        # WITH render check (installs playwright/chromium)
```

Then the skill's §4 (author previews) + §5 (upload). First sync → new project,
incremental upload path.

## Known render warns

- `[RENDER_SKIPPED]` in this run's log is only because `--no-render-check` was
  passed (no chromium in a headless session). Not a real warn — drop it once the
  render check actually runs.

## Action required (unresolved)

- **[FONT_MISSING] — fonts not bundled.** The CSS references `"Inter"` and
  `"JetBrains Mono"` but ships no `@font-face`, so every design built with the DS
  falls back to system fonts. Both are OFL (Google Fonts) — free to ship. Fix on
  the interactive run: drop `Inter-*.woff2` + `JetBrainsMono-*.woff2` under
  `packages/nextmove-ui/src/styles/fonts/`, write a `fonts.css` with `@font-face`
  rules, and set `cfg.extraFonts: ["src/styles/fonts/fonts.css"]`. Or accept the
  system-font substitute (record the OK here) — but the terminal/mono look leans
  hard on JetBrains Mono, so shipping it is worth it.

## Re-sync risks

- Fonts (above) are the one open item — until resolved, previews render in
  fallback fonts and the DS pane shows a "missing brand fonts" banner.
- `dist/` must be rebuilt before every converter run — it's gitignored, so a
  fresh clone has no `dist/` until `npm run build`.
- Preview cards were never authored (§4 skipped — no upload target). Every
  component currently ships the **floor card**. Authoring previews is the main
  work left for a value-adding sync; do it on the interactive run.

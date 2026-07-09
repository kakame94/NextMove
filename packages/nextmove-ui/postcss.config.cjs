// Local no-op PostCSS config. Prevents tsup/esbuild from walking up to the
// monorepo-parent postcss.config.js (which requires Tailwind we don't use).
module.exports = { plugins: {} };

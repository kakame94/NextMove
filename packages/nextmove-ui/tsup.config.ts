import { defineConfig } from "tsup";

export default defineConfig({
  entry: ["src/index.ts"],
  format: ["esm", "cjs"],
  dts: true,
  sourcemap: true,
  clean: true,
  // Bundle the CSS imported from index.ts into dist/index.css
  injectStyle: false,
  loader: {
    ".css": "css",
  },
  external: ["react", "react-dom", "react/jsx-runtime"],
  // Expose a global for UMD-style consumers (Claude Design bundle runtime)
  globalName: "NextMoveUI",
  esbuildOptions(options) {
    options.jsx = "automatic";
  },
});

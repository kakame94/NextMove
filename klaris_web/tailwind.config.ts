import type { Config } from 'tailwindcss';

/**
 * Klaris design tokens — mirror du iOS app et du site vitrine
 * (klaris-presentation.html). OKLCH source de vérité.
 */
const config: Config = {
  content: ['./src/**/*.{ts,tsx}'],
  darkMode: ['class', '[data-theme="dark"]'],
  theme: {
    extend: {
      colors: {
        bg: 'oklch(var(--bg) / <alpha-value>)',
        fg: 'oklch(var(--fg) / <alpha-value>)',
        muted: 'oklch(var(--muted) / <alpha-value>)',
        'muted-fg': 'oklch(var(--muted-fg) / <alpha-value>)',
        card: 'oklch(var(--card) / <alpha-value>)',
        'card-elev': 'oklch(var(--card-elev) / <alpha-value>)',
        border: 'oklch(var(--border) / <alpha-value>)',
        primary: 'oklch(var(--primary) / <alpha-value>)',
        'primary-fg': 'oklch(var(--primary-fg) / <alpha-value>)',
        'primary-soft': 'oklch(var(--primary) / 0.10)',
        success: 'oklch(0.55 0.13 145 / <alpha-value>)',
        destructive: 'oklch(0.55 0.20 25 / <alpha-value>)',
        // Heat scale
        heat1: '#5C8BB0',
        heat2: '#8AB4D0',
        heat3: '#E0A836',
        heat4: '#E07A45',
        heat5: '#D64C2E',
      },
      fontFamily: {
        sans: ['Geist', 'ui-sans-serif', 'system-ui', '-apple-system', 'sans-serif'],
        mono: ['"Geist Mono"', 'ui-monospace', 'SFMono-Regular', 'monospace'],
      },
      borderRadius: {
        sm: '6px',
        DEFAULT: '10px',
        md: '14px',
        lg: '18px',
      },
      boxShadow: {
        sm: '0 1px 2px rgba(0,0,0,0.04)',
        DEFAULT: '0 4px 12px -4px rgba(0,0,0,0.06)',
        md: '0 8px 24px -8px rgba(0,0,0,0.10)',
        lg: '0 16px 48px -16px rgba(0,0,0,0.18)',
      },
    },
  },
  plugins: [],
};

export default config;

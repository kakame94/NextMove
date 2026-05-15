import type { Metadata } from 'next';
import './globals.css';
import { CadastreSplash } from '@/components/CadastreSplash';

export const metadata: Metadata = {
  title: 'Klaris · Adjointe IA des courtiers',
  description:
    "Klaris qualifie tes prospects par SMS, classe par température, propose les inscriptions Centris qui matchent — propulsée par Claude.",
  metadataBase: new URL('https://klarisapp.ai'),
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="fr">
      <body>
        <CadastreSplash />
        {children}
      </body>
    </html>
  );
}

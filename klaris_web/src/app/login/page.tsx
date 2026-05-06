'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { createClient } from '@/lib/supabase/client';

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    setLoading(false);
    if (error) {
      setError('Identifiants invalides.');
      return;
    }
    router.replace('/');
    router.refresh();
  }

  return (
    <main className="min-h-screen flex items-center justify-center px-6">
      <form onSubmit={onSubmit} className="w-full max-w-sm bg-card border border-border rounded-md p-8 shadow-md">
        <h1 className="text-2xl font-bold tracking-tight mb-1">Bienvenue sur Klaris</h1>
        <p className="text-sm text-muted-fg mb-6">Ton adjointe IA est prête à travailler.</p>

        <label className="block text-xs font-semibold uppercase tracking-wide text-muted-fg mb-1">
          Courriel
        </label>
        <input
          type="email"
          required
          autoComplete="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full mb-4 px-3 py-2 bg-bg border border-border rounded-sm text-sm focus:outline-none focus:border-primary"
        />

        <label className="block text-xs font-semibold uppercase tracking-wide text-muted-fg mb-1">
          Mot de passe
        </label>
        <input
          type="password"
          required
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full mb-4 px-3 py-2 bg-bg border border-border rounded-sm text-sm focus:outline-none focus:border-primary"
        />

        {error && (
          <p className="text-sm text-destructive mb-4" role="alert">
            {error}
          </p>
        )}

        <button
          type="submit"
          disabled={loading}
          className="w-full py-2.5 bg-primary text-primary-fg rounded-sm font-semibold disabled:opacity-50"
        >
          {loading ? '…' : 'Se connecter'}
        </button>

        <p className="mt-6 text-[10px] uppercase tracking-widest text-muted-fg text-center font-mono">
          OACIQ · Loi 25 · CASL · Hébergé au Canada
        </p>
      </form>
    </main>
  );
}

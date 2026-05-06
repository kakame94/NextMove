import { createClient } from '@/lib/supabase/server';
import { ProspectRow, type ProspectRowData } from '@/components/ProspectRow';
import { redirect } from 'next/navigation';

export const dynamic = 'force-dynamic'; // RLS-aware data must always be fresh

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: prospects, error } = await supabase
    .from('prospects')
    .select('id, nom, score, secteur, budget, delai, type')
    .order('score', { ascending: false })
    .limit(100);

  return (
    <main className="max-w-3xl mx-auto px-4 py-10">
      <header className="flex items-end justify-between mb-8">
        <div>
          <p className="text-[10px] uppercase tracking-widest text-muted-fg font-mono mb-1">
            Adjointe IA · web mirror
          </p>
          <h1 className="text-2xl font-bold tracking-tight">Prospects</h1>
        </div>
        <SignOutButton />
      </header>

      {error && <p className="text-sm text-destructive">Erreur : {error.message}</p>}

      {!error && (!prospects || prospects.length === 0) && (
        <p className="text-sm text-muted-fg">Aucun prospect pour l’instant.</p>
      )}

      {prospects && prospects.length > 0 && (
        <ul className="space-y-2">
          {(prospects as ProspectRowData[]).map((p) => (
            <li key={p.id}>
              <ProspectRow p={p} />
            </li>
          ))}
        </ul>
      )}

      <footer className="mt-12 text-center text-[10px] uppercase tracking-widest text-muted-fg font-mono">
        OACIQ · Loi 25 · CASL — v{process.env.NEXT_PUBLIC_APP_VERSION ?? '0.0.0'}
      </footer>
    </main>
  );
}

function SignOutButton() {
  // Server action — tiny inline form, no extra file.
  async function signOut() {
    'use server';
    const supabase = await createClient();
    await supabase.auth.signOut();
    redirect('/login');
  }
  return (
    <form action={signOut}>
      <button
        type="submit"
        className="text-xs text-muted-fg hover:text-destructive font-mono uppercase tracking-wider"
      >
        Se déconnecter
      </button>
    </form>
  );
}

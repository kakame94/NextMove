import Link from 'next/link';
import { notFound, redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { HeatChip } from '@/components/HeatIndicator';
import { RecommendationsList } from '@/components/RecommendationsList';

export const dynamic = 'force-dynamic';

interface PageProps {
  params: Promise<{ id: string }>;
}

function formatBudget(b: number | null) {
  if (b == null) return '—';
  if (b >= 1_000_000) return `${(b / 1_000_000).toFixed(2)}M$`;
  return `${Math.round(b / 1000)}K$`;
}

export default async function ProspectDetailPage({ params }: PageProps) {
  const { id } = await params;
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: p, error } = await supabase
    .from('prospects')
    .select('id, nom, telephone, score, secteur, budget, delai, type, pre_approuve')
    .eq('id', id)
    .single();

  if (error || !p) notFound();

  return (
    <main className="max-w-2xl mx-auto px-4 py-10">
      <Link href="/" className="text-xs text-primary font-semibold mb-6 inline-block">
        ← Tous les prospects
      </Link>

      <section className="bg-card border border-border rounded-md p-6 mb-8">
        <div className="flex items-start justify-between gap-3 mb-1">
          <h1 className="text-2xl font-bold tracking-tight truncate">{p.nom ?? '—'}</h1>
          <HeatChip score={p.score ?? 0} />
        </div>
        <p className="text-xs text-muted-fg font-mono mb-5">{p.telephone ?? '—'}</p>

        <dl className="grid grid-cols-[110px_1fr] gap-y-3 text-sm">
          <dt className="text-[10px] uppercase tracking-wider text-muted-fg font-mono self-center">
            Secteur
          </dt>
          <dd>{p.secteur ?? '—'}</dd>

          <dt className="text-[10px] uppercase tracking-wider text-muted-fg font-mono self-center">
            Budget
          </dt>
          <dd className="font-mono">{formatBudget(p.budget)}</dd>

          <dt className="text-[10px] uppercase tracking-wider text-muted-fg font-mono self-center">
            Délai
          </dt>
          <dd>{p.delai ?? '—'}</dd>

          <dt className="text-[10px] uppercase tracking-wider text-muted-fg font-mono self-center">
            Pré-approuvé
          </dt>
          <dd>{p.pre_approuve ? 'Oui' : '—'}</dd>

          <dt className="text-[10px] uppercase tracking-wider text-muted-fg font-mono self-center">
            Type
          </dt>
          <dd className="capitalize">{p.type ?? '—'}</dd>
        </dl>
      </section>

      <RecommendationsList prospectId={id} />
    </main>
  );
}

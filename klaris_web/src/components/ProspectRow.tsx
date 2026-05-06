import Link from 'next/link';
import { HeatDot, HeatChip } from './HeatIndicator';

export interface ProspectRowData {
  id: string;
  nom: string | null;
  score: number;
  secteur: string | null;
  budget: number | null;
  delai: string | null;
  type: string | null;
}

function formatBudget(b: number | null) {
  if (b == null) return '—';
  if (b >= 1_000_000) return `${(b / 1_000_000).toFixed(2)}M$`;
  return `${Math.round(b / 1000)}K$`;
}

export function ProspectRow({ p }: { p: ProspectRowData }) {
  return (
    <Link
      href={`/prospects/${p.id}`}
      className="flex items-center gap-3 px-4 py-3 bg-card border border-border rounded-md hover:border-primary/40 transition-colors"
    >
      <HeatDot score={p.score} />
      <div className="flex-1 min-w-0">
        <div className="text-sm font-semibold truncate">{p.nom ?? '—'}</div>
        <div className="text-xs text-muted-fg font-mono truncate">
          {[p.secteur, formatBudget(p.budget), p.delai].filter(Boolean).join(' · ') || '—'}
        </div>
      </div>
      <HeatChip score={p.score} />
    </Link>
  );
}

import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/react';
import { ProspectRow, type ProspectRowData } from '@/components/ProspectRow';

const base: ProspectRowData = {
  id: '00000000-0000-0000-0000-000000000001',
  nom: 'Tremblay',
  score: 7,
  secteur: 'Verdun',
  budget: 450000,
  delai: '3_mois',
  type: 'acheteur',
};

describe('ProspectRow', () => {
  it('renders name and score dot', () => {
    const { getByText, container } = render(<ProspectRow p={base} />);
    expect(getByText('Tremblay')).toBeInTheDocument();
    expect(container.querySelector('a')).toHaveAttribute('href', '/prospects/' + base.id);
  });

  it('formats budget < 1M as K$', () => {
    const { getByText } = render(<ProspectRow p={{ ...base, budget: 450000 }} />);
    expect(getByText(/450K\$/)).toBeInTheDocument();
  });

  it('formats budget >= 1M as M$', () => {
    const { getByText } = render(<ProspectRow p={{ ...base, budget: 1_250_000 }} />);
    expect(getByText(/1\.25M\$/)).toBeInTheDocument();
  });

  it('handles missing name with em-dash', () => {
    const { getByText } = render(<ProspectRow p={{ ...base, nom: null }} />);
    expect(getByText('—')).toBeInTheDocument();
  });

  it('handles all-null besoins gracefully', () => {
    const { container } = render(
      <ProspectRow p={{ ...base, secteur: null, budget: null, delai: null }} />
    );
    // Should still render without crashing
    expect(container.querySelector('a')).toBeInTheDocument();
  });
});

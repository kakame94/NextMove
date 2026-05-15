import { describe, it, expect } from 'vitest';
import { render } from '@testing-library/react';
import { HeatDot, HeatChip } from '@/components/HeatIndicator';

describe('HeatDot', () => {
  it('renders cold (score < 2) without shadow class', () => {
    const { container } = render(<HeatDot score={1} />);
    const span = container.querySelector('span')!;
    expect(span.className).toContain('bg-heat1');
    expect(span.className).not.toContain('shadow-');
  });

  it('renders scorching (score >= 8) with red shadow', () => {
    const { container } = render(<HeatDot score={9} />);
    const span = container.querySelector('span')!;
    expect(span.className).toContain('bg-heat5');
    expect(span.className).toContain('shadow-');
  });

  it('mid-range scores map to expected heat levels', () => {
    const cases: Array<[number, string]> = [
      [2, 'bg-heat2'],
      [4, 'bg-heat3'],
      [6, 'bg-heat4'],
      [8, 'bg-heat5'],
    ];
    for (const [score, expected] of cases) {
      const { container } = render(<HeatDot score={score} />);
      expect(container.querySelector('span')!.className).toContain(expected);
    }
  });

  it('handles edge cases — score 0 and 10', () => {
    const cold = render(<HeatDot score={0} />).container.querySelector('span')!;
    expect(cold.className).toContain('bg-heat1');

    const hot = render(<HeatDot score={10} />).container.querySelector('span')!;
    expect(hot.className).toContain('bg-heat5');
  });

  it('has aria-hidden — decorative, not announced', () => {
    const { container } = render(<HeatDot score={5} />);
    expect(container.querySelector('span')).toHaveAttribute('aria-hidden');
  });
});

describe('HeatChip', () => {
  it('displays score as N/10', () => {
    const { getByText } = render(<HeatChip score={7} />);
    expect(getByText('7/10')).toBeInTheDocument();
  });

  it('hot tone for score >= 8', () => {
    const { container } = render(<HeatChip score={9} />);
    expect(container.querySelector('span')!.className).toContain('D64C2E');
  });

  it('cold tone for score < 4', () => {
    const { container } = render(<HeatChip score={2} />);
    expect(container.querySelector('span')!.className).toContain('8AB4D0');
  });
});

import type { HTMLAttributes, ReactNode } from "react";

export interface BeliefCardProps extends Omit<HTMLAttributes<HTMLDivElement>, "title"> {
  /** Two-digit index shown as a large faded numeral, e.g. "01". */
  index: string;
  /** Belief title. */
  title: ReactNode;
  /** Belief body. Wrap key phrases in <b> for emphasis. */
  children: ReactNode;
}

/**
 * A numbered manifesto card: a big faded index numeral in the corner, a
 * bold title, and body copy. Grid several two-up for a beliefs section.
 */
export function BeliefCard({ index, title, className, children, ...rest }: BeliefCardProps) {
  return (
    <div className={["nm-belief", className].filter(Boolean).join(" ")} {...rest}>
      <span className="nm-belief__idx" aria-hidden="true">
        {index}
      </span>
      <h3 className="nm-belief__title">{title}</h3>
      <p className="nm-belief__body">{children}</p>
    </div>
  );
}
